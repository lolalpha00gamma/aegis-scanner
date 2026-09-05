# Helios + Aegis — Analyse 2026-09-05 (2.1.85)

Helios **1.5.69** (Build 89). Aegis **2.1.85 alpha** (Build 111). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.84 noch sprangen / tot wirkten

2.1.84 hält leftoverBoxUnit Pixel durch Bildmaß. Fünf Löcher blieben:

1. **`leftoverHoldLookup` jüngster Nachbar.** Exact und 80 Nachbarn, Winner = `at` neueste. Anna in Bin 5, Gast in Bin 6: Anna erbt 0,90 vom Gast. Overlay-Name springt.
2. **12 Bins auf 4K.** 250 px zwischen zwei Köpfen = ein Hash. Hold klebt.
3. **liveRoiBox ohne Miss-Retry.** Crop leer (Kopf am Rand) = False-Empty, Latch stirbt. Helios 1.5.68 hatte dasselbe.
4. **Walk-in außerhalb ROI.** Zweite Person nie im Crop, bis Kalman tot ist.
5. **boxKalman Q fest.** Capture-Jump (AE) = Overlay klebt, Print blockt, Box hinkt.

## Was 2.1.85 wirklich ändert

1. **`leftoverHoldLookup` / `leftoverTrailLookup` Exact zuerst**, sonst Manhattan-Nachbar, nicht Recency.
2. **`leftoverBoxHashBins`.** 12 / 16 ab 1920 / 24 ab 3000.
3. **`liveRoiMissRetries` / `liveRoiMissGoesFull` / `liveRoiExpand`.** 8 fps direkt voll.
4. **`liveRoiPeriodicFull` alle 8 Ticks. `liveRoiSkipsForStranger`.**
5. **`leftoverGhostAspectLock`.** Predict cx/cy, w/h bleibt.
6. **`boxKalmanQ(captureJump)`.** AE 2,5× Process-Noise.
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.85 (Build 111).

2.1.84 bleibt: leftoverBoxUnit, leftoverLiveHash, leftoverTrailPut(sharpness).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank nach Yaw-Bins, Quality-weighted Live-Centroid.

Helios 1.5.69: Kalman-R, Pinch ratio-only 2, ROI S1, Faust-AE nur Continuity, Warp-Floor 96. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
