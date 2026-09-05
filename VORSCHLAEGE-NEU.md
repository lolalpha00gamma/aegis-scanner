# Nachtrag 2026-09-05 (2.1.124)

Siehe ANALYSE.md. **2.1.124** AssignLive, Capture-Hist Rank-Lookup, Cap Keep.

## In 2.1.124 gelandet

1. leftoverAssignLive — FillX vor DropAmbiguous
2. leftoverCaptureHistLookup Rank + Spatial
3. Capture-Hist Cap Keep + sortierte Keys
4. VERSION = Models = MARKETING_VERSION 2.1.124 (Build 150)

# Nachtrag 2026-09-05 (2.1.123)

Siehe ANALYSE.md. **2.1.123** FillX, Gate Cap 6.

## In 2.1.123 gelandet

1. leftoverHoldXMatch + leftoverAssignFillX in leftoverAssign
2. overlayChipCap 6 in leftoverGateChip
3. VERSION = Models = MARKETING_VERSION 2.1.123 (Build 149)

## Nächste, zusätzlich

- leftoverHashHoldFloor bleibt 0,64 (kein Sharpness im Persist).
- dropoutTTLSticky nicht verdrahten — leftoverHoldTTLOf sitzt.
- leftoverHoldsTrack LOCK halten — JUMP bricht.
- leftoverNameLockHeld persist Schema 7.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- leftoverJumpName VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.106.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK/NBR/FAST/INDOOR/TWIN.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- Rank-3+ Crowd `hash#200+`. Jetzt Twins 0/1 via `#101`.
- leftoverGateChip Cap Pref 4–8.
- leftoverHold UUID-Remint: leftoverHoldXMatch auf leftoverHold-Dictionary.
- FillX-Tie-Pad 0,04: Twins gleiche x nicht raten.

Nur main.

# Nachtrag 2026-09-05 (2.1.122)

Siehe ANALYSE.md. **2.1.122** Twin-Rank Exact `hash#101`, Occupied others live+stored, leftoverLastHash empty-Wipe.

## In 2.1.122 gelandet

1. leftoverHashTwinRanked / leftoverHoldHashTwinKey — Twin L Bare, Twin R hash#101
2. leftoverHoldPut/Trail/Lookup/LastHash den Rank, nicht Spatial boxHash
3. leftoverOccupiedOthers live+stored, live vor stored
4. leftoverLastHashWipes empty, Overlay-Keep hält
5. leftoverRankedHashOf Tick vor Last vor Spatial
6. leftoverHoldHashSpatial — NBR Dist nicht 99
7. VERSION = Models = MARKETING_VERSION 2.1.122 (Build 148)

## Nächste, zusätzlich

- leftoverHold x-order UUID-Match (letzter x der Hold-Trail), stärker als nur L/R.
- Triple-Face HUD `TWIN 1`/`2`/`3` statt nur L/R.
- leftoverLastHash wipe Pref vs Overlay-Keep (0,4–2,0 s empty).
- leftoverLiveHashTick nach Transfer kopieren (newId → old.id), sonst Rank 1 Frame tot.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- leftoverJumpName VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.105.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK/NBR/FAST/INDOOR/TWIN.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- leftoverNameLockHeld persist Schema 7.
- Rank-Keys persist Schema 7, Spatial-Migration beim Load.
- leftoverHashHoldFloor bleibt 0,64 (kein Sharpness im Persist).
- leftoverHoldsTrack LOCK halten — JUMP bricht.

Nur main.

# Nachtrag 2026-09-05 (2.1.121)

Siehe ANALYSE.md. **2.1.121** Capture-Hist/Trail Cap 64, Twin-Gleichstand Occupied, Nachbar-Walk Twin aus.

## In 2.1.121 gelandet

1. leftoverCaptureHistTableCapped/Put 64
2. leftoverHashTrailCapped 64
3. leftoverHashTwinLeft strikt <
4. leftoverHoldNeighborScans — Twin kein Grid
5. VERSION = Models = MARKETING_VERSION 2.1.121 (Build 147)

## Nächste, zusätzlich

- leftoverHashHoldFloor bleibt 0,64 (kein Sharpness im Persist).
- dropoutTTLSticky nicht verdrahten — leftoverHoldTTLOf sitzt.
- leftoverHoldsTrack LOCK halten — JUMP bricht.

# Nachtrag 2026-09-05 (2.1.120)

Siehe ANALYSE.md. **2.1.120** Twin x-order, empty Hash-Wipe, INDOOR/LOCK/Adopt Slider.

## In 2.1.120 gelandet

1. leftoverHashTwinOccupied — Twin L Exact, Twin R Occupied, HUD TWIN L/R
2. leftoverLiveHashTickWipes empty
3. leftoverNameLockArm(sec:) + Slider 0,6–2,0
4. leftoverAdoptNeedSec(lockPref:) + Slider 0,6–1,4
5. leftoverHoldIndoorChip HUD INDOOR 4s
6. VERSION = Models = MARKETING_VERSION 2.1.120 (Build 146)

## Nächste, zusätzlich

- Twin persist `hash#100+rank` damit Twin R auch Exact hat, nicht nur Occupied.
- leftoverHold x-order UUID-Match (letzter x der Hold-Trail), stärker als nur L/R.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- leftoverJumpName VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.104.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK/NBR/FAST/INDOOR/TWIN.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- leftoverNameLockHeld persist Schema 7.

Nur main.

# Nachtrag 2026-09-05 (2.1.119)

Siehe ANALYSE.md. **2.1.119** leftoverHoldTTL Slider, Occupied live diesen Tick.

## In 2.1.119 gelandet

1. leftoverHoldTTLOf + Slider 1,2–4,0 persist. Indoor 4 s
2. leftoverOccupiedMerge stored+live — erster Twin-Frame Exact tot
3. VERSION = Models = MARKETING_VERSION 2.1.119 (Build 145)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref-Slider 0,6–1,4 (Clamp sitzt).
- leftoverNameLockSec Pref-Slider 0,6–2,0 (Clamp sitzt).
- **HUD `INDOOR 4s`** solange leftoverHoldSeenSlow, Slider-Wert daneben.
- leftoverNameLockHeld persist Schema 7.
- leftoverJumpName VoiceOver.
- Twin Hamming-0 geometric split nach x-order, nicht Hash.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.103.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK/NBR/FAST.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- leftoverLiveHashTick auch im found.isEmpty-Zweig wischen.

Nur main.

# Nachtrag 2026-09-05 (2.1.118)

Siehe ANALYSE.md. **2.1.118** Hamming-1 Veto, Exact occupied, Name-Lock Overlay.

## In 2.1.118 gelandet

1. leftoverHoldNeighborOk faces≥2 dist≥1 tot
2. leftoverHashOwnOccupied — Lookup/Trail/Pick Exact-Bin tot
3. leftoverNameLockKeeps / leftoverJumpName Overlay zuerst, leftoverLiveNameAnd held = liveNameLock
4. VERSION = Models = MARKETING_VERSION 2.1.118 (Build 144)

## Nächste, zusätzlich

- **Occupied aus Live-Boxen** diesen Tick, nicht nur leftoverLastHash. Erster Twin-Frame stiehlt noch.
- leftoverAdoptSecLock Pref-Slider 0,6–1,4 (Clamp sitzt).
- leftoverNameLockSec Pref-Slider 0,6–2,0 (Clamp sitzt).
- leftoverHold ttl Slider 1,2–4,0 (Clamp sitzt).
- leftoverNameLockHeld persist Schema 7.
- leftoverJumpName VoiceOver.
- Twin Hamming-0 geometric split nach x-order, nicht Hash.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.102.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.

Nur main.

# Nachtrag 2026-09-05 (2.1.117)

Siehe ANALYSE.md. **2.1.117** leftoverAssignMajority LOCK, leftoverLiveNameAnd hält Overlay, HUD NBR aus Lookup, FAST, LOCK/Adopt Pref-Clamp.

## In 2.1.117 gelandet

1. leftoverAssignMajority locked — Majority tot während LOCK
2. leftoverLiveNameAnd locked+held — Overlay-Name bleibt, Twin tot
3. Hist-Token leer während LOCK
4. leftoverHoldNeighborDist / leftoverHoldHashBare — HUD `NBR` nur Hamming-2
5. leftoverHoldFastChip HUD `FAST`
6. leftoverNameLockSecPref 0,6–2,0 / leftoverAdoptSecLockPref 0,6–1,4
7. VERSION = Models = MARKETING_VERSION 2.1.117 (Build 143)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref-Slider 0,6–1,4 (Clamp sitzt).
- leftoverNameLockSec Pref-Slider 0,6–2,0 (Clamp sitzt).
- leftoverHold ttl Slider 1,2–4,0 (Clamp sitzt).
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.101.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK/NBR/FAST.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- **FAST Chip peak-hold 2 Frames** analog Spark — leftoverGateChip mutiert nicht.
- **leftoverPairCommit nach LOCK nicht sofort 3-Tick** — streak 0 sitzt, UI MAJ fehlt.
- **Hamming-1 Neighbor** stiehlt Twins die eng sitzen. Crowd ≥3: dist 1 tot.
- **leftoverHoldNeighborOk bei 3+ Köpfen** dist≥1 tot, nicht erst dist 2.
- **Familien-Bump nur Best-Paar** (bugfix 2.1.15) Pref: Zweit-Treffer +0,02 tot.
- **Gallery-Prune unenrolled** 14 Tage hinter Pref.
- **Score-EMA α Pref** 0,20–0,50 (bugfix 2.1.15 hart).
- **Live-Name 3-Tick Pref** 2–5 bei 8 fps vs 24 fps.
- RTSP 420f, Player-Pfad bleibt 32BGRA.
- RTSP-Reconnect Exponential-Backoff.

Nur main.

# Nachtrag 2026-09-05 (2.1.116)


Siehe ANALYSE.md. **2.1.116** dropoutSeenSlow Reset, Hamming-2 Neighbor-Veto, Twin-name lock 1,2 s, leftoverHoldTTL Pref.

## In 2.1.116 gelandet

1. dropoutSeenSlow fastFor 8 s nur-24-fps = Sticky tot
2. leftoverHoldNeighborOk faces≥2 dist≥2 tot
3. leftoverNameLockArm 1,2 s nach JUMP, HUD `LOCK`, leftoverHoldsTrack hält
4. leftoverHoldTTLPref 1,2–4,0
5. VERSION = Models = MARKETING_VERSION 2.1.116 (Build 142)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref 0,6–1,4.
- leftoverNameLockSec Pref 0,6–2,0.
- leftoverNameLock auf leftoverPairCommit — Majority darf während LOCK nicht taufen.
- Hamming-2 Veto HUD `NBR`.
- leftoverHoldFastFor Overlay `FAST`.
- leftoverHold ttl Slider 1,2–4,0 (Clamp sitzt).
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.100.
- Overlay VoiceOver HOLD/Spark/HASH/LOCK.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.

Nur main.

# Nachtrag 2026-09-05 (2.1.115)

Siehe ANALYSE.md. **2.1.115** leftoverHoldPut Indoor-TTL 4 s, Transfers-Prune leftoverHoldTTL, Sticky nach fps-Hop.

## In 2.1.115 gelandet

1. leftoverHoldPut / leftoverTrailPut ttl = leftoverHoldTTL
2. Transfers-Prune leftoverHoldTTL, nicht 1,2 s
3. dropoutTTLSticky / dropoutSeenSlow — Hop 8→24 hält 4 s
4. VERSION = Models = MARKETING_VERSION 2.1.115 (Build 141)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref 0,6–1,4.
- Twin-name lock 1,2 s nach JUMP. Chip sitzt.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.99.
- Overlay VoiceOver HOLD/Spark/HASH.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- leftoverHold ttl Pref 1,2–4,0 statt nur Takt.
- Merge-Undo Stack 8.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- **Per-Hold TTL in Schema 7.** `at` + `ttl` je Zeile, nicht Session-Sticky.
- **Hamming-2 Neighbor-Veto** wenn zwei Gesichter live — Twin stiehlt Hash-Nachbar.
- **dropoutSeenSlow Reset** nach 8 s nur-24-fps, nicht Session-ewig.

# Nachtrag 2026-09-05 (2.1.114)

Siehe ANALYSE.md. **2.1.114** Audit-Fixes: Live-Uhr, 2-opt, CI DMG/Entitlements, Resume-Sandbox, TAR, RTSP, Center Stage.

## In 2.1.114 gelandet

1. Live-Stamp Epoch
2. leftoverAssign Snapshot
3. CI kein git add Aegis.dmg, codesign --entitlements
4. Resume Bookmark + Detect-Pfade
5. tar() nil wenn n·FAR < 1, DevTest-Header
6. RTSP Fehler, Center Stage .app
7. leftoverHoldPut nur hash#bin + Cap 64
8. retainAccess, restore Live-Dicts, LazyHStack
9. Tests + VERSION 2.1.114 (Build 140)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref 0,6–1,4.
- Twin-name lock 1,2 s nach JUMP. Chip sitzt.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.98.
- Overlay VoiceOver HOLD/Spark/HASH.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- IdentityDesk 9-Tuple → GalleryPayload direkt. Tuple ist 10 Felder.
- Merge-Undo Stack 8.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.

Nur main.

# Nachtrag 2026-09-05 (2.1.113)

Siehe ANALYSE.md. **2.1.113** Prune-Skip Rebase, Hash-Floor 0,64, Cap 64, Capture-Hist persist, HUD HASH/JPEG/JUMP.

## In 2.1.113 gelandet

1. leftoverHoldPruneSkips — Rebase-Tick kein Prune (Hold + Trail)
2. leftoverHashHoldKeeps 0,64 — Encode/Decode/Put/Prune
3. leftoverHashHoldCapped 64
4. leftoverCaptureHist Table persist Hash-Keyed
5. leftoverHashHoldChip / leftoverJpegChip / leftoverIoUJumpChip
6. leftoverGateChip Overlay peek
7. VERSION = Models = MARKETING_VERSION 2.1.113 (Build 139)

## Nächste, zusätzlich

- leftoverAdoptSecLock Pref 0,6–1,4.
- Twin-name lock 1,2 s nach JUMP. Chip sitzt.
- FaceEngine jpegProbe detached queue. Cache sitzt, Detect hoppt noch nach Main.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.98.
- Overlay VoiceOver HOLD/Spark/HASH.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- Tests splitted.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- IdentityDesk 9-Tuple → GalleryPayload direkt. Tuple ist 10 Felder.
- Merge-Undo Stack 8.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverCaptureHist persist — sitzt (2.1.113).
- leftoverHashHoldChip HUD — sitzt (2.1.113).
- JPEG-Fail HUD — sitzt (2.1.113).
- leftoverHoldByHash Cap 64 — sitzt (2.1.113).
- leftoverHashHold prune cosine < 0,64 — sitzt (2.1.113).
- leftoverIoUJump HUD — sitzt (2.1.113).
- leftoverHoldPrune skip Rebase — sitzt (2.1.113).

Nur main.

# Nachtrag 2026-09-05 (2.1.112)

Siehe ANALYSE.md. **2.1.112** Schema 6 Hash-Hold persist, Rebase, dmg untrack.

## In 2.1.112 gelandet

1. leftoverHashHoldEncode/Decode + Trail — Schema 6
2. leftoverHashHoldRebase erstes Live-Tick
3. leftoverCaptureHistEncode Math
4. Aegis.dmg untrack + gitignore
5. VERSION = Models = MARKETING_VERSION 2.1.112 (Build 138)

## Nächste, zusätzlich

- leftoverCaptureHist persist Schema 6. Math sitzt, File fehlt.
- leftoverHashHoldChip HUD `HASH 0,80`.
- JPEG-Fail HUD `JPEG` wenn Probe nil bei Print.
- leftoverHoldByHash Cap 64.
- leftoverHashHold prune cosine < 0,64.
- IdentityDesk 9-Tuple → GalleryPayload direkt.
- Merge-Undo Stack 8.
- leftoverIoUJump HUD `JUMP`.
- FaceEngine jpegProbe detached queue.
- Twin-name lock 1,2 s nach JUMP.
- PhotoKit Live Photos Frame 0, nicht Poster.
- printRevision je Identity.
- leftoverHoldPrune skip denselben Tick wie Rebase.
- gallery.json.bak rotate 3.
- VNDetectFaceRectangles revision pin.
- leftoverHashHold VoiceOver.
- Schema 5 UUID-Bins nach Schema 6 behalten (kein Wipe).

# Nachtrag 2026-09-05 (2.1.111)


**2.1.111** CI: ¾ Hash-Bin Trail. leftoverTrailWriteOk ohne Yaw-Block seit 2.1.104 — Test war 2.1.88.

# Nachtrag 2026-09-05 (2.1.110)

Siehe ANALYSE.md. **2.1.110** JPEG required, Probe-Cache 0,80 s Hash/Cosine, Miss −1, Timer .common, Gate required.

## In 2.1.110 gelandet

1. leftoverBaptizeJpegOk required — Print ohne Probe keine Taufe
2. leftoverJpegProbeReuse 0,80 s — Hash- oder Cosine-Sprung tot
3. leftoverJpegProbePut Miss −1 — Crop-Fail nicht jede Frame
4. leftoverTransfersId jpegRequired — Gate denselben Schalter
5. LiveCapture Timer .common
6. VERSION = Models = MARKETING_VERSION 2.1.110 (Build 136)

## Offen (nicht Pflaster)

- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.94.
- FaceEngine auf outputQueue, nicht Main. JPEG-Cache sitzt (2.1.110), Detect hoppt noch nach Main für leftoverTransfersId Cosine — Probe selbst cached.
- RTSP 420f, Player-Pfad bleibt 32BGRA.
- Overlay VoiceOver HOLD/Spark.
- Per-Box CLAHE statt Full-Frame.
- leftoverAdoptSecLock Pref 0,6–1,4.
- Continuity Desk-View yaw-floor 0,36.
- Gallery print decay: ungenutzte 14-Tage-Prints downweight.
- Partial-Print P-Slot ohne Augen (Schal/Maske).
- Burst-AE 5-Frame Pref Continuity-Nacht.
- Print-Bank 5 Pose-Slots front/left/right/up/down.
- DBSCAN vor Merge.
- Watch-Folder PhotoKit.
- Encrypted gallery export `.aegis`.
- Iris-Textur-Slot als Twin-Veto.
- Specular-Highlight auf Stirn als Card-Photo-Veto.
- Continuity LiDAR-Z als Twin-Trennung.
- Masken-/Schal-Slot. Brille-Slot.
- RTSP-Reconnect Exponential-Backoff.
- Tests splitted.
- Aegis.dmg nicht ins Git — Untrack 2.1.112.
- Temporal ReID-Graph über Hold-Trail.
- PnP 6DoF, Slot folgt der Nase.
- leftoverBaptizeJpegOk required — sitzt (2.1.110).
- leftoverJpegProbeReuse Hash/Cosine / Miss −1 — sitzt (2.1.110).
- Timer .common — sitzt (2.1.110).
- leftoverBaptizeGate jpegRequired — sitzt (2.1.110).
- ** Overlay-Chip `JPEG` wenn Probe drop > 0,06.**
- ** FaceEngine.jpegProbeDelta in Task.detached neben Detect, nicht Main.**
- ** leftoverJpegProbeReuse TTL Pref 0,25–1,2.**

Nur main.


# Nachtrag 2026-09-05 (2.1.109)

Siehe ANALYSE.md. **2.1.109** JPEG-Probe, Schema 5 Hold-Bins, IoU-Jump, Per-Bin Adopt, 0° Orient. 2.1.108: Spark-Peek, PickLuma, BaptizeGate.

## In 2.1.109 gelandet

1. FaceEngine.jpegProbeDelta — JPEG 70 % Reextract in leftoverTransfersId
2. gallery.json Schema 5 leftoverHoldBins + leftoverHoldTrailBins persist
3. leftoverIoUJumpBlocks 0,40 — Box-Steal keine Taufe
4. leftoverAdoptNeedSec(dt:yawAbs:) — ¾ 1,2 s, frontal 0,80 s
5. liveBufferOrientation — 0° Capture .up
6. VERSION = Models = MARKETING_VERSION 2.1.109 (Build 135)

## In 2.1.108 gelandet

1. leftoverSparkChip peek — Tick in stabilizeLiveMatches, Body mutiert nicht
2. leftoverPickLuma in leftoverSessionCapturePrefersFrame + applyLiveFaces
3. leftoverBaptizeGate in leftoverTransfersId + leftoverBaptizeJpegOk
4. leftoverBlinkLiveness open-streak — 2 Lider offen vor Taufe
5. leftoverLiveNameAnd Mehrheit UND 3-Tick
6. leftoverScoreTickOverlay 3-Tick, sonst EMA
7. liveMinIntervalThermal FrameTap Floor 8 fps
8. setFacesPresent leftoverStreak Lock
9. VERSION = Models = MARKETING_VERSION 2.1.108 (Build 134)

## In 2.1.107 gelandet

1. leftoverSparkTrailOf / leftoverLastHashKeeps — Hash überlebt UUID-Steal
2. leftoverSparkChipHold verdrahtet overlayChipPeakHold
3. leftoverBaptizeGate / leftoverPickLuma / videoStabilizationApplies
4. VERSION = Models = MARKETING_VERSION 2.1.107 (Build 133)

## In 2.1.106 gelandet

1. leftoverAdoptNeedSec 15/24 = 0,80 s, 8 fps 1,2 s
2. liveMinInterval Hunt 10, streak ≥ 1 Lock
3. overlayChipPeakHold 2 Frames
4. leftoverBaptizeJpeg + leftoverBlinkLiveness
5. liveThermalHolds + reconnectCenterStageOff
6. VERSION = Models = MARKETING_VERSION 2.1.106 (Build 132)

## In 2.1.105 gelandet

1. leftoverHoldTrailBins + leftoverCosineSparkLabelOf — Spark ¾ nicht leer
2. leftoverHoldOverlayChipOf binTrail — HOLD roh aus Pose-Bin
3. leftoverBaptizeQuality Blur/Blink/Profil
4. leftoverScoreTickPut / leftoverLiveNameHolds Math aus bugfix 2.1.15
5. VERSION = Models = MARKETING_VERSION 2.1.105 (Build 131)

## In 2.1.104 gelandet

1. liveMinInterval Hunt 8/10, Lock 12/15 — nicht mehr 5/8
2. physicalCaptureRotation aus, Portrait `.right`
3. leftoverTrailWriteOk ohne Yaw-Block — ¾-Trail schreibt Hash-Bin
4. leftoverHoldTrail[id] nur frontal — Spark ¾ kein UUID-Mix
5. leftoverHoldOverlayChipOf bleibt ¾-Chip (Bin-Hold)
6. captureFormatScore 4:3, reselectFormat CS+Format zweimal
7. VERSION = Models = MARKETING_VERSION 2.1.104 (Build 130)

## In 2.1.103 gelandet

1. `availableVideoPixelFormatTypes` statt ObjC-CV-Infix — xcodebuild 2.1.101/102 tot
2. Parameter `videoOut`, nicht `output` (AVPlayerItemVideoOutput)
3. VERSION = Models = MARKETING_VERSION 2.1.103 (Build 129)

## In 2.1.102 gelandet

1. leftoverBaptizeBoth roh UND smooth — nil Smooth keine Taufe
2. leftoverHoldOverlayChipOf — ¾ Chip ohne Frontal-Trail
3. leftoverTrailNowOf — Transfer-Trail ¾ = Hash-Bin
4. leftoverNameFromHold — ¾ ohne Bin kein Frontal-Name
5. leftoverHasHold / overlayName
6. VERSION = Models = MARKETING_VERSION 2.1.102 (Build 128)

## In 2.1.101 gelandet

1. leftoverHoldChip compact HOLD 80/64, ¾-Trail nicht UUID-Mix
2. leftoverScoreHeatMid Nacht 0,60, leftoverSoftmaxFloorOf 0,47
3. Center Stage aus vor Format, Continuity Preset aus, lock 24
4. SHARP + BAND Chips, 420v Sharp-Lift, 422 vor BGRA
5. VERSION = Models = MARKETING_VERSION 2.1.101 (Build 127)

## Offen (nicht Pflaster)

6. Helios Frame-Pump, eine TCC
7. Brille-Slot
9. CLAHE auf den Buffer, nicht nur Banner
12. Drop-in .mlmodel
14. DBSCAN vor Merge
15. VoiceOver spricht den Namen
16. Watch-Folder PhotoKit
19. PnP 6DoF, Slot folgt der Nase
22. Encrypted gallery export `.aegis`
26. Temporal ReID-Graph über Hold-Trail
28. Partial-Print für Profil (P-Slot ohne Augen)
30. Burst-AE 5-Frame-Fenster Pref für Continuity-Nacht
41. Temporal print bank (5 Slots) Pose-Keys
43. Aegis.dmg nicht ins Git — nur CI-Artefakt
45. Masken-/Schal-Slot
46. RTSP-Reconnect Exponential-Backoff
59. Shared AVCaptureSession via XPC mit Helios
61. Print-Bank 5 Pose-Slots (front/left/right/up/down) gewichtet
72. JPEG-Recompress-Probe vor Taufe
77. Blink-Liveness. Lid-Gap 2 Frames
84. Iris-Textur-Slot als Twin-Veto
103. Specular-Highlight auf Stirn als Card-Photo-Veto
107. Continuity LiDAR-Z als Twin-Trennung
109. gallery.json printRevision
110. Per-Box CLAHE nur auf Face-ROI
115. Blink 2-Frame Lid-Gap vor Taufe — Poster
116. JPEG 70 % Probe vor leftoverBaptize
119. Capture-Hist 8 in gallery.json Schema 5
121. leftoverHold hash# bins persist
124. Yaw-binned Print-Bank 5 Slots
137. leftoverHoldBins persist App-Neustart
139. Tests splitted
147. Aegis.dmg nicht ins Git
148. Shared AVCaptureSession XPC mit Helios
152. CIImage createCGImage Farbe 420v messen
158. FaceEngine capture an leftoverPick wenn Frame-Luma nil
159. RTSP 420f analog LiveCapture
- liveMinInterval 8–15 — sitzt.
- physicalCaptureRotation aus — sitzt.
- leftoverTrailWriteOk ohne Yaw — sitzt.
- leftoverHoldTrail[id] frontal — sitzt.
- leftoverSparkChip ¾ leer — sitzt.
- leftoverHoldOverlayChipOf — sitzt.
- leftoverBaptizeBoth ohne ?? raw — sitzt.
- leftoverTrailNowOf — sitzt.
- leftoverNameFromHold — sitzt.
- captureFormatScore 4:3 — sitzt.
- reselectFormat CS zweimal — sitzt.
- leftoverHoldChip compact — sitzt.
- leftoverScoreHeatMid Nacht — sitzt.
- leftoverSoftmaxFloorOf — sitzt.
- Center Stage aus — sitzt.
- Continuity Preset aus — sitzt.
- captureLockFrameRate continuity 24 — sitzt.
- SHARP Chip — sitzt.
- BAND Chip — sitzt.
- 420v Sharp-Lift — sitzt.
- availableVideoPixelFormatTypes — sitzt.

Neu:

- ** leftoverHoldBins persist** Schema 5. — sitzt (2.1.109).
- ** FaceEngine JPEG-Print cosine-drop** nach 70 % Recompress — sitzt Probe (2.1.109).
- ** IoU-Sprung 0,40 Taufe-Veto** analog Helios grabAbortHold. — sitzt (2.1.109).
- ** Per-Bin leftoverAdoptNeedSec** (¾ 1,2 s, frontal 0,80). — sitzt (2.1.109).
- ** Shared XPC mit Helios 1.5.93** eine TCC, ein Buffer, dieselbe 0°-Geometrie.
- ** FaceEngine auf outputQueue**, nicht Main. Detect ist detached; CGImage hoppt noch über Main.
- ** RTSP 420f**, Player-Pfad bleibt 32BGRA.
- ** Overlay VoiceOver HOLD roh/smooth** „gehalten null acht null“.
- ** Per-Box CLAHE** statt Full-Frame.
- ** leftoverAdoptSecLock Pref 0,6–1,4.**
- ** Continuity Desk-View yaw-floor 0,36** analog leftoverPrintProfileYaw.
- ** Gallery print decay:** ungenutzte 14-Tage-Prints downweight.
- ** Partial-Print P-Slot** ohne Augen für Schal/Maske.
- ** Burst-AE 5-Frame Pref** Continuity-Nacht.
- ** Print-Bank 5 Pose-Slots** front/left/right/up/down gewichtet.
- ** DBSCAN vor Merge.**
- ** Watch-Folder PhotoKit.**
- ** Encrypted gallery export `.aegis`.**
- ** Iris-Textur-Slot als Twin-Veto.**
- ** Specular-Highlight auf Stirn als Card-Photo-Veto.**
- ** Continuity LiDAR-Z als Twin-Trennung.**
- ** Masken-/Schal-Slot.**
- ** RTSP-Reconnect Exponential-Backoff.**
- ** Tests splitted.**
- ** Aegis.dmg nicht ins Git** — nur CI-Artefakt.
- ** Overlay VoiceOver Spark** „null acht null nach null acht zwei“.
- ** Brille-Slot.**
- ** Temporal ReID-Graph über Hold-Trail.**
- ** PnP 6DoF, Slot folgt der Nase.**
- ** leftoverAdopt Lock 0,80 s** — sitzt (2.1.106). 15/24 fps 12 Frames.
- ** Hunt 10 fps bis leftoverStreak ≥ 1** — sitzt setFacesPresent(streak:) (2.1.108).
- ** FaceEngine auf outputQueue**, nicht Main. 15 fps auf Main kann UI-Jank.
- ** RTSP 420f**, Player-Pfad bleibt 32BGRA.
- ** Shared XPC mit Helios 1.5.92** eine TCC, ein Buffer, dieselbe 0°-Geometrie.
- ** Overlay VoiceOver HOLD roh/smooth** „gehalten null acht null“.
- ** JPEG 70 % + Blink 2-Frame** — Math sitzt (2.1.106). Gate verdrahtet (2.1.108). FaceEngine Print-Reextract nach JPEG fehlt.
- ** gallery.json Schema 5 Capture-Hist + Hold-Bins** über App-Neustart. leftoverHoldTrailBins stirbt mit dem Prozess.
- ** Per-Box CLAHE** statt Full-Frame.
- leftoverScoreTickPut / leftoverLiveNameHolds — Overlay 3-Tick-AND sitzt (2.1.108).
- ** liveMinInterval thermal** — sitzt FrameTap (2.1.108).
- ** Center Stage nach Continuity-Reconnect** — sitzt (2.1.106) in setFacesPresent.
- ** leftoverSparkChip peak-hold 2 Frames** — Tick sitzt (2.1.108). Body mutiert nicht.
- ** FaceEngine capture an leftoverPick** — sitzt (2.1.108). Indoor 420v Frame vor Box.
- leftoverAdopt bleibt Taufe-Pfad. 0,80/1,2 s sitzt (2.1.106). leftoverTransfersId leftoverBaptizeGate sitzt (2.1.108).
- VideoStabilization aus — Math sitzt, macOS-API fehlt.
- leftoverBaptize Qualitätstor — sitzt (2.1.105). Gate+JPEG sitzt (2.1.108).
- leftoverHoldOverlayChipOf Bin-Trail roh — sitzt (2.1.105).
- leftoverCosineSparkLabelOf — sitzt (2.1.105).
- ** leftoverAdoptSecLock Pref 0,6–1,4.**
- ** Track-ID Hysterese:** IoU-Sprung > 0,4 keine Taufe (Box-Steal).
- ** Continuity Desk-View yaw-floor 0,36** analog leftoverPrintProfileYaw.
- ** Per-Bin leftoverAdoptNeedSec** (¾ 1,2 s, frontal 0,80).
- ** Gallery print decay:** ungenutzte 14-Tage-Prints downweight.
- ** Overlay Spark peak-hold im Tick verdrahten** — sitzt (2.1.108).
- ** FaceEngine JPEG-Print cosine-drop** nach 70 % Recompress — Gate sitzt, Probe fehlt.
- ** IoU-Sprung 0,40 Taufe-Veto** analog Helios grabAbortHold.
- ** leftoverHoldBins persist** Schema 5.
- ** RTSP 420f analog LiveCapture** Player-Pfad 32BGRA.
- ** Partial-Print P-Slot** ohne Augen für Schal/Maske.
- ** Overlay VoiceOver Spark** „null acht null nach null acht zwei“.
- ** Burst-AE 5-Frame Pref** Continuity-Nacht.
- ** Print-Bank 5 Pose-Slots** front/left/right/up/down gewichtet.
- ** DBSCAN vor Merge.**
- ** Watch-Folder PhotoKit.**
- ** Encrypted gallery export `.aegis`.**

Nur main.
