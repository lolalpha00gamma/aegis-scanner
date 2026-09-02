# Aegis — Vorschlagsliste

Stand: **2.1.2 alpha**. Fixes von 2.1.2 stehen in der README, nicht hier.

## In 2.1.2 wirklich im Code (nicht nur in der Liste)

Die 2.1.2-Commits auf main hatten die härtere Kurve und den Galerie-Floor nur in VERSION/VORSCHLÄGE.md. Der FaceEngine-Sigmoid war noch `-11*(c-0.42)`. Jetzt:

- Print-Sigmoid Mitte 0,55 / Steigung 14 (Impostor-Cosine 0,45 ≈ 20 %, nicht 58 %).
- `bestPrintPercent` ist Mittel der oberen Hälfte, nicht max.
- `decide` nutzt `geoAgrees` / `geoMix`: Maße unter 42 % bei Widerspruch vetoiert.
- Galerie-Floor: 1 Person 84, 2–3 80, ≥4 78. Slider bleibt Bias um 78.
- Ensemble nimmt nicht max() über fünf Kopien desselben Prints.
- Crop-Fallback speichert keinen Jacken-Print, wenn der Ganzbild-Print die Box verfehlt.
- Live ~5 fps. Overlay-Badge „Print tot“ / „Print 99 %“.
- Live-Pin IoU 0,12, Qualität hält den stabileren Print, keine Geister-Kästen.

## Nächste Fixes (klein)

- **Live-Print mitteln als echter Embedding-Mittelwert**, nicht nur „schärferes Print behalten“. Drei Frames derselben ID → Mittel-Vektor. Archived `VNFeaturePrintObservation` braucht dazu einen eigenen Float-Buffer.
- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer — sonst sieht man Twins nicht.
- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw.
- **Vision-Handler-Orientierung am Live-Frame.** Webcam-BGRA oft landscape; `.up` verdreht Yaw/Pitch.
- **matchFloor ohne Static-Globals.** `matchFloor`/`soloFloor` sind process-weit — paralleles Labor + Live überschreibt die Schwelle.
- **Slider-Tooltip** zeigt den effektiven Floor (Galerie + Bias), nicht nur 70…96.
- **Labor TAR@0.1 % / 1 % FAR** wirklich rechnen und exportieren — in der Liste schon behauptet, Evaluator prüfen.

## Erweiterungen

- **Drop-in `.mlmodel`.** `FaceEmbedder` als Protokoll, Apple-Print default, ArcFace optional (Lizenz!).
- **PhotoKit-Scan.** Mediathek lokal, ohne Ordner wählen. Nur mit expliziter Foto-Berechtigung.
- **Cluster vor Anlegen.** Unbenannte Gesichter vorschlagen: „3 Fotos, dieselbe Person?“
- **Track über Dateien.** Dieselbe Person in Video A und Foto B über Print, nicht nur innerhalb eines Clips.
- **Export Embeddings.** CSV/JSON der Face-Prints fürs eigene Notebook, ohne Bilder.
- **Landmark-Heatmap.** Welche Verhältnisse ziehen den Score — Stirn, Kiefer, Augen.
- **GPU-Batch.** `VNImageRequestHandler` pro Foto ist der Scan-Flaschenhals. Ein Handler, viele Requests.
- **Kalibrier-Set.** Fünf eigene Fotos (frontal, ¾, Hut, Nacht, Lächeln) als Selbsttest beim ersten Start.
- **Score-Kalibrierung pro Galerie.** Platt-Skalierung auf den Leave-one-out-Scores, statt einer globalen Sigmoid.
- **Temporal-Smoothing der Box.** Live-Jitter der Bounding Box mit 1-Euro-Filter, unabhängig vom Print.
- **Ablehnungsgrund als Overlay.** „z zu klein“ / „Print leer“ direkt am Gesicht, nicht nur in der Spur.
- **Zwei-Pass-Scan.** Erst grobe Boxen, dann Face-Print nur auf den besten Crops — spart Vision-Calls bei Gruppenfotos.
- **Helios-Bridge.** Optional: wenn Helios läuft, Kamera-Session teilen statt zweimal TCC.
- **Offen-Set.** Explizite „unbekannt“-Klasse mit eigener Schwelle, statt nur `nil`.
- **Pose-normalisierter Print.** Yaw/Pitch vor dem Crop, damit Profil nicht gegen Frontal verliert.
- **Referenz-Qualitätssieb.** Anlegen ablehnen wenn capture < 0,40 oder Print tot — verhindert Gift in der Galerie.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric. Bleibt raus.
- Cloud-API. Aegis ist lokal, das ist die Produktgrenze.
- 3DMM-Netze ins Bundle (Größe, Lizenz). Pose-Anhebung reicht, bis ein Drop-in-Modell kommt.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50. Impostor-Cosine sitzt genau dort.
