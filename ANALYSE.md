# Helios + Aegis — Analyse 2026-09-05 (2.1.87)

Helios **1.5.71** (Build 91). Aegis **2.1.87 alpha** (Build 113). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.86 noch sprangen / tot wirkten

2.1.86 hält Detector-Score, L/R-Order, Session-Floor, Centroid Pose, 4K-Nachbar. Fünf Löcher blieben:

1. **Session-Floor am Ghost.** `sessionCapture: old.quality.capture`. Anna war hell 0,70, Frame ist Nacht 0,18. Floor bleibt 0,62, Genuine 0,61 tot.
2. **unknownCentroid ignoriert Session-Floor.** leftoverPrintOk lässt 0,61 durch, Pick `allSatisfy unknownCentroid` wirft den Pool weg. Nacht-Hold tot.
3. **Profil schreibt Hold-EMA.** leftoverHoldWriteOk nur Schärfe. ¾ 0,58 zieht Frontal-Hold 0,80 runter. Nächster Frontal spike-blockt oder Name weg.
4. **Cosine-Spark tot.** leftoverCosineSparkPut nur Tests. Overlay springt 0,64→0,90 ohne Trail. leftoverTrail cap 5, nicht 8.
5. **4K-Order 40 px + Profil im Centroid.** Zwei Köpfe 80 px: Order stiehlt. leftoverLiveWeight unverdrahtet, Profil zieht den Live-Mean.

## Was 2.1.87 wirklich ändert

1. **`leftoverSessionCapture(old:live:)`.** min(Ghost, Live). LibraryStore verdrahtet.
2. **`unknownCentroid(capture:)`.** Nacht-Floor 0,60. leftoverPick reicht sessionCapture durch.
3. **`leftoverHoldWriteOk(yawAbs:)`.** Profil ≥ 0,45 rad kein EMA, kein Trail.
4. **`leftoverCosineSparkPut` / `leftoverCosineSparkLabel`.** Trail cap 8. Overlay `0,64→0,90`.
5. **`leftoverBoxOrderGap(imageW)` 4 %.** **`liveCentroidKeepsPrint`.** Profil raus solange Frontal da.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.87 (Build 113).

2.1.86 bleibt: Detector-Score, L/R-Order-Helfer, Session-Floor-Math, Centroid frontal×yaw, 4K-Nachbar nicht geclippt.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank, Blink-Liveness.

Helios 1.5.71: Continuity-Freeze nur DIP, 24 fps Kalman, kein Doppel-Lead, Display-dt echt, Totzone 6. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
