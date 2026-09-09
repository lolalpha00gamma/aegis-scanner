# Aegis Vorschläge — 2026-09-09 (Pass 32, 2.1.231)

Stand 2.1.231 alpha. Stamp-TTL, Print-Cache Set einmal, Burst-Lock, skipPrint einmal.

## Gelandet in 2.1.231

- cameraMutexStampFresh 250 ms, Palmen/PTS nur frisch
- leftoverPrintCacheHits + leftoverPrintCacheBins Set einmal pro Frame
- burstRejects nmsLock
- stampPrints skipHit einmal

## Erweiterung (neu)

399. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
400. **VNImageRequestHandler(cvPixelBuffer:)** ohne 420f→CGImage. P1.
401. **Gallery Index Pose-Bin + Name.** leftoverPick nicht linear.
402. **HNSW Gallery.**
403. **LiveCapture off MainActor.** Mutex-Beat outputQueue.
404. **Print aus VNFaceObservation** der Detect, kein zweiter Pass.
405. **Template-Aging.**
406. **FA-JSONL Kalibrierung** je Paar.
407. **Glasses On/Off.**
408. **leftoverHoldTrail Disk persist.**
409. **Overlay CAMetalLayer 60 Hz.**
410. **EAR + SM AND.**
411. **Face-Print Versioning.**
412. **gallery.json.bak Rotate.**
413. **Identity-Merge-Wizard.**
414. **ReID-Graph.**
415. **UMAP Cluster-View.**
416. **Export Embeddings JSONL.**
417. **Night-IR Galerie.**
418. **Stereo Yaw-Prior.**
419. **HeliosAegisKit** Mutex einmal.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
