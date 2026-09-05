# Helios + Aegis — Analyse 2026-09-05 (2.1.95)

Helios **1.5.79** (Build 99). Aegis **2.1.95 alpha** (Build 121). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` hinter main, nichts nachziehen.

## Warum Namen nach 2.1.94 noch sprangen / tot wirkten

2.1.94 hält Frame-Luma live, Trail je Bin, HOLD roh/smooth im Label. Drei Löcher blieben im Live-Pfad:

1. **Dropout leftoverHoldLookup unbinned.** `hash#1` ¾ sitzt, Store-Lookup ohne `bin:` findet ihn nicht. Lookaway/holdPrev nach Dropout frontal leer, ¾ tot.
2. **Overlay leftoverHoldLabel ohne Trail.** leftoverHold[id] ist EMA. `gehalten 0,64` — Roh 0,80 unsichtbar. leftoverHoldLabel(smooth:) sitzt, drei Overlay-Pfade reichen nur Hold.
3. **Taufe roh allein.** Overlay zeigt Smooth, leftoverTransfersId tauft 0,82 nach 0,64 mit 3 Trail-Samples. leftoverBaptizeBoth fehlte.

## Was 2.1.95 wirklich ändert

1. **`leftoverHoldLookupYaw`.** Dropout/holdPrev immer Yaw-Bin. LibraryStore 4 Pfade.
2. **`leftoverHoldRawOf` / `leftoverHoldOverlayChip`.** Trail roh, Hold smooth. ContentView Overlay roh/smooth.
3. **`leftoverBaptizeBoth`.** Math roh UND smooth ≥ 0,80. leftoverTransfersId bleibt Spike-Pfad (3 Samples).
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.95 (Build 121).

2.1.94 bleibt: leftoverFrameCapture live, leftoverTrailPut/Lookup(bin:), leftoverHoldLabel(smooth:).

Helios 1.5.79: destEdge je Achse, destEdgeApplies, destEdgeFill. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
