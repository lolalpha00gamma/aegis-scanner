# Aegis — Vorschlagsliste

Stand: **2.1.3 alpha**. Fixes von 2.1.3 stehen auch in der README.

## In 2.1.3 wirklich im Code

Warum 2.1.2 trotz ehrlichem Print niemanden benannt hat, sobald nur eine Person in der Galerie stand:

1. **`lookOf` zieht den Print nicht mehr runter.** 0,75·embed + 0,25·geo hat einen echten 92 %-Print auf ~84 gedrückt — unter soloFloor 88. Jetzt: Print *ist* der Score. Geo vetoiert unter 35 (Deckel 60) und darf bis +4 Punkte geben, wenn Maße und Pose einig sind.
2. **Floors lokal, nicht process-weit.** `matchFloor`/`soloFloor` waren Static-Globals — paralleles Labor + Live haben sich die Schwelle zerschossen. `Floors` wandert als Wert durch `rank`/`decide`.
3. **Solo-Zuschlag +2 statt +4.** 1 Person bleibt Floor 84 (Slider-Bias um 78), solo 86. Zusammen mit (1) ist ein echter Print wieder über der Linie.
4. **Galerie-Centroid.** Score gegen den L2-normierten Mittel-Vektor der Referenzen, nicht nur Mittel der oberen Score-Hälfte. Ein schiefer Winkel in einer Kopie tauft niemanden mehr auf 99 %.
5. **Live-Print EMA.** Dieselbe UUID mittelt den Vektor (α=0,35), statt nur den schärferen Frame zu behalten.
6. **Labor TAR@0,1 % / 1 % FAR** wirklich gerechnet und exportiert.
7. **Referenz-Qualitätssieb.** Anlegen / + ablehnen bei capture < 0,40 oder Print tot.

## In 2.1.2 wirklich im Code (nicht nur in der Liste)

Die 2.1.2-Commits auf main hatten die härtere Kurve und den Galerie-Floor nur in VERSION/VORSCHLÄGE.md. Der FaceEngine-Sigmoid war noch `-11*(c-0.42)`. Dann:

- Print-Sigmoid Mitte 0,55 / Steigung 14 (Impostor-Cosine 0,45 ≈ 20 %, nicht 58 %).
- `bestPrintPercent` ist Mittel der oberen Hälfte, nicht max — 2.1.3 ersetzt das durch den Centroid, Hälfte bleibt Fallback.
- `decide` nutzt `geoAgrees` / `geoMix`: Maße unter 42 % bei Widerspruch vetoiert.
- Galerie-Floor: 1 Person 84, 2–3 80, ≥4 78. Slider bleibt Bias um 78.
- Ensemble nimmt nicht max() über fünf Kopien desselben Prints.
- Crop-Fallback speichert keinen Jacken-Print, wenn der Ganzbild-Print die Box verfehlt.
- Live ~5 fps. Overlay-Badge „Print tot“ / „Print 99 %“.
- Live-Pin IoU 0,12, Qualität hält den stabileren Print, keine Geister-Kästen.

## Nächste Fixes (klein)

- **NMS-Debug.** Optional Quadrate der verworfenen Tile-Treffer — sonst sieht man Twins nicht.
- **EXIF-Orientierungstest** in den Laborbericht. Ein gedrehtes iPhone-Foto kippt Yaw.
- **Vision-Handler-Orientierung am Live-Frame.** Webcam-BGRA oft landscape; `.up` verdreht Yaw/Pitch.
- **Slider-Tooltip** zeigt den effektiven Floor (Galerie + Bias), nicht nur 70…96.
- **Confusion-Matrix** im Laborbericht (Person × Person), nicht nur Genuine/Impostor-Listen.
- **Sonnenbrille / starke Okklusion** als Ablehnungsgrund am Overlay, nicht stiller Print-Tod.
- **Keyframe-Auswahl nach Yaw-Diversität** beim Video-Ingest (frontal + ¾, nicht 40× dasselbe).

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
- **Identitäten mergen.** „Anna“ und „A. Müller“ wenn Centroid-Cosine > 0,82 und der Nutzer bestätigt.
- **Watch-Folder.** Ordner beobachten, neue Fotos automatisch ingestieren.
- **Print quantisieren** (int8) für kleinere Library-Files, Cosine auf dequantisiertem Centroid.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern, eine Klick-Referenz.
- **Softmax-Temperatur auf Look-Scores**, sichtbar im Labor, analog zu Helios' Fusion-T.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric. Bleibt raus.
- Cloud-API. Aegis ist lokal, das ist die Produktgrenze.
- 3DMM-Netze ins Bundle (Größe, Lizenz). Pose-Anhebung reicht, bis ein Drop-in-Modell kommt.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50. Impostor-Cosine sitzt genau dort.
- `lookOf` wieder als 0,75/0,25-Mix. Der Mix ist warum 1-Personen-Galerien stumm blieben.
- Static `matchFloor` wieder process-weit. Labor und Live dürfen sich die Schwelle nicht teilen.
