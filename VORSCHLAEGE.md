# Aegis — Vorschlagsliste

Stand: **2.1.2 alpha**. Fixes von 2.1.2 stehen in der README, nicht hier.

## Erledigt in 2.1.2 (nicht erneut vorschlagen)

- Match-Floor abhängig von Galeriegröße.
- Live-Print: Qualität hält den stabileren Vektor, statt jedes Frame neu zu würfeln.
- Print-Sigmoid härter (Mitte 0.58 statt 0.42) — Impostoren nicht mehr bei 70 %.
- TER-min-max erst ab 3 Identitäten.
- Landmark-Vergleich nur gleich lange Named-Sets.
- Labor: TAR@0.1 % FAR und TAR@1 % FAR.

## Nächste Fixes (klein)

- **Print-Status im Overlay.** Badge „Print tot“ / „Print 99 %“ direkt auf der Box, nicht nur in der Spur-Liste.
- **Live-Print mitteln als echter Embedding-Mittelwert**, nicht nur „älteres Print behalten“. Drei Frames derselben ID → Mittel-Vektor.
- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer — sonst sieht man Twins nicht.
- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw, obwohl Thumbnails mit Transform geladen werden.
- **Vision-Handler-Orientierung am Live-Frame.** Webcam-BGRA oft landscape; `.up` verdreht Yaw/Pitch.
- **matchFloor ohne Static-Globals.** `matchFloor`/`soloFloor` sind process-weit — paralleles Labor + Live überschreibt die Schwelle.

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

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric. Bleibt raus.
- Cloud-API. Aegis ist lokal, das ist die Produktgrenze.
- 3DMM-Netze ins Bundle (Größe, Lizenz). Pose-Anhebung reicht, bis ein Drop-in-Modell kommt.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
