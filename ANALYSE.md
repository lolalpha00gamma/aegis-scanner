# Helios + Aegis — Analyse 2026-09-04 (2.1.76)

Helios **1.5.60** (Build 80). Aegis **2.1.76 alpha** (Build 102). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.75 noch sprangen

2.1.75 hat WEG auf Live-Kiste, Live-Yaw, UNBEKANNT-Streak, Tauf-Streak, TWIN? 0,90. Vier Löcher blieben:

1. **TWIN? 0,90 rief leftoverClearStreak.** Weich und hart dieselbe Clear. Overlay TWIN?, Streak 0 → Gast n+1.
2. **leftoverHoldsTrack ohne Schärfe.** leftoverPick ließ 0,62 scharf durch. HoldsTrack sah 0,62 tot → Streak weg, Gast.
3. **WEG-Pin Floor leftoverIoU 0,28.** Atmende Kiste 0,20 = kein Chip. Overlay leer trotz Freeze.
4. **WEG ohne Countdown.** Ghost-TTL unsichtbar, wirkt tot.

## Was 2.1.76 wirklich ändert

1. **`leftoverTwinKeepsStreak`.** TWIN? hält, TWIN 0,93 löscht.
2. **`leftoverHoldsTrack(sharpness:)`.** 0,62 scharf = Overlay, kein Gast.
3. **`leftoverLookawayIoU` 0,12.** WEG pinnt atmende Kisten. Fallback max-IoU.
4. **`leftoverLookawayLabel(until:now:)`.** `WEG in 0,8 s`. VERSION = Models = MARKETING_VERSION 2.1.76 (Build 102).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, Burst-5 Pref, Dropout-TTL Pref.

Helios 1.5.60: pinchActor nur Lock-Pool, 8 fps Bind + last-3, Pinch-Open geglättet, Slot S1/S2. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
