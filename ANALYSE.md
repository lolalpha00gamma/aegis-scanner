# Helios + Aegis — Analyse 2026-09-04 (2.1.84)

Helios **1.5.68** (Build 88). Aegis **2.1.84 alpha** (Build 110). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` geprüft: hinter main, nichts nachziehen.

## Warum Namen nach 2.1.83 noch sprangen / tot wirkten

2.1.83 hält Adopt-Blend, Predict bei Fremder Kiste, Trail-Schärfe, Live-ROI, Kalman-NMS, Ghost-AE. Ein Loch blieb, das leftover kaputt macht sobald mehr als eine Kiste im Bild ist:

**`leftoverBoxHash` Clamp-auf-1.** Live-Box ist Pixel (vnToPixels). Tests liefen mit 0–1. cx=200 und cx=900 landen beide in Bin 11. Hold/Trail von Anna klebt an Gast 2. Nach Dropout erbt der Falsche den Cosine.

## Was 2.1.84 wirklich ändert

1. **`leftoverBoxUnit` / Hash mit imageW/H.** Pixel-Kisten räumlich getrennt.
2. **`leftoverLiveHash`.** Alle Hold/Trail-Writes dieselbe Normierung.
3. **`leftoverTrailPut(sharpness:)`.** Blur auch im Put kein Append.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.84 (Build 110).

2.1.83 bleibt: leftoverAdoptBlend, leftoverPredictOnEmptyLike, leftoverTrailWriteOk, kalmanNmsDrops, liveRoiBox, exposureLockHold(reconnect).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank nach Yaw-Bins, Quality-weighted Centroid, leftoverKalman-Q aus Capture analog Helios luma-Q, Hold-Hash 16 Bins auf 4K.

Helios 1.5.68: ROI-Miss (8 fps direkt voll), Pinch-Open Extra-Margin, Faust-AE, Kalman-Q, Freeze nur im AE-Fenster, Tip-Occlusion. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
