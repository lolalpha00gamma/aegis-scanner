# Helios + Aegis — Analyse 2026-09-04 (2.1.81)

Helios **1.5.65** (Build 85). Aegis **2.1.81 alpha** (Build 107). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` geprüft: 2.1.15, hinter main, nichts nachziehen.

## Warum Namen nach 2.1.80 noch sprangen / tot wirkten

2.1.80 hat Kalman am Ghost, Latch-Hold, leftoverPending. Drei Löcher blieben:

1. **Kalman ohne Velocity.** Leerer Frame hielt die Box. Walker 8 fps: Overlay klebt, Reconnect-IoU tot, Gast n+1.
2. **`leftoverPending[newId]` nach `adopted.id = old.id`.** Filter auf liveIds wischte den Namen. Overlay tot obwohl Track lebte.
3. **Latch-Ende hartes Wipe.** Kalman tot, Chip weg in einem Frame. 0,4 s HOLD fehlte.

## Was 2.1.81 wirklich ändert

1. **`boxKalmanVelocity` + `boxKalmanPredict`.** Leerer Latch: `cx += vx·dt`, Ghost-Box folgt.
2. **`leftoverPendingMirror`.** Ghost-UUID → Adopt-ID.
3. **`leftoverLatchChipKeeps`.** Overlay/Pending 4,4 s, Kalman 4 s.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.81 (Build 107).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank, Quality-weighted Centroid.

Helios 1.5.65: Ghost bei Low-Conf, Warp-Cap, Palm-Kalman. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
