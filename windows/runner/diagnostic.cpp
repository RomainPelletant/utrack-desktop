// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#include "diagnostic.h"

#include <dxgi.h>
#include <stdarg.h>
#include <stdio.h>
#include <windows.h>

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cstdint>
#include <string>
#include <thread>

#include "utils.h"

namespace diagnostic {
namespace {

// A blank window past this delay means Flutter could not render.
constexpr auto kFirstFrameTimeout = std::chrono::seconds(15);

// Shared with the C runtime streams and Dart, which open the same file.
constexpr DWORD kShareAll =
    FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE;

bool g_enabled = false;
std::wstring g_path;
std::atomic<bool> g_first_frame{false};

bool Requested() {
  bool requested = false;
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv != nullptr) {
    for (int i = 1; i < argc; i++) {
      if (wcscmp(argv[i], L"--diagnostic") == 0) {
        requested = true;
      }
    }
    ::LocalFree(argv);
  }
  wchar_t value[8];
  DWORD length = ::GetEnvironmentVariableW(L"UTD_DIAGNOSTIC", value, 8);
  if (length > 0 && length < 8 && wcscmp(value, L"0") != 0) {
    requested = true;
  }
  return requested;
}

// Native crashes (access violations…) never reach the Dart log.
LONG WINAPI OnUnhandledException(EXCEPTION_POINTERS* info) {
  const EXCEPTION_RECORD* record = info->ExceptionRecord;
  HMODULE module = nullptr;
  wchar_t path[MAX_PATH] = L"?";
  if (::GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                               GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           static_cast<LPCWSTR>(record->ExceptionAddress),
                           &module)) {
    ::GetModuleFileNameW(module, path, MAX_PATH);
  }
  const wchar_t* name = wcsrchr(path, L'\\');
  Log("Crash: exception 0x%08lX in %s+0x%llx", record->ExceptionCode,
      Utf8FromUtf16(name ? name + 1 : path).c_str(),
      static_cast<unsigned long long>(
          reinterpret_cast<uintptr_t>(record->ExceptionAddress) -
          reinterpret_cast<uintptr_t>(module)));
  return EXCEPTION_CONTINUE_SEARCH;  // Keeps Windows Error Reporting.
}

void LogSystem() {
  wchar_t exe[MAX_PATH];
  if (::GetModuleFileNameW(nullptr, exe, MAX_PATH)) {
    Log("Executable: %s", Utf8FromUtf16(exe).c_str());
  }

  // GetVersionEx lies to apps without a compatibility manifest entry.
  using RtlGetVersionFn = LONG(WINAPI*)(RTL_OSVERSIONINFOW*);
  auto rtl_get_version = reinterpret_cast<RtlGetVersionFn>(
      ::GetProcAddress(::GetModuleHandleW(L"ntdll.dll"), "RtlGetVersion"));
  RTL_OSVERSIONINFOW version = {sizeof(version)};
  if (rtl_get_version && rtl_get_version(&version) == 0) {
    Log("Windows %lu.%lu build %lu", version.dwMajorVersion,
        version.dwMinorVersion, version.dwBuildNumber);
  }

  // UTD is x64 only: it runs emulated on ARM64.
  using IsWow64Process2Fn = BOOL(WINAPI*)(HANDLE, USHORT*, USHORT*);
  auto is_wow64_process2 = reinterpret_cast<IsWow64Process2Fn>(
      ::GetProcAddress(::GetModuleHandleW(L"kernel32.dll"), "IsWow64Process2"));
  USHORT process_machine = 0;
  USHORT native_machine = 0;
  if (is_wow64_process2 && is_wow64_process2(::GetCurrentProcess(),
                                             &process_machine,
                                             &native_machine)) {
    Log("CPU: %s", native_machine == IMAGE_FILE_MACHINE_ARM64
                       ? "ARM64 (x64 emulation)"
                   : native_machine == IMAGE_FILE_MACHINE_AMD64 ? "x64"
                                                                : "other");
  }

  Log("Remote Desktop session: %s",
      ::GetSystemMetrics(SM_REMOTESESSION) ? "yes" : "no");
  HDC screen = ::GetDC(nullptr);
  Log("Monitors: %d, system DPI: %d", ::GetSystemMetrics(SM_CMONITORS),
      ::GetDeviceCaps(screen, LOGPIXELSX));
  ::ReleaseDC(nullptr, screen);

  // What Skia and WebView2 can render with (a blank window often comes from
  // the GPU): "Microsoft Basic Render Driver" is the software adapter.
  IDXGIFactory1* factory = nullptr;
  if (FAILED(::CreateDXGIFactory1(__uuidof(IDXGIFactory1),
                                  reinterpret_cast<void**>(&factory)))) {
    Log("GPU: DXGI unavailable");
    return;
  }
  IDXGIAdapter1* adapter = nullptr;
  for (UINT i = 0; factory->EnumAdapters1(i, &adapter) != DXGI_ERROR_NOT_FOUND;
       i++) {
    DXGI_ADAPTER_DESC1 desc;
    if (SUCCEEDED(adapter->GetDesc1(&desc))) {
      Log("GPU %u: %s (vendor 0x%04X, device 0x%04X, %llu MB%s)", i,
          Utf8FromUtf16(desc.Description).c_str(), desc.VendorId,
          desc.DeviceId,
          static_cast<unsigned long long>(desc.DedicatedVideoMemory >> 20),
          desc.Flags & DXGI_ADAPTER_FLAG_SOFTWARE ? ", software" : "");
    }
    adapter->Release();
  }
  factory->Release();
}

}  // namespace

void Start() {
  if (!Requested()) {
    return;
  }
  wchar_t local_app_data[MAX_PATH];
  DWORD length =
      ::GetEnvironmentVariableW(L"LOCALAPPDATA", local_app_data, MAX_PATH);
  if (length == 0 || length >= MAX_PATH) {
    return;
  }
  std::wstring dir = std::wstring(local_app_data) + L"\\UTD";
  ::CreateDirectoryW(dir.c_str(), nullptr);  // Fails when it already exists.
  g_path = dir + L"\\utd-diagnostic.log";

  // A new log at each launch.
  HANDLE file = ::CreateFileW(g_path.c_str(), GENERIC_WRITE, kShareAll,
                              nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL,
                              nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    return;
  }
  ::CloseHandle(file);
  g_enabled = true;

  // Read by lib/app_log.dart.
  ::SetEnvironmentVariableW(L"UTD_DIAGNOSTIC_LOG", g_path.c_str());
  ::SetUnhandledExceptionFilter(OnUnhandledException);

  Log("UTD diagnostic mode");

  // Output of the runner and plugins, as a bonus: the log does not depend on
  // it, as a GUI app has no valid standard streams to start with.
  // flutter_windows.dll has its own C runtime: the engine output is never
  // captured, hence the Dart log writing to the file directly.
  FILE* unused;
  if (_wfreopen_s(&unused, g_path.c_str(), L"a", stdout) == 0 &&
      _wfreopen_s(&unused, g_path.c_str(), L"a", stderr) == 0) {
    setvbuf(stdout, nullptr, _IONBF, 0);
    setvbuf(stderr, nullptr, _IONBF, 0);
  } else {
    Log("Runner and plugin output not captured");
  }

  LogSystem();

  std::thread([] {
    std::this_thread::sleep_for(kFirstFrameTimeout);
    if (!g_first_frame) {
      Log("No Flutter frame after %lld s: the window stays blank",
          static_cast<long long>(kFirstFrameTimeout.count()));
    }
  }).detach();
}

void Log(const char* format, ...) {
  if (!g_enabled) {
    return;
  }
  char message[1024];
  va_list args;
  va_start(args, format);
  vsnprintf(message, sizeof(message), format, args);
  va_end(args);
  SYSTEMTIME time;
  ::GetLocalTime(&time);
  char line[1100];
  int length = snprintf(line, sizeof(line),
                        "%04d-%02d-%02dT%02d:%02d:%02d.%03d [native] %s\n",
                        time.wYear, time.wMonth, time.wDay, time.wHour,
                        time.wMinute, time.wSecond, time.wMilliseconds, message);
  if (length <= 0) {
    return;
  }
  // Opened for each line, like the Dart log: FILE_APPEND_DATA writes at the
  // end even when the C runtime streams or Dart wrote in between.
  HANDLE file = ::CreateFileW(g_path.c_str(), FILE_APPEND_DATA, kShareAll,
                              nullptr, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL,
                              nullptr);
  if (file == INVALID_HANDLE_VALUE) {
    return;
  }
  // snprintf returns the untruncated length.
  size_t size = std::min(static_cast<size_t>(length), sizeof(line) - 1);
  DWORD written;
  ::WriteFile(file, line, static_cast<DWORD>(size), &written, nullptr);
  ::CloseHandle(file);
}

void MarkFirstFrame() {
  g_first_frame = true;
}

void Finish(int exit_code) {
  if (!g_enabled) {
    return;
  }
  Log("Exit (code %d)", exit_code);
  // Shows users which file to attach to their bug report.
  std::wstring arguments = L"/select,\"" + g_path + L"\"";
  ::ShellExecuteW(nullptr, nullptr, L"explorer.exe", arguments.c_str(),
                  nullptr, SW_SHOWNORMAL);
}

}  // namespace diagnostic
