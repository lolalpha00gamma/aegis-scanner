# Analyse Helios 1.6.102 + Aegis 2.1.251 — 2026-09-10 (Pass 54)

Run 267 Compile tot: `$0` in `{ c in c.index == $0.index }`. unknownCentroid muss Roh-Cosine, nicht leftoverHoldSmooth.

200 Repos (Detect→Align 112×112→ArcFace/FaceNet/dlib/SFace): Aegis FacePrint. Kein Gewicht dieser Pass.

# Analyse Helios 1.6.102 + Aegis 2.1.251 — 2026-09-10 (Pass 53)


2.1.250 CI tot: Swift 6 `contains` + split-Args + Test-lets. P12 `-t cert` ohne Key. Xcode 16.4 statt 26.3. leftoverPick session min() über alle Gesichter.

200 Repos (Detect→Align 112×112→ArcFace/FaceNet/dlib/SFace): Aegis FacePrint. Kein Gewicht dieser Pass.

# Analyse Helios 1.6.102 + Aegis 2.1.250 — 2026-09-10 (Pass 52)


Kein Merge von `bugfix`. Predict bleibt 0. Kein neues leftover*-Flag.

## Aegis vs. 200 FR-Repos (Detect → Align → Embed → Cosine)

Die Liste (`face-recognition-repos-200.md`) teilt eine Pipeline: 5-Punkt Similarity → 112×112 → trainierter Embedder → L2-Norm → ein Cosine.

Aegis bleibt auf `VNGenerateFacePrintRequest`. Das ist das Personen-Album, kein Angular-Margin-Recognizer. Drei Lücken, die FaceUnlock/glance/Immich schließen:

1. **Embedding.** FacePrint statt ArcFace/SFace. Ohne `printRevision`-Bump und CoreML-Weights kein Tausch in diesem Pass. buffalo_l = InsightFace non-commercial. Kommerziell: YuNet+SFace (Apache-2).
2. **Align.** Vision richtet intern aus. Warped 256px Crops haben FacePrint schon einmal zum Jacket-Print gemacht — deshalb kein 5-Punkt-Warp vor FacePrint.
3. **Match.** Ein Cosine plus kalibrierter Operating Point. Geometry-Veto gegen den Embedder bleibt Aegis-Policy (`lookOf`), nicht NIST-1:N.

P0 bleibt CameraBroker. P1 Embedder = SFace/ArcFace CoreML, 5-Punkt 112×112, LFW in `bench/` gegen FacePrint.

## Warum Identitäten nach 2.1.249 weiter rutschten

1. leftoverCaptureHistOf Box-first (≥3). Burst-3 Flash senkt Median. Pass 52: leftover wenn länger.
2. Skip-Summary / Hold-Chip / IoU-Adopt Tests-only. Pass 52 verdrahtet HUD + Overlay.
3. DMG ad-hoc. Secrets da, Workflow las sie nicht. Pass 52: `macos/ci-sign.sh`.

## Bugfix-Protokoll (Pass 52)

Pass 1 — Burst-3 Flash vor Cap-8 leftover. Fix: leftoverCaptureHistOf l.count > b.count.

Pass 2 — HUD tot. Fix: leftoverPrintSkipSummary + leftoverFaceTrackHoldChip + leftoverNameLockAdoptChip.

Pass 3 — Ad-hoc DMG. Fix: Developer ID Import, Notarize, ein macos-15 Runner.

## Nächster sinnvoller Code-Pass

1. CameraBroker XPC + IOSurface. P0.
2. FaceEmbedder Protocol + SFace/ArcFace CoreML, printRevision.
3. VNImageRequestHandler(cvPixelBuffer:).
4. leftoverHoldsTrack yawAbs live (bewusst nil).
5. HNSW Gallery.

# Analyse Helios 1.6.102 + Aegis 2.1.249 — 2026-09-09 (Pass 51)


Kein Merge von `bugfix`. Predict bleibt 0. Kein neues *Need(dt). Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp + palmWidth + Body/8 + Closedness-held sitzen. Predict bleibt 0.
2. analogClosed Mix + held freeze (Pass 50). Pass 51: Start/Hold Grab dieselbe `closedSmooth`.
3. Deadman hart 0,004. Pass 51: `palmDeadZone(dt)` 8 Hz ×1,55.
4. Ampel-Dwell roh 40 px. Pass 51: `magnet()` snapped.
5. Zwei Apps, eine Kamera. Ohne CameraBroker zwei Vision, zwei TCC.
6. `bugfix` (~85 Versionen hinter main) — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. leftoverPick twinPair nil ohne Live-Paar (2.1.247).
2. leftoverGhostAspectLock hypot-Aspect (2.1.248). Trail-Hash live. roiEvery aus dt.
3. leftoverCaptureHistByHash war Burst-Kopie. Pass 51: Cap 8 Put, leftoverPick Lookup.
4. leftoverHoldsTrack yawAbs: nil bewusst. leftoverPrintBudgetYawDelta Of je UUID.
5. leftoverCaptureHistOf Box-first (≥3) bewusst. Flash nach 3 Frames bleibt ein Loch.
6. LiveCapture `@MainActor`. Gallery linear. CameraBroker fehlt. CGImage-Kopie.

## Ineffizienzen (beide)

- Aegis: CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.
- Aegis Gallery linear leftoverHoldXMatch.

## Bugfix-Protokoll (Pass 51)

Pass 1 — Helios Deadman nie clutcht. Fix: palmDeadmanStill × palmDeadZone(dt).

Pass 2 — Start/Hold roh nach analog-Freeze. Fix: pinchStartsGrab/pinchHoldsGrab closedSmooth.

Pass 3 — Ampel-Dwell 40 px Reset. Fix: magnet() chromeDwellAt.

Pass 4 — Capture-Hist Burst pollutet Median. Fix: leftoverCaptureHistPut Cap 8 + leftoverPick Lookup.

## Nächster sinnvoller Code-Pass

1. CameraBroker XPC + IOSurface (Spec `docs/CameraBroker.md`). P0.
2. VNImageRequestHandler(cvPixelBuffer:) Aegis LiveCapture.
3. leftoverCaptureHistOf leftover wenn länger als Burst.
4. leftoverPrintSkipSummary HUD.
5. HNSW Gallery.
6. Overlay CAMetalLayer.

# Analyse Helios 1.6.101 + Aegis 2.1.248 — 2026-09-09 (Pass 50)

Kein Merge von `bugfix`. Predict bleibt 0. Kein neues *Need(dt). Kein neues leftover*-Flag.

## Helios — warum Gesten schlecht wirken

1. Continuity ~8 Hz. HUD-Lerp + palmWidth + Body/8 sitzen. Predict bleibt 0.
2. analogClosed Mix lerp't Closedness×z×Kontakt. Pass 50: Closedness **held freeze** — 8-Hz-Drop öffnet den Zug nicht.
3. ROI Scale lerp (Pass 50) statt Hart 1,6/3. Full every aus dt: 250 ms Wand bei 8 und 24 Hz.
4. 720@24 konnte 1080@15 nicht gewinnen (Cold-Start −90). Pass 50: `cameraFormatPromoted` +320 wenn gemessen ≥12 und Format ≥12. 1080@8 tot.
5. Zwei Apps, eine Kamera. Mutex sample-fresh. Ohne CameraBroker zwei Vision, zwei TCC.
6. `bugfix` (~85 Versionen hinter main) — Merge wäre ein Wipe.

## Aegis — warum Identitäten schlecht wirken

1. leftoverPick twinPair nil ohne Live-Paar (2.1.247). Ada+Bob ohne Prints leftover darf.
2. leftoverGhostAspectLock linear W/H dehnte die Box. Pass 50: hypot-Aspect, last Ratio, Size-Blend.
3. leftoverTrailWriteHash tot — leftoverLiveHash rief Hold-Hash. Pass 50: Trail-Hash live (Alias).
4. ROI/skipDetect every 2 @ 24 fps = Hitch. Pass 50: every aus dt (8 Hz /2, 24 Hz /4).
5. leftoverHoldsTrack yawAbs: nil bewusst. leftoverPrintBudgetYawDelta **Of je UUID** — global würde Ada still mit Twin-Drehung mitdrucken.
6. leftoverScore Twin-Penalty ist frame-global (ein twinPair) — Argmax ändert sich nicht. Kein Bug.
7. LiveCapture `@MainActor`. Gallery linear. CameraBroker fehlt. CGImage-Kopie.

## Ineffizienzen (beide)

- Aegis: CGImage-Kopie statt `VNImageRequestHandler(cvPixelBuffer:)`. Helios sitzt auf PixelBuffer.
- SwiftUI Overlay-Rows statt Metal.
- Mutex-Datei statt XPC/IOSurface.
- Aegis Gallery linear leftoverHoldXMatch, skaliert nicht über Haushalts-Größe.

## Bugfix-Protokoll (Pass 50)

Pass 1 — Helios analog Hold droppt 8 Hz. Fix: pinchClosednessSmooth held.

Pass 2 — Scale Hart-Cliff 12 fps. Fix: visionRoiScale lerp.

Pass 3 — 720@24 nie 1080@15. Fix: cameraFormatPromoted in bestFormat.

Pass 4 — Full-ROI 83 ms @ 24 fps. Fix: every aus dt, 250 ms Wand.

Pass 5 — Ghost-Box Stretch. Fix: leftoverGhostAspectLock hypot-Aspect.

Pass 6 — Trail-Hash tot. Fix: leftoverTrailWriteHash leftoverLiveHash.

Pass 7 — Detect 12 Hz @ 24 fps. Fix: roiEvery aus dt.

## Nächster sinnvoller Code-Pass

1. CameraBroker XPC + IOSurface (Spec `docs/CameraBroker.md`). P0.
2. VNImageRequestHandler(cvPixelBuffer:) Aegis LiveCapture.
3. LiveCapture off MainActor.
4. HNSW Gallery.
5. Wrist-Vel Pinch-Veto / Per-Finger 4-Tip-Gate.
6. Overlay CAMetalLayer.

P0: CameraBroker. Branch `bugfix` nicht mergen.

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
