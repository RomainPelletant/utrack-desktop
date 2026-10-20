# AGENTS.md

Guidance for AI coding agents working on UTD (utrack-desktop): a Flutter desktop app
(macOS, Windows, Linux) that embeds a YouTrack instance in a webview and polls its
notification center.

## Layout

- `lib/main.dart`: app entry, single-instance check, native menus, `utd/app` method channel.
- `lib/screens/`: server setup, YouTrack webview (`flutter_inappwebview`), notification settings.
- `lib/notifications/`: YouTrack API client (`/api/inbox/threads`), polling service,
  token storage (`flutter_secure_storage`).
- `lib/server_store.dart`: remembered server URL (`shared_preferences`).
- `lib/system_l10n.dart`: supported locales (English first) and localized strings outside widgets.
- `lib/l10n/`: generated translations, **do not edit by hand** (see below).
- Native runners: `macos/Runner` (Swift), `windows/runner` (C++), `linux/runner` (GTK, C).
  The `utd/app` channel is implemented in `MainFlutterWindow.swift` and `flutter_window.cpp`.
- `scripts/release.sh`: build and package per platform; `scripts/sbom.py`: CycloneDX SBOM.
- `tool/l10n.py`: single source of truth for every translation.

## Translations

All strings (Flutter UI and native macOS menus) live in `tool/l10n.py`, 35 languages.
To add or change a string:

1. Add the key to the right list (`FLUTTER_KEYS`, `NATIVE_KEYS`, …) and a translation
   for **every** language in the matching dict.
2. Run `python3 tool/l10n.py && flutter gen-l10n`.
3. Commit the regenerated `lib/l10n/*` and `macos/Runner/*.lproj` files.

CI fails if the generated files are not up to date.

## Checks (same as CI)

```bash
flutter pub get
python3 tool/l10n.py && flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
shellcheck scripts/*.sh
```

Run them before considering a change done.

## Conventions

- Flutter version is pinned in `.github/workflows/{ci,release,vulnerabilities}.yml`
  (`FLUTTER_VERSION`): keep the three in sync.
- Format with `dart format`; lints are `flutter_lints` (native folders are excluded from analysis).
- Behaviour differs per platform (menus, closing the window, unread badge): check
  macOS, Windows and Linux when touching `main.dart` or native code.
- Never log or persist the YouTrack token outside the secure storage.
- Record user-visible changes in `CHANGELOG.md` under `[Unreleased]` (Keep a Changelog).
- Linux builds need WPE WebKit ≥ 2.50 (Debian testing in CI, Flatpak for users).

## Releases

Pushing a `v*` tag runs `.github/workflows/release.yml`; release notes come from the
matching `CHANGELOG.md` section and the version from `pubspec.yaml`.

## Legal

UTD is not affiliated with JetBrains: do not use JetBrains or YouTrack branding
(logos, names as product name) in the app or assets.
