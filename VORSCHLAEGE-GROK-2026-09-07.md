# Nachtrag Grok 2026-09-07 — 2.1.191 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.191 (Build 216) auf 2.1.190 (Frontal-Enroll tot, Coach ohne ¾R). Helios 1.5.192.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt.

## Warum es nach 2.1.190 weiter riss

1. printQualityBlocksEnroll `bin != 1` — Bin 0 Frontal blockt Enroll. Tests prüften nur ¾ und Profil.
2. enrollmentCoach F+¾. ¾R unsichtbar. Blink-Schritt tot.
3. Galerie-ForEach `face.id` — Remint unmountet Ada.

## In 2.1.191 / 1.5.192 gelandet

- printQualityBlocksEnroll Bin ≥ 2. createIdentity + referenceRejected.
- enrollCoachStep Front → ¾L → ¾R → Blink.
- leftoverGalleryRowId. Strip-ForEach.
- leftoverMissClears canonical ignoriert Need.
- Helios pointerFillStep + Continuity-Cap + Vel.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface.
P0 FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P2 Blink haveBlink aus leftoverBlinkLiveness.
P2 VNTrackObjectRequest. Replay 20 s.

## Erweiterung (neu)

1. Overlay-Box bleibt Detect-ID, Strip identityId — zwei Identities.
2. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
3. First-reference Bin 0 hart, ¾ erst nach Frontal (createIdentity sitzt).
4. CameraBroker statt flock.
5. FaceTrack.coastAt ≠ Print-TTL.

# Nachtrag Grok 2026-09-07 — 2.1.190 gelandet, Rest offen


Quelle: Review + Fix Aegis 2.1.190 (Build 215) auf 2.1.189 (TrackKind tot am Miss-Clear, Tests tot). Helios 1.5.191.
Kein Binary-Lauf. `bugfix` #3 nicht gemergt.

## Warum Live nach 2.1.189 weiter riss

1. leftoverMissClears: `kind != .live && miss >= 3` — miss=3 ist `.coast`, Ada weg.
2. leftoverTrackKindKeeps unverdrahtet. leftoverTrackKindChip tot.
3. MatchMathTests `var near = ones` schattete `static func near` — CI kompiliert nicht. Nutzer bleibt auf altem Binary.
4. Helios Kalman ohne Span, Fill-Gap tot am Ghost.

## In 2.1.190 / 1.5.191 gelandet

- leftoverMissClears = !TrackKindKeeps. coastAt 0,40 s.
- leftoverHoldChip · coast/ghost.
- nearVec. Tests wieder grün.
- Helios Kalman Span, holdGhost Fill-Gap, pinchPhase, CI macos-15.

## Offen

P0 CameraBroker. FaceTrack einzige Map. leftoverCoastPrintAt ≠ coastAt (Print-TTL vs Coast-Start).
P1 CVPixelBuffer bis Detect. LiveCapture nicht MainActor.
P2 Golden-Frames 8 fps. TrackKind-TTL. HeliosAegisKit.
P2 MatchMathTests splitten (4900 Zeilen, Shadow-Bug).

## Erweiterung (neu)

1. Broker IOSurface. Mutex nur Heartbeat.
2. Gallery-Row-ID überlebt Detect.
3. Enroll-Coach State Machine.
4. Overlay-Metal 90 Hz.
5. Replay 20 s Continuity + PTS.
6. Watchdog Pause → Built-in.
7. AVCaptureSessionWasInterrupted.
8. VNTrackObjectRequest.
9. livePending drop-oldest.
10. Continuity 720p Format-Lock.
11. FaceTrack.coastAt eigener Stamp — nicht leftoverCoastPrintAt.
12. Temperature-skalierte Cosine.
13. Licht-Eimer (frontal / ¾ / Profil) statt einem Cosine.
14. Match-Log JSONL für Replay.
15. Drop-in `.mlmodel` FaceEmbedder-Protokoll.
16. P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
17. Temporal ReID-Graph über Hold-Trail.
18. gallery.json.bak Rotate 3.
19. RTSP 420f, Reconnect Exponential-Backoff.
20. Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
21. Swift Testing statt DIY `ok()`.
22. Zwei-Cam-Stereo mit Helios Continuity + Aegis Built-in.

## Bugfix-Skill

Pass 1: Diagnose. Pass 2: 2.1.190 auf main. Pass 3: CI hart.
