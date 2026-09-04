# Nachtrag 2026-09-04 (2.1.75)

Siehe ANALYSE.md. **2.1.75** schließt WEG auf Live-Kiste, Live-Yaw, UNBEKANNT-Streak, Tauf-Streak, TWIN? 0,90 wirklich im Code.

## In 2.1.75 gelandet

1. leftoverLookawayPin — WEG auf Live, nicht Ghost-ID
2. leftoverLookawayYawOf — Live-Yaw sticht Ghost
3. leftoverHoldSkipLookaway — EMA freeze
4. leftoverUnknownKeepsStreak — kein Gast n+1
5. leftoverStreakKeepsLive — Blink re-adoptiert
6. leftoverTwinPairLabel TWIN? 0,90 / TWIN 0,93
7. VERSION = Models = MARKETING_VERSION 2.1.75 (Build 101)

## In 2.1.74 gelandet

1. Testdaten holen in der App (LFW → Downloads/AegisBench)

## In 2.1.73 gelandet

1. leftoverStreakBoxWrite — Streak- und Pick-IoU Kalman
2. leftoverLookawayHolds + WEG — Freeze ohne Clear
3. persistGuestTap — zweiter Overlay-Tap schreibt
4. leftoverBaptizeStillBlocks 0,45 s — Vorbeigehen tauft nicht
5. leftoverUnknownHard UNBEKANNT
6. leftoverTwinPairLabel TWIN 0,93
7. leftoverTransfersId stillFor
8. VERSION = Models = MARKETING_VERSION 2.1.73 (Build 99)

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
30. Live-HUD „gehalten 0,64 · Ghost 0,8 s“ in einer Zeile
31. PhotoKit Personen-UUID als Soft-Prior
32. RTSP-Keyframe leftoverHoldSurvive analog Detector-Miss
33. Burst-AE 5-Frame-Fenster Pref für Continuity-Nacht
34. Dropout-TTL Pref (kurz/normal/lang)
35. Capture-Hist in gallery.json Schema 5
36. CLAHE vor Print nur wenn captureJumpBlocks
37. Status „Hold prune n“ Pref still/eine Zeile
38. EMA-α Pref (träge / normal / flink)
39. Ghost-Kiste Opacity 0,35 Pref
40. Merge-Wizard Rename-Lock
41. Twin-Hard-Veto Pref 0,90 / 0,92 / 0,94
42. printPin Burst-Hist der Ghost-UUID beim Adopt
43. Detector-Score ins leftoverPick als dritter Term
44. Continuity Desk-View: Yaw-Floor 0,36 statt 0,28
45. Familien-Foto: leftoverTwinHard nur wenn Gallery ≥ 2 und same-shot
46. Tap-Lock Box-Stroke amber Pref
47. Helios-Steal-Palm: wenn Helios LOCK, Aegis leftover freeze
48. Per-Identität Floor-Offset (±4) nach 3 False-Accepts
49. Landmark-Jitter Poster-Streak in leftoverPick
50. Overlay-Tap Gast Bestätigen 2. Tap sitzt — Keyboard-Return analog
51. Lookaway leftoverHold halten sitzt — HUD WEG sitzt jetzt am Face; Countdown analog Helios IDLE in noch offen
52. Still-Hold 0,45 s sitzt — Pref 0,30 / 0,45 / 0,70
53. Open-Set UNBEKANNT sitzt — Gast-Index nach 8 s Pref
54. Kalman-Streak sitzt — leftoverStreak nach Ghost-Adopt Trail übernehmen sitzt
55. Twin-Zahl sitzt — Soft-Veto 0,90 als `TWIN? 0,90` sitzt
56. Live-HUD Ghost-Countdown analog Helios IDLE in — Chip sitzt am Face, nicht Statuszeile
57. Enrolled Lookaway: leftoverHold EMA einfrieren sitzt
58. Partial-Print P-Slot ohne Augen als eigener leftoverPick-Term
59. Gallery-Export verschlüsselt
60. Brille / Maske Slot UI
61. ByteTrack-ähnlicher leftover (Kalman + IoU + Print, nicht nur IoU-first)
62. Quality-weighted Gallery-Centroid (Schärfe × Frontal)
63. Shared AVCaptureSession mit Helios über XPC
64. WEG-Countdown „WEG in 0,8 s“ analog Helios IDLE in
65. Overlay Keyboard-Return tauft Gast analog zweitem Tap

Nur main.
