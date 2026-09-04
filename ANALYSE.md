# Helios + Aegis — Analyse 2026-09-04

Helios **1.5.47** (Build 67). Aegis **2.1.62 alpha** (Build 89). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26 / macos-14.

## Warum Namen sprangen

Matching ist nicht „Cosine > 0,78“. Live-ReID ist:

```
Box → NMS → Print (manchmal skip) → Geo → leftover-Assign
    → Majority 3 → Name-Lock 8 s → Ghost-TTL → Open-Set Floor
```

Widersprachen sich zwei Stufen, taufte die dritte trotzdem. Twin 0,91 still Anna, Ghost 0,64 stahl UUID, Poster ohne Blink. `MatchMath` war ein Katalog von Pflastern; Tests grün, Overlay eine Version später.

## Was 2.1.62 wirklich ändert

1. **Konflikt-Tick.** BOX / PRINT / GEO / LOCK müssen einig sein, sonst keine Taufe. Geo votet erst ab Mix 42 — 20 % Maße kippen keinen 90 % Print. Overlay `KONFLIKT` auf der Live-Kiste, nicht auf der toten leftover-UUID (die wurde nach dem Tick weggefiltert).
2. **leftover weicht Live.** Kiste schon auf Anna → leftover tauft sie nicht um. `leftoverYieldsToLive`.
3. **Centroid je Kamera.** Built-in-Mean auf Continuity lügt. Cache-Key `…|builtin` / `…|continuity`.
4. **Burst schärferes Ref.** `enrollmentBurstDup` droppte das schärfere Incoming — `enrollBurstReplace` tauscht.
5. **Live-FAR** im Floor-Hint (`FAR n%`) aus Gast/KONFLIKT vs. Galerie.
6. **Schema 3.** Restore warnt bei gallery.json < 3. Gast-Helpers (`guestPersistId` / `Keeps`) sitzen; Gast als Identity-Write nach leftoverAdoptSec ist nächste, nicht stilles Anlegen.

`matchLive` nilt `decidedId` bei Konflikt. leftoverPick gibt nil zurück, wenn die Stimmen uneinig sind.

## Was Masse noch bringen würde

- Gast als persistente Klasse nach 8 s leftover (Schema 3 Write).
- Helios Frame-Pump, eine TCC.
- Brille-Slot, Live-ROI Crop, CLAHE-Banner.
- Drop-in `.mlmodel`, DBSCAN vor Merge, Zwei-Kamera-Live.
- leftoverStreakSince in gallery.json.
- VoiceOver + farbenblind Ampel.

Helios 1.5.47: Phase-Chip, 120 ms Blend, Game-Mode, Continuity-Reconnect. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
