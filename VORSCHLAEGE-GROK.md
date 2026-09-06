# Nachtrag 2026-09-06 — Review (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.149** (Build 168).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.158 alpha** (Build 183).
Nur `main`. Agent-Regel: keine Nebenbranches.

Dieser Text ist Diagnose + Erweiterung. Kein Versionsbump ohne Xcode-Build.

## Warum es schlecht wirkt

Beide Apps sind ein Vision-Tick plus ein Haufen RAM-Maps. Jeder Release klebt ein Veto auf denselben Pfad.

1. Continuity ist 8 fps. Ein Tick Dropout = 125 ms. Zwei Ticks = sichtbarer Sprung.
2. Vision rankt Flaeche. Gitarre / Rumpf fuellen Slots vor Hand bzw. Gesicht.
3. Aegis-Identitaet ist kein Objekt: 25 leftover-Maps, Schema 15. 2.1.158 hat einen Remint-Plan, die Maps bleiben.
4. Zwei Prozesse, eine Kamera. Datei-Lock ohne flock und ohne PID-Leben. Nach 12 s ohne Heartbeat greift Aegis Continuity waehrend Helios noch haelt.
5. Overlay und Detect haben verschiedene Uhren.

## Restloecher

### Helios CameraSession

- claimCameraMutex nur in configureAndRun sichtbar. geometryTick existiert. lastFormatBand wird gesetzt — Property muss existieren, sonst Compile-Bruch.
- applyCaptureGeometry periodisch: ANALYSE sagt alle 32 Frames, Startpfad macht es nur beim Configure.
- Mutex ohne kill(pid,0): Crash laesst Lock 12 s liegen.
- Frame-Pump XPC fehlt. Zwei DisplayLinks sitzen seit 1.5.149.

### Aegis

- HungarianX n<=8 plus FillX bleibt Greedy im Crowd.
- cameraMutexParse nutzt Int(now) — Sekundenraster.
- Yield nur Helios nach Aegis. Helios-Start waehrend Aegis laeuft: Lock wird ueberschrieben, Session-Konflikt 1-2 s.
- LiveCapture MainActor plus startRunning auf outputQueue plus Detect-Jank.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild.
bugfix-Branch nicht mergen (1.5.8 / 2.1.15).

Pass 1: Architektur + Mutex + Map-Stapel — Findings ja.
Pass 2: Version README/VERSION/ANALYSE konsistent 1.5.149 / 2.1.158.
Pass 3: Vorschlaege getrennt von Fixes.

## Erweiterungen (zusaetzlich zur bestehenden Liste)

1. CameraBroker-XPC: ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC.
2. PID-Liveness im Mutex (Feld 2 existiert).
3. Heartbeat aus dem Frame-Callback, nicht nur Main-Timer / Configure.
4. FaceTrack / HandTrack als ein Struct. Eine Remint-Funktion.
5. Detect 8-12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.
6. Ein Cost: a*IoU + b*print + c*hamming + d*yaw.
7. Open-Set Energy + Softmax. Unter Gap = Unsure, nicht Gast.
8. Enrollment-HUD: 3 Yaw-Slots + Blink bevor Taufe.
9. gallery.json WAL + bak rotate 3.
10. Prefs je camera uniqueID.
11. Hand Shape-Prior statt neuer Thresholds.
12. Gemeinsames CameraMath-Package (Mutex/Format/Rotation leben doppelt).
13. Lokaler Telemetry-Ring 30 s (fps, ranks, remint, mutex).
14. Center Stage force-off nach Sleep in beiden Clients.
15. Szenario-Fixtures: Gitarre+Hand 8 fps, Twin Restart, Helios haelt Lock.

Bewusst nicht: Versionsbump, Blind-Patch MatchMath/CoordMath, Merge bugfix.
Naechster Code-Schritt: CameraBroker oder FaceTrack-Struct.
