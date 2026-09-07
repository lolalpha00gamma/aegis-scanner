# Nachtrag 2026-09-07 — 1.5.170 / 2.1.172 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.170** (Build 189).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.172 alpha** (Build 197).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.169 Hist-Prior. 2.1.171 Unsure-Streak/Coast-TTL. Fünf Löcher blieben: Gitarre Conf ohne Hist, Guitar-Hist lockt S1, printBudget ohne Still, Coast-Stamp restampt Cache, Kalman-Predict unverdrahtet.

## Warum es schlecht wirkte (dieser Pass)

1. **palmBind Conf ohne Compact.** 0,29 und 0,14 sind beide palmScaleIsHand (< 0,72). Tick 0 Ring leer: Conf 0,95 = S1 Prop.
2. **Hist-Prior bei Guitar-Median.** med 0,29, jump 0 → Prior 1 für beide. Compact erholt S1 nicht. Ring nahm 0,29.
3. **printBudgetSkip ohne stillFor.** Still 0,10 s + IoU 0,95 skippt Print. Coast-TTL 2 s, Twin im Kalman-Kasten = Ada.
4. **leftoverCoastPrintStampMerge restampte Cache.** skipPrints→Detect, live = stored, Stamp = now. TTL tot.
5. **leftoverPredictHeld rief boxKalmanPredict.** leftoverFaceTrackKalmanPredict saß, Store nicht.
6. **Overlay `?` ohne Streak.** leftoverUnsureTicks ungelesen.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.170 / 2.1.172 gelandet

- **palmBindCompactPrefers** vor Conf. Compact < 0,28 vor Gitarre-Range, auch ohne Hist.
- **palmScaleHistPrior Guitar-Hist.** med ≥ 0,28 → Compact 1, Gitarre 0.
- **palmScaleMedianRecords.** 0,29 nicht in lastS1ScaleRing.
- **palmSlotConfEma / palmSlotConfHolds.** 1-Frame Dip hält S1.
- **printBudgetSkip(stillFor:).** < 0,80 s kein Skip. LibraryStore min(liveStillFor).
- **leftoverCoastPrintSame / StampMerge(stored:).** Identischer Vec kein Restamp.
- **leftoverPredictHeld → leftoverFaceTrackKalmanPredict.** Cap 0,12.
- **leftoverUnsureChip(streak:) `??`.** leftoverOverlayGuest liest leftoverUnsureTicks.
- Tests + MARKETING 1.5.170 / 2.1.172 (Build 189 / 197). Schema 15 bleibt.

Pass 13: Compact vor Conf, Guitar-Hist-Erholung, stillFor, Coast-Stamp, Kalman-Predict, Overlay `??` — 1.5.170 / 2.1.172.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Predict sitzt, Maps bleiben Schatten.
2. **Coast-Print in gallery.json** mit Age. Restart sonst Twin neu.
3. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
4. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
5. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot.
6. **IOHID Event-Tap** statt CGEvent (`bugfix`).
7. **AX SetPosition ein Call/Frame** (`bugfix`).
8. **Per-App Gain aus AX bundle id** (`bugfix`).
9. **Gesture-Log JSONL** (`bugfix`).
10. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
11. **Pair-Commit WAL** in gallery.json.
12. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
13. **VNDetectHumanBodyPose** als Prop-Veto. Compact-Prefer sitzt, Body-Pose ist die harte Spur.
14. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
15. **Lokaler Telemetry-Ring 30 s** + OSLog.
16. **Center Stage force-off nach Sleep.**
17. **Continuity USB-Hub Watchdog** nach Sleep.
18. **Per-Slot One-Euro Cutoff aus fps.**
19. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
20. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
21. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
22. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
23. **Gallery compaction:** pruneCosine 0,98 Burst raus.
24. **Aegis live outputQueue ≠ MainActor.**
25. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute.
26. **destEdgePad Pref je Display-UUID.**
27. **Kalman-Zeiger 2D** constant-velocity.
28. **maximumHandCount 2** hart. Compact-Prefer sitzt, Vision liefert weiter 4.
29. **Latency-HUD** Tick zu AX-move.
30. **Prefs je camera uniqueID.**
31. **leftoverSoftmaxBlocks bleibt auf leftoverScore.**
32. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
33. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID.
34. **FaceTrack Encode in gallery.json extra.**
35. **Speaker-Diarization** als Aegis-Cue.
36. **Face-Print ONNX sidecar** optional neben Vision.
37. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM.**
38. **printBudget aus FaceTrack.stillFor** sitzt. Per-Face statt min() — Twin bewegt, Ada still: Ada skippt nicht mehr mit.
39. **palmSlotConfEma je Slot**, nicht nur S1 lastHands. S2 Dip tot.
40. **CI `swiftc` MatchMathTests + GestureTests vor DMG.**
41. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV). 0,28 ist Desk-fest.
42. **S1+S2 Chirality-Freeze 800 ms** nach beiden gesehen — Flip tot.
43. **leftoverHold-Write nur nach Yaw-Bin-Coverage** (F+¾+P). Frontal-Hold auf Profil tot.
44. **Negativ-Galerie** (bekannte Nicht-Matches) als Open-Set-Stütze.
45. **Print-Bank PCA-Whitening** vor Cosine.
46. **Cursor-Magnetismus** 8 px an AX-Hit.
47. **Helios Dwell-Klick** optional neben Pinzette.
48. **Watch-Companion** Haptic-Klick.
49. **Aegis Spotlight-Importer** für die Foto-Mediathek.
50. **Doorbell-Cue** — wer gerade ins Bild kam.
51. **Maus-Jiggle-Suppressor** ohne Hand.
52. **Clamshell: Vision pausieren** (Akku).
53. **Jerk Dead-Man** für versehentliches Fling (Hochpass sitzt, Ruck-Gate fehlt).
54. **Shared Lock Schema v2** generation + intent + palm-rect + face-rect.
55. **Vision Pro / Spatial Persona Sidecar.**

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal. printBudget per-Face stillFor. palmSlotConf je Slot.

# Nachtrag 2026-09-07 — 1.5.169 / 2.1.171 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.169** (Build 188).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.171 alpha** (Build 196).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.168 Joint-Group. 2.1.170 Unsure/IoU. Vier Löcher blieben: leftoverTried auf Unsure, Coast-Vec ohne Alter, Name-Hist 3 Votes nach Remint, Gitarre Conf 0,95 vor Hand 0,14.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverTried.insert auf Unsure.** leftoverPinStatus zählte einen Pin. leftoverTried sperrte denselben leftover in der AssignLive-Nachlese. Twin ohne Vec wirkte „gehalten“.
2. **Unsure ewig.** leftoverClearStreak lief nicht. leftoverHold/Coast überlebten `?` bis Dropout. Overlay Gast-Chip für immer.
3. **leftoverCoastPrint ohne TTL.** skipPrints + Stillstand: Cache ≥32, Cosine 1,0 gegen sich selbst. Twin im Kalman-Kasten = Ada.
4. **liveNameHist Remint voll.** 3 Ada-Votes wandern auf die neue UUID. stabilizeLiveMatches tauft Twin Tick 0.
5. **palmBind Conf vor Hist.** Gitarre 0,29 Vision-Conf 0,95 vor Hand 0,14. Joint-Group nur 16 vs 6, nicht Scale-Sprung.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.169 / 2.1.171 gelandet

- **leftoverTriedInserts / leftoverPinCounts.** Unsure kein Tried, kein Pin. LibraryStore verdrahtet.
- **leftoverUnsureStreakAdvance / leftoverUnsureStreakClears.** 3× `?` → leftoverClearStreak + Remint-Live. Lookup über remintPlan.
- **leftoverCoastPrintFresh (2 s) + leftoverCoastPrintStampMerge.** skipPrints Stamp hält. LibraryStore SkipCosine liest nur frische Vecs.
- **leftoverNameHistRemintTrim keep 1.** remap tot = Hist hält.
- **palmScaleHistPrior soft.** Jump 0,08–0,12 linear. Veto bleibt 0.
- **palmBindHandsFirst(hist:)** vor Conf. HandTracker lastS1ScaleRing.
- Tests + MARKETING 1.5.169 / 2.1.171 (Build 188 / 196). Schema 15 bleibt.

Pass 12: Unsure-Tried tot, Unsure-Streak, Coast-TTL, Name-Hist-Trim, Hist-Prior — 1.5.169 / 2.1.171.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** px/py sitzen im Struct, boxKalmanV remintet extra — Pack ist Schatten. Ein Dict, Apply/Decode/Encode einmal.
2. **leftoverFaceTrackKalmanPredict verdrahten.** 2.1.170 hat Vel im Struct, LibraryStore schreibt boxKalmanV separat. Predict nach Remint sonst 0.
3. **Coast-Print in gallery.json** mit Age. Restart sonst Twin neu. leftoverCoastPrintAt stirbt mit dem Prozess.
4. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
6. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Detect 8–12 fps, Overlay 60 Hz, Baptize nur Detect-Tick.
7. **IOHID Event-Tap** statt CGEvent (`bugfix`).
8. **AX SetPosition ein Call/Frame** (`bugfix`).
9. **Per-App Gain aus AX bundle id** (`bugfix`).
10. **Gesture-Log JSONL** (`bugfix`).
11. **OneEuro State in FaceTrack.** boxEuro remintet extra.
12. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Unsure-Chip sitzt, HUD fehlt.
13. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
14. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
15. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
16. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
17. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt, unsure-ratio) + OSLog.
18. **Center Stage force-off nach Sleep** in beiden Clients.
19. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
20. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
21. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
22. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
23. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
24. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
25. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
26. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
27. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
28. **destEdgePad Pref je Display-UUID.**
29. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
30. **maximumHandCount 2** hart. Joint-Group + Hist-Prior sitzen, Observation-first bleibt Vision-seitig.
31. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
32. **Prefs je camera uniqueID** (Orient, Format, Pad).
33. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen.
34. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
35. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID. Live-PID mit Stamp > 6 s nach Sleep nicht SIGKILL — bewusste Grenze.
36. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct (Vel stirbt).
37. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
38. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
39. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile bis CameraBroker.
40. **leftoverUnsure Overlay `??` vs `?`.** Streak 2 anders als Streak 1. Chip sitzt `?`.
41. **printBudget aus FaceTrack.stillFor.** Still 0,8 s + IoU 0,92 skippt ehrlich, nicht nur fps.
42. **palmSlotConfEma.** Slot hält die schwächere Hand 1 Frame. Hist-Prior sitzt pro Tick.
43. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
44. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture.
45. **Coast-Vec persist Age in gallery** plus leftoverCoastPrintAt Encode.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store (boxKalmanV + leftoverCoastPrintAt + leftoverUnsureTicks hinein) oder CameraBroker oder Overlay-Metal.

# Nachtrag 2026-09-07 — 1.5.168 / 2.1.170 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.168** (Build 187).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.170 alpha** (Build 195).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.169 Lookup las Hold/Kalman/Coast, leftoverPick bekam trotzdem leftoverHold[old.id] = nil und leftoverCoastCosine schob die Hold-Zahl 0,70 als Cosine. Twin im Kalman-Kasten erbte den Namen.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverHold als Cosine.** leftoverCoastPrintSkipCosine nil → leftoverCoastCosine(stored: 0,70). leftoverPickPrint fällt auf Hold. leftoverPrintOk(0,70) pinnt. Twin ohne Vec getauft.
2. **leftoverPick holdPrev old.id.** Lookup saß nur beim Kandidaten-Bau. leftoverHoldPrevOf / leftoverAdvance lasen leftoverHold[old.id] nach Drop = nil.
3. **Detect-Skip ohne Coast-Vec.** Hold-Zahl rankte Kandidaten, nicht IoU. Nachbar mit 0,70 schlug echte Überlappung.
4. **Mutex tot-PID frei, Zombie blieb.** WRITE pidLive gibt den Lock frei. Der tote PID-Eintrag nach Sleep wurde nicht SIGKILL — hung Prozess 12 s.
5. **palmBind Conf-Tie ohne Joint-Group.** Gitarre 6 Joints vs Hand 16, gleiche Scale: Vision-Conf, nicht Topologie.
6. **Kalman-Vel nicht im FaceTrack.** Predict nach Remint 0. Maps extra, Struct kannte px/py nicht.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.168 / 2.1.170 gelandet

- **leftoverHoldViaLookup / leftoverHoldLookupUnsure.** skipCosine nil + Hold nur Lookup → Unsure `?`. leftoverPickPrint(holdOnlyUnsure) kein Hold-Fallback. leftoverPick tot.
- **leftoverDetectSkipIoUOnly / leftoverPickArgmaxIou / leftoverPick(iouOnly).** Detect-Skip ohne Vec: max IoU, nicht Hold-Zahl.
- **leftoverCoastCosineMeasured.** LibraryStore leftover matching. holdPrev = Remint-Lookup. Overlay `?`.
- **leftoverFaceTrackKalmanVel / Predict.** px/py/pw/ph im FaceTrack. Pack/Unpack/RemintDropMaps. dt > 2 s tot.
- **cameraMutexHeartbeatKillPid / KillAllowed.** tot-PID SIGKILL unter LOCK_EX. Self nie, Live nie. CameraSession + LiveCapture.
- **palmBindJointGroupPrefers.** 16 vs 6 vor Conf-Tie. palmBindHandsFirst verdrahtet.
- Tests + MARKETING 1.5.168 / 2.1.170 (Build 187 / 195). Schema 15 bleibt.

Pass 11: Unsure ohne Vec, Detect-Skip IoU, Joint-Group, Heartbeat-SIGKILL, Kalman-Vel — 1.5.168 / 2.1.170.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Vel sitzt im Struct. Maps bleiben Schatten — ein Dict, Apply/Decode/Encode einmal.
2. **Coast-Print in gallery.json.** Restart sonst Twin neu. leftoverCoastPrint nicht nur RAM.
3. **leftoverTried nicht auf Unsure.** Nächster Tick mit Print darf pinnen. Jetzt leftoverTried.insert — Retry tot bis Dropout.
4. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
6. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Detect 8–12 fps, Overlay 60 Hz, Baptize nur Detect-Tick.
7. **IOHID Event-Tap** statt CGEvent (`bugfix`).
8. **AX SetPosition ein Call/Frame** (`bugfix`).
9. **Per-App Gain aus AX bundle id** (`bugfix`).
10. **Gesture-Log JSONL** (`bugfix`).
11. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture. Linux-CI Fixture.
12. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
13. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
14. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Unsure-Chip sitzt, HUD fehlt.
15. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
16. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
17. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
18. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
19. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt). Drift 1.5.168/2.1.170 sonst in einem Monat.
20. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt, unsure-ratio) + OSLog.
21. **Center Stage force-off nach Sleep** in beiden Clients.
22. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
23. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
24. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
25. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
26. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
27. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
28. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
29. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
30. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
31. **destEdgePad Pref je Display-UUID.**
32. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict. FaceTrack-Vel ist der Baustein.
33. **maximumHandCount 2** hart. Joint-Group sitzt, Observation-first bleibt Vision-seitig.
34. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
35. **Prefs je camera uniqueID** (Orient, Format, Pad).
36. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen.
37. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
38. **Helios palmScale histogram prior Bayes** — Gitarre 0,29 vs Hand 0,14, nicht nur hartes Gate + Veto.
39. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID. Live-PID mit Stamp > 6 s nach Sleep nicht SIGKILL — bewusste Grenze.
40. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct (Vel stirbt).
41. **stabilizeLiveMatches remint-aware.** Vote-Cap nach Remint 1 Tick statt 3.
42. **OneEuro State in FaceTrack.** boxEuro remintet extra.
43. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
44. **leftover matching Unsure-Streak.** 3× `?` hintereinander → leftoverClearStreak, nicht ewig Gast.
45. **Coast-Vec TTL.** RAM-Cache ohne Print 2 s → nil, sonst Twin nach Stillstand.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal.

# Nachtrag 2026-09-06 — 1.5.167 / 2.1.169 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.167** (Build 186).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.169 alpha** (Build 194).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.168 hat Coast-Vec und Print-Yaw-Δ. 1.5.166 Hist-Veto Live. Zwei Löcher blieben:
WRITE-Pfad des Mutex ignorierte tote PIDs; leftover matching las leftoverHold/Kalman/Coast auf old.id nach RemintDrop.

## Warum es schlecht wirkte (dieser Pass)

1. **Mutex WRITE ohne pidLive.** cameraMutexParse kill't tote PIDs auf dem Read. Unter LOCK_EX reichte LockedLine pidLive nicht durch — toter Helios-PID hielt den Lock 12 s. Aegis tot nach Crash/Sleep.
2. **RemintDrop vs leftover matching.** Hold/Kalman/Coast liegen nach Drop auf der Live-UUID. leftover matching las old.id → nil. leftoverHold-Fallback tot, Kalman-IoU tot, Coast-Cache tot.
3. Von `bugfix` bewusst nicht gemergt: IOHID, AX SetPosition, Per-App-Gain, JSONL.

## In 1.5.167 / 2.1.169 gelandet

- **cameraMutexWriteAllowed / LockedLine(pidLive:).** CameraSession + LiveCapture: kill(2) vor LOCK_EX-Write. Toter Holder → Lock frei.
- **leftoverHoldRemintLookup.** leftover matching liest Hold/Kalman/Coast über Source→Live.
- Tests + MARKETING 1.5.167 / 2.1.169 (Build 186 / 194). Schema 15 bleibt.

Pass 10: Mutex WRITE pidLive, leftoverHoldRemintLookup — 1.5.167 / 2.1.169.

## Erweiterungen (neu, oben)

1. **leftover matching Unsure** wenn leftoverCoastPrintSkipCosine nil und leftoverHold nur über Lookup sitzt — Twin ohne Vec nicht auf 0,70 taufen.
2. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Maps bleiben Schatten.
3. **CameraBroker-XPC** — eine TCC, IOSurface an beide.
4. **Mutex Heartbeat SIGKILL** des Zombies nach Sleep, nicht nur Lock frei.
5. **Coast-Print in gallery.json** — Restart sonst Twin neu.
6. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture.
7. **Kalman-Vel in FaceTrack.** Predict nach Remint sonst 0.
8. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot.
9. **IOHID Event-Tap** statt CGEvent (`bugfix`).
10. **AX SetPosition ein Call/Frame** (`bugfix`).
11. **Per-App Gain aus AX bundle id** (`bugfix`).
12. **Gesture-Log JSONL** (`bugfix`).
13. **App-Group group.helios.aegis** Yield/Mutex/Pad einmal.
14. **Detect-Skip leftover matching nur IoU** wenn beide Coast-Vec nil.
15. **Helios palmBind Joint-Group** neben Conf-Tie und Hist-Veto.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh.

# Nachtrag 2026-09-06 — 1.5.166 / 2.1.168 (kein Merge von `bugfix`)


Helios `bpms9cmnxc-debug/Helios` **1.5.166** (Build 185).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.168 alpha** (Build 193).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **printBudget |yaw| < 8°.** Frontal → 5° skippt Print. leftoverHold-Zahl vom Frontal-Tick tauft Twin. Δ seit Print fehlte.
2. **livePrintEmpty → leftoverHold-Zahl.** Kein Print-Vec. Twin im Kalman-Kasten erbt 0,85. `v.count ≥ 32` hätte Coast-Vec tot gemacht.
3. **palmBindScaleOf EMA.** Gitarre 0,29 → 0,21. Scale-Max 0,72 = Hand. Conf-Tie sitzt, Hist-Veto fehlte.
4. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.166 / 2.1.168 gelandet

- `leftoverPrintBudgetYawDelta` + `leftoverPrintYawMerge` — Yaw nur nach Print.
- `leftoverCoastPrintSkipCosine` — skipPrints Cache ≥32, ohne Live-Print.
- `printBudgetSkip(yawDelta:)` — |Δ| ≥ 8° → Print. Continuity-Gate bleibt.
- `palmScaleHistVeto` auf Live-Scale — Bind-EMA tot.
- Tests + 1.5.166 / 2.1.168 (Build 185 / 193).

Pass 9: Coast-Vec, Print-Yaw-Δ, Hist-Veto Live — 1.5.166 / 2.1.168.

# Nachtrag 2026-09-06 — 1.5.165 / 2.1.167 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.165** (Build 184).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.167 alpha** (Build 192).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **Name-Hist / Print-Trail / Blink / Still / 1-Euro nur `filter keepBoxes`.** FaceTrack remintete Hold/Yaw. Nach Vision-UUID-Remint blieben Mehrheit, Median-Print, Liveness und Box-Euro auf der Source-UUID — Overlay **Gast** 3 Ticks, Taufe neu.
2. **leftoverCoastCosine nahm live vor Hold.** skipPrints + leerer Print: Rest-Cosine überschrieb leftoverHold. Twin nach Detect-Skip falsch.
3. **printBudget ohne Continuity-Gate.** liveDt-Jitter 16 ms skippte Desk-View-Prints obwohl 8 fps gemeint war.
4. **Task.detached las `liveYaw`.** MainActor-Map im Detached-Task — printBudget-Yaw raste.
5. **palmBindHandsFirst Observation-Order.** Gleiche Scale/Counts: Vision-Reihenfolge, nicht Conf. Gitarre/zweite Hand stiehlt S1.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL, familyBump-only-Best-Paar (längst auf main).

## In 1.5.165 / 2.1.167 gelandet

- **FaceTrack Yaw/Still/EMA/Blink/Lid/Open/Vote.** Pack+RemintDropMaps. LibraryStore verdrahtet.
- **leftoverHoldRemintDrop** auf Name-Hist, Print-Trail, Drift, Score-Ticks, 1-Euro, Landmark, Capture-Hist, Tap-Lock, Mask-Hold, Jump-Pending.
- **leftoverCoastCosine(livePrintEmpty:).** Skip ohne Print nimmt Hold.
- **printBudgetSkip(continuity:).** Continuity nie skip.
- **Yaw-Snapshot vor Task.detached.**
- **palmBindHandsFirst(confs:).** Höhere Vision-Conf vor Observation-Order.
- Tests + MARKETING 1.5.165 / 2.1.167 (Build 184 / 192). Schema 15 bleibt.

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Scale-Gate 0,28 zittert bei 8 fps. Conf-Tie sitzt, Joint-Group fehlt.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref liegt in Helios-UserDefaults; Aegis hat eigene Keys. Kein App-Group bis CameraBroker.

### Aegis

- FaceTrack remintet Skalare, Store hält die Maps noch parallel — nächster Schritt: ein `[UUID: FaceTrack]` als Source of Truth.
- Kalman-Vel (px/py) nicht im FaceTrack. Coast-Print speichert Trail, nicht den letzten `VNFaceObservation`.
- LiveCapture MainActor plus startRunning auf outputQueue.
- gallery.json ohne WAL-Log (rotate 3 mildert, ersetzt kein Journal).
- leftoverSoftmaxBlocks läuft weiter auf leftoverScore, nicht Roh — absichtlich.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild der Maschine.
`bugfix` 1.5.8 / 2.1.15 nicht mergen. Von dort bereits auf main: Dead-Man/Fling/Wischen (1.5.127), destEdgePad (1.5.149), flock NB, Unsure statt Gast.
Dieser Pass aus bugfix: nichts gemergt. IOHID/AX/Per-App-Gain/JSONL bleiben Vorschlag.

Pass 1: Mutex + Assign + Detect-Skip-Print — 1.5.152 / 2.1.160.
Pass 2: Caches/flock + Yield-Reconfigure + Munkres/4-opt + FaceTrack — 1.5.158 / 2.1.161.
Pass 3: Skip-Vision, RemintDrop (nur IoU), Yield-Grace, Open-Set, USB-Watchdog — 1.5.160 / 2.1.162.
Pass 4: RemintDrop alle Maps, Gallery-Floor Roh, flock NB, CAS LockedLine, tmp-Write tot, bak 3, Reanchor Kamera-Tick, freezeAxis Drop — 1.5.161 / 2.1.163.
Pass 5: ClaimDue 80 ms, leftoverPickArgmax Roh, Coast-Print, fsync, Yield-Pref Panel — 1.5.162 / 2.1.164.
Pass 6: skipDetect Scope, skipPrints-Coast, leftoverPickPrint Hold, FaceTrack extra, ClaimBackoff — 1.5.163 / 2.1.165.
Pass 7: FaceTrack-Remint verdrahtet, printBudget IoU+Yaw, expected-gen CAS, ClaimChip, liveYaw Remint, Aegis ClaimBackoff — 1.5.164 / 2.1.166.
Pass 8: FaceTrack Live-Skalare, Name-Hist/Print-Trail/1-Euro remintet, Coast livePrintEmpty, Continuity nie skip, Bind-Conf, Yaw-Snapshot — 1.5.165 / 2.1.167.

## Erweiterungen (zusätzlich, neu oben)

1. **leftoverPrintYaw in FaceTrack.** Extra-Map nach Remint, Print-Budget sonst nach Twin-ID taub.
2. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
3. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Skalare reminten. Maps bleiben Schatten — ein Dict, Apply/Decode/Encode einmal.
2. **Coast-Print Vector:** letzten `VNFaceObservation.featurePrint` je Track cachen. Trail remintet, der Vision-Blob nicht.
3. **Kalman-Vel in FaceTrack** (px/py/pw/ph). Sonst Predict nach Remint 0. Vel-Map remintet extra, nicht im Struct.
4. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`:** Yield-Grace, Mutex-Pfad, destEdgePad je Display-UUID einmal. Panel in Helios steuert Aegis ohne Broker.
6. **Two-Phase Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
7. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt.
8. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
9. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Blink überlebt Remint, HUD fehlt.
10. **Prefs je camera uniqueID** (Orient, Format, Pad). printBudget Continuity-Gate sitzt, Pref je Cam fehlt.
11. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
12. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
13. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt) + OSLog.
14. **Center Stage force-off nach Sleep** in beiden Clients.
15. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s, Detect-Skip Hold überlebt, skipPrints 24 fps nur bei IoU≥0,92, Yaw 20° druckt, liveYaw überlebt Remint, Name-Hist überlebt Remint, Continuity nie skip, Bind-Conf vor Order, CAS Gen mismatch Aegis tot.
16. **Echte Maus:** HID-Tap, Warp 0,8 s Pause. Reanchor 4 Hz, RMS > 8 px (Kamera-Tick sitzt, HID fehlt).
17. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
18. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
19. **destEdgePad Pref je Display-UUID.**
20. **IOHID Event-Tap** statt CGEvent-Post (`bugfix`).
21. **AX SetPosition ein Call/Frame** (`bugfix`).
22. **Per-App Gain aus AX bundle id** (`bugfix`).
23. **Gesture-Log JSONL** neben Filmstreifen (`bugfix`).
24. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
25. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
26. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
27. **maximumHandCount 2 + Joint-Group** statt Observation-first. Conf-Tie sitzt.
28. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
29. **Tests splitten** (GestureTests / MatchMathTests).
30. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
31. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
32. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
33. **Helios Kill-Switch Datei** neben Mutex (Aegis liest, mutet Baptize solange Faust-Lock).
34. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
35. **Overlay Metal instanced bones** — SwiftUI ForEach 21 Joints × 2 Hände bei 90 Hz tot.
36. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
37. **Helios palmScale histogram prior** — Gitarre 0,29 vs Hand 0,14 als Bayes, nicht hartes Gate 0,28.
38. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
39. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei (Linux-CI mit Fixture, ohne AVCapture).
40. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen — 0,72 scharf vs 0,73 blur muss durch.
41. **Claim-Telemetry Ring** 30 s skip-ratio + lastDt neben dem Chip (Chip sitzt, Ring fehlt).
42. **Mutex flock owner-PID in der Zeile schon da** — nach Sleep SIGKILL des Zombies, nicht 12 s stale.
43. **printBudget je uniqueID:** Continuity-Gate sitzt (nie skip). Pref je Cam (Built-in 30 fps vs 24) fehlt.
44. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct.
45. **leftoverLivePrintVec** neben Trail: letzter Roh-Vektor, nicht Median-5. Twin-Coast ehrlich.
46. **stabilizeLiveMatches vor matchLive remint-aware.** Hist sitzt. Vote-Cap nach Remint 1 Tick statt 3 wäre weicher.
47. **OneEuro State in FaceTrack.** boxEuro remintet extra, Struct kennt den Filter nicht.
48. **Vision revision + observation UUID persist** über VNTrackObjectRequest statt eigenes Remint.
49. **Helios Slot-Conf EMA** in PalmSlot — Conf-Tie sitzt pro Tick, Slot hält die schwächere Hand über 1 Frame.
50. **Kill-Switch + Baptize-Mute Datei** testdriven: Helios schreibt, Aegis skippt leftoverPick solange Faust-Lock.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`, leftoverSoftmaxBlocks auf Roh, Kalman-Vel in FaceTrack ohne Test auf der Maschine.
Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal.
