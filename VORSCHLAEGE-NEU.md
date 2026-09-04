# Nachtrag 2026-09-04 (2.1.72)

Siehe ANALYSE.md. **2.1.72** schließt Trail-Kalman-Lookup, EMA an dt, Twin-Hard-Veto 0,92, Lookaway-Freeze, Rename-Lock, Ghost-Overlay, AE/GHOST-Chips, Gast-Taufen wirklich im Code.

## In 2.1.72 gelandet

1. leftoverTrailWriteHash — Trail Put/Lookup Kalman, nicht Roh-Box
2. leftoverHoldAlpha(dt) — 8 fps Spike 0,06 dämpft
3. leftoverTwinHardBlocks 0,92 — auch Baptize tot
4. leftoverLookawayBlocks — enrolled Yaw freeze
5. renameIdentity Tap-Lock 3 s
6. ghostFaces Overlay + GHOST n,s Chip
7. exposureLockLabel AE n,s
8. tapGuestSuggests TAUFEN?
9. leftoverHoldPruneLine liveEmpty — Partial still
10. TAP nicht leftover-orange
11. VERSION = Models = MARKETING_VERSION 2.1.72 (Build 98)

## In 2.1.71 gelandet

1. printTrailKeepsOnGhostAdopt — Ghost-Adopt wischt Median nicht
2. leftoverHoldWriteHash — Put Kalman, nicht Roh-Box
3. tapOverlay 3 s — Overlay-Tap sperrt leftover, Chip TAP ns
4. captureBurstBlocksPrint — AE-Burst 3 Frames, enrolled
5. exposureLockHold(dt) — 8 fps 0,40 s
6. overlayBoxDash / .ghost — leftover gestrichelt, kein Gast-Sprung
7. leftoverHoldPruneLine — Status eine Zeile
8. VERSION = Models = MARKETING_VERSION 2.1.71 (Build 97)

## In 2.1.70 gelandet

1. leftoverHoldSurvive live+Ghost — Partial wischt Live nicht, Stale weg
2. Trail/Kalman/Euro für Dropped
3. captureJumpBlocksPrint — enrolled AE-Sprung hält Gallery-Print
4. dropoutTTL / liveGhostHold(dt) — 8 fps 1,6 s
5. tapNameLock 3 s — leftover tauft nicht nach manuellem Tap
6. Hash-Lookup Kalman nach Dropout
7. VERSION = Models = MARKETING_VERSION 2.1.70 (Build 96)

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
22. Encrypted gallery export
23. Detector-NMS nach Kalman-Box
24. Helios-Palm als Attention-Kegel
25. Merge-Wizard Undo 30 s
26. Temporal ReID-Graph über Hold-Trail
27. Overlay VoiceOver für Hold-Wert
28. Partial-Print für Profil (P-Slot ohne Augen)
29. Gallery-Centroid nur Frames mit leftoverPrintSharp
30. Live-HUD „gehalten 0,64 · Ghost 0,8 s“ — Ghost-TTL-Chip sitzt, Hold+TTL in einer Zeile noch Mix
31. Twin-Pair Cosine ins Overlay, nicht nur TWIN (Hard-Veto sitzt)
32. PhotoKit Personen-UUID als Soft-Prior
33. RTSP-Keyframe leftoverHoldSurvive analog Detector-Miss
34. Burst-AE sitzt 3 Frames — 5-Frame-Fenster Pref für Continuity-Nacht
35. Dropout-TTL Pref (kurz/normal/lang)
36. Twin-Pair Overlay-Zahl `0,93` neben TWIN, nicht nur Veto
37. Capture-Hist in gallery.json Schema 5 (Burst über Restore)
38. CLAHE vor Print nur wenn captureJumpBlocks, nicht dauernd
39. Status „Hold prune n“ sitzt nur leerer Frame — Pref still/eine Zeile
40. Overlay-Tap Gast TAUEN? sitzt — Bestätigen-Button 2. Tap persistiert
41. Lookaway-Freeze sitzt — HUD `WEG` analog Helios LOCK
42. EMA-α Pref (träge / normal / flink) unabhängig von dt
43. Ghost-Kiste Opacity 0,35 Pref
44. Rename-Lock sitzt — Merge-Wizard Rename noch offen
45. Kalman-Hash Trail sitzt — leftoverStreakBox noch Mix Roh
46. AE-Chip sitzt — Ampel gelb während Lock, nicht nur Text
47. Twin-Hard-Veto Pref 0,90 / 0,92 / 0,94
48. Enrolled Lookaway: leftoverHold halten (nicht nur Pick nil), analog Helios Freeze-Cursor
49. printPin Burst-Hist der Ghost-UUID beim Adopt übernehmen
50. Live-HUD Ghost-Countdown analog Helios IDLE in — Chip sitzt am Face, nicht Statuszeile
51. Gallery-Export `.aegis` verschlüsselt, Passphrase im Schlüsselbund
52. Detector-Score ins leftoverPick als dritter Term (Box×Print×Det)
53. Continuity Desk-View: Yaw-Floor 0,36 statt 0,28 (Webcam von oben)
54. Familien-Foto: leftoverTwinHard nur wenn Gallery ≥ 2 und same-shot
55. Still-Hold 0,45 s vor Baptize auch ohne leftoverHold (erste Begegnung)
56. Tap-Lock Farbe: TAP-Chip amber sitzt im Text — Box-Stroke amber Pref
57. Helios-Steal-Palm: wenn Helios LOCK, Aegis leftover freeze (Frame-Pump)
58. Open-Set 0,50–0,62: `UNBEKANNT` hart, kein Gast-Index-Sprung
59. Landmark-Jitter in leftoverPick: Poster-Streak blockt Adopt auch ohne MAD
60. Per-Identität Floor-Offset (±4) nach 3 False-Accepts

Nur main.
