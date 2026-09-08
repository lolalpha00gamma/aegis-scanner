# Aegis Vorschläge — 2026-09-08 (Pass 10, 2.1.208)

Stand 2.1.208 alpha. Hung-Detect, Print-Cache Yaw-Bin, JPEG-Bin, Blink-Assign.

## Gelandet in 2.1.208

- liveEmitHungCancel + liveDetectGen
- leftoverLastHashBinKey / leftoverPrintCacheHits×Put
- leftoverJpegProbeStoreBin / LookupBin (Profil ≠ Frontal)
- leftoverAssignPrintCell blinkOk intern alreadyNamed:false

## Erweiterung (neu)

73. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
74. **gallery ANN / HNSW** nach Print-Index.
75. **Identity-Merge-Wizard** Cosine 0,89–0,94 + Pairwise-Heatmap.
76. **Watch-Folder PhotoKit** + Export `.aegis` verschlüsselt.
77. **P-Slot Maske/Schal**, Brille Twin-Veto.
78. **ReID-Graph** Hold-Trail.
79. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
80. **FaceTrack.id uniqueID-Reconnect** via Print+Yaw-Bin.
81. **Overlay CAMetalLayer 60 Hz**, Detect 8–24.
82. **Gemeinsamer CVPixelBuffer** Detect+Print.
83. **VNTrackObjectRequest** Box zwischen Detect-Ticks.
84. **LiveCapture nicht @MainActor.**
85. **420f vs 420v** Color-Space Continuity/Built-in.
86. **Eine Fixture Restart+Twin+AssignLive** statt 40 Bool-Orakel.
87. **Overlay identity-Lerp unabhängig von Assign.**
88. **Match-Log JSONL** für False-Accept Replay.
89. **Drop-in `.mlmodel`** Print-Backbone ohne MatchMath-Rewrite.
90. **Hung-Detect: VNRequest cancel** statt nur Gen-Bump.
91. **leftoverPrintCache persist** in extra (RAM-only tot nach Restart).
92. **Temporal-Median Cosine 3 Ticks** statt nur EMA.
93. **Print-Budget pro Identität**, nicht nur Hash×Bin.
94. **Guest vs enrolled two-speed detect.**
95. **VNDetectFaceCaptureQuality** als Print-Skip.

Kein 2.1.209-Flag ohne CameraBroker oder LiveCapture off MainActor.
