# Nachtrag 2026-09-06 — 1.5.161 / 2.1.163 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.161** (Build 180).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.163 alpha** (Build 188).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, Prefs lagen schon — nicht gemergt. Von dort gezogen: flock nicht blocken, Unsure statt Gast, IOHID/AX bleiben Vorschlag.

## Warum es schlecht wirkte (dieser Pass)

1. **Remint hielt Source.** `leftoverHoldRemintApply` kopiert A→C und lässt A. Nur leftoverLastIoU droppte. leftoverHold/Streak/Pending/NameLock/Pair* blieben Zombies — nach UUID-Wechsel erbte der Nachbar den Namen.
2. **leftoverPick Gallery-Floor tot.** Open-Set sah `leftoverScore`, nicht Cosine. Eine Kiste Cosine 0,50–0,61 mit Gap > 0,08 (oder Solo) pinnt. leftoverHoldSmooth zieht Roh 0,70 gegen Hold 0,50 auf ~0,60 — Taufe des Nachbarn.
3. **Blocking flock.** `LOCK_EX` ohne NB auf Helios-Vision-Tick (jeder 8. Frame) und Aegis-Heartbeat. Gegenseite im ftruncate → Capture-Queue steht. Das ist der Ruck bei 8 fps, der wie „schlechte Erkennung“ wirkt.
4. **Reader ohne flock.** Sieht ftruncate-0, fällt auf stale tmp (anderes PID, alter Owner).
5. **tmp-Write Compat.** Zwei Dateien, zwei Writer, Reboot räumt tmp, Caches bleibt — Split-Brain.
6. **gallery.json ein .bak.** Crash während Save = Galerie leer, ein Backup.
7. **Reanchor nur DisplayLink.** Kamera-Tick warpt 8 fps ohne NSEvent-Truth → 125 ms Drift wächst.
8. **Mutex unsichtbar.** Kein Chip — Yield sieht man nicht.
9. **Claim ohne CAS.** Unlocked Read, dann Write. Aegis sah holder=nil während Helios ftruncate oder LOCK_SH|NB fail, schrieb über Helios.
10. **Gallery-Floor auf Smooth.** leftoverHoldSmooth(0,70, Hold 0,50) = 0,57 < Genuine — Roh 0,70 starb. Floor muss leftoverPickPrint (roh) sehen.

## In 1.5.161 / 2.1.163 gelandet

- RemintDrop alle leftover-Maps + DropBins + DropId + freezeAxis. FaceTrack Unpack-Helfer (verdrahten nach StreakBox-Typ).
- leftoverOpenSetGalleryFloor auf **Roh-Cosine** (nicht leftoverHoldSmooth). Session-Genuine, Yaw des Top-Cands. Nacht-Floor −0,02 bleibt.
- flock LOCK_EX|LOCK_NB Write, LOCK_SH|LOCK_NB Read. Busy = Skip, nicht Stall.
- cameraMutexSkipClaim + LockedLine: Busy-Read kein Claim. Unter LOCK_EX neu lesen, gen++. Aegis schreibt nicht über Helios in der TOCTOU-Lücke.
- cameraMutexWriteTmp false. tmp nur noch Read-Legacy.
- gallery.bak rotate 3.
- Mutex-Chip HUD/Toolbar (nur nach erfolgreichem Write).
- pointerReanchor am Kamera-Tick.
- Tests + MARKETING_VERSION 1.5.161 / 2.1.163.

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Observation-order von Vision. Scale-Gate 0,28 zittert bei 8 fps.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref (Auto-Return an/aus, Grace 2–8 s) noch nicht im Panel.

### Aegis

- FaceTrack Unpack sitzt, LibraryStore droppt Maps einzeln — StreakBox/Kalman nicht im Struct.
- Detect-Skip Coast ohne Print: leftover Hold muss IoU-only überleben.
- LiveCapture MainActor plus startRunning auf outputQueue.
- gallery.json ohne WAL-Log (rotate 3 mildert, ersetzt kein Journal).
- 24 Maps bleiben im RAM; Pack/Unpack nur 8 Felder.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild der Maschine.
`bugfix` 1.5.8 / 2.1.15 nicht mergen. Von dort bereits auf main: Dead-Man/Fling/Wischen (1.5.127), destEdgePad (1.5.149).
Dieser Pass aus bugfix: flock nicht blocken (Heartbeat), Unsure statt Gast. IOHID/AX/Per-App-Gain/JSONL bleiben Vorschlag.

Pass 1: Mutex + Assign + Detect-Skip-Print — 1.5.152 / 2.1.160.
Pass 2: Caches/flock + Yield-Reconfigure + Munkres/4-opt + FaceTrack — 1.5.158 / 2.1.161.
Pass 3: Skip-Vision, RemintDrop (nur IoU), Yield-Grace, Open-Set, USB-Watchdog — 1.5.160 / 2.1.162.
Pass 4: RemintDrop alle Maps, Gallery-Floor Roh, flock NB, CAS LockedLine, tmp-Write tot, bak 3, Reanchor Kamera-Tick, freezeAxis Drop — 1.5.161 / 2.1.163.

## Erweiterungen (zusätzlich, neu oben)

1. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC.
2. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt. Two-Phase INTENT → Yield → CONFIRM.
3. **LibraryStore → ein FaceTrack-Dict** inkl. StreakBox/Kalman/Pair. Eine Remint-Funktion.
4. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
5. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
6. **Prefs je camera uniqueID** (Orient, Format, Pad).
7. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
8. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
9. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio) + OSLog.
10. **Center Stage force-off nach Sleep** in beiden Clients.
11. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s.
12. **Echte Maus:** HID-Tap, Warp 0,8 s Pause. Reanchor 4 Hz, RMS > 8 px (Kamera-Tick sitzt, HID fehlt).
13. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
14. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
15. **destEdgePad Pref je Display-UUID.**
16. **IOHID Event-Tap** statt CGEvent-Post (`bugfix`).
17. **AX SetPosition ein Call/Frame** (`bugfix`).
18. **Per-App Gain aus AX bundle id** (`bugfix`).
19. **Gesture-Log JSONL** neben Filmstreifen (`bugfix`).
20. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
21. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
22. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
23. **maximumHandCount 2 + Joint-Group** statt Observation-first.
24. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
25. **Tests splitten** (GestureTests / MatchMathTests).
26. **Yield Pref:** Auto-Return an/aus, Grace 2–8 s im Panel.
27. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
28. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
29. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
30. **Helios Kill-Switch Datei** neben Mutex (Aegis liest, mutet Baptize solange Faust-Lock).
31. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
32. **Overlay Metal instanced bones** — SwiftUI ForEach 21 Joints × 2 Hände bei 90 Hz tot.
33. **Aegis leftover Coast-Print:** Detect-Skip Tick speichert letzten Voll-Print, Hold überlebt IoU-only.
34. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
35. **Helios palmScale histogram prior** — Gitarre 0,29 vs Hand 0,14 als Bayes, nicht hartes Gate 0,28.
36. **Mutex gen++ compare-and-swap** — Claim ohne Read-Modify-Write-Loch zwischen Parse und Write.
37. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
38. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei (Linux-CI mit Fixture, ohne AVCapture).
39. **Mutex fsync vor LOCK_UN.** Crash mitten im Write = leere Caches-Datei; rotate mildert gallery.json, nicht den Lock.
40. **leftoverPick Argmax auf Roh-Cosine**, leftoverScore nur Tie-Break — Score-Inflation darf nicht den Nachbarn wählen.
41. **Helios Claim jeden Frame** statt % 8 — 8 fps × 8 = 1 s tot gegen Heartbeat-Stale 12, aber Aegis 2 s Beat sieht Lücken.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`.
Nächster Code-Schritt: CameraBroker oder FaceTrack inkl. StreakBox oder Overlay-Metal.
