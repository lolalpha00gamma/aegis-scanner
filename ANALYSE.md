# Helios + Aegis — Analyse 2026-09-04 (2.1.75)

Helios **1.5.59** (Build 79). Aegis **2.1.75 alpha** (Build 101). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.73/74 noch sprangen

2.1.73 hat Kalman-Streak, Lookaway-Hold, Still, UNBEKANNT, TAUFEN?, TWIN 0,93 verdrahtet. 2.1.74 Testdaten in der App. Fünf Löcher blieben:

1. **WEG auf old.id, dann Filter liveIds.** leftoverPending[ghost] wurde gestrippt. Overlay zeigte nichts, Live-Kiste ohne Namen.
2. **Lookaway las Ghost-Yaw.** Blick zurück: Freeze blieb. Blick weg: Freeze zu spät.
3. **UNBEKANNT rief leftoverClearStreak.** Re-Entry = Gast n+1. Open-Set-Band wirkte tot.
4. **Taufe wischte Streak.** Blink → 0,45 s + Adopt-Need, Name weg.
5. **TWIN 0,90 ohne Fragezeichen.** Weich und hart dieselbe Label — Overlay log.

## Was 2.1.75 wirklich ändert

1. **`leftoverLookawayPin`.** WEG auf die nächste Live-Kiste. EMA freeze.
2. **`leftoverLookawayYawOf`.** Live-Yaw sticht Ghost.
3. **`leftoverUnknownKeepsStreak`.** Open-Set hält Streak, kein Gast-Index.
4. **`leftoverStreakKeepsLive`.** Nach Taufe Streak auf der UUID. Blink re-adoptiert.
5. **`leftoverTwinPairLabel` TWIN? 0,90.** Hart bleibt TWIN 0,93. VERSION = Models = MARKETING_VERSION 2.1.75 (Build 101).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge, Burst-5 Pref, Dropout-TTL Pref.

Helios 1.5.59: 8 fps interpoliert mit Lock-Hand, Reconnect-Pool in actorMapped, pinchActor im Slot, Palm-Reach skippt Lock. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
