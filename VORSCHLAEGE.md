# Aegis — Vorschlagsliste

Stand: **2.1.6 alpha**. Fixes von 2.1.6 stehen auch in der README.

## In 2.1.6 wirklich im Code

Warum 2.1.5 trotz Cancel und HLS-Transform Galerien und Live trotzdem schief zog: unscharfe Kopien hatten gleiches Gewicht im Centroid, der Ordner-Walk ignorierte Cancel, HLS blieb fest 0,22 s, fünf Frontals füllten keinen ¾-Slot, und `stampPrints` ließ `printVec` leer.

1. **Gewichteter Centroid.** `capture * (0,35 + 0,65·sharpness)`, Floor 0,08. Eine verwackelte Kopie zieht den Mittelvektor nicht mehr.
2. **Walk-Cancel pro Datei.** `AegisScanFlag` (Sendable + NSLock) in `FrameExtractor.walk`.
3. **HLS-Timer adaptiv.** 0,50 s leer / 0,125 s bei Track, Timer wird neu gesetzt.
4. **Pose-Coverage-Meter.** F / ¾ / P an der Identitätszeile. Warnung wenn derselbe Slot ≥2 und ein anderer 0.
5. **Print-Drift.** Overlay „andere Person oder Brille?“ bei Cosine-Abstand > 0,12 zum Galerie-Centroid.
6. **Enrollment-Vorschau** unter Anlegen, bevor Commit.
7. **`printVec` in `stampPrints`.** Scan-Fotos haben den Vektor, nicht nur Live.

## In 2.1.5 wirklich im Code

Warum 2.1.4 live und in der Galerie trotzdem daneben lag: HLS kam ungedreht an, ein Profil als erste Referenz hat den Centroid verdreht, der Overlay-Hinweis hat den Print-% versteckt, und ein Ordner-Scan war nicht abzubrechen.

1. **HLS/Player-Transform.** `grab()` wendet `preferredTransform` der Videospur an. Webcam bleibt `videoRotationAngle`.
2. **Enrollment-Yaw.** Erste Referenz mit |Yaw| > 0,7 wird abgelehnt. Weitere ¾-Shots derselben Person bleiben erlaubt.
3. **Duplikat-Warnung.** Anlegen, wenn Centroid-Cosine zu einer existierenden Person > 0,88 — Status sagt den Namen, legt aber an.
4. **Print-% + Hinweis.** Badge ist `Print 92% · Profil`, nicht nur „Profil“.
5. **Scan-Cancel.** `scanGeneration` bricht Detect ab; Ordner-Walk läuft in `Task.detached`. Button **Abbrechen**.
6. **Adaptive Live-FPS.** FrameTap 0,50 s leer / 0,125 s bei Track.
7. **HEIC-Burst.** `loadCGImage` nimmt das schärfste der ersten 8 Frames.

## In 2.1.4 wirklich im Code

Warum 2.1.3 trotz ehrlichem Print und lokalem Floor live schief lag: Vision hat jedes Webcam-Frame als `.up` gelesen, Video-Ingest hat 20× dieselbe Pose behalten, und der Slider hat den effektiven Floor nicht gezeigt.

1. **Live-Orientierung.** `videoRotationAngle` der Capture-Connection dreht den CGImage, bevor Vision ihn sieht. Continuity/geklapptes MacBook kippt Yaw nicht mehr. CIContext wird wiederverwendet.
2. **Keyframe-Yaw.** Video-Ingest nimmt scharfe Frames mit Δyaw ≥ 0,22, nicht 40× Frontal.
3. **Overlay-Grund.** „Print tot · Okklusion?“, „z zu klein“, „Profil“, „unscharf“ am Kasten, nicht nur in der Spur.
4. **Slider zeigt Floor.** `Galerie n: Floor 84 · Solo 86` statt nur 70…96.
5. **NMS-Debug.** Toggle zeichnet verworfene Tile-Zwillinge gestrichelt orange.
6. **Labor: Konfusion + EXIF.** Person × Person mean-% plus Zähler für Orientation ≠ 1.
7. **Live-Box EMA** 0,62/0,38 — weniger Jitter bei gleichem Track.

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

- **Negativ-Bestätigung vor Anlegen.** Ein Klick „nicht \(Name)“ schreibt ein Hard-Negative, ohne die Galerie zu löschen.
- **Live-Reconnect hält UUID.** Kamera-Drop darf den Track nicht auf eine neue Person taufen, wenn der Print noch passt.
- **Coverage-Slot erzwingen.** + auf einen vollen Frontal-Slot ohne leeren ¾ blockt, nicht nur warnt.
- **Crop-Print mit Orientierung.** Fallback-Crop in `stampPrints` läuft noch als `.up`.
- **Labor auf gewichtetem Centroid.** TAR@FAR nutzt denselben Weight wie `meanPrintVector`.

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
- **Zwei-Pass-Scan.** Erst grobe Boxen, dann Face-Print nur auf den besten Crops — spart Vision-Calls bei Gruppenfotos.
- **Helios-Bridge.** Optional: wenn Helios läuft, Kamera-Session teilen statt zweimal TCC.
- **Offen-Set.** Explizite „unbekannt“-Klasse mit eigener Schwelle, statt nur `nil`.
- **Pose-normalisierter Print.** Yaw/Pitch vor dem Crop, damit Profil nicht gegen Frontal verliert.
- **Identitäten mergen.** „Anna“ und „A. Müller“ wenn Centroid-Cosine > 0,82 und der Nutzer bestätigt.
- **Watch-Folder.** Ordner beobachten, neue Fotos automatisch ingestieren.
- **Print quantisieren** (int8) für kleinere Library-Files, Cosine auf dequantisiertem Centroid.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern, eine Klick-Referenz.
- **Softmax-Temperatur auf Look-Scores**, sichtbar im Labor, analog zu Helios' Fusion-T.
- **Ablehnen-Taste am Overlay.** Ein Klick schreibt „nicht diese Person“ in die Labor-Liste, ohne die Galerie zu löschen.
- **Negativ-IDs.** Hard-Negatives pro Person (Geschwister, gleiche Brille) heben den lokalen Floor, ohne die Sigmoid anzufassen.
- **Live-Reconnect hält UUID.** Kamera-Drop darf den Track nicht auf eine neue Person taufen, wenn der Print noch passt.
- **On-device Eval-Clip.** Die letzten 50 Live-Frames als Mini-Labor, TAR/FAR ohne Ordner wählen.
- **Auto-Enrollment-Halt.** Dieselbe UUID 8 s mit Print ≥ 94 % und Yaw < 0,3 → Vorschlag „als Referenz übernehmen?“, nie still schreiben.
- **Per-Kamera Orientierungs-Override.** Eine Continuity-Cam, die `videoRotationAngle` falsch meldet, bekommt einen manuellen 90°-Hebel.
- **Familien-Floor.** Zwei Personen mit Cosine 0,80–0,88 (Geschwister) bekommen lokal +4 Floor, ohne die globale Sigmoid zu härten.
- **HEIC-Depth.** Wenn die Datei einen Depth-Channel hat, Yaw aus der Tiefenkarte statt nur Vision-Pose.
- **Scan-Resume.** Abgebrochener Ordner merkt den letzten URL, „Weiter“ statt von vorn.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric. Bleibt raus.
- Cloud-API. Aegis ist lokal, das ist die Produktgrenze.
- 3DMM-Netze ins Bundle (Größe, Lizenz). Pose-Anhebung reicht, bis ein Drop-in-Modell kommt.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50. Impostor-Cosine sitzt genau dort.
- `lookOf` wieder als 0,75/0,25-Mix. Der Mix ist warum 1-Personen-Galerien stumm blieben.
- Static `matchFloor` wieder process-weit. Labor und Live dürfen sich die Schwelle nicht teilen.
- Ungewichteter 1/n-Centroid. Eine unscharfe Kopie darf den Mittelvektor nicht ziehen.
- `printVec` wieder leer lassen nach `stampPrints`.
