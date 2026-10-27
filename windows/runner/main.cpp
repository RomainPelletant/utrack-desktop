// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// Brings the window of an already running UTD to the front. Clicks on
// notifications go to that instance: it registered the notification activator.
void ActivateRunningInstance() {
  HWND hwnd = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"UTD");
  if (!hwnd) {
    return;  // Still starting: no window yet.
  }
  ::ShowWindow(hwnd, ::IsIconic(hwnd) ? SW_RESTORE : SW_SHOW);
  ::SetForegroundWindow(hwnd);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // One UTD per user session; held until the process exits. Otherwise every
  // instance would poll and show the same notifications.
  ::CreateMutexW(nullptr, FALSE, L"Local\\RomainPelletant.UTD.SingleInstance");
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    ActivateRunningInstance();
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // WebView2 renders in software: its GPU process fails in Remote Desktop
  // sessions, virtual machines and with some drivers, leaving the page blank.
  // Read by the WebView2 loader when the environment is created; a value set
  // by the user wins.
  if (!::GetEnvironmentVariableW(L"WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS",
                                 nullptr, 0)) {
    ::SetEnvironmentVariableW(L"WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS",
                              L"--disable-gpu");
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");
  // Skia instead of Impeller (the default on Windows in Flutter 3.47): when the GPU
  // cannot be used (Remote Desktop, virtual machines, broken drivers), Skia
  // falls back to D3D11 WARP then to software rendering, while Impeller has
  // no software backend and leaves the whole window blank.
  project.set_impeller_switch(flutter::ImpellerSwitch::Disabled);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"UTD", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
