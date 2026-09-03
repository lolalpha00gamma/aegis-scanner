# Aegis — Vorschlagsliste

Stand: **2.1.37 alpha**. Nur `main`. `bugfix` ist Altlast — nicht fortsetzen.

## In 2.1.37 wirklich im Code

2.1.36 leftover tauft nicht unter 0,80 — Overlay-Kiste blieb trotzdem grün wie enrolled. Taufe-Hold unsichtbar (Live wirkt tot für 0,28–0,80 s). Slot-Buchstabe ohne Farbe. Close-Pair ohne Badge. Continuity still Fallback, kein Picker.

1. **`overlayBoxKind`.** leftover orange, enrolled grün, selected weiß.
2. **`nameVoteProgress`.** Overlay `2/3` / `5/7` bis Mehrheit sitzt.
3. **`siblingBadge`.** pairCosine ≥ 0,80 → „Geschwister?“.
4. **`slotTone`.** F grün, ¾ amber, P rot, U violet.
5. **Kamera-Picker** Auto / Built-in / Continuity. Prefs. Webcam-Restart.
6. Tests: boxKind, voteProgress, siblingBadge, slotTone.
7. MARKETING_VERSION 2.1.37 (Build 64), `Models.swift` + `VERSION` gleich.

## In 2.1.36 wirklich im Code

2.1.35 Familien-Taufe 5 Ticks — leftover 0,64 erbte UUID **und** Namens-Hist. Look-Delta 8 ohne Centroid. Taufe in Frames (24 fps = 80 ms).

1. **`leftoverBaptize` 0,80.** Darunter Hold-Label, keine Taufe, Hist weg.
2. **`nameClosePair(pairCosine:)`.** Look-Delta < 8 **und** Centroid ≥ 0,80.
3. **`nameAgreeNeed(family:dt:)`.** 0,28 s / 0,80 s, geklemmt 2–10 / 5–16 Ticks. `liveDt` aus PTS.
4. MARKETING_VERSION 2.1.36 (Build 63), `Models.swift` + `VERSION` gleich.

## In 2.1.35 wirklich im Code

2.1.34 war ein Versionsstempel ohne Code: Models 2.1.33, pbxproj Build 61, Taufe 2 Ticks, leftover unsichtbar. Commit-Text log.

1. **`nameAgreeNeed(family:)` 5 Ticks** bei close Pair (< 8 Punkte), sonst 2.
2. **`nameHistCap(need+3)`.** Leere Tokens zählen nicht und kürzen das Fenster nicht auf unter Need.
3. **`leftoverHoldLabel`** Overlay + Status `gehalten 0.64`.
4. **`renameConfirmSameId`.** Confirm einer anderen Zeile tot.
5. MARKETING_VERSION 2.1.35 (Build 62), `Models.swift` + `VERSION` gleich.

## In 2.1.34 nicht im Code

VERSION-Datei 2.1.34, Commit-Text Familien-Taufe/Hold-Label — Models 2.1.33, pbxproj Build 61, `nameAgreeNeed` 2. Die Fixes sitzen in 2.1.35.

## In 2.1.33 wirklich im Code

2.1.32 PTS und Slot-Count — ein Look=Print-Tick taufte. Look≠Print zählte. Rename klebte. `.bak` ohne fsync. Kleine Box rauscht. Overlay ohne Slot/Namen.

1. **`nameMajorityAgreeing` 2 Ticks.** Leere Tokens zählen nicht. Sonst keine Taufe.
2. **`renameConfirmExpired` 8 s.**
3. **`.bak` fsync** nach Copy.
4. **`oneEuroCutoff` + Box-Fläche.** < 0,04 → ×1,45.
5. **`slotLetter` + `liveNameDisagreeLabel`** im Overlay.
6. Tests: agreeing, expired, slotLetter, kleine Box.
7. MARKETING_VERSION 2.1.33 (Build 61), `Models.swift` + `VERSION` gleich.

## In 2.1.32 wirklich im Code

2.1.31 hat Look=Print, Slot-hart leftover, Trail-Slot, fsync — 1-Euro dt kam trotzdem aus der Apply-Wanduhr (Coalesce → dt 0). `+` ließ den Live-Trail auf dem alten Centroid. Slot-Count nur in der Statuszeile.

1. **1-Euro dt aus PTS.** FrameTap reicht den Sample-Stempel durch `onFrame` bis `applyLiveFaces`.
2. **`+` leert Print-Trail.** Neuer Ref darf den Median nicht mit der Vorperson mischen.
3. **`slotCountLabel`** in der Namensliste `F 2 · ¾ 1 · P 0 · U 0`.
4. Tests: slotCountLabel.
5. MARKETING_VERSION 2.1.32 (Build 60), `Models.swift` + `VERSION` gleich.

## In 2.1.31 wirklich im Code

2.1.30 leftover sameSlot fiel auf alle printable, wenn der Slot leer war (¾-Ghost pinnt Frontal). lookOf-Sieger ≠ Print-Sieger taufte. Print-Trail mischte Frontal+¾. boxPinTakePrint stahl namenlose Hold. Rename ohne Duplikat-Confirm. gallery.json ohne fsync.

1. **`leftoverPick` Slot-hart.** sameSlot gesetzt + kein Treffer → nil.
2. **`liveNameAgree`.** Look ≠ Print → keine Taufe, Notiz „Look und Print uneinig“.
3. **`printTrailAccepts`.** Slot-Wechsel leert den Median-Trail.
4. **`boxPinTakePrint` nur enrolled/named.**
5. **`renameConflict` + Confirm** (zweites Return).
6. **`GalleryFile.save` fsync** nach atomarem Write.
7. Tests: leftover all-false sameSlot, liveNameAgree, printTrailAccepts, renameConflict, printEnrolled.
8. MARKETING_VERSION 2.1.31 (Build 59), `Models.swift` + `VERSION` gleich.

## In 2.1.30 wirklich im Code

2.1.29 hat Cap-Notiz, Pose-Gewicht, Tick-Cache — leftover ignorierte den Pose-Slot (¾-Ghost pinnt Frontal-Nachbarn). IoU-Hysterese und Print-Pin uneinig → zwei Frames UUID-Flackern. Overlay nur „Print 82%“, kein Look. Identität nur löschen+neu.

1. **`leftoverPick sameSlot`.** Gleicher Pose-Slot zuerst, sonst Print-Score.
2. **`boxPinTakePrint`.** IoU-Hold + anderer Print-Pin → Print im selben Pass.
3. **`lookPrintLabel`.** Overlay `P 82 · L 82`, Cap-Silbe bleibt 2.1.29.
4. **Identität umbenennen.** TextField Return, persist.
5. Tests: sameSlot, lookPrintLabel, boxPinTakePrint.
6. MARKETING_VERSION 2.1.30 (Build 58), `Models.swift` + `VERSION` gleich.

## In 2.1.29 wirklich im Code

2.1.28 lookOf im Live mit Pose=1, Deckel unsichtbar, Centroids jedes Gesicht, Print-Hit = lookOf.

1. **`lookOfCapNote` „Print gekappt“** wenn < 70 bei Geo < 35 wirklich auf 60.
2. **`matchLive` poseWeight**, nicht Pose 1.
3. **Centroid/ratioSheet Cache** je Identität×Slot über den Tick.
4. **Print-Hit Sigmoid**, `.aegis` lookOf.
5. MARKETING_VERSION 2.1.29 (Build 57), `Models.swift` + `VERSION` gleich.

## In 2.1.28 wirklich im Code

2.1.27 leftover 0,72 / lookOf ≥ 80 — Live nutzte lookOf **nicht**. `matchLive` scored Roh-Print, `geoVetoSkipPrint` 88 kippte Genuine 80–87 % mit Jacke. Leftover 0,72 ließ 0,62–0,71 fallen. Unschärfe ging in den Median-Trail.

1. **`matchLive` lookOf.** Ohne gemessenes Print-Paar 0, nicht Geo.
2. **`geoVetoSkipPrint` 80** — decide und lookOf gleich.
3. **`leftoverPrintCosine` 0,64** + scharfer Genuine 0,62 (`leftoverPrintOk` + Schärfe).
4. **Print-Trail `skipPrint`.** Laplacian unter Floor behält den alten Vektor.
5. **`leftoverScore`.** Schärfe-Bonus 0,05 — 0,72 scharf schlägt 0,73 blur.
6. MARKETING_VERSION 2.1.28 (Build 56), `Models.swift` + `VERSION` gleich.

## In 2.1.27 wirklich im Code

2.1.26 leftover ging über `iouPrintBlocks` (0,80) — Genuine 0,62–0,85 pinnten nicht. `lookOf` kappte 80–83 % auf 60 sobald Geo < 35. Hold-Still IoU 0,82 klebte den Print beim Nicken. `liveCentroid` rechnete immer den All-Mean, auch bei Slot-Hit.

1. **`leftoverPrintCosine` 0,72** / `leftoverPrintOk`. Enrolled Pin bleibt 0,80.
2. **`lookOf` ≥ 80 nie kappen.** < 70 + Geo < 35 → min(embed, 60).
3. **Hold-Still + Schärfe.** IoU-Floor 0,70, `holdStillSharp` 0,18. Nicken mit scharfem Crop darf.
4. **`liveCentroid` Slot zuerst**, All-Mean nur Fallback.
5. MARKETING_VERSION 2.1.27 (Build 55), `Models.swift` + `VERSION` gleich.

## In 2.1.26 wirklich im Code

2.1.25 hat Slot-Centroid und leftover nächster Print — Live zeigte trotzdem die Box der Vorperson (Hysterese + 1-Euro), Mimik-Zeilen liefen jeden Webcam-Frame, Restore war ein Klick ohne Warnung, TER-Fusion blieb default an.

1. **`boxEuroResetOnHysteresis`.** Print-Pin ≥ 0,80 + IoU-Hysterese → Euro leer, neue Box.
2. **Live-`ratioSheet` identity-only.** Mimik wird im cheapGraph-Pfad nicht mehr gelegt. Scan-Tiles `cheapGraph: true`.
3. **TER-Fusion `defaultEnabled` ohne `.terFusion`.** Diagnose, Toggle bleibt. Einmal-Migration räumt alte allCases-Prefs.
4. **Restore-Dialog.** ≥ 7 Tage / Schema < 2 / andere printRevision.
5. **Ampel Continuity-Floor (S·), Geo-Spark, Track gehalten/neu.** `enrolledAt` paler ≥ 90 d.
6. **Snapshot-Media-Row** für Live-Kopien. Labor Genuine-vs-U extra Zeile.
7. MARKETING_VERSION 2.1.26 (Build 54), `Models.swift` + `VERSION` gleich.

## In 2.1.25 wirklich im Code

2.1.24 hat Geo je Pose-Slot — der **Print** blieb 72/28 über alle Posen: ¾-Sonde vs. Frontal-Centroid weich. Leftover nahm first-in-order, nicht den nächsten Print. `overlayHint` mischte die Galerie. Yaw-Skip war unsichtbar. Bewegung lieferte trotzdem einen neuen Print (Blur). Enrollment-Pose nur schwach in der Statuszeile.

1. **`liveCentroid(slot:)`.** ¾-Sonde gegen ¾-Refs, 72/28 nur Fallback. `matchLive` und Overlay-Hint.
2. **Leftover nächster Print.** `leftoverPick` / `leftoverRank` — nicht die ältere UUID.
3. **Leftover-Status** eine Zeile (`Live · Leftover-Pin n Track`).
4. **Yaw-Skip in decide-Notiz** (`¾, Maße ignoriert`).
5. **Hold-Still** IoU < 0,82 → alten Print behalten.
6. **Pose-Meter** in Anlegen-Status (`Pose fehlt Frontal+¾` / `Pose fertig`).
7. MARKETING_VERSION 2.1.25 (Build 53), `Models.swift` + `VERSION` gleich.

## In 2.1.24 wirklich im Code

2.1.23 hat echte Geo und leftover-Adopt — Namen flackerten trotzdem: `leftoverPinned` filterte `identities.faceIds` (Galerie-Snapshot). Seit 2.1.17 hat der Live-Track eine eigene UUID, leftover war immer leer. Leftover ohne Print klebte die UUID auf den Nachbarn. `matchLive` nahm den Maß-Median über **alle** Posen: ¾-Sonde vs. Frontal-Centroid → geoMix ~15, `geoVetoBlocks` kippte echte 80–87 %-Prints. `gallery.json` ohne Schema-Version.

1. **Leftover über namedTracks.** Letzter `.aegis`-Treffer am Live-Track, nicht Galerie-UUID. `leftoverNamedTrack`.
2. **Leftover braucht Print.** `leftoverNeedsPrint` — nil-Cosine pinnt nicht.
3. **Track-Pin `namedTracks`.** IoU-Print-Veto gilt dem genannten Live-Track, nicht nur enrolled Snapshot-UUIDs.
4. **Geo je Pose-Slot.** ¾-Sonde gegen ¾-Refs, sonst Fallback alle. Frontal-Maße vetoieren ¾ nicht.
5. **`geoVetoBlocks(..., yawAbs)`.** Yaw ≥ 0,28 und Print ≥ 80 → kein Veto (`geoVetoYawSkip` / `geoVetoYawPrint`).
6. **`gallery.json` Schema 2** neben `printRevision`.
7. MARKETING_VERSION 2.1.24 (Build 52), `Models.swift` + `VERSION` gleich.

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

- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Hold-Still-Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen.
- **liveCentroid Cache am Identity-Modell** (2.1.29 cacht nur den Tick; 2.1.32 leert den Trail bei `+`).
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Jacobi nur Still-Labor**, Scan-Tiles sind cheap — Still-Foto-Detect ohne Tiles noch voller Graph wenn `tiles: false` und nicht live.
- **Enrollment AE-Lock.** `+` wartet 200 ms nach Belichtungssprung.
- **Ampel G-Lampe** neben C/S/Y wenn lookOfCapped (rot) vs skip (grün).
- **gallery.json SHA-256** neben schemaVersion, Restore warnt bei Drift.
- **Enrollment-Coach.** „Kopf nach links“ wenn ¾ fehlt, nicht nur Statuszeile.
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Live-FAR** aus den letzten 200 Impostor-Ticks im Labor.
- **Galerie kompakt:** unscharfe same-Slot-Refs droppen, sobald eine scharfe da ist.
- **1-Euro minCutoff Slider** für Continuity vs Built-in, Fläche bleibt Bias.
- **Uneinig-Namen nur Live**, Still-Fotos nicht mit Look/Print-Ghosts.
- **Slot-Letter Farbe** (F grün, ¾ amber, P rot) analog Quality-Ampel. **→ 2.1.37 slotTone**
- **Leftover nicht taufen** bis Print ≥ 0,80 — Hold darf die Overlay-Kiste, nicht die Galerie. **→ 2.1.36 leftoverBaptize**
- **nameHist in Sekunden** (8 fps × 5 Ticks = 0,6 s), nicht Frame-Count. **→ 2.1.36 nameAgreeNeed(dt:)**
- **Pairwise close Pair aus Centroid-Cosine**, nicht nur Look-Delta 8. **→ 2.1.36 pairCosine**
- **Overlay leftover vs enrolled** verschiedene Kistenfarbe, nicht nur Text. **→ 2.1.37 overlayBoxKind**
- **Leftover-Hist nicht an die nächste Box vererben.** **→ 2.1.36 wipe**
- **Kamera-Picker** Built-in / Continuity analog Helios 1.5.19. **→ 2.1.37 CameraChoice**
- **Taufe-Hold sichtbar:** Overlay `2/3` bzw. `5/7` bis Mehrheit sitzt — sonst wirkt Live „tot“. **→ 2.1.37 nameVoteProgress**
- **Zwei-Personen-FAR im Overlay.** Wenn pairCosine ≥ 0,80, Badge „Geschwister?“ statt Name. **→ 2.1.37 siblingBadge**

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
- **Cheap-Graph auch Still**, wenn graphBio aus ist — Detect soll die Spur nicht trotzdem rechnen.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Enrollment-Wizard.** Pose-Coverage-Meter vor „fertig“ bleibt UI-Ring, Statuszeile ist 2.1.25.
- **Live Hold-Still-Ring** 0,8 s vor Print-Request — spart unscharfe Embeds visuell (Skip ist 2.1.25).
- **Burst-Median** der letzten 5 Live-Prints beim `+`, nicht nur im Track.
- **Licht-Eimer.** Tags Tag/Kunstlicht/Nacht am Face, Match bevorzugt denselben Eimer.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix, decide-Notiz) für Labor nach der Session.
- **Hard-Neg „gleiche Jacke“.** Texture-Hit ohne Print → explizit ablehnen.
- **Labor TAR@FAR live-simuliert:** letzte 50 Webcam-Prints gegen die Galerie, nicht nur Still-Fotos.
- **Geo-Veto-Log.** Eine Zeile im Overlay wenn Maße blocken, nicht nur „nicht zugeordnet“.
- **Track-ID entkoppelt von Face-UUID.** Live-Track `T…`, Galerie bleibt Snapshot-UUID — Anlegen kann nicht mehr den Track umbiegen.
- **ratioSheet Cache** am Identity-Modell, nicht jedes Live-Frame neu medianen.
- **Print-first Matcher** als eigene Strategy-Hit-Zeile im Live (nicht nur .aegis), zum Debug.
- **Box-Hysterese + Print-Pin in einem Pass.** Jetzt IoU dann Print; bei Uneinigkeit zwei Frames UUID-Flackern.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Continuity 8 fps:** Spark-Fenster in Sekunden (schon als Idee), analog Helios sampleDt.
- **Drop-in `.mlmodel` bleibt der große Sprung** — Apple-Print ist die Decke.
- **Live-FAR-Spark** letzte 200 Impostor-Ticks im Overlay, nicht nur Labor.
- **Enrollment-Coach.** „Kopf nach links“ wenn ¾ fehlt, Pose-Balken F/¾/P.
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück.
- **gallery.json SHA-256** neben schemaVersion.
- **Hold-Still-Ring** 0,8 s im Overlay.
- **Track-ID `T…` in der UI**, Galerie bleibt Snapshot-UUID.
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **liveCentroid Cache** am Identity-Modell (slot + printRevision).
- **Identitäten mergen** UI-Button, nicht nur Anlegen-Confirm.
- **Offen-Set.** Explizite „unbekannt“-Klasse.
- **Helios-Bridge.** Eine Kamera-Session, eine TCC.
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, Track über Print.
- **PhotoKit-Scan** nur mit expliziter Foto-Berechtigung.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix).
- **AE-Lock 200 ms** nach Belichtungssprung beim `+`.
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Per-Identität leftover-Log** in der Overlay-Kiste, nicht nur Statuszeile.
- **Hold-Still Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen, nicht nur Text.
- **liveCentroid Cache** am Identity-Modell, nicht jedes Live-Frame neu mischen.
- **Yaw-bedingtes leftover:** ¾-Sonde gegen leftover ¾-Print, nicht Frontal-Ghost.
- **Quality-Spark der leftover-UUID** im Overlay, damit man sieht warum 0,64 hielt.
- **decide-Notiz „Print gekappt“** nur unter 70 — 2.1.27 kappt ≥80 nicht mehr, Log fehlte.
- **Pairwise leftover vs. enrolled** eine Zeile im Labor (war der Pin zu Recht 0,64?).
- **lookOf-Delta im Overlay** (Print 82 → look 82, Geo 18) wenn Veto skippt — sonst wirkt 80 % „tot“.
- **Centroid-Cache** am Identity (slot + printRevision), nicht jedes Live-Frame `meanPrintVector`.
- **ratioSheet Cache** am Identity-Modell (steht schon unter Fixes, hier der Haken: matchLive mediant jedes Frame).
- **Overlay Print vs look** (`P 82 · L 82`) wenn Geo das Look nicht kippt — sonst wirkt skip „tot“.
- **Hard-Negativ Cosine-Floor live** aus Reject-Liste, nicht nur Labor.

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
- Leftover über Galerie-UUIDs (Live-Track ≠ Snapshot seit 2.1.17).
- Leftover ohne Print (nil-Cosine).
- Geo-Median über alle Posen gegen eine ¾-Sonde.
- Geo-Veto ¾-Sonde (yaw ≥ 0,28) gegen Frontal-Maße bei Print ≥ 80.
- `gallery.json` ohne schemaVersion schreiben.
- `bugfix`-Branch anlegen oder fortsetzen. Nur `main`.
- Leftover first-in-order statt nächstem Print.
- `liveCentroid` wieder 72/28 über alle Posen gegen eine ¾-Sonde.
- Neuen Print bei Box-Sprung (Motion-Blur) übernehmen.
- Yaw-Skip ohne Notiz.
- TER-Fusion wieder default an.
- Hysterese-Box der Vorperson trotz Print-Pin halten.
- Restore ohne Dialog bei Schema < 2.
- Leftover wieder über `pinPrintCosine` 0,80 (Genuine 0,75 tot).
- `lookOf` 80–83 % wieder auf 60 kappen.
- Hold-Still wieder hart IoU 0,82 ohne Schärfe.
- `liveCentroid` All-Mean rechnen, bevor der Slot trifft.
- `matchLive` Roh-Print statt lookOf.
- Geo-Veto skip erst ab 88 (80–87 % mit Jacke tot).
- Leftover-Floor 0,72 (Genuine 0,62–0,71 tot).
- Unscharfen Print in den Median-Trail.
- Leftover-Ranking nur Cosine (unscharf 0,73 schlägt scharf 0,72).
- `lookOf` mit `printMeasured: true` ohne Vektor-Paar (Geo tauft).
- leftover ohne Pose-Slot (¾ auf Frontal-Ghost).
- leftover sameSlot Fallback auf andere Slots.
- IoU-Hold gegen anderen Print-Pin zwei Frames stehen lassen.
- namenloser Print-Pin stiehlt IoU-Hold.
- Look≠Print taufen.
- Print-Trail Frontal+¾ mischen.
- Identität nur über Löschen+neu umbenennen.
- Rename ohne Duplikat-Confirm.
- gallery.json ohne fsync.
- Overlay nur „Print 82%“ ohne Look.
- Ein Look=Print-Tick tauft.
- Look≠Print als Namensstimme.
- Rename-Confirm ohne Timeout.
- `.bak` ohne fsync.
- 1-Euro Cutoff unabhängig von Box-Fläche.
- Overlay ohne Slot-Buchstaben.
- Leftover-Kiste dieselbe Farbe wie enrolled.
- Taufe still, ohne `n/need` im Overlay.
- Continuity still Fallback ohne Picker.
- Close-Pair ohne Badge.
