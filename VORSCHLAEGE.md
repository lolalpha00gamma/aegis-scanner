# Aegis — Vorschlagsliste

Stand: **2.1.1 alpha**. Fixes von 2.1.1 stehen in der README, nicht hier.

## Nächste Fixes (klein)

- **Print-Status im Overlay.** Badge „Print tot“ / „Print 99 %“ direkt auf der Box, nicht nur in der Spur-Liste.
- **Live-Print mitteln.** Drei Frames derselben ID → Mittel-Vektor, weniger Zittern.
- **Match-Floor abhängig von Galeriegröße.** 1 Person: 84. 2–3: 80. ≥4: 78. Slider bleibt Override.
- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer — sonst sieht man Twins nicht.
- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw.

## Erweiterungen

- **Drop-in `.mlmodel`.** `FaceEmbedder` als Protokoll, Apple-Print default, ArcFace optional (Lizenz!).
- **PhotoKit-Scan.** Mediathek lokal, ohne Ordner wählen. Nur mit expliziter Foto-Berechtigung.
- **Cluster vor Anlegen.** Unbenannte Gesichter vorschlagen: „3 Fotos, dieselbe Person?“
- **FAR-Anzeige.** Laborbericht TAR@0.1 % FAR, nicht nur EER — das ist die Zahl die zählt.
- **Track über Dateien.** Dieselbe Person in Video A und Foto B über Print, nicht nur innerhalb eines Clips.
- **Export Embeddings.** CSV/JSON der Face-Prints fürs eigene Notebook, ohne Bilder.
- **Landmark-Heatmap.** Welche Verhältnisse ziehen den Score — Stirn, Kiefer, Augen.
- **GPU-Batch.** `VNImageRequestHandler` pro Foto ist der Scan-Flaschenhals. Ein Handler, viele Requests.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric. Bleibt raus.
- Cloud-API. Aegis ist lokal, das ist die Produktgrenze.
- 3DMM-Netze ins Bundle (Größe, Lizenz). Pose-Anhebung reicht, bis ein Drop-in-Modell kommt.
