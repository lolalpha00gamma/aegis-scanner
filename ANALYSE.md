# Helios + Aegis — Analyse 2026-09-04 (2.1.78)

Helios **1.5.62** (Build 82). Aegis **2.1.78 alpha** (Build 104). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.77 noch sprangen / tot wirkten

2.1.77 hat 0,62-Label, WEG-Fremder, Miss-3, 8 fps Adopt 0,6 s. Drei Löcher blieben:

1. **`found.isEmpty` wischte leftoverStreak / Kalman / Miss / Pair.** Ein Detector-Dropout bei 8 fps (üblich) reset Adopt und Majority. Nächster Frame = Gast n+1. leftoverHoldSurvive hielt den Cosine, die Streak-Uhr nicht.
2. **Genuine-Floor 0,62 ohne Yaw.** Profil-Twin 0,62 scharf = Hold und Adopt. Frontal-Nachbar verliert den Namen.
3. **Twin-Hard 0,92 bei zwei Gesichtern.** Same-shot 0,90 ist TWIN? weich — leftoverPick tauft trotzdem, wenn Print 0,82.

## Was 2.1.78 wirklich ändert

1. **`leftoverEmptyKeepsStreak`.** Leerer Frame: Streak, Miss, Pair, Kalman bleiben. Overlay leer, UUID nicht neu.
2. **`leftoverPrintFloor(yawAbs:)`.** Profil ≥ 0,28 rad → Floor 0,70. Frontal 0,62.
3. **`leftoverTwinHardVetoNow`.** Zwei Kisten im Frame: Hard 0,88. Ein Gesicht bleibt 0,92.
4. **`leftoverPick(facesInFrame:)`.** Same-shot Twin blockt Adopt.
5. VERSION = Models = MARKETING_VERSION 2.1.78 (Build 104).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank, Quality-weighted Centroid.

Helios 1.5.62: slotLatch 4 s, Warp 80 px, DIP-Occlusion, preferredNearest. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
