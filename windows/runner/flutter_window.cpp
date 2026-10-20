// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#include "flutter_window.h"

#include <flutter/standard_method_codec.h>

#include <optional>
#include <string>

#include "flutter/generated_plugin_registrant.h"

namespace {

// App entries of the system menu. Command IDs must be below 0xF000 with the
// low four bits clear (Windows uses them internally for WM_SYSCOMMAND).
struct AppCommand {
  UINT id;
  const char* label_key;  // Key in the "setMenuLabels" map.
  const char* method;     // Method invoked on the Dart side.
};

constexpr AppCommand kAppCommands[] = {
    {0x1000, "changeServer", "changeServer"},
    {0x1010, "notifications", "notificationSettings"},
    {0x1020, "about", "about"},
};

std::wstring Utf16FromUtf8(const std::string& utf8) {
  if (utf8.empty()) {
    return std::wstring();
  }
  int length = ::MultiByteToWideChar(CP_UTF8, 0, utf8.data(),
                                     static_cast<int>(utf8.size()), nullptr, 0);
  std::wstring utf16(length, L'\0');
  ::MultiByteToWideChar(CP_UTF8, 0, utf8.data(), static_cast<int>(utf8.size()),
                        utf16.data(), length);
  return utf16;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  app_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "utd/app",
      &flutter::StandardMethodCodec::GetInstance());
  app_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        HandleAppMethodCall(call, std::move(result));
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::HandleAppMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (call.method_name() == "setMenuLabels") {
    if (const auto* labels =
            std::get_if<flutter::EncodableMap>(call.arguments())) {
      SetSystemMenuLabels(*labels);
    }
    result->Success();
  } else if (call.method_name() == "showWindow") {
    HWND hwnd = GetHandle();
    ::ShowWindow(hwnd, ::IsIconic(hwnd) ? SW_RESTORE : SW_SHOW);
    ::SetForegroundWindow(hwnd);
    result->Success();
  } else {
    result->NotImplemented();
  }
}

void FlutterWindow::SetSystemMenuLabels(const flutter::EncodableMap& labels) {
  HMENU menu = ::GetSystemMenu(GetHandle(), FALSE);
  if (!menu) {
    return;
  }
  for (const auto& command : kAppCommands) {
    ::DeleteMenu(menu, command.id, MF_BYCOMMAND);
  }
  if (!system_menu_separator_added_) {
    ::AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
    system_menu_separator_added_ = true;
  }
  for (const auto& command : kAppCommands) {
    auto it = labels.find(flutter::EncodableValue(std::string(command.label_key)));
    if (it == labels.end()) {
      continue;
    }
    if (const auto* label = std::get_if<std::string>(&it->second)) {
      ::AppendMenuW(menu, MF_STRING, command.id, Utf16FromUtf8(*label).c_str());
    }
  }
}

void FlutterWindow::OnDestroy() {
  app_channel_ = nullptr;
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_SYSCOMMAND:
      for (const auto& command : kAppCommands) {
        if ((wparam & 0xFFF0) == command.id) {
          if (app_channel_) {
            app_channel_->InvokeMethod(command.method, nullptr);
          }
          return 0;
        }
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
