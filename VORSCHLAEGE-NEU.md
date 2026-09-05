# Nachtrag 2026-09-05 (2.1.89)

Siehe ANALYSE.md. **2.1.89** schließt Gast-Schatten-Floor, Profil-unknownCentroid, AE-Hold-EMA.

## In 2.1.89 gelandet

1. leftoverSessionCaptureBox — per-Box Capture
2. leftoverPick capture: [Int: Double]
3. unknownCentroid(yawAbs) — Profil 0,65 unbekannt
4. leftoverHoldAlpha(captureJump) — AE 0,20 → α 0,08
5. FaceEngine reicht Yaw
6. VERSION = Models = MARKETING_VERSION 2.1.89 (Build 115)

## In 2.1.88 gelandet

1. leftoverSessionCapture Live schlägt Ghost
2. leftoverHoldWriteOk Lookaway 0,28
3. leftoverPickPrint — Floor roh
4. leftoverHoldClimb — Nacht 0,61→0,66 bleibt
5. FaceEngine unknownCentroid(capture)
6. VERSION = Models = MARKETING_VERSION 2.1.88 (Build 114)

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
29. Gallery-Centroid nur Frames mit leftoverPrintSharp
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
74. Yaw-binned Print-Bank 5 Slots, leftoverHold nur frontal, Profil eigener Slot.
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
92. **per-Box Capture** — sitzt.
93. **Hold-EMA α aus Capture-Jump** — sitzt.
94. **Gallery-Print nur leftoverPrintSharp ∧ frontal>0.7.** ¾ in der Galerie zieht den Centroid.
95. **Twin-Pair Cosine in leftoverScore** als vierter Term, nicht nur Veto.
96. **Session-Luma aus Frame-Histogram**, nicht aus Box-Capture. Center Stage täuscht Box-Luma.
97. **unknownCentroid Yaw** — sitzt.
98. **Overlay „HOLD roh/smooth“** zwei Zahlen, Smooth-Taufe sichtbar.
99. **Face-Print Byte-Salt** nach OS-Update, alte gallery.json nicht still matchen.
103. **Specular-Highlight auf Stirn** als Card-Photo-Veto. Poster/Ausweis tauft nicht.
104. **Identity-Night-Floor.** Anna immer indoor: Session-Drop nur für Unbekannte, nicht für sie.
105. **Capture-Histogram 8 Frames.** Flash 1 Tick senkt nicht den Floor. Median, nicht min.
106. **Outdoor-WB als Capture-Prior.** 5600 K + hohe Luma = Tag, auch wenn Box dunkel (Gegenlicht).
107. **Continuity LiDAR-Z** als Twin-Trennung. Zwei Köpfe, Δz > 0,35 m, kein leftoverSteal.
108. **Overlay Capture-Chip `CAP 0,18`** neben HOLD — Nacht-Floor sichtbar.
109. **gallery.json printRevision.** VNFaceLandmarks-Bump → Banner, alte Prints nicht matchen.
110. **Per-Box CLAHE** nur auf die Face-ROI, Full-Frame frisst AE.
111. **Yaw-binned leftoverHold** 3 Slots (front / ¾ / profile), nicht eine EMA für alle Posen.
- Live-Tag schlägt Ghost — sitzt.
- Print-Floor roh — sitzt.
- Nacht-Climb kein Spike — sitzt.
- per-Box Capture — sitzt.
- unknownCentroid Yaw — sitzt.
- Hold-EMA AE-Sprung — sitzt.

Nur main.
