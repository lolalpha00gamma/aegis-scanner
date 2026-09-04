# Helios + Aegis — Analyse 2026-09-04 (2.1.83)

Helios **1.5.67** (Build 87). Aegis **2.1.83 alpha** (Build 109). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` geprüft: hinter main, nichts nachziehen.

## Warum Namen nach 2.1.82 noch sprangen / tot wirkten

2.1.82 hält Kalman am Adopt, Latch trotz Poster, Hold-EMA an dt. Vier Löcher blieben:

1. **Adopt droppte Kalman nicht, Overlay nahm die Live-Box roh.** Erster Reconnect-Frame = Teleport, IoU tot, Gast n+1.
2. **`boxKalmanPredict` nur bei `found.isEmpty`.** emptyLike (Poster IoU < 0,18) ließ vx liegen — Walker klebt, dann springt.
3. **Trail-Append ohne Schärfe.** Hold-Write sitzt, MAD bekam Blur-0,70. Twin-Hard falsch.
4. **Detector volles Bild, kein Kalman-NMS.** 8 fps False-Empty. Walker-Doppelkiste neben der Predict-Box.

## Was 2.1.83 wirklich ändert

1. **`leftoverAdoptBlend`.** Live durch Kalman, k=0,55.
2. **`leftoverPredictOnEmptyLike`.** Predict auch bei Fremder Kiste.
3. **`leftoverTrailWriteOk`.** dieselbe Schwelle wie Hold-Write.
4. **`kalmanNmsDrops` + `liveRoiBox`.** Twin weg, Crop um Kalman.
5. **`exposureLockHold(reconnect:)`.** 8 fps 0,80 s nach Ghost-Adopt.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.83 (Build 109).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank mit Pose-Keys, Quality-weighted Centroid im leftover-Trail (Math sitzt, Trail speichert nur Cosine).

Helios 1.5.67: Pinch-Hold 0 wenn Gate zu, Latch max S1/S2, Vision-ROI, Palm-Vel am Tick. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
