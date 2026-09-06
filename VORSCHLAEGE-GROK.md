# Nachtrag 2026-09-06 — 1.5.164 / 2.1.166 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.164** (Build 183).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.166 alpha** (Build 191).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **LibraryStore remintete 24 Maps einzeln.** FaceTrack-Pack saß seit 2.1.165, Store rief ihn nie auf. Eine vergessene Map (liveYaw) blieb auf der Source-UUID — nach Remint war Yaw tot, printBudget und Lookaway trafen Luft.
2. **printBudgetSkip nur dt + 18 ms.** 24 fps + Vision 19 ms skippte den Print auch bei IoU 0,50 und Yaw 20°. leftoverCoastCosine hielt die alte Cosine, Twin-Taufe nach Kopfdrehung.
3. **Mutex expected-gen tot.** LockedLine bumpte Gen unter LOCK_EX, prüfte die SH-Read-Gen nicht. Aegis Heartbeat + Claim konnten dieselbe Zeile zweimal auf Gen N schreiben.
4. **Aegis zählte LOCK_NB-Fails nicht.** Helios hatte ClaimBackoff, Aegis-Heartbeat behandelte busy als holder=nil-Pause ohne Fail-Zähler. Chip log „—“ während Helios schrieb.
5. **HUD-Chip ohne Druck.** `helios` / `YIELD` ohne Fail-Count. Contention unsichtbar.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL, familyBump-only-Best-Paar (längst auf main).

## In 1.5.164 / 2.1.166 gelandet

- **LibraryStore → FaceTrack-Remint.** Hold/Pending/Streak/Hash/IoU/Name/Miss/StreakBox/Pair in einem Pack, ein RemintDrop, Unpack ohne Defaults. Kalman-Vel bleibt eigene Map (px/py).
- **liveYaw/Pitch/Roll reminten** mit dem Plan — sonst printBudget-Yaw und Lookaway nach UUID-Remint tot.
- **printBudgetSkip(minIoU:yawAbs:).** Skip nur wenn IoU ≥ 0,92 *und* |yaw| < 8°. Unstabiler Track druckt trotz 19 ms.
- **cameraMutexCasAllows / expectedGen.** Aegis bricht bei Gen-Mismatch ab, Helios schreibt (Continuity-Vorrang).
- **cameraMutexClaimChip.** `helios · 1nb` / `helios · backoff` / `YIELD`. Overlay-Ton backoff = 1.
- **Aegis mutexClaimFails + ClaimDue** analog Helios. SkipClaim busy zählt.
- Unpack schreibt Defaults nicht mehr in die Maps (Hold 0 / pending "" / miss 0).
- Tests + MARKETING 1.5.164 / 2.1.166 (Build 183 / 191). Schema 15 bleibt.

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Observation-order von Vision. Scale-Gate 0,28 zittert bei 8 fps.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref liegt in Helios-UserDefaults; Aegis hat eigene Keys. Kein App-Group bis CameraBroker.

### Aegis

- FaceTrack remintet, Store hält die Maps noch parallel — nächster Schritt: ein `[UUID: FaceTrack]` als Source of Truth.
- Kalman-Vel (px/py) nicht im FaceTrack. Coast-Print speichert nur Cosine, nicht den letzten featurePrint.
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

## Erweiterungen (zusätzlich, neu oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Remint sitzt. Maps bleiben Schatten — ein Dict, Apply/Decode/Encode einmal.
2. **Coast-Print Vector:** letzten `VNFaceObservation.featurePrint` je Track cachen. Detect-Skip rechnet Cosine gegen den Cache, nicht nur leftoverHold-Zahl.
3. **Kalman-Vel in FaceTrack** (px/py/pw/ph). Sonst Predict nach Remint 0.
4. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`:** Yield-Grace, Mutex-Pfad, destEdgePad je Display-UUID einmal. Panel in Helios steuert Aegis ohne Broker.
6. **Two-Phase Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
7. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt.
8. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
9. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
10. **Prefs je camera uniqueID** (Orient, Format, Pad).
11. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
12. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
13. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt) + OSLog.
14. **Center Stage force-off nach Sleep** in beiden Clients.
15. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s, Detect-Skip Hold überlebt, skipPrints 24 fps nur bei IoU≥0,92, Yaw 20° druckt, liveYaw überlebt Remint, CAS Gen mismatch Aegis tot.
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
27. **maximumHandCount 2 + Joint-Group** statt Observation-first.
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
43. **printBudget je uniqueID:** Continuity 8 fps nie skip, Built-in 24 fps mit IoU-Gate (Gate sitzt, Pref je Cam fehlt).
44. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`, leftoverSoftmaxBlocks auf Roh, Kalman-Vel in FaceTrack ohne Test auf der Maschine.
Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal.
