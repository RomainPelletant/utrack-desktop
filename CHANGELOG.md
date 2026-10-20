# Changelog

All notable changes to UTD are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
