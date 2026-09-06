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
