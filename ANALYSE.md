# Helios + Aegis — Analyse 2026-09-04 (2.1.79)

Helios **1.5.63** (Build 83). Aegis **2.1.79 alpha** (Build 105). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.78 noch sprangen / tot wirkten

2.1.78 hat leeren-Frame-Streak, Yaw-Floor, Same-shot Twin 0,88. Drei Löcher blieben:

1. **`leftoverPending = [:]` auf jedem leeren Frame.** Streak/Kalman blieben, Overlay-Namen nicht. Ghost-Kiste ohne Chip = tot.
2. **`liveGhostHold` 1,6 s bei 8 fps.** Continuity-AE 2–3 s: Ghosts tot, faces schon gewischt, leftoverPool leer. Nächster Frame = Gast n+1.
3. **Profil-Floor an Lookaway 0,28 rad (~16°).** Leichte Drehung 0,62 scharf wurde tot, obwohl noch frontal.

## Was 2.1.79 wirklich ändert

1. **`leftoverEmptyKeepsOverlay`.** leftoverPending / liveHeldIds bleiben. Auswahl bleibt.
2. **`leftoverLatch` 4 s.** dropoutTTL / liveGhostHold 8 fps = 4 s, 24 fps 1,2 s.
3. **`leftoverPrintProfileYaw` 0,45.** Floor 0,70 erst ab ~26°, nicht 16°.
4. **`leftoverHoldSurvive(emptyKeeps:)`.** Leerer keep-Set hält Hold.
5. VERSION = Models = MARKETING_VERSION 2.1.79 (Build 105).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, temporal print bank, Quality-weighted Centroid.

Helios 1.5.63: ghostHands Latch 4 s, Steal skippt Ghosts, Phantom-Tip DIP. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
