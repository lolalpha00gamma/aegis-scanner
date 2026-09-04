# Nachtrag 2026-09-04 (2.1.70)

Siehe ANALYSE.md. **2.1.70** schließt leftoverHoldSurvive auf Partial, Dropout-TTL an dt, Capture-Jump auf Enrolled-Print, Tap-Name-Lock 3 s wirklich im Code.

## In 2.1.70 gelandet

1. leftoverHoldSurvive live+Ghost — Partial wischt Live nicht, Stale weg
2. Trail/Kalman/Euro für Dropped
3. captureJumpBlocksPrint — enrolled AE-Sprung hält Gallery-Print
4. dropoutTTL / liveGhostHold(dt) — 8 fps 1,6 s
5. tapNameLock 3 s — leftover tauft nicht nach manuellem Tap
6. Hash-Lookup Kalman nach Dropout
7. VERSION = Models = MARKETING_VERSION 2.1.70 (Build 96)

## In 2.1.69 gelandet

1. leftoverDropped — Partial- und Voll-Dropout ghosten enrolled
2. Kalman/Euro für Dropped, leftoverHashBox vor Hash
3. leftoverBlurBlocks — 0,64 blur kein Pick, 0,80 trotz Blur
4. Nachbar-Radius 2 bei w/h-Bin ≤ 2
5. VERSION = Models = MARKETING_VERSION 2.1.69 (Build 95)

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
34. Enrolled-Print nicht mit Blur-Frame überschreiben sitzt im IoU+printPin; Capture-Jump sitzt — Burst-AE über 3 Frames noch
35. Tap-Lock HUD im Overlay neben TAP ns (Farbe)
36. Dropout-TTL Pref (kurz/normal/lang)
37. livePrintTrail nach Ghost-Adopt nicht wipe (printPin löscht Trail noch)
38. Name-Lock 3 s auch nach Overlay-Tap, nicht nur Anlegen/+
39. Kalman-Hash in leftoverHoldPut (Write noch Roh-Box der adopted Kiste)
40. Ghost-Overlay gestrichelt statt Gast-Sprung
41. Exposure-Lock Hold 0,20 s an 8 fps auf 0,40 s
42. leftoverHoldSurvive prune-Log im Status eine Zeile

Nur main.
