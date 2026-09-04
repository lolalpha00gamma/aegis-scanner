# Nachtrag 2026-09-04 (2.1.69)

Siehe ANALYSE.md. **2.1.69** schließt Partial-Ghost (auch enrolled), Blur-Gate, Kalman-Hash und mittlere-Box-Radius wirklich im Code.

## In 2.1.69 gelandet

1. leftoverDropped — Partial- und Voll-Dropout ghosten enrolled
2. Kalman/Euro für Dropped, leftoverHashBox vor Hash
3. leftoverBlurBlocks — 0,64 blur kein Pick, 0,80 trotz Blur
4. Nachbar-Radius 2 bei w/h-Bin ≤ 2
5. VERSION = Models = MARKETING_VERSION 2.1.69 (Build 95)

## In 2.1.68 gelandet

1. leftoverAllowsCrossSlot — F→¾→P mit Print ≥ 0,64
2. leftoverHoldsTrack — 0,64 Overlay, kein Gast, kein UUID-Steal
3. leftoverAdoptReady nur bei leftoverPrintOk(holdPrev)
4. kleine Box: Nachbar-Radius 2
5. centroidWeight in meanPrintVector / Partial / printWeights
6. leftoverHoldSurvive — UUID-Hold/Trail/Slot am Ghost nach Dropout
7. VERSION = Models = MARKETING_VERSION 2.1.68 (Build 94)

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
27. Hash-Bins komplett adaptiv (Radius 2 bis Bin 2 ist der kleine+mittlere Fall)
28. Overlay VoiceOver für Hold-Wert
29. Partial-Print für Profil (P-Slot ohne Augen)
30. Gallery-Centroid nur Frames mit leftoverPrintSharp
31. Live-HUD „gehalten 0,64 · Ghost 0,8 s“
32. Twin-Pair Cosine ins Overlay, nicht nur TWIN
33. Dropout-TTL an liveDt: 8 fps 1,6 s, 24 fps 1,2 s
34. Enrolled-Print nicht mit Blur-Frame überschreiben (holdStillSkip sitzt, Capture-Jump noch)
35. PhotoKit Personen-UUID als Soft-Prior
36. RTSP-Keyframe leftoverHoldSurvive analog Detector-Miss
37. Name-Lock 3 s nach manuellem Tap, leftover darf nicht taufen
