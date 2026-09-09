# Analyse Helios 1.6.96 + Aegis 2.1.243 — 2026-09-09

Kein Merge von `bugfix`. Kein Version-Bump. Swift unangetastet (kein macOS-Compiler hier).

## Helios — warum Gesten schlecht wirken

1. Continuity liefert ~8 Hz. Relativer Zeiger, One-Euro, HUD-Lerp und Coast sind verdrahtet. Der Cursor coaste korrekt, fühlt sich aber nach Ruckeln an, weil Samples 125 ms auseinanderliegen. Predict bleibt absichtlich 0.
2. Pinch ist ein Skalar (`pinchClosednessSmooth`). Faust, Schnabel und echte Pinzette teilen dieselbe Achse. analogClosed Hysterese 0,58/0,48 hält den Hold, startet aber keinen Zug — gut. Fehlt: Per-Finger-Kontakt.
3. ROI: Miss-1 hält lastRoi, jedes 4. Tick Full. Zweite Hand außerhalb des Crops kommt erst nach 500 ms. Rand-Palme kann den Actor noch stehlen, wenn Full und Track gleichzeitig kommen.
4. Zwei Apps, eine Kamera. AE-Lock nach `startRunning` und Wake-Reassert sitzen. Sleep ohne Stop lässt die Session laufen — Format fällt auf Preset, nicht auf stored 540/360, wenn configureAndRun den falschen Pfad nimmt.
5. GestureEngine ist ~95 kB eine Datei. Call-Sites waren jahrelang tot (Tests grün, Tick ignorierte sie). Das Muster wiederholt sich: neue Helfer ohne Wiring.

## Aegis — warum Identitäten schlecht wirken

1. LiveCapture `@MainActor`. Detect, Print, Kalman, Overlay in einem Tick. skipDetect every 4 friert 3/4 Frames. Ghost Scale-Blend 0,25 weicht den Sprung, ersetzt keine echten Detects.
2. Nacht / 420v: Laplacian war 0. Jetzt `videoRange: continuity || live`. Baptize-Floor 0,06 nachts. Overlay hält 0,62 bei Sharp 0,14 — das ist Policy, kein Detect-Fehler. Nutzer liest „erkennt nicht“.
3. OpenSet Unsure-Chip sitzt. Twin Same-Shot 0,88 nur im HardVeto, nicht in leftoverPick Rank. Zwei Gesichter gleicher Cosine → Ada bleibt, obwohl Spread < 0,08.
4. Gallery linear. HashSolo vor x-Match rettet Restart einer Person. Haushalt + Profil-Bins explodiert in leftoverHoldXMatch.
5. leftoverHoldTrail nur RAM. Stop → weg. Nächster Start tauft neu.

## Ineffizienzen (beide)

- CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.
- Semantische Duplikate: VORSCHLAEGE-Dateien listen dieselben 30 Ideen jeder Pass neu.

## Bugfix-Protokoll (Review, kein Swift)

Pass 1 — Befund: keine neuen Crash-Bugs in den gelesenen Pfaden (Twin-Veto, printBudgetSkipIds, overlayRows Dedup, pinchClosednessSmooth, visionRoiHolds). Offene Löcher sind Wiring/Architektur, nicht Off-by-One.

Pass 2 — Befund: leftoverPrintBudgetYawDelta global ungenutzt; Of sitzt per UUID in printBudgetSkipIds. Kein Fix ohne Tick-Änderung.

Pass 3 — Befund: unverändert. Drei Review-Pässe ohne neuen Code-Bug. Loop für Swift-Fixes stoppt hier, weil ungebaute Patches die Call-Site-Geschichte wiederholen würden.

## Nächster sinnvoller Code-Pass (wenn macOS da ist)

1. Helios: `hudCoastCap` aus `palmWidth`. Klein, testbar.
2. Aegis: leftoverTwinSameShot in leftoverPick Rank.
3. Gemeinsam: CameraBroker Spezifikation (eine Datei, kein Feature-Fleisch).
