# Nachtrag 2026-09-05 (2.1.88)

Siehe ANALYSE.md. **2.1.88** schließt Ghost-Tag-Floor, ¾-EMA, Impostor-Smooth, Nacht-Climb-Spike, FaceEngine Capture.

## In 2.1.88 gelandet

1. leftoverSessionCapture Live schlägt Ghost
2. leftoverHoldWriteOk Lookaway 0,28
3. leftoverPickPrint — Floor roh
4. leftoverHoldClimb — Nacht 0,61→0,66 bleibt
5. FaceEngine unknownCentroid(capture)
6. VERSION = Models = MARKETING_VERSION 2.1.88 (Build 114)

## In 2.1.87 gelandet

1. leftoverSessionCapture min(Ghost, Live)
2. unknownCentroid(capture) — Nacht 0,61 bleibt
3. leftoverHoldWriteOk(yawAbs) — Profil kein EMA
4. leftoverCosineSparkPut / Label — Overlay 0,64→0,90, Trail cap 8
5. leftoverBoxOrderGap 4 % + liveCentroidKeepsPrint
6. VERSION = Models = MARKETING_VERSION 2.1.87 (Build 113)

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
8. Live-ROI Crop im Detector — sitzt
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
23. Detector-NMS nach Kalman-Box — sitzt
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
35. Detector-Score ins leftoverPick als dritter Term — sitzt
36. Continuity Desk-View: Yaw-Floor 0,36 statt 0,28
37. Per-Identität Floor-Offset (±4) nach 3 False-Accepts
38. Keyboard-Return tauft Gast analog zweitem Tap
39. Face-ID an der Kiste (kurz, 6 Zeichen) analog Helios S1
40. Quality-weighted Gallery-Centroid — sitzt
41. Temporal print bank (5 Slots) Pose-Keys statt einer leftoverHold-EMA
42. Same-shot Twin: leftoverTwinHard schon bei 0,88 — sitzt
43. Aegis.dmg nicht ins Git — nur CI-Artefakt
44. ArcFace-Temperatur auf den Cosine (platt bei 0,70–0,90)
45. Masken-/Schal-Slot (untere Hälfte aus, Augen halten)
46. RTSP-Reconnect Exponential-Backoff statt hartem Drop
47. Multi-Cam-Triangulation für 3D-Slot
48. Watch-Haptik bei UNBEKANNT
49. Face-Clustering nach Burst (Galerie aufräumen)
50. Night-ISO Cap Pref, AE nicht 3 s jagen
51. Print-EMA nur Frames mit leftoverPrintSharp — Trail-Append sitzt
52. Kalman-Predict auch wenn Fremde Kiste da — sitzt
53. leftover Adopt blendet die Live-Box durch den alten Kalman — sitzt
54. Detector-NMS gegen Kalman-Predict-Box — sitzt
55. Exposure-Lock nach Latch-Reconnect 0,8 s — sitzt
56. ROI-Expand: Crop leer → 1,4×, dann volles Bild — sitzt
57. Kalman-Q aus Capture-Jump — sitzt
58. Left/Right-Box-Order als Twin-Prior — sitzt (Gap 4 % sitzt)
59. Shared AVCaptureSession via XPC mit Helios
60. CLAHE nur im ROI, nicht Full-Frame
61. Print-Bank 5 Pose-Slots (front/left/right/up/down) gewichtet
62. Overlay Ghost-Opacity = leftoverEmptySince / latch
63. leftoverBoxHash Pixel-Norm — sitzt
64. Hold-Hash 16 Bins wenn imageW≥1920 — sitzt (24 ab 4K)
65. Ghost-Box Aspect-Lock — sitzt
66. Unbekannte zweite Kiste: ROI aus — sitzt
67. leftoverKalman-Q aus Capture — sitzt
68. Quality-weighted Live-Centroid — sitzt (Profil-Filter sitzt)
69. Detector-Score als dritter leftoverPick-Term — sitzt
70. leftoverHoldLookup Exact vor Nachbar — sitzt
71. Cosine-Spark 8 Frames — Overlay sitzt
72. JPEG-Recompress-Probe. Print vor/nach 70 % JPEG — instabiler Print nicht taufen.
73. Session-Prior Licht — sitzt (Live, nicht Ghost)
74. Yaw-binned Print-Bank 5 Slots, leftoverHold nur frontal, Profil eigener Slot.
75. Softmax-Temperatur 16 auf Gallery-Scores, platt bei 0,70–0,90.
76. Walk-in Full-Frame alle 8 Ticks — sitzt
77. Blink-Liveness. Lid-Gap 2 Frames — Foto an der Wand tauft nicht.
78. Pupillenabstand als Scale-Prior. Geo unabhängig von Box-Größe.
79. Galerie Auto-Split nach 8 leftoverAmbiguous auf dieselbe UUID.
80. HomeKit-Klingel als RTSP-Quelle.
81. Gang als Soft-ReID. Box-Velocity-Signatur 1,2 s, nie Taufe allein.
82. White-Balance Freeze nach Latch analog Faust-AE.
83. 4K-Nachbar nicht geclippt — sitzt.
84. **Iris-Textur-Slot** (VNDetectFaceLandmarks pupil) als Twin-Veto.
85. **Time-of-day Prior** — Anna morgens, Gast abends, nie Taufe allein.
86. **Audio-Doorbell Sync** — Klingel-Frame bekommt leftoverLatch extra 1,2 s.
87. **Print-Drift Alarm** nach OS-Update, nicht nur Banner.
88. **Kalman-Box 3D** aus yaw/pitch, Ghost folgt der Kopfdrehung.
89. Profil kein Hold-EMA — sitzt (jetzt ¾ 0,28).
90. unknownCentroid Session-Floor — sitzt (FaceEngine Capture sitzt).
91. 4K Order-Gap 4 % — sitzt.
92. **per-Box Capture** statt min(alle Live). Gast im Schatten senkt Annas Floor nicht.
93. **Hold-EMA α aus Capture-Jump.** AE-Sprung 0,20 → α 0,08, nicht 0,35.
94. **Gallery-Print nur leftoverPrintSharp ∧ frontal>0,7.** ¾ in der Galerie zieht den Centroid.
95. **Twin-Pair Cosine in leftoverScore** als vierter Term, nicht nur Veto.
96. **Session-Luma aus Frame-Histogram**, nicht aus Box-Capture. Center Stage täuscht Box-Luma.
97. **unknownCentroid Yaw** — Profil 0,65 bei Floor 0,70 ist unbekannt, nicht Genuine 0,62.
98. **Overlay „HOLD roh/smooth“** zwei Zahlen, Smooth-Taufe sichtbar.
99. **Face-Print Byte-Salt** nach OS-Update, alte gallery.json nicht still matchen.
100. Live-Tag schlägt Ghost — sitzt.
101. Print-Floor roh — sitzt.
102. Nacht-Climb kein Spike — sitzt.

Nur main.
