# Aegis Vorschläge — 2026-09-09 (Pass 44, 2.1.243)

Stand 2.1.243 alpha. Ghost Scale-Blend, 420v Sharp live, HashSolo vor x-Match, Coast skipPrints, Overlay-Dedup, Wake-ROI.

## Gelandet in 2.1.243

- leftoverGhostAspectLock lastW Kalman, predW Predict, blend 0,25.
- leftoverSharpnessOf FaceEngine videoRange: continuity || live. Mac 420v + Tiles.
- leftoverHoldByHashSolo leftoverHoldRemint + Bins **vor leftoverHoldXMatch**.
- leftoverCoastPrintWipe skipPrints TTL-Arm.
- leftoverOverlayUniqueRows ContentView overlayRows.
- liveRoiSkipOnWake in noteDidWake.

## Erweiterung (neu)

766. **CameraBroker XPC + IOSurface** mit Helios. P0.
767. **VNImageRequestHandler(cvPixelBuffer:).** P1.
768. **Gallery Index Pose-Bin + Name.**
769. **HNSW Gallery.**
770. **LiveCapture off MainActor.**
771. **Adaptive skipDetect.**
772. **Kalman R aus Vision-Track-Confidence.**
773. **leftoverTwinSameShot live.**
774. **Print-Cache Pose-Bin LRU.**
775. **Print aus VNFaceObservation.**
776. **Template-Aging.**
777. **FA-JSONL.**
778. **Glasses On/Off.**
779. **leftoverHoldTrail Disk.**
780. **Overlay CAMetalLayer.**
781. **HeliosAegisKit.**
782. **EAR + SM AND.**
783. **Identity-Merge-Wizard.**
784. **ReID-Graph.**
785. **Continuity Night-IR.**
786. **Stereo Yaw-Prior.**
787. **Lookaway-Pin IoU-only.**
788. **Dual-Cam Yaw.**
789. **UMAP Cluster-View.**
790. **Export Embeddings JSONL.**
791. **enrollSMReady haveProfile.**
792. **leftoverPrintBudgetYawDelta** global (Of sitzt per UUID).
793. **leftoverHoldsTrack leftoverPrintOk yawAbs live** (bewusst nil — Overlay-Hold Profil).
794. **Ada? Streak 2 Overlay.**
795. **leftoverOverlayPeak IoU-Adopt nach Wipe.** sitzt — prüfen Twin-Tie.
796. **Privacy-Blur Unmatched.**
797. **Session-Cluster nach Stop.**
798. **Print-EMA 8 Hz.**
799. **Watch-Alert Household.**
800. **3D-Yaw FaceShape3D.**
801. **leftoverGhostAspectLock mix aus leftoverBoxIoU.** Detect-Snap 1,0 / Coast 0,25.
802. **leftoverGhostAspectLock hypot-Aspect** statt linear W/H — Profil bleibt.
803. **FourCC 420v → leftoverSharpnessOf auto** ohne Continuity-Bool.
804. **leftoverCoastPrintWipe leftoverLastHash.** Coast Wipe Keys, LastHash stale bleibt.
805. **leftoverYawVelocityFreeze** 3-Zeilen-Wire.
806. **leftoverOverlayLerp** zwischen Detect 4.
807. **leftoverFaceTrackPredictHeld miss-scaled mix.**
808. **leftoverPredictBoxes 2D nicht an.** WHV würde regressen.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 43, 2.1.242)

Stand 2.1.242 alpha. OpenSet Unsure-Chip, Peak remain, Coast Wipe.

## Gelandet in 2.1.242

- leftoverOverlayGuestOf openSetUnsure vor StoreName
- leftoverUnsureTicks leftoverOpenSetUnsure
- leftoverOverlayPeakName remaining
- leftoverCoastPrintWipe stale Keys

leftoverSessionCaptureBox / PrefersFrame waren schon live in leftoverPick.

## Erweiterung (neu)

731. **CameraBroker XPC + IOSurface** mit Helios. P0.
732. **VNImageRequestHandler(cvPixelBuffer:).** P1.
733. **Gallery Index Pose-Bin + Name.**
734. **HNSW Gallery.**
735. **LiveCapture off MainActor.**
736. **Adaptive skipDetect.**
737. **Kalman R aus Vision-Track-Confidence.**
738. **leftoverTwinSameShot live.**
739. **Print-Cache Pose-Bin LRU.**
740. **Print aus VNFaceObservation.**
741. **Template-Aging.**
742. **FA-JSONL.**
743. **Glasses On/Off.**
744. **leftoverHoldTrail Disk.**
745. **Overlay CAMetalLayer.**
746. **HeliosAegisKit.**
747. **EAR + SM AND.**
748. **Identity-Merge-Wizard.**
749. **ReID-Graph.**
750. **Continuity Night-IR.**
751. **Stereo Yaw-Prior.**
752. **Lookaway-Pin IoU-only.**
753. **Dual-Cam Yaw.**
754. **UMAP Cluster-View.**
755. **Export Embeddings JSONL.**
756. **enrollSMReady haveProfile.**
757. **leftoverSharpnessOf 420v.**
758. **leftoverHoldByHashSolo.**
759. **leftoverPrintBudgetYawDelta.**
760. **leftoverOverlayUniqueRows.**
761. **leftoverHoldsTrack leftoverPrintOk yawAbs live** (bewusst nil — Overlay-Hold Profil).
762. **Ada? Streak 2 Overlay.**
763. **leftoverGhostAspectLock Scale-Blend** statt lastW/H copy.
764. **leftoverOverlayPeak IoU-Adopt nach Wipe.**
765. **leftoverCoastPrint skipPrints TTL-Arm.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 42, 2.1.241)

Stand 2.1.241 alpha. leftoverTransfersId capture, Kalman WHV persist, AE nach Start.

## Gelandet in 2.1.241

- leftoverBaptizeQuality / leftoverTransfersId / leftoverAssignPrintCell / leftoverOverlayFirmName capture
- leftoverFaceTrackPredictHeld pw/ph live
- leftoverHoldKalmanEncode 12 WHV
- AE/WB nach startRunning

## Erweiterung (neu)

694. **CameraBroker XPC + IOSurface** mit Helios. P0.
695. **VNImageRequestHandler(cvPixelBuffer:).** P1.
696. **Gallery Index Pose-Bin + Name.**
697. **HNSW Gallery.**
698. **LiveCapture off MainActor.**
699. **Adaptive skipDetect.**
700. **Kalman R aus Vision-Track-Confidence.**
701. **leftoverOpenSetEnergy Unsure-Chip.**
702. **leftoverTwinSameShot live.**
703. **Print-Cache Pose-Bin LRU.**
704. **Print aus VNFaceObservation.**
705. **Template-Aging.**
706. **FA-JSONL.**
707. **Glasses On/Off.**
708. **leftoverHoldTrail Disk.**
709. **Overlay CAMetalLayer.**
710. **HeliosAegisKit.**
711. **EAR + SM AND.**
712. **Identity-Merge-Wizard.**
713. **ReID-Graph.**
714. **Continuity Night-IR.**
715. **Stereo Yaw-Prior.**
716. **Lookaway-Pin IoU-only.**
717. **Dual-Cam Yaw.**
718. **UMAP Cluster-View.**
719. **Export Embeddings JSONL.**
720. **enrollSMReady haveProfile.**
721. **leftoverSessionCaptureBox Hist-Median.**
722. **leftoverSessionCapturePrefersFrame.**
723. **leftoverCoastPrintFresh Key-Wipe.**
724. **leftoverSharpnessOf 420v.**
725. **leftoverHoldByHashSolo.**
726. **leftoverPrintBudgetYawDelta.**
727. **leftoverOverlayUniqueRows.**
728. **leftoverHoldsTrack leftoverPrintOk yawAbs live** (bewusst nil — Overlay-Hold Profil).
729. **Ada? Streak 2 Overlay.**
730. **leftoverGhostAspectLock Scale-Blend** statt lastW/H copy.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 41, 2.1.240)

Stand 2.1.240 alpha. leftoverPick SessionCapture, OccupiedLiveOnly, SkipLookaway, GhostIds.

## Gelandet in 2.1.240

- leftoverSessionCapture in leftoverPick
- leftoverOccupiedLiveOnly nach Coast-TTL
- leftoverHoldSkipLookaway vor unbinned EMA
- leftoverGhostIds Dropout-Union

## Erweiterung (neu)

657. **CameraBroker XPC + IOSurface** mit Helios. P0.
658. **VNImageRequestHandler(cvPixelBuffer:).** P1.
659. **Gallery Index Pose-Bin + Name.**
660. **HNSW Gallery.**
661. **LiveCapture off MainActor.**
662. **Adaptive skipDetect.**
663. **Kalman R aus Vision-Track-Confidence.**
664. **leftoverOpenSetEnergy Unsure-Chip.**
665. **leftoverTwinSameShot live.**
666. **Print-Cache Pose-Bin LRU.**
667. **Print aus VNFaceObservation.**
668. **Template-Aging.**
669. **FA-JSONL.**
670. **Glasses On/Off.**
671. **leftoverHoldTrail Disk.**
672. **Overlay CAMetalLayer.**
673. **HeliosAegisKit.**
674. **EAR + SM AND.**
675. **Identity-Merge-Wizard.**
676. **ReID-Graph.**
677. **Continuity Night-IR.**
678. **Stereo Yaw-Prior.**
679. **Lookaway-Pin IoU-only.**
680. **Dual-Cam Yaw.**
681. **UMAP Cluster-View.**
682. **Export Embeddings JSONL.**
683. **enrollSMReady haveProfile.**
684. **leftoverSessionCapture leftoverTransfersId.**
685. **leftoverSessionCaptureBox Hist-Median.**
686. **leftoverSessionCapturePrefersFrame.**
687. **leftoverCoastPrintFresh Key-Wipe.**
688. **leftoverSharpnessOf 420v.**
689. **leftoverHoldByHashSolo.**
690. **leftoverPrintBudgetYawDelta.**
691. **leftoverOverlayUniqueRows.**
692. **leftoverOverlayLerp ContentView.**
693. **leftoverAssignPrintOk capture.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 40, 2.1.239)

Stand 2.1.239 alpha. Kalman W/H live. Firm-Name yaw. skip every 4.

## Gelandet in 2.1.239

- boxKalmanWHV + leftoverFaceTrackKalmanPredict pw/ph skipDetect
- leftoverOverlayFirmName leftoverAssignPrintOk yawAbs + sharpness
- leftoverDetectSkipTick every: 4 (Default 8)
- leftoverPrintSharpOf Nacht leftoverHoldsTrack 0,62 / 0,14

## Erweiterung (neu)

622. **CameraBroker XPC + IOSurface** mit Helios. P0.
623. **VNImageRequestHandler(cvPixelBuffer:).** P1.
624. **Gallery Index Pose-Bin + Name.**
625. **HNSW Gallery.**
626. **LiveCapture off MainActor.**
627. **Adaptive skipDetect.** IoU hoch every 8, Jitter every 2.
628. **Kalman R aus Vision-Track-Confidence.**
629. **leftoverOpenSetEnergy Unsure-Chip.**
630. **leftoverTwinSameShot live.**
631. **Print-Cache Pose-Bin LRU.**
632. **Print aus VNFaceObservation.**
633. **Template-Aging.**
634. **FA-JSONL.**
635. **Glasses On/Off.**
636. **leftoverHoldTrail Disk.**
637. **Overlay CAMetalLayer.**
638. **HeliosAegisKit.**
639. **EAR + SM AND.**
640. **Identity-Merge-Wizard.**
641. **ReID-Graph.**
642. **Continuity Night-IR.**
643. **Stereo Yaw-Prior.**
644. **Lookaway-Pin IoU-only.**
645. **Dual-Cam Yaw.**
646. **UMAP Cluster-View.**
647. **Export Embeddings JSONL.**
648. **enrollSMReady haveProfile.**
649. **leftoverSessionCapture leftoverTransfersId.**
650. **leftoverFaceTrackPredictHeld pw/ph** wenn Ghost-Aspect aus.
651. **leftoverOverlayLerp ContentView.**
652. **leftoverCoastPrintVecOf.**
653. **leftoverAssignPrintOk capture.**
654. **leftoverHoldKalmanEncode WHV.**
655. **yawVelocityFreeze in leftoverPick.**
656. **AE-Lock nach startRunning.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 39, 2.1.238)

Stand 2.1.238 alpha. leftoverHoldsTrack capture. Burst 3. Wake CS Continuity.

## Gelandet in 2.1.238

- leftoverHoldsTrack leftoverPrintOk(capture: leftoverSessionCapture)
- enrollBurstReady vor Burst-Replace
- reconnectCenterStageOff in recoverAfterWake

## Erweiterung (neu)

589. **CameraBroker XPC + IOSurface** mit Helios. P0.
590. **VNImageRequestHandler(cvPixelBuffer:).** P1.
591. **Gallery Index Pose-Bin + Name.**
592. **HNSW Gallery.**
593. **LiveCapture off MainActor.**
594. **Adaptive skipDetect.**
595. **Kalman R aus Vision-Track-Confidence.**
596. **leftoverOpenSetEnergy Unsure-Chip** statt Gast n+1 (Pick sitzt).
597. **leftoverTwinSameShot live.**
598. **Print-Cache Pose-Bin LRU.**
599. **Print aus VNFaceObservation.**
600. **Template-Aging.**
601. **FA-JSONL.**
602. **Glasses On/Off.**
603. **leftoverHoldTrail Disk.**
604. **Overlay CAMetalLayer.**
605. **HeliosAegisKit.**
606. **EAR + SM AND.**
607. **Identity-Merge-Wizard.**
608. **ReID-Graph.**
609. **Continuity Night-IR.**
610. **Stereo Yaw-Prior.**
611. **Lookaway-Pin IoU-only.**
612. **Detect-Skip every 4.**
613. **Dual-Cam Yaw.**
614. **UMAP Cluster-View.**
615. **Export Embeddings JSONL.**
616. **boxKalmanW/H Vel.**
617. **enrollSMReady haveProfile.**
618. **leftoverBaptizeQuality live Overlay-Name.**
619. **yawVelocityFreeze in leftoverPick.**
620. **leftoverOverlayLerp DisplayLink 60 Hz.**
621. **AE-Lock nach startRunning** (Helios 1.6.91, Aegis applyBestFormat vor Unlock).

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

# Aegis Vorschläge — 2026-09-09 (Pass 38, 2.1.237)

Stand 2.1.237 alpha. skipDetect IoU statt ==. overlayHint Profil 0,70.

## Gelandet in 2.1.237

- leftoverDetectSkip(leftoverBoxIoU) in skipDetect
- overlayHint Profil ≥ 0,70 = poseSlot

## Erweiterung (neu)

559. **CameraBroker XPC + IOSurface** mit Helios. P0.
560. **VNImageRequestHandler(cvPixelBuffer:).** P1.
561. **Gallery Index Pose-Bin + Name.**
562. **HNSW Gallery.**
563. **LiveCapture off MainActor.**
564. **Adaptive skipDetect.**
565. **Kalman R aus Vision-Track-Confidence.**
566. **leftoverOpenSetEnergy Unsure-Chip.**
567. **leftoverTwinSameShot live.**
568. **Print-Cache Pose-Bin LRU.**
569. **Print aus VNFaceObservation.**
570. **Template-Aging.**
571. **FA-JSONL.**
572. **Glasses On/Off.**
573. **leftoverHoldTrail Disk.**
574. **Overlay CAMetalLayer.**
575. **HeliosAegisKit.**
576. **EAR + SM AND.**
577. **Identity-Merge-Wizard.**
578. **ReID-Graph.**
579. **Continuity Night-IR.**
580. **Stereo Yaw-Prior.**
581. **Lookaway-Pin IoU-only.**
582. **Detect-Skip every 4.**
583. **Dual-Cam Yaw.**
584. **UMAP Cluster-View.**
585. **Export Embeddings JSONL.**
586. **boxKalmanW/H Vel.**
587. **enrollSMReady haveProfile.**
588. **leftoverSessionCapture an PrintOk.**

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.

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
