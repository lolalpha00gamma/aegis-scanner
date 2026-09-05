# Helios + Aegis — Analyse 2026-09-05 (2.1.104)

Helios **1.5.88** (Build 108). Aegis **2.1.104 alpha** (Build 130). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## 2.1.103 → 2.1.104

2.1.103 (main): CI-Fix. Swift-Overlay `availableVideoPixelFormatTypes`, Parameter `videoOut` (nicht `output` / AVPlayerItemVideoOutput). Live: Tap 5 fps, RotationCoordinator dreht den Buffer, leftoverTrailWriteOk blockt Yaw ≥ 0,28, Spark liest Frontal-UUID in ¾, Desk-View 4:3 tot, reselectFormat Queue-Hop.

## Warum Namen nach 2.1.103 noch sprangen / tot wirkten

1. **`FrameTap minInterval` 0,20 / 0,125.** Hunt 5 fps, Lock 8 fps. leftoverAdoptNeedSec 1,2 s = 6–10 Frames. EMA und Taufe hungern. Helios pumpt jeden Frame.
2. **`RotationCoordinator` Horizon-Level.** Helios 1.5.58 hat das getötet: physisches Drehen, Box 90°, leftover stiehlt. Aegis hatte denselben Pfad noch.
3. **`leftoverTrailWriteOk` Yaw ≥ 0,28.** leftoverHoldBinWriteOk schreibt ¾-Hold, Trail nicht. leftoverTrailNowOf ¾ = [] — Taufe ohne Bin-Trail.
4. **`leftoverSparkChip` ohne Yaw.** Overlay ¾ zeigt Frontal-UUID-Spark `0,80→0,82`.
5. **`captureFormatScore` height ≤ 1080.** Desk-View 1920×1440 Score −1.
6. **`reselectFormat` outputQueue → MainActor.** Device-Lock nach Sample, CS nicht zweimal.

`bugfix` (familyBump / Score-EMA / Gallery-Prune) hinter main, nichts nachziehen.

## Was 2.1.104 wirklich ändert

1. liveMinInterval Hunt 8/10, Lock 12/15. Continuity 15 fps sobald ein Track sitzt.
2. physicalCaptureRotation aus. Capture 0°. Portrait-Buffer `.right`, sonst `.up`.
3. leftoverTrailWriteOk ohne Yaw-Block. leftoverHoldTrail[id] nur frontal. leftoverSparkChip ¾ leer statt UUID-Mix.
4. leftoverHoldOverlayChipOf bleibt ¾-Chip (Bin-Hold, kein Frontal-Trail).
5. captureFormatScore 4:3 1920×1440. reselectFormat CS+Format zweimal auf Main.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.104 (Build 130).

2.1.103 bleibt: `availableVideoPixelFormatTypes` + `videoOut`.
2.1.102 bleibt: leftoverBaptizeBoth roh UND smooth, leftoverHoldOverlayChipOf, leftoverTrailNowOf, leftoverNameFromHold.

Helios 1.5.88: 15-fps-Pinch, 420v-Luma, Desk-View 4:3, Enhance-Skip, WARP-HUD. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
