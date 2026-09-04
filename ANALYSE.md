# Helios + Aegis — Analyse 2026-09-04

Helios **1.5.49** (Build 69). Aegis **2.1.64 alpha** (Build 91). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26.

## Warum Namen sprangen

Matching ist nicht „Cosine > 0,78“. Live-ReID ist:

```
Box → NMS → Print (manchmal skip) → Geo → leftover-Assign
    → Majority 3 → Name-Lock 8 s → Ghost-TTL → Open-Set Floor
```

Widersprachen sich zwei Stufen, taufte die dritte trotzdem. Twin 0,91 still Anna, Ghost 0,64 stahl UUID, Poster ohne Blink. `MatchMath` war ein Katalog von Pflastern; Tests grün, Overlay eine Version später.

2.1.63 hat leftoverTransfersId und Gast 1/2. leftoverHold hing an der UUID — Dropout warf Hold. Streak-Since lebte nur im RAM. Gast hätte nach 8 s leftover still in gallery.json landen können. Ampel nur Farbe. Continuity-Nacht ohne Hinweis.

## Was 2.1.64 wirklich ändert

1. **`leftoverHold` keyed by Box-Hash.** UUID stirbt beim Dropout, die Kiste bleibt. Lookup TTL = leftoverAdoptSec (1,2 s). Prune am Tick.
2. **`leftoverStreakSince` in gallery.json.** Schema 4. Restore lädt die Uhr, nicht bei 0 neu.
3. **Gast nie silent.** `guestPersistWrites` nur nach Tauf-Button. `guestPersistSilent` immer false.
4. **Farbenblind Ampel.** Grün ●, Amber ◐, Rot ✕ — nicht nur Hue. VoiceOver `solid`/`half`/`cross`.
5. **CLAHE-Banner.** Continuity + dunkle Schärfe → Overlay `CLAHE`. Ausgleich selbst nächste.
6. **`liveROI` Math.** Pad + Clamp. Draht in den Detector nächste.

Was Masse noch bringen würde:

- Helios Frame-Pump, eine TCC.
- CLAHE wirklich auf den PixelBuffer, nicht nur Banner.
- Brille-Slot, Drop-in `.mlmodel`, DBSCAN vor Merge, Zwei-Kamera-Live.
- VoiceOver spricht den Namen, nicht nur Lampen-Pattern.
- Print-MAD > 0,04 wirft Spike.
- Identity-Graph als Soft-Prior, nie Taufe.

Helios 1.5.49: Tip-Z verdrahtet, Display-Link, KALIB HIER, Homographie-Warmup, Per-App Gain. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
