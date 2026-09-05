# Helios + Aegis — Analyse 2026-09-05 (2.1.92)

Helios **1.5.76** (Build 96). Aegis **2.1.92 alpha** (Build 118). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.91 noch sprangen / tot wirkten

2.1.91 hält leftoverHold[id:bin], Capture-Hist in leftoverPick, ¾ erbt nicht Frontal. Drei Löcher blieben:

1. **leftoverHoldByHash unbinned.** Store schrieb Hash nur frontal (`leftoverHoldWriteOk`). ¾-Bin UUID-keyed. Dropout: UUID weg, Hash ohne Bin. leftoverHoldPrevOf ¾ → nil → Smooth = roh. Twin 0,70 tauft.
2. **leftoverPick ohne Hash-Bin.** holdPrev frontal, bins leer nach Dropout. ¾ Smooth ignoriert Frontal — und hat keinen eigenen Prev.
3. **Center-Stage Box-Luma.** leftoverSessionCaptureBox nimmt Live-Box. Crop 0,18 senkt den Floor, 0,61 wirkt genuin. Overlay ohne BIN — ¾ unsichtbar.

## Was 2.1.92 wirklich ändert

1. **`leftoverHoldHashKey` / `leftoverHoldPut(bin:)` / `leftoverHoldLookup(bin:)`.** ¾ überlebt Dropout räumlich.
2. **leftoverHoldPrevOf + leftoverPick `holdHash`.** LibraryStore reicht leftoverHoldByHash. BinWriteOk schreibt Hash.
3. **`leftoverSessionCapturePrefersFrame`.** leftoverPick `frameCapture`. Overlay `BIN n` in leftoverHoldLabel.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.92 (Build 118).

2.1.91 bleibt: leftoverHold[id:bin], Capture-Hist, ¾ erbt nicht Frontal.

Was Masse noch bringen würde: FaceEngine Frame-Histogram in leftoverPick `frameCapture` (Store reicht noch Box), CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank als Galerie, Blink-Liveness, Iris-Twin-Veto.

Helios 1.5.76: Totzone je Achse, destEdge Kamera-Tick, Warp Relock Map. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
