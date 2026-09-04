# Helios + Aegis — Analyse 2026-09-04 (2.1.66)

Helios **1.5.50** (Build 70). Aegis **2.1.66 alpha** (Build 92). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen sprangen

Matching ist nicht „Cosine > 0,78“. Live-ReID ist:

```
Box → NMS → Print (manchmal skip) → Geo → leftover-Assign
    → Majority 3 → Name-Lock 8 s → Ghost-TTL → Open-Set Floor
```

2.1.64 hat leftoverHold per Box-Hash und Schema 4. **2.1.65 hat Nachbar-Hash und Print-MAD nur in ANALYSE.md behauptet** — MatchMath blieb Exact-Lookup, Models.swift war kurz ein Placeholder (275ce66 Restore). MARKETING_VERSION blieb 2.1.64. Drei Löcher im Binary:

1. **Exact-Hash.** `leftoverBoxHash` rastert 12×12. Ein Schritt über die Bin-Kante wechselt `1.2.3.4` → `1.3.3.4`. Hold tot, Spike-Gatter tot, 0,70 tauft.
2. **Leerer Frame wischt die Hash-Tabelle.** Detector-Miss: `leftoverHoldByHash = [:]`. TTL 1,2 s war egal. Wiedereintritt: `holdPrev == nil`.
3. **`guestOrder.filter { liveIds }`.** Leerer Frame löscht die Liste. `guestIndex` unbekannt → immer Gast 1. Zwei leftover-Kisten = zwei „Gast 1“.
4. **Print-Trail ohne MAD.** Median 0,64 neben einem Twin-Frame 0,80: `leftoverHoldBlocks` lässt Baptize 0,80 durch, MED-Gatter sieht den Median über Floor.

## Was 2.1.66 wirklich ändert

1. **`leftoverBoxHashNeighbors`.** cx/cy ±1, Lookup nimmt den jüngsten gültigen Nachbarn. Ferne Bins (`9.9.9.9`) bleiben leer. Breite/Höhe fest.
2. **Leerer Frame: Prune nach TTL, kein Wipe.** UUID-Hold stirbt (Track tot), Hash überlebt den Dropout.
3. **`guestOrderKeeps` 8 s.** Unbekannte ID ist Gast n+1. Overlay nicht mehr zwei „Gast 1“.
4. **`printMAD` / `printMADBlocks`.** ≥ 3 Samples. Peak−Median oder MAD > 0,04 → Overlay `MAD`, keine Taufe.
5. **VERSION = Models = MARKETING_VERSION 2.1.66** (Build 92). 2.1.65 war Docs plus Placeholder.

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`.

Helios 1.5.50: Phase blockt Scharf, Homographie ohne Laptop-Fallback, Display-Link-Cap aus Velocity. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
