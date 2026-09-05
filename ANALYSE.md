# Helios + Aegis — Analyse 2026-09-05 (2.1.93)

Helios **1.5.77** (Build 97). Aegis **2.1.93 alpha** (Build 119). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` hinter main, nichts nachziehen.

## Warum Namen nach 2.1.92 noch sprangen / tot wirkten

2.1.92 hält leftoverHoldByHash je Bin, leftoverPick Hash-Hold, Frame-Luma-Helfer, leftoverHoldBinChip. Drei Löcher blieben:

1. **Capture-Hist leftover-weit.** Gast mit eigener Hist 3+ erbte Annas Median. Flash ohne Box-Hist muss leftover halten.
2. **HUD ohne CAP, BIN nicht wired.** leftoverHoldLabel yawAbs saß tot. Nacht-Floor unsichtbar.
3. **leftoverScore linear 0,70–0,90.** Twin 0,72 vs 0,80 platt. Softmax fehlte.

## Was 2.1.93 wirklich ändert

1. **`leftoverCaptureHistOf`.** Box-Hist ≥ 3. leftoverPick `captureBoxHist`.
2. **`leftoverCaptureChip` + leftoverHoldLabel yawAbs** im Overlay.
3. **`leftoverScoreHeat` Temp 16 + `leftoverScoreSoftmax` Floor 0,55.** leftoverPick wired.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.93 (Build 119).

2.1.92 bleibt: leftoverHoldByHash je Bin, leftoverPick Hash-Hold, leftoverSessionCapturePrefersFrame, leftoverHoldBinChip.

Helios 1.5.77: Open-Hysterese, Fill coalesced, destBounds-Latch, Fill-Share. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
