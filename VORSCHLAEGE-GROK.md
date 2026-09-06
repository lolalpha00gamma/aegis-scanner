# Nachtrag 2026-09-06 — Review 1.5.152 / 2.1.160 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.152** (Build 171).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.160 alpha** (Build 185).
Nur `main`. Agent-Regel: keine Nebenbranches.

Dieser Text ist Diagnose + Erweiterung. Versionsbump nur mit den gelandeten Mutex-/Assign-/Detect-Helfern.

## Warum es schlecht wirkte (bis 1.5.151 / 2.1.159)

Beide Apps sind ein Vision-Tick plus ein Haufen RAM-Maps. Jeder Release klebte ein Veto auf denselben Pfad.

1. Continuity ist 8 fps. Ein Tick Dropout = 125 ms. Zwei Ticks = sichtbarer Sprung.
2. Vision rankt Fläche. Gitarre / Rumpf füllen Slots vor Hand bzw. Gesicht.
3. Aegis-Identität ist kein Objekt: 25 leftover-Maps, Schema 15. Remint-Plan sitzt, die Maps bleiben.
4. Zwei Prozesse, eine Kamera. Datei-Lock ohne flock, ohne PID-Leben, Stamp in ganzen Sekunden. Aegis-Heartbeat überschrieb Helios alle 2 s.
5. Overlay und Detect haben verschiedene Uhren.

## In 1.5.152 / 2.1.160 gelandet

- Mutex-Stamp Millisekunden, PID-Parse, pidLive, ClaimWrites (Helios Vorrang), YieldsNow (Aegis weicht live).
- HungarianX n>8 Cost-Greedy + 2-opt statt FillX.
- Detect-Skip wenn alle Kalman-IoU ≥ 0,92 (skipPrints, Tick 8 voll).

## Restlöcher

### Helios CameraSession

- Frame-Pump XPC fehlt. Zwei DisplayLinks sitzen seit 1.5.149.
- claim prüft kill(pid,0), flock fehlt. /tmp statt ~/Library/Caches.
- Overlay bleibt SwiftUI 8–24 fps, nicht Metal 90 Hz.

### Aegis

- Greedy+2-opt hängt 4-Zyklus. Jonker-Volgenant fehlt.
- Yield stoppt den Heartbeat, startet die Session nicht auf Built-in um (1–2 s Konflikt bis Restart).
- LiveCapture MainActor plus startRunning auf outputQueue plus Detect-Jank.
- 25 leftover-Maps. FaceTrack-Struct fehlt.

## Bugfix-Protokoll

Keine ungetesteten Logic-Patches auf main ohne xcodebuild.
bugfix-Branch nicht mergen (1.5.8 / 2.1.15). Fehlende Prefs von dort liegen seit 1.5.127 / 1.5.149 auf main.

Pass 1: Mutex + Assign + Detect-Skip — gelandet.
Pass 2: Version README/VERSION/ANALYSE 1.5.152 / 2.1.160.
Pass 3: Vorschläge getrennt von Fixes.

## Erweiterungen (zusätzlich)

1. CameraBroker-XPC: ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC.
2. fcntl flock. Lock in ~/Library/Caches.
3. Aegis Yield → Session auf Built-in umlegen, nicht nur Timer stoppen.
4. FaceTrack / HandTrack als ein Struct. Eine Remint-Funktion.
5. Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.
6. Ein Cost: a*IoU + b*print + c*hamming + d*yaw. Jonker-Volgenant.
7. Open-Set Energy + Softmax. Unter Gap = Unsure, nicht Gast.
8. Enrollment-HUD: 3 Yaw-Slots + Blink bevor Taufe.
9. gallery.json WAL + bak rotate 3.
10. Prefs je camera uniqueID.
11. Hand Shape-Prior / Body-Pose statt neuer Thresholds.
12. Gemeinsames CameraMath-Package (Mutex/Format/Rotation leben doppelt).
13. Lokaler Telemetry-Ring 30 s (fps, ranks, remint, mutex) + OSLog.
14. Center Stage force-off nach Sleep in beiden Clients.
15. Szenario-Fixtures: Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live.
16. Echte Maus: HID-Tap, Warp 0,8 s Pause.
17. Palm-Occlusion S2∩S1. Hand-over-Face Mute.
18. Speaker-Diarization als Aegis-Cue.

Bewusst nicht: Blind-Patch MatchMath/CoordMath, Merge bugfix.
Nächster Code-Schritt: CameraBroker oder FaceTrack-Struct oder Aegis-Yield-Reconfigure.
