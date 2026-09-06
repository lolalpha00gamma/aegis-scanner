# Nachtrag 2026-09-06 — 1.5.162 / 2.1.164 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.162** (Build 181).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.164 alpha** (Build 189).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **Claim % 8.** Continuity 8 fps × 8 = 1 s zwischen Mutex-Writes. Aegis-Heartbeat 2 s sah Lücken, Yield/Steal flackerte.
2. **leftoverPick Argmax auf leftoverScore.** Schärfe/Yaw/Heat-Inflation wählte den Nachbarn (0,65 scharf + Detector 0,99 schlägt 0,80 roh), obwohl Gallery-Floor schon auf Roh-Cosine stand.
3. **Detect-Skip ohne Print.** Kalman-Coast setzt `FaceObservation.coast` mit leerem Print. leftoverPick sah cosine nil → leftoverHold starb, IoU-only Taufe des Nachbarn.
4. **Kein fsync vor LOCK_UN.** Crash/Kill mitten im Write = leere Caches-Lock. Reader fällt auf Legacy-tmp oder holder=nil.
5. **Yield-Grace hart 4 s, kein Panel.** Auto-Return unsichtbar. Operator konnte nicht 2–8 s oder Aus wählen.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL. Unsure-statt-Gast und flock-NB lagen schon auf main.

## In 1.5.162 / 2.1.164 gelandet

- `cameraMutexClaimDue` 80 ms (8 fps jeder Frame, 60 fps gedrosselt) statt `geometryTick % 8`.
- `cameraMutexFsyncBeforeUnlock` vor LOCK_UN in Helios und Aegis.
- Yield Auto-Return + Grace 2–8 s: Helios ControlPanel, Aegis Toolbar, LiveCapture liest Pref.
- `leftoverPickArgmax` auf Roh-Cosine; leftoverScore nur Tie-Break bei Spread ≤ 0,08. Open-Set-Unsure auf Roh, außer Schärfe dreht.
- `leftoverCoastCosine`: Detect-Skip hält leftoverHold wenn live-Print leer.
- Tests + MARKETING_VERSION 1.5.162 / 2.1.164 (Build 181 / 189).

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Observation-order von Vision. Scale-Gate 0,28 zittert bei 8 fps.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref liegt in Helios-UserDefaults; Aegis hat eigene Keys. Kein App-Group bis CameraBroker.

### Aegis

- FaceTrack Unpack sitzt, LibraryStore droppt Maps einzeln — StreakBox/Kalman nicht im Struct.
- LiveCapture MainActor plus startRunning auf outputQueue.
- gallery.json ohne WAL-Log (rotate 3 mildert, ersetzt kein Journal).
- 24 Maps bleiben im RAM; Pack/Unpack nur 8 Felder.
- leftoverSoftmaxBlocks läuft weiter auf leftoverScore, nicht Roh.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild der Maschine.
`bugfix` 1.5.8 / 2.1.15 nicht mergen. Von dort bereits auf main: Dead-Man/Fling/Wischen (1.5.127), destEdgePad (1.5.149), flock NB, Unsure statt Gast.
Dieser Pass aus bugfix: Yield-Pref ins Panel (Idee), IOHID/AX/Per-App-Gain/JSONL bleiben Vorschlag.

Pass 1: Mutex + Assign + Detect-Skip-Print — 1.5.152 / 2.1.160.
Pass 2: Caches/flock + Yield-Reconfigure + Munkres/4-opt + FaceTrack — 1.5.158 / 2.1.161.
Pass 3: Skip-Vision, RemintDrop (nur IoU), Yield-Grace, Open-Set, USB-Watchdog — 1.5.160 / 2.1.162.
Pass 4: RemintDrop alle Maps, Gallery-Floor Roh, flock NB, CAS LockedLine, tmp-Write tot, bak 3, Reanchor Kamera-Tick, freezeAxis Drop — 1.5.161 / 2.1.163.
Pass 5: ClaimDue 80 ms, leftoverPickArgmax Roh, Coast-Print, fsync, Yield-Pref Panel — 1.5.162 / 2.1.164.

## Erweiterungen (zusätzlich, neu oben)

1. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC. Größter einzelner Effizienzgewinn.
2. **App-Group `group.helios.aegis`:** Yield-Grace, Mutex-Pfad, destEdgePad je Display-UUID einmal. Panel in Helios steuert Aegis ohne Broker.
3. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt. Two-Phase INTENT → Yield → CONFIRM.
4. **LibraryStore → ein FaceTrack-Dict** inkl. StreakBox/Kalman/Pair. Eine Remint-Funktion, Pack/Unpack alle 24 Maps.
5. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
6. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
7. **Prefs je camera uniqueID** (Orient, Format, Pad).
8. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
9. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
10. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt) + OSLog.
11. **Center Stage force-off nach Sleep** in beiden Clients.
12. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s, Detect-Skip Hold überlebt.
13. **Echte Maus:** HID-Tap, Warp 0,8 s Pause. Reanchor 4 Hz, RMS > 8 px (Kamera-Tick sitzt, HID fehlt).
14. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
15. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
16. **destEdgePad Pref je Display-UUID.**
17. **IOHID Event-Tap** statt CGEvent-Post (`bugfix`).
18. **AX SetPosition ein Call/Frame** (`bugfix`).
19. **Per-App Gain aus AX bundle id** (`bugfix`).
20. **Gesture-Log JSONL** neben Filmstreifen (`bugfix`).
21. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
22. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
23. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
24. **maximumHandCount 2 + Joint-Group** statt Observation-first.
25. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
26. **Tests splitten** (GestureTests / MatchMathTests).
27. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
28. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
29. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
30. **Helios Kill-Switch Datei** neben Mutex (Aegis liest, mutet Baptize solange Faust-Lock).
31. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
32. **Overlay Metal instanced bones** — SwiftUI ForEach 21 Joints × 2 Hände bei 90 Hz tot.
33. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
34. **Helios palmScale histogram prior** — Gitarre 0,29 vs Hand 0,14 als Bayes, nicht hartes Gate 0,28.
35. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
36. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei (Linux-CI mit Fixture, ohne AVCapture).
37. **leftoverSoftmaxBlocks auf Roh-Cosine**, Score nur Tie-Break analog leftoverPickArgmax.
38. **Coast-Print Vector** nicht nur Cosine-Hold: letzten VNFaceObservation.featurePrint cachen, Detect-Skip rechnet Cosine gegen den Cache.
39. **Mutex gen++ compare-and-swap** file-lock + expected-gen. Claim ohne Read-Modify-Write-Loch zwischen Parse und Write (LockedLine sitzt, expected-gen fehlt).
40. **Claim-Telemetry Chip** (dt, skip-ratio) im HUD neben helios/YIELD — 1 s Lücke wieder sichtbar.
41. **Aegis Yield-Pref lesen aus Helios UserDefaults** sobald App-Group sitzt; bis dahin zwei Keys.
42. **FaceTrack.lastPrint** in Pack/Unpack, LibraryStore remintet ein Dict statt 24 Maps.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`.
Nächster Code-Schritt: CameraBroker oder FaceTrack inkl. StreakBox oder Overlay-Metal.
