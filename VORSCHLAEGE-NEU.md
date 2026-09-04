# Nachtrag 2026-09-04 (2.1.78)

Siehe ANALYSE.md. **2.1.78** schließt leeren-Frame-Streak, Yaw-Floor 0,70, Same-shot Twin 0,88 wirklich im Code.

## In 2.1.78 gelandet

1. leftoverEmptyKeepsStreak — Dropout hält Streak/Kalman
2. leftoverPrintFloor yaw — Profil 0,70 / Frontal 0,62
3. leftoverTwinHardVetoNow — zwei Gesichter 0,88
4. leftoverPick facesInFrame
5. VERSION = Models = MARKETING_VERSION 2.1.78 (Build 104)

## In 2.1.77 gelandet

1. leftoverHoldLabel sharpness — gehalten 0,62
2. leftoverLookawayPinsStranger — kein WEG auf Nachbar
3. leftoverMissAdvance 3 Frames
4. leftoverAdoptNeedSec 8 fps 0,6 s
5. leftoverTwinTint TWIN? amber / TWIN rot
6. VERSION = Models = MARKETING_VERSION 2.1.77 (Build 103)

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
8. Live-ROI Crop im Detector (Math sitzt, Detector nicht)
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
23. Detector-NMS nach Kalman-Box
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
40. Quality-weighted Gallery-Centroid (Schärfe × Frontal)
41. Temporal print bank (5 Slots) statt einer leftoverHold-EMA
42. Same-shot Twin: zwei Gesichter im Frame → leftoverTwinHard schon bei 0,88 — sitzt
43. Aegis.dmg nicht ins Git — nur CI-Artefakt
44. ArcFace-Temperatur auf den Cosine (platt bei 0,70–0,90)
45. Masken-/Schal-Slot (untere Hälfte aus, Augen halten)
46. RTSP-Reconnect Exponential-Backoff statt hartem Drop
47. Multi-Cam-Triangulation für 3D-Slot
48. Watch-Haptik bei UNBEKANNT
49. Face-Clustering nach Burst (Galerie aufräumen)
50. leftoverEmptyKeepsStreak sitzt
51. leftoverPrintFloor Profil 0,70 sitzt
52. leftoverTwinHardVetoNow 0,88 sitzt

Nur main.
