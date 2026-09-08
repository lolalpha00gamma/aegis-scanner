# Nachtrag Grok 2026-09-08 — 2.1.199 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.199 (Build 224) auf 2.1.198 (Merge überschrieb Print-Yaw, Recency-EMA Glücks-Frame). Helios 1.6.37.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.198 weiter riss

1. leftoverPrintYawMerge kopierte Live-Yaw für jeden mit printVec, sobald irgendwer druckte. Ada-Δ 0, SameBin immer true.
2. leftoverPrintEma α 0,45 — letzter Frame 45 %, Median-Glück nur verschoben.
3. LibraryStore printedIds = adopted.filter printVec, nicht Commit.
4. Helios Continuity 8 fps (bestFormat fps≥24), PinchGate 2D, Lift-Sign kippte, HUD ohne q.

## In 2.1.199 / 1.6.37 gelandet

- leftoverPrintYawMerge hält committed. Nur fehlende IDs.
- leftoverPrintYawStamp nach Commit. Store printedIds leer.
- leftoverPrintEma Gleichgewicht 1/n.
- Helios cameraFormatScore, pinch3DTrusts, liftSignHolds, pinchRatioSmooth, qualityChip, Tastatur-Ring.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu)

1. CameraBroker Shared Memory statt flock/90 Hz.
2. FaceTrack Debug-Dump eine Map JSON.
3. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
4. Licht-Eimer (frontal / ¾ / Profil) statt einem Cosine.
5. Match-Log JSONL für Replay.
6. Drop-in `.mlmodel` FaceEmbedder-Protokoll.
7. Overlay-Metal 90 Hz unabhängig von 8 fps Detect.
8. leftoverPrintTrail nur Live-next, old-Print als Ankergewicht.
9. Tests splitten (MatchMathTests > 200 kB). Swift Testing.
10. Helios liest leftover-Boxen als Palm-Occlusion. Aegis-Yaw als Click-Lock.
11. PrintQuality als Hungarian-Gewicht (unscharf 0,22 drückt Cost).
12. leftoverPrintYaw in gallery.json persist — Restart sonst SameBin tot.
13. Detect-Interval ≠ Print-Interval. 8 fps Detect, Print nur nach Still.
14. Twin-Bin ¾L vs ¾R (signed yaw, nicht nur |yaw|).
15. Overlay identity-Lerp unabhängig von Assign.
16. Blink-Liveness auf Assign, nicht nur Enroll.
17. gallery ANN (HNSW) ab n>50.
18. CVPixelBuffer bis Detect, kein CGImage-Hop.
19. Name-Lock nur nach Blink + 3 Frames gleicher ID.
20. P-Slot Maske/Schal, Brille-Slot als Twin-Veto.

# Nachtrag Grok 2026-09-08 — 2.1.198 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.198 (Build 223) auf 2.1.197 (signed Hold-Bin, Hist in Frames, Median-Glück, Peak-Need tot). Helios 1.6.36.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.197 weiter riss

1. leftoverHoldBin ohne abs. SameBin war |yaw|, Hold-EMA schrieb −Profil in Bin 0.
2. nameHistCap 5 Frames. Continuity 8 fps = 0,62 s, Familien-Need 0,80 s hungert.
3. Gallery-Print Median/blendEmbeddings — ein Glücks-Frame überschreibt.
4. leftoverPeakHoldNeed existierte in keinem Call. Overlay „?“ nach Remint 3 Frames bei 24 fps = 125 ms Flicker.

## In 2.1.198 / 1.6.36 gelandet

- leftoverHoldBin abs intern.
- nameHistCap(need, dt) Sekunden, Cap 24.
- leftoverPrintEma / leftoverPrintBlend ≥ 3.
- leftoverPeakHoldNeed in Advance + IoUAdopt.
- Helios pinch3DApproach, pinchActor z, PalmJump, pullTowardPalmGrow, fistScharfGrace.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu)

1. CameraBroker Shared Memory statt flock/90 Hz.
2. FaceTrack Debug-Dump eine Map JSON.
3. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
4. Licht-Eimer (frontal / ¾ / Profil) statt einem Cosine.
5. Match-Log JSONL für Replay.
6. Drop-in `.mlmodel` FaceEmbedder-Protokoll.
7. Overlay-Metal 90 Hz unabhängig von 8 fps Detect.
8. leftoverPrintTrail nur Live-next, old-Print als Ankergewicht.
9. Tests splitten (MatchMathTests > 200 kB). Swift Testing.
10. Helios liest leftover-Boxen als Palm-Occlusion. Aegis-Yaw als Click-Lock.

# Nachtrag Grok 2026-09-08 — 2.1.197 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.197 (Build 222) auf 2.1.196 (PrintOk nillte 0,64 → x-Fill stahl UUID). Helios 1.6.35.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.196 weiter riss

1. leftoverAssignPrintOk nillte schwache Cosine. leftoverAssignLive x-Fill las `nil` als Remint — Ada UUID an den Nachbarn, Taufe 0,64 über x.
2. leftoverPrintYaw nil → Live-Yaw. leftoverPrintSameBin immer true → Diversity-Skip beim ersten Print.
3. leftoverAssignPrintSteals blieb leftoverPrintOk 0,64.
4. HungarianX Cost-Pad+1 für verbotene Paare — Recursion maximiert nAss, assignet trotzdem.
5. Helios pinchStartsGrab ignorierte Landmark-q. Freeze-Geist stand. Ampel-Ring 6 px bei 8 fps.

## In 2.1.197 / 1.6.35 gelandet

- leftoverAssignPrintCell: Taufe Cosine, gemessen `0`, ungemessen `nil`.
- leftoverAssignXFillAllows / leftoverAssignHungarianXPairOk / DropForbidden.
- leftoverAssignPrintRank 2-opt/3-Zyklus.
- leftoverPrintSameBin Optional, LibraryStore ohne Live-Fallback.
- leftoverAssignPrintSteals über leftoverAssignPrintOk.
- Helios pinchClosednessNeed(quality), freezePalmPredict, chromeDwellRingWidth(dt).

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map (`isCanonical()` ist true, LibraryStore hält ~20 Dicts).
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu, oben)

1. **FaceTrack `[UUID: FaceTrack]` einzige leftover-Map.** Predict/Coast/Hold/Print/Yaw in einer Struct. Dict-Desync tot.
2. **CameraBroker XPC + IOSurface.** Eine TCC, eine Session, Aegis+Helios lesen.
3. **Blink-Liveness auf Assign**, nicht nur Enroll. leftoverAssignPrintOk + Blink-Streak 2.
4. **Licht-Eimer je Pose-Bin** (frontal / ¾ / Profil) statt einem Cosine-Floor.
5. **Platt-Temperatur Cosine** je Bin — 0,80 hart tauft im ¾ falsch, frontal zu streng.
6. **gallery ANN** (HNSW) ab n>50. Linear Cosine skaliert nicht.
7. **Match-Log JSONL** (PTS, UUID, cosine, yaw, bin, assign-path) für Replay.
8. **Drop-in `.mlmodel` FaceEmbedder-Protokoll** neben VNGenerateFacePrint.
9. **Overlay CAMetalLayer 90 Hz**, Detect 8–24 fps. Box-Lerp unabhängig.
10. **leftoverPrintYaw nur bei Commit stempeln**, nicht leftoverPrintYawMerge jedes Live-Yaw.
11. **PrintQuality als Hungarian-Gewicht** (nicht nur 0/Cosine). Unscharf 0,22 drückt Cost.
12. **DisplayLink 90 Hz HUD** (Helios), Kamera bleibt 8–24 fps.
13. **HeliosAegisKit** gemeinsamer CameraBroker + Mutex-PTS.
14. **LiDAR-Pinch** (Depth) statt nur Landmark-z.
15. **IOHID Event-Tap / AX SetPosition / Per-App Gain** (`bugfix`, opt-in).
16. **CVPixelBuffer bis Detect**, kein CGImage-Hop.
17. **VNTrackObjectRequest** neben Rectangles.
18. **Swift Testing** statt DIY `ok()`. MatchMathTests splitten.
19. **Name-Lock nur nach Blink + 3 Frames** gleicher ID.
20. **P-Slot Maske/Schal, Brille-Slot** als Twin-Veto.

# Nachtrag Grok 2026-09-07 — 2.1.196 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.196 (Build 221) auf 2.1.195 (Assign 0,64 tauft, Twin-Detect, Print-Burst). Helios 1.6.34.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.195 weiter riss

1. leftoverAssignLive nutzte leftoverPrintOk 0,64. Overlay-Hold tauft UUIDs — Ada wird der Nachbar.
2. Twin-Detect zwei Boxen, gleiche Pose, Overlap. Hungarian gibt zwei Exact.
3. Print-Burst Cosine 0,98 gleicher Pose-Bin füllt gallery.json mit Duplikaten.
4. leftoverPrintYaw signed → leftoverHoldBin(−0,50) = frontal.

## In 2.1.196 / 1.6.34 gelandet

- leftoverAssignPrintOk = leftoverBaptize + leftoverBaptizeQuality.
- leftoverAssignTwinYawCull vor leftoverAssignLive.
- leftoverPrintDiversitySkip. leftoverPrintSameBin |yaw|.
- Helios chromeDwellNeed/StillNeed, pinch3DVeto, HMM qualityScale, freezeLive, fpsSparkBars, Achse H/V.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.
P2 VNTrackObjectRequest. Replay 20 s. HeliosAegisKit.

## Erweiterung (neu)

1. CameraBroker Shared Memory statt flock/90 Hz.
2. FaceTrack Debug-Dump eine Map JSON.
3. Pose-Meter ¾L/¾R getrennt, nicht ein ¾.
4. Print-Diversity — 2.1.196 Skip 0,98. Rest: Licht-Eimer je Bin.
5. Name-Lock nur nach Blink + 3 Frames gleicher ID.
6. Twin-Veto — 2.1.196 |Δyaw| < 8°. Rest: P-Slot Maske/Schal.
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
18. Schema 15 bleibt — leftoverBlinkByIdentity ist Runtime.
19. CVPixelBuffer bis Detect, kein CGImage-Hop.
20. Swift Testing statt DIY `ok()`.
21. Faceprint EMA 3 Frames vor Gallery-Commit.
22. Overlay Peak-Hold 3 Frames nach Remint (identity row bleibt).
23. Detect-Queue 1 in-flight + 1 pending, drop-oldest mit PTS.
24. CameraBroker IOSurface — ein Capture, zwei Subscriber (Helios+Aegis).
25. liveNameLock nur owner, nie near-match (Coach 2.1.195 schon so).
26. leftoverBlinkByIdentity nicht persistieren — Schema 15 bleibt.
27. HeliosAegisKit Shared Package.
28. Session-Replay 20 s Ringpuffer, JSONL Export.
29. FaceTrack als einzige Map — leftoverHold/Coast/PrintYaw sterben.
30. Overlay-Metal 60 Hz, Detect bleibt 8–24.

## Bugfix-Skill

Pass 1: Assign 0,64 tauft, Twin-Detect, Print-Burst, signed Yaw-Bin.
Pass 2: 2.1.196 / 1.6.34 auf main.
Pass 3: CI muss failen dürfen. Assign 0,64 tot, Twin-Cull, Diversity 0,98, SameBin |yaw|.

# Nachtrag Grok 2026-09-07 — 2.1.195 gelandet, Rest offen

Quelle: Review + Fix Aegis 2.1.195 (Build 220) auf 2.1.194 (Blink Detect-UUID, Twin Overlay Detect). Helios 1.5.196.
Kein Binary-Lauf (Linux-Sandbox). Tests in CI. `bugfix` nicht gemergt. Nur `main`.

## Warum es nach 2.1.194 weiter riss

1. leftoverBlinkSeen nur liveBlinkSeen[detectId]. Remint = Coach „einmal blinzeln“ trotz Ada-Blink.
2. leftoverOverlayRowId Twin-Fallback Detect-UUID. Unmatched Remint unmountet die zweite Box.
3. FrameTap pending konvertierte CGImage obwohl Detect < 80 ms noch läuft — 8 fps extra CPU.
4. DidWake ohne liveRoiSkipOnce. Interior-ROI nach Sleep tot.
5. Box-Hash als Blink-Key hätte Ada-Blink auf neuen Enroll in derselben Box geleakt.

## In 2.1.195 / 1.5.196 gelandet

- leftoverBlinkSeenOf Detect + Identity. Hash nie für Liveness. leftoverStampBlink Name-Lock.
- leftoverOverlayBoxHash Twin- und unmatched-ForEach. Detect nur letzter Fallback.
- liveFrameTapSkipsCGImage busy < 80 ms. DidWake liveRoiSkipOnce.
- Coach identityId nur owner. leftoverBlinkByIdentity prune merge/delete.
- Helios Sleep-Fill, 300 ms Mute, PINCH an der Hand.

## Offen (nicht noch ein Slider)

P0 CameraBroker IOSurface. FaceTrack einzige Store-Map.
P1 Overlay-Metal. LiveCapture nicht @MainActor.
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
18. Schema 15 bleibt — leftoverBlinkByIdentity ist Runtime.
19. CVPixelBuffer bis Detect, kein CGImage-Hop.
20. Swift Testing statt DIY `ok()`.
21. Faceprint EMA 3 Frames vor Gallery-Commit.
22. Overlay Peak-Hold 3 Frames nach Remint (identity row bleibt).
23. Detect-Queue 1 in-flight + 1 pending, drop-oldest mit PTS.
24. CameraBroker IOSurface — ein Capture, zwei Subscriber (Helios+Aegis).
25. liveNameLock nur owner, nie near-match (Coach 2.1.195 schon so).
26. leftoverBlinkByIdentity nicht persistieren — Schema 15 bleibt.

## Bugfix-Skill

Pass 1: Blink Detect-UUID, Twin Detect-ForEach, FrameTap CGImage, Wake ROI.
Pass 2: 2.1.195 / 1.5.196 auf main.
Pass 3: CI muss failen dürfen. Blink identity, Box-Hash Twin, Skip < 80 ms.

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
