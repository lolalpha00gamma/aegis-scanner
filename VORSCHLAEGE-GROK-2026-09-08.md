# Aegis Vorschläge — 2026-09-08 (Pass 8, 2.1.207)

Stand 2.1.207 alpha. Ergänzung zu 2.1.206 (Unpack/Move/Print-Index/Twin-Lock).

## Gelandet in 2.1.207

`leftoverPairLast` nach Remint aus Unpack (siehe BUGFIX One-Liner in LibraryStore).

## Erweiterung (neu)

73. **leftoverTracks auch Live-Skalare** Yaw/Kalman/Blink. P0 Rest.
74. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
75. **gallery ANN / HNSW** nach Print-Index.
76. **Identity-Merge-Wizard** Cosine 0,89–0,94 + Pairwise-Heatmap.
77. **Watch-Folder PhotoKit** + Export `.aegis` verschlüsselt.
78. **P-Slot Maske/Schal**, Brille Twin-Veto.
79. **ReID-Graph** Hold-Trail.
80. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
81. **FaceTrack.id uniqueID-Reconnect** via Print+Yaw-Bin.
82. **Overlay CAMetalLayer 60 Hz**, Detect 8–24.
83. **Gemeinsamer CVPixelBuffer** Detect+Print.
84. **VNTrackObjectRequest** Box zwischen Detect-Ticks.
85. **Hung-Detect Cancel** nach 1 s.
86. **LiveCapture nicht @MainActor.**
87. **420f vs 420v** Color-Space Continuity/Built-in.
88. **Eine Fixture Restart+Twin+AssignLive** statt 40 Bool-Orakel.
89. **leftoverPrintYaw in gallery.json persist**.
90. **Detect-Interval ≠ Print-Interval**.
91. **Twin-Bin ¾L vs ¾R**.
92. **Overlay identity-Lerp unabhängig von Assign**.
93. **Blink-Liveness auf Assign**.
94. **Match-Log JSONL** für False-Accept Replay.
95. **Drop-in `.mlmodel`** Print-Backbone ohne MatchMath-Rewrite.

Kein 2.1.208-Flag ohne CameraBroker oder leftoverTracks als einzige Live-Map.
