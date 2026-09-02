# Aegis — Vorschlagsliste

Stand: **2.1.18 alpha**. Nur `main`. `bugfix` ist Altlast — nicht fortsetzen.

## In 2.1.18 wirklich im Code

Warum Live sich tot/falsch anfühlte: eingeschriebene Live-UUIDs klebten als Geister-Kiste wenn niemand da war (IoU-Rest 0,08 klaute die ID vom Nachbarn), Pin-Print 0,72 vertauschte Geschwister, die Webcam nahm das erste Built-in (nicht Front), Labor warf Continuity-Refs mit Laplacian 0,10 raus, Burst-Filter schwieg.

1. **Geister-Kisten.** `found.isEmpty` → Live-Faces weg. Galerie-Snapshots haben anderes `mediaId`.
2. **`pinPrintCosine` 0,80.** `MatchMath.pinByPrint`. 0,72 klebte Geschwister.
3. **Leftover-IoU 0,18.**
4. **`preferredCamera` Front-Wide** vor Continuity/Desk-View.
5. **`LiveCapture.stop`** räumt tap / Continuity / uniqueID.
6. **Labor-Floor 0,08** (`laborQualityRejects`) für eingeschriebene Refs.
7. **Ingest-Duplikat** in der Statuszeile (`n Burst-Kopien übersprungen`).
8. Caption `+` = extra Foto, Namensfeld egal.
9. `poseCoverageBlocks` gibt nil — dritter Frontal blockt nicht.
10. MARKETING_VERSION 2.1.18 (Build 46), `Models.swift` + `VERSION` gleich.

## In 2.1.17 wirklich im Code

- Live + Anlegen: Track behält UUID, Galerie bekommt Kopie.
- Pose-Slot warnt, blockt nicht.
- `+` disabled nur ohne Gesicht.

## In 2.1.15–2.1.16

`rematchLive`, Continuity-Blend 0,20, Box-Hysterese, Ingest-Duplikat 0,95, Labor ohne Unschärfe-Paare, `gallery.json.bak`, `enrolledAt`, Spark-Reset, familyBump pro Paar, OneEuro-Init öffentlich. TAR `floor(far·n)−1`.

## Nächste Fixes (klein)

- Ampel-Spark Continuity-Floor in gespeicherten `qualitySpark` markieren (jetzt über `item.kind == .live`).
- `enrolledAt` paler in der UI, wenn `printAgeDays ≥ 90`.
- Gallery.json Schema-Version neben printRevision.
- Labor: Genuine-vs-U ohne Full-Paare extra Zeile (ForcedPartial).
- `boxEuro` hart leeren wenn `cameraUniqueID` wechselt (Reconnect in derselben Session).
- Snapshot-Live-Kopie `mediaId` in einer unsichtbaren Gallery-Media-Row, sonst Browse zählt sie nicht.

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
- **Helios-Bridge.** Eine Kamera-Session, eine TCC-Freigabe — kein Code kopieren.
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
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, derselbe Track über Print, nicht IoU.
- **Geschwister-Wizard.** Pairwise-Heatmap vorschlagen, Floor +4 bestätigen lassen.
- **Live-Quality-Ampel persistieren.** C/S/Y der letzten Session im Labor.
- **Partial-vs-Full Confusion-Matrix** extra Block.
- **Continuity uniqueID-Liste.** Manuell markieren, falls Desk-View nicht als Continuity erkannt wird.
- **Yaw aus Landmarks**, wenn `face.yaw` 0 und Vision keine Pose lieferte.
- **Box-1-Euro minCutoff** nach mittlerem Frame-dt (8 fps vs 24 fps) — Filter hat dt, Cutoff ist fest.
- **Gallery-Restore.** UI „letzte gallery.json.bak laden“ nach kaputtem Save.
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Leave-one-identity-out Labor.** Neben Leave-one-photo, damit 2-Personen-Galerien nicht sich selbst messen.
- **Live-Match nur Centroids.** `rematchLive` soll nicht jedes Ref-Foto neu scoren — ein Dot pro Identität.
- **Median-Blend** der letzten 5 Live-Prints statt One-Euro-alpha, weniger Glücks-Frame.
- **Hard-Negativ im Overlay.** Taste N wie U, ohne Umweg über Ablehnen-Menü.
- **Scan-Queue priorisiert große Gesichter** (Portrait zuerst, Crowd später).
- **HEIC-Gain-Map** als Capture-Qualität, nicht nur Laplacian.
- **Identität umbenennen** in der Liste (jetzt nur löschen + neu).
- **Export Labor als CSV-Datei**, nicht nur Textfeld.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API. Aegis ist lokal.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50.
- `lookOf` wieder als 0,75/0,25-Mix.
- `if embed < 1 { return geo }`. 0,4 % ist ein Impostor, kein fehlender Print.
- Static `matchFloor` wieder process-weit.
- Ungewichteter 1/n-Centroid.
- `printVec` wieder leer lassen nach `stampPrints`.
- Coverage nur warnen.
- TAR@FAR mit `ceil(far·n)−1` (bricht n=101 → Schwelle 10).
- Live-Box wieder EMA 0,62/0,38.
- 1-Euro nach Reconnect weiterlaufen lassen (Ghost-Box).
- Voller Print als Identität, wenn der Mund fehlt.
- TAR ohne CI bei n_impostor < 200.
- Teil-Print gegen den vollen Galerie-Centroid.
- Maske als erste Referenz.
- Tiles über einem großen Portrait-Gesicht.
- Schärfe < 0,12 trotzdem taufen (Built-in). Continuity bleibt 0,08.
- `VNGenerateFacePrint` auf unscharfen Crops.
- U-Slot als erste Referenz.
- Continuity-Yaw hart aus `videoRotationAngle` ohne Override.
- `qualityRejects` wieder ohne Continuity-Floor.
- Live-Frames droppen statt coalescen.
- U-Slot still schreiben nach Masken-Hold.
- `bugfix`-Branch fortsetzen. Nur `main`.
- Versionsstempel in Models ohne MARKETING_VERSION.
- Live-Track in der Overlay-Liste lassen, wenn `found.isEmpty`.
- Pin-Print unter 0,80.
- Leftover-IoU 0,08.
