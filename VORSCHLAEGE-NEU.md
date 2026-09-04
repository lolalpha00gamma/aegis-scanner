# Nachtrag 2026-09-04 (2.1.71)

Siehe ANALYSE.md. **2.1.71** schließt printPin-Trail, Kalman-Hash im Put, Overlay-Tap-Lock, Burst-AE 3 Frames, Exposure 8 fps 0,40 s, leftover gestrichelt wirklich im Code.

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
30. Live-HUD „gehalten 0,64 · Ghost 0,8 s“
31. Twin-Pair Cosine ins Overlay, nicht nur TWIN
32. PhotoKit Personen-UUID als Soft-Prior
33. RTSP-Keyframe leftoverHoldSurvive analog Detector-Miss
34. Burst-AE sitzt 3 Frames — 5-Frame-Fenster Pref für Continuity-Nacht
35. Tap-Lock Farbe: TAP-Chip amber, leftover orange, nicht beides Hue
36. Dropout-TTL Pref (kurz/normal/lang)
37. Name-Lock nach Overlay-Tap sitzt — nach Keyboard-Rename noch offen
38. Ghost-Kiste als echtes Overlay (liveGhosts zeichnen), nicht nur Dash am Adopt
39. Exposure-Lock HUD `AE 0,3 s` neben TAP
40. leftoverHoldSurvive prune-Log Pref (still / eine Zeile)
41. Kalman-Hash auch leftoverTrailPut (Trail-Write noch Mix)
42. printPin + IoU: Burst-Hist der Ghost-UUID beim Adopt übernehmen
43. Overlay-Tap auf Gast = Tauf-Vorschlag, nicht nur Select
44. Capture-Hist in gallery.json Schema 5 (Burst über Restore)
45. 8 fps: leftoverHoldEMA alpha an dt, sonst Spike 0,06 in einem Tick
46. CLAHE vor Print nur wenn captureJumpBlocks, nicht dauernd
47. Twin-Pair ins leftoverPick als Hard-Veto über 0,92
48. Helios-Steal analog: leftover Freeze wenn enrolled wegsieht, nicht taufen
49. Status „Hold prune n“ nur bei leerem Frame, nicht Partial
50. Live-HUD Ghost-TTL Countdown analog Helios LOCK tot

Nur main.
