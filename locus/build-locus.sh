#!/bin/bash
# Local-only Locus.app / Locus.dmg. Do not wire into GitHub Actions.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
VER="$(tr -d '[:space:]' < "$ROOT/VERSION")"
OUT="${LOCUS_OUT:-$ROOT/dist}"
APP="$OUT/Locus.app"
DMG="$OUT/Locus-$VER.dmg"
mkdir -p "$OUT"

if ! command -v swiftc >/dev/null 2>&1; then
  echo "swiftc fehlt — auf dem Mac ausführen." >&2
  exit 1
fi

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"

swiftc -O -parse-as-library \
  -target arm64-apple-macos14.0 \
  -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
  -framework SwiftUI -framework AppKit -framework MapKit -framework CoreLocation -framework Combine \
  -o "$APP/Contents/MacOS/Locus" \
  "$ROOT/Sources/"*.swift

chmod +x "$APP/Contents/MacOS/Locus"

SIGN_APP="$REPO/macos/ci-sign.sh"
if [ "${1:-}" = "sign" ] && [ -x "$SIGN_APP" ]; then
  IDENTITY="${APPLE_CODESIGN_IDENTITY:--}"
  codesign --force --sign "$IDENTITY" --options runtime --timestamp=none \
    --entitlements "$ROOT/Locus.entitlements" "$APP" || true
  "$SIGN_APP" app "$APP" || true
fi

hdiutil create -volname "Locus $VER" -srcfolder "$APP" -ov -format UDZO "$DMG"
echo "built $APP"
echo "built $DMG"
