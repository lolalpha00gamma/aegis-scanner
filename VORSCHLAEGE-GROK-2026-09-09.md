# Aegis Vorschläge — 2026-09-09 (Pass 37, 2.1.236)

Stand 2.1.236 alpha. geoVetoYawPrint 72. Yaw-Strafe saturiert bei ProfileYaw. skipDetect Kalman-Coast.

## Gelandet in 2.1.236

- geoVetoYawPrint 80 → 72
- leftoverScore / leftoverLiveWeight / centroidWeight `/ leftoverPrintProfileYaw`
- skipDetect leftoverFaceTrackKalmanPredict / leftoverFaceTrackKalmanVel
- FaceEngine decide/centroid signed yaw

## Erweiterung (neu)

531. **CameraBroker XPC + IOSurface** mit Helios. P0.
532. **VNImageRequestHandler(cvPixelBuffer:).** P1.
533. **Gallery Index Pose-Bin + Name.**
534. **HNSW Gallery.**
535. **LiveCapture off MainActor.**
536. **Adaptive skipDetect.**
537. **Kalman R aus Vision-Track-Confidence.**
538. **overlayHint Profil** an leftoverPrintProfileYaw.
539. **leftoverOpenSetEnergy Unsure-Chip.**
540. **leftoverTwinSameShot live.**
541. **Print-Cache Pose-Bin LRU.**
542. **Print aus VNFaceObservation.**
543. **Template-Aging.**
544. **FA-JSONL.**
545. **Glasses On/Off.**
546. **leftoverHoldTrail Disk.**
547. **Overlay CAMetalLayer.**
548. **HeliosAegisKit.**
549. **EAR + SM AND.**
550. **Identity-Merge-Wizard.**
551. **ReID-Graph.**
552. **Continuity Night-IR.**
553. **Stereo Yaw-Prior.**
554. **Lookaway-Pin IoU-only.**
555. **Detect-Skip every 4.**
556. **Dual-Cam Yaw.**
557. **UMAP Cluster-View.**
558. **Export Embeddings JSONL.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 36, 2.1.235)

Stand 2.1.235 alpha. Kalman-Vel Sleep-Zero, PredictBoxes Batch, enrollSMReady Burst-Gate, Hold ohne Yaw.

## Gelandet in 2.1.235

- leftoverFaceTrackKalmanVel Sleep-Zero vor boxKalmanV
- leftoverPredictBoxes in leftoverPredictHeld
- enrollSMReady AND FromChip (Burst + leftoverLiveNameAnd)
- leftoverHoldsTrack leftoverPrintOk(yawAbs: nil)

## Erweiterung (neu)

501. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
502. **VNImageRequestHandler(cvPixelBuffer:)** ohne 420f→CGImage. P1.
503. **Gallery Index Pose-Bin + Name.** leftoverPick nicht linear.
504. **HNSW Gallery.**
505. **LiveCapture off MainActor.** Mutex-Beat outputQueue.
506. **leftoverYawPenalty / 0,50** an leftoverPrintProfileYaw 0,45 koppeln.
507. **FaceEngine decide/centroid abs()** nach leftoverPick signed.
508. **geoVetoYawSkip tot.** skipPrint == yawPrint == 80.
509. **Print aus VNFaceObservation** der Detect.
510. **Template-Aging.**
511. **FA-JSONL Kalibrierung** je Paar.
512. **Glasses On/Off.**
513. **leftoverHoldTrail Disk persist.**
514. **Overlay CAMetalLayer 60 Hz.**
515. **HeliosAegisKit** Mutex einmal.
516. **leftoverBaptizeQuality** live vor Taufe.
517. **leftoverOverlayLerp** in ContentView zwischen Detect.
518. **leftoverOpenSetUnsure** statt Gast n+1.
519. **leftoverCoastPrintVecOf** skipPrints ohne Vec.
520. **Spark-Chip Hash-Bin signed.**
521. **Lookaway-Pin IoU-only.**
522. **EAR + SM AND.**
523. **Face-Print Versioning.**
524. **UMAP Cluster-View.**
525. **Stereo Built-in + Continuity** Yaw-Prior.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
