# Helios + Aegis — Analyse 2026-09-05 (2.1.86)

Helios **1.5.70** (Build 90). Aegis **2.1.86 alpha** (Build 112). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.85 noch sprangen / tot wirkten

2.1.85 hält leftoverHoldLookup Exact, 4K-Bins, ROI-Miss, Ghost-Aspect, Kalman-Q. Fünf Löcher blieben:

1. **4K-Nachbar-Clip.** `leftoverBoxHashBinsInferred` bei Hash `11.11.3.2` → 12 Bins. Nachbar `12.11.3.2` geclippt. Hold stirbt an der 12er-Kante obwohl 24 Bins.
2. **leftoverPick ohne Detector.** `FaceObservation.score` (VN-Confidence) saß ungenutzt. Zwei 0,66-Prints, der unscharfe Detector gewinnt nicht.
3. **Kein L/R-Prior.** Anna links, Gast rechts: leftover nimmt den höheren Cosine rechts. Name springt.
4. **Session-Floor fest.** Nacht 0,61 tot gegen Genuine 0,62. Indoor-Hold stirbt.
5. **Centroid ohne Frontal/Yaw.** `centroidWeight` nur Capture×Schärfe. Profil-Print zieht den Live-Mean.

## Was 2.1.86 wirklich ändert

1. **`leftoverBoxHashNeighbors` used = max(24, bins, inferred).** Bin 11 → Nachbar 12.
2. **`leftoverScore(detScore:)` / leftoverPick `detScore`.** VN-Confidence dritter Term.
3. **`leftoverBoxOrderKeeps`.** Anna links bleibt links.
4. **`leftoverSessionFloor`.** Capture < 0,28 → Floor −0,02.
5. **`centroidWeight(frontal:yawAbs:)`.** Profil weniger Gewicht. FaceEngine verdrahtet.
6. **`leftoverCosineSparkPut` / `leftoverLiveWeight`.** Math für Overlay und Live-Centroid.
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.86 (Build 112).

2.1.85 bleibt: leftoverHoldLookup Exact, 4K-Bins, ROI-Miss, Ghost-Aspect, boxKalmanQ.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank, Blink-Liveness.

Helios 1.5.70: Kalman-State, adaptive Totzone, Low-Conf Freeze, 60 Hz, ROI keep-S1. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
