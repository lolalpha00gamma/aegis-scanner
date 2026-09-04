# Helios + Aegis — Analyse 2026-09-04 (2.1.72)

Helios **1.5.56** (Build 76). Aegis **2.1.72 alpha** (Build 98). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.71 noch sprangen

2.1.71 hat printPin-Trail, Kalman-Put, Overlay-Tap-Lock, Burst-AE, leftover gestrichelt verdrahtet. Fünf Löcher blieben:

1. **Trail-Lookup Roh-Box.** Put Kalman, `trailNow` `leftoverBoxHash(adopted.box)`. MAD tot, erster 0,82 tauft.
2. **EMA ohne dt.** 8 fps ein Tick = Spike 0,06 wie 7 Frames bei 24 fps. leftoverHoldSmooth sprang.
3. **Twin 0,93 + Baptize 0,82 Adopt.** Soft-Veto 0,90 ließ Zwillinge taufen. Keyboard-Rename ohne Tap-Lock.
4. **Ghosts nicht gezeichnet.** `liveGhosts` nur IDs am Live-Face. Dropout: Kiste weg, Overlay tot. Enrolled Yaw ¾ taufte leftover.
5. **AE/Ghost ohne Chip.** Exposure-Lock unsichtbar. Overlay-Tap auf Gast nur Select.

## Was 2.1.72 wirklich ändert

1. **`leftoverTrailWriteHash`.** Put = Lookup = Kalman. Tests Trail-Hash = Hold-Hash.
2. **`leftoverHoldAlpha(dt)`.** 8 fps α ≈ 0,05. Spike 0,06 dämpft.
3. **`leftoverTwinHardBlocks` 0,92.** Auch Baptize tot. **`renameIdentity` Tap-Lock 3 s.**
4. **`ghostFaces()` Overlay.** Dropout gestrichelt. **`leftoverLookawayBlocks`** enrolled Yaw ≥ 0,28 freeze.
5. **AE / GHOST HUD.** Gast-Tap `TAUFEN?`. TAP nicht leftover-orange. Prune-Log nur leerer Frame.
6. VERSION = Models = MARKETING_VERSION 2.1.72 (Build 98).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, Burst-5 Pref, Dropout-TTL Pref.

Helios 1.5.56: Drag-Timeout, Latch-displayTick, destClamp lastScreen, Palm 8 fps 4, IDLE/Relock/SCALE, ⌥-Relock. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
