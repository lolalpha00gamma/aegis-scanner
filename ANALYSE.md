# Helios + Aegis — Analyse 2026-09-05 (2.1.94)

Helios **1.5.78** (Build 98). Aegis **2.1.94 alpha** (Build 120). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` hinter main, nichts nachziehen.

## Warum Namen nach 2.1.93 noch sprangen / tot wirkten

2.1.93 hält Capture-Hist je Box, CAP-Chip, Score-Softmax, HUD BIN. Drei Löcher blieben im Live-Pfad:

1. **`frameCapture` default nil.** leftoverSessionCapturePrefersFrame tot. Center Stage Box 0,18 senkt Floor. Math sitzt, Store reicht Box.
2. **Trail-Nachbarn unbinned.** Frontal 0,80 füttert ¾ über Spatial-Nachbar. leftoverHoldLookup(bin:) sitzt, Trail analog fehlte.
3. **HOLD eine Zahl.** Overlay `gehalten 0,80` — Smooth-Taufe 0,64 unsichtbar.

## Was 2.1.94 wirklich ändert

1. **`leftoverFrameCapture` / `leftoverFrameCaptureByte`.** 8×8 Buffer. leftoverPick `frameCapture:` live.
2. **`leftoverTrailPut(bin:)` / `leftoverTrailLookup(bin:)`.** Gleicher Yaw-Bin, Spatial-Nachbar frontal füttert ¾ nicht.
3. **`leftoverHoldLabel(smooth:)`.** `gehalten 0,80 / 0,64`. Overlay roh/smooth.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.94 (Build 120).

2.1.93 bleibt: leftoverCaptureHistOf, leftoverCaptureChip, leftoverScoreHeat/Softmax, leftoverHoldLabel yawAbs.

Helios 1.5.78: HOLD je Achse, destEdge radial + 8 fps Gain, Coast τ Diagonale, Warp Relock 3 Frames. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
