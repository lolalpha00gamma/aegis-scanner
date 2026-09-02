# Aegis — Vorschlagsliste

Stand: **2.1.5 alpha**. 2.1.4 hat Live-Mittel, TAR-Index, Floor-Text. 2.1.5 schließt Print-Miss, Pose-Mix und veraltete Live-Frames.

## In 2.1.5 wirklich im Code

- Live: `livePending` statt Frames wegwerfen, solange `liveBusy`.
- `stopLive` leert Pending und Busy.
- Galerie-Print: Capture/Frontal-Gewicht + Yaw-Kompatibilität.
- `stampPrints` IoU 0,18 statt 0,32.
- MatchMath-Tests für Gewicht und Yaw.

## Nächste Fixes (klein)

- EXIF-Orientierungstest in den Laborbericht.
- Quality mit ins printHistory (Paar Data+capture).
- Kalman auf der Live-Box bei schneller Bewegung.

## Erweiterungen

- Drop-in `.mlmodel` (Apple-Print default, ArcFace optional).
- PhotoKit-Scan lokal.
- Cluster vor Anlegen.
- Track über Dateien.
- Export Embeddings ohne Bilder.
- GPU-Batch.
- Kalibrier-Set (frontal, 3/4, Hut, Nacht, Lächeln).
- Score-Kalibrierung pro Galerie (Platt).
- Helios-Bridge, eine Kamera-Session.
- Offen-Set / Doppelgänger-Warnung.
- Labor als Panel mit TAR@FAR-Kurve.
- Track-Verlust-Timeout 0,6 s.

## Nicht tun

- Raster wieder abstimmen lassen.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität.
- Sigmoid-Mitte wieder unter 0,50.
- Helios-Gesten-Code hierher kopieren.
