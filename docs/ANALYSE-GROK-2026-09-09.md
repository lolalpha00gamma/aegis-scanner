# Analyse Helios 1.6.98 + Aegis 2.1.245 — 2026-09-09

Kein Merge von `bugfix`. Predict bleibt 0. Kein neues *Need(dt). Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp/Coast + palmWidth-Lerp sitzen. Samples 125 ms. Predict bleibt 0.
2. analogClosed Mix lerp't Closedness×z×Kontakt. Faust/Schnabel/Pinzette teilen eine Achse.
3. ROI Miss-1 + Full/4, Scale 1,6 Continuity / 3 Built-in. Hart-Schwelle 0,10 s.
4. Zwei Apps, eine Kamera. Mutex Stamp+Lock sample-fresh. Ohne CameraBroker zwei Vision, zwei TCC.
5. `bugfix` (Helios 1.6.15 / Aegis 2.1.15) ~80 Versionen hinter main — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. Twin Rank: leftoverPickSameShot + leftoverAmbiguousBlocks facesInFrame (2.1.244). pairCosine bleibt Gallery-Centroid.
2. leftoverPrintYawMerge printedIds: printCommitted + Remint (2.1.245). leftoverHoldsTrack yawAbs: nil bewusst: Overlay-Hold 0,64 auf Profil.
3. leftoverLastHash nach Coast-Wipe. leftoverOccupiedOthers liest LastHash roh — GhostDrop nur Merge-Pfad.
4. LiveCapture `@MainActor`. Detect+Print+Overlay ein Tick. skipDetect every 4. Gallery linear. CameraBroker fehlt.
5. leftoverScore Twin-Penalty uniform — leftoverPickArgmax rankt Roh-Cosine, Penalty ändert Tie nicht.

## Ineffizienzen (beide)

- CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.
- Semantische Duplikate: VORSCHLAEGE-Dateien listen dieselben 30 Ideen jeder Pass neu.

## Bugfix-Protokoll (Pass 47)

Pass 1 — Befund: leftoverPrintYawMerge printedIds:[] no-op, printCommitted ohne Remint. Fix: printCommitted + leftoverHoldRemintDrop.

Pass 2 — Befund: leftoverLastHash nach Coast-Wipe stale, OccupiedOthers Ghost. Fix: Filter live ∪ Coast ∪ leftover.

Pass 3 — Befund: Helios Stamp+Lock Date() ohne Sample. Fix: cameraMutexStampFresh Write.

Pass 4 — leftoverHoldsTrack yawAbs:nil bewusst. Nicht verdrahten.

## Nächster sinnvoller Code-Pass

1. CameraBroker Spezifikation (eine Datei, kein Feature-Fleisch). P0.
2. leftoverOccupiedOthers leftoverOccupiedGhostDrop.
3. LiveCapture off MainActor.
4. visionRoiScale lerp 1,6↔3.
5. HNSW Gallery.

P0: CameraBroker. Branch `bugfix` nicht mergen.
