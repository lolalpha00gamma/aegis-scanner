# Zwei Produkte, ein Repo

| Pfad | Produkt | Zweck |
|------|---------|--------|
| `macos/` | **Aegis Scanner** | Gesichter in Bild/Video |
| `locus/` | **Locus** | Standortverlauf / Find-My-Cache-Snapshots + Karte |

Versionen getrennt: `VERSION` (Aegis) vs. `locus/VERSION`.

Signatur: `macos/ci-sign.sh` + Secrets wie Aegis. Locus-Entitlements: `locus/Locus.entitlements`. Build nur lokal: `locus/build-locus.sh`. Kein extra GitHub-Actions-Job.
