# Nachtrag 2026-09-05 (2.1.85)

Siehe ANALYSE.md. **2.1.85** schließt leftoverHoldLookup Identity-Swap, 4K-Bins, ROI-Miss, Ghost-Aspect, Kalman-Q aus Capture.

## In 2.1.85 gelandet

1. leftoverHoldLookup / TrailLookup Exact vor Nachbar
2. leftoverBoxHashBins 12 / 16 / 24
3. liveRoiMissRetries / GoesFull / Expand
4. liveRoiPeriodicFull + liveRoiSkipsForStranger
5. leftoverGhostAspectLock
6. boxKalmanQ(captureJump)
7. VERSION = Models = MARKETING_VERSION 2.1.85 (Build 111)

## In 2.1.84 gelandet

1. leftoverBoxUnit / Hash imageW/H — Pixel nicht ein Bin
2. leftoverLiveHash — Hold/Trail dieselbe Normierung
3. leftoverTrailPut(sharpness:) — Blur kein Append
4. VERSION = Models = MARKETING_VERSION 2.1.84 (Build 110)

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
35. Detector-Score ins leftoverPick als dritter Term
36. Continuity Desk-View: Yaw-Floor 0,36 statt 0,28
37. Per-Identität Floor-Offset (±4) nach 3 False-Accepts
38. Keyboard-Return tauft Gast analog zweitem Tap
39. Face-ID an der Kiste (kurz, 6 Zeichen) analog Helios S1
40. Quality-weighted Gallery-Centroid (Schärfe × Frontal) — Math sitzt, leftover-Trail ist Cosine
41. Temporal print bank (5 Slots) Pose-Keys statt einer leftoverHold-EMA
42. Same-shot Twin: zwei Gesichter im Frame → leftoverTwinHard schon bei 0,88 — sitzt
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
58. Left/Right-Box-Order als Twin-Prior (Anna links bleibt links)
59. Shared AVCaptureSession via XPC mit Helios
60. CLAHE nur im ROI, nicht Full-Frame
61. Print-Bank 5 Pose-Slots (front/left/right/up/down) gewichtet
62. Overlay Ghost-Opacity = leftoverEmptySince / latch
63. leftoverBoxHash Pixel-Norm — sitzt
64. Hold-Hash 16 Bins wenn imageW≥1920 — sitzt (24 ab 4K)
65. Ghost-Box Aspect-Lock: Predict ändert cx/cy, nicht w/h — sitzt
66. Unbekannte zweite Kiste: ROI aus, Full-Frame ein Tick — sitzt
67. leftoverKalman-Q aus Capture analog Helios luma-Q — sitzt (boxKalmanQ)
68. Quality-weighted Live-Centroid (Schärfe × Frontal × 1−|yaw|)
69. Detector-Score als dritter leftoverPick-Term
70. leftoverHoldLookup Exact vor Nachbar — sitzt
71. **Cosine-Spark 8 Frames im Overlay.** Hold 0,64→0,90 sichtbar, nicht nur Label.
72. **JPEG-Recompress-Probe.** Print vor/nach 70 % JPEG — instabiler Print nicht taufen.
73. **Session-Prior Licht, nicht Demografie.** Indoor-Luma hält Floor −2 für 30 s.
74. **Yaw-binned Print-Bank** 5 Slots, leftoverHold nur frontal, Profil eigener Slot.
75. **Softmax-Temperatur 16** auf Gallery-Scores, platt bei 0,70–0,90.
76. **Walk-in Full-Frame alle 8 Ticks** — sitzt (liveRoiPeriodicFull).

Nur main.
