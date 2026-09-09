# Analyse Helios 1.6.97 + Aegis 2.1.244 — 2026-09-09

Kein Merge von `bugfix`. Predict bleibt 0. Kein neues *Need(dt). Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp/Coast + palmWidth-Cap sitzen. Samples 125 ms. Predict bleibt 0.
2. analogClosed Mix lerp't Closedness×z×Kontakt. Faust/Schnabel/Pinzette teilen eine Achse.
3. ROI Miss-1 + Full/4, Scale 3. Zweite Hand außerhalb des Crops erst nach 500 ms.
4. Zwei Apps, eine Kamera. Mutex+TERM. Ohne CameraBroker zwei Vision, zwei TCC.
5. `bugfix` (Helios 1.6.15 / Aegis 2.1.15) ~80 Versionen hinter main — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. Twin Rank: leftoverTwinSameShot war nur HardVeto. leftoverAmbiguousBlocks ließ Schärfe Ada wählen. Pass 46: leftoverPickSameShot + leftoverAmbiguousBlocks facesInFrame. pairCosine bleibt Gallery-Centroid, nicht zwei Live-Gesichter.
2. leftoverPrintYawMerge `printedIds: []` bewusst no-op. Stamp auf Commit. skipPrints-Yaw stale, nicht falsch.
3. leftoverHoldsTrack `yawAbs: nil` bewusst: Overlay-Hold 0,64 auf Profil. leftoverPick hat Floor.
4. LiveCapture `@MainActor`. Detect+Print+Overlay ein Tick. skipDetect every 4. Gallery linear. CameraBroker fehlt.
5. leftoverScore Twin-Penalty uniform — leftoverPickArgmax rankt Roh-Cosine, Penalty ändert Tie nicht.

## Ineffizienzen (beide)

- CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.
- Semantische Duplikate: VORSCHLAEGE-Dateien listen dieselben 30 Ideen jeder Pass neu.

## Bugfix-Protokoll (Pass 46)

Pass 1 — Befund: leftoverAmbiguousBlocks Schärfe-Pick = Rank-Loch bei zwei Live-Kisten. Fix: leftoverPickSameShot.

Pass 2 — Befund: pinchAnalog `if k>0` Mix-Switch = Mini-Kontakt-Cliff. Fix: Mix lerp't.

Pass 3 — Befund: leftoverPrintYawMerge printedIds:[] und leftoverHoldsTrack yawAbs:nil bewusst. Nicht verdrahten.

## Nächster sinnvoller Code-Pass

1. CameraBroker Spezifikation (eine Datei, kein Feature-Fleisch). P0.
2. leftoverPrintYawMerge printedIds: printCommitted, falls Stamp-Pfad miss.
3. LiveCapture off MainActor.
4. Overlay palmWidth Lerp prev→next.
5. HNSW Gallery.

P0: CameraBroker. Branch `bugfix` nicht mergen.
