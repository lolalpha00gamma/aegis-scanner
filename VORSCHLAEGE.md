# Aegis — Vorschlagsliste

Stand: **2.1.4 alpha**. 2.1.3 hat ehrliche `lookOf` und Geister-Kästen. 2.1.4 schließt Live-Jitter, TAR-Index und Floor-Text.

## In 2.1.4 wirklich im Code

- Live-Print: Ring der letzten 3 Prints, Score = Mittel, nicht schärfstes Frame.
- Box-EMA (α=0,55) auf demselben Track.
- Webcam-Throttle 0,09 s (~11 fps).
- TAR@FAR: `k = max(0, ceil(far·n)−1)`.
- `toHit` nutzt `floors.match` statt hart 78.
- Slider-Label `78 → Floor 84`.
- Overlay zeigt `decide`-Note wenn abgelehnt.
- Built-in Wide vor Continuity-Front.
- `printHistory` nicht Codable.

## In 2.1.3 wirklich im Code

- **`lookOf` behandelt 0,4 % Print nicht als „KI aus“.** `if embed < 1 { return geo }` hat Impostor-Prints auf Geometrie fallen lassen und Fremde getauft.
- **Keine Static-Floors.** `matchFloor`/`soloFloor` waren process-weit — Labor und Live überschrieben sich.
- **Name nur wenn `decide` eine ID setzt**, nicht wenn Prozent ≥ Slider. Overlay, Strip, IdentityDesk.
- **Live-Geister weg.** Leeres Detektionsframe hat eingeschriebene Boxen stehen lassen.
- **Anlegen ohne Print/Qualität blockt**, solange die KI-Spur an ist.
- **Labor TAR @ 0,1 % / 1 % FAR.**
- **Webcam landscapeRight + Frontkamera**, analog Helios.
- **MatchMath** + CI-Test ohne Vision.

## Nächste Fixes (klein)

- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw — Ingest nutzt Thumbnail-Transform, Live nicht.
- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer.
- **Quality-gewichtetes Print-Mittel** in der Galerie (scharfe Frontal-Refs zählen mehr).
- **Print tot als eigene Overlay-Farbe**, auch wenn die Box nicht selektiert ist (jetzt nur Badge).
- **Live-Yaw-Bin.** Profil-Frames nicht mit Frontal-Refs mitteln.

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
- **Doppelgänger-Warnung.** Zwei Identitäten mit Print-Cosine > 0,70 beim Anlegen.
- **Kalman auf der Live-Box**, sobald EMA nicht reicht (schnelle Bewegung).
- **Galerie nach Yaw-Bins.** Match nur gegen ähnliche Pose, sonst Geometrie-Veto härter.
- **Labor als Panel**, nicht nur Textexport — Kurve TAR@FAR live.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API. Aegis ist lokal.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50.
- Helios-Gesten-Code hierher kopieren.
