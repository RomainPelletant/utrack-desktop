#!/bin/bash
# SPDX-FileCopyrightText: 2026 Romain Pelletant
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/upload_app_store.sh /path/to/file.pkg [--wait]

Required environment variables:
  APP_STORE_CONNECT_API_KEY      App Store Connect API key ID
  APP_STORE_CONNECT_ISSUER_ID    App Store Connect issuer ID

Optional environment variables:
  APP_STORE_CONNECT_P8_FILE      Path to the AuthKey .p8 file
  APP_STORE_CONNECT_APPLE_ID     Numeric Apple ID, used for build status polling
  APP_BUNDLE_VERSION             CFBundleVersion, used with APP_STORE_CONNECT_APPLE_ID
  APP_SHORT_VERSION              CFBundleShortVersionString, used with APP_STORE_CONNECT_APPLE_ID

Examples:
  export APP_STORE_CONNECT_API_KEY=ABC123DEF4
  export APP_STORE_CONNECT_ISSUER_ID=01234567-89ab-cdef-0123-456789abcdef
  export APP_STORE_CONNECT_P8_FILE="$HOME/Keys/AuthKey_ABC123DEF4.p8"
  scripts/upload_app_store.sh build/macos/Runner.pkg

  export APP_STORE_CONNECT_APPLE_ID=1234567890
  export APP_BUNDLE_VERSION=1
  export APP_SHORT_VERSION=0.9.6
  scripts/upload_app_store.sh release/mac7z.pkg --wait
EOF
}

err() {
  echo "error: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "missing required command: $1"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

[ $# -ge 1 ] || {
  usage
  exit 1
}

FILE_PATH="$1"
WAIT_MODE=0

if [ "${2:-}" = "--wait" ]; then
  WAIT_MODE=1
elif [ $# -ge 2 ]; then
  err "unknown argument: $2"
fi

[ -f "$FILE_PATH" ] || err "file not found: $FILE_PATH"
[ -n "${APP_STORE_CONNECT_API_KEY:-}" ] || err "APP_STORE_CONNECT_API_KEY is required"
[ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ] || err "APP_STORE_CONNECT_ISSUER_ID is required"

need_cmd xcrun
need_cmd mktemp

ALTOOL_ARGS=(
  --output-format json
  --show-progress
  --api-key "$APP_STORE_CONNECT_API_KEY"
  --api-issuer "$APP_STORE_CONNECT_ISSUER_ID"
)

TMP_KEY_DIR=""
cleanup() {
  if [ -n "$TMP_KEY_DIR" ] && [ -d "$TMP_KEY_DIR" ]; then
    rm -rf "$TMP_KEY_DIR"
  fi
}
trap cleanup EXIT

if [ -n "${APP_STORE_CONNECT_P8_FILE:-}" ]; then
  [ -f "$APP_STORE_CONNECT_P8_FILE" ] || err "p8 file not found: $APP_STORE_CONNECT_P8_FILE"
  TMP_KEY_DIR="$(mktemp -d)"
  cp "$APP_STORE_CONNECT_P8_FILE" "$TMP_KEY_DIR/AuthKey_${APP_STORE_CONNECT_API_KEY}.p8"
  export API_PRIVATE_KEYS_DIR="$TMP_KEY_DIR"
fi

case "$FILE_PATH" in
  *.pkg|*.ipa)
    UPLOAD_CMD=(--upload-package "$FILE_PATH")
    ;;
  *)
    UPLOAD_CMD=(--upload-app -f "$FILE_PATH")
    ;;
esac

echo "Uploading $FILE_PATH to App Store Connect..."
xcrun altool "${UPLOAD_CMD[@]}" "${ALTOOL_ARGS[@]}"

if [ "$WAIT_MODE" -eq 1 ]; then
  [ -n "${APP_STORE_CONNECT_APPLE_ID:-}" ] || err "APP_STORE_CONNECT_APPLE_ID is required with --wait"
  [ -n "${APP_BUNDLE_VERSION:-}" ] || err "APP_BUNDLE_VERSION is required with --wait"
  [ -n "${APP_SHORT_VERSION:-}" ] || err "APP_SHORT_VERSION is required with --wait"

  echo "Waiting for App Store Connect processing..."
  xcrun altool \
    --build-status \
    --apple-id "$APP_STORE_CONNECT_APPLE_ID" \
    --bundle-version "$APP_BUNDLE_VERSION" \
    --bundle-short-version-string "$APP_SHORT_VERSION" \
    --platform macos \
    --wait \
    "${ALTOOL_ARGS[@]}"
fi

