# Nachtrag 2026-09-05 (2.1.105)

Siehe ANALYSE.md. **2.1.105** leftoverHoldTrailBins, HOLD/Spark roh je Bin, leftoverBaptizeQuality. 2.1.104: Live 15 fps, leftoverTrailWriteOk ohne Yaw-Block.

## In 2.1.105 gelandet

1. leftoverHoldTrailBins + leftoverCosineSparkLabelOf — Spark ¾ nicht leer
2. leftoverHoldOverlayChipOf binTrail — HOLD roh aus Pose-Bin
3. leftoverBaptizeQuality Blur/Blink/Profil
4. leftoverScoreTickPut / leftoverLiveNameHolds Math aus bugfix 2.1.15
5. VERSION = Models = MARKETING_VERSION 2.1.105 (Build 131)

## In 2.1.104 gelandet

1. liveMinInterval Hunt 8/10, Lock 12/15 — nicht mehr 5/8
2. physicalCaptureRotation aus, Portrait `.right`
3. leftoverTrailWriteOk ohne Yaw-Block — ¾-Trail schreibt Hash-Bin
4. leftoverHoldTrail[id] nur frontal — Spark ¾ kein UUID-Mix
5. leftoverHoldOverlayChipOf bleibt ¾-Chip (Bin-Hold)
6. captureFormatScore 4:3, reselectFormat CS+Format zweimal
7. VERSION = Models = MARKETING_VERSION 2.1.104 (Build 130)

## In 2.1.103 gelandet

1. `availableVideoPixelFormatTypes` statt ObjC-CV-Infix — xcodebuild 2.1.101/102 tot
2. Parameter `videoOut`, nicht `output` (AVPlayerItemVideoOutput)
3. VERSION = Models = MARKETING_VERSION 2.1.103 (Build 129)

## In 2.1.102 gelandet

1. leftoverBaptizeBoth roh UND smooth — nil Smooth keine Taufe
2. leftoverHoldOverlayChipOf — ¾ Chip ohne Frontal-Trail
3. leftoverTrailNowOf — Transfer-Trail ¾ = Hash-Bin
4. leftoverNameFromHold — ¾ ohne Bin kein Frontal-Name
5. leftoverHasHold / overlayName
6. VERSION = Models = MARKETING_VERSION 2.1.102 (Build 128)

## In 2.1.101 gelandet

1. leftoverHoldChip compact HOLD 80/64, ¾-Trail nicht UUID-Mix
2. leftoverScoreHeatMid Nacht 0,60, leftoverSoftmaxFloorOf 0,47
3. Center Stage aus vor Format, Continuity Preset aus, lock 24
4. SHARP + BAND Chips, 420v Sharp-Lift, 422 vor BGRA
5. VERSION = Models = MARKETING_VERSION 2.1.101 (Build 127)

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
9. CLAHE auf den Buffer, nicht nur Banner
12. Drop-in .mlmodel
14. DBSCAN vor Merge
15. VoiceOver spricht den Namen
16. Watch-Folder PhotoKit
19. PnP 6DoF, Slot folgt der Nase
22. Encrypted gallery export `.aegis`
26. Temporal ReID-Graph über Hold-Trail
28. Partial-Print für Profil (P-Slot ohne Augen)
30. Burst-AE 5-Frame-Fenster Pref für Continuity-Nacht
41. Temporal print bank (5 Slots) Pose-Keys
43. Aegis.dmg nicht ins Git — nur CI-Artefakt
45. Masken-/Schal-Slot
46. RTSP-Reconnect Exponential-Backoff
59. Shared AVCaptureSession via XPC mit Helios
61. Print-Bank 5 Pose-Slots (front/left/right/up/down) gewichtet
72. JPEG-Recompress-Probe vor Taufe
77. Blink-Liveness. Lid-Gap 2 Frames
84. Iris-Textur-Slot als Twin-Veto
103. Specular-Highlight auf Stirn als Card-Photo-Veto
107. Continuity LiDAR-Z als Twin-Trennung
109. gallery.json printRevision
110. Per-Box CLAHE nur auf Face-ROI
115. Blink 2-Frame Lid-Gap vor Taufe — Poster
116. JPEG 70 % Probe vor leftoverBaptize
119. Capture-Hist 8 in gallery.json Schema 5
121. leftoverHold hash# bins persist
124. Yaw-binned Print-Bank 5 Slots
137. leftoverHoldBins persist App-Neustart
139. Tests splitted
147. Aegis.dmg nicht ins Git
148. Shared AVCaptureSession XPC mit Helios
152. CIImage createCGImage Farbe 420v messen
158. FaceEngine capture an leftoverPick wenn Frame-Luma nil
159. RTSP 420f analog LiveCapture
- liveMinInterval 8–15 — sitzt.
- physicalCaptureRotation aus — sitzt.
- leftoverTrailWriteOk ohne Yaw — sitzt.
- leftoverHoldTrail[id] frontal — sitzt.
- leftoverSparkChip ¾ leer — sitzt.
- leftoverHoldOverlayChipOf — sitzt.
- leftoverBaptizeBoth ohne ?? raw — sitzt.
- leftoverTrailNowOf — sitzt.
- leftoverNameFromHold — sitzt.
- captureFormatScore 4:3 — sitzt.
- reselectFormat CS zweimal — sitzt.
- leftoverHoldChip compact — sitzt.
- leftoverScoreHeatMid Nacht — sitzt.
- leftoverSoftmaxFloorOf — sitzt.
- Center Stage aus — sitzt.
- Continuity Preset aus — sitzt.
- captureLockFrameRate continuity 24 — sitzt.
- SHARP Chip — sitzt.
- BAND Chip — sitzt.
- 420v Sharp-Lift — sitzt.
- availableVideoPixelFormatTypes — sitzt.

Neu:

- leftoverLastHash je FaceId — sitzt als leftoverHoldTrailBins (2.1.105). Spark/HOLD ohne Box-Hash.
- ** leftoverAdopt Lock 0,80 s** bei 15 fps (12 Frames) statt hart 1,2 s.
- ** Hunt 10 fps bis leftoverStreak ≥ 1**, nicht 8 — erste Taufe sonst weiter hungernd.
- ** FaceEngine auf outputQueue**, nicht Main. 15 fps auf Main kann UI-Jank.
- ** RTSP 420f**, Player-Pfad bleibt 32BGRA.
- ** Shared XPC mit Helios 1.5.89** eine TCC, ein Buffer, dieselbe 0°-Geometrie.
- ** Overlay VoiceOver HOLD roh/smooth** „gehalten null acht null“.
- ** JPEG 70 % + Blink 2-Frame** vor leftoverBaptize — leftoverBaptizeQuality sitzt, JPEG-Probe fehlt.
- ** gallery.json Schema 5 Capture-Hist + Hold-Bins** über App-Neustart. leftoverHoldTrailBins stirbt mit dem Prozess.
- ** Per-Box CLAHE** statt Full-Frame.
- leftoverScoreTickPut / leftoverLiveNameHolds — Math sitzt (2.1.105). Overlay bleibt liveScoreEMA, Vote bleibt Mehrheit. **3-Tick-AND hinter Pref.**
- ** liveMinInterval thermal** 8 fps 2 s halten analog Helios, nicht hart Hunt.
- ** Center Stage nach Continuity-Reconnect** nochmal aus — CS kommt mit dem Gerät zurück.
- ** leftoverSparkChip peak-hold 2 Frames** sonst 8 fps Overlay flackert.
- ** FaceEngine capture an leftoverPick** wenn Frame-Luma nil — Indoor 420v sonst Nacht-Softmax.
- leftoverAdopt bleibt Taufe-Pfad. 1,2 s sitzt. leftoverTransfersId ohne Smooth tauft nicht mehr.
- VideoStabilization aus — Math fehlt auf macOS.
- leftoverBaptize Qualitätstor — sitzt (2.1.105).
- leftoverHoldOverlayChipOf Bin-Trail roh — sitzt (2.1.105).
- leftoverCosineSparkLabelOf — sitzt (2.1.105).

Nur main.
