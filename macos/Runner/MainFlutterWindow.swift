// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import Cocoa
import FlutterMacOS
import Metal
import UserNotifications
import WebKit

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    Diagnostic.start()
    let flutterViewController = FlutterViewController()
    Diagnostic.log("Flutter engine created")
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    Diagnostic.log("Plugins registered")

    let channel = FlutterMethodChannel(
      name: "utd/app",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setBadge":
        // Unread notification count on the Dock icon; nil clears it.
        NSApp.dockTile.badgeLabel = call.arguments as? String
        result(nil)
      case "showWindow":
        self?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        result(nil)
      case "isDuplicateInstance":
        result(SingleInstance.running != nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    WebViewContextMenu.install(channel: channel)
    WebViewMouseDown.install(channel: channel)
    AppMenu.install(channel: channel)
    if SingleInstance.running != nil {
      SingleInstance.handOff(window: self)
    } else {
      SingleInstance.listen(channel: channel, window: self)
    }

    super.awakeFromNib()
  }
}

/// Diagnostic mode, started by `open -a UTD --args --diagnostic` or
/// UTD_DIAGNOSTIC=1. From the very start, native steps, the Flutter engine
/// output (stdout/stderr) and the Dart log (lib/app_log.dart, told the path
/// through UTD_DIAGNOSTIC_LOG) go to utd-diagnostic.log in the app's Logs
/// folder (sandbox container), for users to attach to bug reports. It must
/// never contain the token or page contents.
enum Diagnostic {
  /// The log file, or nil outside the diagnostic mode.
  static let url: URL? = {
    let value = ProcessInfo.processInfo.environment["UTD_DIAGNOSTIC"] ?? ""
    let requested =
      CommandLine.arguments.contains("--diagnostic") || !(value.isEmpty || value == "0")
    // A duplicate copy quits at once: it must not wipe the running one's log.
    guard requested, SingleInstance.running == nil else { return nil }
    return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Logs/UTD/utd-diagnostic.log")
  }()
  private static var enabled = false

  private static let timestamp: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    return formatter
  }()

  static func start() {
    guard let url, !enabled else { return }
    // A new log at each launch. Both streams then append, so that they do not
    // overwrite each other (nor the Dart log, written to the same file).
    try? FileManager.default.createDirectory(
      at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard FileManager.default.createFile(atPath: url.path, contents: nil),
      freopen(url.path, "a", stdout) != nil, freopen(url.path, "a", stderr) != nil
    else { return }
    setvbuf(stdout, nil, _IONBF, 0)
    setvbuf(stderr, nil, _IONBF, 0)
    enabled = true
    setenv("UTD_DIAGNOSTIC_LOG", url.path, 1)
    // Logs the exit and shows users which file to attach to their bug report.
    NotificationCenter.default.addObserver(
      forName: NSApplication.willTerminateNotification, object: nil, queue: nil
    ) { _ in
      log("Quit")
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    NSSetUncaughtExceptionHandler { exception in
      Diagnostic.log(
        "Uncaught exception: \(exception.name.rawValue) \(exception.reason ?? "")\n"
          + exception.callStackSymbols.joined(separator: "\n"))
    }

    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    log("UTD \(version) diagnostic mode")
    log("Executable: \(Bundle.main.bundlePath)")
    log("macOS \(ProcessInfo.processInfo.operatingSystemVersionString)")
    log("Model: \(model), \(cpu)")
    log("GPU: \(MTLCreateSystemDefaultDevice()?.name ?? "no Metal device")")
    for screen in NSScreen.screens {
      log("Screen: \(Int(screen.frame.width))x\(Int(screen.frame.height)) @\(screen.backingScaleFactor)x")
    }
  }

  /// Appends a line to the log; does nothing outside the diagnostic mode.
  static func log(_ message: String) {
    guard enabled else { return }
    fputs("\(timestamp.string(from: Date())) [native] \(message)\n", stderr)
  }

  private static var model: String {
    var size = 0
    guard sysctlbyname("hw.model", nil, &size, nil, 0) == 0, size > 0 else { return "?" }
    var buffer = [CChar](repeating: 0, count: size)
    sysctlbyname("hw.model", &buffer, &size, nil, 0)
    return String(cString: buffer)
  }

  private static var cpu: String {
    #if arch(arm64)
      return "arm64"
    #else
      var translated: Int32 = 0
      var size = MemoryLayout<Int32>.size
      sysctlbyname("sysctl.proc_translated", &translated, &size, nil, 0)
      return translated == 1 ? "x86_64 (Rosetta)" : "x86_64"
    #endif
  }
}

/// Keeps a single UTD running. macOS may launch another copy with the same
/// bundle ID (e.g. a build next to the installed app) when a notification is
/// clicked: that copy hands the notification's URL to the running one and
/// quits.
final class SingleInstance: NSObject, UNUserNotificationCenterDelegate {
  private static let shared = SingleInstance()
  private static let openURL = Notification.Name("io.github.romainpelletant.utrack-desktop.openUrl")

  /// The copy launched before this one, if this one is a duplicate.
  static let running: NSRunningApplication? = {
    let me = NSRunningApplication.current
    guard let id = Bundle.main.bundleIdentifier, let launched = me.launchDate else { return nil }
    // Launch order breaks the tie when two copies start together.
    return NSRunningApplication.runningApplications(withBundleIdentifier: id).first {
      $0 != me && !$0.isTerminated
        && ($0.launchDate ?? .distantPast, $0.processIdentifier)
          < (launched, me.processIdentifier)
    }
  }()

  private var handedOff = false

  /// Running copy: opens the URLs handed over by duplicates.
  static func listen(channel: FlutterMethodChannel, window: NSWindow) {
    DistributedNotificationCenter.default().addObserver(
      forName: openURL, object: nil, queue: .main
    ) { note in
      if let url = note.object as? String, !url.isEmpty {
        channel.invokeMethod("openUrl", arguments: url)
      } else {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }

  /// Duplicate: hides its window, catches the click on the notification that
  /// launched it (instead of the notifications plugin) and quits.
  static func handOff(window: NSWindow) {
    window.alphaValue = 0
    DispatchQueue.main.async { window.orderOut(nil) }
    UNUserNotificationCenter.current().delegate = shared
    // Launched another way (Finder, Dock): no click comes.
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { shared.handOff(url: nil) }
  }

  private func handOff(url: String?) {
    guard !handedOff else { return }
    handedOff = true
    // Sandboxed apps can't send a userInfo: the URL goes in the object.
    DistributedNotificationCenter.default().postNotificationName(
      Self.openURL, object: url ?? "", userInfo: nil, deliverImmediately: true)
    Self.running?.activate(options: [])
    NSApp.terminate(nil)
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let url =
      response.actionIdentifier == UNNotificationDefaultActionIdentifier
      // Key used by flutter_local_notifications.
      ? response.notification.request.content.userInfo["payload"] as? String : nil
    completionHandler()
    handOff(url: url)
  }
}

/// Looks up a native string in <lang>.lproj/Localizable.strings
/// (generated by tool/l10n.py).
func L(_ key: String) -> String {
  NSLocalizedString(key, comment: "")
}

/// Builds the localized macOS menu bar. Flutter's PlatformMenuBar is not used:
/// it replaces the whole menu bar and cannot provide the Edit menu that gives
/// copy/paste to the web view.
final class AppMenu: NSObject {
  private static let shared = AppMenu()
  private var channel: FlutterMethodChannel?

  static func install(channel: FlutterMethodChannel) {
    shared.channel = channel
    let appName = ProcessInfo.processInfo.processName
    let mainMenu = NSMenu()

    let services = NSMenu(title: L("menu.services"))
    mainMenu.addSubmenu(appName, [
      item(String(format: L("menu.about"), appName), #selector(showAbout), target: shared),
      item(L("menu.licenses"), #selector(showLicenses), target: shared),
      .separator(),
      item(L("menu.changeServer"), #selector(changeServer), target: shared),
      item(L("menu.notifications"), #selector(notificationSettings), target: shared),
      .separator(),
      submenuItem(services),
      .separator(),
      item(String(format: L("menu.hide"), appName), #selector(NSApplication.hide(_:)), "h"),
      item(L("menu.hideOthers"), #selector(NSApplication.hideOtherApplications(_:)), "h",
           [.command, .option]),
      item(L("menu.showAll"), #selector(NSApplication.unhideAllApplications(_:))),
      .separator(),
      item(String(format: L("menu.quit"), appName), #selector(NSApplication.terminate(_:)), "q"),
    ])
    NSApp.servicesMenu = services

    mainMenu.addSubmenu(L("menu.edit"), [
      item(L("menu.undo"), Selector(("undo:")), "z"),
      item(L("menu.redo"), Selector(("redo:")), "z", [.command, .shift]),
      .separator(),
      item(L("menu.cut"), #selector(NSText.cut(_:)), "x"),
      item(L("menu.copy"), #selector(NSText.copy(_:)), "c"),
      item(L("menu.paste"), #selector(NSText.paste(_:)), "v"),
      item(L("menu.pasteAndMatchStyle"), #selector(NSTextView.pasteAsPlainText(_:)), "v",
           [.command, .option, .shift]),
      item(L("menu.delete"), #selector(NSText.delete(_:))),
      item(L("menu.selectAll"), #selector(NSText.selectAll(_:)), "a"),
    ])

    mainMenu.addSubmenu(L("menu.view"), [
      item(L("menu.enterFullScreen"), #selector(NSWindow.toggleFullScreen(_:)), "f",
           [.command, .control]),
    ])

    // Nil-targeted WKWebView actions: they reach the web view through the
    // responder chain and are enabled only when they apply.
    mainMenu.addSubmenu(L("menu.navigation"), [
      item(L("menu.back"), #selector(WKWebView.goBack(_:)), "["),
      item(L("menu.forward"), #selector(WKWebView.goForward(_:)), "]"),
      .separator(),
      item(L("menu.reload"), #selector(WKWebView.reload(_:)), "r"),
    ])

    let window = mainMenu.addSubmenu(L("menu.window"), [
      item(L("menu.minimize"), #selector(NSWindow.performMiniaturize(_:)), "m"),
      item(L("menu.zoom"), #selector(NSWindow.performZoom(_:))),
      .separator(),
      item(L("menu.bringAllToFront"), #selector(NSApplication.arrangeInFront(_:))),
    ])
    NSApp.windowsMenu = window

    NSApp.helpMenu = mainMenu.addSubmenu(L("menu.help"), [])
    NSApp.mainMenu = mainMenu
  }

  private static func item(
    _ title: String, _ action: Selector, _ key: String = "",
    _ modifiers: NSEvent.ModifierFlags = .command, target: AnyObject? = nil
  ) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
    item.keyEquivalentModifierMask = modifiers
    item.target = target
    return item
  }

  private static func submenuItem(_ menu: NSMenu) -> NSMenuItem {
    let item = NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
    item.submenu = menu
    return item
  }

  @objc private func changeServer() {
    channel?.invokeMethod("changeServer", arguments: nil)
  }

  @objc private func notificationSettings() {
    channel?.invokeMethod("notificationSettings", arguments: nil)
  }

  /// Opens Flutter's license page (this app and all its dependencies).
  @objc private func showLicenses() {
    channel?.invokeMethod("showLicenses", arguments: nil)
  }

  /// Standard About panel, with the license and the JetBrains trademark notice.
  @objc private func showAbout() {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let credits = NSAttributedString(
      string: L("about.license") + "\n\n" + L("about.trademark"),
      attributes: [
        .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
        .foregroundColor: NSColor.secondaryLabelColor,
        .paragraphStyle: paragraph,
      ])
    NSApp.orderFrontStandardAboutPanel(options: [.credits: credits])
    NSApp.activate(ignoringOtherApps: true)
  }
}

extension NSMenu {
  @discardableResult
  fileprivate func addSubmenu(_ title: String, _ items: [NSMenuItem]) -> NSMenu {
    let menu = NSMenu(title: title)
    items.forEach(menu.addItem)
    let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    item.submenu = menu
    addItem(item)
    return menu
  }
}

/// Adds app entries to the web view's native right-click menu.
/// flutter_inappwebview does not support context menus on macOS, so this
/// hooks WKWebView.willOpenMenu(_:with:) directly.
final class WebViewContextMenu: NSObject {
  private static let shared = WebViewContextMenu()
  private static let itemTag = 0x7574_7263  // "utrc"
  private var channel: FlutterMethodChannel?

  static func install(channel: FlutterMethodChannel) {
    shared.channel = channel

    let cls: AnyClass = WKWebView.self
    let originalSel = #selector(NSView.willOpenMenu(_:with:))
    let swizzledSel = #selector(WKWebView.utd_willOpenMenu(_:with:))
    guard let original = class_getInstanceMethod(cls, originalSel),
      let swizzled = class_getInstanceMethod(cls, swizzledSel)
    else { return }

    // If WKWebView only inherits the method, add it to WKWebView rather than
    // swapping NSView's implementation for every view in the app.
    if class_addMethod(
      cls, originalSel, method_getImplementation(swizzled), method_getTypeEncoding(swizzled))
    {
      class_replaceMethod(
        cls, swizzledSel, method_getImplementation(original), method_getTypeEncoding(original))
    } else {
      method_exchangeImplementations(original, swizzled)
    }
  }

  static func addItems(to menu: NSMenu) {
    guard menu.item(withTag: itemTag) == nil else { return }
    let item = NSMenuItem(
      title: L("menu.changeServer"), action: #selector(changeServer), keyEquivalent: "")
    item.target = shared
    item.tag = itemTag
    menu.addItem(.separator())
    menu.addItem(item)
  }

  @objc private func changeServer() {
    channel?.invokeMethod("changeServer", arguments: nil)
  }
}

/// flutter_inappwebview_macos delays the web view's mouse-down events until a
/// round trip to Dart has cleared Flutter's focus (workaround for its issue
/// #2380). WebKit then gets the mouse-up first, no click fires and YouTrack's
/// dropdowns (issue fields, menus) never open. This hands the events straight
/// to WKWebView and clears Flutter's focus without waiting.
enum WebViewMouseDown {
  private typealias Handler = @convention(c) (AnyObject, Selector, NSEvent) -> Void

  static func install(channel: FlutterMethodChannel) {
    guard let cls = NSClassFromString("flutter_inappwebview_macos.InAppWebView") else { return }
    let selectors = [
      #selector(NSResponder.mouseDown(with:)),
      #selector(NSResponder.rightMouseDown(with:)),
      #selector(NSResponder.otherMouseDown(with:)),
    ]
    for sel in selectors {
      let webKitImp = class_getMethodImplementation(WKWebView.self, sel)
      // Only replace the plugin's own overrides, never WKWebView's.
      guard let method = class_getInstanceMethod(cls, sel), let webKitImp,
        method_getImplementation(method) != webKitImp
      else { continue }
      let webKitHandler = unsafeBitCast(webKitImp, to: Handler.self)
      let block: @convention(block) (AnyObject, NSEvent) -> Void = { view, event in
        channel.invokeMethod("unfocus", arguments: nil)
        webKitHandler(view, sel, event)
      }
      method_setImplementation(method, imp_implementationWithBlock(block))
    }
  }
}

extension WKWebView {
  @objc func utd_willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
    // Swizzled: this calls the original implementation.
    utd_willOpenMenu(menu, with: event)
    WebViewContextMenu.addItems(to: menu)
  }
}
