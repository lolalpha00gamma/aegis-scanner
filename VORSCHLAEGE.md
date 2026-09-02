# Aegis — Vorschlagsliste

Stand: **2.1.7 alpha**. Branch `bugfix`. Fixes von 2.1.7 stehen auch in der README.

## In 2.1.7 wirklich im Code

Warum 2.1.6 trotz gewichtetem Centroid und Pose-Meter trotzdem falsch taufte und Live-IDs verlor:

1. **`lookOf(printMeasured:)`.** `if embed < 1 { return geo }` hat Impostor-Prints von 0,4 % auf Geometrie fallen lassen — Fremde mit ähnlichen Maßen wurden getauft. Jetzt: ungemessen = Geo; gemessen = Print ist der Score, Geo vetoiert oder +4.
2. **Crop-Print mit `orientation`.** `stampPrints`-Fallback rief `identityPrint` als `.up` auf. Gedrehtes iPhone-Foto kippte den Crop-Print.
3. **Coverage-Slot erzwingen.** `poseCoverageBlocks` — `+` auf denselben vollen Slot ohne leeren ¾/Profil wird abgelehnt.
4. **Live-Reconnect.** Ghosts 1,8 s + Print-Cosine > 0,72 halten die UUID nach Kamera-Drop. `startLive` snapshotet die alten Faces vor `stopLive`.
5. **Built-in-Cam zuerst.** Continuity/Desk-View nur Fallback.
6. **Familien-Floor.** Pairwise Centroid-Cosine 0,80–0,88 → +4 Floor, ohne die Sigmoid zu härten.
7. **Hard-Negativ.** Taste „nicht Name“ speichert den Probe-Vektor an der Identität, Score-Deckel 35.
8. **Anlegen zweimal bei Duplikat.** Cosine > 0,88 legt nicht still an.
9. **MatchMath** wieder im Target. CI `swiftc` ohne Vision. Overlay Maske/Sonnenbrille.
10. **`printRevision`** in `gallery.json` (`VNGenerateFacePrint/1`).

## In 2.1.6 wirklich im Code

Warum 2.1.5 trotz Cancel und HLS-Transform Galerien und Live trotzdem schief zog: unscharfe Kopien hatten gleiches Gewicht im Centroid, der Ordner-Walk ignorierte Cancel, HLS blieb fest 0,22 s, fünf Frontals füllten keinen ¾-Slot, und `stampPrints` ließ `printVec` leer.

1. **Gewichteter Centroid.** `capture * (0,35 + 0,65·sharpness)`, Floor 0,08.
2. **Walk-Cancel pro Datei.** `AegisScanFlag` in `FrameExtractor.walk`.
3. **HLS-Timer adaptiv.** 0,50 s leer / 0,125 s bei Track.
4. **Pose-Coverage-Meter.** F / ¾ / P. Warnung wenn derselbe Slot ≥2 und ein anderer 0.
5. **Print-Drift.** Overlay bei Cosine-Abstand > 0,12 zum Galerie-Centroid.
6. **Enrollment-Vorschau** unter Anlegen.
7. **`printVec` in `stampPrints`.**

## Nächste Fixes (klein)

- **Face-Print-Revision merken und mismatch warnen.** Feld liegt in `gallery.json`, UI sagt es noch nicht, wenn Apple das Modell dreht.
- **Teil-Print.** Okkludierte untere Hälfte matcht gegen Stirn/Augen, mit niedrigerem Floor.
- **Labor auf denselben Weight-Pfad sichtbar.** TAR@FAR nutzt schon `meanPrintVector`; Report sollte die Gewichte pro Ref listen.
- **Live-Box 1-Euro**, unabhängig vom Print.
- **Per-Kamera Orientierungs-Override**, falls Continuity `videoRotationAngle` falsch meldet.
- **Scan-Resume.** Abgebrochener Ordner merkt den letzten URL.

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
- **Identitäten mergen.** Bestätigung wenn Centroid-Cosine > 0,82.
- **Watch-Folder.** Neue Fotos automatisch ingestieren.
- **Print quantisieren** (int8) für kleinere Library-Files.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern.
- **On-device Eval-Clip.** Die letzten 50 Live-Frames als Mini-Labor.
- **Auto-Enrollment-Halt.** UUID 8 s mit Print ≥ 94 % und Yaw < 0,3 → Vorschlag, nie still schreiben.
- **HEIC-Depth.** Yaw aus der Tiefenkarte.
- **Negativ-IDs in der Laborliste** exportieren, nicht nur intern deckeln.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API. Aegis ist lokal.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50.
- `lookOf` wieder als 0,75/0,25-Mix. Der Mix ist warum 1-Personen-Galerien stumm blieben.
- `if embed < 1 { return geo }`. 0,4 % ist ein Impostor, kein fehlender Print.
- Static `matchFloor` wieder process-weit.
- Ungewichteter 1/n-Centroid.
- `printVec` wieder leer lassen nach `stampPrints`.
- Coverage nur warnen. Volle Frontals ohne ¾ verdrehen den Centroid.
