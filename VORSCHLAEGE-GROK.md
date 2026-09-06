# Nachtrag 2026-09-06 — Review 1.5.160 / 2.1.162 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.160** (Build 179).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.162 alpha** (Build 187).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, fehlende Prefs lagen schon seit 1.5.127/1.5.149 — nicht gemergt.

## Warum es schlecht wirkte

Beide Apps sind ein Vision-Tick plus ein Haufen RAM-Maps. Jeder Release klebte ein Veto auf denselben Pfad. Continuity über Wi-Fi ist **8 fps** — das ist kein Bug, das ist das Transport. Die Patches 1.5.100–1.5.158 behandelten 8 fps wie einen Defekt.

1. Continuity Wi-Fi = 8 fps (125 ms). Ein Tick Dropout = sichtbarer Sprung. USB sollte 24–30 sein; darunter Watchdog, nicht bei Wi-Fi.
2. Zwei Prozesse, eine Kamera. Datei-Lock: Writer flock + ftruncate, Reader ohne flock. Leerer Caches-String fiel auf stale `/tmp`.
3. Aegis-Yield stoppte den Heartbeat. Einmal gewichen = für immer Built-in. YieldsNow bleibt kleben bei holder nil.
4. Detect-Skip setzte nur `skipPrints`. `VNDetectFaceRectangles` + Landmarks + Quality liefen jedes Tick.
5. `leftoverHoldRemintApply` kopiert und hält Source. `leftoverLastIoU.values` inkl. Zombies → Skip nie oder Skip falsch.
6. Overlay `leftoverUnsureChip ?? guestName` → Tick 1 = Gast, nicht „?“.
7. leftoverPick: Softmax max ≥ 0,55 trotz Gap 0,08 (t=16) tauft den Nachbarn.
8. Overlay SwiftUI am Kamera-Takt. 8 fps Skelett, 90 Hz Cursor.
9. FaceTrack-Struct sitzt, LibraryStore hat weiter ~25 Maps. Remint 20×.

## In 1.5.160 / 2.1.162 gelandet

- Detect-Skip Vision + Kalman-Coast (`FaceObservation.coast`, gleiche UUID).
- leftoverDetectSkipLiveIous / RemintDrop auf leftoverLastIoU.
- Yield-Grace 4 s, Auto-Return, Heartbeat bleibt.
- Open-Set Gap/Energy, Overlay Unsure-First.
- Mutex Pick `cachesEmpty` (ftruncate ≠ Legacy-tmp).
- USB-Continuity-Watchdog fps < 10 / 2 s. Wi-Fi 8 fps kein Restart.
- README Helios auf dem Binary (hing bei 1.5.158 trotz 1.5.159).

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks sitzen seit 1.5.149.
- Overlay bleibt SwiftUI, nicht Metal 90 Hz.
- tmp-Write noch Compat — streichen nach diesem Release (beide Apps 1.5.160 / 2.1.162).
- CGWarp ohne NSEvent.mouseLocation-Reanchor. Drift wächst.
- Observation-order von Vision. Scale-Gate 0,28 zittert bei 8 fps.
- GestureTests > 180 kB, CoordMath ~200 kB.

### Aegis

- FaceTrack nicht in LibraryStore verdrahtet. Drop sitzt nur auf leftoverLastIoU. 24 Maps bleiben.
- Detect-Skip Coast ohne Print: leftover Hold muss IoU-only überleben. Tick 0 (voll) bleibt Pflicht.
- LiveCapture MainActor plus startRunning auf outputQueue plus Detect-Jank (Coast mildert, löscht nicht).
- Open-Set in leftoverPick auf `scored` — Gallery-Floor 0,64 kann weiter taufen wenn Gap > 0,08.
- gallery.json ohne WAL.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild der Maschine.
`bugfix` 1.5.8 / 2.1.15 nicht mergen. Von dort bereits auf main: Dead-Man/Fling/Wischen-Prefs (1.5.127), destEdgePad (1.5.149).
Dieser Pass hat aus bugfix **nur Ideen** gezogen: Heartbeat nicht töten, Detector sparen, Unsure statt Gast, IOHID/AX bleiben Vorschlag.

Pass 1: Mutex + Assign + Detect-Skip-Print — 1.5.152 / 2.1.160.
Pass 2: Caches/flock + Yield-Reconfigure + Munkres/4-opt + FaceTrack — 1.5.158 / 2.1.161.
Pass 3: Skip-Vision, RemintDrop, Yield-Grace, Open-Set, USB-Watchdog — 1.5.160 / 2.1.162.
Pass 4: Vorschläge getrennt von Fixes.

## Erweiterungen (zusätzlich, neu oben)

1. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC.
2. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt. Two-Phase INTENT → Yield → CONFIRM.
3. **tmp-Write streichen,** nur Caches + flock LOCK_EX|LOCK_NB (Heartbeat darf nicht blocken).
4. **LibraryStore → ein FaceTrack-Dict.** leftoverHoldRemintDrop für alle 25 Maps, eine Remint-Funktion.
5. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.** Coast-Print aus letztem Voll-Tick.
6. **Open-Set Gallery-Floor:** leftoverPick top < leftoverPrintGenuine (0,62) = Unsure, auch bei Gap > 0,08.
7. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. gallery.json WAL + bak rotate 3.
8. **Prefs je camera uniqueID** (Orient, Format, Pad).
9. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
10. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
11. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio) + OSLog.
12. **Center Stage force-off nach Sleep** in beiden Clients.
13. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s.
14. **Echte Maus:** HID-Tap, Warp 0,8 s Pause. NSEvent.mouseLocation 4 Hz Reanchor, RMS > 8 px.
15. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
16. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
17. **Mutex-Chip im HUD** (`helios|aegis|YIELD`).
18. **destEdgePad Pref je Display-UUID.**
19. **IOHID Event-Tap** statt CGEvent-Post (`bugfix`).
20. **AX SetPosition ein Call/Frame** (`bugfix`).
21. **Per-App Gain aus AX bundle id** (`bugfix`).
22. **Gesture-Log JSONL** neben Filmstreifen (`bugfix`).
23. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
24. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
25. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
26. **maximumHandCount 2 + Joint-Group** statt Observation-first.
27. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
28. **Tests splitten** (GestureTests / MatchMathTests).
29. **flock LOCK_NB** auf Read+Write. Reader sieht nie ftruncate-0.
30. **Yield Pref:** Auto-Return an/aus, Grace 2–8 s im Panel.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`.
Nächster Code-Schritt: CameraBroker oder LibraryStore→FaceTrack (alle Maps Drop) oder Overlay-Metal.
