# Helios + Aegis — Analyse 2026-09-05 (2.1.91)

Helios **1.5.75** (Build 95). Aegis **2.1.91 alpha** (Build 117). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` (2.1.15) hinter main, nichts nachziehen.

## Warum Namen nach 2.1.90 noch sprangen / tot wirkten

2.1.90 hält Pick-EMA AE, Twin-Score, Galerie-frontal, Capture-Median-Helfer, Hold-Bin-Helfer. Drei Löcher blieben:

1. **leftoverHoldBin tot.** Store `leftoverHold[id]`. leftoverPick Smooth mit Frontal-Hold 0,80 auf ¾-Roh 0,68 → 0,76. Twin 0,72 verliert gegen den geglätteten ¾.
2. **leftoverHoldWriteOk skippt ¾.** Bin konnte nie schreiben. Blick zurück: Hold stale oder frontal-kontaminiert.
3. **Capture-Hist nicht in leftoverPick.** `liveCaptureHist` sitzt für Burst-Print. leftoverSessionCaptureBox(hist:) ohne Samples → Flash 1 Tick senkt den Floor. Median-Helfer tot.

## Was 2.1.91 wirklich ändert

1. **`leftoverHoldKey` / `leftoverHoldPrevOf`.** ¾/Profil erben nicht Frontal. leftoverPick Smooth je Bin.
2. **`leftoverHoldBins` im Store.** `leftoverHoldBinPut` / Survive / Drop. leftoverHoldWriteOk bleibt frontal-only für leftoverHold[id].
3. **leftoverPick `captureHist` + `holdBins`.** liveCaptureHist an Box(hist:). Flash-Median sitzt.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.91 (Build 117).

2.1.90 bleibt: Pick-EMA AE, Twin-Score, Galerie-frontal, Capture-Median-Helfer, Hold-Bin-Helfer.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Drop-in `.mlmodel`, DBSCAN vor Merge, Yaw-binned Print-Bank als Galerie, Blink-Liveness, Iris-Twin-Veto.

Helios 1.5.75: Kalman-Q je Achse, Warp-Cap Diagonale, Rand-Gain 40 px. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
