# Helios + Aegis — Analyse 2026-09-05 (2.1.88)

Helios **1.5.72** (Build 92). Aegis **2.1.88 alpha** (Build 114). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.87 noch sprangen / tot wirkten

2.1.87 hält Live-min mit Ghost, unknownCentroid-Floor, Profil-EMA 0,45, Spark Overlay, 4K-Gap. Fünf Löcher blieben:

1. **Ghost-Nacht im Floor.** `leftoverSessionCapture` min(Ghost 0,18, Live 0,70) = 0,18. Tag bleibt Nacht-Floor. Twin 0,61 tauft.
2. **¾ schreibt Hold-EMA.** leftoverHoldWriteOk erst ab Profil 0,45 rad. ¾ 0,35 zieht Frontal-Hold 0,80 auf 0,70. Nächster Frontal spike-blockt.
3. **Print-Floor auf Smooth.** leftoverPick filtert leftoverPrintOk(smoothed). Impostor 0,50 ∧ Hold 0,80 → 0,70. Name klebt am Falschen.
4. **Nacht-Climb = Twin-Spike.** Hold 0,61 → 0,66 ist +0,05. leftoverHoldBlocks wirft Anna beim Hellwerden weg.
5. **FaceEngine unknownCentroid ohne Capture.** Live-Name-Pfad Floor 0,62 hart. Nacht 0,61 → decidedId nil, Overlay tot obwohl leftoverPick halten würde.

## Was 2.1.88 wirklich ändert

1. **`leftoverSessionCapture`.** Live nonempty ignoriert Ghost. Tag 0,70 bleibt 0,70.
2. **`leftoverHoldWriteOk`.** Yaw-Skip bei leftoverLookawayYaw 0,28, nicht erst 0,45.
3. **`leftoverPickPrint`.** leftoverPrintOk auf RAW. Smooth nur Score.
4. **`leftoverHoldClimb`.** prev < 0,62 kein Spike-Block.
5. **FaceEngine `unknownCentroid(capture:)`.** Nacht-Floor 0,60 auch im Live-Namen.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.88 (Build 114).

2.1.87 bleibt: Live-min (Nacht), unknownCentroid Session-Math, Profil-Helfer, Spark Overlay, 4K-Gap, Live-Centroid ohne Profil-Mix.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank, Blink-Liveness, per-Box Capture statt min(alle Live).

Helios 1.5.72: Display-Link nicht compounden, Freeze vel 0, Fill tot bei Hold, Totzone MAD, Kamera rebased. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
