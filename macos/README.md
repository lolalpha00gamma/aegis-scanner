# Aegis

Lokaler Image- & Video-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**  
Version **1.0.6 alpha**.

## Image-Datei

[**Aegis.dmg herunterladen**](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)

1. Image öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Die Datei ist ad-hoc signiert (kein Apple-Developer-Account) — deshalb der Rechtsklick beim ersten Start.

## Was die App macht

Ordner mit Fotos und Videos wählen, oder einen Live-Stream (Webcam, RTSP, HLS, MJPEG, Snapshot) einspeisen. Aegis zieht Frames, erkennt Gesichter und zeigt Übereinstimmung in Prozent für mehrere Strategien — offline auf dem Gerät.

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Einzelnes Best-Frame, harte Qualitätsgrenze (Baseline) |
| **Vision Box** | Nächstes Feature-Print-Exemplar, Vision Rev. 3 |
| **Landmark-Geometrie** | Landmark-Form, Procrustes-normalisiert |
| **Gesichtsmaße** | Nase/Augen, Augenbreite, Mund, Philtrum |
| **Gesichtsform** | Kiefer, Wangen, Aspekt, Kinn |
| **Augenregion** | Augenbreite, Lidöffnung, Brauen |
| **Mittelgesicht** | Nase, Philtrum, Mund |
| **Kieferlinie** | Kieferbreite, Wangen, Kinn |
| **Quality-Gate** | Nächstes Exemplar × `VNDetectFaceCaptureQuality` |
| **Temporal** | Nächstes Video-Exemplar, Tracks ohne Kreuzer-Tausch |
| **Feature Print** | `VNGenerateImageFeaturePrintRequest` auf ausgerichtetem Crop |
| **Aegis Ensemble** | Fusion. Enge Rennen bleiben offen und werden erklärt |

## Lizenz

MIT
