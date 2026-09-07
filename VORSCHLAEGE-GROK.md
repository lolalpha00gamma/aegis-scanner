# Nachtrag 2026-09-07 — 1.5.185 / 2.1.184 (kein Merge von `bugfix`)

Aegis `lolalpha00gamma/aegis-scanner` **2.1.184 alpha** (Build 209).
Helios `bpms9cmnxc-debug/Helios` **1.5.185** (Build 204).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.183 Peak IoU-Adopt. NameLock Coast wischt Ada. Peak-Floor hart 0,40. Helios Overlay-ID snappt.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverNameLockHeldCoast vor IoU.** Until-Filter tot-UUID. Matching-Sticky Ghost. Peak-Adopt rettet Overlay-Name, nicht leftoverNameLockKeeps.
2. **Peak-IoU hart 0,40.** 8 fps Twin-Tie, 60 fps zu weich.
3. **Helios overlayLerpHands nur gleiche ID.** S2-Coast-ID ≠ Live-ID.
4. **Zwei Sessions.** Mutex+TERM Pflaster. Ohne CameraBroker zwei Vision, zwei TCC.
5. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 2.1.184 / 1.5.185 gelandet

- **leftoverNameLockHeldIoUAdopt** unique IoU vor Coast. Held + Until auf Live. Twin-Tie tot.
- **leftoverOverlayPeakIoUFloor** 8 fps 0,32 / 60 fps 0,50. Peak und NameLock.
- leftoverNameLockAdoptChip `iou Ada`.
- Helios **overlayLerpAdoptId** unique Palm < 0,18.
- Tests + MARKETING 2.1.184 / 1.5.185 (Build 209 / 204). Schema 15 bleibt.

Pass 25: NameLock IoU-Adopt, Peak-Floor aus fps, Overlay-ID-Adopt — 2.1.184 / 1.5.185.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
2. **Vision tracking-ID als Remint-Seed** vor IoU.
3. **CMSampleBuffer-PTS als Fill-Uhr.** LiveCapture emit ist `Date()`.
4. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.**
5. **Overlay Metal 90 Hz.**
6. **Aegis live outputQueue ≠ MainActor.** FrameTap hop't jedes CGImage auf Main.
7. **Aegis live CVPixelBuffer statt CGImage-Hop.**
8. **Print-Bank nur auf leftoverNameLockHeld Live-UUID** nach IoU-Adopt.
9. **Face-Print Quality** sharpness×(1-|yaw|/90) vor leftoverHold-Write.
10. **NameLock-Adopt HUD** `iou Ada` verdrahten.
11. **leftoverNameLockUntil Restore nach IoU-Adopt** in gallery.json.
12. **Adaptive IoU-Floor aus Box-Fläche** nicht nur fps — nah = strenger.
13. **VNTrackObjectRequest** statt Remint.
14. **Temperature-skalierte Cosine** statt hart 0,80.
15. **gallery.json.bak Rotate 3** schon WAL — printRevision je Identity.
16. **P-Slot Maske/Schal**, Brille-Slot als Twin-Veto.
17. **Temporal ReID-Graph** über Hold-Trail.
18. **RTSP 420f**, Reconnect Exponential-Backoff.
19. **Watch-Folder PhotoKit**, Export `.aegis` verschlüsselt.
20. **Negativ-Galerie Props.**
21. **Print-Bank PCA-Whitening.**
22. **IOHID Event-Tap** (`bugfix`) als opt-in Pref.
23. **Tests splitten** (MatchMathTests > 200 kB).
24. **Swift Testing** statt DIY `ok()`.
25. **CI `swiftc` Tests vor DMG hart.**
26. **Shared Peak via Mutex-Datei** Helios HUD liest Ada.
27. **Speaker-Diarization.**
28. **Face-Print ONNX sidecar.**
29. **Gallery-on-disk mmap.**
30. **Lock Schema v2.**
31. **Doorbell-Cue.**
32. **Center Stage force-off nach Sleep.**
33. **nv12 IOSurface zero-copy** sobald CameraBroker sitzt.
34. **App-Group `group.helios.aegis`.**
35. **POSIX-Semaphore + INTENT → Yield → CONFIRM.**

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder Aegis outputQueue ≠ MainActor oder PTS-Wall-Anchor.

# Nachtrag 2026-09-07 — 1.5.182 / 2.1.183 (kein Merge von `bugfix`)

Aegis `lolalpha00gamma/aegis-scanner` **2.1.183 alpha** (Build 208).
Helios `bpms9cmnxc-debug/Helios` **1.5.182** (Build 201).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.181 Ghost-Knochen / Kalman-P / Peak-Assign. Opacity sprang. HUD S1-only. Remint-Map leer → Peak tot.

## Warum es schlecht wirkte (dieser Pass)

1. **isGhost diskret.** overlayLerpHands `var h = to`. Alpha 1→0,50 Tick 0. Knochen Bezier, Opacity nicht.
2. **HUD Actor-Slot.** S2-Coast nur Wrist-Label. Status ohne `S2 · ghost`.
3. **Aegis Remint-Map leer.** leftoverHoldRemintDrop lässt Peak auf tot-UUID. Advance wischt. Overlay „?“ 1–3 Frames.
4. **PeakRemain nicht in remintKeys.**
5. **Zwei Sessions.** Mutex+TERM Pflaster. Ohne CameraBroker zwei Vision, zwei TCC.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.182 / 2.1.183 gelandet

- **overlayGhostBlend / overlayLerpGhostBlend.** TrackedHand.ghostBlend. Canvas Opacity über dt.
- **overlayGhostSlotChip** HUD `S2 · ghost` / `S1+S2 · ghost`.
- **leftoverOverlayPeakIoUAdopt** unique IoU ≥ 0,40. leftoverOverlayPeakStoredBoxes Streak vor Kalman.
- **leftoverOverlayPeakRemain** in remintKeys.
- Tests + MARKETING 1.5.182 / 2.1.183 (Build 201 / 208). Schema 15 bleibt.

Pass 24: Ghost-Opacity-Lerp, S2 Ghost-Chip, Peak IoU-Adopt — 1.5.182 / 2.1.183.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
2. **leftoverNameLockHeld IoU-Adopt** analog Peak. Matching-Sticky sitzt sonst auf tot-UUID.
3. **Peak-IoU-Floor aus fps** — 8 fps 0,32, 60 fps 0,50. Continuity sonst Twin-Tie.
4. **Vision tracking-ID als Remint-Seed** vor IoU. VNDetectFaceRectangles tracking-ID.
5. **CMSampleBuffer-PTS als Fill-Uhr.** LiveCapture emit ist `Date()`, fpsStamp tot.
6. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.**
7. **Overlay Metal 90 Hz.** SwiftUI Canvas Ghosts jetzt sichtbar, ForEach 21×2 weiter tot.
8. **Eine Homographie je Display-UUID.**
9. **POSIX-Semaphore + INTENT → Yield → CONFIRM.**
10. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
11. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto (Ghost-Blend, Peak-IoU).
12. **Latency-HUD Tick→AX.**
13. **App-Group `group.helios.aegis`.**
14. **IOHID Event-Tap** (`bugfix` 1.5.8) als opt-in Pref, nicht Merge des 1.5.8-Trees.
15. **AX SetPosition ein Call/Frame** (`bugfix`).
16. **Per-App Gain aus AX bundle id** (`bugfix`).
17. **Gesture-Log JSONL** (`bugfix`).
18. **Enrollment-HUD 3-Slot im Overlay.**
19. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
20. **Watch-IMU Pinch-Confirm.**
21. **Vision Hand-Mesh** (macOS 26).
22. **Aegis-Yaw als Helios Click-Lock.**
23. **VNDetectHumanBodyPose** als Prop-Veto.
24. **Gemeinsames CameraMath-Package.**
25. **Telemetry-Ring 30 s + OSLog.**
26. **Center Stage force-off nach Sleep.**
27. **Continuity USB-Hub Watchdog + AVCaptureSession interruption.**
28. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
29. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
30. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
31. **VNTrackObjectRequest** statt Remint.
32. **Aegis live outputQueue ≠ MainActor.** FrameTap hop't jedes CGImage auf Main.
33. **Kalman-Zeiger 2D** echter P/Q/R.
34. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
35. **Negativ-Galerie Props.**
36. **Print-Bank PCA-Whitening.**
37. **Cursor-Magnetismus** 8 px an AX-Hit.
38. **Dwell-Klick** optional neben Pinzette.
39. **Doorbell-Cue.**
40. **Clamshell: Vision pausieren.**
41. **Jerk Dead-Man.**
42. **Lock Schema v2.**
43. **Vision Pro Sidecar.**
44. **CI `swiftc` Tests vor DMG hart** (heute continue-on-error).
45. **Helios Kill-Switch Datei** neben Mutex.
46. **leftoverOverlayPeakRemain persistieren.**
47. **Aegis live CVPixelBuffer statt CGImage-Hop.**
48. **Swift Testing** statt DIY `ok()`.
49. **nv12 IOSurface zero-copy** sobald CameraBroker sitzt.
50. **overlayLerpHands ID-mismatch** analog Peak — S2 Coast-ID vs Live-ID.
51. **ghostBlend auf OverlayController-Cursor.**
52. **leftoverStreakBox 1-Tick Lag** — Peak-Stored Kalman-only Fallback schon, Streak-Write nach Matching.
53. **Shared Peak via Mutex-Datei** Helios HUD liest Ada.
54. **Bone-velocity clamp Overlay** nach Bezier — Tips überschwingen sonst.
55. **Speaker-Diarization.**
56. **Face-Print ONNX sidecar.**
57. **Gallery-on-disk mmap.**
58. **Hover-Preview ohne Click.**
59. **kAXFocusedUIElementChanged** statt FocusTracker-Poll.
60. **Peak-Adopt HUD-Chip** `iou Ada` analog StoreChip.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: leftoverNameLockHeld IoU-Adopt oder CameraBroker-XPC oder Aegis outputQueue ≠ MainActor oder PTS-Wall-Anchor.

# Nachtrag 2026-09-07 — 1.5.181 / 2.1.182 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.181** (Build 200).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.182 alpha** (Build 207).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.181 Overlay-Peak. leftoverMirrorPending ohne PeakHeld. Helios Canvas fraß Ghosts.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverMirrorPending** remintete PeakHeld nicht. Assign-Live → Overlay „?“.
2. **Helios TrackingOverlay `where !isGhost`.** S2-Coast unsichtbar.
3. **Kalman-P = 0 auf Fill-Gap.**
4. **Zwei Sessions.** Mutex+TERM ist Pflaster.
5. Von `bugfix` bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.181 / 2.1.182 gelandet

- **leftoverAssignAtomic PeakHeld/Remain** in leftoverMirrorPending.
- Helios **overlayDrawsGhost**, pointerKalmanResetsPOnGap false.
- Tests + MARKETING 1.5.181 / 2.1.182 (Build 200 / 207). Schema 15 bleibt.

Pass 23: Peak-Assign, Ghost-Knochen, Kalman-P.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide.
2. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.**
3. **Aegis live outputQueue ≠ MainActor.** FrameTap hop't jedes CGImage auf Main.
4. **Overlay Metal 90 Hz.**
5. **CMSampleBuffer-PTS als Fill-Uhr.**
6. **Eine Homographie je Display-UUID.**
7. **POSIX-Semaphore + INTENT → Yield → CONFIRM.**
8. **Palm-Print Sticky-ID.**
9. **Overlay-Why Inspector.**
10. **Latency-HUD Tick→AX.**
11. **App-Group `group.helios.aegis`.**
12. **IOHID Event-Tap** (`bugfix` 1.5.8) als opt-in Pref.
13. **AX SetPosition ein Call/Frame** (`bugfix`).
14. **Per-App Gain aus AX bundle id** (`bugfix`).
15. **Gesture-Log JSONL** (`bugfix`).
16. **Enrollment-HUD 3-Slot im Overlay.**
17. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
18. **Watch-IMU Pinch-Confirm.**
19. **Vision Hand-Mesh** (macOS 26).
20. **Aegis-Yaw als Helios Click-Lock.**
21. **VNDetectHumanBodyPose** als Prop-Veto.
22. **Gemeinsames CameraMath-Package.**
23. **Telemetry-Ring 30 s + OSLog.**
24. **Center Stage force-off nach Sleep.**
25. **Continuity USB-Hub Watchdog.**
26. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
27. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
28. **Tests splitten.**
29. **VNTrackObjectRequest** statt Remint.
30. **Kalman-Zeiger 2D** echter P/Q/R.
31. **Guitar-Schwelle aus Sitzabstand.**
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG hart.**
42. **Helios Kill-Switch Datei.**
43. **leftoverOverlayPeakRemain persistieren.**
44. **Aegis live CVPixelBuffer statt CGImage-Hop.**
45. **Swift Testing** statt DIY `ok()`.
46. **nv12 IOSurface zero-copy.**
47. **Speaker-Diarization.**
48. **Face-Print ONNX sidecar.**
49. **Gallery-on-disk mmap.**
50. **Hover-Preview ohne Click.**
51. **overlayLerpHands Ghost-Opacity lerp.**
52. **S2 Ghost-Chip im HUD-Status.**

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass.

Nächster Code-Schritt: CameraBroker-XPC oder FaceTrack-Store oder Aegis outputQueue ≠ MainActor.

# Nachtrag 2026-09-07 — 1.5.180 / 2.1.181 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.180** (Build 199).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.181 alpha** (Build 206).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.179 Overlay-Lerp an, Fill-Uhr Ghost, Reanchor-Split. Hub-Doppelframe snappt Lerp. Floor 0,05 freeze. Reanchor hart 8 px. Aegis Overlay „?“ 1–3 Frames nach Remint-UUID.

## Warum es schlecht wirkte (dieser Pass)

1. **overlayLerpShould true, Hitch tot.** Continuity-Hub schiebt 8–20 ms Doppelframe. dt 0,010 < 0,045 → Lerp-Tabellen leer, Skelett snappt auf 8 fps.
2. **overlayLerpDt Floor 0,05.** 8 fps 0,125. t = elapsed/0,05 = 1 nach 50 ms, Freeze 75 ms bis zum nächsten Vision-Tick.
3. **pointerReanchor hart 8 px.** 60 fps Built-in: 5 px CGWarp-Drift bleibt. Studio-Display snappt. 8 fps braucht 8 px, 60 fps 3 px.
4. **Aegis leftoverOverlayGuestOf nach Remint.** Hist keep 1, Need 3. Sticky sitzt auf alter UUID. 1–3 Frames „?“ trotz Ada.
5. **Zwei Sessions.** Mutex+TERM ist Pflaster. Ohne CameraBroker zwei Vision, zwei TCC.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.180 / 2.1.181 gelandet

- **pointerReanchorRms(dt:)** 8 fps → 8 px, 60 fps → 3 px. Kamera-Tick. HUD `REAN 3`.
- **overlayLerpDtOf** ohne Floor 0,05.
- **overlayLerpHitchKeeps** Hub-Doppelframe, Cap 2. AppState hält From/To. HUD `LERP hitch`.
- **leftoverOverlayPeakGuest / PeakName / PeakAdvance** 3 Frames über Remint-UUID. Display dekrementiert nicht.
- Tests + MARKETING 1.5.180 / 2.1.181 (Build 199 / 206). Schema 15 bleibt.

Pass 22: Lerp-Hitch, Reanchor-RMS, Overlay-Peak — 1.5.180 / 2.1.181.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
2. **CMSampleBuffer-PTS als Fill-Uhr.** lastFillSeen ist Wandzeit. Continuity-Hub-Sleep vs PTS-Sprung.
3. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.** Matching bleibt Schatten-Maps.
4. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Lerp 8 fps glättet Knochen, nicht das HUD.
5. **Eine Homographie je Display-UUID.**
6. **POSIX-Semaphore + INTENT → Yield → CONFIRM.** flock überlebt Sleep/Hub schlecht.
7. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
8. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto.
9. **Latency-HUD Tick→AX.**
10. **App-Group `group.helios.aegis`.**
11. **IOHID Event-Tap** (`bugfix` 1.5.8).
12. **AX SetPosition ein Call/Frame** (`bugfix`).
13. **Per-App Gain aus AX bundle id** (`bugfix`).
14. **Gesture-Log JSONL** (`bugfix`).
15. **Enrollment-HUD 3-Slot im Overlay.**
16. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
17. **Watch-IMU Pinch-Confirm.**
18. **Vision Hand-Mesh** (macOS 26).
19. **Aegis-Yaw als Helios Click-Lock.**
20. **VNDetectHumanBodyPose** als Prop-Veto.
21. **Gemeinsames CameraMath-Package.**
22. **Telemetry-Ring 30 s + OSLog.**
23. **Center Stage force-off nach Sleep.**
24. **Continuity USB-Hub Watchdog + AVCaptureSession interruption.**
25. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
26. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
27. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
28. **VNTrackObjectRequest** statt Remint.
29. **Aegis live outputQueue ≠ MainActor.**
30. **Kalman-Zeiger 2D** constant-velocity.
31. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional neben Pinzette.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG.**
42. **Helios Kill-Switch Datei** neben Mutex.
43. **Continuity double-frame drop** vor Vision (AVCapture coalesce < 45 ms).
44. **Overlay Knochen-Längen Constraint** nach Bezier — Tips überschwingen sonst.
45. **leftoverOverlayPeak IoU-Adopt** wenn Remint-Map fehlt.
46. **DisplayLink rebase auf PTS** nach Hub-Sleep.
47. **Swift Testing** statt DIY `ok()`.
48. **nv12 IOSurface zero-copy** sobald CameraBroker sitzt.
49. **Pinch-Hysterese aus palmScale**, nicht px.
50. **Face-Print Cosine-EMA** statt Majority-3.
51. **Mutex kevent EVFILT_VNODE + fcntl** statt flock-only.
52. **Helios Warp nur auf Display-UUID** unter dem Cursor.
53. **VNDetectFaceRectangles tracking-ID** statt Eigen-Remint.
54. **Camera interruption-Handler** + Session-Restart-Token.
55. **Overlay-Name Peak über Empty-Coast** (Hold ohne UUID).
56. **One-Euro minCutoff aus MAD**, nicht nur fps.
57. **Helios CGEventSource HID-Post** (`bugfix` IOHID Vorstufe).
58. **Aegis liveNameHist Ring nach Peak**, nicht vor.
59. **Bone-velocity clamp Overlay** (Bezier überschwingt Tips).
60. **Shared flock INTENT-byte** in Lockfile Schema v2.
61. **S2 Pinch-Mute aus Yaw** (Aegis Blick weg = Helios kein Klick).
62. **Fill-Gap Predict nur wenn PTS monoton.**
63. **Overlay-Ghost Peak an Hitch koppeln** — Hub-Frame kein Ghost-Reset.
64. **Print-Bank k-NN 3** statt 1-NN Burst.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

# Nachtrag 2026-09-07 — 1.5.179 / 2.1.180 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.179** (Build 198).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.180 alpha** (Build 205).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.178 Fill-Gap Rebase/MAD. OverlayLerp false. Fill lastHandSeen ohne Ghost. Reanchor am displayTick. Aegis StoreName sitzt, Held nach TTL tot.

## Warum es schlecht wirkte (dieser Pass)

1. **overlayLerpShould = false.** Continuity 8 fps Skelett-Ruck. overlayLerpT clamp 1 macht Lerp sicher.
2. **Fill-Gap lastHandSeen.** Ghost zählt nicht für Dead-Man (richtig) und nicht für Fill (falsch). Coast 280 ms, Fill tot.
3. **pointerReanchor am displayTick.** 90 Hz Fill schreibt Warp. NSEvent > 8 px zieht den Zeiger zurück. Kamera-Tick (1.5.161) bleibt Ground-Truth.
4. **Aegis leftoverNameLockHeldSurvive emptyKeeps:false.** TTL wischt Held. StoreName braucht poseAt. Remint Hist keep 1, Need 3 → Overlay „?“.
5. **Zwei Sessions.** Mutex+TERM ist Pflaster. Ohne CameraBroker zwei Vision, zwei TCC.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.179 / 2.1.180 gelandet

- **overlayLerpShould** 0,045…0,20. AppState lerpPublishedHands 8 fps intra.
- **lastFillSeen / obsFillSeesHand(ghost:true).** Dead-Man weiter !ghost.
- **pointerReanchorAppliesFill() false** Fill-Pfad + displayTick. Kamera-Tick reanchort.
- **leftoverOverlayGuestOf** sticky Held, sonst Hist-Tail. leftoverOverlayStickyName „Ada?“.
- **leftoverNameLockHeldCoast** live/ghost nach TTL. Matching bleibt leftoverNameLockKeeps(Until).
- Tests + MARKETING 1.5.179 / 2.1.180 (Build 198 / 205). Schema 15 bleibt.

Pass 21: Overlay-Lerp, Fill-Uhr Ghost, Reanchor-Split, Overlay-Sticky — 1.5.179 / 2.1.180.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
2. **CMSampleBuffer-PTS als Fill-Uhr.** lastFillSeen ist Wandzeit. Continuity-Hub-Sleep vs PTS-Sprung.
3. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.** Matching bleibt Schatten-Maps.
4. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Lerp 8 fps glättet Knochen, nicht das HUD.
5. **Eine Homographie je Display-UUID.**
6. **POSIX-Semaphore + INTENT → Yield → CONFIRM.** flock überlebt Sleep/Hub schlecht.
7. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
8. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto.
9. **Latency-HUD Tick→AX.**
10. **App-Group `group.helios.aegis`.**
11. **IOHID Event-Tap** (`bugfix` 1.5.8).
12. **AX SetPosition ein Call/Frame** (`bugfix`).
13. **Per-App Gain aus AX bundle id** (`bugfix`).
14. **Gesture-Log JSONL** (`bugfix`).
15. **Enrollment-HUD 3-Slot im Overlay.**
16. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
17. **Watch-IMU Pinch-Confirm.**
18. **Vision Hand-Mesh** (macOS 26).
19. **Aegis-Yaw als Helios Click-Lock.**
20. **VNDetectHumanBodyPose** als Prop-Veto.
21. **Gemeinsames CameraMath-Package.**
22. **Telemetry-Ring 30 s + OSLog.**
23. **Center Stage force-off nach Sleep.**
24. **Continuity USB-Hub Watchdog + AVCaptureSession interruption.**
25. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
26. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
27. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
28. **VNTrackObjectRequest** statt Remint.
29. **Aegis live outputQueue ≠ MainActor.**
30. **Kalman-Zeiger 2D** constant-velocity.
31. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional neben Pinzette.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG.**
42. **Helios Kill-Switch Datei** neben Mutex.
43. **pointerReanchor RMS aus fps** — 8 px bei 8 fps, 3 px bei 60.
44. **overlayLerpDt = rawFrameDt** ohne Floor 0,05.
45. **Overlay-Name Peak-Hold 3 Frames** über Remint-UUID.
46. **DisplayLink rebase auf PTS** nach Hub-Sleep.
47. **Swift Testing** statt DIY `ok()`.
48. **nv12 IOSurface zero-copy** sobald CameraBroker sitzt.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder FaceTrack-Store oder Overlay-Metal.
# Nachtrag 2026-09-07 — 1.5.178 / 2.1.179 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.178** (Build 197).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.179 alpha** (Build 204).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.177 Rebase setzte lastMapped2 = cursorSmooth (Fill-Offset). Aegis leftoverHasHold ignorierte poseAt. Overlay StoreName las nur Frontal-Hold, ¾-Bins tot. HUD ohne `store Ada`.

## Warum es schlecht wirkte (dieser Pass)

1. **Rebase auf Fill, nicht Kamera.** Nach Continuity-Lücke lastMapped = Palme, cursorSmooth = alter Fill. lastMapped2 = Fill → displayLinkVelocity (Kamera−Fill)/dt = Flug.
2. **lastDisplayTick nicht rebased.** Erster Fill nach Lücke mit Rest-dt trotz Cap 1,5×.
3. **Fill-Cap ignoriert MAD.** Continuity-Jitter volle px-Budget, Overshoot.
4. **leftoverHasHold ohne poseAt.** leftoverHold-Dict tot nicht. Overlay leftoverNameFromHold nach Latch 4 s noch Ada.
5. **StoreName nur Frontal.** leftoverHold[id] ¾ = nil, Bins 0,77 Ada, Overlay trotzdem „?“.
6. **Kein Store-Chip.** Jump-Lock LOCK 1,2 s, danach still. Ada im Overlay ohne Why.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.178 / 2.1.179 gelandet

- **obsFillGapRebasePoint.** lastMapped2 = lastMapped ?? cursorSmooth. lastDisplayTick = 0.
- **pointerKalmanCapMul.** MAD 0,018 → Cap × 0,45.
- **leftoverHoldMaxOf / leftoverHasHoldOf.** Bins+Frontal, poseAt Latch 4 s.
- **leftoverStoreChip `store Ada`.** Gate nach LOCK tot.
- **leftoverOverlayGuest** HoldMax, nicht nur Frontal.
- Tests + MARKETING 1.5.178 / 2.1.179 (Build 197 / 204). Schema 15 bleibt.

Pass 20: Fill-Gap Kamera-Rebase + MAD-Cap, leftoverHasHold poseAt, StoreChip — 1.5.178 / 2.1.179.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn. Ohne den sitzen Helios und Aegis auf zwei Sessions.
2. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.** StoreName sitzt im Overlay. Matching bleibt Schatten-Maps. Nächster Aegis-Strukturhebel.
3. **palmKalman + pointerKalman eine Uhr.** palmKalman 0–1 Kamera, pointerKalman Quartz. Observation-Timestamp speist beide. P nicht auf Fill-Gap 0 setzen.
4. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Fill-Gap macht das Overlay ehrlicher, nicht schneller.
5. **Eine Homographie je Display-UUID.** destEdgeNearest sitzt, SpaceMap bleibt eine Karte für Laptop+5K.
6. **POSIX-Semaphore + INTENT → Yield → CONFIRM.** flock überlebt Sleep/Hub schlecht.
7. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
8. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto (Hist, Span, Keep, Conf-Dip, Gap, StoreName).
9. **Latency-HUD Tick→AX.** End-to-end ms. 8 fps vs 90 Hz messbar.
10. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal.
11. **IOHID Event-Tap** statt CGEvent (`bugfix` 1.5.8).
12. **AX SetPosition ein Call/Frame** (`bugfix`).
13. **Per-App Gain aus AX bundle id** (`bugfix`).
14. **Gesture-Log JSONL** (`bugfix`).
15. **Enrollment-HUD 3-Slot im Overlay.**
16. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
17. **Watch-IMU Pinch-Confirm.**
18. **Vision Hand-Mesh** (macOS 26).
19. **Frame-ID auf IOSurface.**
20. **Aegis-Yaw als Helios Click-Lock.**
21. **VNDetectHumanBodyPose** als Prop-Veto.
22. **Gemeinsames CameraMath-Package.** Mutex-Logik ist 1:1 kopiert.
23. **Telemetry-Ring 30 s + OSLog.**
24. **Center Stage force-off nach Sleep.**
25. **Continuity USB-Hub Watchdog.**
26. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
27. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
28. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
29. **VNTrackObjectRequest** statt Remint.
30. **Aegis live outputQueue ≠ MainActor.**
31. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional neben Pinzette.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG.**
42. **Helios Kill-Switch Datei** neben Mutex.
43. **Speaker-Diarization.**
44. **Face-Print ONNX sidecar.**
45. **Gallery-on-disk mmap.**
46. **Hover-Preview ohne Click.**
47. **pointerKalman echter P/Q/R.** CapMul skaliert nur. Process-Noise dunkel höher, State über Fill.
48. **Fill-Gap Audio-Cue** 8 fps Drop.
49. **Per-Display Fill-Gap Mul** USB 2,0 / Wi-Fi 3,2.
50. **lastHandSeen aus Kamera-PTS**, nicht CACurrentMediaTime. Hub-Pause sonst Gap-false.
51. **leftoverJumpName + StoreName ein Overlay-Pfad.** Jump 1,2 s dann store, nicht zwei Reader.
52. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei mit Fill-Gap.
53. **kAXFocusedUIElementChanged** statt FocusTracker-Poll.
54. **maximumHandCount 2 + Joint-Group** statt Observation-first.
55. **palmKalman P nicht auf Fill-Gap resetten.** Kamera-Uhr ≠ Display-Uhr.
56. **Overlay Chip-Budget `store` vor Spark.** Cap 6 droppt sonst Ada.
57. **FaceTrack Pack als Live-Store** — leftoverHold/Bins/NameLock eine Unpack-Quelle.
58. **Continuity-Drop HUD** `CAM 400` neben FILL gap.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder FaceTrack-Store als einziges Dict oder Overlay-Metal.

# Nachtrag 2026-09-07 — 1.5.177 / 2.1.179 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.177** (Build 196).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.179 alpha** (Build 204).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.176 Fill-Gap return ließ lastMapped2/Vel 400 ms stehen — nächster Tick flog. HUD ohne FILL gap, Predict-Chip blieb. Aegis StoreGet nahm nameUntil (Jump-Lock 1,2 s) als TTL — Overlay Gast nach Remint obwohl Hold 0,80 Ada.

## Warum es schlecht wirkte (dieser Pass)

1. **Fill-Gap ohne Rebase.** obsFillSkipsGap return. lastMapped2 + palmVelScreen aus der Lücke. displayLinkVelocity 400 ms Delta = Flug über die Naht.
2. **FILL gap Chip tot.** Helper + Test saßen, HUD/displayTick riefen nicht. Predict-Chip log nach Lücke.
3. **Fill Euler, nicht CV.** displayLinkCursorOf vel×dt. Nach Rebase brauchte der Fill denselben Kalman-Schritt wie die Tests.
4. **Store TTL = Jump-Lock.** leftoverFaceTrackHolds `now >= nameUntil`. leftoverNameLockUntil ist 1,2 s JUMP, nicht Latch 4 s. poseAt lag im Struct, Holds las ihn nicht.
5. **Overlay ignorierte StoreName.** leftoverOverlayGuest nur Hist. Nach Remint Hist leer → „?“, Ada im Hold.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.177 / 2.1.179 gelandet

- **obsFillGapRebase / pointerKalmanResets.** Lücke latched, nächster Fill lastMapped2 = cursorSmooth, Vel 0.
- **obsFillGapChip** im HUD. Predict-Chip tot über der Lücke.
- **obsFillGapMulPref 1,8–3,2.** Slider Fill-Lücke. Default 2,4.
- **pointerKalmanVel / Predict.** CV dt<2 s, Cap X/Y. displayTick Fill = Predict.
- **leftoverFaceTrackHolds poseAt.** Latch 4 s wenn poseAt sitzt. nameUntil nur ohne poseAt (Tests).
- **leftoverFaceTrackStoreNameOf / leftoverOverlayGuestOf.** LibraryStore Overlay StoreName vor Hist.
- Tests + MARKETING 1.5.177 / 2.1.179 (Build 196 / 204). Schema 15 bleibt.

Pass 19: Fill-Gap Rebase + Kalman-CV, Store poseAt, Overlay StoreName — 1.5.177 / 2.1.179.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn. Ohne den sitzen Helios und Aegis auf zwei Sessions.
2. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.** StoreName sitzt im Overlay. Matching bleibt Schatten-Maps. Nächster Aegis-Strukturhebel.
3. **palmKalman + pointerKalman eine Uhr.** palmKalman 0–1 Kamera, pointerKalman Quartz. Observation-Timestamp speist beide.
4. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Fill-Gap macht das Overlay ehrlicher, nicht schneller.
5. **Eine Homographie je Display-UUID.** destEdgeNearest sitzt, SpaceMap bleibt eine Karte für Laptop+5K.
6. **POSIX-Semaphore + INTENT → Yield → CONFIRM.** flock überlebt Sleep/Hub schlecht.
7. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
8. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto (Hist, Span, Keep, Conf-Dip, Gap, StoreName).
9. **Latency-HUD Tick→AX.** End-to-end ms. 8 fps vs 90 Hz messbar.
10. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal.
11. **IOHID Event-Tap** statt CGEvent (`bugfix` 1.5.8).
12. **AX SetPosition ein Call/Frame** (`bugfix`).
13. **Per-App Gain aus AX bundle id** (`bugfix`).
14. **Gesture-Log JSONL** (`bugfix`).
15. **Enrollment-HUD 3-Slot im Overlay.**
16. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
17. **Watch-IMU Pinch-Confirm.**
18. **Vision Hand-Mesh** (macOS 26).
19. **Frame-ID auf IOSurface.**
20. **Aegis-Yaw als Helios Click-Lock.**
21. **VNDetectHumanBodyPose** als Prop-Veto.
22. **Gemeinsames CameraMath-Package.** Mutex-Logik ist 1:1 kopiert.
23. **Telemetry-Ring 30 s + OSLog.**
24. **Center Stage force-off nach Sleep.**
25. **Continuity USB-Hub Watchdog.**
26. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
27. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
28. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
29. **VNTrackObjectRequest** statt Remint.
30. **Aegis live outputQueue ≠ MainActor.**
31. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional neben Pinzette.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG.**
42. **Helios Kill-Switch Datei** neben Mutex.
43. **Speaker-Diarization.**
44. **Face-Print ONNX sidecar.**
45. **Gallery-on-disk mmap.**
46. **Hover-Preview ohne Click.**
47. **pointerKalman Q aus palm MAD.** Process-Noise dunkel höher.
48. **Fill-Gap Audio-Cue** 8 fps Drop.
49. **Per-Display Fill-Gap Mul** USB 2,0 / Wi-Fi 3,2.
50. **StoreName Chip** `store Ada` neben Hist `?`.
51. **leftoverHasHold über poseAt-TTL.**
52. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei mit Fill-Gap.
53. **kAXFocusedUIElementChanged** statt FocusTracker-Poll.
54. **maximumHandCount 2 + Joint-Group** statt Observation-first.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder FaceTrack-Store als einziges Dict oder Overlay-Metal.

# Nachtrag 2026-09-07 — 1.5.176 / 2.1.178 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.176** (Build 195).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.178 alpha** (Build 203).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.175 SIGTERM stahl den Lock sofort. WAL Restore 2 s RAM. Fill über Continuity-Lücken.

## Warum es schlecht wirkte (dieser Pass)

1. **SIGTERM dann Steal.** cameraMutexClaimWrites: Helios immer true. Holder live nach TERM → zwei Sessions, Overlay 8 fps, Cursor driftet.
2. **WAL Restore tot nach Restart.** leftoverPairCommitWALFresh ttl 2 s. Crash, App 5 s später auf → Taufe weg. Load las `.wal` nie. Save ließ WAL liegen.
3. **displayTick über Lücken.** Continuity drop 400 ms: Fill interpoliert tot, Zeiger fliegt, Overlay lügt.
4. **FaceTrack StoreGet nur Tests.** Matching bleibt leftover-Maps.
5. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.176 / 2.1.178 gelandet

- **cameraMutexTermBlocksWrite.** SIGTERM + pidLive → kein LockedLine. SIGKILL stiehlt.
- **cameraMutexTermChip / Remain.** HUD `TERM 1,4`. ClaimChip term:.
- **obsFillSkipsGap.** lastHand > 2,4× medianDt oder kein Hand → displayTick tot. Chip `FILL gap`.
- **leftoverPairCommitWALApply / RestoreDisk / AgeOk 24 h.** Load mtime, WAL neuer als gallery.json mergen.
- **leftoverPairCommitWALShouldClear** nach Save.
- **leftoverFaceTrackStoreName.**
- Tests + MARKETING 1.5.176 / 2.1.178 (Build 195 / 203). Schema 15 bleibt.

Pass 18: TERM-Steal tot, WAL-Restore Load, Fill-Gap — 1.5.176 / 2.1.178.

## Erweiterungen (neu, oben)

1. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn. Ohne den sitzen Helios und Aegis auf zwei Sessions, zwei Vision, zwei TCC.
2. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.** StoreName sitzt, Matching bleibt Schatten-Maps. Nächster Aegis-Strukturhebel.
3. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Fill-Gap macht das Overlay ehrlicher, nicht schneller.
4. **Eine Homographie je Display-UUID.** destEdgeNearest sitzt, SpaceMap bleibt eine Karte für Laptop+5K.
5. **POSIX-Semaphore + INTENT → Yield → CONFIRM.** flock überlebt Sleep/Hub schlecht. TERM-Wait ist Pflaster.
6. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R. Freeze-fps bleibt Schätzung.
7. **Overlay-Why Inspector.** Tap auf HUD-Chip zeigt Veto (Hist, Span, Keep, Conf-Dip, Gap).
8. **Latency-HUD Tick→AX.** End-to-end ms. 8 fps vs 90 Hz messbar.
9. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal.
10. **IOHID Event-Tap** statt CGEvent (`bugfix` 1.5.8).
11. **AX SetPosition ein Call/Frame** (`bugfix`).
12. **Per-App Gain aus AX bundle id** (`bugfix`).
13. **Gesture-Log JSONL** (`bugfix`).
14. **Enrollment-HUD 3-Slot im Overlay.**
15. **Helios liest Aegis leftover-Boxen** als Palm-Occlusion.
16. **Watch-IMU Pinch-Confirm.**
17. **Vision Hand-Mesh** (macOS 26).
18. **Frame-ID auf IOSurface.**
19. **Aegis-Yaw als Helios Click-Lock.**
20. **VNDetectHumanBodyPose** als Prop-Veto.
21. **Gemeinsames CameraMath-Package.** Mutex-Logik ist 1:1 kopiert.
22. **Telemetry-Ring 30 s + OSLog.**
23. **Center Stage force-off nach Sleep.**
24. **Continuity USB-Hub Watchdog.**
25. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
26. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
27. **Tests splitten** (GestureTests / MatchMathTests > 200 kB).
28. **VNTrackObjectRequest** statt Remint.
29. **Aegis live outputQueue ≠ MainActor.**
30. **Kalman-Zeiger 2D** constant-velocity. Fill-Gap braucht den, sonst Coast tot.
31. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV).
32. **Negativ-Galerie Props.**
33. **Print-Bank PCA-Whitening.**
34. **Cursor-Magnetismus** 8 px an AX-Hit.
35. **Dwell-Klick** optional neben Pinzette.
36. **Doorbell-Cue.**
37. **Clamshell: Vision pausieren.**
38. **Jerk Dead-Man.**
39. **Lock Schema v2.**
40. **Vision Pro Sidecar.**
41. **CI `swiftc` Tests vor DMG.**
42. **Helios Kill-Switch Datei** neben Mutex.
43. **Speaker-Diarization.**
44. **Face-Print ONNX sidecar.**
45. **Gallery-on-disk mmap.**
46. **Hover-Preview ohne Click.**
47. **Curl-Rate Pref** 0,12–0,28.
48. **S2 Close-Ratio Pref** im Panel.
49. **Freeze-Ticks Pref** 4–10.
50. **Fill-Gap Pref** 1,8–3,2× medianDt.
51. **WAL Age Pref** 1–48 h.
52. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei mit TERM-Wait.
53. **kAXFocusedUIElementChanged** statt FocusTracker-Poll.
54. **maximumHandCount 2 + Joint-Group** statt Observation-first.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder FaceTrack-Store oder Overlay-Metal.
# Nachtrag 2026-09-07 — 1.5.175 / 2.1.177 (kein Merge von `bugfix`)


Helios `bpms9cmnxc-debug/Helios` **1.5.175** (Build 194).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.177 alpha** (Build 202).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.176 Occupied ohne tieKey. Print-Bank Burst. Pair-Commit ohne WAL. Hung-live SIGKILL. Helios Freeze 800 ms.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverHashTwinOccupied ohne tieKey.** leftoverHashTwinLeft sitzt. Occupied rief ohne UUID. Twin x+yaw beide Occupied → Majority tauft falsch.
2. **Print-Bank Burst.** leftoverPrintPruneDup tot. gallery.json identische Prints, Cosine 0,99 lügt Identität.
3. **Pair-Commit RAM-only.** Crash während Save = Taufe tot. .bak rotiert gallery, nicht leftoverPairCommit.
4. **SIGKILL sofort.** Holder nach Sleep tot ohne Unlock. Continuity mutex 12 s.
5. **FaceTrack Lookup tot als Store.** Maps bleiben Schatten. StoreGet fehlte.
6. Helios Freeze/Curl/S2-Pinch — siehe Helios VORSCHLAEGE-GROK.md.
7. Von `bugfix` bewusst nicht gemergt: IOHID, AX SetPosition, Per-App-Gain, JSONL.

## In 1.5.175 / 2.1.177 gelandet

- **leftoverHashTwinOccupied(tieKey:).** LibraryStore UUID. leftoverOccupiedOtherRows.
- **leftoverPrintBankPrune** in printBankBlend.
- **leftoverPairCommitWAL** vor gallery.json, 3-Rotate, Restore < 2 s.
- **cameraMutexHeartbeatKillSignal.** SIGTERM, dann SIGKILL nach 2 s.
- **leftoverFaceTrackStoreGet.** Lookup+Hold.
- Helios Freeze-Need, Curl Pre-Arm, S2 Pinch-Floor.
- Tests + VERSION = Models = MARKETING 2.1.177 (Build 202). Schema 15 bleibt.

Pass 17: Twin-tieKey, Print-Prune, Pair-WAL, SIGTERM — 1.5.175 / 2.1.177.

## Erweiterungen (neu, oben)

1. **Eine Frame-Uhr.** Observation-Timestamp ist die einzige Uhr. Fill nur intra-frame. Coast = Kalman.
2. **Palm-Print Sticky-ID.** Wrist→Thumb statt Vision L/R.
3. **Overlay-Why Inspector.** HUD-Chip zeigt Veto-Grund.
4. **Per-Display SpaceMap.** Zwei Homographien, ein Pad.
5. **POSIX-Semaphore + Intent.** Statt `/tmp` flock. INTENT → Yield → CONFIRM.
6. **Negativ-Galerie Props.** Cosine gegen Gitarre/Kabel vor isHand / vor leftoverHold.
7. **Latency-HUD Tick→AX.** End-to-end ms, Telemetry-Ring 30 s.

8. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
9. **App-Group `group.helios.aegis`.**
10. **Overlay Metal 90 Hz.**
11. **IOHID Event-Tap** (`bugfix` 1.5.8).
12. **AX SetPosition ein Call/Frame** (`bugfix`).
13. **Per-App Gain** (`bugfix`).
14. **Gesture-Log JSONL** (`bugfix`).
15. **FaceTrack `[UUID: FaceTrack]` als einziges leftover-Dict.**
16. **Enrollment-HUD 3-Slot im Overlay.**
17. **WAL Restore beim Load** wenn gallery.json fehlt.
18. **SIGTERM-Chip im Mutex-HUD.**
19. **Helios liest leftover-Boxen** als Palm-Occlusion.
20. **Watch-IMU Pinch-Confirm.**
21. **Vision Hand-Mesh** (macOS 26).
22. **Frame-ID auf IOSurface.**
23. **Aegis-Yaw als Helios Click-Lock.**
24. **VNDetectHumanBodyPose** als Prop-Veto.
25. **Gemeinsames CameraMath-Package.**
26. **Telemetry-Ring 30 s + OSLog.**
27. **Center Stage force-off nach Sleep.**
28. **Continuity USB-Hub Watchdog.**
29. **SpaceMap Auto-Recalib.**
30. **Two-mode Pointer.**
31. **Tests splitten.**
32. **VNTrackObjectRequest** statt Remint.
33. **Aegis live outputQueue ≠ MainActor.**
34. **Kalman-Zeiger 2D.**
35. **Latency-HUD.**
36. **Guitar-Schwelle aus Sitzabstand.**
37. **Negativ-Galerie.**
38. **Print-Bank PCA-Whitening.**
39. **Cursor-Magnetismus.**
40. **Dwell-Klick.**
41. **Doorbell-Cue.**
42. **Clamshell: Vision pausieren.**
43. **Jerk Dead-Man.**
44. **Lock Schema v2.**
45. **Vision Pro Sidecar.**
46. **CI `swiftc` Tests vor DMG.**
47. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM.**
48. **Helios Kill-Switch Datei.**
49. **Speaker-Diarization.**
50. **Face-Print ONNX sidecar.**
51. **Gallery-on-disk mmap.**
52. **Hover-Preview ohne Click.**
53. **Curl-Rate Pref.**
54. **S2 Close-Ratio Pref.**
55. **Freeze-Ticks Pref.**
56. **Per-Slot PinchGate continuity flag.**
57. **Shared integration test** Helios+Aegis gegen Fake-Lock.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, Overlay-Metal.

Nächster Code-Schritt: CameraBroker-XPC oder Overlay-Metal oder FaceTrack-Store. WAL Restore beim Load.
# Nachtrag 2026-09-07 — 1.5.174 / 2.1.176 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.174** (Build 193).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.176 alpha** (Build 201).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.175 Skip-HUD. Hung-live PID hielt die Kamera. Coach ¾R unsichtbar. Twin x+yaw beide Occupied. Helios S1-Coast ghostete S2.

## Warum es schlecht wirkte (dieser Pass)

1. **cameraMutexHeartbeatKillPid live == true nie.** Prozess da, Stamp tot → Kamera ewig.
2. **enrollmentCoach F+¾.** ¾L sitzt, ¾R fehlt, Coach nil.
3. **leftoverHashTwinLeft x+yaw gleich.** beide Occupied. Center-Stage-Zwillinge tot.
4. **FaceTrack nur Pack.** leftoverGateChip liest vier Maps.
5. **Helios S1-Coast ghostet S2.** Zwei-Pinzette Overlay tot.

## In 1.5.174 / 2.1.176 gelandet

- **Hung-live 12 s.** 5 s frisch bleibt.
- **leftoverEnrollSlotChip F/¾L/¾R.** Coach `enroll ¾R`.
- **leftoverHashTwinLeft tieKey.**
- **leftoverFaceTrackLookup / Holds / PrintPruneDup / PairCommitWAL.**
- Helios S2 Coast-Ghost, Freeze, Span, Pre-Arm, Overlay-Ghost Any.
- Tests + MARKETING 1.5.174 / 2.1.176 (Build 193 / 201). Schema 15 bleibt.

Pass 16: Hung-live, Enroll-Slots, Twin-Tie, S2 Ghost — 1.5.174 / 2.1.176.

## Erweiterungen (neu, oben)

1. **tieKey in leftoverHashTwinOccupied verdrahten.**
2. **Print-Prune in LibraryStore.write.**
3. **Pair-Commit WAL nach gallery.json.**
4. **FaceTrack als einziges leftover-Dict.**
5. **Hung-live SIGTERM 2 s vor SIGKILL.**
6. **Enrollment-HUD 3-Slot im Overlay.**
7. **CameraBroker-XPC.**
8. **App-Group `group.helios.aegis`.**
9. **Overlay Metal 90 Hz.**
10. **IOHID / AX / Per-App-Gain / JSONL** (`bugfix`).
11. **Helios liest Aegis leftover-Boxen.**
12. **Watch-IMU Pinch-Confirm.**
13. **Vision Hand-Mesh** (macOS 26).
14. **Frame-ID auf IOSurface.**
15. **Aegis-Yaw als Helios Click-Lock.**
16. **VNDetectHumanBodyPose.**
17. **CameraMath-Package.**
18. **Telemetry-Ring 30 s.**
19. **Center Stage force-off nach Sleep.**
20. **Continuity USB-Hub Watchdog.**
21. **SpaceMap Auto-Recalib.**
22. **Two-mode Pointer.**
23. **Tests splitten.**
24. **VNTrackObjectRequest.**
25. **outputQueue ≠ MainActor.**
26. **Kalman-Zeiger 2D.**
27. **Latency-HUD.**
28. **Guitar-Schwelle aus IOD.**
29. **Negativ-Galerie.**
30. **PCA-Whitening.**
31. **Cursor-Magnetismus.**
32. **Dwell-Klick.**
33. **Doorbell-Cue.**
34. **Clamshell Pause.**
35. **Jerk Dead-Man.**
36. **Lock Schema v2.**
37. **Vision Pro Sidecar.**
38. **CI `swiftc` Tests vor DMG.**
39. **Zwei-Phasen Mutex.**
40. **Helios Kill-Switch Datei.**
41. **Speaker-Diarization.**
42. **ONNX sidecar.**
43. **Gallery mmap.**
44. **Hover-Preview ohne Click.**
45. **Freeze-Need aus fps.**
46. **Per-Finger Curl-Rate.**
47. **S2 Pinch-Ratio Floor.**

# Nachtrag 2026-09-07 — 1.5.173 / 2.1.175 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.173** (Build 192).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.175 alpha** (Build 200).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.174 Print je Gesicht. ROI Ada+Twin. Overlay ohne `still`. Helios S1-Hist auf S2.

## Warum es schlecht wirkte (dieser Pass)

1. **liveRoiBox alle Kalman.** Ada still im Crop. Twin-Print-Budget tot.
2. **leftoverGateChip ohne Skip.** Ada druckt unsichtbar.
3. **Helios S1-Hist auf S2.** Compact-Ring veto'te 0,29. Zweite Hand tot.
4. **lastS2 1 Miss tot.** Zwei-Pinzette 8 fps tot.
5. **Keep-Band = Gitarre zur Hand.** nearLast 0,29 = isHand.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.173 / 2.1.175 gelandet

- **leftoverPrintSkipChip / SkipSummary / liveRoiTracks.** Ada still raus aus Crop.
- **palmBindScaleHistOf / lastS2ScaleRing / s2MissTicks.**
- **palmScaleIsHand keep ohne Band + Approaching + Dense-Band.**
- **palmPinchMuteOverlap + ScaleClass-Chip.**
- Tests + MARKETING 1.5.173 / 2.1.175 (Build 192 / 200). Schema 15 bleibt.

Pass 15: Skip-HUD, ROI ohne still, S2 Hist+Coast, Keep-Gitarre tot — 1.5.173 / 2.1.175.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.**
2. **CameraBroker-XPC.**
3. **App-Group `group.helios.aegis`.**
4. **Overlay Metal 90 Hz.**
5. **IOHID / AX / Per-App-Gain / JSONL** (`bugfix` 1.5.8 / 2.1.15).
6. **Helios liest Aegis leftover-Boxen** auf der Mutex-Zeile als Palm-Occlusion.
7. **Watch-IMU Pinch-Confirm.**
8. **Vision Hand-Mesh** (macOS 26).
9. **Frame-ID auf IOSurface.**
10. **Faust-forming Pre-Arm.**
11. **Aegis-Yaw als Helios Click-Lock.**
12. **S2 Overlay-Ghost analog S1.**
13. **Enrollment-HUD** 3 Yaw-Slots + Blink.
14. **Pair-Commit WAL.**
15. **Helios Kill-Switch Datei.**
16. **VNDetectHumanBodyPose** Prop-Veto.
17. **Gemeinsames CameraMath-Package.**
18. **Telemetry-Ring 30 s + OSLog.**
19. **Center Stage force-off nach Sleep.**
20. **Continuity USB-Hub Watchdog.**
21. **Per-Slot One-Euro aus fps.**
22. **SpaceMap Auto-Recalib.**
23. **Two-mode Pointer.**
24. **Tests splitten.**
25. **VNTrackObjectRequest** statt Remint.
26. **Gallery compaction.**
27. **Aegis live outputQueue ≠ MainActor.**
28. **Kalman-Zeiger 2D.**
29. **Latency-HUD.**
30. **Shared Fake-Lock-Test.**
31. **Speaker-Diarization.**
32. **Face-Print ONNX sidecar.**
33. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM.**
34. **Guitar-Schwelle aus Sitzabstand.**
35. **S1+S2 Chirality-Freeze 800 ms.**
36. **Negativ-Galerie.**
37. **Print-Bank PCA-Whitening.**
38. **Cursor-Magnetismus.**
39. **Dwell-Klick / Watch-Companion.**
40. **Doorbell-Cue.**
41. **Clamshell: Vision pausieren.**
42. **Jerk Dead-Man.**
43. **Lock Schema v2.**
44. **Vision Pro Sidecar.**
45. **CI `swiftc` Tests vor DMG.**
46. **Adaptive Coast-Need aus miss-dt.**
47. **Palm-span statt nur Scale** für Band-Gate.
48. **S2 Conf-EMA Ring.**
49. **Hover-Preview ohne Click.**
50. **Per-Hand Pinch-Ratio Floor aus palmScale.**
51. **Gallery-on-disk mmap.**
52. **Helios Testmodus Replay** aus JSONL.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, maximumHandCount 2.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal. S2 Overlay-Ghost. leftover-Box auf Mutex-Zeile.

# Nachtrag 2026-09-07 — 1.5.172 / 2.1.174 (kein Merge von `bugfix`)


Helios `bpms9cmnxc-debug/Helios` **1.5.172** (Build 191).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.174 alpha** (Build 199).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.173 FaceTrack-PredictHeld. printBudget min/max global. Helios Bind-EMA mischte Gitarre.

## Warum es schlecht wirkte (dieser Pass)

1. **printBudgetSkip min(stillFor) / max(|yaw|).** Twin bewegt → Ada druckt. leftoverHold wandert.
2. **leftoverPrintYawMerge ohne printedIds.** Ada-Yaw = live, Δ 0.
3. **FaceEngine skipPrints bool.** Ein Flag für alle. Per-Box fehlte.
4. **Helios palmBindScaleOf auf alle Blobs.** 0,29→0,21 = isHand, Conf 0,95.
5. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.172 / 2.1.174 gelandet

- **printBudgetSkipIds / SkipAll / leftoverPrintSkipHits / SkipBoxes.** Ada still, Twin print.
- **FaceEngine skipPrintBoxes.** stampPrints skippt Ada.
- **leftoverPrintYawMerge(printedIds:).** Ada-Yaw hält.
- **palmBindScaleClass + lastS2 Conf/Keep.** Helios Gitarre nicht S1, S2-Dip hält.
- Tests + MARKETING 1.5.172 / 2.1.174 (Build 191 / 199). Schema 15 bleibt.

Pass 14: Print je Gesicht, Live-Scale Bind, S2 Conf — 1.5.172 / 2.1.174.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.**
2. **CameraBroker-XPC.**
3. **App-Group `group.helios.aegis`.**
4. **Overlay Metal 90 Hz.**
5. **IOHID / AX / Per-App-Gain / JSONL** (`bugfix` 1.5.8 / 2.1.15).
6. **maximumHandCount bleibt 4.** 2 wäre Regression (Vision rankt Gitarre zuerst).
7. **Print-Skip HUD** `Ada still · Twin print`.
8. **S2 Coast unabhängig von s1MissTicks.**
9. **S1∩S2 Pinch-Mute.**
10. **Approaching-Gate im Gitarrenband** ohne Keep-Radius.
11. **Enrollment-HUD** 3 Yaw-Slots + Blink.
12. **Pair-Commit WAL.**
13. **Helios Kill-Switch Datei.**
14. **VNDetectHumanBodyPose** Prop-Veto.
15. **Gemeinsames CameraMath-Package.**
16. **Telemetry-Ring 30 s + OSLog.**
17. **Center Stage force-off nach Sleep.**
18. **Continuity USB-Hub Watchdog.**
19. **Per-Slot One-Euro aus fps.**
20. **SpaceMap Auto-Recalib.**
21. **Two-mode Pointer.**
22. **Tests splitten.**
23. **VNTrackObjectRequest** statt Remint.
24. **Gallery compaction.**
25. **Aegis live outputQueue ≠ MainActor.**
26. **Palm-Occlusion S2∩S1.**
27. **Kalman-Zeiger 2D.**
28. **Latency-HUD.**
29. **Shared Fake-Lock-Test.**
30. **FaceTrack Encode extra.**
31. **Speaker-Diarization.**
32. **Face-Print ONNX sidecar.**
33. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM.**
34. **Guitar-Schwelle aus Sitzabstand.**
35. **S1+S2 Chirality-Freeze 800 ms.**
36. **Negativ-Galerie.**
37. **Print-Bank PCA-Whitening.**
38. **Cursor-Magnetismus.**
39. **Dwell-Klick / Watch-Companion.**
40. **Doorbell-Cue.**
41. **Clamshell: Vision pausieren.**
42. **Jerk Dead-Man.**
43. **Lock Schema v2.**
44. **Vision Pro Sidecar.**
45. **ScaleClass-Chip Test-HUD.**
46. **skipPrintBoxes an Detect-ROI.**
47. **Helios S2 Hist-Ring.**
48. **CI `swiftc` Tests vor DMG.**

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite, maximumHandCount 2.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal. Print-Skip HUD.

# Nachtrag 2026-09-07 — 1.5.170 / 2.1.172 (kein Merge von `bugfix`)


Helios `bpms9cmnxc-debug/Helios` **1.5.170** (Build 189).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.172 alpha** (Build 197).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.169 Hist-Prior. 2.1.171 Unsure-Streak/Coast-TTL. Fünf Löcher blieben: Gitarre Conf ohne Hist, Guitar-Hist lockt S1, printBudget ohne Still, Coast-Stamp restampt Cache, Kalman-Predict unverdrahtet.

## Warum es schlecht wirkte (dieser Pass)

1. **palmBind Conf ohne Compact.** 0,29 und 0,14 sind beide palmScaleIsHand (< 0,72). Tick 0 Ring leer: Conf 0,95 = S1 Prop.
2. **Hist-Prior bei Guitar-Median.** med 0,29, jump 0 → Prior 1 für beide. Compact erholt S1 nicht. Ring nahm 0,29.
3. **printBudgetSkip ohne stillFor.** Still 0,10 s + IoU 0,95 skippt Print. Coast-TTL 2 s, Twin im Kalman-Kasten = Ada.
4. **leftoverCoastPrintStampMerge restampte Cache.** skipPrints→Detect, live = stored, Stamp = now. TTL tot.
5. **leftoverPredictHeld rief boxKalmanPredict.** leftoverFaceTrackKalmanPredict saß, Store nicht.
6. **Overlay `?` ohne Streak.** leftoverUnsureTicks ungelesen.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.170 / 2.1.172 gelandet

- **palmBindCompactPrefers** vor Conf. Compact < 0,28 vor Gitarre-Range, auch ohne Hist.
- **palmScaleHistPrior Guitar-Hist.** med ≥ 0,28 → Compact 1, Gitarre 0.
- **palmScaleMedianRecords.** 0,29 nicht in lastS1ScaleRing.
- **palmSlotConfEma / palmSlotConfHolds.** 1-Frame Dip hält S1.
- **printBudgetSkip(stillFor:).** < 0,80 s kein Skip. LibraryStore min(liveStillFor).
- **leftoverCoastPrintSame / StampMerge(stored:).** Identischer Vec kein Restamp.
- **leftoverPredictHeld → leftoverFaceTrackKalmanPredict.** Cap 0,12.
- **leftoverUnsureChip(streak:) `??`.** leftoverOverlayGuest liest leftoverUnsureTicks.
- Tests + MARKETING 1.5.170 / 2.1.172 (Build 189 / 197). Schema 15 bleibt.

Pass 13: Compact vor Conf, Guitar-Hist-Erholung, stillFor, Coast-Stamp, Kalman-Predict, Overlay `??` — 1.5.170 / 2.1.172.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Predict sitzt, Maps bleiben Schatten.
2. **Coast-Print in gallery.json** mit Age. Restart sonst Twin neu.
3. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
4. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
5. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot.
6. **IOHID Event-Tap** statt CGEvent (`bugfix`).
7. **AX SetPosition ein Call/Frame** (`bugfix`).
8. **Per-App Gain aus AX bundle id** (`bugfix`).
9. **Gesture-Log JSONL** (`bugfix`).
10. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe.
11. **Pair-Commit WAL** in gallery.json.
12. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
13. **VNDetectHumanBodyPose** als Prop-Veto. Compact-Prefer sitzt, Body-Pose ist die harte Spur.
14. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
15. **Lokaler Telemetry-Ring 30 s** + OSLog.
16. **Center Stage force-off nach Sleep.**
17. **Continuity USB-Hub Watchdog** nach Sleep.
18. **Per-Slot One-Euro Cutoff aus fps.**
19. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s.
20. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
21. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
22. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
23. **Gallery compaction:** pruneCosine 0,98 Burst raus.
24. **Aegis live outputQueue ≠ MainActor.**
25. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute.
26. **destEdgePad Pref je Display-UUID.**
27. **Kalman-Zeiger 2D** constant-velocity.
28. **maximumHandCount 2** hart. Compact-Prefer sitzt, Vision liefert weiter 4.
29. **Latency-HUD** Tick zu AX-move.
30. **Prefs je camera uniqueID.**
31. **leftoverSoftmaxBlocks bleibt auf leftoverScore.**
32. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
33. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID.
34. **FaceTrack Encode in gallery.json extra.**
35. **Speaker-Diarization** als Aegis-Cue.
36. **Face-Print ONNX sidecar** optional neben Vision.
37. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM.**
38. **printBudget aus FaceTrack.stillFor** sitzt. Per-Face statt min() — Twin bewegt, Ada still: Ada skippt nicht mehr mit.
39. **palmSlotConfEma je Slot**, nicht nur S1 lastHands. S2 Dip tot.
40. **CI `swiftc` MatchMathTests + GestureTests vor DMG.**
41. **Guitar-Schwelle aus Sitzabstand** (IOD / FOV). 0,28 ist Desk-fest.
42. **S1+S2 Chirality-Freeze 800 ms** nach beiden gesehen — Flip tot.
43. **leftoverHold-Write nur nach Yaw-Bin-Coverage** (F+¾+P). Frontal-Hold auf Profil tot.
44. **Negativ-Galerie** (bekannte Nicht-Matches) als Open-Set-Stütze.
45. **Print-Bank PCA-Whitening** vor Cosine.
46. **Cursor-Magnetismus** 8 px an AX-Hit.
47. **Helios Dwell-Klick** optional neben Pinzette.
48. **Watch-Companion** Haptic-Klick.
49. **Aegis Spotlight-Importer** für die Foto-Mediathek.
50. **Doorbell-Cue** — wer gerade ins Bild kam.
51. **Maus-Jiggle-Suppressor** ohne Hand.
52. **Clamshell: Vision pausieren** (Akku).
53. **Jerk Dead-Man** für versehentliches Fling (Hochpass sitzt, Ruck-Gate fehlt).
54. **Shared Lock Schema v2** generation + intent + palm-rect + face-rect.
55. **Vision Pro / Spatial Persona Sidecar.**

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal. printBudget per-Face stillFor. palmSlotConf je Slot.

# Nachtrag 2026-09-07 — 1.5.169 / 2.1.171 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.169** (Build 188).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.171 alpha** (Build 196).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

1.5.168 Joint-Group. 2.1.170 Unsure/IoU. Vier Löcher blieben: leftoverTried auf Unsure, Coast-Vec ohne Alter, Name-Hist 3 Votes nach Remint, Gitarre Conf 0,95 vor Hand 0,14.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverTried.insert auf Unsure.** leftoverPinStatus zählte einen Pin. leftoverTried sperrte denselben leftover in der AssignLive-Nachlese. Twin ohne Vec wirkte „gehalten“.
2. **Unsure ewig.** leftoverClearStreak lief nicht. leftoverHold/Coast überlebten `?` bis Dropout. Overlay Gast-Chip für immer.
3. **leftoverCoastPrint ohne TTL.** skipPrints + Stillstand: Cache ≥32, Cosine 1,0 gegen sich selbst. Twin im Kalman-Kasten = Ada.
4. **liveNameHist Remint voll.** 3 Ada-Votes wandern auf die neue UUID. stabilizeLiveMatches tauft Twin Tick 0.
5. **palmBind Conf vor Hist.** Gitarre 0,29 Vision-Conf 0,95 vor Hand 0,14. Joint-Group nur 16 vs 6, nicht Scale-Sprung.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.169 / 2.1.171 gelandet

- **leftoverTriedInserts / leftoverPinCounts.** Unsure kein Tried, kein Pin. LibraryStore verdrahtet.
- **leftoverUnsureStreakAdvance / leftoverUnsureStreakClears.** 3× `?` → leftoverClearStreak + Remint-Live. Lookup über remintPlan.
- **leftoverCoastPrintFresh (2 s) + leftoverCoastPrintStampMerge.** skipPrints Stamp hält. LibraryStore SkipCosine liest nur frische Vecs.
- **leftoverNameHistRemintTrim keep 1.** remap tot = Hist hält.
- **palmScaleHistPrior soft.** Jump 0,08–0,12 linear. Veto bleibt 0.
- **palmBindHandsFirst(hist:)** vor Conf. HandTracker lastS1ScaleRing.
- Tests + MARKETING 1.5.169 / 2.1.171 (Build 188 / 196). Schema 15 bleibt.

Pass 12: Unsure-Tried tot, Unsure-Streak, Coast-TTL, Name-Hist-Trim, Hist-Prior — 1.5.169 / 2.1.171.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** px/py sitzen im Struct, boxKalmanV remintet extra — Pack ist Schatten. Ein Dict, Apply/Decode/Encode einmal.
2. **leftoverFaceTrackKalmanPredict verdrahten.** 2.1.170 hat Vel im Struct, LibraryStore schreibt boxKalmanV separat. Predict nach Remint sonst 0.
3. **Coast-Print in gallery.json** mit Age. Restart sonst Twin neu. leftoverCoastPrintAt stirbt mit dem Prozess.
4. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
6. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Detect 8–12 fps, Overlay 60 Hz, Baptize nur Detect-Tick.
7. **IOHID Event-Tap** statt CGEvent (`bugfix`).
8. **AX SetPosition ein Call/Frame** (`bugfix`).
9. **Per-App Gain aus AX bundle id** (`bugfix`).
10. **Gesture-Log JSONL** (`bugfix`).
11. **OneEuro State in FaceTrack.** boxEuro remintet extra.
12. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Unsure-Chip sitzt, HUD fehlt.
13. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
14. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
15. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
16. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
17. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt, unsure-ratio) + OSLog.
18. **Center Stage force-off nach Sleep** in beiden Clients.
19. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
20. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
21. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
22. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
23. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
24. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
25. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
26. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
27. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
28. **destEdgePad Pref je Display-UUID.**
29. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict.
30. **maximumHandCount 2** hart. Joint-Group + Hist-Prior sitzen, Observation-first bleibt Vision-seitig.
31. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
32. **Prefs je camera uniqueID** (Orient, Format, Pad).
33. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen.
34. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
35. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID. Live-PID mit Stamp > 6 s nach Sleep nicht SIGKILL — bewusste Grenze.
36. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct (Vel stirbt).
37. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
38. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
39. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile bis CameraBroker.
40. **leftoverUnsure Overlay `??` vs `?`.** Streak 2 anders als Streak 1. Chip sitzt `?`.
41. **printBudget aus FaceTrack.stillFor.** Still 0,8 s + IoU 0,92 skippt ehrlich, nicht nur fps.
42. **palmSlotConfEma.** Slot hält die schwächere Hand 1 Frame. Hist-Prior sitzt pro Tick.
43. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
44. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture.
45. **Coast-Vec persist Age in gallery** plus leftoverCoastPrintAt Encode.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass, FaceTrack-Store-Rewrite.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store (boxKalmanV + leftoverCoastPrintAt + leftoverUnsureTicks hinein) oder CameraBroker oder Overlay-Metal.

# Nachtrag 2026-09-07 — 1.5.168 / 2.1.170 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.168** (Build 187).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.170 alpha** (Build 195).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.169 Lookup las Hold/Kalman/Coast, leftoverPick bekam trotzdem leftoverHold[old.id] = nil und leftoverCoastCosine schob die Hold-Zahl 0,70 als Cosine. Twin im Kalman-Kasten erbte den Namen.

## Warum es schlecht wirkte (dieser Pass)

1. **leftoverHold als Cosine.** leftoverCoastPrintSkipCosine nil → leftoverCoastCosine(stored: 0,70). leftoverPickPrint fällt auf Hold. leftoverPrintOk(0,70) pinnt. Twin ohne Vec getauft.
2. **leftoverPick holdPrev old.id.** Lookup saß nur beim Kandidaten-Bau. leftoverHoldPrevOf / leftoverAdvance lasen leftoverHold[old.id] nach Drop = nil.
3. **Detect-Skip ohne Coast-Vec.** Hold-Zahl rankte Kandidaten, nicht IoU. Nachbar mit 0,70 schlug echte Überlappung.
4. **Mutex tot-PID frei, Zombie blieb.** WRITE pidLive gibt den Lock frei. Der tote PID-Eintrag nach Sleep wurde nicht SIGKILL — hung Prozess 12 s.
5. **palmBind Conf-Tie ohne Joint-Group.** Gitarre 6 Joints vs Hand 16, gleiche Scale: Vision-Conf, nicht Topologie.
6. **Kalman-Vel nicht im FaceTrack.** Predict nach Remint 0. Maps extra, Struct kannte px/py nicht.
7. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.168 / 2.1.170 gelandet

- **leftoverHoldViaLookup / leftoverHoldLookupUnsure.** skipCosine nil + Hold nur Lookup → Unsure `?`. leftoverPickPrint(holdOnlyUnsure) kein Hold-Fallback. leftoverPick tot.
- **leftoverDetectSkipIoUOnly / leftoverPickArgmaxIou / leftoverPick(iouOnly).** Detect-Skip ohne Vec: max IoU, nicht Hold-Zahl.
- **leftoverCoastCosineMeasured.** LibraryStore leftover matching. holdPrev = Remint-Lookup. Overlay `?`.
- **leftoverFaceTrackKalmanVel / Predict.** px/py/pw/ph im FaceTrack. Pack/Unpack/RemintDropMaps. dt > 2 s tot.
- **cameraMutexHeartbeatKillPid / KillAllowed.** tot-PID SIGKILL unter LOCK_EX. Self nie, Live nie. CameraSession + LiveCapture.
- **palmBindJointGroupPrefers.** 16 vs 6 vor Conf-Tie. palmBindHandsFirst verdrahtet.
- Tests + MARKETING 1.5.168 / 2.1.170 (Build 187 / 195). Schema 15 bleibt.

Pass 11: Unsure ohne Vec, Detect-Skip IoU, Joint-Group, Heartbeat-SIGKILL, Kalman-Vel — 1.5.168 / 2.1.170.

## Erweiterungen (neu, oben)

1. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Vel sitzt im Struct. Maps bleiben Schatten — ein Dict, Apply/Decode/Encode einmal.
2. **Coast-Print in gallery.json.** Restart sonst Twin neu. leftoverCoastPrint nicht nur RAM.
3. **leftoverTried nicht auf Unsure.** Nächster Tick mit Print darf pinnen. Jetzt leftoverTried.insert — Retry tot bis Dropout.
4. **CameraBroker-XPC** — eine TCC, IOSurface an beide. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`.** Yield/Mutex/Pad einmal. Panel in Helios steuert Aegis.
6. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot. Detect 8–12 fps, Overlay 60 Hz, Baptize nur Detect-Tick.
7. **IOHID Event-Tap** statt CGEvent (`bugfix`).
8. **AX SetPosition ein Call/Frame** (`bugfix`).
9. **Per-App Gain aus AX bundle id** (`bugfix`).
10. **Gesture-Log JSONL** (`bugfix`).
11. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture. Linux-CI Fixture.
12. **Zwei-Phasen Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
13. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
14. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Unsure-Chip sitzt, HUD fehlt.
15. **Pair-Commit WAL** in gallery.json (Crash mitten im Twin).
16. **Helios Kill-Switch Datei** neben Mutex — Aegis mutet Baptize solange Faust-Lock.
17. **Face-Print ONNX sidecar** optional neben Vision — Open-Set Energy ehrlich.
18. **Speaker-Diarization** als Aegis-Cue (wer spricht, bleibt S1).
19. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt). Drift 1.5.168/2.1.170 sonst in einem Monat.
20. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt, unsure-ratio) + OSLog.
21. **Center Stage force-off nach Sleep** in beiden Clients.
22. **Continuity USB-Hub Watchdog** nach Sleep (uniqueID wechselt, Format 0×0).
23. **Per-Slot One-Euro Cutoff aus fps**, nicht global 14 bei 8 fps.
24. **SpaceMap Auto-Recalib** RMS > 24 px / 2 s, eine Karte je Display-UUID.
25. **Two-mode Pointer:** Desk absolut, 0,8 s Dwell relativ.
26. **Tests splitten** (GestureTests / MatchMathTests). Dateien > 200 kB.
27. **Vision revision + VNTrackObjectRequest** statt eigenes Remint.
28. **Gallery compaction:** pruneCosine 0,98 Burst raus, WAL checkpoint jede 50 Saves.
29. **Aegis live outputQueue ≠ MainActor** — Detect-Jank nicht in SwiftUI.
30. **Palm-Occlusion S2∩S1.** Hand-over-Face Mute über die Lock-Zeile.
31. **destEdgePad Pref je Display-UUID.**
32. **Kalman-Zeiger 2D** constant-velocity statt 1-Euro + Predict. FaceTrack-Vel ist der Baustein.
33. **maximumHandCount 2** hart. Joint-Group sitzt, Observation-first bleibt Vision-seitig.
34. **Latency-HUD** Tick zu AX-move, über 40 ms Gain halb.
35. **Prefs je camera uniqueID** (Orient, Format, Pad).
36. **leftoverSoftmaxBlocks bleibt auf leftoverScore.** Nicht auf Roh umstellen.
37. **Shared integration test** Helios+Aegis gegen Fake-Lock-Datei.
38. **Helios palmScale histogram prior Bayes** — Gitarre 0,29 vs Hand 0,14, nicht nur hartes Gate + Veto.
39. **Mutex Heartbeat hung-live.** Jetzt nur tot-PID. Live-PID mit Stamp > 6 s nach Sleep nicht SIGKILL — bewusste Grenze.
40. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct (Vel stirbt).
41. **stabilizeLiveMatches remint-aware.** Vote-Cap nach Remint 1 Tick statt 3.
42. **OneEuro State in FaceTrack.** boxEuro remintet extra.
43. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
44. **leftover matching Unsure-Streak.** 3× `?` hintereinander → leftoverClearStreak, nicht ewig Gast.
45. **Coast-Vec TTL.** RAM-Cache ohne Print 2 s → nil, sonst Twin nach Stillstand.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh, SIGKILL live-hung PID, CameraBroker in diesem Pass.

Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal.

# Nachtrag 2026-09-06 — 1.5.167 / 2.1.169 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.167** (Build 186).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.169 alpha** (Build 194).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

2.1.168 hat Coast-Vec und Print-Yaw-Δ. 1.5.166 Hist-Veto Live. Zwei Löcher blieben:
WRITE-Pfad des Mutex ignorierte tote PIDs; leftover matching las leftoverHold/Kalman/Coast auf old.id nach RemintDrop.

## Warum es schlecht wirkte (dieser Pass)

1. **Mutex WRITE ohne pidLive.** cameraMutexParse kill't tote PIDs auf dem Read. Unter LOCK_EX reichte LockedLine pidLive nicht durch — toter Helios-PID hielt den Lock 12 s. Aegis tot nach Crash/Sleep.
2. **RemintDrop vs leftover matching.** Hold/Kalman/Coast liegen nach Drop auf der Live-UUID. leftover matching las old.id → nil. leftoverHold-Fallback tot, Kalman-IoU tot, Coast-Cache tot.
3. Von `bugfix` bewusst nicht gemergt: IOHID, AX SetPosition, Per-App-Gain, JSONL.

## In 1.5.167 / 2.1.169 gelandet

- **cameraMutexWriteAllowed / LockedLine(pidLive:).** CameraSession + LiveCapture: kill(2) vor LOCK_EX-Write. Toter Holder → Lock frei.
- **leftoverHoldRemintLookup.** leftover matching liest Hold/Kalman/Coast über Source→Live.
- Tests + MARKETING 1.5.167 / 2.1.169 (Build 186 / 194). Schema 15 bleibt.

Pass 10: Mutex WRITE pidLive, leftoverHoldRemintLookup — 1.5.167 / 2.1.169.

## Erweiterungen (neu, oben)

1. **leftover matching Unsure** wenn leftoverCoastPrintSkipCosine nil und leftoverHold nur über Lookup sitzt — Twin ohne Vec nicht auf 0,70 taufen.
2. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Maps bleiben Schatten.
3. **CameraBroker-XPC** — eine TCC, IOSurface an beide.
4. **Mutex Heartbeat SIGKILL** des Zombies nach Sleep, nicht nur Lock frei.
5. **Coast-Print in gallery.json** — Restart sonst Twin neu.
6. **Shared Fake-Lock-Test** tot-PID Write ohne AVCapture.
7. **Kalman-Vel in FaceTrack.** Predict nach Remint sonst 0.
8. **Overlay Metal 90 Hz.** SwiftUI ForEach 21×2 tot.
9. **IOHID Event-Tap** statt CGEvent (`bugfix`).
10. **AX SetPosition ein Call/Frame** (`bugfix`).
11. **Per-App Gain aus AX bundle id** (`bugfix`).
12. **Gesture-Log JSONL** (`bugfix`).
13. **App-Group group.helios.aegis** Yield/Mutex/Pad einmal.
14. **Detect-Skip leftover matching nur IoU** wenn beide Coast-Vec nil.
15. **Helios palmBind Joint-Group** neben Conf-Tie und Hist-Veto.

Bewusst nicht: Merge `bugfix`, Blind-Patch Schwellen, leftoverSoftmaxBlocks auf Roh.

# Nachtrag 2026-09-06 — 1.5.166 / 2.1.168 (kein Merge von `bugfix`)


Helios `bpms9cmnxc-debug/Helios` **1.5.166** (Build 185).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.168 alpha** (Build 193).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **printBudget |yaw| < 8°.** Frontal → 5° skippt Print. leftoverHold-Zahl vom Frontal-Tick tauft Twin. Δ seit Print fehlte.
2. **livePrintEmpty → leftoverHold-Zahl.** Kein Print-Vec. Twin im Kalman-Kasten erbt 0,85. `v.count ≥ 32` hätte Coast-Vec tot gemacht.
3. **palmBindScaleOf EMA.** Gitarre 0,29 → 0,21. Scale-Max 0,72 = Hand. Conf-Tie sitzt, Hist-Veto fehlte.
4. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL.

## In 1.5.166 / 2.1.168 gelandet

- `leftoverPrintBudgetYawDelta` + `leftoverPrintYawMerge` — Yaw nur nach Print.
- `leftoverCoastPrintSkipCosine` — skipPrints Cache ≥32, ohne Live-Print.
- `printBudgetSkip(yawDelta:)` — |Δ| ≥ 8° → Print. Continuity-Gate bleibt.
- `palmScaleHistVeto` auf Live-Scale — Bind-EMA tot.
- Tests + 1.5.166 / 2.1.168 (Build 185 / 193).

Pass 9: Coast-Vec, Print-Yaw-Δ, Hist-Veto Live — 1.5.166 / 2.1.168.

# Nachtrag 2026-09-06 — 1.5.165 / 2.1.167 (kein Merge von `bugfix`)

Helios `bpms9cmnxc-debug/Helios` **1.5.165** (Build 184).
Aegis `lolalpha00gamma/aegis-scanner` **2.1.167 alpha** (Build 192).
Nur `main`. Agent-Regel: keine Nebenbranches. `bugfix` gelesen, nicht gemergt.

## Warum es schlecht wirkte (dieser Pass)

1. **Name-Hist / Print-Trail / Blink / Still / 1-Euro nur `filter keepBoxes`.** FaceTrack remintete Hold/Yaw. Nach Vision-UUID-Remint blieben Mehrheit, Median-Print, Liveness und Box-Euro auf der Source-UUID — Overlay **Gast** 3 Ticks, Taufe neu.
2. **leftoverCoastCosine nahm live vor Hold.** skipPrints + leerer Print: Rest-Cosine überschrieb leftoverHold. Twin nach Detect-Skip falsch.
3. **printBudget ohne Continuity-Gate.** liveDt-Jitter 16 ms skippte Desk-View-Prints obwohl 8 fps gemeint war.
4. **Task.detached las `liveYaw`.** MainActor-Map im Detached-Task — printBudget-Yaw raste.
5. **palmBindHandsFirst Observation-Order.** Gleiche Scale/Counts: Vision-Reihenfolge, nicht Conf. Gitarre/zweite Hand stiehlt S1.
6. Von `bugfix` (1.5.8 / 2.1.15) bewusst nicht gemergt: IOHID Event-Tap, AX SetPosition/Frame, Per-App-Gain, JSONL, familyBump-only-Best-Paar (längst auf main).

## In 1.5.165 / 2.1.167 gelandet

- **FaceTrack Yaw/Still/EMA/Blink/Lid/Open/Vote.** Pack+RemintDropMaps. LibraryStore verdrahtet.
- **leftoverHoldRemintDrop** auf Name-Hist, Print-Trail, Drift, Score-Ticks, 1-Euro, Landmark, Capture-Hist, Tap-Lock, Mask-Hold, Jump-Pending.
- **leftoverCoastCosine(livePrintEmpty:).** Skip ohne Print nimmt Hold.
- **printBudgetSkip(continuity:).** Continuity nie skip.
- **Yaw-Snapshot vor Task.detached.**
- **palmBindHandsFirst(confs:).** Höhere Vision-Conf vor Observation-Order.
- Tests + MARKETING 1.5.165 / 2.1.167 (Build 184 / 192). Schema 15 bleibt.

## Restlöcher

### Helios

- Frame-Pump XPC fehlt. Zwei DisplayLinks seit 1.5.149.
- Overlay SwiftUI, nicht Metal 90 Hz.
- Scale-Gate 0,28 zittert bei 8 fps. Conf-Tie sitzt, Joint-Group fehlt.
- GestureTests > 180 kB, CoordMath ~200 kB.
- CGEvent-Post statt IOHID (`bugfix`).
- Yield-Pref liegt in Helios-UserDefaults; Aegis hat eigene Keys. Kein App-Group bis CameraBroker.

### Aegis

- FaceTrack remintet Skalare, Store hält die Maps noch parallel — nächster Schritt: ein `[UUID: FaceTrack]` als Source of Truth.
- Kalman-Vel (px/py) nicht im FaceTrack. Coast-Print speichert Trail, nicht den letzten `VNFaceObservation`.
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
Pass 8: FaceTrack Live-Skalare, Name-Hist/Print-Trail/1-Euro remintet, Coast livePrintEmpty, Continuity nie skip, Bind-Conf, Yaw-Snapshot — 1.5.165 / 2.1.167.

## Erweiterungen (zusätzlich, neu oben)

1. **leftoverPrintYaw in FaceTrack.** Extra-Map nach Remint, Print-Budget sonst nach Twin-ID taub.
2. **CI `swiftc` MatchMathTests + GestureTests vor DMG.** Linux-Sandbox hat kein Swift.
3. **LibraryStore `[UUID: FaceTrack]` als Source of Truth.** Skalare reminten. Maps bleiben Schatten — ein Dict, Apply/Decode/Encode einmal.
2. **Coast-Print Vector:** letzten `VNFaceObservation.featurePrint` je Track cachen. Trail remintet, der Vision-Blob nicht.
3. **Kalman-Vel in FaceTrack** (px/py/pw/ph). Sonst Predict nach Remint 0. Vel-Map remintet extra, nicht im Struct.
4. **CameraBroker-XPC:** ein Prozess besitzt AVCapture, IOSurface an Helios und Aegis. Eine TCC. Größter einzelner Effizienzgewinn.
5. **App-Group `group.helios.aegis`:** Yield-Grace, Mutex-Pfad, destEdgePad je Display-UUID einmal. Panel in Helios steuert Aegis ohne Broker.
6. **Two-Phase Mutex INTENT → Yield → CONFIRM** in der Lock-Zeile (Palm-Rect / Face-Rect) bis CameraBroker.
7. **Lock-Zeile Mini-IPC:** Palm-Rect / Face-Rect + Mutex-Chip bis der Broker sitzt.
8. **Detect 8–12 fps, Overlay 60 Hz Metal, Baptize nur Detect-Tick.**
9. **Enrollment-HUD:** 3 Yaw-Slots + Blink bevor Taufe. Blink überlebt Remint, HUD fehlt.
10. **Prefs je camera uniqueID** (Orient, Format, Pad). printBudget Continuity-Gate sitzt, Pref je Cam fehlt.
11. **VNDetectHumanBodyPose** als Prop-Veto. Hand Shape-Prior statt neuer Thresholds.
12. **Gemeinsames CameraMath-Package** (Mutex/Format/Rotation/Yield leben doppelt).
13. **Lokaler Telemetry-Ring 30 s** (fps, ranks, remint, mutex, skip-ratio, claim-dt) + OSLog.
14. **Center Stage force-off nach Sleep** in beiden Clients.
15. **Szenario-Fixtures:** Gitarre+Hand 8 fps, Twin Restart, Helios hält Lock, Aegis weicht live, Auto-Return nach 4 s, Detect-Skip Hold überlebt, skipPrints 24 fps nur bei IoU≥0,92, Yaw 20° druckt, liveYaw überlebt Remint, Name-Hist überlebt Remint, Continuity nie skip, Bind-Conf vor Order, CAS Gen mismatch Aegis tot.
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
27. **maximumHandCount 2 + Joint-Group** statt Observation-first. Conf-Tie sitzt.
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
43. **printBudget je uniqueID:** Continuity-Gate sitzt (nie skip). Pref je Cam (Built-in 30 fps vs 24) fehlt.
44. **FaceTrack Encode in gallery.json extra** — Restart lädt Maps, nicht das Struct.
45. **leftoverLivePrintVec** neben Trail: letzter Roh-Vektor, nicht Median-5. Twin-Coast ehrlich.
46. **stabilizeLiveMatches vor matchLive remint-aware.** Hist sitzt. Vote-Cap nach Remint 1 Tick statt 3 wäre weicher.
47. **OneEuro State in FaceTrack.** boxEuro remintet extra, Struct kennt den Filter nicht.
48. **Vision revision + observation UUID persist** über VNTrackObjectRequest statt eigenes Remint.
49. **Helios Slot-Conf EMA** in PalmSlot — Conf-Tie sitzt pro Tick, Slot hält die schwächere Hand über 1 Frame.
50. **Kill-Switch + Baptize-Mute Datei** testdriven: Helios schreibt, Aegis skippt leftoverPick solange Faust-Lock.

Bewusst nicht: Blind-Patch MatchMath/CoordMath-Schwellen, Merge `bugfix`, leftoverSoftmaxBlocks auf Roh, Kalman-Vel in FaceTrack ohne Test auf der Maschine.
Nächster Code-Schritt: `[UUID: FaceTrack]` als Store oder CameraBroker oder Overlay-Metal.
