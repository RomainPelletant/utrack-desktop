# Changelog

All notable changes to UTD are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Security: UTD only opens pages of your YouTrack server when asked by a notification
  click or another process. Look-alike addresses such as
  `https://yt.example.com.evil.net` were accepted, and could show a fake login page in
  the window, which has no address bar.
- Security: links to other apps only open when you click them in the page, and only
  e-mail (`mailto:`), phone (`tel:`) and JetBrains Toolbox (`jetbrains:`) links. Others
  (`file:`, `smb:`, `ms-*:`, `search-ms:`…) are ignored, so a script in the page can no
  longer open local files or programs.
- Windows: diagnostic mode (`--diagnostic`) no longer stops after the first line of
  `utd-diagnostic.log`.
- Windows: no more blank window without explanation. UTD now says when the Microsoft
  Edge WebView2 Runtime is missing, with a link to download it, and shows an error with
  a Retry button when the web view does not start (Remote Desktop, virtual machines,
  security software blocking WebView2).
- Windows: no more blank window for old graphics drivers/platforms, usefull for remote
  desktop session, virtual machines and with
  some graphics drivers. The web view renders in software (no GPU; set
  `WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS` to override it) and the rest of the window
  falls back to software rendering when the GPU cannot be used.
- Linux: notifications now work without a password service (GNOME Keyring, KWallet) or
  with a locked one. UTD keeps the token until it quits, never in a file, and says so in
  the notification settings.

### Added

- Diagnostic mode, for when UTD does not start or stays blank: start it with
  `--diagnostic` (Windows: the **UTD (diagnostic)** Start menu shortcut) and it logs every
  step of its startup (system, graphics card, Flutter engine, web view, errors and
  crashes) to `utd-diagnostic.log`, then shows this file when you quit. Attach it to your
  bug report; it never contains the token. Works on Windows, macOS and Linux; see the
  README.
- Windows: a diagnostic log in `%LOCALAPPDATA%\UTD\utd.log` (UTD and WebView2 versions,
  web view errors) to attach to bug reports. It never contains the token.
- Nightly builds: every merge to master publishes the `nightly` pre-release on GitHub
  (macOS, Windows, Linux), to test fixes before they are released.

## [1.0.2] - 2026-10-20

### Fixed

- Windows: the page no longer stays blank when UTD is installed for all users. The web
  view now keeps its data in `%LOCALAPPDATA%\UTD\WebView2`; you need to sign in to
  YouTrack again once.

## [1.0.1] - 2026-10-20

### Fixed

- macOS: dropdowns in the page (issue fields such as State, Assignee or Priority, menus)
  now open on click.

## [1.0.0] - 2026-10-18

First release.

### Added

- **YouTrack desktop client**: the app shows the web interface of a YouTrack instance in
  a full window.
- **Server selection** on first launch. The address is remembered, and `https://` is
  added when omitted. The server can be changed at any time.
- **Platforms**: macOS, Windows and Linux.
  - macOS: **UTD** menu, **Navigation** menu (Back ⌘[, Forward ⌘], Reload ⌘R), full
    **Edit** menu (copy and paste), and a "Change Server…" entry in the right-click menu.
  - Windows: app actions in the window system menu (Alt+Space).
  - Linux: app actions in the page right-click menu.
- **Desktop notifications** from the YouTrack notification center, using a permanent
  token stored in the system vault. Clicking a notification opens the issue or article.
  On macOS, the Dock icon badge shows the unread count and the app keeps running when the
  window is closed.
  The **Notifications…** window shows the last check (time, unread count) and explains
  failures: rejected token, unreadable keychain item, server error, notifications blocked by
  the system (with a shortcut to the system settings).
- **35 languages**, picked from the system language. English is the default.
- **Links**:
  - external links and `mailto:`, `tel:`, etc. links open in the system apps;
  - links that open a new window stay in the app when they point to the YouTrack server.
- Error screen, with "Retry" and "Change server", when the server cannot be reached.
- **About** window with the license and the JetBrains trademark notice, and the list of
  third-party licenses.
- App icon.
- Apache 2.0 license (`LICENSE` and `NOTICE` files).

### Known issues

- The Windows version has not been built or tested yet.
- Linux requires WPE WebKit 2.50 or later. The web view relies on a pre-release (beta) of
  `flutter_inappwebview`.
- Notifications use `/api/inbox`, an undocumented YouTrack API (the one used by the
  YouTrack Mobile app). JetBrains may change it without notice.
- On Windows and Linux, closing the window quits the app and stops notifications.

[Unreleased]: https://github.com/romainpelletant/utrack-desktop/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/romainpelletant/utrack-desktop/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/romainpelletant/utrack-desktop/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/romainpelletant/utrack-desktop/releases/tag/v1.0.0
