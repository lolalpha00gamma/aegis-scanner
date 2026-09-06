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
