# Nachtrag 2026-09-06 — Review 1.5.158 / 2.1.161 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.158** (Build 177).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.161 alpha** (Build 186).
Nur `main`. Agent-Regel: keine Nebenbranches.

Dieser Text ist Diagnose + Erweiterung. Versionsbump nur mit gelandeten Mutex-/Assign-/Yield-Fixes.

## Warum es schlecht wirkte (bis 1.5.157 / 2.1.160)

Beide Apps sind ein Vision-Tick plus ein Haufen RAM-Maps. Jeder Release klebte ein Veto auf denselben Pfad.

1. Continuity ist 8 fps. Ein Tick Dropout = 125 ms. Zwei Ticks = sichtbarer Sprung.
2. Zwei Prozesse, eine Kamera. Datei-Lock in `/tmp` ohne flock. Atomic-Rename ist kein Exclusive.
3. Aegis-Yield stoppte den Heartbeat, nicht die Session. Continuity blieb belegt.
4. YieldsNow klebte. Einmal gewichen = für immer.
5. Hungarian n>8 = Greedy+2-opt. 4-Zyklus bleibt auf der Diagonale.
6. 25 leftover-Maps. Remint-Plan sitzt, Identität nicht.
7. Overlay SwiftUI am Kamera-Takt. 8 fps Skelett, 90 Hz Cursor.

## In 1.5.158 / 2.1.161 gelandet

- Caches-Lock `HeliosAegis/helios.aegis.camera.lock`, Dual-Read tmp, Dual-Write, flock LOCK_EX.
- YieldsNow löst wenn Holder Aegis. YieldReconfigure legt Aegis auf Built-in um.
- leftoverAssignHungarianXKuhn (Munkres) + 3-opt + 4-opt. 4-Zyklus tot.
- FaceTrack Pack/Remint (Maps bleiben).
- README Helios auf dem Binary (war 1.5.152).

## Restlöcher

### Helios CameraSession

- Frame-Pump XPC fehlt. Zwei DisplayLinks sitzen seit 1.5.149.
- Overlay bleibt SwiftUI, nicht Metal 90 Hz.
- tmp-Write noch Compat — streichen nach einem Release.
- Continuity-Watchdog (fps < 10 → Format/Restart) fehlt.

### Aegis

- FaceTrack nicht in LibraryStore verdrahtet. 25 Maps.
- Yield-Grace / Auto-Return Continuity fehlt.
- Detect-Skip spart Print, nicht VNDetect.
- LiveCapture MainActor plus startRunning auf outputQueue plus Detect-Jank.
- Open-Set Energy fehlt. Unter Gap = Gast statt Unsure (Unsure-Chip sitzt, Floor nicht).

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild.
bugfix-Branch nicht mergen (1.5.8 / 2.1.15). Fehlende Prefs von dort liegen seit 1.5.127 / 1.5.149 auf main.

Pass 1: Mutex + Assign + Detect-Skip — 1.5.152 / 2.1.160.
Pass 2: Caches/flock + Yield-Reconfigure + Munkres/4-opt + FaceTrack — 1.5.158 / 2.1.161.
Pass 3: Vorschläge getrennt von Fixes.

## Erweiterungen (zusätzlich)

1. CameraBroker-XPC: ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC.
2. Lock-Zeile als Mini-IPC (Palm-Rect / Face-Rect) bis der Broker sitzt.
3. Two-Phase Claim INTENT → Yield → CONFIRM.
4. tmp-Write streichen, nur Caches.
5. LibraryStore → ein FaceTrack-Dict. Eine Remint-Funktion verdrahtet.
6. Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.
7. Detect-Skip auch VNDetect wenn IoU+Yaw sitzen.
8. Open-Set Energy + Softmax. Unter Gap = Unsure, nicht Gast.
9. Enrollment-HUD: 3 Yaw-Slots + Blink bevor Taufe.
10. gallery.json WAL + bak rotate 3.
11. Prefs je camera uniqueID.
12. Hand Shape-Prior / Body-Pose statt neuer Thresholds.
13. Gemeinsames CameraMath-Package (Mutex/Format/Rotation leben doppelt).
14. Lokaler Telemetry-Ring 30 s (fps, ranks, remint, mutex) + OSLog.
15. Center Stage force-off nach Sleep in beiden Clients.
16. Szenario-Fixtures: Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live auf Built-in.
17. Echte Maus: HID-Tap, Warp 0,8 s Pause.
18. Palm-Occlusion S2∩S1. Hand-over-Face Mute über die Lock-Zeile.
19. Speaker-Diarization als Aegis-Cue.
20. Mutex-Chip im HUD.
21. Continuity-Watchdog fps < 10 für 2 s.
22. Yield-Grace 4 s, Pref Auto-Return Continuity.
23. NSEvent.mouseLocation 4 Hz Reanchor.
24. destEdgePad Pref je Display-UUID.

Bewusst nicht: Blind-Patch MatchMath/CoordMath, Merge bugfix.
Nächster Code-Schritt: CameraBroker oder LibraryStore→FaceTrack oder Overlay-Metal.
