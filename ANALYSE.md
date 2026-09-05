# Helios + Aegis — Analyse 2026-09-05 (2.1.96)

Helios **1.5.80** (Build 100). Aegis **2.1.96 alpha** (Build 122). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## Warum Namen nach 2.1.95 noch sprangen / tot wirkten

2.1.95 Dropout-Hold je Bin, Overlay roh/smooth, leftoverBaptizeBoth Math. Drei Löcher, plus CI tot:

1. **CI kompiliert nicht.** MatchMathTests: `roi`/`edge`/`anna` redeclare in einer `run()`-Funktion. `leftoverBoxHashBins(1280)` ohne `imageW:`. Tests failen in 8 s, DMG wird nie gebaut.
2. **leftoverTransfersId tauft auf Roh.** leftoverBaptizeBoth sitzt, Spike-Pfad und Non-Spike ignorieren Smooth. Twin 0,82 nach Hold 0,64 mit 3 Samples stiehlt.
3. **holdPrev = leftoverHold[id] ?? lookupYaw.** leftoverHoldPrevOf sitzt, Store reicht Frontal-EMA in leftoverPick/TransfersId. ¾ erbt 0,80.
4. **Lookaway schreibt ¾ in leftoverHold[id].** Unbinned EMA ist Frontal. ¾-Lookup nach Dropout tauft den Twin.

`bugfix` (2.1.15) hinter main, nichts nachziehen.

## Was 2.1.96 wirklich ändert

1. **Tests kompilieren.** Unique-Lets, `leftoverBoxHashBins(imageW:)`.
2. **leftoverTransfersId leftoverBaptizeBoth.** Non-Spike Smooth. Spike-Trail Mean.
3. **LibraryStore leftoverHoldPrevOf** für holdPrev/holdNow. leftoverPick `holdPrev` nur leftoverHold[id] — Pick hat holdHash/holdBins.
4. **Lookaway schreibt leftoverHold[id] nur Bin 0.** leftoverHoldLookupYaw `yawAbs: nil` → nil.
5. VERSION = Models = MARKETING_VERSION 2.1.96 (Build 122).

2.1.95 bleibt: leftoverHoldLookupYaw, leftoverHoldRawOf, leftoverBaptizeBoth Math.

Helios 1.5.80: destEdge räumlich, Fill kein zweites destEdge, HUD je Achse, CI jointGain. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
