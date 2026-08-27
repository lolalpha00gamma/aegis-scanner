# Aegis

Lokaler Image- & Video-Scanner für macOS. Extrahiert Frames, erkennt Gesichter und zeigt **Übereinstimmung in Prozent** für sieben Strategien — gebaut, um die konservative Apple-Fotos-Personenpipeline zu schlagen.

Alles läuft **offline auf dem Gerät**. Keine Cloud, keine Fotomediathek-API.

## Warum Aegis

Apple Fotos ist präzise, aber konservativ: schlechte Qualität, starke Pose oder kleine Gesichter werden oft verworfen. Aegis macht das Gegenteil der harten Grenze:

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Einzelnes Best-Frame, harte Qualitätsgrenze (Baseline) |
| **Vision Box** | `VNDetectFaceRectanglesRequest` Rev. 3 |
| **Landmark-Geometrie** | Landmark-Form, Procrustes-normalisiert |
| **Quality-Gate** | Feature Print × `VNDetectFaceCaptureQuality` |
| **Temporal** | Qualitätsgewichteter Mittelwert über Video-Tracks |
| **Feature Print** | `VNGenerateImageFeaturePrintRequest` auf ausgerichtetem Crop |
| **Aegis Ensemble** | Fusion aller Signale |

Der Vorsprung sitzt in drei Stellen: Video-Tracks statt Einzelbild, weiche Qualitätsgewichte statt Drop, Ensemble statt einem Embedding.

## Voraussetzungen

- macOS 14 Sonoma oder neuer
- Xcode 15.4+

## Start

```bash
git clone https://github.com/lolalpha00gamma/aegis-scanner.git
cd aegis-scanner
open macos/AegisScanner.xcodeproj
```

In Xcode: Team unter Signing wählen, dann **⌘R**.

1. **Ordner** — Fotos und Videos (JPEG, HEIC, PNG, MP4, MOV)
2. Aegis zieht Video-Frames und erkennt Gesichter
3. Gesicht wählen → Namen eintragen → **Anlegen**
4. Jede Strategie zeigt Prozent. Schwelle per Slider.

CSV-Export über die Toolbar.

## Web-Labor

Dasselbe Experiment läuft im Browser mit FaceNet-128d (TinyFace + SSD + Landmark + Temporal + Ensemble), inklusive Labor-Datensatz.

## Lizenz

MIT
