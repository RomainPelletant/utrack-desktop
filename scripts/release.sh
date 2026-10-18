#!/bin/bash
# Builds and packages UTD. Used by .github/workflows/release.yml and locally.
#
# Usage:
#   scripts/release.sh macos            # → release/UTD-<v>-macos.dmg (universal)
#   scripts/release.sh linux            # → release/UTD-<v>-linux-<arch>.tar.gz + .deb
#   scripts/release.sh flatpak          # → release/UTD-<v>-linux-<arch>.flatpak
#   scripts/release.sh windows          # → release/UTD-<v>-windows-x64.zip + -setup.exe
#   scripts/release.sh notes [<v>]      # prints the CHANGELOG.md section of <v>
#   scripts/release.sh version          # prints the pubspec.yaml version
#
# macOS signing (all optional; without APPLE_SIGN_ID_APP the app is ad-hoc
# signed and notarization is skipped):
#   APPLE_SIGN_ID_APP    "Developer ID Application: Name (TEAMID)"
#   APPLE_ACCOUNT_ID     Apple ID used for notarization
#   APPLE_TEAM_ID        Team ID
#   APPLE_APP_PASSWORD   App-specific password of APPLE_ACCOUNT_ID
#
# Set SKIP_BUILD=1 to package an existing `flutter build` output.
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="UTD"
PACKAGE_NAME="utrack-desktop"   # Debian package
LINUX_BINARY="utd"              # linux/CMakeLists.txt BINARY_NAME
LINUX_APP_ID="io.github.romainpelletant.utrack_desktop"   # linux/CMakeLists.txt APPLICATION_ID
VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)"
OUTPUT_DIR="release"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { echo -e "\n${BLUE}▶ $1${NC}" >&2; }
ok()   { echo -e "${GREEN}✓ $1${NC}" >&2; }
warn() { echo -e "${YELLOW}⚠ $1${NC}" >&2; }
err()  { echo -e "${RED}✗ $1${NC}" >&2; exit 1; }

size() { du -sh "$1" | awk '{print $1}'; }

build() {
  if [ "${SKIP_BUILD:-0}" = "1" ]; then
    warn "SKIP_BUILD=1: packaging the existing build"
  else
    step "[$1] flutter build $1 --release"
    flutter build "$1" --release
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# Release notes: the "## [<version>]" section of CHANGELOG.md
# ══════════════════════════════════════════════════════════════════════════════
release_notes() {
  local version="${1:-$VERSION}"
  local notes
  notes="$(awk -v header="## [${version}]" '
    index($0, header) == 1 { found = 1; next }
    found && /^## \[/       { exit }
    found && /^\[[^]]+\]: / { next }   # link references at the end of the file
    found                   { print }
  ' CHANGELOG.md)"
  [ -n "$(echo "$notes" | tr -d '[:space:]')" ] \
    || err "No \"## [${version}]\" section in CHANGELOG.md"
  echo "$notes"
}

# ══════════════════════════════════════════════════════════════════════════════
# macOS → signed, notarized, universal .dmg
# ══════════════════════════════════════════════════════════════════════════════
release_macos() {
  local app="build/macos/Build/Products/Release/${APP_NAME}.app"
  local dmg="$OUTPUT_DIR/${APP_NAME}-${VERSION}-macos.dmg"
  local staging
  local identity="${APPLE_SIGN_ID_APP:-}"

  build macos
  [ -d "$app" ] || err "Missing $app"
  lipo -info "$app/Contents/MacOS/$APP_NAME" >&2

  # Sign inside-out: nested code first, then the app with its entitlements
  # (sandbox, network, files). `codesign --deep` would drop the entitlements.
  local sign_args=(--force)
  if [ -n "$identity" ]; then
    step "[macOS] Signing with: $identity"
    # Hardened runtime and secure timestamp are required for notarization.
    sign_args+=(--options runtime --timestamp --sign "$identity")
  else
    # No hardened runtime here: its library validation rejects ad-hoc signed
    # frameworks ("different Team IDs") and the app would not launch.
    warn "APPLE_SIGN_ID_APP not set: ad-hoc signature, no notarization"
    sign_args+=(--sign -)
  fi

  local frameworks="$app/Contents/Frameworks"
  if [ -d "$frameworks" ]; then
    find "$frameworks" -type f -name "*.dylib" -print0 |
      while IFS= read -r -d '' lib; do codesign "${sign_args[@]}" "$lib"; done
    find "$frameworks" -maxdepth 1 -name "*.framework" -print0 |
      while IFS= read -r -d '' fw; do codesign "${sign_args[@]}" "$fw"; done
  fi
  codesign "${sign_args[@]}" \
    --entitlements macos/Runner/Release.entitlements "$app"
  codesign --verify --deep --strict --verbose=2 "$app"
  ok "Signature valid"

  step "[macOS] Creating DMG..."
  staging="$(mktemp -d)"
  cp -R "$app" "$staging/"
  ln -s /Applications "$staging/Applications"
  rm -f "$dmg"
  hdiutil create -volname "$APP_NAME" -srcfolder "$staging" \
    -ov -format UDZO -fs HFS+ "$dmg" >&2
  rm -rf "$staging"

  if [ -n "$identity" ]; then
    codesign --force --timestamp --sign "$identity" "$dmg"
    step "[macOS] Notarizing (this can take a few minutes)..."
    xcrun notarytool submit "$dmg" \
      --apple-id "${APPLE_ACCOUNT_ID:?APPLE_ACCOUNT_ID is required}" \
      --team-id "${APPLE_TEAM_ID:?APPLE_TEAM_ID is required}" \
      --password "${APPLE_APP_PASSWORD:?APPLE_APP_PASSWORD is required}" \
      --wait
    # Attach the ticket so Gatekeeper accepts the app offline.
    xcrun stapler staple "$dmg"
    xcrun stapler validate "$dmg"
    ok "Notarized and stapled"
  fi
  ok "DMG → $dmg ($(size "$dmg"))"
}

# ══════════════════════════════════════════════════════════════════════════════
# Linux → .tar.gz + .deb
# ══════════════════════════════════════════════════════════════════════════════
release_linux() {
  local flutter_arch deb_arch
  case "$(uname -m)" in
    x86_64)        flutter_arch=x64;   deb_arch=amd64 ;;
    aarch64|arm64) flutter_arch=arm64; deb_arch=arm64 ;;
    *) err "Unsupported architecture: $(uname -m)" ;;
  esac
  local bundle="build/linux/${flutter_arch}/release/bundle"
  local tarball="$OUTPUT_DIR/${APP_NAME}-${VERSION}-linux-${deb_arch}.tar.gz"
  local deb="$OUTPUT_DIR/${PACKAGE_NAME}_${VERSION}_${deb_arch}.deb"

  build linux
  [ -x "$bundle/$LINUX_BINARY" ] || err "Missing $bundle/$LINUX_BINARY"

  step "[Linux] Creating tar.gz..."
  rm -f "$tarball"
  tar -czf "$tarball" -C "$bundle" --transform "s,^\.,${APP_NAME}," .
  ok "tar.gz → $tarball ($(size "$tarball"))"

  step "[Linux] Creating .deb..."
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/DEBIAN" "$root/usr/bin" "$root/usr/lib/$PACKAGE_NAME" \
    "$root/usr/share/applications" "$root/usr/share/pixmaps"
  cp -R "$bundle/." "$root/usr/lib/$PACKAGE_NAME/"
  ln -s "/usr/lib/$PACKAGE_NAME/$LINUX_BINARY" "$root/usr/bin/$LINUX_BINARY"
  cp assets/icon/utd_logo.png "$root/usr/share/pixmaps/$LINUX_BINARY.png"

  # Named after the GTK application ID so Wayland docks match the window.
  cat > "$root/usr/share/applications/$LINUX_APP_ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
GenericName=YouTrack client
Comment=Desktop client for YouTrack
Exec=/usr/bin/$LINUX_BINARY
Icon=$LINUX_BINARY
StartupWMClass=$LINUX_BINARY
Terminal=false
Categories=Development;ProjectManagement;
EOF

  cat > "$root/DEBIAN/control" <<EOF
Package: $PACKAGE_NAME
Version: $VERSION
Architecture: $deb_arch
Maintainer: Romain Pelletant <romain.pelletant@sixtaupi.com>
Installed-Size: $(du -sk "$root/usr" | awk '{print $1}')
Depends: libgtk-3-0t64 | libgtk-3-0, libwpewebkit-2.0-1 (>= 2.50), libwpe-1.0-1, libwpebackend-fdo-1.0-1, libepoxy0, libsecret-1-0
Section: devel
Priority: optional
Homepage: https://github.com/${GITHUB_REPOSITORY:-romainpelletant/utrack-desktop}
Description: Desktop client for YouTrack
 UTD embeds a YouTrack instance in a desktop window and shows the
 YouTrack notification center as desktop notifications.
 YouTrack is a trademark of JetBrains s.r.o. UTD is an independent
 project, not affiliated with or endorsed by JetBrains.
EOF

  rm -f "$deb"
  dpkg-deb --build --root-owner-group "$root" "$deb" >&2
  rm -rf "$root"
  ok ".deb → $deb ($(size "$deb"))"
}

# ══════════════════════════════════════════════════════════════════════════════
# Linux → .flatpak bundle (WPE WebKit included, any distribution)
# ══════════════════════════════════════════════════════════════════════════════
release_flatpak() {
  local deb_arch
  case "$(uname -m)" in
    x86_64)        deb_arch=amd64 ;;
    aarch64|arm64) deb_arch=arm64 ;;
    *) err "Unsupported architecture: $(uname -m)" ;;
  esac
  local manifest="linux/flatpak/${LINUX_APP_ID}.yml"
  local repo="build/flatpak-repo"
  local bundle="$OUTPUT_DIR/${APP_NAME}-${VERSION}-linux-${deb_arch}.flatpak"

  command -v flatpak-builder >/dev/null || err "flatpak-builder is not installed"
  if [ -n "${FLUTTER_VERSION:-}" ] &&
    ! grep -q "FLUTTER_VERSION: ${FLUTTER_VERSION}\$" "$manifest"; then
    err "FLUTTER_VERSION in $manifest is not $FLUTTER_VERSION"
  fi

  flatpak remote-add --user --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

  step "[Flatpak] Building (the first build compiles WPE WebKit: 1–2 h)..."
  flatpak-builder --user --install-deps-from=flathub --force-clean \
    --disable-rofiles-fuse --repo="$repo" build/flatpak "$manifest" >&2

  step "[Flatpak] Creating bundle..."
  rm -f "$bundle"
  # The GNOME runtime is installed from Flathub along with the bundle.
  flatpak build-bundle \
    --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo \
    "$repo" "$bundle" "$LINUX_APP_ID"
  ok "flatpak → $bundle ($(size "$bundle"))"
}

# ══════════════════════════════════════════════════════════════════════════════
# Windows → portable .zip
# ══════════════════════════════════════════════════════════════════════════════
release_windows() {
  local release_dir="build/windows/x64/runner/Release"
  local zip="$OUTPUT_DIR/${APP_NAME}-${VERSION}-windows-x64.zip"

  build windows
  [ -f "$release_dir/${APP_NAME}.exe" ] || err "Missing $release_dir/${APP_NAME}.exe"
  # Installed by windows/CMakeLists.txt (InstallRequiredSystemLibraries).
  local dll
  for dll in msvcp140.dll vcruntime140.dll vcruntime140_1.dll; do
    [ -f "$release_dir/$dll" ] || err "Missing MSVC runtime $release_dir/$dll"
  done

  step "[Windows] Creating zip..."
  local staging
  staging="$(mktemp -d)"
  cp -R "$release_dir" "$staging/$APP_NAME"
  rm -f "$zip"
  # Windows' own bsdtar (no zip in Git Bash). Not Compress-Archive: Windows
  # PowerShell 5.1 stores "\" in entry names, so other tools see flat files
  # named "UTD\data\...". Not Git Bash's tar either: it can't write zips.
  "$(cygpath -u "${SYSTEMROOT:-C:\\Windows}")/System32/tar.exe" -a -c \
    -f "$(cygpath -w "$zip")" -C "$(cygpath -w "$staging")" "$APP_NAME"
  rm -rf "$staging"
  ok "zip → $zip ($(size "$zip"))"

  step "[Windows] Creating installer..."
  local iscc setup="$OUTPUT_DIR/${APP_NAME}-${VERSION}-windows-x64-setup.exe"
  iscc="$(command -v iscc || true)"
  [ -n "$iscc" ] || iscc="$(cygpath -u "${PROGRAMFILES:-C:\\Program Files} (x86)")/Inno Setup 6/ISCC.exe"
  [ -x "$iscc" ] || err "Inno Setup 6 is not installed (choco install innosetup)"
  rm -f "$setup"
  # MSYS_NO_PATHCONV: Git Bash would turn the "/D..." switches into paths
  # ("C:/Program Files/Git/DAppVersion=..."), which ISCC reads as scripts.
  MSYS_NO_PATHCONV=1 "$iscc" /Q \
    "/DAppVersion=$VERSION" \
    "/DSourceDir=$(cygpath -w "$PWD/$release_dir")" \
    "/DOutputDir=$(cygpath -w "$PWD/$OUTPUT_DIR")" \
    windows/installer/utd.iss >&2
  ok "installer → $setup ($(size "$setup"))"
}

# ══════════════════════════════════════════════════════════════════════════════
case "${1:-}" in
  macos|linux|flatpak|windows)
    mkdir -p "$OUTPUT_DIR"
    echo -e "${BLUE}${APP_NAME} ${VERSION} — $1 release${NC}" >&2
    "release_$1"
    ;;
  notes)   release_notes "${2:-}" ;;
  version) echo "$VERSION" ;;
  *)
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
