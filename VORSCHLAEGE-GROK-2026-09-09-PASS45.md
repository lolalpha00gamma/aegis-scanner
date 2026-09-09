# Aegis Vorschläge — 2026-09-09 (Pass 45 Review, 2.1.243)

Stand 2.1.243 alpha. Review ohne Version-Bump. Kein Swift-Touch in diesem Pass — Linux-Sandbox kann Xcode nicht bauen.

## Warum es noch schlecht wirkt

Nicht fehlende Schwellen. Die letzten 40 Pässe verdrahteten tote Helfer. Was bleibt, ist Architektur:

- LiveCapture sitzt auf `@MainActor`. Detect + Print + Overlay teilen denselben Run-Loop. Continuity 8 Hz + skipDetect 4 fühlt sich tot an, obwohl MatchMath hält.
- Zwei Prozesse (Helios + Aegis) kämpfen um eine Kamera. Mutex-Stamp 250 ms, Claim, Yield — trotzdem AE-Jagd und Format-Reset nach Sleep.
- Gallery ist linear. leftoverHoldByHashSolo rettet Restart, skaliert nicht über Haushalts-Größe.
- leftoverHoldsTrack `yawAbs: nil` bewusst. Profil-Hold 0,64 bleibt Overlay-Policy, nicht Print-Policy. Das ist kein Bug, aber fühlt sich nach „erkennt schlecht“ an.

## Erweiterung (neu)

801. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC, ein Format, ein AE-Lock. P0.
802. **LiveCapture off MainActor** + Frame-Token. Overlay liest Snapshot, Tick schreibt.
803. **Adaptive skipDetect** aus visionMs + stillFor, nicht hart every 4.
804. **Kalman R aus VNFaceObservation.confidence.**
805. **HNSW / IVF-PQ Gallery** statt linear leftoverHoldXMatch.
806. **Print-Cache Pose-Bin LRU** + leftoverHoldTrail Disk nach Stop.
807. **Glasses On/Off** zwei Templates, nicht eine EMA.
808. **Identity-Merge-Wizard** nach Session-Cluster.
809. **Lookaway-Pin IoU-only** wenn yaw-Estimator nach Dropout 0 liefert.
810. **Privacy-Blur Unmatched** Overlay.
811. **Watch-Alert Household** nur nach Firm-Name + Streak 3.
812. **VNImageRequestHandler(cvPixelBuffer:)** ohne CGImage-Kopie.
813. **Overlay CAMetalLayer** statt SwiftUI ForEach-Rows.
814. **Template-Aging** leftoverPrintAt > 14 d → Re-Enroll Chip.
815. **Dual-Cam Yaw** Built-in + Continuity, ohne zweiten Claim.
816. **Session-Export Embeddings JSONL** für Offline-FA.
817. **ReID-Graph** leftoverTransfersId als Kante, nicht Override.
818. **enrollSMReady haveProfile** Burst nicht ready bei nur Frontal.
819. **leftoverTwinSameShot** in leftoverPick Rank, nicht nur HardVeto.
820. **printBudgetSkipIds** Continuity-Nacht: Laplacian-Floor vor Skip.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` nicht mergen.
