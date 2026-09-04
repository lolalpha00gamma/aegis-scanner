# Helios + Aegis — Analyse 2026-09-04

Helios **1.5.48** (Build 68). Aegis **2.1.63 alpha** (Build 90). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26.

## Warum Namen sprangen

Matching ist nicht „Cosine > 0,78“. Live-ReID ist:

```
Box → NMS → Print (manchmal skip) → Geo → leftover-Assign
    → Majority 3 → Name-Lock 8 s → Ghost-TTL → Open-Set Floor
```

Widersprachen sich zwei Stufen, taufte die dritte trotzdem. Twin 0,91 still Anna, Ghost 0,64 stahl UUID, Poster ohne Blink. `MatchMath` war ein Katalog von Pflastern; Tests grün, Overlay eine Version später.

2.1.62 hat Konflikt-Tick und leftoverYieldsToLive. leftoverPick blieb bei 0,64 erlaubt und `LibraryStore` kopierte danach immer `old.id` plus PrintVec. Overlay-Pflaster `Gast 1` hing an der gestohlenen UUID — zwei Ghosts beide „Gast 1“, Name-Lock weiter Anna.

## Was 2.1.63 wirklich ändert

1. **`leftoverTransfersId`.** UUID, Track-ID, PrintVec nur bei Baptize 0,80. 0,64 hält leftoverHold, tauft nicht.
2. **Gast 1 / Gast 2.** `guestOrder` in der Store-Schicht, `guestName` liest nur. Overlay zeigt Gast bevor pinned Owner.
3. **CI macos-26.** Tests vor xcodebuild, arm64, Signing wie Helios. macos-14 hat den SDK-Stand der Math nicht.

Was Masse noch bringen würde:

- Gast als persistente Klasse nur nach Tauf-Button, nicht 8 s silent.
- Helios Frame-Pump, eine TCC.
- Brille-Slot, Live-ROI Crop, CLAHE-Banner.
- Drop-in `.mlmodel`, DBSCAN vor Merge, Zwei-Kamera-Live.
- leftoverStreakSince in gallery.json.
- VoiceOver + farbenblind Ampel.
- leftoverHold keyed by Box-Hash über Dropout.

Helios 1.5.48: Phase-Gatter, Homographie je Display, Klick-Haptik. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
