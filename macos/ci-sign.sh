#!/bin/bash
# Sign Aegis.app / Aegis.dmg with Developer ID, then notarize.
# Secrets stay in the environment. Never echo their values.
#
#   macos/ci-sign.sh app  path/to/Aegis.app
#   macos/ci-sign.sh dmg  path/to/Aegis.dmg
set -euo pipefail

CMD="${1:-}"
TARGET="${2:-}"
if [ "$CMD" != "app" ] && [ "$CMD" != "dmg" ]; then
  echo "usage: macos/ci-sign.sh app|dmg <path>" >&2
  exit 2
fi
[ -e "$TARGET" ] || { echo "missing $TARGET" >&2; exit 1; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENTITLEMENTS="$ROOT/macos/AegisScanner.entitlements"
STATE="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/aegis-sign-state"
mkdir -p "$(dirname "$STATE")"

first_nonempty() {
  for v in "$@"; do
    if [ -n "${v}" ]; then
      printf '%s' "$v"
      return 0
    fi
  done
  return 1
}

CERT_B64="$(first_nonempty \
  "${APPLE_CERTIFICATE:-}" \
  "${BUILD_CERTIFICATE_BASE64:-}" \
  "${APPLE_CERTIFICATE_BASE64:-}" \
  "${BUILD_CERTIFICATE:-}" \
  "${P12_BASE64:-}" \
  "${CERTIFICATE_BASE64:-}" \
  "${MACOS_CERTIFICATE:-}" \
  "${CSC_LINK:-}" || true)"
CERT_PW="$(first_nonempty \
  "${P12_PASSWORD:-}" \
  "${APPLE_CERTIFICATE_PASSWORD:-}" \
  "${CERTIFICATE_PASSWORD:-}" \
  "${CSC_KEY_PASSWORD:-}" \
  "${CERT_PASSWORD:-}" || true)"
TEAM_ID="$(first_nonempty \
  "${APPLE_TEAM_ID:-}" \
  "${TEAM_ID:-}" || true)"
WANT_ID="$(first_nonempty \
  "${APPLE_CODESIGN_IDENTITY:-}" \
  "${CODESIGN_IDENTITY:-}" \
  "${APPLE_IDENTITY:-}" || true)"
APPLE_ID_USER="$(first_nonempty \
  "${APPLE_ID:-}" \
  "${APPLE_ID_USERNAME:-}" \
  "${APPLEID:-}" || true)"
APPLE_ID_PASS="$(first_nonempty \
  "${APPLE_APP_SPECIFIC_PASSWORD:-}" \
  "${APPLE_ID_PASSWORD:-}" \
  "${APPLE_PASSWORD:-}" \
  "${AC_PASSWORD:-}" \
  "${APPLEIDPASS:-}" \
  "${APPLE_APP_PASSWORD:-}" \
  "${NOTARYTOOL_PASSWORD:-}" \
  "${APP_PASSWORD:-}" \
  "${APPLE_ID_APP_PASSWORD:-}" \
  "${NOTARY_PASSWORD:-}" \
  "${APP_SPECIFIC_PASSWORD:-}" || true)"
API_KEY="$(first_nonempty \
  "${APP_STORE_CONNECT_API_KEY:-}" \
  "${APPLE_API_KEY:-}" \
  "${API_KEY_P8:-}" || true)"
API_KEY_ID="$(first_nonempty \
  "${APP_STORE_CONNECT_API_KEY_ID:-}" \
  "${APPLE_API_KEY_ID:-}" \
  "${API_KEY_ID:-}" || true)"
API_ISSUER="$(first_nonempty \
  "${APP_STORE_CONNECT_ISSUER_ID:-}" \
  "${APPLE_ISSUER_ID:-}" \
  "${ISSUER_ID:-}" || true)"
KC_PASS="$(first_nonempty \
  "${KEYCHAIN_PASSWORD:-}" \
  "aegis-ci-keychain" || true)"

MODE="adhoc"
IDENTITY="-"
if [ -f "$STATE" ]; then
  # shellcheck disable=SC1090
  . "$STATE"
fi

write_state() {
  umask 077
  cat > "$STATE" <<EOF
MODE=${MODE}
IDENTITY=$(printf '%q' "$IDENTITY")
KC_PATH=$(printf '%q' "${KC_PATH:-}")
EOF
}

write_signing_txt() {
  local dir
  dir="$(cd "$(dirname "$TARGET")" && pwd)"
  {
    echo "mode=${MODE}"
    echo "identity=${IDENTITY}"
  } > "${dir}/signing.txt"
}

import_cert() {
  [ -n "$CERT_B64" ] || return 1
  local tmp raw
  tmp="$(mktemp "${TMPDIR:-/tmp}/aegis-cert.XXXXXX")"
  raw="$CERT_B64"
  if printf '%s' "$raw" | grep -q 'BEGIN '; then
    printf '%s\n' "$raw" > "$tmp"
  else
    raw="$(printf '%s' "$raw" | tr -d '\n\r ')"
    raw="${raw#data:application/x-pkcs12;base64,}"
    raw="${raw#data:application/pkcs12;base64,}"
    if ! printf '%s' "$raw" | base64 --decode > "$tmp" 2>/dev/null; then
      echo "certificate decode failed" >&2
      rm -f "$tmp"
      return 1
    fi
  fi
  KC_PATH="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/aegis-signing.keychain-db"
  rm -f "$KC_PATH"
  security create-keychain -p "$KC_PASS" "$KC_PATH"
  security set-keychain-settings -lut 21600 "$KC_PATH"
  security unlock-keychain -p "$KC_PASS" "$KC_PATH"
  security list-keychains -d user -s "$KC_PATH" $(security list-keychains -d user | tr -d '"')
  security default-keychain -s "$KC_PATH"
  local imported=0
  # Identity + key. `-t cert -f pkcs12` drops the private key → ad-hoc fallback.
  if security import "$tmp" -k "$KC_PATH" -P "$CERT_PW" -A \
      -T /usr/bin/codesign -T /usr/bin/security >/dev/null 2>&1; then
    imported=1
  elif security import "$tmp" -k "$KC_PATH" -P "$CERT_PW" -A -t cert -f pkcs12 \
      -T /usr/bin/codesign -T /usr/bin/security >/dev/null 2>&1; then
    imported=1
  elif security import "$tmp" -k "$KC_PATH" -A \
      -T /usr/bin/codesign -T /usr/bin/security >/dev/null 2>&1; then
    imported=1
  fi
  rm -f "$tmp"
  [ "$imported" -eq 1 ] || return 1
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KC_PASS" "$KC_PATH" >/dev/null 2>&1 || true
  local found
  found="$(security find-identity -v -p codesigning "$KC_PATH" | awk -F'"' '/Developer ID Application/{print $2; exit}')"
  if [ -z "$found" ]; then
    found="$(security find-identity -v -p codesigning "$KC_PATH" | awk -F'"' '/Apple Development|Developer ID/{print $2; exit}')"
  fi
  if [ -n "$WANT_ID" ]; then
    IDENTITY="$WANT_ID"
  elif [ -n "$found" ]; then
    IDENTITY="$found"
  else
    echo "no codesign identity in keychain" >&2
    return 1
  fi
  MODE="developer-id"
  echo "codesign identity ready"
}

if [ "$IDENTITY" = "-" ] && [ -n "$CERT_B64" ]; then
  if import_cert; then
    :
  else
    echo "certificate import failed — ad-hoc fallback" >&2
    IDENTITY="-"
    MODE="adhoc"
  fi
elif [ "$IDENTITY" = "-" ]; then
  echo "no certificate secret — ad-hoc sign"
fi

if [ "$CMD" = "app" ]; then
  extra=(--timestamp=none)
  if [ "$IDENTITY" != "-" ]; then
    extra=(--timestamp)
  fi
  codesign --force --sign "$IDENTITY" \
    --options runtime \
    "${extra[@]}" \
    --entitlements "$ENTITLEMENTS" \
    "$TARGET"
  codesign --verify --deep --strict "$TARGET"
  write_state
  write_signing_txt
  echo "app signed (${MODE})"
  exit 0
fi

if [ "$IDENTITY" != "-" ]; then
  codesign --force --sign "$IDENTITY" --timestamp "$TARGET"
  codesign --verify "$TARGET" || true
fi

if [ "$MODE" = "developer-id" ] || [ "$MODE" = "developer-id-unnotarized" ]; then
  keyp8="${TMPDIR:-/tmp}/aegis-notary.p8"
  set +e
  if [ -n "$API_KEY" ] && [ -n "$API_KEY_ID" ] && [ -n "$API_ISSUER" ]; then
    if printf '%s' "$API_KEY" | grep -q 'BEGIN PRIVATE KEY'; then
      printf '%s\n' "$API_KEY" > "$keyp8"
    else
      printf '%s' "$API_KEY" | base64 --decode > "$keyp8" 2>/dev/null || printf '%s\n' "$API_KEY" > "$keyp8"
    fi
    xcrun notarytool submit "$TARGET" \
      --key "$keyp8" \
      --key-id "$API_KEY_ID" \
      --issuer "$API_ISSUER" \
      --wait --timeout 180
    st=$?
    rm -f "$keyp8"
  elif [ -n "$APPLE_ID_USER" ] && [ -n "$APPLE_ID_PASS" ] && [ -n "$TEAM_ID" ]; then
    xcrun notarytool submit "$TARGET" \
      --apple-id "$APPLE_ID_USER" \
      --password "$APPLE_ID_PASS" \
      --team-id "$TEAM_ID" \
      --wait --timeout 180
    st=$?
  else
    echo "notarization skipped (no Apple ID / API key)"
    st=2
  fi
  set -e
  if [ "${st:-1}" -eq 0 ]; then
    xcrun stapler staple "$TARGET"
    xcrun stapler validate "$TARGET"
    MODE="notarized"
  else
    echo "notarization failed or skipped — signed DMG remains"
    MODE="developer-id-unnotarized"
  fi
fi

write_state
write_signing_txt
echo "dmg signing: ${MODE}"
exit 0
