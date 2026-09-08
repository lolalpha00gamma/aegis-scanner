# Aegis Vorschläge — 2026-09-08 (Pass 24, 2.1.223)

Stand 2.1.223 alpha. P-Slot, Yaw-Kompass, Twin-Split persist.

## Gelandet in 2.1.223

- leftoverEnrollSlotHave profile / ±2
- enrollSMChip Front→¾L→¾R→P→Blink
- enrollYawCompass
- twinSplitInsert + UserDefaults + leftoverPick cull

## Erweiterung (neu)

235. **LiveCapture off MainActor.** Detect+Print blockiert die UI. P0 nach CameraBroker.
236. **HNSW Gallery.** Linear-Scan O(n) jede Frame.
237. **CameraBroker XPC + IOSurface** mit Helios. Eine TCC.
238. **Overlay CAMetalLayer 60 Hz.**
239. **leftoverHoldTrail Disk persist.**
240. **Glasses On/Off Templates.**
241. **Face-Print Versioning.**
242. **Export Embeddings JSONL.**
243. **UMAP Cluster-View.**
244. **Identity-Merge-Wizard.**
245. **Helios Palm-Box Occlusion-Skip** via Mutex-Zeile.
246. **Blink-Liveness EAR**, nicht nur SM-Chip.
247. **Profil-Hold nicht in Frontal-EMA.** leftoverHold Bin 0 bleibt Front.
248. **Continuity Night-IR eigene Galerie.**
249. **Per-Camera WB-Lock** Osmo vs Phone.
250. **Name-Lock × P-Slot** — Taufe erst nach P wenn Twins in FA-Matrix.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` (2.1.15) nicht mergen.

# Aegis Vorschläge — 2026-09-08 (Pass 23, 2.1.222)

Stand 2.1.222 alpha. Still-Dedup, Name-Suffix, Compact, Burst, AE-Lock, PhotoKit-Debounce.

## Gelandet in 2.1.222

- peopleAlbumStillDup Yaw-Bin + Capture
- displayNameSuffix Ada → Ada 2
- galleryCompactDrops capture < 0,35, letzter Still hält
- burstRejectTick 3 / 200 ms
- captureLocksAE Continuity
- photoKitDebounce 1,2 s

## Erweiterung (neu)

221. **LiveCapture off MainActor.** Detect+Print blockiert die UI.
222. **HNSW Gallery.** Linear-Scan O(n) jede Frame.
223. **Live Enroll Yaw-Kompass.** Chip treibt die Pose.
224. **Helios Palm-Box Occlusion-Skip** via Mutex-Zeile.
225. **leftoverHoldTrail Disk persist.**
226. **Glasses On/Off Templates.**
227. **Face-Print Versioning.**
228. **Export Embeddings JSONL.**
229. **UMAP Cluster-View.**
230. **Identity-Merge-Wizard.**
231. **P-Slot wirklich schreiben.**
232. **Overlay CAMetalLayer 60 Hz.**
233. **Twin-Split IDs wirklich trennen** in gallery.json.
234. **CameraBroker XPC + IOSurface** mit Helios.

P0: CameraBroker. Kein neues leftover*-Flag. Branch `bugfix` (2.1.15) nicht mergen.

# Aegis Vorschläge — 2026-09-08 (Pass 22, 2.1.221)


Stand 2.1.221 alpha. PickFloor, People-Seed 3.

## Gelandet in 2.1.221

- leftoverPickFloor min(roh, Median) in leftoverPick
- peopleAlbumEnrollOk need: peopleAlbumSeedNeed() (3, nicht 1)

## Erweiterung (neu)

211. **People still-dedup** perceptual-hash vor Seed.
212. **Burst-Reject** 3 same-hash / 200 ms.
213. **Display-Name-Suffix** Kollision Ada/Ada 2.
214. **Live Enroll Yaw-Kompass.**
215. **Gallery compact** captureQuality < 0,35.
216. **Helios Palm-Box Occlusion-Skip.**
217. **PhotoKit Change-Observer Debounce.**
218. **leftoverHoldTrail Disk persist.**
219. **Continuity AE-Lock** geteilt mit Helios.
220. **HNSW Gallery.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 21, 2.1.220)

Stand 2.1.220 alpha. Print-Cache Disk, People-SM-Gate, Twin-Split, Mask-Veto.

## Gelandet in 2.1.220

- leftoverPrintCacheEncode / Decode gallery.json
- peopleAlbumSMBlocksSeed Front+L+R
- twinAutoSplit FA ×3 SPLIT-Chip
- maskTwinVeto Floor 0,78 leftoverPick

## Erweiterung (neu)

201. **LiveCapture off MainActor.**
202. **Glasses On/Off Templates** (nicht nur Maske).
203. **Per-Camera WB-Lock.**
204. **HNSW Gallery.**
205. **Twin-Split IDs wirklich trennen.**
206. **Face-Print Versioning.**
207. **Export Embeddings** JSONL.
208. **UMAP Cluster-View.**
209. **P-Slot wirklich schreiben.**
210. **Identity-Merge-Wizard.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 20, 2.1.219)

Stand 2.1.219 alpha. Median, Enroll-Liveness, Merge-Undo, Capture-Spark.

## Gelandet in 2.1.219

- cosineTickMedian / leftoverHoldSmooth(trail:)
- enrollSMBlocksName / enrollSMReadyFromChip
- mergeUndoHolds / mergeUndoChip
- captureQualitySpark CQ-Chip

## Erweiterung (neu)

191. **Print-Cache persist** Disk.
192. **LiveCapture off MainActor.**
193. **Glasses On/Off Templates.**
194. **Per-Camera WB-Lock.**
195. **Auto-Split Twins** FA-Matrix.
196. **HNSW Gallery.**
197. **Enrollment Hard-Gate** auch People-Seed.
198. **Face-Print Versioning.**
199. **Export Embeddings** JSONL.
200. **UMAP Cluster-View.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 19, 2.1.218)

Stand 2.1.218 alpha. Lookalike, Night/IR, Guest-TTL, Hidden-Album.

## Gelandet in 2.1.218

- lookalikeNegative / lookalikeNegativeScores / lookalikeRejectedCap
- nightIRPrintSkip in stampPrints
- guestTTLExpired + pruneGuestTTL
- peopleAlbumSkipHidden

## Erweiterung (neu)

181. **Print-Cache persist** Disk.
182. **LiveCapture off MainActor.**
183. **Enrollment Liveness Pflicht.**
184. **Glasses On/Off Templates.**
185. **Per-Camera WB-Lock.**
186. **Cosine 3-Tick Median.**
187. **Auto-Split Twins** FA-Matrix.
188. **HNSW Gallery.**
189. **Merge-Undo 30 s.**
190. **Capture-Quality Spark.**

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 18, 2.1.217)

Stand 2.1.217 alpha. Temporal Vote, Capture-Skip, People-Dup, Enroll-Meter.

## Gelandet in 2.1.217

- nameTemporalVote / nameTemporalNeed Floor 5
- printCaptureQualitySkip in stampPrints
- peopleAlbumDuplicate Cosine 0,89
- enrollQualityMeter Chip

## Erweiterung (neu)

171. **Lookalike Negative-Embed.**
172. **Night/IR Continuity** Luma-Gate.
173. **Face-Print Versioning.**
174. **RAW/HEIC Watch-Folder.**
175. **Export Embeddings** JSONL.
176. **UMAP Cluster-View.**
177. **Guest-TTL** Auto-Forget.
178. **Merge-Undo 30 s.**
179. **Capture-Quality Spark** Overlay-Box.
180. **Photos Hidden-Album** skip.

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 17, 2.1.216)

Stand 2.1.216 alpha. Track lost Detect, People Yaw, limited-auth, FA Matrix.

## Gelandet in 2.1.216

- overlayTrackLost / overlayTrackForcesDetect + FaceEngine.lastTrackLostCount
- peopleAlbumYawPick / ScanCap 12 / YawDiverse
- peopleAlbumFetchAny limited → .any
- falseAcceptPairMatrix UI

## Erweiterung (neu)

161. **Temporal Majority-Vote** 5 Frames vor Name-Lock.
162. **Lookalike Negative-Embed.**
163. **Enrollment-Quality-Meter** live.
164. **Duplicate-Identity Detector** People-Seed.
165. **Night/IR Continuity** Luma-Gate.
166. **Face-Print Versioning.**
167. **RAW/HEIC Watch-Folder.**
168. **Export Embeddings** JSONL.
169. **Print-Cache persist** auf Disk.
170. **VNDetectFaceCaptureQuality** Print-Skip.

P0: CameraBroker. Kein neues leftover*-Flag.

# Aegis Vorschläge — 2026-09-08 (Pass 16, 2.1.215)

Stand 2.1.215 alpha. VNTrack persist, Enroll-SM skip, People 3 Stills, FA Heatmap.

## Gelandet in 2.1.215

- overlayTrackPersist / FaceEngine.trackBoxes(persist:) + seedTrack
- enrollSMSkipCapture → skipIds
- peopleAlbumStillCap / AuthOk + 3 Stills Detect
- falseAcceptPairHeatmap Chip

## Erweiterung (neu)

149. **People-Album Yaw-Diversität** Front+L+R.
150. **FA-Heatmap Matrix-UI.**
151. **Print-Cache persist** auf Disk.
152. **VNDetectFaceCaptureQuality** Print-Skip.
153. **Track lost → Detect sofort.**
154. **Photos limited-auth** nur sichtbare Alben.
155. **Cluster-Merge** 3 Stills.
156. **mmap leftover-Boxen** Helios Palm-Occlusion.
157. **gallery ANN / HNSW.**
158. **Identity-Merge-Wizard.**
159. **LiveCapture nicht @MainActor.**
160. **Overlay CAMetalLayer 60 Hz.**

P0: CameraBroker. Kein neues leftover*-Flag.

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
