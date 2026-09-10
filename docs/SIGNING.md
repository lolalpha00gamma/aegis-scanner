# Aegis.dmg signieren

Secrets liegen nur im Repo (Settings → Secrets and variables → Actions).
Dieser Ordner ist der offene Teil: Workflow + Script lesen die Namen, Werte nie.

## Pflicht für Developer ID

Eines der Zertifikat-Aliase, Base64 vom `.p12`:

- `BUILD_CERTIFICATE_BASE64` (gesetzt im Runner 2.1.250)
- `APPLE_CERTIFICATE`
- `APPLE_CERTIFICATE_BASE64`
- `P12_BASE64`
- `CERTIFICATE_BASE64`
- `MACOS_CERTIFICATE`

Passwort zum P12, eines von:

- `P12_PASSWORD` (gesetzt im Runner 2.1.250)
- `APPLE_CERTIFICATE_PASSWORD`
- `CERTIFICATE_PASSWORD`

Optional, überschreibt die Identity-Erkennung:

- `APPLE_CODESIGN_IDENTITY` — `Developer ID Application: Name (TEAMID)`
- `APPLE_TEAM_ID` (gesetzt im Runner 2.1.250)

`macos/ci-sign.sh` importiert das P12 **mit Schlüssel** (nicht `-t cert`).
Ohne privaten Schlüssel fällt CI auf Ad-hoc zurück.

## Notarisierung (Gatekeeper ohne Rechtsklick)

App Store Connect API (bevorzugt):

- `APP_STORE_CONNECT_API_KEY` — Inhalt der `.p8` oder Base64
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`

oder Apple-ID:

- `APPLE_ID` (gesetzt im Runner 2.1.250)
- `APPLE_APP_SPECIFIC_PASSWORD` — **fehlt noch**, sonst `mode=developer-id-unnotarized`
- `APPLE_TEAM_ID`

Aliase für das App-Passwort: `APPLE_PASSWORD`, `AC_PASSWORD`, `APPLEIDPASS`,
`NOTARY_PASSWORD`.

Ohne dieses Passwort bleibt die Datei Developer-ID-signiert, Gatekeeper
beim ersten Start ggf. Rechtsklick → Öffnen.

## Ablauf

`macos/ci-sign.sh` importiert das P12 in eine Runner-Keychain, signiert
`Aegis.app` mit Hardened Runtime + Entitlements, danach `Aegis.dmg`,
dann `notarytool submit --wait` und `stapler staple`.

Ohne Zertifikat fällt CI auf Ad-hoc zurück und schreibt `mode=adhoc`
nach `signing.txt`. Release-Notes lesen denselben Mode.

Ein Image (`macos-15`). Timeout 20. Kein zweiter macOS-Job.
Xcode: höchste installierte Version (nicht fest `Xcode.app` = 16.4).
