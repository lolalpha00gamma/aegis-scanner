# Aegis **1.0.4 alpha**

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden:
- [Aegis.dmg (Code)](https://github.com/lolalpha00gamma/aegis-scanner/raw/main/Aegis.dmg)
- [Release 1.0.4 alpha](https://github.com/lolalpha00gamma/aegis-scanner/releases/tag/v1.0.4-alpha)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert.

## Neu in 1.0.4 alpha

- Keine Doppel-Gesichter mehr (Boxen derselben Person werden zusammengeführt)
- Zweite Person löscht die erste nicht mehr — Referenzen bleiben zugeordnet, Prozent bleibt sichtbar
- Zwei neue Klassifizierer: **Gesichtsmaße** (Nase/Augen, Augenbreite, Mund) und **Gesichtsform** (Kiefer, Aspekt, Kinn)
- Ensemble nutzt alle Signale, um ähnliche Gesichter zu trennen

## Strategien

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Einzelnes Best-Frame, harte Qualitätsgrenze |
| **Vision Box** | `VNDetectFaceRectanglesRequest` Rev. 3 |
| **Landmark-Geometrie** | Landmark-Form, Procrustes-normalisiert |
| **Gesichtsmaße** | Nase zu Augen, Augenbreite, Mund, Philtrum |
| **Gesichtsform** | Kiefer, Wangen, Aspekt, Kinn |
| **Quality-Gate** | Feature Print × Capture-Qualität |
| **Temporal** | Mittelwert über Video-Tracks |
| **Feature Print** | `VNGenerateImageFeaturePrintRequest` |
| **Aegis Ensemble** | Fusion |

## Lizenz

MIT
