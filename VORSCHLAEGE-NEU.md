# Nachtrag 2026-09-04 (2.1.68)

Siehe ANALYSE.md. **2.1.68** schließt Cross-Slot-Hold, Hold-ohne-Steal, leftoverHold über Dropout, kleine-Box-Radius und Centroid-Gewicht wirklich im Code.

## In 2.1.68 gelandet

1. leftoverAllowsCrossSlot — F→¾→P mit Print ≥ 0,64
2. leftoverHoldsTrack — 0,64 Overlay, kein Gast, kein UUID-Steal; Streak erst bei Transfer weg
3. leftoverAdoptReady nur bei leftoverPrintOk(holdPrev)
4. kleine Box: Nachbar-Radius 2
5. centroidWeight in meanPrintVector / Partial / printWeights
6. leftoverHoldSurvive — UUID-Hold/Trail/Slot am Ghost nach Dropout
7. VERSION = Models = MARKETING_VERSION 2.1.68 (Build 94)

## In 2.1.67 gelandet

1. leftoverPinned aus liveGhosts nach Dropout
2. leftoverBoxHashNeighbors cx/cy/w/h ±1
3. leftoverBaptizeSpike — 0,80 nach 0,64 kein UUID-Steal
4. leftoverHoldTrailByHash, Put seeded von Nachbarn
5. leftoverAdoptReady(holdPrev) skippt 1,2 s
6. VERSION = Models = MARKETING_VERSION 2.1.67 (Build 93)

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
27. Hash-Bins komplett adaptiv (Radius 2 ist der kleine Fall)
28. Blur-Gate vor leftoverPick
29. Kalman-Box vor Hash
30. Partial-Print für Profil (P-Slot ohne Augen)
31. Overlay VoiceOver für Hold-Wert
