# Nachtrag 2026-09-05 (2.1.101)

Siehe ANALYSE.md. **2.1.101** HOLD compact, Nacht-Softmax, Center-Stage, SHARP/BAND. 2.1.100: leftoverScore Nacht, Capture-Band 15–30.

## In 2.1.101 gelandet

1. leftoverHoldChip compact HOLD 80/64, ¾-Trail nicht UUID-Mix
2. leftoverScoreHeatMid Nacht 0,60, leftoverSoftmaxFloorOf 0,47
3. Center Stage aus vor Format, Continuity Preset aus, lock 24
4. SHARP + BAND Chips, 420v Sharp-Lift, 422 vor BGRA
5. VERSION = Models = MARKETING_VERSION 2.1.101 (Build 127)

## In 2.1.100 gelandet

1. leftoverScore capture: — Nacht-Rampe ab leftoverPrintSharpOf 0,12
2. leftoverPick reicht Box-Capture in leftoverScore
3. captureLockFrameLo Band 15–30
4. VERSION = Models = MARKETING_VERSION 2.1.100 (Build 126)

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
126. leftoverHoldTrail[id] je Bin verdrahten — Math sitzt (¾ leer), Store speichert noch kein Bin-Trail
137. leftoverHoldBins persist App-Neustart
139. Tests splitted
147. Aegis.dmg nicht ins Git
148. Shared AVCaptureSession XPC mit Helios
152. CIImage createCGImage Farbe 420v messen
158. FaceEngine capture an leftoverPick wenn Frame-Luma nil
159. RTSP 420f analog LiveCapture
- leftoverHoldChip compact — sitzt.
- leftoverHoldTrailOf ¾ kein UUID-Mix — sitzt.
- leftoverScoreHeatMid Nacht — sitzt.
- leftoverSoftmaxFloorOf — sitzt.
- Center Stage aus — sitzt.
- Continuity Preset aus — sitzt.
- captureLockFrameRate continuity 24 — sitzt.
- SHARP Chip — sitzt.
- BAND Chip — sitzt.
- 420v Sharp-Lift — sitzt.
- leftoverScore capture — sitzt.
- captureLockFrameLo — sitzt.
- leftoverHoldNow leftoverHoldPrevOf — sitzt.
- pinByPrint ≥ — sitzt.
- leftoverPrintSharpOf — sitzt.
- Capture 420f — sitzt.

Neu:

- ** Bin-Trail in leftoverHoldTrailByHash `#bin` schreiben**, nicht nur filtern.
- ** Overlay VoiceOver HOLD roh/smooth** „gehalten null acht null“.
- ** JPEG 70 % + Blink 2-Frame** vor leftoverBaptize — Poster tauft nicht.
- ** gallery.json Schema 5 Capture-Hist + Hold-Bins** über App-Neustart.
- ** Per-Box CLAHE** statt Full-Frame.
- ** Shared XPC mit Helios** eine TCC, ein Buffer.

Nur main.
