# Aegis Vorschläge — 2026-09-08 (Pass 15, 2.1.214)

Stand 2.1.214 alpha. VNTrack, People-Album, False-Accept JSONL.

## Gelandet in 2.1.214

- overlayTrackUsesVision + FaceEngine.trackBoxes
- overlayTrackStep IoU-Fuse
- peopleAlbumEnrollOk + Photos Seed
- falseAcceptJSONL Replay (Lock vs Vote, Cap 500)

## Erweiterung (neu)

137. **VNTrack Observation persist** über skipDetect-Frames.
138. **Enroll-SM skippt volle Bins** beim Capture.
139. **Photos limited-auth** nur sichtbare Alben.
140. **People-Album lädt 3 Stills** nicht nur den Namen.
141. **FA-Replay UI** mit Pair-Heatmap.
142. **Cluster-Merge** 3 Stills.
143. **mmap leftover-Boxen** Helios Palm-Occlusion.
144. **gallery ANN / HNSW** nach Print-Index.
145. **Identity-Merge-Wizard** Cosine 0,89–0,94.
146. **P-Slot Maske/Schal**, Brille Twin-Veto.
147. **LiveCapture nicht @MainActor.**
148. **Overlay CAMetalLayer 60 Hz.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 14, 2.1.213)

Stand 2.1.213 alpha. Mac 1080, Softmax×Galerie, Overlay reduced-motion.

## Gelandet in 2.1.213

- sessionPresetApplies720 nur external
- gallerySoftmaxTemp
- overlayTrackTau reduceMotion 0

## Erweiterung (neu)

123. **PhotoKit People-Album** Enroll-Seed.
124. **VNTrackObjectRequest** Box zwischen Detect (Track statt nur Lerp).
125. **False-Accept JSONL Replay-UI.**
126. **Cluster-Merge** 3 Stills.
127. **mmap leftover-Boxen** Helios Palm-Occlusion.
128. **gallery ANN / HNSW** nach Print-Index.
129. **Identity-Merge-Wizard** Cosine 0,89–0,94.
130. **P-Slot Maske/Schal**, Brille Twin-Veto.
131. **ReID-Graph** Hold-Trail.
132. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
133. **Drop-in `.mlmodel`** Print-Backbone.
134. **gallery.json.bak Rotate 3.**
135. **Gemeinsamer CVPixelBuffer** Detect+Print.
136. **Enroll-SM skippt volle Bins** beim Capture.
137. **Hung-Vision Timeout-Token.**
138. **LiveCapture nicht @MainActor.**
139. **Overlay CAMetalLayer 60 Hz.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 13, 2.1.212)

Stand 2.1.212 alpha. Osmo 720@24, Enroll-SM Chip, Overlay-Track 60 Hz.

## Gelandet in 2.1.212

- captureLockFrameRate external 24
- sessionPresetApplies720 Osmo 720, Continuity skip
- enrollSMChip Front→¾L→¾R→Blink
- overlayTrackDt + Timer-Beat 60 Hz

## Erweiterung (neu)

109. **PhotoKit People-Album** Enroll-Seed.
110. **VNTrackObjectRequest** Box zwischen Detect (Track statt nur Lerp).
111. **False-Accept JSONL Replay-UI.**
112. **Softmax-Temperature × Gallery-Größe.**
113. **Cluster-Merge** 3 Stills.
114. **mmap leftover-Boxen** Helios Palm-Occlusion.
115. **gallery ANN / HNSW** nach Print-Index.
116. **Identity-Merge-Wizard** Cosine 0,89–0,94.
117. **P-Slot Maske/Schal**, Brille Twin-Veto.
118. **ReID-Graph** Hold-Trail.
119. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
120. **Drop-in `.mlmodel`** Print-Backbone.
121. **gallery.json.bak Rotate 3.**
122. **Gemeinsamer CVPixelBuffer** Detect+Print.

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 12, 2.1.211)

Stand 2.1.211 alpha. Osmo Choice, Coast ohne Kalman-Write, Yaw-Meter.

## Gelandet in 2.1.211

- CameraChoice.osmo + cameraChoiceSkipsBuiltIn
- liveCoastElapsed + skipDetect Kalman halt
- printYawCoverageBest Chip

## Erweiterung (neu)

102. **Osmo Format-Leiter** 720@24, nicht Continuity-8.
103. **Enroll-SM** Chip treibt Front→¾L→¾R→Blink.
104. **mmap leftover-Boxen** Helios Palm-Occlusion.
105. **VNTrackObjectRequest** zwischen Detect.
106. **Softmax-Temperature × Gallery-Größe.**
107. **False-Accept JSONL Replay-UI.**
108. **PhotoKit People-Album** Enroll-Seed.

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 11, 2.1.210)


Stand 2.1.210 alpha. Hung coast, inflight 0, Name-Strip, Wake.

## Gelandet in 2.1.210

- liveHungCoastOverlay Kalman
- liveHungSpawnOk inflight 0
- cameraNameBare sticky
- recoverAfterWake

## Erweiterung (neu)

96. **PhotoKit People-Album** Enroll-Seed.
97. **Box-Track 60 Hz** unabhängig von Detect.
98. **False-Accept JSONL Replay-UI.**
99. **Softmax-Temperature × Gallery-Größe.**
100. **Cluster-Merge** 3 Stills.
101. **Print-Budget Yaw-Coverage-Meter.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 10b, 2.1.209)

Stand 2.1.209 alpha. uniqueID sticky, Hung spawn cap, Print-Cache yaw nil.

## Gelandet in 2.1.209

- cameraUniqueIDSticky + cameraRoleOf (Osmo ≠ Mac)
- liveHungSpawnOk cap 2 + liveHungGenDrops drain
- leftoverPrintCacheHits yaw Optional

## Erweiterung (neu)

73. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC. P0.
74. **gallery ANN / HNSW** nach Print-Index.
75. **Identity-Merge-Wizard** Cosine 0,89–0,94 + Pairwise-Heatmap.
76. **Watch-Folder PhotoKit** + Export `.aegis` verschlüsselt.
77. **P-Slot Maske/Schal**, Brille Twin-Veto.
78. **ReID-Graph** Hold-Trail.
79. **Stereo Built-in + Continuity** Disparität als Yaw-Prior.
80. **Overlay CAMetalLayer 60 Hz**, Detect 8–24.
81. **Gemeinsamer CVPixelBuffer** Detect+Print.
82. **VNTrackObjectRequest** Box zwischen Detect-Ticks.
83. **LiveCapture nicht @MainActor.**
84. **Hung-Vision Timeout-Token.**
85. **Osmo als CameraChoice.**
86. **Match-Log JSONL** für False-Accept Replay.
87. **Drop-in `.mlmodel`** Print-Backbone.
88. **Temperature Cosine** statt hart 0,80.
89. **Enroll-SM** Front → ¾L → ¾R → Blink.
90. **gallery.json.bak Rotate 3**.

Kein 2.1.210-Flag ohne CameraBroker.

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
