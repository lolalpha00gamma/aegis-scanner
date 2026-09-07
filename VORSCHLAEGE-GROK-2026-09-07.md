# Nachtrag Grok 2026-09-07 — 2.1.194 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.194 (Build 219) auf 2.1.193 (Twin-Drop). Helios 1.5.195.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.193 weiter riss

1. leftoverOverlayKeepsRow `continue` — zweite Ada/Twin unsichtbar.
2. Helios Silence-Age CACurrent nach Sleep 0.

## In 2.1.194 / 1.5.195 gelandet

- leftoverOverlayRowId Detect-Fallback.
- Helios frameSilenceAge, mean ohne Tips, Pause-Resume.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.

## Erweiterung (neu)

1. leftoverBlinkSeen identity-weit.
2. NSWorkspace DidWake → liveRoiSkipOnce.
3. Overlay Hash der Box wenn Twin+Remint.
4. FrameTap pending ohne CGImage.

## Bugfix-Skill

Pass 1: Twin-Drop, Silence Sleep.
Pass 2: 2.1.194 / 1.5.195 auf main.
Pass 3: Twin Detect-ID. Silence 400 s.

# Nachtrag Grok 2026-09-07 — 2.1.193 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.193 (Build 218) auf 2.1.192 (Overlay Detect-UUID, Live ohne Blink, emitBusy Drop-new, Pause tot). Helios 1.5.194.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.192 weiter riss

1. Overlay-ForEach `face.id`. Remint neue Detect-UUID → SwiftUI unmountet Ada. leftoverGalleryRowId saß nur im Strip.
2. createIdentity ignorierte leftoverBlinkSeen. Live ohne Blink = Person aus dem Nichts.
3. FrameTap emitBusy Drop-new. livePending in LibraryStore nie gefüllt.
4. cameraMutexWatchdogAction pause. LiveCapture rief nie stopRunning. ClaimWrites false (Helios hält) return ohne Pause — flock-Hammer.

## In 2.1.193 / 1.5.194 gelandet

- leftoverGalleryRowId Overlay + leftoverOverlayUniqueRows.
- enrollBlocksWithoutBlink. createIdentity live hart.
- liveEmitPendingWhileBusy. Conversion-Fail wischt Busy nicht.
- Session-Pause 2 s, Interrupted, Pause hält, Resume Claim zuerst.
- Helios obsFillClock Wall schlägt Mutex, WARP skip, Pinch Slot, Tip-Floor 0,20.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface.
P0 FaceTrack einzige Store-Map (20 Dictionaries bleiben).
P1 Overlay-Metal. LiveCapture Detect nicht @MainActor.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu)

1. CameraBroker Shared Memory statt flock/90 Hz.
2. FaceTrack Debug-Dump eine Map JSON.
3. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
4. Print-Diversity: gleicher Pose-Bin Cosine > 0,98 → Skip.
5. Name-Lock nur nach Blink + 3 Frames gleicher ID.
6. Twin-Veto: |Δyaw| < 8° und x-Overlap > 0,45 → ein Exact.
7. Temperature-skalierte Cosine statt hart 0,80.
8. Licht-Eimer (frontal / ¾ / Profil) statt einem Cosine.
9. Match-Log JSONL für Replay.
10. Drop-in `.mlmodel` FaceEmbedder-Protokoll.
11. P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
12. VNTrackObjectRequest neben Rectangles.
13. RTSP 420f, Reconnect Exponential-Backoff.
14. Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
15. Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
16. gallery.json.bak Rotate 3, printRevision je Identity.
17. Temporal ReID-Graph über Hold-Trail.
18. Schema 15 bleibt — leftoverCoastAt ist Runtime.
19. Peak-Hold 3 Frames nach Remint — Box Detect tot, Row identityId sitzt.
20. Fill freeze 250 ms nach Wake (Helios) — Wall-Sprung > 2 s rebase.
21. NSEvent.mouseLocation Ground-Truth 4 Hz (Helios).
22. Swift Testing statt DIY `ok()`.

## Bugfix-Skill

Pass 1: Diagnose — Overlay Detect-UUID, Live ohne Blink, emitBusy Drop-new, Pause nur Write-Fail.
Pass 2: 2.1.193 / 1.5.194 auf main, Call-Sites verdrahtet.
Pass 3: CI muss failen dürfen. Overlay Dedup, Blink-Block, Pause Partner, Fill-Uhr Wall.

# Nachtrag Grok 2026-09-07 — 2.1.192 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.192 (Build 217) auf 2.1.191 (Print-TTL als coastAt, Blink-Default true). Helios 1.5.193.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.191 weiter riss

1. leftoverCoastPrintAt (Print-TTL 2 s, jeder Print frisch) als FaceTrack.coastAt — miss=8 bleibt `.coast` wenn Print < 0,40 s.
2. enrollCoachStep haveBlink Default true. FaceEngine rief ohne haveBlink — Blink-Schritt tot.
3. Strip-Coach ohne leftoverBlinkSeen. Foto vor der Cam = Coach fertig.
4. leftoverCoastAt isEmpty-Fallback über leftoverHoldRemintDrop — FaceTrack-Drop rückgängig.
5. Models.swift auf 116 Zeilen gekürzt — FaceObservation/Identity tot, App kompiliert nicht.

## In 2.1.192 / 1.5.193 gelandet

- leftoverCoastAtStamp. FaceTrack.coastAt ≠ leftoverCoastPrintAt.
- leftoverHoldChip / leftoverMissClears / leftoverClearStreak / Remint-Union.
- leftoverCoastAt = faceMaps.coastAt (kein Drop-Undo).
- haveBlink Default false. leftoverBlinkSeen. Strip + Preview.
- Models.swift vollständig (388 Zeilen).
- Helios obsFillSeesHand !ghost, WarpWriter, FILL ms · Vel, PINCH-Chip.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface.
P0 FaceTrack einzige Store-Map (20 Dictionaries bleiben).
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P1 CameraSession Session-Pause 2 s verdrahten.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu)

1. Overlay-Box bleibt Detect-ID, Strip identityId — zwei Identities.
2. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
3. createIdentity verlangt leftoverBlinkSeen — Foto vor der Cam enrollt nicht.
4. CameraBroker statt flock.
5. Overlay `HOLD · coast 0,3s` — Alter aus leftoverCoastAt.
6. FaceTrack Debug-Dump eine Map JSON — 20 Dictionaries unsichtbar.
7. livePending drop-oldest 1-slot statt emitBusy Drop-new.
8. Print-Diversity: gleicher Pose-Bin Cosine > 0,98 → Skip (kein Burst).
9. Name-Lock nur nach Blink + 3 Frames gleicher ID.
10. Twin-Veto: |Δyaw| < 8° und x-Overlap > 0,45 → ein Exact.
11. Temperature-skalierte Cosine statt hart 0,80.
12. Licht-Eimer (frontal / ¾ / Profil) statt einem Cosine.
13. Match-Log JSONL für Replay.
14. Drop-in `.mlmodel` FaceEmbedder-Protokoll.
15. P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
16. VNTrackObjectRequest neben Rectangles.
17. RTSP 420f, Reconnect Exponential-Backoff.
18. Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
19. Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
20. gallery.json.bak Rotate 3, printRevision je Identity.
21. Temporal ReID-Graph über Hold-Trail.
22. Schema 15 bleibt — leftoverCoastAt ist Runtime.

## Bugfix-Skill

Pass 1: Diagnose — Print-TTL als coastAt, Blink-Default, Remint-Fallback.
Pass 2: 2.1.192 / 1.5.193 auf main, Call-Sites verdrahtet.
Pass 3: CI muss failen dürfen. Coach-fertig braucht haveBlink:true.

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
