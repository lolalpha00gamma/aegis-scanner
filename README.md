# Aegis

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden: [Aegis.dmg](https://github.com/lolalpha00gamma/aegis-scanner/raw/main/Aegis.dmg) · [Release v1.0](https://github.com/lolalpha00gamma/aegis-scanner/releases/download/v1.0/Aegis.dmg)

Lokaler Image- & Video-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen (Datei im Stammverzeichnis dieses Repos)
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert — deshalb der Rechtsklick beim ersten Start.

## Was die App macht

Ordner mit Fotos und Videos wählen. Aegis zieht Frames, erkennt Gesichter und zeigt Übereinstimmung in Prozent für sieben Strategien — offline auf dem Gerät.

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Einzelnes Best-Frame, harte Qualitätsgrenze (Baseline) |
| **Vision Box** | `VNDetectFaceRectanglesRequest` Rev. 3 |
| **Landmark-Geometrie** | Landmark-Form, Procrustes-normalisiert |
| **Quality-Gate** | Feature Print × `VNDetectFaceCaptureQuality` |
| **Temporal** | Qualitätsgewichteter Mittelwert über Video-Tracks |
| **Feature Print** | `VNGenerateImageFeaturePrintRequest` auf ausgerichtetem Crop |
| **Aegis Ensemble** | Fusion aller Signale |

## Lizenz

MIT
