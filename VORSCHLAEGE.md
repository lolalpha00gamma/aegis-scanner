# Aegis — Vorschlagsliste

Stand: **2.1.80 alpha**. Aktueller Nachtrag: [VORSCHLAEGE-NEU.md](VORSCHLAEGE-NEU.md). Analyse: [ANALYSE.md](ANALYSE.md). Nur `main`. `bugfix` ist Altlast — nicht fortsetzen.

Neu in 2.1.80: Kalman am Ghost, Latch-Hold, leftoverPending bleibt.

## In 2.1.80 wirklich im Code

2.1.79 Overlay/Latch. Kalman tot am zweiten leeren Frame. emptyKeeps ewig. leftoverPending Wipe am Frame-Start.

1. **`leftoverKeepBoxes`.** used ∪ dropped ∪ ghosts ∪ hold.
2. **`leftoverLatchKeeps` + `leftoverEmptySince`.**
3. **leftoverPending** bleibt am Latch.
4. **`leftoverHoldSurvive(..., emptyFor:)`.**
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.80 (Build 106).

## In 2.1.70 wirklich im Code

2.1.69 leftoverDropped/Blur/Kalman. Survive nur leer. Trail nur used. printPin blendet AE-Sprung. Ghost-TTL fest 1,2 s. Tap-Name leftover tauft.

1. **`leftoverHoldSurvive(..., live:)`.** Keep = Ghosts ∪ Live.
2. **Trail/Kalman für Dropped.**
3. **`captureJumpBlocksPrint`.** Enrolled AE-Sprung hält Print.
4. **`dropoutTTL(dt)`.** 8 fps 1,6 s.
5. **`tapNameLock` 3 s.** leftoverTransfersId tot.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.70 (Build 96).

## In 2.1.69 wirklich im Code


2.1.68 Cross-Slot/Hold. Partial-Dropout ohne Ghost. Enrolled auf leerem Frame nicht geistert. Blur 0,64 war Pick.

1. **`leftoverDropped`.** Partial + leer, auch enrolled.
2. **Kalman/Euro für Dropped + leftoverHashBox.**
3. **`leftoverBlurBlocks`.**
4. **Nachbar-Radius 2 bei Bin ≤ 2.**
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.69 (Build 95).

## In 2.1.68 wirklich im Code

2.1.67 Ghost-Pool/Hash/Twin. Slot-Mismatch gab nil. Hold ohne Transfer machte Gast. holdPrev 0,00 skippte 1,2 s. Kleine Kiste sprang 2 Bins. centroidWeight unverdrahtet. Leerer Frame wischte UUID-Hold.

1. **`leftoverAllowsCrossSlot`.** F→¾→P mit Print ≥ 0,64.
2. **`leftoverHoldsTrack`.** Overlay halten, UUID und Live unangetastet. Streak erst bei Transfer/Gast weg.
3. **Adopt-Skip nur Print-Hold.** 0,10 skippt nicht.
4. **Kleine-Box-Radius 2.**
5. **`centroidWeight` in meanPrintVector / Partial / printWeights.**
6. **`leftoverHoldSurvive`.** Dropout: UUID-Hold, Trail, Slot am Ghost, nicht Wipe.
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.68 (Build 94).

## In 2.1.67 wirklich im Code


2.1.66 Hash überlebte Dropout, leftover las ihn nicht: previous leer, Ghosts nur in pinByPrint 0,80. Größe wechselte Bin. Transfer stahl UUID bei 0,82 nach 0,64. Trail UUID-keyed.

1. **Ghost-Pool.** leftoverPinned = previous + liveGhosts.
2. **Hash w/h ±1.** Größe-Jitter hält Hold.
3. **`leftoverBaptizeSpike`.** Twin 0,80 nach 0,64 kein Steal.
4. **Trail by Hash.** MAD überlebt Dropout.
5. **Adopt mit holdPrev.** 1 Frame, nicht 1,2 s extra.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.67 (Build 93).

## In 2.1.66 wirklich im Code

2.1.65 hat Nachbar-Hash und Print-MAD nur dokumentiert. Exact-Lookup, leerer Frame wischt Hash und Gast-Liste, MARKETING_VERSION 2.1.64.

1. **`leftoverBoxHashNeighbors` / Lookup.** cx/cy ±1, jüngster Nachbar, ferne Bins leer.
2. **Leerer Frame: TTL-Prune, kein Wipe** der Hash-Tabelle.
3. **`guestOrderKeeps` 8 s.** Unbekannt = Gast n+1.
4. **`printMADBlocks`.** ≥ 3 Samples, Peak−Median oder MAD > 0,04, Overlay `MAD`.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.66 (Build 92).

## Nächste (offen)

- Helios Frame-Pump, eine TCC. Gemeinsamer Buffer, eine Kamera-Session.
- CLAHE wirklich auf den PixelBuffer (Metal), nicht nur Banner.
- Brille-/Hut-Slot: eigener Centroid, Print ohne Augenbrauen-Band.
- Live-ROI Crop im Detector, nicht nur Math — 8 fps Continuity auf dem Gesicht.
- Drop-in `.mlmodel` neben Apple Print (ONNX/CoreML Slot).
- DBSCAN vor Merge statt nur Centroid 0,89–0,94.
- Zwei-Kamera-Live: Built-in + Continuity, IoU-Fusion nicht OR.
- Print-Revision-Banner nach OS-Update (Schema warnt, UI fordert Neu-Scan).
- VoiceOver spricht den Overlay-Namen, nicht nur Lampen-Pattern.
- Watch-Folder PhotoKit: neuer Shot → Enroll-Queue.
- Aktives Lernen nur 0,86–0,94, nie Open-Set-Müll.
- Identity-Graph als Soft-Prior (Familie), nie Taufe.
- PnP 6DoF, Slot folgt der Nase bei Yaw.
- Family-Bump UI neben Open-Set Slider.
- Gallery-at-rest FileVault-Hinweis beim ersten Persist.
- Temporal ReID über leftoverHold-Trail (3 Ticks, nicht 1 Cosine).
- ~~Quality-weighted Gallery-Centroid (scharf 2×, Blur 0,4×).~~ — 2.1.68 `centroidWeight` in mean/partial/printWeights.
- Enrollment aus Video-Keyframes, nicht nur Standbild.
- Export gallery.json encrypted (CryptoKit, Geräte-gebunden).
- Live-FAR Sparkline statt nur Floor-Hint.
- Unknown-Reject mit Open-Set-Energy, nicht nur Cosine-Floor.
- Alter/Geschlecht nur Prior, nie ID.
- Masken-Partial-Print aggressiver (untere Hälfte droppen).
- leftoverHold auch auf Slot F/3-4/P, nicht nur Box-Hash — Slot-Hold überlebt Dropout in 2.1.68, eigene Tabelle fehlt.
- Detector-NMS nach Kalman-Box (NMS auf geglätteter Box, nicht roh).
- Hash-Bins adaptiv an Box-Größe (große Kiste gröber).
- Merge-Wizard Undo 30 s.
- Gast als persistente Identity nach Tauf-Button — Math sitzt, UI-Draht nächste.
- Blur-Gate vor leftoverPick (Schärfe < 0,12 kein Hold).
- Kalman-Box vor Hash, nicht nur nach Track-Pin.
- Enroll-from-video: 1 Keyframe je Slot, nicht Burst derselben Pose.
- Overlay spricht den Hold-Wert (VoiceOver „gehalten null komma vierundsechzig“).
- Partial-Print für Profil (P-Slot ohne Augen).

## In 2.1.64 wirklich im Code (2.1.65 war Docs)

2.1.63 leftover stiehlt keine UUID, Gast 1/2. leftoverHold hing an der UUID — Dropout warf Hold. Streak-Since nur RAM. Gast hätte nach 8 s leftover still in gallery.json landen können. Ampel nur Farbe.

1. **`leftoverBoxHash` / `leftoverHoldLookup`.** Hold über Dropout, keyed by quantisierter Box, TTL 1,2 s. Exact-Hash — Nachbarn erst 2.1.66.
2. **gallery.json Schema 4.** `leftoverStreakSince` Encode/Decode, Restore lädt die Uhr.
3. **`guestPersistWrites`.** Nur Tauf-Button. Nie 8 s silent.
4. **Ampel-Glyphen.** ● ◐ ✕ plus VoiceOver-Pattern.
5. **CLAHE-Banner + `liveROI` Math.** Continuity-Nacht Overlay. Crop-Draht nächste.
6. Tests + VERSION = Models 2.1.64 (Build 91). 2.1.65 bumpte VERSION, nicht MatchMath.

## Nächste (offen)

- Helios Frame-Pump, eine TCC. Gemeinsamer Buffer, eine Kamera-Session.
- CLAHE wirklich auf den PixelBuffer (Metal), nicht nur Banner.
- Brille-/Hut-Slot: eigener Centroid, Print ohne Augenbrauen-Band.
- Live-ROI Crop im Detector, nicht nur Math — 8 fps Continuity auf dem Gesicht.
- Drop-in `.mlmodel` neben Apple Print (ONNX/CoreML Slot).
- DBSCAN vor Merge statt nur Centroid 0,89–0,94.
- Zwei-Kamera-Live: Built-in + Continuity, IoU-Fusion nicht OR.
- Print-Revision-Banner nach OS-Update (Schema warnt, UI fordert Neu-Scan).
- VoiceOver spricht den Overlay-Namen, nicht nur Lampen-Pattern.
- Watch-Folder PhotoKit: neuer Shot → Enroll-Queue.
- Aktives Lernen nur 0,86–0,94, nie Open-Set-Müll.
- Identity-Graph als Soft-Prior (Familie), nie Taufe.
- PnP 6DoF, Slot folgt der Nase bei Yaw.
- Family-Bump UI neben Open-Set Slider.
- Print-MAD > 0,04 wirft Spike, Overlay `MAD`.
- Gallery-at-rest FileVault-Hinweis beim ersten Persist.
- Temporal ReID über leftoverHold-Trail (3 Ticks, nicht 1 Cosine).
- Quality-weighted Gallery-Centroid (scharf 2×, Blur 0,4×).
- Enrollment aus Video-Keyframes, nicht nur Standbild.
- Export gallery.json encrypted (CryptoKit, Geräte-gebunden).
- Live-FAR Sparkline statt nur Floor-Hint.
- Unknown-Reject mit Open-Set-Energy, nicht nur Cosine-Floor.
- Alter/Geschlecht nur Prior, nie ID.
- Masken-Partial-Print aggressiver (untere Hälfte droppen).

## In 2.1.63 wirklich im Code

2.1.62 Konflikt-Tick und leftoverYieldsToLive. leftover taufte trotzdem bei Print 0,64: `adopted[bestJ].id = old.id` plus PrintVec. Overlay zeigte immer `Gast 1`. CI macos-14, Tests nach dem Build.

1. **`leftoverTransfersId`.** UUID und Print nur bei Baptize 0,80. 0,64 hält die Kiste, stiehlt keine Identität.
2. **`guestOrder` / `guestName`.** Overlay `Gast 1` / `Gast 2`. SwiftUI mutiert nicht.
3. **CI macos-26.** Tests zuerst, arm64, Signing wie Helios.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.63 (Build 90).

## Nächste (offen, 2.1.62 — erledigt in 2.1.63)

leftover-UUID-Steal und Gast-1-für-alle sitzen in 2.1.63. Gast als persistente Identity nach 8 s leftover fehlt (kein stilles Anlegen).

## In 2.1.62 wirklich im Code

2.1.61 Blink/Kalman/Split verdrahtet. leftover taufte trotzdem, wenn Print, Geo und Lock uneinig waren. Twin 0,91 still Anna. Ghost 0,64 stahl UUID. Burst droppte das schärfere Incoming. Built-in-Centroid auf Continuity. Overlay `KONFLIKT` saß auf der toten leftover-UUID und verschwand.

1. **`conflictTickAgrees`.** BOX/PRINT/GEO/LOCK einig, sonst keine Taufe. Geo votet erst ab Mix 42. `matchLive` nilt `decidedId`. Overlay `KONFLIKT` auf der **Live-Kiste**.
2. **`leftoverYieldsToLive`.** leftoverPick stiehlt keine schon live-getaufte UUID.
3. **`liveCentroidCacheKey(camera:)`.** `builtin` vs `continuity`.
4. **`enrollBurstReplace`.** Burst-Duplikat: schärferes Incoming ersetzt, unschärferes fällt.
5. **`liveFAR` / `liveFARLabel`.** Floor-Hint `FAR n%`.
6. **gallerySchema 3.** Restore warnt bei < 3. `guestPersistId` / `Keeps` / `leftoverStreakSincePersist` Math+Streak-Draht. Gast-Identity-Write nächste.
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.62 (Build 89).

## Nächste (offen, 2.1.61 — erledigt in 2.1.62)

Konflikt-Tick, leftover-Yield, Per-Kamera-Centroid, Burst-Replace, Live-FAR, Schema 3 sitzen in 2.1.62. Gast als persistente Identity nach 8 s leftover fehlt.

## In 2.1.61 wirklich im Code

2.1.60 Blink/Kalman/Split nur Math. Poster ohne Lid-Toggle, Continuity-Box hinter Sprung, leftover-Majority 10 Kreuz-Ticks still taufen.

1. **`posterNeedsBlink` verdrahtet.** Overlay `BLINK`.
2. **`boxKalman` 8 fps** statt 1-Euro. 24 fps bleibt 1-Euro.
3. **`clusterSplit` Overlay `SPLIT`.**
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.61 (Build 88).

## Nächste (offen, 2.1.60 — erledigt in 2.1.61)

Liveness-Blink, Box-Kalman, Cluster-Split sitzen in 2.1.61.

## In 2.1.60 wirklich im Code

2.1.59 leftover taufte Zwillinge 0,89–0,94 still. Pinned Overlay zeigte Anna bei leftover 0,64. Merge-Banner nur Top-1. Zwei Personen: Print OR Geo. leftoverScore additiv (0,05) zu schwach gegen Blur.

1. **`leftoverTwinSuggest` 0,89–0,94.** leftoverPick nil, Overlay `TWIN`.
2. **`leftoverShowsName` / `unknownStickyName`.** Overlay `Gast 1` bis Baptize 0,80.
3. **`mergeHintLabel` +N weitere.** Button mehrmals, Top bleibt Confirm.
4. **`twoPersonAnd`.** Gallery=2: Print und Geo einig, sonst keine Taufe.
5. **`leftoverScore` multiplikativ** 0,88–1,00 × Schärfe.
6. **`livenessBlink` / `posterNeedsBlink`.** Math; Jitter-Poster bleibt.
7. **`boxKalman` 8 fps.** Math.
8. **`clusterSplit` 10 Ticks.** Math.
9. Tests + VERSION = Models = MARKETING_VERSION 2.1.60 (Build 87).

## Nächste (offen, 2.1.59 — erledigt in 2.1.60)

Twin-Wizard leftover, Gast-Sticky, Merge-Liste, Print+Geo AND, Score×Schärfe sitzen in 2.1.60.

## In 2.1.59 wirklich im Code

2.1.58 Merge-Schwelle / Open-Set-Math — leftover taufte Profil-Ghosts, Poster, AE-Sprünge, Maske-Full-Print. Wizard fehlte.

1. **`leftoverPickAspect` / aspectOk.** Schmal nur Baptize 0,80.
2. **`unknownCentroid`** in matchLive und leftoverPick.
3. **`partialPrintMasked`** Match gegen meanPartialVector.
4. **Poster-Jitter** 4 Frames, leftover `POSTER`.
5. **`captureJumps` + AE-Lock 200 ms.**
6. **`printCommitMedian`** leftover-Trail, Overlay `MED`.
7. **Merge-Banner + `mergeIdentities`.**
8. **Open-Set im `floorHint`.**
9. Tests + VERSION = Models = MARKETING_VERSION 2.1.59 (Build 86).

## Nächste (offen, 2.1.58 — erledigt in 2.1.59)

Poster/AE/Partial/Unknown-Centroid/Aspekt/Merge-UI/Open-Set-Label sitzen in 2.1.59.

## In 2.1.58 wirklich im Code

2.1.56 leftover-EMA nach Pick, Cache FIFO, Open-Set Floor tot. 2.1.57 Yaw/Majority, Hold blieb Display.

1. **`leftoverHoldSmooth` / `leftoverHoldBlocks`.** Spike ≥ 0,04 ohne 0,80 vor leftoverPick.
2. **`printCacheTouch`.** LRU-Hit ans Ende.
3. **`unknownRejectFloor(slider:)`.** Slider-28, Clamp 40–70. matchLive.
4. **`mergeSuggest` 0,89–0,94.**
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.58 (Build 85).

## Nächste (offen, 2.1.57 — erledigt in 2.1.58)

leftover-Hold vor Pick, echter LRU, Open-Set-Slider, Merge-Schwelle sitzen in 2.1.58.

## In 2.1.57 wirklich im Code

2.1.56 leftover Slot-hart — Yaw ignoriert, 2-opt ein Tick, Print-Budget tot, Name-Lock Overlay ohne TTL-Chip.

1. **`leftoverPick(yawAbs:)`** Penalty 0,12.
2. **`leftoverAssignMajority` 3 Frames.** Overlay `MAJ n/3`.
3. **`printBudgetSkip`.** 24 fps visMs > 18, 8 fps nie.
4. **`nameLockTTLLabel`** in `voteProgress`.
5. **`posterFaceReject` / `boxAspectFrontal` / `printCommitMedian` / `exposureLock` / `partialPrintMasked` / `unknownCentroid`.**
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.57 (Build 84).

## Nächste (offen, 2.1.56 — erledigt in 2.1.57)

Yaw-Slot leftoverPick, leftover-Assign Majority, Print-Budget, Name-Lock Overlay-TTL sitzen in 2.1.57. Poster/AE-Lock/Partial-Print/Unknown-Centroid sind Math — Wiring nächste.

## In 2.1.56 wirklich im Code

2.1.55 Ghost=leftover — Desk-View gespiegelt, Dropout-dt 0,50 s, Name-Lock ohne TTL, Idle 8 fps beim Blinker, Print-Cache kalt, leftover-Hold roh, Live-NMS tot.

1. **`mirrorAsFront`.** Desk-View nie.
2. **`medianLiveDt`.** leftover-Need folgt Median, nicht Spike.
3. **`nameLockVoteTTL` 8 s** in `nameLockHolds`.
4. **`liveFacesLatch`.** 2 Frames bevor 8 fps.
5. **`liveDuplicate` 0,45 / nested 0,55.** Foto 0,42 bleibt.
6. **`leftoverHoldEMA`.**
7. **`printCacheDropCount`.** LRU/FIFO, nicht removeAll.
8. Tests + VERSION = Models = MARKETING_VERSION 2.1.56 (Build 83).

## Nächste (offen, 2.1.55 — erledigt in 2.1.56)

Desk-View-Spiegel, Median-dt, Name-Lock-TTL, Face-Hysterese, Live-NMS, leftover-EMA, Print-Cache sitzen in 2.1.56.

## In 2.1.55 wirklich im Code

2.1.54 Print-Fallback — Ghost 1,8 > leftover 1,2. leftover in Frames. Kamera-Puffer plus CI-Rotate. 2 fps Idle. Open-Set tot.

1. **`liveGhostHold` = leftoverAdoptSec.**
2. **leftover in Sekunden.** `leftoverAdoptReady(elapsed:streak:)`. Overlay `1/10` Zehntel.
3. **`unknownReject` 50 %.**
4. **RotationCoordinator** + Vision `.up`.
5. **Idle 5 fps.** Wipe-Mute nur Hist < 4. Overlay STUMM folgt derselben Hist.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.55 (Build 82).

## Nächste (offen, 2.1.51 — erledigt in 2.1.55)

Ghost-TTL, leftover-Streak in Sekunden, Unknown-Reject, Name-Lock nach Wipe sitzen in 2.1.55.

## In 2.1.51 wirklich im Code

2.1.50 leftover Spread/Twin — Dropout ohne Print fiel auf IoU. Ghost 0,64 stahl UUID. 2-opt taufte Twin-Zeilen. Burst-Refs in 200 ms.

1. **`reconnectSkipsIoU`.** Dropout/Ghost: IoU-Pfad aus, auch ohne Print.
2. **`reconnectGhostNeedsBaptize`.** Ghost-Print < 0,80 kein Pin.
3. **`leftoverAssignDropAmbiguous`.** Spread < 0,08 droppt die 2-opt-Zeile.
4. **`enrollmentBurstDup`.** `+` Slot + 0,95 in 400 ms.
5. Tests: Assign-Drop, Skip-IoU, Ghost-Baptize, Burst.
6. MARKETING_VERSION 2.1.51 (Build 78), `Models.swift` + `VERSION` gleich.

## In 2.1.50 wirklich im Code

2.1.49 leftover 1,2 s — Zwillinge/Walker mit Print 0,70/0,69 wurden trotzdem getauft. Wipe → sofort neue Stimme. Nicken F→¾ zog den ¾-Centroid. IoU nach Dropout. Gähnen zählte als Vote. `reconnectPrefersPrint(liveDt)` feuerte nie (Kamera-dt 125 ms < 0,40 s).

1. **`leftoverAmbiguous` / `leftoverAmbiguousBlocks`.** Top-2 Spread < 0,08 kein Adopt, außer Schärfe dreht den Sieger.
2. **`leftoverTwinBlocksBox`.** pairCosine ≥ 0,90: leftover nur Print ≥ 0,80. `leftoverPick(twinPair:)` aus Match.
3. **`leftoverWipeMute` 800 ms + Overlay STUMM.** Genuine 0,64 tauft den Nachbarn nicht sofort.
4. **`poseSlotSticky`.** F→¾ zwei Frames, Maske (`upper`) sofort.
5. **`mouthOpen`.** mouthH_iod ≥ 0,42 keine Namensstimme.
6. **`reconnectPrefersPrint(fromGhost:)`.** Ghost oder Lücke ≥ 0,40 s → Print vor IoU.
7. Tests: Spread, Twin-Veto, Sticky, Mute, Mund, Ghost-Print, Schärfe-Unblock.
8. MARKETING_VERSION 2.1.50 (Build 77), `Models.swift` + `VERSION` gleich.

## In 2.1.49 wirklich im Code

2.1.48 leftover ~380 ms — jemand geht vorbei, UUID sitzt. Pale Prints (90 d) zogen den Centroid. Kisten-Sprung unsichtbar. Cache nur `id:slot`.

1. **`leftoverAdoptSec` 1,20.** 8 fps 10 Frames, 24 fps 75, Cap 80. Overlay `1/10`.
2. **`palePrintDrops`.** Live-Centroid ohne ≥ 90 d, solange frische Refs.
3. **`headCountJumped`.** Overlay cyan `KOPF n→m` 0,45 s. 0→1 kein Flash.
4. **`liveCentroidCacheKey`.** IDs sortiert + Slot + Pale.
5. Tests: Need 10/75, Pale, Key, Flash.
6. MARKETING_VERSION 2.1.49 (Build 76), `Models.swift` + `VERSION` gleich.

## Nächste (offen, 2.1.49 — erledigt in 2.1.50)

Die Punkte leftover Ambiguity, Twin-Veto, Mouth-open, Reconnect-Ghost, Slot-Hysterese, Wipe-Mute sitzen in 2.1.50.

## In 2.1.48 wirklich im Code

2.1.47 leftover 3+ Assign — Adopt schrieb die UUID im **ersten** Frame. Nachbar erbt den Namen beim Vorbeigehen. `liveCentroid` mischte 72/28 inkl. Profil wenn der Slot leer war. `nameVoteAccepts` ignorierte Maske, Blick weg, Lid zu. `leftoverAdoptNeed` kappte bei 8 Frames (24 fps = 128 ms, nicht 380 ms).

1. **`leftoverAdvance`.** Gleiche Box 3+/~380 ms, dann Adopt. `leftoverPick` und `leftoverAssign`. Overlay `1/4`. Andere Box setzt auf 1.
2. **`leftoverAdoptNeed(dt)`.** 8 fps 4 Frames, 24 fps 24 Frames (~380 ms). Cap 30, nicht 8.
3. **`liveCentroid`.** Slot leer → Frontal-only, nie Profil-Mix.
4. **`nameVoteAccepts`.** occluded / gazeAway / eyesClosed = keine Stimme.
5. Tests: Need 4/24, Streak +1/Reset, Same-Target, Maske/Blick/Lid, Frontal-Fallback.
6. MARKETING_VERSION 2.1.48 (Build 75), `Models.swift` + `VERSION` gleich.

## In 2.1.47 wirklich im Code

2.1.46 Pose-Freeze aus globalem `liveDt` — ein Dropout (0,40 s) maß Δyaw über 0,40 und fror **alle** Tracks. Spark war Hit-Prozent (LookOf 82), nicht Centroid-Cosine. leftover nur 2×2. `gallery.json.sha256` geschrieben, beim Load nie gelesen. Overlay zeigte `F` ohne Achse. `identitiesCrossed` ohne Blitz. Deskew-Blur (Laplacian 0,08 nach Roll) ging in den Print.

1. **`trackDt` / `poseDropoutResets`.** Lücke > 2,6 × Kamera-dt setzt Pose neu. Freeze nur aus dem Track-dt.
2. **`poseFreezeAxis`.** Overlay `FY` / `FP` / `FR` / `FYP`.
3. **`printDriftSample`.** Spark = Centroid-Cosine × 100, nicht Hit-Prozent.
4. **`leftoverAssign`.** Greedy + 2-opt für 3+ leftover-Tracks.
5. **`shaSidecarStatus`.** Load prüft sidecar; mismatch → Banner.
6. **`swapFlashHold` 0,45 s.** Overlay gelb + `SWAP`.
7. **`motionBlurDrops`.** Align + Laplacian < 0,10 → alter Print bleibt.
8. Tests: Dropout-dt, Achse Y/P/R, Spark 82, SHA gleich/fehlend/falsch, 2-opt schlägt greedy, Blur.
9. MARKETING_VERSION 2.1.47 (Build 74), `Models.swift` + `VERSION` gleich.

## In 2.1.46 wirklich im Code

2.1.45 Pose-Freeze — Pitch+Roll mit 0,15/Frame ohne dt. Continuity 8 fps: Rauschen 0,12 fror die Stimme, Namen wirkten tot. Swap nur `adopted.count == 2`. Overlay-Index statt Track-UUID. Print-Drift unsichtbar.

1. **`poseVelocityFreeze(dt:)`.** 8 fps Yaw 0,15 / Pitch-Roll 0,18. 24 fps 0,06 / 0,10.
2. **`pairSwapIndices`.** 3 Köpfe → 3 Paare, leftover-Swap nicht nur 2×2.
3. **`trackLabel`.** `T` + 3 Hex auf der Kiste.
4. **`printDriftSpark`.** 8 Samples Print-Prozent (sonst Look).
5. Tests: 8 fps 0,12 läuft, 24 fps 0,12 friert, 3 Paare, Track, Spark.
6. MARKETING_VERSION 2.1.46 (Build 73), `Models.swift` + `VERSION` gleich.

## Nächste (offen)

- **Identitäten-Merge-Wizard UI** bei Centroid 0,89–0,94. **→ 2.1.59 Merge-Banner + Button**
- **Helios-Bridge.** Eine Kamera-Session, eine TCC.
- **Enrollment AE-Lock** 200 ms nach Belichtungssprung. **→ 2.1.59 captureJumps + exposureLock**
- **Zwei-Kamera-Live.** Built-in + Continuity, Track über Print.
- **PhotoKit-Scan** nur mit expliziter Foto-Berechtigung.
- **Live-FAR** letzte 200 Impostor-Ticks im Labor, Overlay-Ticker. Floor-Hint **→ 2.1.62 liveFARLabel**. Labor-200 fehlt.
- **Open-Set Slider UI** um unknownRejectFloor. **→ 2.1.59 floorHint Open-Set n**
- **Quality-weighted Centroid.** sharpness × print.
- **Unknown sticky UUID.** „Stranger 1“ ohne Namen.
- **Print+Geo AND bei 2 Personen**, nicht OR.
- **3-Frame Enrollment Burst** auto-pick schärfstes. **→ 2.1.62 enrollBurstReplace** (Dup-Pfad). 3-Frame-Puffer fehlt.
- **DBSCAN Gallery-Cluster** vor Merge-Wizard.
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll, Apple-Print default.
- **Per-Identität leftover-Log** in der Overlay-Kiste.
- **Pairwise-Heatmap klickbar** im Labor.
- **Box-Kalman** statt 1-Euro bei 8 fps.
- **Ampel R-Lampe** wenn |Δroll| freeze (neben C/S/Y).
- **Watch-Folder.** Neue Fotos automatisch ingestieren.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern.
- **Platt-Skalierung** der Sigmoid auf Leave-one-out der Galerie.
- **Print-Revision-Banner** wenn Face-Print nach OS-Update andere Dim liefert.
- **Poster-Face reject.** **→ 2.1.59 landmarkJitter + leftover POSTER**
- **Glasses as Slot.** Brille an/aus nicht neue Identität.
- **Track-ID in Labor-CSV.**
- **CLAHE vor Print** bei Continuity, sonst Nacht-Print driftet.
- **Partial-Print bei Maske.** **→ 2.1.59 partialPrintMasked in matchLive**
- **Enrollment-Radar** F/¾/P als Ring, nicht nur Balken.
- **Gallery-Compact.** gleiche Pose Cosine 0,97 mergen, Confirm.
- **Name-Farbe sticky** nach Lock, nicht jedes Tick neu.
- **Nacht-ISO Banner** wenn Capture < 0,30 drei Frames — CLAHE vorschlagen.
- **Twin-Wizard.** pairCosine 0,89–0,94 → „dieselbe Person?“ statt still taufen. Merge-Banner 2.1.59 deckt Centroid, nicht leftover-Twin.
- **Ransac-1 Print.** **→ 2.1.59 printCommitMedian leftover-Trail**
- **Identity-Graph.** Wer mit wem im Bild — Soft-Prior, nie Taufe.
- **Liveness-Blink.** 1 Lid-Toggle in 2 s sonst Poster. Jitter-Poster sitzt.
- **Cross-Cam ReID.** Built-in → Continuity gleiche UUID über Print, nicht IoU.
- **Hard-Negatives aus leftover-Miss.** Labor-CSV automatisch.
- **PnP-Pose.** 6DoF statt nur Yaw, Slot-Hysterese folgt der Nase.
- **Enrollment-Retake.** Unschärfe 3× hintereinander → Overlay „nochmal halten“.
- **Track birth/death Log.** Overlay `+Anna` / `−Ben` 0,45 s.
- **Voice-Print optional.** Zweite Stimme nur Confirm, nie Live-Taufe.
- **Print-Cache LRU 512** statt `removeAll` — Burst nach 513 Gesichtern sonst kalt. **→ 2.1.56 printCacheDropCount**
- **Live-dt Median** analog Helios sampleDts — ein Dropout darf leftover-Need nicht auf 0,50 s kippen. **→ 2.1.56 medianLiveDt**
- **Enrollment-Burst 400 ms auch über `+` in der Liste**, nicht nur Kamera.
- **Yaw-Slot-Prior im leftoverPick** bevor IoU, sonst ¾-Ghost auf Frontal-Nachbarn (Slot-hart sitzt, Pick-Reihenfolge nicht). **→ 2.1.57 leftoverPick yawAbs**
- **Box-Aspekt < 0,38 kein leftover-Frontal.** **→ 2.1.59 leftoverPickAspect**
- **Merge-Liste mehr als ein Paar.** Banner zeigt Top-1; Wizard mit Confirm je Paar fehlt.
- **Poster-Liveness Blink** als zweite Spur neben Jitter.
- **Unknown sticky „Gast 1“** nach Open-Set, damit leftover nicht die nächste UUID stiehlt.
- **Quality-weighted leftoverScore** sharpness × print, Bonus sitzt, Gewicht in Centroid nicht.
- **CLAHE Continuity-Nacht** vor Print, Capture < 0,30 Banner.
- **Helios Frame-Pump teilen** — eine TCC, ein RotationCoordinator.
- **Gallery-JSON Schema 3:** `ghostHoldSec` persistiert, Restore nach Crash.
- **Testmodus ident20 parallel zu Live** ohne Galerie zu wischen.
- **Continuity-Desk-View eigener Pose-Slot `desk`**, nicht Profil.
- **Box-NMS 0,45 bei Live** — Tiles/Equalize-Zwillinge taufen zwei UUIDs auf ein Gesicht. **→ 2.1.56 liveDuplicate**
- **Name-Lock TTL 8 s ohne Vote** analog Rename-Confirm — sonst klebt Anna nach Verlassen. **→ 2.1.56 nameLockVoteTTL**
- **Cosine-EMA des leftover-Hold** statt Roh-0,64, sonst ein scharfer Twin 0,70 tauft. **→ 2.1.56 leftoverHoldEMA**
- **Continuity Desk-View nicht als Front spiegeln.** `position == .unspecified` ist oft Desk-View, nicht FaceTime. **→ 2.1.56 mirrorAsFront**
- **Unknown als Galerie-Klasse.** Reject-Centroid aus den letzten Impostor-Ticks, nicht nur Floor 50. **Math → 2.1.57 unknownCentroid.**
- **Print jeden 2. Frame wenn visMs > 18** analog Helios AX-Budget — 24 fps Trail fängt den Skip. **→ 2.1.57 printBudgetSkip**
- **leftoverStreakSince in gallery.json Schema 3** — Crash mitten im Walk tauft nicht neu. Streak-Helper **→ 2.1.62 leftoverStreakSincePersist**. JSON-Write fehlt.
- **Face-count Hysterese Idle→Live** 2 Frames Gesicht bevor 8 fps, sonst Blinker am Türrahmen. **→ 2.1.56 liveFacesLatch**
- **Live-ROI um letzte Boxen.** Vision nur Crop bei 8 fps, Full-Frame alle 4 Ticks.
- **leftover-Assign 3-Frame Majority** bevor UUID wechselt, sonst ein Tick Kreuz tauft. **→ 2.1.57 leftoverAssignMajority**
- **VNDetectFaceCaptureQuality** als vierte Ampel neben C/S/Y.
- **Per-Kamera-Centroid** Built-in vs Continuity, Cross-Cam ReID über den Split. **→ 2.1.62 liveCentroidCacheKey(camera:)**
- **Shared Frame-Pump mit Helios.** Bridge sitzt als Idee, eine Session-API fehlt.
- **Name-Lock Overlay `LOCK n s`** Countdown der 8 s, sonst wirkt tot nach Verlassen. **→ 2.1.57 nameLockTTLLabel**
- **Desk-View Horizont-Linie** im Overlay, sonst wirkt ungespiegelt „falsch herum“.
- **Print-Cache Hit-Rate im Labor**, Cap 512 sichtbar wenn Burst droppt.
- **Cluster-split Wizard** wenn leftover-Majority 10 Ticks uneinig bleibt.
- **Live freeze-frame Enrollment.** Space legt die aktuelle Kiste an, ohne Galerie-Wisch.
- **Track-Farbe sticky** nach leftover, nicht jedes Tick neu.
- **Print-Budget HUD** visMs analog Helios, Cap 18 ms sichtbar.
- **Box-Aspekt < 0,38 kein leftover-Frontal.** Math sitzt (`boxAspectFrontal`), Wire in leftoverPick **→ 2.1.59 leftoverPickAspect**.
- **Guest-Identität persistieren.** `Gast n` nach 8 s leftover → eigene UUID, nicht nächste Anna. Helpers **→ 2.1.62**. Write fehlt.
- **Liveness-Blink verdrahten.** `posterNeedsBlink` in leftover nach Jitter.
- **Box-Kalman verdrahten** statt 1-Euro bei Continuity 8 fps.
- **Cluster-Split Overlay** wenn leftover-Majority 10 Ticks uneinig — „zwei Personen?“.
- **Drop-in FaceEmbedder `.mlmodel`.** Apple-Print default, ArcFace optional.
- **PhotoKit-Alben** nur mit expliziter Berechtigung, Watch-Folder danach.
- **CLAHE Continuity-Nacht** Capture < 0,30 drei Frames, Banner.
- **Cross-Cam ReID.** Built-in → Continuity über Print, nicht IoU.
- **Enrollment-Radar** F/¾/P als Ring plus Coach-Pfeil (Text sitzt).
- **Print-Revision-Banner** nach OS-Update wenn Dim ≠ gallery.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an leftover 0,80–0,88.
- **Identity-Graph.** Wer mit wem im Bild — Soft-Prior, nie Taufe.
- **Helios Frame-Pump teilen.** Eine TCC, ein RotationCoordinator.
- **Liveness-Blink verdrahten.** **→ 2.1.61 posterNeedsBlink**
- **Box-Kalman verdrahten.** **→ 2.1.61 8 fps**
- **Cluster-Split Overlay.** **→ 2.1.61 SPLIT**
- **Guest persist Schema 3.** `Gast n` nach 8 s leftover eigene UUID. Restore-Gate **→ 2.1.62 gallerySchema 3**. Identity-Write fehlt. Overlay Gast 1/2 **→ 2.1.63 guestOrder**.
- **Konflikt-Tick Overlay.** Print≠Geo≠Lock keine Taufe. **→ 2.1.62 conflictTickAgrees + KONFLIKT**
- **leftover weicht Live-Taufe.** **→ 2.1.62 leftoverYieldsToLive**. UUID-Steal 0,64 **→ 2.1.63 leftoverTransfersId**.
- **Print-MAD Reject.** 5-Frame Median sitzt, MAD > 0,04 wirft den Spike.
- **Family-Bump UI** neben Open-Set-Slider.
- **Gallery at rest** FileVault-Hinweis, keine Extra-Crypto.
- **Track-Farbe sticky** nach leftover, nicht jedes Tick neu.
- **Temporal consensus** leftover-Hold 3 gleiche Slots bevor Gast.
- **Continuity night ISO Banner** Capture < 0,30 drei Frames + CLAHE-Vorschlag.
- **Occlusion skip** Maske > 0,4 Fläche kein leftover-Frontal.
- **Voice confirm leftover** 0,80–0,88 nur mit „ja“, nie still.
- **Gallery compact Confirm** Pose 0,97 Merge-Karte statt still.
- **PnP-Nase 6DoF** Slot-Hysterese folgt der Nase, nicht nur Yaw.
- **Tauf-Button für Gast.** 8 s leftover legt keine Identity an — Nutzer tauft explizit.
- **Overlay-Farbe je Gast-Index**, sticky über Dropout.
- **leftoverHold keyed by Box-Hash** 200 ms, nicht nur UUID — Dropout verliert sonst Gast 2.
- **Open-Set FAR-Lampe** rot ab 5 % Impostor über Floor.
- **PrintVec-Isolation.** Ghost-Print bleibt auf Ghost-UUID. **→ 2.1.63 kein Copy unter 0,80**.
- **Live-Kiste ohne Print** Overlay `?`, nicht leftover-Name.
- **Zwei-Box-Swap 120 ms** Animation statt UUID-Sprung.

## Nächste (offen, 2.1.50 — erledigt in 2.1.51)

Die Punkte leftoverAssign-Ambiguity, Ghost-Baptize, Dropout-IoU-Skip, Enrollment-Burst sitzen in 2.1.51.

## In 2.1.45 wirklich im Code

2.1.44 Lock-Drop — Nicken taufte den Nachbarn: `liveYaw` ohne Pitch, |Δpitch| 0,20 / Frame schrieb eine neue Stimme. Roll (Schulterzucken) ebenso. `boxesCrossed` brauchte Keep < Pin 0,28. IoU-Hold klebte bei 0,30, Kreuz 0,70 blieb tot. Assigned-Swap über Box-IoU nach greedy Zuweisung ist tot: UUID klebt an der *Stelle*, Keep ≈ 0,8 — Swap nie.

1. **`poseVelocityFreeze`.** Yaw **oder** Pitch **oder** Roll. `livePitch` / `liveRoll` analog `liveYaw`. `FaceQuality.roll`.
2. **`boxesCrossed` klar besser.** Kreuz ≥ Keep + 0,15, auch wenn Keep über Pin liegt (leftover-ungenutzt).
3. **`identitiesCrossed`.** Nach Zuweisung 2×2: Print-Kreuz, nicht Box. UUIDs tauschen, Hist/Euro/Trail/Hold/EMA/Yaw leer.
4. Tests: Keep 0,30 Kreuz 0,70 = Swap; Pitch-Nicken friert; Roll friert; Print-Kreuz 0,78 vs Keep 0,40 = Swap.
5. MARKETING_VERSION 2.1.45 (Build 72), `Models.swift` + `VERSION` gleich.

## In 2.1.44 wirklich im Code

2.1.43 Yaw-Freeze / Lock-HUD — Lock hielt Anna, obwohl der Print 0,40 war (Nachbar im Track). Anlegen ohne Balken. Roll im Crop. Galerie ohne Digest. SHA-Sidecar nur im Happy-Path. Hold-Still-Math ohne Overlay.

1. **`nameLockDrops`.** Print der Lock-ID < 0,50 oder nicht in Versus → Lock weg. Mehrheit tauft weiter.
2. **`poseMeter`.** F/¾/P-Balken in der Liste.
3. **`coachArrow`.** ‹ › · auf der Kiste.
4. **Crop-Align.** `eyeRoll` + Deskew |θ| ≥ 8° vor Face-Print, Canvas wächst mit (keine Ecken-Clips).
5. **`digestShort` + sidecar** `gallery.json.sha256` auch nach Fallback-Write.
6. **`labCSVRow`.** Export mit Note.
7. **Hold-Still 0,8 s.** `holdStillReady` bevor ein neuer Print den alten ersetzt. Overlay `HALTEN n%`.
8. Tests: Drop, Balken, Pfeil, Hold-Still Ready, Digest, Roll, CSV.
9. MARKETING_VERSION 2.1.44 (Build 71), `Models.swift` + `VERSION` gleich.

## In 2.1.43 wirklich im Code

2.1.42 leftover-Lock — Live taufte trotzdem den Nachbarn, sobald der Kopf sich drehte: jeder ¾-Frame eine neue Stimme, Lock kippte. Unscharfe Continuity-Ticks (Laplacian 0,09) zählten als Namensstimme, obwohl der Print-Trail sie schon skippte. Overlay zeigte nach Taufe nichts (`nameVoteProgress` nil) — Uneinig wirkte tot. Zwei Köpfe tauschten die Box, leftover adoptierte die UUID des Nachbarn. Name nur in der selektierten Kiste.

1. **`yawVelocityFreeze`.** |Δyaw| > 0,15 / Frame → Token leer, Lock hält.
2. **`nameVoteAccepts`.** Schärfe unter Floor keine Stimme (Built-in 0,12 / Continuity 0,08).
3. **`nameLockLabel` „hält“.** Overlay nach Taufe nicht leer. leftover bleibt bei Progress.
4. **`boxesCrossed`.** IoU-Kreuz tauscht UUIDs, leftover-Adopt nicht. `applyLiveFaces` bei 2×2.
5. **Name in jeder getauften Kiste**, nicht nur selected.
6. Tests: Freeze, Vote-Qualität, Lock-HUD, IoU 1/0, Kreuz vs. einseitig.
7. MARKETING_VERSION 2.1.43 (Build 70), `Models.swift` + `VERSION` gleich.

## In 2.1.42 wirklich im Code

2.1.41 Namens-Lock — leftover 0,64 taufte trotzdem: `leftoverHold[fid]` gesetzt **und** `liveNameLock` noch Anna (gleiche Live-UUID nach Dropout). `nameLockHolds(voted:nil, locked:Anna)=Anna`, dann `leftoverHold.removeValue` — Overlay grün bei Cosine 0,64. Hold wurde jeden Frame mit `leftoverHold = [:]` gelöscht, orange „gehalten“ nur ein Tick.

1. **`leftoverSkipsLock` / `leftoverLocked`.** Lock nur wenn `leftoverHold[fid] == nil`. Mehrheit (voted) tauft weiterhin.
2. **Hold bleibt.** `leftoverHold` nicht mehr jeden Frame leeren — orange bis Mehrheit oder Track weg. Pin ≥ 0,80 nimmt Hold weg.
3. Tests: Hold 0,64 kein Lock-Anna; Mehrheit tauft leftover.
4. MARKETING_VERSION 2.1.42 (Build 69), `Models.swift` + `VERSION` gleich.

## In 2.1.41 wirklich im Code

2.1.40 Vote-Fenster / Print-führt — der Name starb nach der Taufe: Look≠Print schreibt `""` in `liveNameHist`. Cap kappte inklusive Leer, Majority filtert erst danach. 10 Uneinig-Ticks schieben 7 Familien-Stimmen raus, `else { identityId = nil }`. Overlay tot.

1. **`nameHistAppend`.** Leere Tokens nicht anhängen. Cap gilt nur agreeing.
2. **`nameLockHolds`.** Nach Mehrheit bleibt die UUID, bis eine andere ID die Mehrheit hat. `liveNameLock` analog Hist.
3. Leftover-Wipe und `stopLive` leeren den Lock.
4. Tests: 12× `""` lässt 7 A stehen; Lock hält ohne Vote; neue Mehrheit kippt.
5. MARKETING_VERSION 2.1.41 (Build 68), `Models.swift` + `VERSION` gleich.

## In 2.1.40 wirklich im Code

2.1.39 Print-führt / leftover hungert nicht — Familie taufte trotzdem nie: `nameAgreeNeed(family: true, dt: 0,125) == 7`, `nameMajorityAgreeing` Default-Window 5, `slice.count >= 7` nie. Overlay `nameVoteProgress` zählte alle Stimmen (wirkte getauft), `identityId` blieb nil. Print-führt setzte `versus[0].percent = print` — LookOf 86 wurde 82, `decide` kippte am Solo-Floor 84. Margin 8 blockte Genuine, den Geo nur 4–7 Punkte über den Print-Sieger hob.

1. **`nameMajorityAgreeing` Fenster `max(window, need)`.** 7 Familien-Ticks taufen. `stabilizeLiveMatches` reicht `cap`.
2. **Print-führt behält LookOf.** decide und Overlay L sind Look, nicht Roh-Print.
3. **`liveNamePrintClear` 4** für Fremde. Familie bleibt Margin 8.
4. Tests: Need 7 trotz Window 5, Margin 4 Fremde / 4 Familie tot / 8 Familie.
5. MARKETING_VERSION 2.1.40 (Build 67), `Models.swift` + `VERSION` gleich.

## In 2.1.39 wirklich im Code

2.1.38 leftover orange / Coach — Live taufte trotzdem nicht: `lookOf` hebt den Geo-Geschwister (Jacke/Haar +4) über den Print-Sieger, `liveNameAgree` setzt **jeden** Tick `identityId = nil`. Leftover 0,64–0,79 wischte die Namens-Hist **jeden Frame** (`leftoverWipeHist` in `stabilizeLiveMatches`) — Genuine sitzt orange „gehalten 0,64“ und die Mehrheit kommt nie.

1. **`liveNamePrintLeads`.** Look≠Print und Print-Abstand ≥ 8 → versus auf den Print-Sieger, `decide` sieht denselben. Geo-Rauschen tauft nicht den Nachbarn, blockt aber auch nicht mehr.
2. **`leftoverStarvesVote = false`.** Wipe nur am Pin (`applyLiveFaces`). Votes laufen. Sobald Mehrheit sitzt, `leftoverHold` weg — Kiste grün, nicht ewig orange.
3. Tests: Print-führt 12 vs 2, leftoverStarvesVote.
4. MARKETING_VERSION 2.1.39 (Build 66), `Models.swift` + `VERSION` gleich.

## In 2.1.38 wirklich im Code

2.1.37 leftover orange / Taufe-Hold — leftover ≥ 0,80 blieb orange, obwohl leftoverBaptize den Namen schreiben durfte. Anlegen nur Statuszeile „Pose fehlt ¾“, Live wirkte ratlos.

1. **`enrollmentCoach`.** yaw + Coverage → „Kopf nach links drehen (¾)“ / „Blick zur Kamera“ / „halten“. Overlay ausgewählte Kiste + `enrollmentHint`.
2. **leftoverHold nur `leftoverWipeHist`.** Cosine ≥ 0,80 keine orange Kiste, Hist bleibt, Taufe sichtbar.
3. Tests: Coach-Fälle, leftoverWipeHist 0,64 vs 0,81.
4. MARKETING_VERSION 2.1.38 (Build 65), `Models.swift` + `VERSION` gleich.

## In 2.1.37 wirklich im Code

2.1.36 leftover tauft nicht unter 0,80 — Overlay-Kiste blieb trotzdem grün wie enrolled. Taufe-Hold unsichtbar (Live wirkt tot für 0,28–0,80 s). Slot-Buchstabe ohne Farbe. Close-Pair ohne Badge. Continuity still Fallback, kein Picker.

1. **`overlayBoxKind`.** leftover orange, enrolled grün, selected weiß.
2. **`nameVoteProgress`.** Overlay `2/3` / `5/7` bis Mehrheit sitzt.
3. **`siblingBadge`.** pairCosine ≥ 0,80 → „Geschwister?“.
4. **`slotTone`.** F grün, ¾ amber, P rot, U violet.
5. **Kamera-Picker** Auto / Built-in / Continuity. Prefs. Webcam-Restart.
6. Tests: boxKind, voteProgress, siblingBadge, slotTone.
7. MARKETING_VERSION 2.1.37 (Build 64), `Models.swift` + `VERSION` gleich.

## In 2.1.36 wirklich im Code

2.1.35 Familien-Taufe 5 Ticks — leftover 0,64 erbte UUID **und** Namens-Hist. Look-Delta 8 ohne Centroid. Taufe in Frames (24 fps = 80 ms).

1. **`leftoverBaptize` 0,80.** Darunter Hold-Label, keine Taufe, Hist weg.
2. **`nameClosePair(pairCosine:)`.** Look-Delta < 8 **und** Centroid ≥ 0,80.
3. **`nameAgreeNeed(family:dt:)`.** 0,28 s / 0,80 s, geklemmt 2–10 / 5–16 Ticks. `liveDt` aus PTS.
4. MARKETING_VERSION 2.1.36 (Build 63), `Models.swift` + `VERSION` gleich.

## In 2.1.35 wirklich im Code

2.1.34 war ein Versionsstempel ohne Code: Models 2.1.33, pbxproj Build 61, Taufe 2 Ticks, leftover unsichtbar. Commit-Text log.

1. **`nameAgreeNeed(family:)` 5 Ticks** bei close Pair (< 8 Punkte), sonst 2.
2. **`nameHistCap(need+3)`.** Leere Tokens zählen nicht und kürzen das Fenster nicht auf unter Need.
3. **`leftoverHoldLabel`** Overlay + Status `gehalten 0.64`.
4. **`renameConfirmSameId`.** Confirm einer anderen Zeile tot.
5. MARKETING_VERSION 2.1.35 (Build 62), `Models.swift` + `VERSION` gleich.

## In 2.1.34 nicht im Code

VERSION-Datei 2.1.34, Commit-Text Familien-Taufe/Hold-Label — Models 2.1.33, pbxproj Build 61, `nameAgreeNeed` 2. Die Fixes sitzen in 2.1.35.

## In 2.1.33 wirklich im Code

2.1.32 PTS und Slot-Count — ein Look=Print-Tick taufte. Look≠Print zählte. Rename klebte. `.bak` ohne fsync. Kleine Box rauscht. Overlay ohne Slot/Namen.

1. **`nameMajorityAgreeing` 2 Ticks.** Leere Tokens zählen nicht. Sonst keine Taufe.
2. **`renameConfirmExpired` 8 s.**
3. **`.bak` fsync** nach Copy.
4. **`oneEuroCutoff` + Box-Fläche.** < 0,04 → ×1,45.
5. **`slotLetter` + `liveNameDisagreeLabel`** im Overlay.
6. Tests: agreeing, expired, slotLetter, kleine Box.
7. MARKETING_VERSION 2.1.33 (Build 61), `Models.swift` + `VERSION` gleich.

## In 2.1.32 wirklich im Code

2.1.31 hat Look=Print, Slot-hart leftover, Trail-Slot, fsync — 1-Euro dt kam trotzdem aus der Apply-Wanduhr (Coalesce → dt 0). `+` ließ den Live-Trail auf dem alten Centroid. Slot-Count nur in der Statuszeile.

1. **1-Euro dt aus PTS.** FrameTap reicht den Sample-Stempel durch `onFrame` bis `applyLiveFaces`.
2. **`+` leert Print-Trail.** Neuer Ref darf den Median nicht mit der Vorperson mischen.
3. **`slotCountLabel`** in der Namensliste `F 2 · ¾ 1 · P 0 · U 0`.
4. Tests: slotCountLabel.
5. MARKETING_VERSION 2.1.32 (Build 60), `Models.swift` + `VERSION` gleich.

## In 2.1.31 wirklich im Code

2.1.30 leftover sameSlot fiel auf alle printable, wenn der Slot leer war (¾-Ghost pinnt Frontal). lookOf-Sieger ≠ Print-Sieger taufte. Print-Trail mischte Frontal+¾. boxPinTakePrint stahl namenlose Hold. Rename ohne Duplikat-Confirm. gallery.json ohne fsync.

1. **`leftoverPick` Slot-hart.** sameSlot gesetzt + kein Treffer → nil.
2. **`liveNameAgree`.** Look ≠ Print → keine Taufe, Notiz „Look und Print uneinig“.
3. **`printTrailAccepts`.** Slot-Wechsel leert den Median-Trail.
4. **`boxPinTakePrint` nur enrolled/named.**
5. **`renameConflict` + Confirm** (zweites Return).
6. **`GalleryFile.save` fsync** nach atomarem Write.
7. Tests: leftover all-false sameSlot, liveNameAgree, printTrailAccepts, renameConflict, printEnrolled.
8. MARKETING_VERSION 2.1.31 (Build 59), `Models.swift` + `VERSION` gleich.

## In 2.1.30 wirklich im Code

2.1.29 hat Cap-Notiz, Pose-Gewicht, Tick-Cache — leftover ignorierte den Pose-Slot (¾-Ghost pinnt Frontal-Nachbarn). IoU-Hysterese und Print-Pin uneinig → zwei Frames UUID-Flackern. Overlay nur „Print 82%“, kein Look. Identität nur löschen+neu.

1. **`leftoverPick sameSlot`.** Gleicher Pose-Slot zuerst, sonst Print-Score.
2. **`boxPinTakePrint`.** IoU-Hold + anderer Print-Pin → Print im selben Pass.
3. **`lookPrintLabel`.** Overlay `P 82 · L 82`, Cap-Silbe bleibt 2.1.29.
4. **Identität umbenennen.** TextField Return, persist.
5. Tests: sameSlot, lookPrintLabel, boxPinTakePrint.
6. MARKETING_VERSION 2.1.30 (Build 58), `Models.swift` + `VERSION` gleich.

## In 2.1.29 wirklich im Code

2.1.28 lookOf im Live mit Pose=1, Deckel unsichtbar, Centroids jedes Gesicht, Print-Hit = lookOf.

1. **`lookOfCapNote` „Print gekappt“** wenn < 70 bei Geo < 35 wirklich auf 60.
2. **`matchLive` poseWeight**, nicht Pose 1.
3. **Centroid/ratioSheet Cache** je Identität×Slot über den Tick.
4. **Print-Hit Sigmoid**, `.aegis` lookOf.
5. MARKETING_VERSION 2.1.29 (Build 57), `Models.swift` + `VERSION` gleich.

## In 2.1.28 wirklich im Code

2.1.27 leftover 0,72 / lookOf ≥ 80 — Live nutzte lookOf **nicht**. `matchLive` scored Roh-Print, `geoVetoSkipPrint` 88 kippte Genuine 80–87 % mit Jacke. Leftover 0,72 ließ 0,62–0,71 fallen. Unschärfe ging in den Median-Trail.

1. **`matchLive` lookOf.** Ohne gemessenes Print-Paar 0, nicht Geo.
2. **`geoVetoSkipPrint` 80** — decide und lookOf gleich.
3. **`leftoverPrintCosine` 0,64** + scharfer Genuine 0,62 (`leftoverPrintOk` + Schärfe).
4. **Print-Trail `skipPrint`.** Laplacian unter Floor behält den alten Vektor.
5. **`leftoverScore`.** Schärfe-Bonus 0,05 — 0,72 scharf schlägt 0,73 blur.
6. MARKETING_VERSION 2.1.28 (Build 56), `Models.swift` + `VERSION` gleich.

## In 2.1.27 wirklich im Code

2.1.26 leftover ging über `iouPrintBlocks` (0,80) — Genuine 0,62–0,85 pinnten nicht. `lookOf` kappte 80–83 % auf 60 sobald Geo < 35. Hold-Still IoU 0,82 klebte den Print beim Nicken. `liveCentroid` rechnete immer den All-Mean, auch bei Slot-Hit.

1. **`leftoverPrintCosine` 0,72** / `leftoverPrintOk`. Enrolled Pin bleibt 0,80.
2. **`lookOf` ≥ 80 nie kappen.** < 70 + Geo < 35 → min(embed, 60).
3. **Hold-Still + Schärfe.** IoU-Floor 0,70, `holdStillSharp` 0,18. Nicken mit scharfem Crop darf.
4. **`liveCentroid` Slot zuerst**, All-Mean nur Fallback.
5. MARKETING_VERSION 2.1.27 (Build 55), `Models.swift` + `VERSION` gleich.

## In 2.1.26 wirklich im Code

2.1.25 hat Slot-Centroid und leftover nächster Print — Live zeigte trotzdem die Box der Vorperson (Hysterese + 1-Euro), Mimik-Zeilen liefen jeden Webcam-Frame, Restore war ein Klick ohne Warnung, TER-Fusion blieb default an.

1. **`boxEuroResetOnHysteresis`.** Print-Pin ≥ 0,80 + IoU-Hysterese → Euro leer, neue Box.
2. **Live-`ratioSheet` identity-only.** Mimik wird im cheapGraph-Pfad nicht mehr gelegt. Scan-Tiles `cheapGraph: true`.
3. **TER-Fusion `defaultEnabled` ohne `.terFusion`.** Diagnose, Toggle bleibt. Einmal-Migration räumt alte allCases-Prefs.
4. **Restore-Dialog.** ≥ 7 Tage / Schema < 2 / andere printRevision.
5. **Ampel Continuity-Floor (S·), Geo-Spark, Track gehalten/neu.** `enrolledAt` paler ≥ 90 d.
6. **Snapshot-Media-Row** für Live-Kopien. Labor Genuine-vs-U extra Zeile.
7. MARKETING_VERSION 2.1.26 (Build 54), `Models.swift` + `VERSION` gleich.

## In 2.1.25 wirklich im Code

2.1.24 hat Geo je Pose-Slot — der **Print** blieb 72/28 über alle Posen: ¾-Sonde vs. Frontal-Centroid weich. Leftover nahm first-in-order, nicht den nächsten Print. `overlayHint` mischte die Galerie. Yaw-Skip war unsichtbar. Bewegung lieferte trotzdem einen neuen Print (Blur). Enrollment-Pose nur schwach in der Statuszeile.

1. **`liveCentroid(slot:)`.** ¾-Sonde gegen ¾-Refs, 72/28 nur Fallback. `matchLive` und Overlay-Hint.
2. **Leftover nächster Print.** `leftoverPick` / `leftoverRank` — nicht die ältere UUID.
3. **Leftover-Status** eine Zeile (`Live · Leftover-Pin n Track`).
4. **Yaw-Skip in decide-Notiz** (`¾, Maße ignoriert`).
5. **Hold-Still** IoU < 0,82 → alten Print behalten.
6. **Pose-Meter** in Anlegen-Status (`Pose fehlt Frontal+¾` / `Pose fertig`).
7. MARKETING_VERSION 2.1.25 (Build 53), `Models.swift` + `VERSION` gleich.

## In 2.1.24 wirklich im Code

2.1.23 hat echte Geo und leftover-Adopt — Namen flackerten trotzdem: `leftoverPinned` filterte `identities.faceIds` (Galerie-Snapshot). Seit 2.1.17 hat der Live-Track eine eigene UUID, leftover war immer leer. Leftover ohne Print klebte die UUID auf den Nachbarn. `matchLive` nahm den Maß-Median über **alle** Posen: ¾-Sonde vs. Frontal-Centroid → geoMix ~15, `geoVetoBlocks` kippte echte 80–87 %-Prints. `gallery.json` ohne Schema-Version.

1. **Leftover über namedTracks.** Letzter `.aegis`-Treffer am Live-Track, nicht Galerie-UUID. `leftoverNamedTrack`.
2. **Leftover braucht Print.** `leftoverNeedsPrint` — nil-Cosine pinnt nicht.
3. **Track-Pin `namedTracks`.** IoU-Print-Veto gilt dem genannten Live-Track, nicht nur enrolled Snapshot-UUIDs.
4. **Geo je Pose-Slot.** ¾-Sonde gegen ¾-Refs, sonst Fallback alle. Frontal-Maße vetoieren ¾ nicht.
5. **`geoVetoBlocks(..., yawAbs)`.** Yaw ≥ 0,28 und Print ≥ 80 → kein Veto (`geoVetoYawSkip` / `geoVetoYawPrint`).
6. **`gallery.json` Schema 2** neben `printRevision`.
7. MARKETING_VERSION 2.1.24 (Build 52), `Models.swift` + `VERSION` gleich.

## In 2.1.23 wirklich im Code

2.1.22 hat Track-Pin 0,28 und liveCentroid 72/28 — Geo-Veto war trotzdem tot: `matchLive` fakte `geoAgrees: true` / `geoMix: printPercent`. Leftover klebte enrolled UUIDs auf jede namenlose Box (Nachbar erbt). IoU setzte die UUID auch bei Print-Cosine 0,45. Overlay kippte die volle decide-Zeile in die Kiste.

1. **`matchLive` echte Landmark-Geo.** Median der `ratioSheet`-Identitätsmaße vs. Sonde. `geoAgrees` / `geoMix` ehrlich. Fehlende Geo → kein Veto (`liveGeoAgrees`).
2. **Leftover nur namenlos.** `leftoverAdoptAllowed` — schon eingeschriebene adopted-Boxen bleiben. Print-Veto wie IoU.
3. **IoU stiehlt nicht** wenn Cosine gemessen und `< pinPrintCosine`. `iouPrintBlocks`. Euro der falschen UUID wird geleert.
4. **`overlayNoteFirst`:** erste Klausel im Overlay, volle Notiz in der Seitenliste.
5. `ratioPercent` / `medianComponents` in MatchMath — dieselbe Kurve wie Still-`ratioScore`.
6. MARKETING_VERSION 2.1.23 (Build 51), `Models.swift` + `VERSION` gleich.

## In 2.1.22 wirklich im Code

2.1.21 leftover 0,28 galt nur dem *zweiten* Pin. Der erste enrolled Track klebte weiter bei IoU **0,12** — zwei Köpfe im Bild, eine UUID wandert. Overlay `1 − cosine > 0,12` (also cosine < 0,88) markierte fast jeden echten Treffer als „andere Person“. `matchLive` rief `tinyUnreliable(..., continuity: false)` und `meanPrintVector` über alle Posen. `stabilizeLiveMatches` schrieb leere Prints in die Mehrheit und ließ gelöschte UUIDs stehen. 1-Euro bei 8 fps: Box einen Frame hinten.

1. **`trackPinIoU` 0,28.** `MatchMath.trackPin` für enrolled und leftover. 0,12 ist tot.
2. **`liveCentroid` 72 % Frontal + 28 % alle.** `matchLive` und Overlay-Hint nutzen denselben Vektor.
3. **`overlayAlienHint` Cosine < 0,50.** Genuine 0,62–0,85 bleibt still.
4. **`tinyUnreliable(continuity: liveContinuity)`** in `matchLive`.
5. **`oneEuroCutoff`:** dt ≥ 0,10 → ×1,7.
6. **`stabilizeLiveMatches`:** `!measured` skip; UUID nicht in der Galerie → `identityId = nil`.
7. MARKETING_VERSION 2.1.22 (Build 50), `Models.swift` + `VERSION` gleich.

## In 2.1.21 wirklich im Code

2.1.20 hat Centroids und boxEuro-Reset — Live ließ echte 90 %-Prints trotzdem fallen: `lookOf` kappte auf 60 sobald Landmark-Geo < 35 (Jacke, Haar, ¾). Geo-Veto blockte 93 % bei Geo 18. Namensmehrheit 3 Ticks ohne den Prozentwert der gewählten ID. Leftover 0,18 klaute die UUID. Overlay schrieb nur „nicht zugeordnet“.

1. **`lookOf` starker Print (≥ 84) nie unter Embed.** Geo gibt weiter bis +4, kappt nicht auf 60.
2. **`geoVetoBlocks` skip ab 88 % Print.** 84–87 nur noch bei Geo < 22.
3. **`nameVoteFrames` 5** + **`votedPercent`**: Overlay zeigt den Score der gewählten Identität, dann EMA.
4. **`leftoverIoU` 0,28.** Auswahl bleibt am Track, solange er da ist.
5. **Overlay-Badge** zeigt die decide-Notiz statt nur „nicht zugeordnet“.
6. MARKETING_VERSION 2.1.21 (Build 49).

## In 2.1.20 wirklich im Code

Warum Live falsch taufte, auch nach 2.1.19: `rematchLive` hat das volle Ensemble über jedes Galerie-Foto, Profile ohne Vision-Yaw = Frontal, Crop-Print mit zweiter Orientierung, 1-Euro überlebte den Kamerawechsel, dritter Frontal blockte nicht.

1. **`matchLive` Centroids.** Eine Sonde, ein Mittelvektor pro Identität. Danach 3-Tick aus 2.1.19.
2. **Median-Blend** letzte 5 Live-Prints (`MatchMath.medianBlend`).
3. **Yaw aus Landmarks** wenn `|yaw| < 0,02`.
4. **Crop-Print `.up`**, nur wenn der Handler schon aufrecht ist.
5. **`poseCoverageBlocks`** — 3. gleicher Slot, solange Frontal oder ¾ fehlt.
6. **`boxEuro` + Print-Trail leer** bei `cameraUniqueID`-Wechsel.
7. **`leftoverIoU` 0,18** benannt. Leftover-Pin nur darüber.
8. Anlegen-Confirm Centroid **0,82** (war 0,88).
9. Labor: Centroid-Cosine zwischen Identitäten.
10. MARKETING_VERSION 2.1.20 (Build 48), `Models.swift` + `VERSION` gleich.

## In 2.1.19 wirklich im Code

Warum 2.1.18 Live zwischen Geschwistern sprang und Jacken taufte: `rematchLive` schrieb jeden Frame den Roh-Namen. `fusedOf` nahm TER-Fusion (lookRow 0,40 + geoRow 0,26 + graph 0,14 + texture 0,03) — Geometrie doppelt, Kleidung als Identität. `decide` blockte `!geoAgrees && geoMix < 42 && percent < 94`. `graphBiomarkers` 4× Jacobi + Floyd–Warshall pro Live-Gesicht. `.bak` ohne UI.

1. **`nameMajority` 3 Ticks** + **`liveScoreEMA` 0,35** in `stabilizeLiveMatches`.
2. **`.aegis` = `lookOf`**, sobald Print gemessen. TER bleibt Anzeige-Spur.
3. **`geoVetoBlocks`.** 90 %+ Print nur bei Geo < 22, 84 %+ bei Geo < 35.
4. **`cheapGraphBiomarkers`** im Live-Detect (kein Jacobi).
5. **Backup-Taste** lädt `gallery.json.bak`.
6. **`pruneKeepIncoming`** beim `+` (Cosine > 0,98, Schärfere bleibt).
7. MARKETING_VERSION 2.1.19 (Build 47).

## In 2.1.18 wirklich im Code

Warum Live sich tot/falsch anfühlte: eingeschriebene Live-UUIDs klebten als Geister-Kiste wenn niemand da war (IoU-Rest 0,08 klaute die ID vom Nachbarn), Pin-Print 0,72 vertauschte Geschwister, die Webcam nahm das erste Built-in (nicht Front), Labor warf Continuity-Refs mit Laplacian 0,10 raus, Burst-Filter schwieg.

1. **Geister-Kisten.** `found.isEmpty` → Live-Faces weg. Galerie-Snapshots haben anderes `mediaId`.
2. **`pinPrintCosine` 0,80.** `MatchMath.pinByPrint`. 0,72 klebte Geschwister.
3. **Leftover-IoU 0,18.**
4. **`preferredCamera` Front-Wide** vor Continuity/Desk-View.
5. **`LiveCapture.stop`** räumt tap / Continuity / uniqueID.
6. **Labor-Floor 0,08** (`laborQualityRejects`) für eingeschriebene Refs.
7. **Ingest-Duplikat** in der Statuszeile (`n Burst-Kopien übersprungen`).
8. Caption `+` = extra Foto, Namensfeld egal.
9. `poseCoverageBlocks` gibt nil — dritter Frontal blockt nicht.
10. MARKETING_VERSION 2.1.18 (Build 46), `Models.swift` + `VERSION` gleich.

## In 2.1.17 wirklich im Code

- Live + Anlegen: Track behält UUID, Galerie bekommt Kopie.
- Pose-Slot warnt, blockt nicht.
- `+` disabled nur ohne Gesicht.

## In 2.1.15–2.1.16

`rematchLive`, Continuity-Blend 0,20, Box-Hysterese, Ingest-Duplikat 0,95, Labor ohne Unschärfe-Paare, `gallery.json.bak`, `enrolledAt`, Spark-Reset, familyBump pro Paar, OneEuro-Init öffentlich. TAR `floor(far·n)−1`.

## Nächste Fixes (klein)

- **Leftover überspringt Lock.** 0,64 tauft nicht über `nameLockHolds`. **→ 2.1.42 leftoverLocked**
- **Leere Tokens nicht im Cap.** **→ 2.1.41 nameHistAppend**
- **Namens-Lock nach Taufe.** **→ 2.1.41 nameLockHolds**
- **Yaw-Velocity Freeze.** **→ 2.1.43 yawVelocityFreeze; Pitch+Roll → 2.1.45 poseVelocityFreeze**
- **Print-Qualität vor Vote.** **→ 2.1.43 nameVoteAccepts**
- **Lock-HUD halten.** Overlay `hält` statt `2/3` sobald Lock sitzt. **→ 2.1.43 nameLockLabel**
- **Zwei-Gesichter-Swap-Guard.** **→ 2.1.43 leftover unused; 2.1.45 boxesCrossed Keep-über-Pin + identitiesCrossed Print**
- **Live-Name in unselektierter Kiste.** **→ 2.1.43 overlay**
- **Export Labor als CSV-Datei**, nicht nur Textfeld. **→ 2.1.44 labCSVRow**
- **Hold-Still-Ring** im Overlay 0,8 s, analog Peace. **→ 2.1.44 holdStillReady / HALTEN n%**
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen. **→ 2.1.44 poseMeter**
- **liveCentroid Cache am Identity-Modell** (2.1.29 cacht nur den Tick; 2.1.32 leert den Trail bei `+`).
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames. **→ 2.1.46 printDriftSpark; 2.1.47 printDriftSample Centroid**
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID. **→ 2.1.46 trackLabel**
- **Crop-Align Augen** vor `VNGenerateFacePrint`. **→ 2.1.44 eyeRoll / deskewIfNeeded**
- **Live-FAR** aus den letzten 200 Impostor-Ticks im Labor.
- **Open-Set Unknown.** Explizite „unbekannt“-Klasse, Slider für Reject, nicht nur Floor.
- **Platt-Skalierung** der Sigmoid auf Leave-one-out der Galerie, globaler Mid 0,55 nur Fallback.
- **Print-Revision-Banner** wenn `VNGenerateFacePrint` nach OS-Update andere Dim liefert.
- **Coach-Pfeil** auf der Kiste (‹ ›) statt nur Text. **→ 2.1.44 coachArrow**
- **gallery.json SHA-256** neben schemaVersion. **→ 2.1.44 digestShort + sidecar; 2.1.47 shaSidecarStatus Verify**
- **Enrollment AE-Lock.** `+` wartet 200 ms nach Belichtungssprung.
- **Motion-Blur nach Deskew.** Laplacian < 0,10 nach Roll-Korrektur verwerfen — sonst schiefer Crop + Unschärfe im Print. **→ 2.1.47 motionBlurDrops**
- **SHA-Verify beim Load.** sidecar ≠ Hash von gallery.json → Banner, Restore anbieten. **→ 2.1.47 shaVerifyNote**
- **3-Tick Still-Median** bevor der neue Print committed — ein scharfer Blur-Frame darf den Trail nicht kippen.
- **Box-Aspect-Gate.** width/height < 0,38 (hartes Profil) nicht als Frontal-Print.
- **Pale-Print droppen** aus dem Live-Centroid nach `printAgePaleDays`, bleibt in der Galerie.
- **Identitäten mergen UI-Button**, nicht nur Anlegen-Confirm bei Centroid > 0,82.
- **Restore-Diff mit SHA.** Backup vs. aktuell: welche IDs kämen zurück, Digest daneben.
- **Track-ID `T…` in der Overlay-Kiste**, Snapshot-UUID bleibt intern.
- **Ampel G-Lampe** neben C/S/Y wenn lookOfCapped (rot) vs skip (grün).
- **Galerie kompakt:** unscharfe same-Slot-Refs droppen, sobald eine scharfe da ist.
- **1-Euro minCutoff Slider** für Continuity vs Built-in.
- **Continuity-Print jeden 2. Frame** bei ≥ 20 fps. Trail/Median fängt den Skip.
- **IVF / ANN ab 50 IDs.** Brute-Force Cosine wird bei Familien-Galerien langsam.
- **3+-Gesichter Hungarian.** 2×2-Swap deckt Crowd nicht — Zuweisung min-cost über Print+IoU. **→ 2.1.47 leftoverAssign greedy+2-opt**
- **Print-Swap 3×3** greedy identitiesCrossed-Paare, nicht nur 2×2. **→ 2.1.46 pairSwapIndices (Hungarian bleibt)**
- **Ampel R-Lampe** wenn |Δroll| freeze (neben C/S/Y).
- **Box-Kalman** statt 1-Euro bei 8 fps (Continuity hängt einen Frame).
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix, decide-Notiz).
- **Licht-Eimer.** Tag/Kunstlicht/Nacht am Face, Match bevorzugt denselben Eimer.
- **Identitäten mergen** UI-Button, nicht nur Anlegen-Confirm bei Centroid > 0,82.
- **Helios-Bridge.** Eine Kamera-Session, eine TCC-Freigabe.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix, decide-Notiz).
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, Track über Print.
- **PhotoKit-Scan** nur mit expliziter Foto-Berechtigung.
- **Drop-in `.mlmodel`.** FaceEmbedder-Protokoll, Apple-Print default.
- **Per-Identität leftover-Log** in der Overlay-Kiste.
- **Identitäten-Merge-Wizard** bei Centroid 0,89–0,94 statt still zwei Personen.
- **Pairwise-Heatmap klickbar** im Labor.
- **Watch-Folder.** Neue Fotos automatisch ingestieren.
- **Print quantisieren** (int8) für kleinere Library-Files.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern.
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Hold-Still-Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen.
- **liveCentroid Cache am Identity-Modell** (2.1.29 cacht nur den Tick; 2.1.32 leert den Trail bei `+`).
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Live-FAR** aus den letzten 200 Impostor-Ticks im Labor.
- **Open-Set Unknown.** Explizite „unbekannt“-Klasse, Slider für Reject, nicht nur Floor.
- **Platt-Skalierung** der Sigmoid auf Leave-one-out der Galerie, globaler Mid 0,55 nur Fallback.
- **Zwei-Gesichter-Swap-Guard.** IoU-Kreuz: wenn A und B die Box tauschen, UUIDs tauschen, nicht leftover-Adopt.
- **Print-Revision-Banner** wenn `VNGenerateFacePrint` nach OS-Update andere Dim liefert.
- **Coach-Pfeil** auf der Kiste (‹ ›) statt nur Text.
- **Live-Name in unselektierter Kiste** sobald Mehrheit sitzt (jetzt nur selected overlayName).
- **gallery.json SHA-256** neben schemaVersion.
- **Enrollment AE-Lock.** `+` wartet 200 ms nach Belichtungssprung.
- **Ampel G-Lampe** neben C/S/Y wenn lookOfCapped (rot) vs skip (grün).
- **Galerie kompakt:** unscharfe same-Slot-Refs droppen, sobald eine scharfe da ist.
- **1-Euro minCutoff Slider** für Continuity vs Built-in.
- **Jacobi nur Still-Labor.** Still-Foto-Detect ohne Tiles noch voller Graph wenn `tiles: false`.
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Hold-Still-Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen.
- **liveCentroid Cache am Identity-Modell** (2.1.29 cacht nur den Tick; 2.1.32 leert den Trail bei `+`).
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Jacobi nur Still-Labor**, Scan-Tiles sind cheap — Still-Foto-Detect ohne Tiles noch voller Graph wenn `tiles: false` und nicht live.
- **Enrollment AE-Lock.** `+` wartet 200 ms nach Belichtungssprung.
- **Ampel G-Lampe** neben C/S/Y wenn lookOfCapped (rot) vs skip (grün).
- **gallery.json SHA-256** neben schemaVersion, Restore warnt bei Drift.
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Live-FAR** aus den letzten 200 Impostor-Ticks im Labor.
- **Galerie kompakt:** unscharfe same-Slot-Refs droppen, sobald eine scharfe da ist.
- **1-Euro minCutoff Slider** für Continuity vs Built-in, Fläche bleibt Bias.
- **Uneinig-Namen nur Live**, Still-Fotos nicht mit Look/Print-Ghosts.
- **Coach-Pfeil** auf der Kiste (‹ ›) statt nur Text — Richtung beim Live-Anlegen.
- **Live-Name in unselektierter Kiste** sobald Mehrheit sitzt (jetzt nur selected overlayName).
- **Open-Set Unknown.** Explizite „unbekannt“-Klasse, Slider für Reject, nicht nur Floor.
- **Taufe-Hysterese.** Nach Mehrheit bleibt der Name, bis Print-Cosine unter 0,50 fällt — nicht bei einem Look≠Print-Tick.
- **Platt-Skalierung** der Sigmoid auf Leave-one-out der Galerie, globaler Mid 0,55 nur Fallback.
- **Zwei-Gesichter-Swap-Guard.** IoU-Kreuz: wenn A und B die Box tauschen, UUIDs tauschen, nicht leftover-Adopt.
- **Print-Revision-Banner** wenn `VNGenerateFacePrint` nach OS-Update andere Dim liefert.

- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Hold-Still-Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen.
- **liveCentroid Cache am Identity-Modell** (2.1.29 cacht nur den Tick; 2.1.32 leert den Trail bei `+`).
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Jacobi nur Still-Labor**, Scan-Tiles sind cheap — Still-Foto-Detect ohne Tiles noch voller Graph wenn `tiles: false` und nicht live.
- **Enrollment AE-Lock.** `+` wartet 200 ms nach Belichtungssprung.
- **Ampel G-Lampe** neben C/S/Y wenn lookOfCapped (rot) vs skip (grün).
- **gallery.json SHA-256** neben schemaVersion, Restore warnt bei Drift.
- **Enrollment-Coach.** „Kopf nach links“ wenn ¾ fehlt, nicht nur Statuszeile. **→ 2.1.38 enrollmentCoach**
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Live-FAR** aus den letzten 200 Impostor-Ticks im Labor.
- **Galerie kompakt:** unscharfe same-Slot-Refs droppen, sobald eine scharfe da ist.
- **1-Euro minCutoff Slider** für Continuity vs Built-in, Fläche bleibt Bias.
- **Uneinig-Namen nur Live**, Still-Fotos nicht mit Look/Print-Ghosts.
- **Slot-Letter Farbe** (F grün, ¾ amber, P rot) analog Quality-Ampel. **→ 2.1.37 slotTone**
- **Leftover nicht taufen** bis Print ≥ 0,80 — Hold darf die Overlay-Kiste, nicht die Galerie. **→ 2.1.36 leftoverBaptize**
- **nameHist in Sekunden** (8 fps × 5 Ticks = 0,6 s), nicht Frame-Count. **→ 2.1.36 nameAgreeNeed(dt:)**
- **Pairwise close Pair aus Centroid-Cosine**, nicht nur Look-Delta 8. **→ 2.1.36 pairCosine**
- **Overlay leftover vs enrolled** verschiedene Kistenfarbe, nicht nur Text. **→ 2.1.37 overlayBoxKind**
- **Leftover-Hist nicht an die nächste Box vererben.** **→ 2.1.36 wipe**
- **Kamera-Picker** Built-in / Continuity analog Helios 1.5.19. **→ 2.1.37 CameraChoice**
- **Taufe-Hold sichtbar:** Overlay `2/3` bzw. `5/7` bis Mehrheit sitzt — sonst wirkt Live „tot“. **→ 2.1.37 nameVoteProgress**
- **Zwei-Personen-FAR im Overlay.** Wenn pairCosine ≥ 0,80, Badge „Geschwister?“ statt Name. **→ 2.1.37 siblingBadge**
- **leftover ≥ 0,80 keine Hold-Kiste.** Taufe sichtbar, nicht orange wie 0,64. **→ 2.1.38 leftoverWipeHist**
- **Coach-Pfeil** auf der Kiste (‹ ›) statt nur Text — Richtung beim Live-Anlegen.
- **Pose-Balken F/¾/P** neben dem Namen, Coach sagt wohin, Balken sagt wie viel.
- **Hold-Still-Ring** 0,8 s im Overlay bevor Print-Request (Skip ist 2.1.25).
- **Live-Name in unselektierter Kiste** sobald Mehrheit sitzt (jetzt nur selected overlayName).
- **AE-Lock 200 ms** nach Belichtungssprung beim `+`.
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **gallery.json SHA-256** neben schemaVersion.

## Erweiterungen

- **Taufe-Hysterese / Namens-Lock.** **→ 2.1.41** Ein Look≠Print-Tick nach Mehrheit darf nicht nil setzen. Leftover-Hold **→ 2.1.42 leftoverLocked**
- **Lock-HUD halten.** Overlay `hält` statt `2/3` sobald Lock sitzt. **→ 2.1.43 nameLockLabel**
- **Yaw-Velocity Freeze** vor neuer Stimme, wenn der Kopf sich dreht. **→ 2.1.43**
- **Print-Qualität vor Vote** (unscharfer Tick keine Stimme). **→ 2.1.43**
- **Zwei-Gesichter-Swap-Guard.** Box-Tausch = UUID-Tausch, nicht leftover. **→ 2.1.43**
- **IVF ab 50 IDs.** Brute-Force Cosine wird bei Familien-Galerien langsam; Inverted-File / ANN nur als Lookup, decide bleibt.
- **Continuity-Print jeden 2. Frame.** `VNGenerateFacePrint` bei 24 fps verdoppelt die Last; 8 fps bleibt jeder Frame. Trail/Median fängt den Skip.
- **Drop-in `.mlmodel`.** `FaceEmbedder` als Protokoll, Apple-Print default, ArcFace optional (Lizenz!).
- **PhotoKit-Scan.** Mediathek lokal, nur mit expliziter Foto-Berechtigung.
- **Cluster vor Anlegen.** Unbenannte Gesichter: „3 Fotos, dieselbe Person?“
- **Track über Dateien.** Dieselbe Person in Video A und Foto B über Print.
- **Export Embeddings.** CSV/JSON der Face-Prints ohne Bilder.
- **GPU-Batch.** Ein `VNImageRequestHandler`, viele Requests.
- **Kalibrier-Set.** Fünf eigene Fotos (frontal, ¾, Hut, Nacht, Lächeln) als Selbsttest.
- **Score-Kalibrierung pro Galerie.** Platt-Skalierung auf Leave-one-out statt globaler Sigmoid.
- **Pose-normalisierter Print.** Yaw/Pitch vor dem Crop, nicht nur Slot-Mix.
- **Helios-Bridge.** Eine Kamera-Session, eine TCC-Freigabe — kein Code kopieren.
- **Offen-Set.** Explizite „unbekannt“-Klasse mit eigener Schwelle.
- **Identitäten mergen.** UI-Button, nicht nur Anlegen-Confirm bei Centroid > 0,82.
- **Watch-Folder.** Neue Fotos automatisch ingestieren.
- **Print quantisieren** (int8) für kleinere Library-Files.
- **Aktives Lernen.** „Ist das dieselbe Person?“ an unsicheren Rändern.
- **On-device Eval-Clip.** Die letzten 50 Live-Frames als Mini-Labor.
- **Auto-Enrollment-Halt.** UUID 8 s mit Print ≥ 94 % und Yaw < 0,3 → Vorschlag, nie still schreiben.
- **HEIC-Depth.** Yaw aus der Tiefenkarte.
- **Negativ-IDs in der Laborliste** exportieren, nicht nur intern deckeln.
- **Familien-Cluster UI.** Pairwise-Heatmap im Labor, nicht nur +4 Floor.
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, derselbe Track über Print, nicht IoU.
- **Geschwister-Wizard.** Pairwise-Heatmap vorschlagen, Floor +4 bestätigen lassen.
- **Live-Quality-Ampel persistieren.** C/S/Y der letzten Session im Labor.
- **Partial-vs-Full Confusion-Matrix** extra Block.
- **Continuity uniqueID-Liste.** Manuell markieren, falls Desk-View nicht als Continuity erkannt wird.
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Leave-one-identity-out Labor.** Neben Leave-one-photo, damit 2-Personen-Galerien nicht sich selbst messen.
- **Hard-Negativ im Overlay.** Taste N wie U, ohne Umweg über Ablehnen-Menü.
- **Scan-Queue priorisiert große Gesichter** (Portrait zuerst, Crowd später).
- **HEIC-Gain-Map** als Capture-Qualität, nicht nur Laplacian.
- **Identität umbenennen** in der Liste (jetzt nur löschen + neu).
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **Live-Quality an Frame-dt.** 8 fps vs 24 fps: Spark-Fenster in Sekunden, nicht Frames.
- **Score-Kalibrierung live.** Platt auf den letzten 200 Live-Ticks, Slider nur Bias.
- **Cheap-Graph auch Still**, wenn graphBio aus ist — Detect soll die Spur nicht trotzdem rechnen.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück, bevor überschrieben wird.
- **Enrollment-Wizard.** Pose-Coverage-Meter vor „fertig“ bleibt UI-Ring, Statuszeile ist 2.1.25, Coach 2.1.38.
- **Live Hold-Still-Ring** 0,8 s vor Print-Request — spart unscharfe Embeds visuell (Skip ist 2.1.25).
- **Burst-Median** der letzten 5 Live-Prints beim `+`, nicht nur im Track.
- **Licht-Eimer.** Tags Tag/Kunstlicht/Nacht am Face, Match bevorzugt denselben Eimer.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix, decide-Notiz) für Labor nach der Session.
- **Hard-Neg „gleiche Jacke“.** Texture-Hit ohne Print → explizit ablehnen.
- **Labor TAR@FAR live-simuliert:** letzte 50 Webcam-Prints gegen die Galerie, nicht nur Still-Fotos.
- **Geo-Veto-Log.** Eine Zeile im Overlay wenn Maße blocken, nicht nur „nicht zugeordnet“.
- **Track-ID entkoppelt von Face-UUID.** Live-Track `T…`, Galerie bleibt Snapshot-UUID — Anlegen kann nicht mehr den Track umbiegen.
- **ratioSheet Cache** am Identity-Modell, nicht jedes Live-Frame neu medianen.
- **Print-first Matcher** als eigene Strategy-Hit-Zeile im Live (nicht nur .aegis), zum Debug.
- **Box-Hysterese + Print-Pin in einem Pass.** Jetzt IoU dann Print; bei Uneinigkeit zwei Frames UUID-Flackern.
- **Track-ID `T…` in der UI.** intern `trackId` gibt es, die Kiste zeigt die Snapshot-UUID.
- **Continuity 8 fps:** Spark-Fenster in Sekunden (schon als Idee), analog Helios sampleDt.
- **Drop-in `.mlmodel` bleibt der große Sprung** — Apple-Print ist die Decke.
- **Live-FAR-Spark** letzte 200 Impostor-Ticks im Overlay, nicht nur Labor.
- **Enrollment-Coach.** „Kopf nach links“ wenn ¾ fehlt, Pose-Balken F/¾/P. **→ 2.1.38 Text; Balken bleibt**
- **Crop-Align Augen** vor `VNGenerateFacePrint`.
- **Restore-Diff.** Backup vs. aktuell: welche IDs kämen zurück.
- **gallery.json SHA-256** neben schemaVersion.
- **Hold-Still-Ring** 0,8 s im Overlay.
- **Track-ID `T…` in der UI**, Galerie bleibt Snapshot-UUID.
- **Export Labor als CSV-Datei**, nicht nur Textfeld.
- **liveCentroid Cache** am Identity-Modell (slot + printRevision).
- **Identitäten mergen** UI-Button, nicht nur Anlegen-Confirm.
- **Offen-Set.** Explizite „unbekannt“-Klasse.
- **Helios-Bridge.** Eine Kamera-Session, eine TCC.
- **Zwei-Kamera-Live.** Built-in + Continuity parallel, Track über Print.
- **PhotoKit-Scan** nur mit expliziter Foto-Berechtigung.
- **Match-Log JSONL** (Tick, UUID, lookOf, geoMix).
- **AE-Lock 200 ms** nach Belichtungssprung beim `+`.
- **Print-Drift-Spark.** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **Per-Identität leftover-Log** in der Overlay-Kiste, nicht nur Statuszeile.
- **Hold-Still Ring** im Overlay 0,8 s, analog Peace.
- **Pose-Meter als Balken** (F/¾/P) neben dem Namen, nicht nur Text.
- **liveCentroid Cache** am Identity-Modell, nicht jedes Live-Frame neu mischen.
- **Yaw-bedingtes leftover:** ¾-Sonde gegen leftover ¾-Print, nicht Frontal-Ghost.
- **Quality-Spark der leftover-UUID** im Overlay, damit man sieht warum 0,64 hielt.
- **Coach-Pfeil** auf der Kiste (‹ ›) statt nur Text — Richtung beim Live-Anlegen.
- **Live-Name in unselektierter Kiste** sobald Mehrheit sitzt (jetzt nur selected overlayName).
- **Identitäten-Merge-Wizard** bei Centroid 0,89–0,94 statt still zwei Personen.
- **Pairwise-Heatmap klickbar** im Labor (Genuine vs Impostor).
- **Print-Drift-Spark** Overlay-Linie Cosine zum Centroid über 8 Frames.
- **AE-Lock 200 ms** nach Belichtungssprung beim `+`.
- **Crop-Align Augen** vor `VNGenerateFacePrint` (Roll-Korrektur).
- **Pose-Balken F/¾/P** neben dem Namen, Coach sagt wohin, Balken sagt wie viel.
- **Hold-Still-Ring** 0,8 s im Overlay bevor Print-Request.
- **decide-Notiz „Print gekappt“** nur unter 70 — 2.1.27 kappt ≥80 nicht mehr, Log fehlte.
- **Pairwise leftover vs. enrolled** eine Zeile im Labor (war der Pin zu Recht 0,64?).
- **lookOf-Delta im Overlay** (Print 82 → look 82, Geo 18) wenn Veto skippt — sonst wirkt 80 % „tot“.
- **Centroid-Cache** am Identity (slot + printRevision), nicht jedes Live-Frame `meanPrintVector`.
- **ratioSheet Cache** am Identity-Modell (steht schon unter Fixes, hier der Haken: matchLive mediant jedes Frame).
- **Overlay Print vs look** (`P 82 · L 82`) wenn Geo das Look nicht kippt — sonst wirkt skip „tot“.
- **Hard-Negativ Cosine-Floor live** aus Reject-Liste, nicht nur Labor.

## Nicht tun

- Raster wieder abstimmen lassen. Kleidung/Licht hat das 2024/25 zerstört.
- Geschlecht / Ethnie als Soft-Biometric.
- Cloud-API. Aegis ist lokal.
- 3DMM-Netze ins Bundle.
- Image-Feature-Print als Identität. Jacke ≠ Gesicht.
- Sigmoid-Mitte wieder unter 0,50.
- `lookOf` wieder als 0,75/0,25-Mix.
- `if embed < 1 { return geo }`. 0,4 % ist ein Impostor, kein fehlender Print.
- Static `matchFloor` wieder process-weit.
- Ungewichteter 1/n-Centroid.
- `printVec` wieder leer lassen nach `stampPrints`.
- Coverage nur warnen, wenn Frontal und ¾ fehlen.
- TAR@FAR mit `ceil(far·n)−1` (bricht n=101 → Schwelle 10).
- Live-Box wieder EMA 0,62/0,38.
- 1-Euro nach Reconnect weiterlaufen lassen (Ghost-Box).
- Voller Print als Identität, wenn der Mund fehlt.
- TAR ohne CI bei n_impostor < 200.
- Teil-Print gegen den vollen Galerie-Centroid.
- Maske als erste Referenz.
- Tiles über einem großen Portrait-Gesicht.
- Schärfe < 0,12 trotzdem taufen (Built-in). Continuity bleibt 0,08.
- `VNGenerateFacePrint` auf unscharfen Crops.
- U-Slot als erste Referenz.
- Continuity-Yaw hart aus `videoRotationAngle` ohne Override.
- `qualityRejects` wieder ohne Continuity-Floor.
- Live-Frames droppen statt coalescen.
- U-Slot still schreiben nach Masken-Hold.
- `bugfix`-Branch fortsetzen. Nur `main`.
- Versionsstempel in Models ohne MARKETING_VERSION.
- Live-Track in der Overlay-Liste lassen, wenn `found.isEmpty`.
- Pin-Print unter 0,80.
- Leftover-IoU 0,08.
- TER-Fusion wieder in `.aegis` mischen. lookOf ist der Score.
- Geo-Veto 42/94 gegen starke Prints.
- 4× Jacobi pro Webcam-Frame.
- `lookOf` starke Prints wieder auf 60 kappen.
- Leftover-IoU wieder 0,18.
- Namensmehrheit ohne `votedPercent`.
- Auswahl jedes Live-Frame auf `adopted.first` setzen.
- Enrolled-Track-IoU wieder 0,12.
- Overlay „andere Person“ bei Cosine 0,88.
- `matchLive` immer `continuity: false`.
- `matchLive` `geoAgrees: true` / `geoMix: printPercent` faken.
- Leftover auf schon gematchte/enrolled Boxen.
- IoU-UUID setzen bei Cosine < `pinPrintCosine`.
- Volle decide-Notiz in die Overlay-Kiste.
- Leftover über Galerie-UUIDs (Live-Track ≠ Snapshot seit 2.1.17).
- Leftover ohne Print (nil-Cosine).
- Geo-Median über alle Posen gegen eine ¾-Sonde.
- Geo-Veto ¾-Sonde (yaw ≥ 0,28) gegen Frontal-Maße bei Print ≥ 80.
- `gallery.json` ohne schemaVersion schreiben.
- `bugfix`-Branch anlegen oder fortsetzen. Nur `main`.
- Leftover first-in-order statt nächstem Print.
- `liveCentroid` wieder 72/28 über alle Posen gegen eine ¾-Sonde.
- Neuen Print bei Box-Sprung (Motion-Blur) übernehmen.
- Yaw-Skip ohne Notiz.
- TER-Fusion wieder default an.
- Hysterese-Box der Vorperson trotz Print-Pin halten.
- Restore ohne Dialog bei Schema < 2.
- Leftover wieder über `pinPrintCosine` 0,80 (Genuine 0,75 tot).
- `lookOf` 80–83 % wieder auf 60 kappen.
- Hold-Still wieder hart IoU 0,82 ohne Schärfe.
- `liveCentroid` All-Mean rechnen, bevor der Slot trifft.
- `matchLive` Roh-Print statt lookOf.
- Geo-Veto skip erst ab 88 (80–87 % mit Jacke tot).
- Leftover-Floor 0,72 (Genuine 0,62–0,71 tot).
- Unscharfen Print in den Median-Trail.
- Leftover-Ranking nur Cosine (unscharf 0,73 schlägt scharf 0,72).
- `lookOf` mit `printMeasured: true` ohne Vektor-Paar (Geo tauft).
- leftover ohne Pose-Slot (¾ auf Frontal-Ghost).
- leftover sameSlot Fallback auf andere Slots.
- IoU-Hold gegen anderen Print-Pin zwei Frames stehen lassen.
- namenloser Print-Pin stiehlt IoU-Hold.
- Look≠Print taufen.
- Print-Trail Frontal+¾ mischen.
- Identität nur über Löschen+neu umbenennen.
- Rename ohne Duplikat-Confirm.
- gallery.json ohne fsync.
- Overlay nur „Print 82%“ ohne Look.
- Ein Look=Print-Tick tauft.
- Look≠Print als Namensstimme.
- Rename-Confirm ohne Timeout.
- `.bak` ohne fsync.
- 1-Euro Cutoff unabhängig von Box-Fläche.
- Overlay ohne Slot-Buchstaben.
- Leftover-Kiste dieselbe Farbe wie enrolled.
- Taufe still, ohne `n/need` im Overlay.
- Continuity still Fallback ohne Picker.
- Close-Pair ohne Badge.
- leftover ≥ 0,80 weiter orange nach Taufe.
- Anlegen ohne Coach („Pose fehlt ¾“ ohne Richtung).
- Look≠Print bei Print-Abstand ≥ 8 totlegen (Geo-Rauschen = nie Taufe).
- leftover jeden Tick leere Namens-Tokens füttern (Genuine 0,64–0,79 hungert).
- leftoverHold nach erfolgreicher Mehrheit stehen lassen (ewig orange).
- Leere Look≠Print-Tokens in den Hist-Cap (Taufe stirbt nach 10 Uneinig).
- `identityId = nil` sobald keine Mehrheit, trotz vorheriger Taufe.
- `bugfix`-Branch anlegen oder fortsetzen. Nur `main`.
- Yaw-Freeze ohne Pitch (Nicken tauft den Nachbarn).
- Pose-Freeze ohne Roll (Schulterzucken tauft).
- `boxesCrossed` nur Keep < Pin (IoU-Hold 0,30 macht Swap tot).
- Assigned-Swap über Box-IoU nach greedy Zuweisung (Keep hoch, Swap tot).
- Pose-Freeze ohne dt (8 fps Pitch-Rauschen tot).
- `identitiesCrossed` nur `adopted.count == 2`.
- Overlay-Index statt Track-ID.
- Print-Drift unsichtbar.
