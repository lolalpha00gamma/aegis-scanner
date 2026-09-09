# Analyse Helios 1.6.100 + Aegis 2.1.247 — 2026-09-09

Kein Merge von `bugfix`. Predict bleibt 0. Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp + palmWidth sitzen. Predict bleibt 0.
2. analogClosed Mix lerp't Closedness×z×Kontakt. Eine Achse für Faust/Schnabel/Pinzette.
3. ROI Scale 1,6 + Full/2 sitzt. Body war immer skip @ 8 Hz. Pass 49: jedes 8. Tick.
4. Zwei Apps, eine Kamera. Mutex sample-fresh. Ohne CameraBroker zwei Vision, zwei TCC.
5. `bugfix` ~80 Versionen hinter main — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. leftoverPick twinPair Live (2.1.246) + Gallery-Fallback. Ohne Vec → Hard-Veto. Pass 49: nil.
2. liveRoi Full/8 + skipDetect/4 = Walk-in 1 s. Pass 49: both every 2.
3. leftoverHoldsTrack yawAbs: nil bewusst. LiveCapture `@MainActor`. Gallery linear. CameraBroker fehlt. CGImage-Kopie.

## Ineffizienzen (beide)

- Aegis: CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`. Helios sitzt auf PixelBuffer.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.

## Bugfix-Protokoll (Pass 49)

Pass 1 — Befund: leftoverPick Gallery-Fallback ohne Live-Print. Fix: twinPair nil.

Pass 2 — Walk-in: ROI Full/8 + skipDetect/4. Fix: both every 2.

Pass 3 — Helios: Body @ 8 Hz immer skip. Fix: jedes 8. Tick.

## Nächster sinnvoller Code-Pass

1. CameraBroker Spec `docs/CameraBroker.md` umsetzen (XPC+IOSurface). P0.
2. VNImageRequestHandler(cvPixelBuffer:) Aegis LiveCapture.
3. LiveCapture off MainActor.
4. Adaptive skipDetect.
5. HNSW Gallery.

P0: CameraBroker. Branch `bugfix` nicht mergen.

# Analyse Helios 1.6.99 + Aegis 2.1.246 — 2026-09-09

Kein Merge von `bugfix`. Predict bleibt 0. Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp + palmWidth sitzen. Predict bleibt 0.
2. analogClosed Mix lerp't Closedness×z×Kontakt. Eine Achse für Faust/Schnabel/Pinzette.
3. ROI Scale 1,6 + Full/2 (war /4). Zweite Palme 250 ms.
4. Zwei Apps, eine Kamera. Mutex sample-fresh. Ohne CameraBroker zwei Vision, zwei TCC.
5. `bugfix` ~80 Versionen hinter main — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. leftoverPick twinPair war Gallery-Centroid. Ada+Bob Live 0,40, Gallery-Schwester 0,90 → Hard-Veto. Pass 48: max paarweise Live-Print.
2. leftoverPrintYawMerge printCommitted sitzt (2.1.245). leftoverHoldsTrack yawAbs: nil bewusst.
3. LiveCapture `@MainActor`. skipDetect every 4. Gallery linear. CameraBroker fehlt. CGImage-Kopie.

## Ineffizienzen (beide)

- Aegis: CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`. Helios sitzt auf PixelBuffer.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.

## Bugfix-Protokoll (Pass 48)

Pass 1 — Befund: leftoverPick twinPair Gallery-Paar blockt Ada+Bob. Fix: Live-Print max pairwise.

Pass 2 — Helios: Scale 1,6 + Full/4 = 500 ms. Fix: every 2.

## Nächster sinnvoller Code-Pass

1. CameraBroker Spezifikation (eine Datei, kein Feature-Fleisch). P0.
2. VNImageRequestHandler(cvPixelBuffer:) Aegis LiveCapture.
3. LiveCapture off MainActor.
4. Adaptive skipDetect.
5. HNSW Gallery.

P0: CameraBroker. Branch `bugfix` nicht mergen.
