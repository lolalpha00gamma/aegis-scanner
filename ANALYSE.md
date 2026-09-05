# Helios + Aegis — Analyse 2026-09-05 (2.1.90)

Helios **1.5.74** (Build 94). Aegis **2.1.90 alpha** (Build 116). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.89 noch sprangen / tot wirkten

2.1.89 hält per-Box Capture, unknownCentroid Yaw, Hold-EMA α aus Capture-Jump. Fünf Löcher blieben:

1. **leftoverHoldSmooth ignoriert captureJump.** Pick-Pfad α 0,35 trotz AE. LibraryStore schreibt träge, leftoverPick scored den Spike.
2. **leftoverScore ohne twinPair.** Hard-Veto 0,92. 0,88–0,91 gewinnt leftoverScore gegen den echten Frontal. Vierter Term fehlte.
3. **Galerie-Centroid schluckt ¾.** centroidWeight dämpft, leftoverCentroidOk fehlte. ¾ in der Galerie zieht Anna auf den Twin.
4. **Capture min/live, kein Median.** Flash 1 Tick 0,70→0,18 senkt den Floor. Hist ≥ 3 → Median.
5. **eine leftoverHold-EMA für alle Posen.** WriteOk skippt ¾, Bin-Helfer fehlte für den nächsten Store-Key.

## Was 2.1.90 wirklich ändert

1. **`leftoverHoldSmooth(captureJump:)`.** leftoverPick reicht den Jump.
2. **`leftoverScore(twinPair:)`.** ≥ 0,88 Same-Shot zieht Score.
3. **`leftoverCentroidOk`.** FaceEngine meanPrintVector nur scharf+frontal, sonst Fallback.
4. **`leftoverSessionCaptureMedian` / Box(hist:).** Flash 1 Tick Floor bleibt.
5. **`leftoverHoldBin`.** 0 frontal / 1 ¾ / 2 Profil.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.90 (Build 116).

2.1.89 bleibt: per-Box Capture, unknownCentroid Yaw, Hold-α AE.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank, Blink-Liveness, Iris-Twin-Veto.

Helios 1.5.74: Fill-Coast, Rest-MAD Screen-Vel, 2×2 Kalman-P, Naht 24 px, HOLD. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
