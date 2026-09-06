# Aegis Nachtrag 2.1.166 — 2026-09-06

Binary **2.1.166 alpha Build 191**. FaceTrack-Remint verdrahtet, printBudget IoU+Yaw, expected-gen CAS.

## In 2.1.166 gelandet

1. leftoverFaceTrackRemintDropMaps — Hold/Pending/Streak/Hash/IoU/Name/Miss/Pair ein Remint
2. liveYaw/Pitch/Roll reminten
3. printBudgetSkip(minIoU:yawAbs:) — Skip nur IoU ≥ 0,92 und |yaw| < 8°
4. cameraMutexCasAllows / expectedGen, ClaimChip, mutexClaimFails
5. Unpack ohne Defaults
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.166 (Build 191)

Rest: FaceTrack als Store, CameraBroker, Overlay-Metal. Siehe VORSCHLAEGE-GROK.md.
