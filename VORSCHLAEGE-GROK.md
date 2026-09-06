# Nachtrag 2026-09-06 — 1.5.163 / 2.1.165 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.163** (Build 182).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.165 alpha** (Build 190).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **2.1.164 Compile-Loch.** `leftoverCoastCosine(skipDetect:)` in `applyLiveFaces`, Parameter nie übergeben. Coast existierte in MatchMath, Binary kompiliert nicht bzw. Coast nie am Pin.
2. **skipPrints ≠ skipDetect.** 24 fps `printBudgetSkip` (Vision > 18 ms) setzt skipDetect false. FaceEngine boxed ohne Print. leftoverCoastCosine gab nil, leftoverHold tot — IoU-only Taufe.
3. **leftoverPickPrint `{ raw }`.** cosine nil → leftoverPrintOk false, leftoverHoldSmooth nil, origRaw −1, Gallery-Floor Unsure. Selbst mit Coast am Call-Site fiel leftoverPick ohne Hold-Fill.
4. **FaceTrack 8 Felder.** StreakBox/Kalman/Pair nicht im Struct. pairLast-UUID nach Remint Zombie.
5. **Claim hämmert.** LOCK_NB-Fail alle 80 ms hinter Aegis-Write. 3 Fails brauchen 400 ms Pause.
6. **Models.build 188 vs Binary 189.** HUD log hinter MARKETING.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.163 / 2.1.165 gelandet

- `applyLiveFaces(skipDetect:skipPrints:)` — Coast kompiliert und läuft.
- `leftoverCoastCosine(skipPrints:)` — printBudgetSkip hält leftoverHold.
- `leftoverPickPrint` raw ?? Hold, leftoverPick `holdOf` in leftoverPrintOk/Smooth/origRaw.
- FaceTrack StreakBox/Kalman/Pair. Pack/Unpack/Remint. pairLast-Value wird mit-remintet.
- `cameraMutexClaimBackoffFails` 3 / `ClaimBackoffDt` 400 ms (Helios CameraSession zählt SkipClaim + Write-Fail).
- Models.build 190 = MARKETING 2.1.165. Tests + 1.5.163 / 2.1.165 (Build 182 / 190).

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Observation-order von Vision. Scale-Gate 0,28 zittert bei 8 fps.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref liegt in Helios-UserDefaults; Aegis hat eigene Keys. Kein App-Group bis CameraBroker.

### Aegis

- LibraryStore droppt Maps weiter einzeln — FaceTrack-Pack sitzt, Store umzieht nicht.
- LiveCapture MainActor plus startRunning auf outputQueue.
- gallery.json ohne WAL-Log (rotate 3 mildert, ersetzt kein Journal).
- leftoverSoftmaxBlocks läuft weiter auf leftoverScore, nicht Roh — absichtlich: softmax([0,73, 0,72]) pmax≈0,54 < 0,55 würde den Schärfe-Flip blocken.
- Coast speichert nur Cosine, nicht den letzten featurePrint.

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

## Erweiterungen (zusätzlich, neu oben)

1. **LibraryStore → ein FaceTrack-Dict.** Pack sitzt (StreakBox/Kalman/Pair). Store hat noch 24 Maps + 24 RemintDrop.
2. **Coast-Print Vector:** letzten `VNFaceObservation.featurePrint` je Track cachen. Detect-Skip rechnet Cosine gegen den Cache, nicht nur leftoverHold-Zahl.
3. **Print-Budget 24 fps:** skipPrints nur wenn Kalman-IoU ≥ 0,92 *und* Yaw-Δ < 8°. Sonst ein Print trotz 19 ms.
4. **Two-Phase Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
5. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen — 0,72 scharf vs 0,73 blur muss durch.
6. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC. Größter einzelner Effizienzgewinn.
7. **App-Group `group.helios.aegis`:** Yield-Grace, Mutex-Pfad, destEdgePad je Display-UUID einmal. Panel in Helios steuert Aegis ohne Broker.
8. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt.
9. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
10. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
11. **Prefs je camera uniqueID** (Orient, Format, Pad).
12. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
13. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
14. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt) + OSLog.
15. **Center Stage force-off nach Sleep** in beiden Clients.
16. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s, Detect-Skip Hold überlebt, skipPrints 24 fps Hold überlebt.
17. **Echte Maus:** HID-Tap, Warp 0,8 s Pause. Reanchor 4 Hz, RMS > 8 px (Kamera-Tick sitzt, HID fehlt).
18. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
19. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
20. **destEdgePad Pref je Display-UUID.**
21. **IOHID Event-Tap** statt CGEvent-Post (`bugfix`).
22. **AX SetPosition ein Call/Frame** (`bugfix`).
23. **Per-App Gain aus AX bundle id** (`bugfix`).
24. **Gesture-Log JSONL** neben Filmstreifen (`bugfix`).
25. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
26. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
27. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
28. **maximumHandCount 2 + Joint-Group** statt Observation-first.
29. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
30. **Tests splitten** (GestureTests / MatchMathTests).
31. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
32. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
33. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
34. **Helios Kill-Switch Datei** neben Mutex (Aegis liest, mutet Baptize solange Faust-Lock).
35. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
36. **Overlay Metal instanced bones** — SwiftUI ForEach 21 Joints × 2 Hände bei 90 Hz tot.
37. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
38. **Helios palmScale histogram prior** — Gitarre 0,29 vs Hand 0,14 als Bayes, nicht hartes Gate 0,28.
39. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
40. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei (Linux-CI mit Fixture, ohne AVCapture).
41. **Mutex expected-gen CAS** zusätzlich zu LockedLine (Read-Modify-Write-Loch zwischen Parse und Write).
42. **Claim-Telemetry Chip** (dt, skip-ratio, backoff-fails) im HUD neben helios/YIELD.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`, leftoverSoftmaxBlocks auf Roh.
Nächster Code-Schritt: LibraryStore → FaceTrack-Dict oder CameraBroker oder Overlay-Metal.
