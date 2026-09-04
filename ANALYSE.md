# Helios + Aegis — Analyse 2026-09-04 (2.1.71)

Helios **1.5.55** (Build 75). Aegis **2.1.71 alpha** (Build 97). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.70 noch sprangen

2.1.70 hat leftoverHoldSurvive live+Ghost, Dropout-TTL, Capture-Jump, Tap-Name-Lock wirklich verdrahtet. Fünf Löcher blieben:

1. **printPin wischte livePrintTrail.** Ghost-Adopt `removeValue` — Median tot, erster 0,82 tauft. KeepBoxes hielt Dropped, Adopt warf sie weg.
2. **leftoverHoldPut auf Roh-Box.** Lookup Kalman, Write `adopted[bestJ].box`. Kopfdrehen wechselt Bin, Hold weg.
3. **Tap-Lock nur Anlegen/+.** Overlay-Klick setzte `selectedFaceId` ohne `tapNameLockUntil`. leftover taufte in denselben 3 s.
4. **Capture-Jump 1 Frame.** AE-Burst 0,40→0,70→0,52: Undershoot nach 3 Frames schrieb den Gallery-Print. Exposure 0,20 s = 1–2 Frames bei 8 fps.
5. **Leftover-Kiste durchgezogen orange.** Wirkt wie ein Name. Ghost-Overlay sprang als Gast.

## Was 2.1.71 wirklich ändert

1. **`printTrailKeepsOnGhostAdopt`.** printPin lässt Trail/Slot stehen. MAD überlebt den Miss.
2. **`leftoverHoldWriteHash`.** Put = Lookup = Kalman-Kiste. Fallback Roh.
3. **`tapOverlay` / `tapOverlayLocksName`.** Overlay-Tap auf enrolled sperrt leftover 3 s. Chip `TAP ns`.
4. **`captureBurstBlocksPrint`.** 3-Frame-Fenster. `exposureLockHold(dt)` 8 fps 0,40 s.
5. **`overlayBoxDash` / `.ghost`.** Leftover und Ghost gestrichelt. `leftoverHoldPruneLine` Status.
6. VERSION = Models = MARKETING_VERSION 2.1.71 (Build 97).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge.

Helios 1.5.55: Steal blockt Cursor, Relock 0,35 s, LOCK-Timeout 1,2 s, displayTick Freeze, Palm-Reach. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
