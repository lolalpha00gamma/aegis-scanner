# Helios + Aegis — Analyse 2026-09-04 (2.1.70)

Helios **1.5.54** (Build 74). Aegis **2.1.70 alpha** (Build 96). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`.

## Warum Namen nach 2.1.69 noch sprangen

2.1.69 hat leftoverDropped, Blur-Gate, Kalman-Hash, Radius 2 wirklich verdrahtet. Vier Löcher blieben:

1. **leftoverHoldSurvive nur bei leerem Frame.** Partial-Dropout (A bleibt, B dreht weg): Ghosts ja, Hold/Trail/Slot für B nur zufällig, weil Survive `hold.filter { ghosts }` auf Partial nie lief. Survive ohne `live:` hätte den Live-Hold von A gewischt — deshalb der Empty-only-Pfad. Stale-UUIDs wuchsen.
2. **livePrintTrail nur `used`.** Dropped enrolled verloren den Median-Trail. Wiederkommen = MAD tot, erster 0,82 tauft.
3. **printPin-Pfad ohne Capture-Jump.** IoU-Pfad hat holdStillSkip + AE-Lock. printPin blendet den neuen Print immer. Enrolled Gallery-Vektor nach Belichtungssprung.
4. **Ghost-TTL fest 1,2 s.** 8 fps = 9 Frames. Walker hinter Tür fällt durch. Tap-Name: leftover durfte in denselben 3 s taufen.

## Was 2.1.70 wirklich ändert

1. **`leftoverHoldSurvive(..., live:)`.** Keep = Ghosts ∪ Live. Partial und leer derselbe Pfad. Stale weg, Live-Hold bleibt.
2. **Trail/Euro/Kalman für Dropped.** `keepBoxes = used ∪ dropped`.
3. **`captureJumpBlocksPrint`.** Enrolled: AE-Sprung hält den alten Print. IoU und printPin.
4. **`dropoutTTL(dt)` / `liveGhostHold(dt)`.** 8 fps 1,6 s, 24 fps 1,2 s. Lookup/Prune dieselbe TTL.
5. **`tapNameLock` 3 s.** Anlegen/+ stempelt. leftoverTransfersId tot, Overlay hält. Chip `TAP ns`.
6. Hash-Lookup nach Dropout über Kalman-Box, nicht Roh-Kiste.
7. VERSION = Models = MARKETING_VERSION 2.1.70 (Build 96).

Was Masse noch bringen würde: Frame-Pump mit Helios, CLAHE auf den Buffer, Live-ROI Crop, Drop-in `.mlmodel`, DBSCAN vor Merge.

Helios 1.5.54: Steal blockt Actor, LOCK-Chip, Faust-Relock, destClampScreen nächster Screen. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen oder fortsetzen: nein. Nur `main`.
