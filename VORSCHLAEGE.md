# Aegis — Vorschlagsliste

Stand: **2.1.12 alpha**. Nur `main`. 2.1.7–2.1.11 von PR #3 nachgezogen.

## In 2.1.12 wirklich im Code

1. Alles aus 2.1.7–2.1.11 (Orient-Override, U-Slot, Ampel, Schärfe vor Print, Teil-Print, Masken-Veto, 1-Euro-Reset, TAR floor).
2. **Ampel-Spark 8 Frames.** Schlechteste Capture/Schärfe, größtes |Yaw|.
3. **Tile-Budget 2.** Mitte + eine Ecke, nicht 5 Origins.
4. **Continuity-Schärfe 0,08** nur für Continuity/Desk-View.
5. **Orient-Menü vor Live.** Pending-Override überlebt `configureCamera`.
6. **„doch Name“** löscht Hard-Negativ.
7. **Labor Genuine frei vs Teil-Print.**
8. TAR n=101 bleibt 80, nicht 10 (`floor` statt `ceil-1`).

## In 2.1.11 wirklich im Code

Warum 2.1.10 trotz Schärfe-Floor Continuity und Masken trotzdem falsch drehte: `videoRotationAngle` lügt bei Desk-View, U-Slot nur auto wenn der Mund fehlt, Overlay nennt den Namen vor Capture/Schärfe/Yaw, und unscharfe Gesichter gingen trotzdem in `VNGenerateFacePrint`.

1. **Per-Kamera Orient-Override.** Auto/0/90/180/270, Key `aegis.camOrient.{uniqueID}`.
2. **Taste U.** Expliziter Teil-Print, auch ohne Auto-Maske. Erste Referenz bleibt frei.
3. **Live-Ampel C/S/Y** am Overlay, bevor der Name kommt.
4. **Schärfe vor dem Print.** Laplacian < 0,12 → Request nicht, Print leer.

## In 2.1.10 wirklich im Code


Warum 2.1.9 trotz Teil-Print Masken und Portraits trotzdem falsch taufte: die maskierte Probe (`partialVec`) ging gegen den vollen Galerie-Mean (Stoff vs. Gesicht). Eine Maske als erste Referenz hat den Centroid vergiftet. Portrait-Fotos mit einem großen Gesicht wurden trotzdem gekachelt (NMS-Zwillinge, falsche Print-IoU). Unschärfe < 0,12 hat trotzdem benannt.

1. **Teil-Print vs. Teil-Centroid.** `meanPartialVector` nur aus U-Refs. Ohne U-Slot: Full * 0,45, kein Domain-Mix.
2. **Masken-Enrollment-Veto** auf der ersten Referenz. Stoff kommt nicht in den Full-Centroid. `meanPrintVector` lässt okkludierte Refs weg.
3. **Tiles nur bei Crowd.** `largest ≥ 0,28 · min(w,h)` → keine Kacheln.
4. **Schärfe-Floor 0,12** hart in `qualityRejects` / `tinyUnreliable` / Enrollment.
5. **Coverage-Slot U** (Teil-Print). `partialPrint` in `gallery.json`.

## In 2.1.9 wirklich im Code

Warum 2.1.8 trotz 1-Euro und ceil-1 Live-Box und Labor trotzdem verzerrte: Reconnect behielt den 1-Euro-Zustand der UUID (Ghost-Kiste), Masken matchten den vollen Print (Stoff als Identität), TAR@0,1 % bei n=10 hatte keine CI, und Detect-Abbruch nach Ingest vergaß die restlichen Media-IDs.

1. **1-Euro-Reset nach `pinByPrint`.** UUID-Reconnect verwirft den Filter — Box springt auf die neue Position.
2. **Teil-Print.** Augen ohne Mund → oberes Crop, `combinePrint` dämpft den vollen Print (Deckel 88). Overlay „Maske · Teil-Print“.
3. **TAR Bootstrap-CI** bei n_impostor < 200. Labor schreibt `[lo–hi]`.
4. **Detect-Resume.** Restliche Media-IDs in UserDefaults, Taste Fortsetzen nach Ingest-Abbruch.

## In 2.1.8 wirklich im Code

Warum 2.1.7 trotz ehrlichem lookOf und Reconnect trotzdem Labor und Live verzerrte: TAR@FAR nahm `floor(far·n)` statt `ceil−1`, die Live-Box ruckelte mit EMA 0,62/0,38, `printRevision` lag stumm in gallery.json, und ein abgebrochener Ordner begann von vorn.

1. **`MatchMath.tar` ceil-1.** n=10 FAR=0,1 → Index 0 (höchster Impostor), nicht Index 1 (20 % FAR). Labor ruft dieselbe Funktion, kein eigener Raster-Loop.
2. **Live-Box 1-Euro.** Pro UUID, unabhängig vom Print. EMA 0,62/0,38 ist weg.
3. **`printRevision`-Warnung.** UI zeigt, wenn die Galerie unter einem anderen Vision-Modell entstand.
4. **Scan-Resume.** Bookmark des letzten Ordners, restliche Pfade nach Abbruch, Taste „Fortsetzen“.
5. **Yaw-binärer Print.** Probe gegen denselben Slot (F/¾/P), 0,72 Slot + 0,28 Gesamt-Centroid.
6. **Labor-Gewichte.** Report listet capture/sharpness/weight/slot pro Referenz.

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

- Orient-Konflikt als eine Zeile Auto vs Override vs EXIF im Labor.
- U-Slot-Vorschlag nach 1,2 s Maske im Live-Track, nie still schreiben.
- ForcedPartial extra Laborzeile für TAR ohne Full-Paare (Genuine-Split ist da, Impostor noch gemischt).

## Erweiterungen

- **Drop-in `.mlmodel`.** `FaceEmbedder` als Protokoll, Apple-Print default, ArcFace optional (Lizenz!).
- **PhotoKit-Scan.** Mediathek lokal, nur mit expliziter Foto-Berechtigung.
- **Cluster vor Anlegen.** Unbenannte Gesichter: „3 Fotos, dieselbe Person?“
- **Track über Dateien.** Dieselbe Person in Video A und Foto B über Print.
- **Export Embeddings.** CSV/JSON der Face-Prints ohne Bilder.
- **GPU-Batch.** Ein `VNImageRequestHandler`, viele Requests.
- **Kalibrier-Set.** Fünf eigene Fotos (frontal, ¾, Hut, Nacht, Lächeln) als Selbsttest.
- **Score-Kalibrierung pro Galerie.** Platt-Skalierung auf Leave-one-out statt globaler Sigmoid.
- **Pose-normalisierter Print.** Yaw/Pitch vor dem Crop, nicht nur Slot-Mix.
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
- **Familien-Cluster UI.** Pairwise-Heatmap im Labor, nicht nur +4 Floor.
- **Print-Alter.** Referenz älter als N Tage markieren — Frisur/Bart driftet.
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, derselbe Track über Print, nicht IoU.
- **Quality-Gate als harte Ablehnung** unter 0,12 sharpness, nicht nur Score-Dämpfung.
- **Gallery.json Schema-Version** neben printRevision, damit 2.x Leser 3.x Felder überspringen.
- **Hard-Negativ vergessen.** Taste „doch Name“ entfernt den Deckel.
- **Score-Histogramm im Labor.** Genuine vs Impostor als ASCII/Spark, nicht nur mean/median.
- **Live-Quality-Ampel.** Capture/sharpness/yaw als drei Punkte am Overlay, bevor der Name kommt.
- **Print-Alter 90 Tage.** Referenz älter als N Tage markieren — liegt schon als „Print-Alter“ oben, UI- paler.
- **Geschwister-Wizard.** Pairwise-Heatmap vorschlagen, Floor +4 bestätigen lassen.
- **Masken-Enrollment-Slot.** Explizite „obere Hälfte“-Referenz, wenn jemand oft Maske trägt.
- **PartialPrint-Laborzeile.** Genuine-Paare mit/ohne Maske getrennt, sonst TAR die Masken-Dämpfung.
- **Tile-Budget.** Max. 2 Extra-Detects statt 5 Origins, wenn Crowd echt ist.
- **Schärfe vor dem Print.** Laplacian < Floor → Request gar nicht erst, spart Vision.
- **Continuity-Schärfe weicher.** Desk-View oft 0,10–0,14 — Floor 0,08 nur für diese uniqueID, nicht global.
- **U-Slot vom Live-Hold.** 1,2 s Maske im Track → Vorschlag „als Teil-Print“, nie still schreiben.
- **forcedPartial im Labor.** U-Refs extra Zeile, damit TAR nicht mit Full-Paaren gemischt wird.
- **Orient-Menü auch ohne Live.** Letzte uniqueID merken, Override vor Webcam-Start setzen.

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
- TAR@FAR wieder mit `floor(far·n)` (misst 2× den Ziel-FAR).
- Live-Box wieder EMA 0,62/0,38.
- 1-Euro nach Reconnect weiterlaufen lassen (Ghost-Box).
- Voller Print als Identität, wenn der Mund fehlt.
- TAR ohne CI bei n_impostor < 200.
- Teil-Print gegen den vollen Galerie-Centroid (Domain-Mix).
- Maske als erste Referenz (Stoff im Mean).
- Tiles über einem großen Portrait-Gesicht.
- Schärfe < 0,12 trotzdem taufen.
- `VNGenerateFacePrint` auf unscharfen Crops (Laplacian < Floor).
- U-Slot als erste Referenz (Stoff im Mean) — Taste U blockt das.
- Continuity-Yaw hart aus `videoRotationAngle` ohne Override.
