# Helios + Aegis — Analyse 2026-09-04 (2.1.82)

Helios **1.5.66** (Build 86). Aegis **2.1.82 alpha** (Build 108). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` geprüft: hinter main, nichts nachziehen.

## Warum Namen nach 2.1.81 noch sprangen / tot wirkten

2.1.81 hat Kalman-Predict, Pending-Mirror, HOLD-Chip. Drei Löcher blieben:

1. **leftover Adopt droppte Kalman+vx.** ID bleibt, Filter tot. Erster Live-Frame roh → Overlay-Sprung, IoU tot, Gast n+1.
2. **`leftoverEmptySince` global.** Poster/Gast im Frame wischte Annas Latch. 4 s Ghost nur wenn *gar keine* Kiste da.
3. **Hold-EMA ohne dt.** 8 fps Spike 0,06 in einem Tick. Blur unter leftoverPrintSharp schrieb trotzdem Hold.

## Was 2.1.82 wirklich ändert

1. **`leftoverAdoptKeepsKalman`.** Adopt droppt Kalman nicht.
2. **`leftoverEmptyIgnoresStranger`.** IoU < 0,18 = Latch wie leer.
3. **`leftoverHoldAlpha(dt)` am Live-EMA.** **`leftoverHoldWriteOk`.** Blur kein Hold-Write.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.82 (Build 108).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank, Quality-weighted Centroid im leftover-Trail.

Helios 1.5.66: Engine hält Ghosts, Pool am Dropout, Sparse ohne Tips. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
