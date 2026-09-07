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
