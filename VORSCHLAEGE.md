# Aegis — Vorschlagsliste

Stand: **2.1.23 alpha**. Nur `main`. `bugfix` ist Altlast — nicht fortsetzen.

## In 2.1.23 wirklich im Code

2.1.22 hat Track-Pin 0,28 und liveCentroid 72/28 — Geo-Veto war trotzdem tot: `matchLive` fakte `geoAgrees: true` / `geoMix: printPercent`. Leftover klebte enrolled UUIDs auf jede namenlose Box (Nachbar erbt). IoU setzte die UUID auch bei Print-Cosine 0,45. Overlay kippte die volle decide-Zeile in die Kiste.

1. **`matchLive` echte Landmark-Geo.** Median der `ratioSheet`-Identitätsmaße vs. Sonde. `geoAgrees` / `geoMix` ehrlich. Fehlende Geo → kein Veto (`liveGeoAgrees`).
2. **Leftover nur namenlos.** `leftoverAdoptAllowed` — schon eingeschriebene adopted-Boxen bleiben. Print-Veto wie IoU.
3. **IoU stiehlt nicht** wenn Cosine gemessen und `< pinPrintCosine`. `iouPrintBlocks`. Euro der falschen UUID wird geleert.
4. **`overlayNoteFirst`:** erste Klausel im Overlay, volle Notiz in der Seitenliste.
5. `ratioPercent` / `medianComponents` in MatchMath — dieselbe Kurve wie Still-`ratioScore`.
6. MARKETING_VERSION 2.1.23 (Build 51), `Models.swift` + `VERSION` gleich.

## In 2.1.22 wirklich im Code

2.1.21 leftover 0,28 galt nur dem *zweiten* Pin. Der erste enrolled Track klebte weiter bei IoU **0,12** — zwei Köpfe im Bild, eine UUID wandert. Overlay `1 − cosine > 0,12` (also cosine < 0,88) markierte fast jeden echten Treffer als „andere Person“. `matchLive` rief `tinyUnreliable(..., continuity: false)` und `meanPrintVector` über alle Posen. `stabilizeLiveMatches` schrieb leere Prints in die Mehrheit und ließ gelöschte UUIDs stehen. 1-Euro bei 8 fps: Box einen Frame hinten.

1. **`trackPinIoU` 0,28.** `MatchMath.trackPin` für enrolled und leftover. 0,12 ist tot.
2. **`liveCentroid` 72 % Frontal + 28 % alle.** `matchLive` und Overlay-Hint nutzen denselben Vektor.
3. **`overlayAlienHint` Cosine < 0,50.** Genuine 0,62–0,85 bleibt still.
4. **`tinyUnreliable(continuity: liveContinuity)`** in `matchLive`.
5. **`oneEuroCutoff`:** dt ≥ 0,10 → ×1,7.
6. **`stabilizeLiveMatches`:** `!measured` skip; UUID nicht in der Galerie → `identityId = nil`.
7. MARKETING_VERSION 2.1.22 (Build 50), `Models.swift` + `VERSION` gleich.

## In 2.1.21 wirklich im Code

2.1.20 hat Centroids und boxEuro-Reset — Live ließ echte 90 %-Prints trotzdem fallen: `lookOf` kappte auf 60 sobald Landmark-Geo < 35 (Jacke, Haar, ¾). Geo-Veto blockte 93 % bei Geo 18. Namensmehrheit 3 Ticks ohne den Prozentwert der gewählten ID. Leftover 0,18 klaute die UUID. Overlay schrieb nur „nicht zugeordnet“.

1. **`lookOf` starker Print (≥ 84) nie unter Embed.** Geo gibt weiter bis +4, kappt nicht auf 60.
2. **`geoVetoBlocks` skip ab 88 % Print.** 84–87 nur noch bei Geo < 22.
3. **`nameVoteFrames` 5** + **`votedPercent`**: Overlay zeigt den Score der gewählten Identität, dann EMA.
4. **`leftoverIoU` 0,28.** Auswahl bleibt am Track, solange er da ist.
5. **Overlay-Badge** zeigt die decide-Notiz statt nur „nicht zugeordnet“.
6. MARKETING_VERSION 2.1.21 (Build 49).

## In 2.1.20 wirklich im Code

Warum Live falsch taufte, auch nach 2.1.19: `rematchLive` hat das volle Ensemble über jedes Galerie-Foto, Profile ohne Vision-Yaw = Frontal, Crop-Print mit zweiter Orientierung, 1-Euro überlebte den Kamerawechsel, dritter Frontal blockte nicht.

1. **`matchLive` Centroids.** Eine Sonde, ein Mittelvektor pro Identität. Danach 3-Tick aus 2.1.19.
2. **Median-Blend** letzte 5 Live-Prints (`MatchMath.medianBlend`).
3. **Yaw aus Landmarks** wenn `|yaw| < 0,02`.
4. **Crop-Print `.up`**, nur wenn der Handler schon aufrecht ist.
5. **`poseCoverageBlocks`** — 3. gleicher Slot, solange Frontal oder ¾ fehlt.
6. **`boxEuro` + Print-Trail leer** bei `cameraUniqueID`-Wechsel.
7. **`leftoverIoU` 0,18** benannt. Leftover-Pin nur darüber.
8. Anlegen-Confirm Centroid **0,82** (war 0,88).
9. Labor: Centroid-Cosine zwischen Identitäten.
10. MARKETING_VERSION 2.1.20 (Build 48), `Models.swift` + `VERSION` gleich.

## In 2.1.19 wirklich im Code

Warum 2.1.18 Live zwischen Geschwistern sprang und Jacken taufte: `rematchLive` schrieb jeden Frame den Roh-Namen. `fusedOf` nahm TER-Fusion (lookRow 0,40 + geoRow 0,26 + graph 0,14 + texture 0,03) — Geometrie doppelt, Kleidung als Identität. `decide` blockte `!geoAgrees && geoMix < 42 && percent < 94`. `graphBiomarkers` 4× Jacobi + Floyd–Warshall pro Live-Gesicht. `.bak` ohne UI.

1. **`nameMajority` 3 Ticks** + **`liveScoreEMA` 0,35** in `stabilizeLiveMatches`.
2. **`.aegis` = `lookOf`**, sobald Print gemessen. TER bleibt Anzeige-Spur.
3. **`geoVetoBlocks`.** 90 %+ Print nur bei Geo < 22, 84 %+ bei Geo < 35.
4. **`cheapGraphBiomarkers`** im Live-Detect (kein Jacobi).
5. **Backup-Taste** lädt `gallery.json.bak`.
6. **`pruneKeepIncoming`** beim `+` (Cosine > 0,98, Schärfere bleibt).
7. MARKETING_VERSION 2.1.19 (Build 47).

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
- Snapshot-Live-Kopie `mediaId` in einer unsichtbaren Gallery-Media-Row, sonst Browse zählt sie nicht.
- TER-Fusion in der Strategie-Liste als Diagnose, Default aus — `.aegis` braucht sie nicht mehr zum Taufen.
- Jacobi nur noch im Labor / Still, nie Live. Cheap-Graph auch bei Scan-Tiles.
- Restore bestätigt, wenn Backup älter als 7 Tage oder andere printRevision.
- Live-Geo-Spark neben C/S/Y (eine Zahl, Median-Maße vs. gewählter Centroid).
- `ratioSheet` im Live-Pfad nur Identitätszeilen, Mimik gar nicht erst rechnen.
- Leftover-Pin loggen (Status eine Zeile), sonst bleibt UUID-Sprung unsichtbar.
- boxEuro Reset auch wenn IoU hält aber Hysterese die Box der Vorperson zeigt — Print-Pin gewinnt in dem Frame.

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
- **Identitäten mergen.** UI-Button, nicht nur Anlegen-Confirm bei Centroid > 0,82.
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
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Leave-one-identity-out Labor.** Neben Leave-one-photo, damit 2-Personen-Galerien nicht sich selbst messen.
- **Hard-Negativ im Overlay.** Taste N wie U, ohne Umweg über Ablehnen-Menü.
- **Scan-Queue priorisiert große Gesichter** (Portrait zuerst, Crowd später).
- **HEIC-Gain-Map** als Capture-Qualität, nicht nur Laplacian.
- **Identität umbenennen** in der Liste (jetzt nur löschen + neu).
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Live-Quality an Frame-dt.** 8 fps vs 24 fps: Spark-Fenster in Sekunden, nicht Frames.
- **Score-Kalibrierung live.** Platt auf den letzten 200 Live-Ticks, Slider nur Bias.
- **Geschwister-Hold.** Wenn familyBump greift, Mehrheit bleibt 5 Ticks (jetzt default).
- **Cheap-Graph auch Still**, wenn graphBio aus ist — Detect soll die Spur nicht trotzdem rechnen.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Enrollment-Wizard.** Pose-Coverage-Meter (frontal / ¾ / Profil) bevor die erste Person „fertig“ heißt.
- **Live Hold-Still-Ring** 0,8 s vor Print-Request — spart unscharfe Embeds.
- **Burst-Median** der letzten 5 Live-Prints beim `+`, nicht nur im Track.
- **Licht-Eimer.** Tags Tag/Kunstlicht/Nacht am Face, Match bevorzugt denselben Eimer.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix, decide-Notiz) für Labor nach der Session.
- **Hard-Neg „gleiche Jacke“.** Texture-Hit ohne Print → explizit ablehnen.
- **Labor TAR@FAR live-simuliert:** letzte 50 Webcam-Prints gegen die Galerie, nicht nur Still-Fotos.
- **Geo-Veto-Log.** Eine Zeile im Overlay wenn Maße blocken, nicht nur „nicht zugeordnet“.
- **Per-Identität leftover.** Nur die UUID, deren Centroid am nächsten liegt, darf leftover — nie die älteste.
- **Track-ID entkoppelt von Face-UUID.** Live-Track `T…`, Galerie bleibt Snapshot-UUID — Anlegen kann nicht mehr den Track umbiegen.
- **ratioSheet Cache** am Identity-Modell, nicht jedes Live-Frame neu medianen.
- **Yaw-bin Geo.** ¾-Refs nur gegen ¾-Sonden, sonst Profile zerstören den Median.
- **Print-first Matcher** als eigene Strategy-Hit-Zeile im Live (nicht nur .aegis), zum Debug.
- **Box-Hysterese + Print-Pin in einem Pass.** Jetzt IoU dann Print; bei Uneinigkeit zwei Frames UUID-Flackern.

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
- Coverage nur warnen, wenn Frontal und ¾ fehlen.
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
- TER-Fusion wieder in `.aegis` mischen. lookOf ist der Score.
- Geo-Veto 42/94 gegen starke Prints.
- 4× Jacobi pro Webcam-Frame.
- `lookOf` starke Prints wieder auf 60 kappen.
- Leftover-IoU wieder 0,18.
- Namensmehrheit ohne `votedPercent`.
- Auswahl jedes Live-Frame auf `adopted.first` setzen.
- Enrolled-Track-IoU wieder 0,12.
- Overlay „andere Person“ bei Cosine 0,88.
- `matchLive` immer `continuity: false`.
- `matchLive` `geoAgrees: true` / `geoMix: printPercent` faken.
- Leftover auf schon gematchte/enrolled Boxen.
- IoU-UUID setzen bei Cosine < `pinPrintCosine`.
- Volle decide-Notiz in die Overlay-Kiste.
