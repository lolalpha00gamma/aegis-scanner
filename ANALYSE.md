# Helios + Aegis — Analyse 2026-09-04 (2.1.73)

Helios **1.5.57** (Build 77). Aegis **2.1.73 alpha** (Build 99). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.72 noch sprangen

2.1.72 hat Trail-Kalman, EMA-dt, Twin-Hard 0,92, Lookaway-Pick-nil, Ghost-Overlay verdrahtet. Fünf Löcher blieben:

1. **Streak-Box Roh.** leftoverAdvance IoU gegen adopted Roh-Box. Kalman-Jitter reset Streak. Walk tauft nach Dropout.
2. **Lookaway wischte Hold.** leftoverPick nil → leftoverClearStreak. Enrolled Yaw freeze war tot nach einem Tick. Kein WEG-Chip.
3. **TAUFEN? schrieb nicht.** Erster Tap nur Chip. `guestPersistWrites` tot. Zweiter Tap fehlte.
4. **Erste Begegnung 0,82 tauft sofort.** Ohne leftoverHold, ohne 0,45 s still. Vorbeigehen erbt den Namen.
5. **Open-Set 0,50–0,62 Gast-Index.** unknownCentroid nil, Clear, nächster Unbekannter = Gast n+1. Twin-Veto ohne Zahl.

## Was 2.1.73 wirklich ändert

1. **`leftoverStreakBoxWrite`.** Streak-IoU = Kalman, leftoverPick-IoU Kalman.
2. **`leftoverLookawayHolds` + `WEG`.** Lookaway freeze, Streak/Hold bleiben.
3. **`persistGuestTap`.** Zweiter Overlay-Tap tauft. `guestPersistWrites` sitzt.
4. **`leftoverBaptizeStillBlocks` 0,45 s.** Erste Begegnung still, Hold 0,64 skippt.
5. **`leftoverUnknownHard` UNBEKANNT. `leftoverTwinPairLabel` TWIN 0,93.** VERSION = Models = MARKETING_VERSION 2.1.73 (Build 99).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, Burst-5 Pref, Dropout-TTL Pref.

Helios 1.5.57: Reconnect-Palm, 24 fps Pool-leer Tick tot, Relativ destClamp, LOCK · DRAG, Tasche nicht vor Timeout. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
