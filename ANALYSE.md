# Helios + Aegis — Analyse 2026-09-04 (2.1.77)

Helios **1.5.61** (Build 81). Aegis **2.1.77 alpha** (Build 103). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.76 noch sprangen / tot wirkten

2.1.76 hat TWIN? Streak, 0,62 scharf kein Gast, WEG-Pin 0,12, WEG-Countdown. Vier Löcher blieben:

1. **`leftoverHoldLabel` ohne Schärfe.** Track hält bei 0,62 scharf, Overlay `nil` → UNBEKANNT / leer. Wirkt tot.
2. **WEG max-IoU ohne Floor.** leftoverLookawayPin 0,12, LibraryStore fallback auf beliebige Kiste. Fremder bekommt WEG, Name springt.
3. **leftoverClear nach einem Miss.** Twin-/Conflict-Tick = Gast n+1. Blink oder 8 fps Dropout tauft neu.
4. **Adopt 1,2 s bei 8 fps.** 10 Frames. Walker fällt durch. leftoverAdoptNeed(dt) ungenutzt.

## Was 2.1.77 wirklich ändert

1. **`leftoverHoldLabel(sharpness:)`.** 0,62 scharf = `gehalten 0,62`.
2. **`leftoverLookawayPinsStranger`.** WEG nur IoU ≥ 0,12, nicht der Nachbar.
3. **`leftoverMissAdvance` / `leftoverMissClears`.** 3 Miss, nicht 1 Tick.
4. **`leftoverAdoptNeedSec`.** 8 fps 0,6 s analog pinchOpenNeed.
5. **`leftoverTwinTint`.** TWIN? amber, TWIN hart rot.
6. VERSION = Models = MARKETING_VERSION 2.1.77 (Build 103).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, Burst-5 Pref, Dropout-TTL Pref, Yaw-bedingter Genuine-Floor.

Helios 1.5.61: preferredKeepsPool, pointerKeepInPool, stealHoldsPalm, slotBind 8 fps, pinchActor last-3, slotHue. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
