# Helios + Aegis — Analyse 2026-09-05 (2.1.100)

Helios **1.5.84** (Build 104). Aegis **2.1.100 alpha** (Build 126). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## 2.1.99 → 2.1.100

2.1.99: leftoverAdoptReady `needSec` vor `holdPrev` (xcodebuild), HOLD Overlay ¾, pin ≥, Continuity-Sharp, Capture 420f. leftoverScore rampte trotzdem ab Laplacian 0,22 — Nacht 0,14 × 0,88. Capture lockte hart 30 fps.

## Warum Namen nach 2.1.98 noch sprangen / tot wirkten

2.1.98 war IEEE-Pflaster. Live:

1. **`leftoverHoldChip` las `leftoverHold[id]`.** ¾-Bin sitzt in leftoverHoldBins. Overlay zeigte Frontal-EMA 0,80 oder nichts. leftoverHoldPrevOf war tot im Chip.
2. **`pinByPrint` `>` 0,80.** leftoverBaptizeBoth Smooth `≥`. Roh 0,80 tauft nicht, Smooth 0,80 schon — zwei Sprachen.
3. **`leftoverPrintSharp` 0,22** in leftoverPrintOk Genuine-Pfad. Continuity Laplacian 0,12–0,14: 0,62 nachts tot.
4. **LiveCapture 32BGRA + CGContext auf BaseAddress.** Continuity 8 fps. 420f → GetBaseAddress nil → keine Frames.
5. **leftoverScore Sharp-Rampe ab 0,22.** Nacht 0,14 → Faktor 0,88, Genuine 0,72 wird 0,63.
6. **Capture-Lock hart 30.** Range 1–30 min=max 1/30 droppt Continuity auf 8.

`bugfix` (2.1.15) hinter main, nichts nachziehen.

## Was 2.1.99 gelandet hat

1. leftoverHoldChip / overlayName leftoverHoldNow = leftoverHoldPrevOf (Yaw-Bin).
2. pinByPrint / leftoverBaptize `≥` 0,80.
3. leftoverPrintSharpOf Nacht/Continuity 0,12.
4. Capture 420f + CIImage, FormatScore analog Helios.
5. leftoverAdoptReady needSec vor holdPrev — Live-Adopt kompiliert.
6. VERSION = Models = MARKETING_VERSION 2.1.99 (Build 125).

## Was 2.1.100 wirklich ändert

1. leftoverScore `capture:` — Nacht-Rampe ab leftoverPrintSharpOf 0,12, nicht 0,22.
2. leftoverPick reicht Box-Capture in leftoverScore.
3. captureLockFrameLo Band 15–30 analog Helios lockFrameLo.
4. VERSION = Models = MARKETING_VERSION 2.1.100 (Build 126).

Helios 1.5.84: 420f, Fill 90 Hz, ROI 0,10, Warp-Axis, Band 15–30, CS vor Format. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
