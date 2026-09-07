# Aegis Nachtrag 2.1.193 — 2026-09-07

Binary **2.1.193 alpha Build 218**. Overlay identityId. Live-Blink hart. livePending. Session-Pause. Helios Fill-Uhr Wall.

## In 2.1.193 gelandet

1. leftoverGalleryRowId Overlay — ForEach identityId. leftoverOverlayUniqueRows Ghost fällt.
2. enrollBlocksWithoutBlink — Live ohne Blink tot. Foto bleibt.
3. liveEmitPendingWhileBusy — FrameTap drop-oldest, nicht Drop-new.
4. Session-Pause 2 s + Interrupted. ClaimWrites false (Helios hält) pausiert. Resume Claim zuerst.
5. Tests + VERSION = Models = MARKETING 2.1.193 (Build 218). Schema 15 bleibt.

Rest: CameraBroker, FaceTrack einzige Map, Overlay-Metal, CVPixelBuffer. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.192 — 2026-09-07

Binary **2.1.192 alpha Build 217**. leftoverCoastAt. Blink-Coach. Helios Fill Ghost tot.

## In 2.1.192 gelandet

1. leftoverCoastAtStamp — Print-TTL ≠ Coast-Start. miss=8 nach 0,50 s ist Ghost.
2. leftoverHoldChip + leftoverMissClears lesen leftoverCoastAt.
3. Remint leftoverCoastAt = faceMaps.coastAt (Drop kanonisch).
4. enrollCoachStep haveBlink Default false. leftoverBlinkSeen verdrahtet.
5. Models.swift vollständig (FaceObservation/Identity) — Bump hatte 116 Zeilen.
6. Tests + VERSION = Models = MARKETING 2.1.192 (Build 217). Schema 15 bleibt.

Rest: CameraBroker, FaceTrack einzige Map, Overlay-Metal, CVPixelBuffer, Session-Pause 2 s. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.191 — 2026-09-07

Binary **2.1.191 alpha Build 216**. Enroll frontal. Coach ¾L/¾R. Gallery-Row. Helios Fill-Warp.

## In 2.1.191 gelandet

1. printQualityBlocksEnroll Bin ≥ 2. Frontal nicht mehr blockiert.
2. enrollCoachStep Front → ¾L → ¾R → Blink. FaceEngine verdrahtet.
3. leftoverGalleryRowId identityId ?? detectId. Strip-ForEach.
4. leftoverMissClears canonical — Need tot wenn FaceTrack die Map ist.
5. Tests + VERSION = Models = MARKETING 2.1.191 (Build 216). Schema 15 bleibt.

Rest: CameraBroker, FaceTrack einzige Map, Overlay-Metal, CVPixelBuffer, Blink haveBlink. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.190 — 2026-09-07

Binary **2.1.190 alpha Build 215**. TrackKind hält Ada. Tests kompilieren. Overlay-Chip. Helios Kalman-Span.

## In 2.1.190 gelandet

1. leftoverMissClears = !leftoverTrackKindKeeps. Coast hält, Ghost löscht. coastAt 0,40 s.
2. leftoverHoldChipAppendKind. Overlay `HOLD · coast`.
3. MatchMathTests nearVec — `var near` tot.
4. Tests + VERSION = Models = MARKETING 2.1.190 (Build 215). Schema 15 bleibt.

Rest: CameraBroker, FaceTrack einzige Map, Overlay-Metal, CVPixelBuffer, coastAt ≠ Print-TTL. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.189 — 2026-09-07

Binary **2.1.189 alpha Build 214**. ¾-Enroll. Remint-Drop. TrackKind. Helios Kalman-Klemme.

## In 2.1.189 gelandet

1. skipPrint: ¾ (Bin 1) kein Quality-Skip. FaceEngine übergibt Yaw.
2. leftoverFaceTrackRemint = Drop wenn canonical. Source-UUID tot.
3. leftoverTrackKind live | coast | ghost. leftoverMissClears liest Kind.
4. obsFillUsesMutexPts dt. Epoch-Mismatch → own.
5. Tests + VERSION = Models = MARKETING 2.1.189 (Build 214). Schema 15 bleibt.

Rest: CameraBroker, FaceTrack einzige Map, Overlay-Metal, CVPixelBuffer. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.188 — 2026-09-07


Binary **2.1.188 alpha Build 213**. Mutex v2, Kamera-Paar, Twin-tieKey ohne Yaw, Kill aus.

## In 2.1.188 gelandet

1. cameraMutexLine immer 5 Felder + `v2`.
2. obsFillUsesMutexPts Skew 220 ms.
3. leftoverHashTwinLeft x-Tie: tieKey auch ohne Yaw.
4. Default Built-in, Migration Auto → Built-in einmal.
5. SIGKILL Default aus. Toolbar-Toggle Kill.
6. Tests + VERSION = Models = MARKETING 2.1.188 (Build 213). Schema 15 bleibt.

## Offen

P0 CameraBroker.
P0 FaceTrack = einzige Store-Map. leftoverHold/Peak/PairLast/NameLock sind noch 20 Dictionaries.
P1 CVPixelBuffer bis Detect. LiveCapture nicht @MainActor.
P2 MatchMath split. Mutex v2 Datei ist da, Kit fehlt.
P2 Print-Qualität ungleich Skip-Gate (3/4-Enroll).
P2 Golden-Frames 8 fps + PTS.

## Erweiterung (neu)

1. **FaceTrack remint als eine Map.** leftoverAssignAtomicAll, LibraryStore listet keine 20 Moves mehr.
2. **Gallery-Row-ID überlebt Detect.** Overlay zeigt Row-Name, nie UUID-Tail.
3. **Enroll-Coach State Machine:** Front, ¾ L, ¾ R, Blink. Kein Print-Burst 0,98.
4. **Temperature-skalierte Cosine** statt hart 0,80.
5. **VNTrackObjectRequest** neben Rectangles.
6. **RTSP 420f**, Reconnect Exponential-Backoff.
7. **Watch-Folder PhotoKit**, Export `.aegis` verschlüsselt.
8. **P-Slot Maske/Schal**, Brille-Slot als Twin-Veto.
9. **Temporal ReID-Graph** über Hold-Trail.
10. **Overlay 60 Hz CAMetalLayer**, Detect 8–24 fps.
11. **gallery.json.bak Rotate 3**, printRevision je Identity.
12. **Licht-Eimer** (frontal / ¾ / Profil) statt einem Cosine.
13. **Match-Log JSONL** für Replay.
14. **Drop-in `.mlmodel`** FaceEmbedder-Protokoll.
15. **Zwei-Cam-Stereo** mit Helios Continuity + Aegis Built-in (jetzt Default-Paar).
16. **Shared HeliosAegisKit** für Mutex v2 + PTS + SlotKind/CoastKind.

# Aegis Nachtrag 2.1.187 — 2026-09-07

Binary **2.1.187 alpha Build 212**. FrameTap emitBusy. Vision-Interval. Helios 8-fps Klick/Dwell.

## In 2.1.187 gelandet

1. liveEmitAllows + FrameTap emitBusy. markFrameConsumed nach Detect. Hung 1 s.
2. liveMinIntervalFromVision — visMs hebt Interval.
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.187 (Build 212). Schema 15 bleibt.

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, CVPixelBuffer statt CGImage. Siehe VORSCHLAEGE-GROK.md.

# Aegis Nachtrag 2.1.186 — 2026-09-07

Binary **2.1.186 alpha Build 211**. Mutex-PTS. FrameTap Capture-Queue. Print-Qualität. Helios Pinch-Hysterese.

## In 2.1.186 gelandet

1. cameraMutexLine 5. Feld Sample-PTS. obsFillUsesMutexPts. LiveCapture schreibt lastStamp.
2. liveFrameTapEmitsOnCaptureQueue — FrameTap ohne Main-Hop. LibraryStore Task {@MainActor}.
3. printQuality sharpness×(1-|yaw|/90°). skipPrint yaw.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.186 (Build 211). Schema 15 bleibt.

Rest: CameraBroker, Overlay-Metal, IOHID, FaceTrack-Store, CVPixelBuffer statt CGImage. Siehe VORSCHLAEGE-GROK.md.

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
