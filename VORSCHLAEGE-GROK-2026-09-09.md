# Aegis Vorschläge — 2026-09-09 (Pass 34, 2.1.233)

Stand 2.1.233 alpha. FillX live, Trail/Name fold, Empty-Streak, Overlay-Keep, NeedsPrint.

## Gelandet in 2.1.233

- leftoverAssignFillX in leftoverAssignLive vor DropAmbiguous
- leftoverTrailNowOf → leftoverHoldTrailOf
- leftoverNameFromHold → leftoverShowsName
- leftoverEmptyKeepsStreak an leftoverHoldSurvive
- leftoverEmptyKeepsOverlay vor leftoverPending-Wipe
- leftoverNeedsPrint filtert skipIdsAll

## Erweiterung (neu)

444. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
445. **VNImageRequestHandler(cvPixelBuffer:)** ohne 420f→CGImage. P1.
446. **Gallery Index Pose-Bin + Name.** leftoverPick nicht linear.
447. **HNSW Gallery.**
448. **LiveCapture off MainActor.** Mutex-Beat outputQueue.
449. **Print aus VNFaceObservation** der Detect, kein zweiter Pass.
450. **Template-Aging.**
451. **FA-JSONL Kalibrierung** je Paar.
452. **Glasses On/Off.**
453. **leftoverHoldTrail Disk persist.**
454. **Overlay CAMetalLayer 60 Hz.**
455. **EAR + SM AND.**
456. **Face-Print Versioning.**
457. **gallery.json.bak Rotate.**
458. **Identity-Merge-Wizard.**
459. **ReID-Graph.**
460. **UMAP Cluster-View.**
461. **Export Embeddings JSONL.**
462. **Night-IR Galerie.**
463. **Stereo Yaw-Prior.**
464. **HeliosAegisKit** Mutex einmal.
465. **Spark-Chip Hash-Bin signed.**
466. **Lookaway-Pin IoU-only** auf der Live-Kiste.
467. **Kalman-Vel live** Overlay ohne 8-Hz-Sprung.
468. **enrollSMReady** Smile+Yaw vor Burst.
469. **leftoverPredictBoxes** zwischen Detect-Ticks.
470. **Print-Bank Decode** nach Restart.
471. **leftoverBaptizeQuality** live vor Taufe.
472. **leftoverOverlayLerp** zwischen Detect-Ticks.
473. **leftoverOpenSetUnsure** statt Gast n+1.
474. **leftoverCoastPrintVecOf** skipPrints ohne Vec.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
