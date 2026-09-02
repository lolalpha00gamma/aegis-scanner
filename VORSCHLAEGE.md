# Aegis — Vorschlagsliste

Stand: **2.1.15 alpha**. Nur `main`. `bugfix` ist Altlast — fehlende Helfer wurden nachgezogen, der Branch nicht fortgesetzt.

## In 2.1.15 wirklich im Code

Warum 2.1.14 sich tot anfühlte: der Versionsstempel in Xcode blieb 2.1.13 (CI-Tag), Live matchte **jedes** Scan-Gesicht jedes Frame, Print-Blend war 0,35 auch auf Continuity, und Box/Ingest/Labor-Qualität aus `bugfix` lag nicht auf `main`.

1. **`rematchLive`.** Galerie-Refs + Live-Sonden. History-Fotos nicht neu scoren.
2. **`liveBlendAlpha`.** Continuity 0,20 / Built-in 0,35.
3. **Box-Hysterese.** IoU < 0,35 hält; zweites Frame an der pending-Box bestätigt.
4. **`filterIngestDuplicates`.** Cosine > 0,95.
5. **Labor:** `laborIncludesProbe/Ref` skippt Unschärfe; `scoreHistogram`.
6. **`gallery.json.bak`** vor atomarem Save.
7. **`enrolledAt`.** Spark-Reset nach `pinByPrint`.
8. TAR bleibt `floor(far·n)−1` (n=101 FAR 1 % → 80). `bugfix` ceil−1 nicht übernommen.

## In 2.1.14 (Models/VERSION, nicht vollständig im Binary)

Claim: rematchLive, Continuity-Blend, 1-Euro dt, Labor-Histogramm. 1-Euro `dt` war schon in `OneEuro.filter`. Der Rest sitzt erst in 2.1.15.

## In 2.1.13 wirklich im Code

1. **`qualityRejects(continuity:)`.** Derselbe Floor wie `skipPrint`.
2. **Live-Coalesce.** `livePending`.
3. **U-Slot nach 1,2 s Maske.** Status-Vorschlag, nie still geschrieben.
4. **Labor Impostor frei vs Teil-Print.** TAR ohne Masken-Paare.

## In 2.1.12–2.1.7

Siehe Git-Log. Kurz: Ampel-Spark, Tile-Budget 2, Continuity-Floor 0,08, Orient-Override, U-Slot, Teil-Print vs Teil-Centroid, 1-Euro-Reset, TAR floor, lookOf ohne Geo-Fallback.

## Nächste Fixes (klein)

- Ampel-Spark Continuity-Floor in gespeicherten `qualitySpark` markieren (jetzt über `item.kind == .live`).
- `enrolledAt` paler in der UI, wenn `printAgeDays ≥ 90`.
- `boxJumpPending` nach Monitor-/Kamerawchsel hart leeren (stopLive tut es).
- Gallery.json Schema-Version neben printRevision.
- Labor: Genuine-vs-U ohne Full-Paare extra Zeile (ForcedPartial).

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
- **Ingest-Duplikat-Log.** Status „12 Burst-Kopien übersprungen“, nicht still.
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Leave-one-identity-out Labor.** Neben Leave-one-photo, damit 2-Personen-Galerien nicht sich selbst messen.

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
