# Aegis — Vorschlagsliste

Stand: **2.1.3 alpha**. 2.1.2 hatte ehrliche Kurve und Galerie-Floor. 2.1.3 schließt, warum es trotzdem falsch taufte.

## In 2.1.3 wirklich im Code

- **`lookOf` behandelt 0,4 % Print nicht als „KI aus“.** `if embed < 1 { return geo }` hat Impostor-Prints auf Geometrie fallen lassen und Fremde getauft.
- **Keine Static-Floors.** `matchFloor`/`soloFloor` waren process-weit — Labor und Live überschrieben sich.
- **Name nur wenn `decide` eine ID setzt**, nicht wenn Prozent ≥ Slider. Overlay, Strip, IdentityDesk.
- **Live-Geister weg.** Leeres Detektionsframe hat eingeschriebene Boxen stehen gelassen.
- **Anlegen ohne Print/Qualität blockt**, solange die KI-Spur an ist.
- **Labor TAR @ 0,1 % / 1 % FAR.**
- **Webcam landscapeRight + Frontkamera**, analog Helios.
- **MatchMath** + CI-Test ohne Vision.

## Nächste Fixes (klein)

- **Live-Print als Mittel-Vektor** über drei Frames derselben ID, nicht nur „schärferes Print behalten“.
- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw — Ingest nutzt Thumbnail-Transform, Live nicht.
- **Slider-Label** mit effektivem Floor (Galerie + Bias), nicht nur 70…96.
- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer.
- **Temporal-Smoothing der Box.** 1-Euro auf der Live-Box, unabhängig vom Print.
- **Ablehnungsgrund am Overlay.** „z zu klein“ / „Print leer“ direkt am Gesicht.

## Erweiterungen

- **Drop-in `.mlmodel`.** `FaceEmbedder` als Protokoll, Apple-Print default, ArcFace optional (Lizenz!).
- **PhotoKit-Scan.** Mediathek lokal, nur mit expliziter Foto-Berechtigung.
- **Cluster vor Anlegen.** Unbenannte Gesichter: „3 Fotos, dieselbe Person?“
- **Track über Dateien.** Dieselbe Person in Video A und Foto B über Print.
- **Export Embeddings.** CSV/JSON der Face-Prints ohne Bilder.
- **GPU-Batch.** Ein `VNImageRequestHandler`, viele Requests.
- **Kalibrier-Set.** Fünf eigene Fotos (frontal, ¾, Hut, Nacht, Lächeln) als Selbsttest.
- **Score-Kalibrierung pro Galerie.** Platt-Skalierung auf Leave-one-out statt globaler Sigmoid.
- **Pose-normalisierter Print.** Yaw/Pitch vor dem Crop.
- **Helios-Bridge.** Eine Kamera-Session, eine TCC-Freigabe.
- **Offen-Set.** Explizite „unbekannt“-Klasse mit eigener Schwelle.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API. Aegis ist lokal.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50.
