// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Keep running when the window is closed so notifications keep coming;
  // clicking the Dock icon brings the window back.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
    -> Bool
  {
    if !flag { mainFlutterWindow?.makeKeyAndOrderFront(nil) }
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
