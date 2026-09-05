# Helios + Aegis — Analyse 2026-09-05 (2.1.99)

Helios **1.5.83** (Build 103). Aegis **2.1.99 alpha** (Build 125). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## 2.1.98 → 2.1.99

Math-Tests grün. xcodebuild: leftoverAdoptReady `holdPrev` vor `needSec`. Live-Adopt kompiliert nicht.

## 2.1.97 → 2.1.98

Tests liefen durch bis leftoverPick ¾. **leftoverHoldBlocks** `0,70 − 0,66 >= 0,04` ist IEEE-nein (`0,0399…`). Twin im ¾ mit Exact-Spike 0,04 stiehlt. `+1e-9` analog kalmanNmsDrops.

## Warum Namen nach 2.1.96 noch sprangen / tot wirkten

2.1.96 leftoverTransfersId leftoverBaptizeBoth, leftoverHoldPrevOf live. CI kompiliert, Tests tot:

1. **leftoverBaptizeBoth EMA 0,80.** pinByPrint ist `>` 0,80. Smooth 0,80 (Hold nach 0,80) tauft nicht. Twin 0,82 nach echtem Hold 0,80 tot. leftoverBaptizeBoth-Kommentar sagt ≥.
2. **leftoverAdoptNeedSec × 0,5 bei 8 fps.** 0,6 s = 5 Frames. Walker stiehlt. leftoverAdoptNeed-Test will 10 Frames / 1,2 s. Analog Pinch ist falsch — Taufe braucht Zeit, Pinch Reaktionszeit.
3. **leftoverBlurBlocks leftoverPrintSharp 0,22.** leftoverPick-Tests Schärfe 0,20 tot. Continuity Laplacian 0,12–0,14 hält kein leftover 0,64. leftoverHoldWriteOk schreibt nie auf Continuity.
4. **liveRoiBox min 0,18.** HD-Gesicht 80×100 → Crop 144/1280 = 0,11 → nil. Force-Unwrap crasht Tests. Live: kein ROI, 8 fps False-Empty oder Full-Frame.

`bugfix` (2.1.15) hinter main, nichts nachziehen.

## Was 2.1.98 wirklich ändert

1. leftoverHoldBlocks / leftoverBaptizeSpike `+1e-9`.
2. VERSION = Models = MARKETING_VERSION 2.1.98 (Build 124).

2.1.97 bleibt: leftoverBaptizeBoth ≥ 0,80, Adopt 1,2 s, sharpnessFloor 0,12, liveRoi 0,10.
2.1.96 bleibt: leftoverTransfersId leftoverBaptizeBoth verdrahtet, leftoverHoldPrevOf live, Lookaway Bin 0.

Helios 1.5.82: 24 fps Kalman-Test. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
