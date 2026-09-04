# Helios + Aegis — Analyse 2026-09-04 (2.1.67)

Helios **1.5.51** (Build 71). Aegis **2.1.67 alpha** (Build 93). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

CI war seit **2.1.26** rot: `swiftc` für MatchMathTests ohne `Models.swift` → `FaceBox`/`Point2` unbekannt. Kein DMG nach 2.1.25. Nachtrag nimmt Models in den Compile.

## Warum Namen nach 2.1.66 noch sprangen

## Warum Namen nach 2.1.66 noch sprangen

2.1.66 hat Nachbar-Hash (cx/cy), Hash-Prune statt Wipe, Gast n+1, Print-MAD wirklich verdrahtet. Vier Löcher blieben:

1. **Leftover nach Dropout tot.** Leerer Frame macht `faces.removeAll`. Nächster Frame: `previous` leer, `leftoverPinned` leer. Hash-Hold lag in der Tabelle und niemand las sie. Ghosts gingen nur in `pinByPrint` (Floor 0,80). Genuine 0,64–0,79 wurde Gast.
2. **Größe tötet Hash.** Neighbors nur cx/cy ±1. Box-Breite 0,15→0,20 wechselt Bin. Person lehnt sich vor: Hold tot.
3. **`leftoverTransfersId` ignoriert Hold.** Pick lässt Baptize 0,80 durch (Kiste halten). Transfer stahl die UUID bei 0,82 nach Hold 0,64. printMAD braucht ≥ 3 Samples — Trail war UUID-keyed und nach Dropout leer.
4. **Adopt 1,2 s nach jedem Miss.** Streak-Wipe. Hash-Hold bedeutete „die 1,2 s waren schon da“. Trotzdem neu warten → Overlay Gast, dann Sprung.

## Was 2.1.67 wirklich ändert

1. **Ghost-Pool.** `leftoverPinned` nimmt `liveGhosts` plus previous. Named aus matches, nicht nur live previous.
2. **`leftoverBoxHashNeighbors` w/h ±1.** Größe-Jitter hält Hold. Ferne Bins (`9.9.9.9`) bleiben leer.
3. **`leftoverBaptizeSpike`.** 0,80 nach 0,64 = Twin, kein UUID-Steal. 0,80 nach 0,80 bleibt Taufe. `leftoverTransfersId` nimmt holdPrev + Trail.
4. **`leftoverHoldTrailByHash`.** Trail überlebt leere Frames. Put seeded von Nachbarn.
5. **`leftoverAdoptReady(holdPrev:)`.** Hash-Hold: 1 Frame reicht, nicht nochmal 1,2 s.
6. VERSION = Models = MARKETING_VERSION 2.1.67 (Build 93).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`.

Helios 1.5.51: Clamshell lebt, Legacy-dest, destClamp, Game-Exempt. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
