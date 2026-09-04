# Helios + Aegis — Analyse 2026-09-04 (2.1.69)

Helios **1.5.53** (Build 73). Aegis **2.1.69 alpha** (Build 95). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.68 noch sprangen

2.1.68 hat Cross-Slot-Hold, Hold-ohne-Steal, leftoverHoldSurvive, kleine-Box-Radius und Centroid-Gewicht wirklich verdrahtet. Vier Löcher blieben:

1. **Partial-Dropout ohne Ghost.** Zwei Gesichter, eines dreht weg: `liveGhosts` nur bei `found.isEmpty`. Frame 2 leftover pinned B noch aus `previous`. Frame 3 `previous = [A]`, B tot, leftoverHold-Filter wischt B. Overlay Gast, dann Sprung auf den Nachbarn.
2. **Enrolled auf leerem Frame nicht geistert.** `for old in previous where !enrolled.contains` — Anna enrolled, Kamera dunkel, leftoverHoldSurvive hält nur Ghost-IDs, Annas Hold weg. 1,2 s Gast-Fenster beim Wiederkommen.
3. **Blur 0,64 war Pick.** `leftoverPrintOk` ließ cosine ≥ 0,64 unabhängig von Schärfe durch. Unscharfes Profil stahl den Track.
4. **Hash auf der Roh-Kiste, Radius nur bei Bin 0/1.** Kalman wurde vor leftover auf `used` gefiltert. Mittlere Kiste (Bin 2) sprang weiter.

## Was 2.1.69 wirklich ändert

1. **`leftoverDropped`.** Jeder previous-nicht-used, **auch enrolled**, kommt in liveGhosts. Partial und leer dieselbe Saat.
2. **Kalman/Euro bleiben für Dropped.** Hash liest `leftoverHashBox` (Kalman, sonst last box).
3. **`leftoverBlurBlocks`.** Unter leftoverPrintSharp kein Hold-Pick. Baptize 0,80 trotz Blur.
4. **Nachbar-Radius 2 für w/h-Bin ≤ 2.** Schritt nach vorn hält Hold.
5. VERSION = Models = MARKETING_VERSION 2.1.69 (Build 95).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge.

Helios 1.5.53: Pointer-Steal-Freeze, destClampScreen, Pinch-Open 8 fps 1. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
