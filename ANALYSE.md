# Helios + Aegis — Analyse 2026-09-04 (2.1.80)

Helios **1.5.64** (Build 84). Aegis **2.1.80 alpha** (Build 106). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.79 noch sprangen / tot wirkten

2.1.79 hat Overlay-Namen am Ghost, Ghost-TTL 4 s, Profil-Yaw 0,45, emptyKeeps. Drei Löcher blieben:

1. **`keepBoxes = used.union(dropped)`.** Erster leerer Frame: dropped = previous, Kalman bleibt. `faces.removeAll`. Zweiter leerer Frame: previous = [], dropped = [], keepBoxes = [] → Kalman tot. Nächster Live-Frame hasht Roh-Box → Gast n+1.
2. **`leftoverHoldSurvive(emptyKeeps: true)` ohne Zeit.** Tasche im Dunkeln hielt Hold ewig. Latch 4 s fehlte am empty-Pfad.
3. **`leftoverPending = [:]` am Start von jedem Frame.** leftoverEmptyKeepsOverlay kam zu spät. Overlay-Chip weg, obwohl Ghost lebte.

## Was 2.1.80 wirklich ändert

1. **`leftoverKeepBoxes(used, dropped, ghosts, hold)`.** Zweiter leerer Frame hält Kalman am Ghost.
2. **`leftoverLatchKeeps(emptyFor:)` + `leftoverEmptySince`.** emptyKeeps / Overlay / Streak 4 s, dann Wipe.
3. **leftoverPending bleibt** solange Latch. Wipe erst nach Latch oder Live.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.80 (Build 106).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank, Quality-weighted Centroid, Kalman-Predict (`cx+=vx·dt`) auf leerem Frame.

Helios 1.5.64: Warp Smooth, letzter Tip, Engine-Latch. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
