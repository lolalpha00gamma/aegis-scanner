# Nachtrag 2026-09-05 (2.1.95)

Siehe ANALYSE.md. **2.1.95** schließt Dropout-Hold je Bin, Overlay roh/smooth aus Trail, leftoverBaptizeBoth.

## In 2.1.95 gelandet

1. leftoverHoldLookupYaw — Dropout/holdPrev immer Yaw-Bin
2. leftoverHoldRawOf / leftoverHoldOverlayChip — Trail roh, Hold smooth
3. leftoverBaptizeBoth — roh UND smooth ≥ 0,80 (Math; TransfersId Spike-Pfad bleibt)
4. VERSION = Models = MARKETING_VERSION 2.1.95 (Build 121)

## In 2.1.94 gelandet

1. leftoverFrameCapture / leftoverFrameCaptureByte — 8×8 Buffer, leftoverPick frameCapture live
2. leftoverTrailPut(bin:) / leftoverTrailLookup(bin:) — ¾ liest nicht Frontal-Nachbar
3. leftoverHoldLabel(smooth:) — gehalten 0,80 / 0,64
4. VERSION = Models = MARKETING_VERSION 2.1.94 (Build 120)

## In 2.1.93 gelandet

1. leftoverCaptureHistOf — Box-Hist ≥ 3, Flash leftover
2. leftoverCaptureChip + leftoverHoldLabel yawAbs im Overlay
3. leftoverScoreHeat Temp 16 + leftoverScoreSoftmax Floor 0,55
4. VERSION = Models = MARKETING_VERSION 2.1.93 (Build 119)

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
9. CLAHE auf den Buffer, nicht nur Banner
10. Print-Revision-Banner nach OS-Update
11. Zwei-Kamera-Live
12. Drop-in .mlmodel
13. Platt-Skalierung der Sigmoid
14. DBSCAN vor Merge
15. VoiceOver spricht den Namen
16. Watch-Folder PhotoKit
17. Aktives Lernen nur 0,86–0,94
18. Identity-Graph als Soft-Prior, nie Taufe
19. PnP 6DoF, Slot folgt der Nase
20. Family-Bump UI neben Open-Set
21. Gallery-at-rest FileVault-Hinweis
22. Encrypted gallery export `.aegis`, Passphrase im Schlüsselbund
24. Helios-Palm als Attention-Kegel
25. Merge-Wizard Undo 30 s
26. Temporal ReID-Graph über Hold-Trail
27. Overlay VoiceOver für Hold-Wert
28. Partial-Print für Profil (P-Slot ohne Augen)
30. Burst-AE 5-Frame-Fenster Pref für Continuity-Nacht
31. Dropout-TTL Pref (kurz/normal/lang)
32. Capture-Hist in gallery.json Schema 5
33. EMA-α Pref (träge / normal / flink)
34. Twin-Hard-Veto Pref 0,90 / 0,92 / 0,94
36. Continuity Desk-View: Yaw-Floor 0,36 statt 0,28
37. Per-Identität Floor-Offset (±4) nach 3 False-Accepts
38. Keyboard-Return tauft Gast analog zweitem Tap
39. Face-ID an der Kiste (kurz, 6 Zeichen) analog Helios S1
41. Temporal print bank (5 Slots) Pose-Keys statt einer leftoverHold-EMA
43. Aegis.dmg nicht ins Git — nur CI-Artefakt
44. ArcFace-Temperatur auf den Cosine (platt bei 0,70–0,90)
45. Masken-/Schal-Slot (untere Hälfte aus, Augen halten)
46. RTSP-Reconnect Exponential-Backoff statt hartem Drop
47. Multi-Cam-Triangulation für 3D-Slot
48. Watch-Haptik bei UNBEKANNT
49. Face-Clustering nach Burst (Galerie aufräumen)
50. Night-ISO Cap Pref, AE nicht 3 s jagen
59. Shared AVCaptureSession via XPC mit Helios
60. CLAHE nur im ROI, nicht Full-Frame
61. Print-Bank 5 Pose-Slots (front/left/right/up/down) gewichtet
62. Overlay Ghost-Opacity = leftoverEmptySince / latch
72. JPEG-Recompress-Probe. Print vor/nach 70 % JPEG — instabiler Print nicht taufen.
75. Softmax-Temperatur 16 auf Gallery-Scores, platt bei 0,70–0,90.
77. Blink-Liveness. Lid-Gap 2 Frames — Foto an der Wand tauft nicht.
78. Pupillenabstand als Scale-Prior. Geo unabhängig von Box-Größe.
79. Galerie Auto-Split nach 8 leftoverAmbiguous auf dieselbe UUID.
80. HomeKit-Klingel als RTSP-Quelle.
81. Gang als Soft-ReID. Box-Velocity-Signatur 1,2 s, nie Taufe allein.
82. White-Balance Freeze nach Latch analog Faust-AE.
84. **Iris-Textur-Slot** (VNDetectFaceLandmarks pupil) als Twin-Veto.
85. **Time-of-day Prior** — Anna morgens, Gast abends, nie Taufe allein.
86. **Audio-Doorbell Sync** — Klingel-Frame bekommt leftoverLatch extra 1,2 s.
87. **Print-Drift Alarm** nach OS-Update, nicht nur Banner.
88. **Kalman-Box 3D** aus yaw/pitch, Ghost folgt der Kopfdrehung.
99. **Face-Print Byte-Salt** nach OS-Update, alte gallery.json nicht still matchen.
103. **Specular-Highlight auf Stirn** als Card-Photo-Veto. Poster/Ausweis tauft nicht.
104. **Identity-Night-Floor.** Anna immer indoor: Session-Drop nur für Unbekannte, nicht für sie.
106. **Outdoor-WB als Capture-Prior.** 5600 K + hohe Luma = Tag, auch wenn Box dunkel (Gegenlicht).
107. **Continuity LiDAR-Z** als Twin-Trennung. Zwei Köpfe, Δz > 0,35 m, kein leftoverSteal.
108. **Overlay Capture-Chip `CAP 0,18`** neben HOLD — Nacht-Floor sichtbar.
109. **gallery.json printRevision.** VNFaceLandmarks-Bump → Banner, alte Prints nicht matchen.
110. **Per-Box CLAHE** nur auf die Face-ROI, Full-Frame frisst AE.
114. **ArcFace temperature 16** auf leftoverScore, platt 0,70–0,90.
115. **Blink 2-Frame Lid-Gap** vor Taufe — Poster.
116. **JPEG 70 % Probe** vor leftoverBaptize.
119. **Capture-Hist 8 in gallery.json** Schema 5, Session über App-Neustart.
121. **leftoverHold hash# bins in gallery.json** — ¾ nach App-Neustart, TTL 8 s sonst.
124. **Yaw-binned Print-Bank 5 Slots**, leftoverHold nur frontal, Profil eigener Slot. Hash-Bin ist EMA, nicht Print.
126. **leftoverHoldTrail[id] je Bin** analog Hash. UUID-Trail mischt Frontal+¾ wenn der Kopf dreht. Overlay-Chip liest UUID-Trail.
127. **Taufe nur roh UND smooth ≥ 0,80.** leftoverBaptizeBoth sitzt. leftoverTransfersId Spike-3-Samples bleibt Roh. **→ 2.1.95 leftoverBaptizeBoth Math.**
128. **leftoverTrail Profil-TTL 2 s**, Frontal 8 s. ¾-Ghosts kleben sonst.
129. **CAP-Chip Frame/Box** `CAP 0,70/0,18` wenn Center Stage springt.
130. **leftoverFrameCapture in gallery.json** Session über App-Neustart, analog Capture-Hist.
131. **VoiceOver HOLD roh/smooth** getrennt: „gehalten null acht null, geglättet null sechs vier“.
132. **leftoverFrameCapture vs FaceEngine lumaStats** ±0,08 — sonst zwei Nacht-Quellen.
133. **leftoverTransfersId leftoverBaptizeBoth.** Math sitzt, Spike-Pfad nicht umgebaut.
134. **leftoverHoldChip compact `HOLD 80/64`** neben `gehalten 0,80 / 0,64`.
135. **leftoverHold pose tuple** leftoverHold[id] = (cosine, bin), nicht nur EMA.
136. **leftoverHoldLookupYaw ohne yawAbs** default frontal — Dropout ohne Quality.yaw darf ¾ nicht frontal lesen. lookYaw sitzt.
137. **leftoverHoldBins persist** App-Neustart analog Capture-Hist Schema 5.
138. **overlayName yawAbs** in leftoverHoldChip — zwei Overlay-Pfade ohne BIN.
- leftoverHoldLookupYaw Dropout — sitzt.
- Overlay roh/smooth aus Trail — sitzt.
- leftoverBaptizeBoth Math — sitzt.
- Pick-EMA AE — sitzt.
- Twin-Score — sitzt.
- Galerie frontal — sitzt.
- Capture-Median Helfer — sitzt.
- Hold-Bin Helfer — sitzt.
- leftoverHold[id:bin] — sitzt.
- Capture-Hist in leftoverPick — sitzt.
- ¾ erbt nicht Frontal — sitzt.
- leftoverHoldByHash je Bin — sitzt.
- leftoverPick Hash-Hold — sitzt.
- Frame-Luma vs Box (Math) — sitzt.
- Overlay BIN — sitzt.
- Frame-Luma live — sitzt.
- Trail je Bin — sitzt.
- HOLD roh/smooth Label — sitzt.

Nur main.
