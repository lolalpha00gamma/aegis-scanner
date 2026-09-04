# Nachtrag 2026-09-04

Siehe ANALYSE.md. **2.1.64** schließt leftoverHold-Dropout, Streak-Since und stilles Gast-Persist, die 2.1.63 offen ließ.

## In 2.1.64 gelandet

1. leftoverHold keyed by Box-Hash über Dropout
2. leftoverStreakSince in gallery.json Schema 4
3. Gast nur nach Tauf-Button, nie 8 s silent
4. Farbenblind Ampel-Glyphen + VoiceOver-Pattern
5. CLAHE-Banner Continuity-Nacht, liveROI Math

## In 2.1.63 gelandet

1. leftoverTransfersId — UUID/Print nur Baptize 0,80
2. Gast 1 / Gast 2 über guestOrder, Overlay vor pinned Name
3. CI macos-26, Tests zuerst, arm64

## In 2.1.62 gelandet

1. ReID-Konflikt-Tick (BOX|PRINT|GEO|LOCK einig) — `matchLive` + leftoverPick, Overlay `KONFLIKT`
2. Per-Kamera-Centroid — Cache-Key `builtin` / `continuity`
3. Enrollment-Burst schärfstes Ref — `enrollBurstReplace` statt Drop
4. Live-FAR Ticker — Floor-Hint
5. Guest persist Schema 3 — Restore-Gate + Helpers; Identity-Write nach 8 s leftover **→ 2.1.64 nie silent**. Overlay Gast 1/2 **→ 2.1.63**.

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
8. Live-ROI Crop im Detector
9. CLAHE auf den Buffer, nicht nur Banner
10. Print-Revision-Banner nach OS-Update
11. Zwei-Kamera-Live
12. Drop-in `.mlmodel`
13. Platt-Skalierung der Sigmoid
14. DBSCAN vor Merge
15. VoiceOver spricht den Namen
16. Watch-Folder PhotoKit
17. Aktives Lernen nur 0,86–0,94
18. Identity-Graph als Soft-Prior, nie Taufe
19. PnP 6DoF, Slot folgt der Nase
20. Family-Bump UI neben Open-Set
21. Print-MAD > 0,04 wirft Spike
22. Gallery-at-rest FileVault-Hinweis
23. Temporal ReID über Hold-Trail
24. Quality-weighted Centroid
25. Encrypted gallery export
