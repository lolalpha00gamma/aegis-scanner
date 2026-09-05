# Helios + Aegis — Analyse 2026-09-05 (2.1.101)

Helios **1.5.85** (Build 105). Aegis **2.1.101 alpha** (Build 127). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## 2.1.100 → 2.1.101

2.1.100: leftoverScore Nacht-Rampe, Capture-Band 15–30. Live: Overlay lang, ¾ mischt Frontal-Trail, Center Stage an, Preset clampte Continuity, Softmax-Floor 0,55 nachts, Heat-Mid 0,72, kein SHARP/BAND-Chip.

## Warum Namen nach 2.1.100 noch sprangen / tot wirkten

1. **`leftoverHoldChip` lang `gehalten 0,80 / 0,64`.** Overlay voll. Compact `HOLD 80/64` fehlte.
2. **`leftoverHoldTrail[id]` UUID-Mix.** ¾-Chip las Frontal-Trail. leftoverHoldNow sitzt auf dem Bin, Trail nicht.
3. **Kein Center Stage Off.** Helios 1.5.84, Aegis nicht. CS croppt Box, Formatliste 8 fps.
4. **`sessionPreset .hd1280x720` vor dem Gerät.** Continuity 8 + BGRA.
5. **Softmax-Floor 0,55 nachts.** 0,62 vs 0,60 blockt wie Tag 0,72 vs 0,71.
6. **Heat-Mid 0,72 bei Session-Drop.** Genuine 0,62 nachts tot trotz leftoverScore capture.
7. **420v Laplacian ohne Range-Lift.** VideoRange Offset 16, Sharp wirkt 0,10 zu dunkel.
8. **Kein SHARP/BAND-Chip.** Nutzer sieht nicht warum leftover tot ist.

`bugfix` (2.1.15) hinter main, nichts nachziehen.

## Was 2.1.101 wirklich ändert

1. leftoverHoldChip compact `HOLD 80/64`. ¾-Trail nicht UUID-Mix.
2. leftoverScoreHeatMid Nacht 0,60. leftoverSoftmaxFloorOf 0,47 nachts.
3. Center Stage aus vor Format. Continuity kein Preset. lock 24 statt 30.
4. SHARP + BAND Chips. 420v Sharp-Lift. 422 vor BGRA. Format-Chip Toolbar.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.101 (Build 127).

Helios 1.5.85: Preset aus, 24 statt 30, Timer-Retarget, ROI 1,8×, AE 1,2 s, Format-Chip. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
