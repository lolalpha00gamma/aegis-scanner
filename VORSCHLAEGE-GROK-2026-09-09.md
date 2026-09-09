# Aegis Vorschläge — 2026-09-09 (Pass 35, 2.1.234)

Stand 2.1.234 alpha. leftoverPrintFloor/score/baptize abs yaw, Hold-Chip signed.

## Gelandet in 2.1.234

- leftoverPrintFloor / leftoverPrintOk abs (Profil L Floor 0,70)
- leftoverBaptizeQuality / Product abs (Profil L keine Taufe)
- leftoverScore / leftoverLiveWeight / centroidWeight abs (Yaw-Strafe L=R)
- leftoverHoldLabel signed yaw (¾L Chip)
- geoVetoBlocks / geoVetoYawSkipped abs

## Erweiterung (neu)

475. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
476. **VNImageRequestHandler(cvPixelBuffer:)** ohne 420f→CGImage. P1.
477. **Gallery Index Pose-Bin + Name.** leftoverPick nicht linear.
478. **HNSW Gallery.**
479. **LiveCapture off MainActor.** Mutex-Beat outputQueue.
480. **leftoverYawPenalty / 0,50** an leftoverPrintProfileYaw 0,45 koppeln.
481. **FaceEngine decide/centroid abs()** nach leftoverPick signed — Math abs, Call-Site redundant.
482. **geoVetoYawSkip tot.** skipPrint == yawPrint == 80. ¾ 72–79 % noch Veto.
483. **leftoverHoldsTrack leftoverPrintOk ohne yaw** — Overlay 0,64 Profil hält Track.
484. **Print aus VNFaceObservation** der Detect, kein zweiter Pass.
485. **Template-Aging.**
486. **FA-JSONL Kalibrierung** je Paar.
487. **Glasses On/Off.**
488. **leftoverHoldTrail Disk persist.**
489. **Overlay CAMetalLayer 60 Hz.**
490. **HeliosAegisKit** Mutex einmal.
491. **Kalman-Vel live** Overlay ohne 8-Hz-Sprung.
492. **enrollSMReady** Smile+Yaw vor Burst.
493. **leftoverPredictBoxes** zwischen Detect-Ticks.
494. **leftoverBaptizeQuality** live vor Taufe (Math abs sitzt, Call-Site Overlay).
495. **leftoverOverlayLerp** zwischen Detect-Ticks.
496. **leftoverOpenSetUnsure** statt Gast n+1.
497. **leftoverCoastPrintVecOf** skipPrints ohne Vec.
498. **Spark-Chip Hash-Bin signed.**
499. **Lookaway-Pin IoU-only** auf der Live-Kiste.
500. **EAR + SM AND.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
