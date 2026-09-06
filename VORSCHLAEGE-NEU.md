# Aegis Nachtrag 2.1.162 — 2026-09-06

Binary **2.1.162 alpha Build 187**. Detect-Skip Vision, RemintDrop, Yield-Grace, Open-Set.

## In 2.1.162 gelandet

1. leftoverDetectSkipVision + FaceObservation.coast — VNDetect 7/8 tot, UUID hält
2. leftoverDetectSkipLiveIous — keine Remint-Zombies im Skip
3. leftoverHoldRemintDrop auf leftoverLastIoU
4. Yield-Grace 4 s, Auto-Return, Heartbeat bleibt
5. leftoverOpenSetUnsure / OverlayUnsureFirst — „?“ statt Gast
6. cameraMutexPickText(cachesEmpty:)
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.162 (Build 187)

`bugfix` 2.1.15 gelesen, nicht gemergt.

## Nächste, zusätzlich

- LibraryStore → ein FaceTrack-Dict, Drop alle 25 Maps
- Open-Set Gallery-Floor leftoverPrintGenuine
- CameraBroker-XPC mit Helios
- Detect 8–12 fps, Overlay Metal, Baptize nur Detect-Tick
- Enrollment-HUD 3 Yaw + Blink
- gallery.json WAL
- Yield Pref Grace 2–8 s
- flock LOCK_NB
- Telemetry skip-ratio

# Nachtrag 2026-09-06 (2.1.161)

Siehe ANALYSE.md. **2.1.161** Munkres n>8, Yield-Reconfigure Built-in, FaceTrack, Caches-Lock.

## In 2.1.161 gelandet

1. leftoverAssignHungarianXKuhn / Munkres + 3-opt / 4-opt — 4-Zyklus tot
2. cameraMutexYieldReconfigure + LiveCapture Session auf Built-in, YieldsNow löst
3. FaceTrack + leftoverFaceTrackPack / Remint
4. Caches + flock + Dual-Read/Write (Helios 1.5.158)
5. VERSION = Models = MARKETING_VERSION 2.1.161 (Build 186)

## Nächste, zusätzlich

- LibraryStore auf **ein FaceTrack-Dict** umziehen (Pack sitzt, 25 Maps bleiben).
- **Yield-Grace 4 s:** Helios weg → Pref Auto-Return Continuity.
- Detect-Skip auch **VNDetect** (nicht nur skipPrints) wenn IoU+Yaw sitzen.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface statt Datei-Lock.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles. TTL 12 Frames nach Detect-Miss.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- gallery.json WAL + bak rotate 3, printRevision je Identity.
- Enrollment-HUD: 3 Yaw-Slots + Blink bevor Taufe.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Prefs je camera uniqueID.
- Speaker-Diarization als Aegis-Cue.
- Lock-Zeile Palm∩Face Mute (Helios-Box).

# Nachtrag 2026-09-06 (2.1.160)

Siehe ANALYSE.md. **2.1.160** Mutex Claim-Gate, HungarianX n>8 Greedy+2-opt, Detect-Skip.

## In 2.1.160 gelandet

1. leftoverAssignHungarianXGreedy + X2opt — n>8 Cost (IoU+Print), nicht FillX
2. cameraMutexLine %.3f, Pid, pidLive, ClaimWrites, YieldsNow. Heartbeat weicht live, stoppt Timer
3. leftoverDetectSkip / SkipAll / SkipTick — IoU ≥ 0,92 skipPrints, Tick % 8 voll
4. VERSION = Models = MARKETING_VERSION 2.1.160 (Build 185)

## Nächste, zusätzlich

- leftoverAssign n>8 **Jonker-Volgenant O(n³)** statt Greedy+2-opt (2-opt hängt 4-Zyklus).
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. Remint-Plan sitzt, 25 Maps bleiben.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface statt Datei-Lock. Helios 1.5.152.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles. TTL 12 Frames nach Detect-Miss.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- gallery.json.bak Rotate 3, printRevision je Identity. gallery.json zstd. WAL.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen + Liveness-Blink.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe / Haar-Histogramm als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior als schwacher Track-Cue.
- Identity-Graph über Tage.
- leftoverHoldKalmanJump Pref je Camera-UUID.
- **Print-EMA nur sharpness > 0,55.**
- **Kalman-Box yaw-normalisiert.**
- **ByteTrack-Score** α·IoU + β·print + γ·hashHamming.
- **Speaker-Diarization** (wenn Mic an) als Identity-Cue.
- **fcntl flock** statt Datei-Stamp. Lock in ~/Library/Caches.
- **OSLog Signposts** Detect-ms, Remint, Mutex-Yield.
- **Pairwise-Heatmap klickbar** (`bugfix` 2.1.15).
- **Identity-Merge Wizard** (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** (`bugfix`).
- **Platt-Skalierung** Leave-one-out (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll (`bugfix`).
- **BaptizeFloor Pref Slider** 0,72–0,84 je Camera-UUID.
- Gallery compact on sleep. JPEG-Bank cap 12/Identity.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.159: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.159)

Siehe ANALYSE.md. **2.1.159** HungarianX Print-Cost, Spark Hash persist.

## In 2.1.159 gelandet

1. leftoverAssignHungarianXCost IoU + PrintW 0,8. leftoverAssignHungarianXHasPrint hält Twin gegen Spread-Veto.
2. leftoverAssignLive reicht Scores in den Remint-Pass.
3. leftoverSparkChipPack/Unpack — Hash→Chip im selben Dict, Overlay-Lookup Hash-Fallback.
4. VERSION = Models = MARKETING_VERSION 2.1.159 (Build 184)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. Remint-Plan sitzt, 25 Maps bleiben.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface statt Datei-Lock. Helios 1.5.150.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles. TTL 12 Frames nach Detect-Miss.
- **Detect skip wenn Kalman-Box-IoU > 0,92.**
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- gallery.json.bak Rotate 3, printRevision je Identity. gallery.json zstd.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen + Liveness-Blink.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior als schwacher Track-Cue.
- Identity-Graph über Tage.
- leftoverHoldKalmanJump Pref je Camera-UUID.
- **Print-EMA nur sharpness > 0,55.**
- **Kalman-Box yaw-normalisiert.**
- **ByteTrack-Score** α·IoU + β·print + γ·hashHamming.
- **leftoverLiveNameAnd „?“ ohne Taufe.** Majority < Need zeigt Unsure, schreibt kein Guest in Hist.
- **Pairwise-Heatmap klickbar** (`bugfix` 2.1.15).
- **Identity-Merge Wizard** (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** (`bugfix`).
- **Platt-Skalierung** Leave-one-out (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll (`bugfix`).
- **BaptizeFloor Pref Slider** 0,72–0,84 je Camera-UUID.
- **fcntl flock statt Datei-Stamp** für den Kamera-Mutex.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.158: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.158)

Siehe ANALYSE.md. **2.1.158** Remint-Plan, Spark Hash, Quality-Produkt, Continuity-Taufe, Unsure, Mutex.

## In 2.1.158 gelandet

1. leftoverHoldRemintMap einmal + leftoverHoldRemintApply / ApplyId / ApplyBins. Identity-Skip im Remap.
2. leftoverSparkChipHashPut/Get + TickKeeps hashTable
3. leftoverBaptizeQualityProduct Blur × Pose. Continuity Quality-Floor 0,06.
4. leftoverBaptizeFloor(continuity) 0,76 — TransfersId / HoldsTrack / WipeHist verdrahtet
5. leftoverUnsureChip `?` in ContentView overlayName
6. cameraMutex — Yield vor Auto-Return, Lock nicht überschreiben, Heartbeat 2 s, Stale 12 s
7. VERSION = Models = MARKETING_VERSION 2.1.158 (Build 183)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. Remint-Plan sitzt, 25 Maps bleiben.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface statt Datei-Lock. Helios 1.5.149.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles. TTL 12 Frames nach Detect-Miss.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- gallery.json.bak Rotate 3, printRevision je Identity. gallery.json zstd.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen + Liveness-Blink.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior als schwacher Track-Cue.
- Identity-Graph über Tage.
- leftoverHoldKalmanJump Pref je Camera-UUID.
- **Print-EMA nur sharpness > 0,55.**
- **Kalman-Box yaw-normalisiert.**
- **ByteTrack-Score** α·IoU + β·print + γ·hashHamming.
- **Pairwise-Heatmap klickbar** (`bugfix` 2.1.15).
- **Identity-Merge Wizard** (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** (`bugfix`).
- **Platt-Skalierung** Leave-one-out (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll (`bugfix`).
- **BaptizeFloor Pref Slider** 0,72–0,84 je Camera-UUID.
- **fcntl flock statt Datei-Stamp** für den Kamera-Mutex.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.157: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.157)

Siehe ANALYSE.md. **2.1.157** MissCoast return, Spark Hash-Rebind.

## In 2.1.157 gelandet

1. leftoverHoldMissCoast — `return` (Swift 6)
2. leftoverSparkChipTickKeeps lastHash + leftoverSparkChipTickDest — Remint-Miss kein Gast-Flash
3. VERSION = Models = MARKETING_VERSION 2.1.157 (Build 182)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverSparkChipHash persist (hash→chip) neben UUID. TickDest sitzt RAM-only.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. leftoverHoldRemint 20× dieselben Args.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.147.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles. TTL 12 Frames nach Detect-Miss.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity. gallery.json zstd.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen + Liveness-Blink.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior als schwacher Track-Cue.
- Identity-Graph über Tage.
- leftoverHoldKalmanJump Pref je Camera-UUID.
- **Print-EMA nur sharpness > 0,55.**
- **Unsure-Chip** statt Gast. Majority < Need zeigt „?“.
- **Kalman-Box yaw-normalisiert.**
- **Per-Camera Baptize-Floor.** Continuity 8 fps 0,76, Webcam 0,80.
- **ByteTrack-Score** α·IoU + β·print + γ·hashHamming.
- **Pairwise-Heatmap klickbar** (`bugfix` 2.1.15).
- **Identity-Merge Wizard** (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** (`bugfix`).
- **Platt-Skalierung** Leave-one-out (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll (`bugfix`).

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.156: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.156)

Siehe ANALYSE.md. **2.1.156** Steal 2-opt, Held emptyKeeps, CostIoU.

## In 2.1.156 gelandet

1. leftoverNameLockHeldSurvive emptyKeeps — Decode hält, Live wischt
2. leftoverAssignPrintSteal2opt — 3-Zyklus bis Ruhe
3. leftoverAssignCostIoU — |Δx|/Pad, PrintW 0,3 dokumentiert
4. VERSION = Models = MARKETING_VERSION 2.1.156 (Build 181)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverAssignHungarianX Cost = leftoverAssignCost mit **Box-IoU**, nicht |Δx|. PrintW 0,3 verliert gegen dx>Pad.
- leftoverAssignCost printW 0,8 sobald echte CGRect-IoU sitzt — Steal dann überflüssig.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. leftoverHoldRemint 20× dieselben Args.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.146.
- **Kamera-Mutex** mit Helios: Continuity 8 fps wenn beide Sessions. `helios.aegis.camera.lock`.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.
- leftoverMajorityNeed 2 bei Webcam 24 fps, 3 bei Continuity 8 fps.
- **Pairwise-Heatmap klickbar.** Labor-Zelle öffnet die beiden Fotos (`bugfix` 2.1.15).
- **Identity-Merge Wizard** Centroid 0,89–0,94 — nicht still mergen (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** 3 Fotos derselben Datei (`bugfix`).
- **Platt-Skalierung** Leave-one-out statt globaler Sigmoid (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll, Apple-Print default (`bugfix`).
- **Ghost-TTL Pref** 1–8 Ticks, nicht hart MajorityNeed 3.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.155: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.155)

Siehe ANALYSE.md. **2.1.155** Print stiehlt Remint, Ghost-HOLD PairCommit, Held Survive.

## In 2.1.155 gelandet

1. leftoverAssignCost — 1−IoU + 0,3·(1−printCos)
2. leftoverAssignPrintSteals / PrintStealApply — Gap 0,15, Floor leftoverPrintCosine, Twin-nil bleibt
3. leftoverGhostHoldsCommit + DropHold commitMiss — Overlay HOLD ohne Ghost
4. leftoverNameLockHeldSurvive — Schema-7 Until leer hält Namen
5. VERSION = Models = MARKETING_VERSION 2.1.155 (Build 180)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverAssignHungarianX Cost = leftoverAssignCost, nicht nur |Δx|.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. leftoverHoldRemint 20× dieselben Args.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.145.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.
- **Pairwise-Heatmap klickbar.** Labor-Zelle öffnet die beiden Fotos (`bugfix` 2.1.15).
- **Identity-Merge Wizard** Centroid 0,89–0,94 — nicht still mergen (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** 3 Fotos derselben Datei (`bugfix`).
- **Platt-Skalierung** Leave-one-out statt globaler Sigmoid (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll, Apple-Print default (`bugfix`).
- **leftoverAssign n-cycle 2-opt** auch n=2 wenn Print-Steal und Remint widersprechen — Steal sitzt, 2-opt fehlt.
- **Ghost-TTL Pref** 1–8 Ticks, nicht hart MajorityNeed 3.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.154: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.154)

Siehe ANALYSE.md. **2.1.154** DropHold Ghosts+Miss, CI macos-15 zuerst.

## In 2.1.154 gelandet

1. leftoverUUIDUUIDMapDropHold — hold ∪ ghosts ∪ missKeys, Twin-Session hält PairCommit
2. DropDangling destOk Key|Dest — hold.contains(k) redundant
3. CI matrix macos-15+26, fail-fast false, Publish macos-15 Artifact zuerst
4. VERSION = Models = MARKETING_VERSION 2.1.154 (Build 179)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- **Hungarian cost 1−IoU + 0,3·(1−printCos).** IoU allein tauft Geschwister bei Crowd.
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup — Restore arm sitzt, Backup-Decode Schema 7 ohne Held.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- **Ein FaceTrack-Struct** statt leftover-Map-Stapel. leftoverHoldRemint 20× dieselben Args.
- **Ghost-TTL vs PairCommit-TTL.** Overlay HOLD stirbt früher als Ghost — Majority tauft nach Coast.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.144.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.
- **Pairwise-Heatmap klickbar.** Labor-Zelle öffnet die beiden Fotos (`bugfix` 2.1.15).
- **Identity-Merge Wizard** Centroid 0,89–0,94 — nicht still mergen (`bugfix`).
- **Overlay-Name Mehrheit auch Standbilder** 3 Fotos derselben Datei (`bugfix`).
- **Platt-Skalierung** Leave-one-out statt globaler Sigmoid (`bugfix`).
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll, Apple-Print default (`bugfix`).

`bugfix` 2.1.15 gelesen, nicht gemergt. Spark persist + Capture-Hist remaining sitzen in 2.1.153.

Die historische Liste bis 2.1.153: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.153)

Siehe ANALYSE.md. **2.1.153** Spark persist + Tick lastHash, Capture-Hist remaining (Key fehlt hält), DropDangling keep leer.

## In 2.1.153 gelandet

1. leftoverSparkChip persist — Overlay-Chip überlebt Restart, Hold = 2
2. leftoverSparkChipTickKeeps — lastHash hält Chip vor Remint
3. leftoverCaptureHist remaining — Indoor-Blur nach TTL tot, Key ohne remaining hält
4. leftoverUUIDUUIDMapDropDangling keep leer — nur Hold-Keys
5. VERSION = Models = MARKETING_VERSION 2.1.153 (Build 178)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup — Restore arm sitzt, Backup-Decode Schema 7 ohne Held.
- leftoverSparkChip per Hash, nicht nur UUID — Remint-Miss sonst Gast-Flash wenn lastHash tot.
- Capture-Hist MAD-Gate vor Baptize, nicht nur Count ≥ 3 / remaining 0.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Ein FaceTrack-Struct statt leftover-Map-Stapel.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.143.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.
- leftoverJpegDelta UUID-Probe analog leftoverJpegByHash remaining — Restart Indoor-Poster sonst 1 Tick.
- leftoverMissFrames persist analog leftoverPairCommitMiss — Vision-Restart sonst Miss 0, Taufe Tick 1.
- leftoverEmptySince remaining analog leftoverLatch — Restart leerer Frame tauft Ghost.
- leftoverDisagree persist — Twin-Streak 0 nach Restart, Cluster-Split tot.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.152: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.152)

Siehe ANALYSE.md. **2.1.152** DropDangling Hold-Key hält dest.

## In 2.1.152 gelandet

1. leftoverUUIDUUIDMapDropDangling hold — Overlay-Ghost hält Twin-dest
2. VERSION = Models = MARKETING_VERSION 2.1.152 (Build 177)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverSparkChipHeld persist (IoU sitzt, Chip-Tuple RAM).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup — Restore arm sitzt, Backup-Decode Schema 7 ohne Held.
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash.
- leftoverCaptureHist remaining wall-clock analog HashHold Schema 14.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Ein FaceTrack-Struct statt leftover-Map-Stapel.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.141.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.151: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.151)

Siehe ANALYSE.md. **2.1.151** Rank-Rebase nur Twin `#101`, LastHash Yaw hält, DropDangling Key hält, Jump Cam Hold/Taufe, PairCommitMiss persist.

## In 2.1.151 gelandet

1. leftoverHashIsTwinRank / leftoverHashRankRebase — Yaw `#0` hält, `#101` → Spatial. leftoverLastHashRankRebase analog.
2. leftoverUUIDUUIDMapDropDangling Key|Dest — Twin-weg PairCommit hält
3. leftoverPairCommitMiss + leftoverLastIoU persist gallery.json
4. leftoverHoldKalmanJumpCam Continuity 0,34 / Webcam pref. leftoverIoUJumpBlocks / Chip / HoldsTrack / NameLock.
5. VERSION = Models = MARKETING_VERSION 2.1.151 (Build 176)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverSparkChipHeld persist (IoU sitzt, Chip-Tuple RAM).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup — Restore arm sitzt, Backup-Decode Schema 7 ohne Held.
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash.
- leftoverCaptureHist remaining wall-clock analog HashHold Schema 14.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.140.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.
- leftoverHoldKalmanJump Pref je Camera-UUID, nicht nur dt.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.150: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.150)

Siehe ANALYSE.md. **2.1.150** PairCommit Hold nach Remint-Miss, Remint Dest Twin, Bins Rank-Rebase, Jump Slider.

## In 2.1.150 gelandet

1. leftoverHoldRemintId Dest — Twin-proposed hält, nicht self
2. leftoverPairCommitHold / leftoverPairCommitMiss — 3 Ticks Overlay, HOLD-Label
3. leftoverHoldBinsDecode leftoverHashRankRebase — `#101` tot nach Restore
4. leftoverHoldKalmanJumpPref Slider 0,30–0,50 HUD
5. VERSION = Models = MARKETING_VERSION 2.1.150 (Build 175)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairCommitMiss persist analog leftoverPairStreak — RAM-only, Restart wischt Overlay.
- leftoverHashRankRebase nur `#101`, nicht Yaw-Bin `#0` — Spatial-Strip killt leftoverHoldHashKey.
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash.
- leftoverHoldRemint dest Live-UUID die kein Hold-Key ist — DropDangling droppt PairCommit, Hold sieht nil.
- leftoverKalmanJump per Camera (Continuity 0,30 / Webcam 0,50) statt ein Pref.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.139.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z.

`bugfix` 2.1.15 gelesen, nicht gemergt.

Die historische Liste bis 2.1.149: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.149)

Siehe ANALYSE.md. **2.1.149** Pair dest==key persist, Occupied Twin-weg Rank, KeepBoxes PredictOnly Kalman.

## In 2.1.149 gelandet

1. leftoverUUIDUUIDMapDecode dest==key — PairCommit nach Remint persist
2. leftoverOccupiedTwinGone — stored `#101` tot wenn Twin weg
3. leftoverKeepBoxes predictOnly + Kalman ∩ Hold
4. VERSION = Models = MARKETING_VERSION 2.1.149 (Build 174)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverPairLast Value-Remint: Decode dest==key sitzt, DropDangling dest tot wenn Value alte Live-UUID ohne Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- leftoverCaptureHist remaining wall-clock analog HashHold Schema 14 — Hist ist 8 Doubles ohne at.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.138.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z. Twin-Tie ohne Yaw.
- leftoverJpegByHash remaining wall-clock — Schema 13 ist Restore-stale, In-Session TTL sitzt RAM.
- leftoverHoldKalman Jump-Slider UI 0,30–0,50 — Pref sitzt, HUD fehlt.
- leftoverPairCommit Majority 3-Tick Overlay nach Remint-Miss, nicht nur Decode.
- Softmax über Galerie statt Argmax-Taufe — Open-Set Energy-Score.
- Quality-Produkt Blur × Pose × Occlusion als Baptize-Gate, nicht OR.
- Identity-Graph: dieselbe Person über Tage, Trail-Cosine nicht nur Hold.
- Time-of-day Prior (wer ist um 8 Uhr hier) als schwacher Track-Cue.
- Kleidungsfarbe als Weak-Track zwischen Face-Dropouts.
- Multi-Cam Homographie: leftoverHold Welt-x, nicht Frame-x.
- Ein FaceTrack-Struct statt leftover-Map-Stapel.
- Aktive Enrollment-HUD: 3 Posen prompten statt Burst-Ingest.

Die historische Liste bis 2.1.148: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.148)

Siehe ANALYSE.md. **2.1.148** PairCommit Keeps nach Remint, Kalman PredictOnly Ghost, KeepBoxes Ghost-Kalman, Jump Pref 0,30–0,50.

## In 2.1.148 gelandet

1. leftoverPairCommitKeeps — Majority hält committed==proposed
2. leftoverHoldKalmanPredictOnly — Restore / Miss / Ghost-only Predict
3. leftoverKeepBoxes Kalman ∩ Ghosts ohne missCoast
4. leftoverHoldKalmanJumpPref 0,30–0,50
5. VERSION = Models = MARKETING_VERSION 2.1.148 (Build 173)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- leftoverCaptureHist remaining wall-clock analog HashHold Schema 14 — Hist ist 8 Doubles ohne at.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.137.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- Continuity LiDAR depth als Box-Z. Twin-Tie ohne Yaw.
- leftoverJpegByHash remaining wall-clock — Schema 13 ist Restore-stale, In-Session TTL sitzt RAM.
- leftoverOccupied stored Rank nach Yaw-Merge live Exact nicht `#101` überschreiben wenn Twin weg.
- leftoverHoldKalman Jump-Slider UI 0,30–0,50 — Pref sitzt, HUD fehlt.
- leftoverPairCommit Majority 3-Tick Overlay nach Remint-Miss, nicht nur Keeps.
- leftoverKeepBoxes Kalman ∩ Hold ohne Ghost wenn Survive Hold allein.

Die historische Liste bis 2.1.147: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.147)

Siehe ANALYSE.md. **2.1.147** Backup remaining, HashTrail remaining Schema 15, KeepBoxes nach Survive, Hungarian wide FillX.

## In 2.1.147 gelandet

1. restoreFromBackup loadBackupPayload remaining
2. leftoverHashTrailRemainingEncode / Decode remaining — Schema 15
3. leftoverKeepBoxes nach Survive, leftoverKeepHoldIds
4. leftoverAssignHungarianWide Pad > 0,20 → FillX
5. VERSION = Models = MARKETING_VERSION 2.1.147 (Build 172)

## Nächste, zusätzlich

- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8 + wide FillX.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.136.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.
- Continuity LiDAR depth als Box-Z. Twin-Tie ohne Yaw.
- leftoverHoldKalman IoU-Reset Pref 0,30–0,50, nicht hart 0,40.
- leftoverJpegByHash remaining wall-clock — Schema 13 ist Restore-stale, In-Session TTL sitzt RAM.
- leftoverHashHold remaining wall-clock analog JPEG in-session, nicht nur Restore.
- leftoverOccupied stored Rank nach Yaw-Merge live Exact nicht `#101` überschreiben wenn Twin weg.
- leftoverKeepBoxes Kalman nach Survive-Miss ohne missCoast — Ghost-only Hold.

Die historische Liste bis 2.1.146: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.146)

Siehe ANALYSE.md. **2.1.146** skipKalmanReset Compile, KeepBoxes Miss-Kalman, HashHold remaining Schema 14, Hungarian n=8, Occupied stored Rank.

## In 2.1.146 gelandet

1. skipKalmanReset einmal, Advance nach IoU-Loop
2. leftoverKeepBoxes missCoast + kalman
3. leftoverHashHoldRemainingEncode / Decode remaining — Schema 14
4. leftoverHashHoldRebase keepAt
5. leftoverOccupiedMergeYaw stored Rank `#101`
6. leftoverAssignHungarianX n≤8
7. VERSION = Models = MARKETING_VERSION 2.1.146 (Build 171)

## Nächste, zusätzlich

- leftoverHoldTrail remaining analog HashHold — Trail-Decode at=now sitzt.
- leftoverAssign n>8 Jonker-Volgenant, nicht nur HungarianX 8.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.135.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- VNDetectFaceCaptureQuality als Baptize-Gate — Sharpness AND Quality, nicht OR.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.
- Continuity LiDAR depth als Box-Z. Twin-Tie ohne Yaw.
- leftoverHoldKalman IoU-Reset Pref 0,30–0,50, nicht hart 0,40.
- leftoverJpegByHash remaining wall-clock — Schema 13 ist Restore-stale, In-Session TTL sitzt RAM.
- leftoverKeepBoxes nach Survive — Filter sitzt vor Survive, Hold-IDs nach Remint.
- Hungarian n=8 Recursion Cap wenn Pad weit — Crowd 8+ Pad 0,40 explodiert.
- leftoverHashHold remaining wall-clock analog JPEG in-session, nicht nur Restore.

Die historische Liste bis 2.1.145: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.145)

Siehe ANALYSE.md. **2.1.145** Miss-Need 2 Auto, JPEG Schema-11 stale, Kalman Restore 2 Ticks, Occupied Yaw+Rank, Vel-Decay, Hungarian n=6.

## In 2.1.145 gelandet

1. leftoverHoldMissNeedPref 1–3 Default 2 + Auto dt + Slider
2. leftoverJpegRestoreAt — Schema 11 remaining 0
3. leftoverHoldKalmanSkipReset 2 Ticks nach Restore
4. leftoverOccupiedRankBlocks — Ranked nicht Exact
5. leftoverOccupiedMergeYaw — yawAbs Exact vs `#101`
6. leftoverHoldKalmanVelDecay Miss-Coast
7. leftoverAssignHungarianX n≤6
8. VERSION = Models = MARKETING_VERSION 2.1.145 (Build 170)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>6 Jonker-Volgenant, nicht nur HungarianX 6.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named. MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC / IOSurface mit Helios 1.5.134.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.
- Continuity LiDAR depth als Box-Z. Twin-Tie ohne Yaw.
- leftoverHoldKalman IoU-Reset Pref 0,30–0,50, nicht hart 0,40.
- Face Capture Quality + Sharpness AND als Baptize-Gate, nicht OR.
- leftoverJpegByHash remaining wall-clock — Schema 13 ist Restore-stale, In-Session TTL sitzt RAM.
- leftoverKeepBoxes missCoast: Kalman-Filter nach Keep darf Hold-IDs nicht droppen wenn hold nach Remint leer — Remint `out = hold` sitzt.

Die historische Liste bis 2.1.144: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.144)

Siehe ANALYSE.md. **2.1.144** Miss-Coast Kalman/Streak/Faces, JPEG remaining Schema 13.

## In 2.1.144 gelandet

1. leftoverHoldKalmanKeep missCoast — empty live hält
2. leftoverHoldMissHit live ∪ adopted, MissAdvance vor Keep
3. leftoverEmptyWipesMaps / leftoverEmptyWipesOverlay — found.isEmpty 1 Tick tot
4. leftoverJpegRemaining / leftoverJpegAtFromRemaining persist Schema 13
5. VERSION = Models = MARKETING_VERSION 2.1.144 (Build 169)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>5 Jonker-Volgenant, nicht nur HungarianX 5.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.133.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverOccupiedMerge Twin-Yaw: Spatial unique sitzt — leftoverHashTwinLeft yaw-Tie sitzt. Merge emittiert Spatial, Yaw ändert das Set nicht.
- leftoverHoldKalman IoU-Reset nach Restore ohne Live-Box — 1. Tick meas weit, Reset statt Kriechen. Keep missCoast sitzt.
- leftoverAssignHungarianX n=6 Cap nur wenn Pad eng, sonst FillX für Crowd 6+.
- leftoverMissCoastNeed Pref 1–3 analog Helios palmCoastNeed. Hart 1.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.
- leftoverKeepBoxes missCoast: Kalman-Filter nach Keep darf Hold-IDs nicht droppen wenn hold nach Remint leer — Remint `out = hold` sitzt.

Die historische Liste bis 2.1.143: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.143)

Siehe ANALYSE.md. **2.1.143** Miss-Coast 1 Frame, Occupied Spatial-emit, JPEG Cap, Kalman Schema 12, HungarianX n=5.

## In 2.1.143 gelandet

1. leftoverHoldMissCoast / leftoverHoldMissAdvance — Survive + LastHash + Tick 1 Frame
2. leftoverPredictOnMissCoast — Kalman-Predict analog emptyLatch
3. leftoverOccupiedMerge Spatial-emit — live Rank kein Occupied-Key
4. leftoverJpegByHashCapped Encode Cap 64
5. leftoverHoldKalmanEncode/Decode persist Schema 12
6. leftoverAssignHungarianX n≤5 leftoverAssignHungarianN
7. VERSION = Models = MARKETING_VERSION 2.1.143 (Build 168)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>5 Jonker-Volgenant, nicht nur HungarianX 5.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.132.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverJpegByHash remaining TTL, nicht at=now nach Restore — Probe sonst 1,2 s zu frisch.
- leftoverOccupiedMerge Twin-Yaw in Merge: zwei Live gleiches Spatial, kleinerer yawAbs Exact.
- leftoverHold miss-coast Predict Box mit Kalman-v, nicht nur Survive-Keep. PredictOnMissCoast sitzt, v nach Restore Schema 12.
- leftoverHoldKalman IoU-Reset nach Restore ohne Live-Box — 1. Tick meas weit, Reset statt Kriechen.
- leftoverAssignHungarianX n=6 Cap nur wenn Pad eng, sonst FillX für Crowd 6+.
- leftoverHold TTL remaining analog leftoverSeenRemainingEncode.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.

Die historische Liste bis 2.1.142: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.142)

Siehe ANALYSE.md. **2.1.142** Remint vor Survive, Occupied Spatial, JPEG persist Schema 11, Spread-Veto Twin-Mitte.

## In 2.1.142 gelandet

1. leftoverHoldRemintBeforeSurvive — Remint vor Survive, leftoverHoldRemintRows
2. leftoverOccupiedMerge Spatial unique, leftoverLastHashRankRebase
3. leftoverJpegByHashEncode/Decode persist Schema 11
4. leftoverAssignSpreadVeto Twin-Mitte + Unassigned
5. VERSION = Models = MARKETING_VERSION 2.1.142 (Build 167)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>4 Jonker-Volgenant, nicht nur HungarianX 4.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.131.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverHoldKalman persist (Remint sitzt, Restart tot).
- leftoverHold miss-coast 1 Frame: Detect-Drop darf leftoverHoldSurvive nicht leeren — Latch 4 s sitzt, 1-Face-Miss ohne Ghost tot.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.
- leftoverHoldKalman Schema 12 x/y/w/h/p — Restart sonst Box-Sprung bis 3 Frames.
- leftoverAssignHungarianX n=5 Cap, Crowd 5. Person FillX greedy.
- leftoverJpegByHash Cap persist analog leftoverHashHoldCapN 64 — Encode sitzt ungekürzt.
- leftoverOccupiedMerge Twin-Yaw in Merge, nicht nur leftoverHashTwinOccupied danach.
- leftoverHoldRemint Hash-Rescue Twin faces==2 Exact-only sitzt; Hamming-1 Solo. Crowd 3+ Hamming tot.
- leftoverLastHash persist Spatial-only nach RankRebase — Tick schreibt noch `#101` vor Encode.

Die historische Liste bis 2.1.141: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.141)

Siehe ANALYSE.md. **2.1.141** leftoverHoldXMatch Call-Order — CI Compile seit 2.1.139 rot.

## In 2.1.141 gelandet

1. leftoverHoldXMatch pad vor occupied, 4 Call-Sites Remint/RemintBins
2. leftoverAssignHungarianX let used
3. VERSION = Models = MARKETING_VERSION 2.1.141 (Build 166)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>4 Jonker-Volgenant, nicht nur HungarianX 4.
- leftoverOccupiedMerge Hash-Key nach persist UUID-Restore.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverHoldSurvive vs leftoverHold persist Race nach App-Restart (Hold noch Epoch).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.130.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverAssignHungarianX spread-Veto nach min-cost sitzt; Twin-Mitte 1-Live bleibt tot, 2-Live Unique hält.
- leftoverJpegByHash persist in gallery.json analog leftoverLastHash.
- leftoverHoldKalman persist (Remint sitzt, Restart tot).
- leftoverHold miss-coast 1 Frame: Detect-Drop darf leftoverHoldSurvive nicht leeren.
- leftoverJpegByHash persist analog leftoverLastHash — RAM-Cache tot nach Restart.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.

Die historische Liste bis 2.1.140: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.140)

Siehe ANALYSE.md. **2.1.140** Schema 10 StreakBox persist, Kalman Remint/Reset, JPEG per Hash, HungarianX n=4, AssignLiveGate gallery.json.

## In 2.1.140 gelandet

1. leftoverStreakBoxEncode/Decode persist Schema 10
2. leftoverHoldKalman Remint + Reset IoU 0,40 + Keep live
3. leftoverJpegProbeByHash Spatial, Twin teilt nicht
4. leftoverAssignHungarianX n≤4
5. leftoverAssignLiveGate persist gallery.json
6. VERSION = Models = MARKETING_VERSION 2.1.140 (Build 165)

## Nächste, zusätzlich

- leftoverHold TTL remaining analog NameLockUntil / Seen — leftoverHold ist Cosine, HashHold `at` startet nach Restore neu.
- leftoverAssign n>4 Jonker-Volgenant, nicht nur HungarianX 4.
- leftoverOccupiedMerge Hash-Key nach persist UUID-Restore.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverHoldSurvive vs leftoverHold persist Race nach App-Restart (Hold noch Epoch).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash (Bins sind UUID.bin).
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash — Encode sitzt, Keep nur LastHash.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.130.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverAssignHungarianX spread-Veto nach min-cost sitzt; Twin-Mitte 1-Live bleibt tot, 2-Live Unique hält.
- leftoverJpegByHash persist in gallery.json analog leftoverLastHash.
- leftoverHoldKalman persist (Remint sitzt, Restart tot).
- leftoverHold miss-coast 1 Frame: Detect-Drop darf leftoverHoldSurvive nicht leeren.
- leftoverJpegByHash persist analog leftoverLastHash — RAM-Cache tot nach Restart.
- VNDetectFaceCaptureQuality als Baptize-Gate.
- leftoverPairCommit Majority 3-Tick persist nach Value-Remint prüfen.

Die historische Liste bis 2.1.139: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.139)

Siehe ANALYSE.md. **2.1.139** Rank Spatial Dist, Rebase Spatial-first, HungarianX n=3, Hamming Solo, RemintPad, Trail EMA, JPEG TTL Pref.

## In 2.1.139 gelandet

1. leftoverHoldHashSpatial vor Dist/Neighbors/BinsInferred — Rank Dist 0
2. leftoverHashRankRebase Spatial-first, leftoverHoldMoveRankKey live
3. leftoverHoldHashLookupKeys + leftoverHoldSpatialOccupied Twin kein Steal
4. leftoverAssignHungarianX n≤3, AssignRemint/AssignLive nicht FillX
5. leftoverHoldRemintPad Solo Rescue / Twin Pad, HammingRescue faces==1, RemintId pad
6. leftoverHoldTrailEMA Cap 4, leftoverJpegProbeTTLPref 0,25–1,2 UI
7. leftoverStoredHashMerge persist, leftoverMirrorPending JPEG/Streak/Wipe/IoU/Spark/Miss
8. VERSION = Models = MARKETING_VERSION 2.1.139 (Build 164)

## Nächste, zusätzlich

- leftoverStreakBox persist — Streak ohne Box remintet nach Restart nur per Hash.
- leftoverHold TTL remaining analog NameLockUntil / Seen.
- leftoverAssign n>3 Jonker-Volgenant, nicht nur HungarianX 3.
- leftoverOccupiedMerge Hash-Key nach persist UUID-Restore.
- leftoverLastIoU / leftoverSparkChipHeld persist (Mirror sitzt, gallery.json fehlt).
- leftoverHoldSurvive vs leftoverHold persist Race nach App-Restart (Hold noch Epoch).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverPairLast Value-Remint persist: dest tot nach Vision-Restart — DropDangling nach Remint.
- leftoverJpegProbe per-Hash statt per-UUID — Twin teilt sonst die Probe.
- leftoverHoldKalman Reset nach Remint (Box springt, Kalman tot).
- leftoverHoldBins Rank `#101` nach Restore rebase analog leftoverHoldByHash.
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash.
- leftoverAssignLiveGate Pref persist in gallery.json, nicht nur UserDefaults.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.129.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (EMA Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- Live-Centroid EMA Reset nach Vision-Restart.
- leftoverHoldTrailByHash EMA analog UUID-Trail.
- leftoverAssignHungarianX spread-Veto nach min-cost: Twin-Mitte 0,08 bleibt tot.

Die historische Liste bis 2.1.138: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.138)

Siehe ANALYSE.md. **2.1.138** Schema 9 PairStreak/Commit/Streak, Seen remaining, Hungarian n=3, Hash Twin Exact, FillX Pad UI, Trail Cap 4.

## In 2.1.138 gelandet

1. Schema 9 leftoverPairStreak + leftoverPairCommit + leftoverStreak persist
2. leftoverSeenRemainingEncode / leftoverSeenRestore (Schema 8 Epoch rebase)
3. leftoverAssignHungarian 3-Zyklus, leftoverAssignLive Hungarian + padFill
4. leftoverHoldHashRescue facesInFrame Twin Exact, Remint erster Pass padRescue
5. leftoverFillXPad Pref UI 0,06–0,20, Gate Crowd 3
6. leftoverHoldTrailCap 4, leftoverUUIDUUIDMapDropDangling, dest==key tot
7. restoreFromBackup Schema-9-Maps nicht wischen
8. VERSION = Models = MARKETING_VERSION 2.1.138 (Build 163)

## Nächste, zusätzlich

- leftoverStreakBox x persist — Streak ohne Box remintet nach Restart nur per Hash.
- leftoverHold TTL remaining analog NameLockUntil / Seen.
- leftoverLiveHashTick vor persist in leftoverLastHash mergen, Tick selbst nicht persist.
- leftoverHoldByHash Rank-Key rebase nach Schema-9-Restore.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverHoldTrailByHash analog Rescue nach Rank-Key.
- leftoverHoldMove leftoverCaptureHistByHash Rank-Key.
- leftoverAssign n>3 Jonker-Volgenant, nicht nur 3-Zyklus.
- leftoverOccupiedMerge Hash-Key nach persist UUID-Restore.
- leftoverLastIoU / leftoverSparkChipHeld persist.
- leftoverHoldSurvive vs leftoverHold persist Race nach App-Restart (Hold noch Epoch).
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- leftoverHoldMove leftoverJpeg* Maps.
- leftoverPairLast Value-Remint persist: dest existiert nicht mehr nach Vision-Restart — DropDangling sitzt nach Remint, Restore-Reihenfolge PairLast vor Remint.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.128.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail (Cap 4 ist Pflaster).
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- RTSP 420f, Reconnect Exponential-Backoff.
- leftoverCaptureHistByHash persist analog leftoverHoldTrailHash.
- leftoverAssignLiveGate Pref persist in gallery.json, nicht nur UserDefaults.
- Hamming-Gewicht im Hash selbst, nicht nur Spatial-Strip `#`.
- leftoverHoldBins Rank `#101` nach Schema-9-Restore rebase.
- Live-Centroid EMA Reset nach Vision-Restart (Kalman tot, Box springt).

Die historische Liste bis 2.1.137: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.137)

Siehe ANALYSE.md. **2.1.137** Schema 8 PairLast/NameLock remaining/HoldTrail, AssignAtomic, FillX Pref, leftoverHoldMoveBins.

## In 2.1.137 gelandet

1. Schema 8 leftoverPairLast + leftoverNameLockUntil remaining + leftoverHoldTrail persist
2. leftoverNameLockUntilEncode remaining seconds, Restore remaining-first
3. leftoverAssignAtomic = leftoverHoldMove, leftoverMirrorPending Hold/Trail/NameLock/Bins
4. leftoverHoldMoveBins UUID.bin Dest overwrite
5. leftoverFillXRescuePref 0,16–0,36 + Slider, leftoverAssignLive pad, leftoverHoldRemint padRescue
6. leftoverHoldTrail wipe mit leftoverHold
7. VERSION = Models = MARKETING_VERSION 2.1.137 (Build 162)

## Nächste, zusätzlich

- leftoverFillXPad Pref 0,06–0,20 UI. Math sitzt, Slider fehlt.
- leftoverPairCommit / leftoverPairStreak persist — Majority nach Restart tot.
- leftoverStreak / leftoverStreakSince persist analog leftoverHold.
- leftoverLiveHashTick vor persist in leftoverLastHash mergen, Tick selbst nicht persist.
- leftoverHold TTL remaining analog NameLockUntil.
- leftoverHoldMove leftoverCaptureHistByHash Rank-Key.
- leftoverAssignLive n=3 Hungarian, nicht greedy FillX.
- leftoverHoldRemint erster Pass padRescue, nicht nur dritter.
- leftoverUUIDUUIDMapDecode drop dangling dest (tote Live-UUID nach Restart).
- leftoverHoldTrail EMA 4 Samples, nicht unbeschränkt.
- leftoverHoldByHash Rank-Key rebase nach Schema-8-Restore.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverHoldTrailByHash analog Rescue nach Rank-Key.
- Hamming-1 Rescue nur Solo (faces=1), Twin bleibt Exact-only.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.127.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- leftoverOccupiedMerge Hash-Key nach persist UUID-Restore.
- leftoverLastIoU / leftoverSparkChipHeld persist.
- leftoverHoldSurvive vs leftoverHold persist Race nach App-Restart.
- leftoverAssignLiveGate Crowd 3 für drei Gesichter.
- leftoverNameLockHeld ohne Until remaining nach Schema-7-Backup.
- RTSP 420f, Reconnect Exponential-Backoff.
- leftoverHoldMove leftoverJpeg* Maps.
- leftoverPairLast Value-Remint persist: dest existiert nicht mehr nach Vision-Restart — leftoverHoldRemintId sitzt, Restore-Reihenfolge PairLast vor Remint.

Die historische Liste bis 2.1.136: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.136)

Siehe ANALYSE.md. **2.1.136** HoldMove overwrite, Twin-Yaw-Tie, Schema 7 leftoverHold/LastHash/NameLockHeld.

## In 2.1.136 gelandet

1. leftoverHoldMove überschreibt Dest
2. leftoverHashTwinLeft/Rank/Occupied/Ranked yaw-Tie
3. Schema 7 leftoverLastHash + leftoverHold + leftoverNameLockHeld persist
4. leftoverNameLockUntilRestore now+Arm
5. leftoverOccupiedMerge live-first
6. VERSION = Models = MARKETING_VERSION 2.1.136 (Build 161)

## Nächste, zusätzlich

- leftoverFillXRescue Pref 0,16–0,36. Hart 0,28.
- leftoverFillXPad Pref 0,06–0,20.
- leftoverHoldTrail UUID persist neben leftoverHoldTrailByHash.
- leftoverNameLockUntil absolut persist (jetzt nur Arm-Restore).
- leftoverPairLast persist — Restart sonst Twin-Taufe.
- leftoverAssignLive atomar (Hash + Hold + PairLast).
- leftoverLiveHashTick vor leftoverMirrorPending schreiben.
- Hamming-1 Rescue nur Solo (faces=1), Twin bleibt Exact-only.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.126.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverHoldTrailByHash analog Rescue nach Rank-Key.
- RTSP 420f, Reconnect Exponential-Backoff.

Die historische Liste bis 2.1.135: ANALYSE.md. Review: `REVIEW-2.1.134.md`.

Nur main.

# Nachtrag 2026-09-06 (2.1.135)

Siehe ANALYSE.md. **2.1.135** leftoverStoredHashMerge, leftoverHoldByHashRescue. Review 2.1.134 in `REVIEW-2.1.134.md`.

## In 2.1.135 gelandet

1. leftoverStoredHashMerge — Tick füllt Last, Last bleibt
2. leftoverHoldByHashRescue — Hash-Match zuerst, Twin tot, Nachbar nicht stehlen
3. leftoverHoldByHashSolo ruft Rescue
4. leftoverHoldRemint / RemintBins Rescue + storedHash
5. VERSION = Models = MARKETING_VERSION 2.1.135 (Build 160)

## Nächste, zusätzlich

- leftoverFillXRescue Pref 0,16–0,36. Hart 0,28.
- leftoverFillXPad Pref 0,06–0,20.
- leftoverHold UUID persist Schema 7 neben leftoverHoldByHash — App-Restart hat sonst nichts zu reminten.
- leftoverHoldTrailByHash analog Rescue.
- leftoverLiveHashTick vor leftoverMirrorPending schreiben.
- leftoverAssignLive atomar (Hash + Hold + PairLast) — REVIEW 2.1.134.
- Twin-Tie: kleinerer yawAbs, nicht beide Occupied.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Hamming-1 Rescue nur Solo (faces=1), Twin bleibt Exact-only.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.125.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverNameLockHeld persist Schema 7.
- Schema 7 leftoverLastHash persist.

Die historische Liste bis 2.1.133: Commit `ce39283`. Review: `REVIEW-2.1.134.md`.

Nur main.

# Aegis Vorschlaege


Die laufende Review-Liste fuer 2.1.134 steht in `REVIEW-2.1.134.md`.

Die historische Liste bis 2.1.133 liegt im Commit vor `0fd4fec` (Blob `00b233bb7844f1e317ba134127e5c172ad873e95`).
Wiederherstellen:

`git checkout ce3928397bef69068db8cd1b66c6bf789160c69b -- VORSCHLAEGE-NEU.md`

Dann den Kopf aus REVIEW-2.1.134.md oben drauf.

Nur main.
