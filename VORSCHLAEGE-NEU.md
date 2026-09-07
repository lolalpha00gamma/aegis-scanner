# Aegis Nachtrag 2.1.185 — 2026-09-07

Binary **2.1.185 alpha Build 210**. IoU-Floor aus Box-Fläche. PTS-Wall FrameTap. Until-Fill nach Coast. Helios Lerp+Ghost+Pinch-Drop.

## In 2.1.185 gelandet

1. leftoverOverlayPeakIoUFloorArea / FloorBoxes — nah strenger, fps-Floor bleibt Basis. Peak und NameLock.
2. ptsWallStamp — FrameTap nutzt Sample-PTS, nicht Date() für Interval+Emit.
3. leftoverNameLockUntilFillHeld nach Coast — gallery.json Remaining nach IoU-Adopt, Restart hält Ada.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.185 (Build 210). Schema 15 bleibt.

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, outputQueue ≠ MainActor. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.184 — 2026-09-07

Binary **2.1.184 alpha Build 209**. NameLock IoU-Adopt. Peak-IoU-Floor aus fps. Helios Lerp-Adopt.

## In 2.1.184 gelandet

1. leftoverNameLockHeldIoUAdopt unique IoU vor Coast — Held + Until auf Live
2. leftoverOverlayPeakIoUFloor 8 fps 0,32 / 60 fps 0,50 — Peak und NameLock
3. leftoverNameLockAdoptChip `iou Ada`
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.184 (Build 209)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, outputQueue ≠ MainActor. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.183 — 2026-09-07

Binary **2.1.183 alpha Build 208**. Peak IoU-Adopt. Helios Ghost-Opacity-Lerp.

## In 2.1.183 gelandet

1. leftoverOverlayPeakIoUAdopt unique IoU ≥ 0,40 — Remint-Map leer zieht Ada auf Live
2. leftoverOverlayPeakStoredBoxes Streak vor Kalman
3. leftoverOverlayPeakRemain in remintKeys
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.183 (Build 208)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, leftoverNameLockHeld IoU-Adopt, outputQueue ≠ MainActor. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.182 — 2026-09-07

Binary **2.1.182 alpha Build 207**. Peak-Assign in leftoverMirrorPending. Helios Ghost-Knochen.

## In 2.1.182 gelandet

1. leftoverAssignAtomic leftoverOverlayPeakHeld/Remain in leftoverMirrorPending
2. Tests + VERSION = Models = MARKETING_VERSION 2.1.182 (Build 207)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, outputQueue ≠ MainActor. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.181 — 2026-09-07

Binary **2.1.181 alpha Build 206**. Overlay-Peak 3 Frames nach Remint. Helios Lerp-Hitch + Reanchor-RMS.

## In 2.1.181 gelandet

1. leftoverOverlayPeakGuest / PeakName / PeakAdvance — Ada hält 3 Frames über „?“
2. leftoverOverlayPeakHeld/Remain remint-drop + unique live Set
3. Display PeakName dekrementiert nicht (SwiftUI nach Advance)
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.181 (Build 206)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.180 — 2026-09-07

Binary **2.1.180 alpha Build 205**. Overlay-Sticky nach Remint/TTL. Helios Overlay-Lerp + Fill-Uhr.

## In 2.1.180 gelandet

1. leftoverOverlayGuestOf sticky leftoverNameLockHeld, sonst Hist-Tail
2. leftoverNameLockHeldCoast live/ghost nach TTL
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.180 (Build 205)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.179 — 2026-09-07

Binary **2.1.179 alpha Build 204**. Store poseAt. Overlay StoreName. leftoverHasHold poseAt. StoreChip. Helios Fill-Gap Kamera-Rebase.

## In 2.1.179 gelandet

1. leftoverFaceTrackHolds poseAt — Latch 4 s, Jump-Lock nicht TTL
2. leftoverFaceTrackStoreNameOf — Hold+Name ohne Dict-Pack
3. leftoverOverlayGuestOf — StoreName vor Hist
4. leftoverHoldMaxOf / leftoverHasHoldOf — ¾-Bins, poseAt Latch
5. leftoverStoreChip `store Ada` nach LOCK tot
6. LibraryStore leftoverOverlayGuest + leftoverHasHold verdrahtet
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.179 (Build 204)

Rest: CameraBroker, FaceTrack-Dict, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.178 — 2026-09-07

Binary **2.1.178 alpha Build 203**. WAL-Restore Load. TERM blockt Write. FaceTrack StoreName.

## In 2.1.178 gelandet

1. leftoverPairCommitWALApply / RestoreDisk — Crash-Restore nach mtime, nicht 2 s RAM
2. leftoverPairCommitWALShouldClear nach gallery.json Save
3. cameraMutexTermBlocksWrite + TERM-Chip
4. leftoverFaceTrackStoreName
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.178 (Build 203)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.177 — 2026-09-07

Binary **2.1.177 alpha Build 202**. Twin-tieKey. Print-Prune Bank. Pair-WAL. SIGTERM. Helios Freeze-fps.

## In 2.1.177 gelandet

1. leftoverHashTwinOccupied(tieKey:) — LibraryStore UUID, Occupied Exact bei Yaw-Tie
2. leftoverOccupiedOtherRows — Twin-Rows mit UUID
3. leftoverPrintBankPrune in printBankBlend — Burst 0,98 raus
4. leftoverPairCommitWAL vor gallery.json, 3-Rotate, Restore < 2 s
5. cameraMutexHeartbeatKillSignal SIGTERM → SIGKILL 2 s
6. leftoverFaceTrackStoreGet
7. Tests + MARKETING_VERSION 2.1.177 (Build 202)

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.176 — 2026-09-07

Binary **2.1.176 alpha Build 201**. Hung-live. Enroll ¾L/¾R. Twin-Tie. FaceTrack-Lookup. Helios S2 Ghost.

## In 2.1.176 gelandet

1. cameraMutexHeartbeatKillPid hung-live — Stamp ≥ 12 s trotz live-PID
2. leftoverEnrollSlotChip / SlotHave — Coach `enroll ¾R`
3. leftoverHashTwinLeft tieKey — Yaw-Gleichstand nicht beide Occupied
4. leftoverFaceTrackLookup / Holds, PrintPruneDup, PairCommitWAL
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.176 (Build 201)

Rest: FaceTrack als Store, CameraBroker. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.175 — 2026-09-07

Binary **2.1.175 alpha Build 200**. Print-Skip HUD. ROI ohne still. Helios S2 Hist+Coast.

## In 2.1.175 gelandet

1. leftoverPrintSkipChip / SkipSummary — Ada still, Twin print
2. liveRoiTracks — Crop nur Print-Bedarf
3. leftoverGateChip + leftoverPrintSkipIds
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.175 (Build 200)

Rest: FaceTrack als Store, CameraBroker. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.174 — 2026-09-07


Binary **2.1.174 alpha Build 199**. Print je Gesicht. Yaw-Merge nur mit Print. Helios Live-Scale.

## In 2.1.174 gelandet

1. printBudgetSkipIds / SkipAll — Twin bewegt, Ada skippt
2. leftoverPrintSkipHits / SkipBoxes + FaceEngine skipPrintBoxes
3. leftoverPrintYawMerge(printedIds:) — Ada-Yaw hält
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.174 (Build 199)

Rest: FaceTrack als Store, CameraBroker. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.173 — 2026-09-07

Binary **2.1.173 alpha Build 198**. FaceTrack-PredictHeld. Coast gallery. Lookaway-Tried tot. stillFor/Stamp/`??` aus 2.1.172 bleiben.

## In 2.1.173 gelandet

1. leftoverFaceTrackPredictHeld + VelMerge
2. leftoverCoastPrint + Age in gallery.json
3. leftoverTriedInserts(lookaway:)
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.173 (Build 198)

Rest: FaceTrack als Store, CameraBroker. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.172 — 2026-09-07


Binary **2.1.172 alpha Build 197**. stillFor, Coast-Stamp, Kalman-Predict, Overlay `??`.

## In 2.1.172 gelandet

1. printBudgetSkip(stillFor:) — < 0,80 s kein Skip
2. leftoverCoastPrintSame / StampMerge(stored:) — identischer Cache kein Restamp
3. leftoverPredictHeld → leftoverFaceTrackKalmanPredict
4. leftoverUnsureChip(streak:) `??` — leftoverOverlayGuest liest leftoverUnsureTicks
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.172 (Build 197)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.171 — 2026-09-07

Binary **2.1.171 alpha Build 196**. Unsure-Tried tot, Unsure-Streak 3, Coast-TTL 2 s, Name-Hist Remint keep 1.

## In 2.1.171 gelandet

1. leftoverTriedInserts / leftoverPinCounts — Unsure kein Tried, kein Pin
2. leftoverUnsureStreakAdvance/Clears — 3× `?` → leftoverClearStreak
3. leftoverCoastPrintFresh / StampMerge — RAM-Cache 2 s tot
4. leftoverNameHistRemintTrim — nach Remint 1 Vote, Twin nicht sofort Ada
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.171 (Build 196)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.170 — 2026-09-07

Binary **2.1.170 alpha Build 195**. Unsure ohne Vec, Detect-Skip IoU, Kalman-Vel, Heartbeat-SIGKILL.

## In 2.1.170 gelandet

1. leftoverHoldLookupUnsure / leftoverHoldViaLookup — Twin nicht auf 0,70 taufen
2. leftoverDetectSkipIoUOnly / leftoverPick(iouOnly) — Detect-Skip max IoU
3. leftoverCoastCosineMeasured + holdPrev Lookup
4. leftoverFaceTrackKalmanVel px/py im FaceTrack
5. cameraMutexHeartbeatKillPid — tot-PID SIGKILL
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.170 (Build 195)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.169 — 2026-09-06

Binary **2.1.169 alpha Build 194**. Remint-Lookup nach Drop, Mutex WRITE pidLive.

## In 2.1.169 gelandet

1. leftoverHoldRemintLookup — leftover matching liest Hold/Kalman/Coast auf Live-UUID
2. cameraMutexWriteAllowed / LockedLine(pidLive:) — tot Helios-PID, Lock frei
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.169 (Build 194)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.168 — 2026-09-06


Binary **2.1.168 alpha Build 193**. Coast-Print-Vec, Print-Yaw-Δ.

## In 2.1.168 gelandet

1. leftoverPrintBudgetYawDelta — Drehung seit letztem Print, nicht |yaw|
2. leftoverCoastPrintSkipCosine — skipPrints Cache ≥32 gegen Twin
3. printBudgetSkip(yawDelta:) — |Δ| ≥ 8° → Print trotz |yaw| 5°
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.168 (Build 193)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.167 — 2026-09-06

Binary **2.1.167 alpha Build 192**. Live-Skalare im FaceTrack, Name-Hist/Print-Trail remintet, Continuity nie printBudget.

## In 2.1.167 gelandet

1. FaceTrack Yaw/Still/EMA/Blink/Vote — Pack+Remint
2. leftoverHoldRemintDrop Name-Hist, Print-Trail, 1-Euro, Drift, Capture-Hist
3. leftoverCoastCosine(livePrintEmpty:)
4. printBudgetSkip(continuity:)
5. Yaw-Snapshot vor Task.detached
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.167 (Build 192)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.
