# Aegis Vorschläge — 2026-09-09 (Pass 33, 2.1.232)

Stand 2.1.232 alpha. Spark/Pick signed yaw, Lookaway abs.

## Gelandet in 2.1.232

- tickLeftoverSparkChips signed quality.yaw
- leftoverPick yawAbs signed (leftoverHoldPrevOf L/R)
- leftoverLookawayBlocks abs, Ghost-Yaw signed

## Erweiterung (neu)

420. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
421. **VNImageRequestHandler(cvPixelBuffer:)** ohne 420f→CGImage. P1.
422. **Gallery Index Pose-Bin + Name.** leftoverPick nicht linear.
423. **HNSW Gallery.**
424. **LiveCapture off MainActor.** Mutex-Beat outputQueue.
425. **leftoverHoldTrailOf falten** in leftoverTrailNowOf.
426. **Print aus VNFaceObservation** der Detect, kein zweiter Pass.
427. **Template-Aging.**
428. **FA-JSONL Kalibrierung** je Paar.
429. **Glasses On/Off.**
430. **leftoverHoldTrail Disk persist.**
431. **Overlay CAMetalLayer 60 Hz.**
432. **EAR + SM AND.**
433. **Face-Print Versioning.**
434. **gallery.json.bak Rotate.**
435. **Identity-Merge-Wizard.**
436. **ReID-Graph.**
437. **UMAP Cluster-View.**
438. **Export Embeddings JSONL.**
439. **Night-IR Galerie.**
440. **Stereo Yaw-Prior.**
441. **HeliosAegisKit** Mutex einmal.
442. **Spark-Chip Hash-Bin signed.**
443. **Lookaway-Pin IoU-only** auf der Live-Kiste.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
