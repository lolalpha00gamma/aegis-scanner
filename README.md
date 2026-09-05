# Aegis **2.1.128 alpha**

Direkt laden:
- [Aegis.dmg (Latest)](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)
- [Releases](https://github.com/lolalpha00gamma/aegis-scanner/releases)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [Aegis.dmg](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI auf **macos-26** baut das Image nach jedem Push auf `main`.

## Neu in 2.1.128 alpha

Print vor x nach Restart tauft den Twin. leftoverHold tot auf neuer UUID. Bins/LOCK/JPEG bleiben auf old.

- **`leftoverAssignRemint` vor Print.** leftoverAssignLive stiehlt keine x-Spalte.
- **`leftoverHoldRemint`.** stored nur Hold-Keys, Ghosts ∪ StreakBox.
- **`leftoverHoldRemintBins`.** NameLock, Pending, JPEG, Hash nach Survive.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.128 (Build 154).

## Neu in 2.1.127 alpha


HoldX Spread tötete den eindeutig näheren Hold. FillX ohne Spread tauft Twin-Mitte.

- **`leftoverXAmbiguous`.** Relativ 2·d, nicht d2−d ≤ 0,08.
- **`leftoverAssignFillX` Spread** analog HoldX. Twin-Mitte tot, 0,02 vs 0,08 bleibt.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.127 (Build 153).

## Neu in 2.1.126 alpha

FillX Hold-Index stahl den näheren Twin. HoldX ohne Occupied. Gate-Chips sprangen nach vorn.

- **`leftoverAssignFillX` Dist-greedy.** Nächster Hold, nicht Zeile 0.
- **`leftoverHoldXMatch(occupied:spread:)`.** Occupied skip, Twin-Mitte tot.
- **`overlayChipCap` Original-Lage.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.126 (Build 152).

## Neu in 2.1.125 alpha

FillX tauft Far nach Restart. Gate prefix droppt TWIN/NBR. Drei Gesichter beide TWIN R.

- **`leftoverFillXPad` 0,12.** leftoverHoldXMatch + leftoverAssignFillX. Far tot. AssignLive erbt das.
- **`overlayChipKeep`.** JUMP/LOCK/TWIN/NBR zuerst, unique.
- **`leftoverHashTwinChip`.** Crowd `TWIN 1/2/3`, Zwei-Gesicht L/R.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.125 (Build 151).

## Neu in 2.1.124 alpha

Audit 53–55: FillX nach DropAmbiguous hob das Twin-Veto. Capture-Hist Rank vs Spatial. Cap ohne Reihenfolge.

- **`leftoverAssignLive`.** Print-Assign, x-Fill nur leere Zeilen, Twin-Spread danach.
- **`leftoverCaptureHistLookup`.** Rank-Key, Spatial-Fallback.
- **Capture-Hist Cap:** Keep zuerst, Rest sortiert. Persist Keep leftoverLastHash.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.124 (Build 150).

## Neu in 2.1.123 alpha

Direkt laden:
- [Aegis.dmg (Latest)](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)
- [Releases](https://github.com/lolalpha00gamma/aegis-scanner/releases)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [Aegis.dmg](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI auf **macos-26** baut das Image nach jedem Push auf `main`.

## Neu in 2.1.123 alpha

leftoverAssign Print tot nach Restart. Gate-Chips unbegrenzt.

- **leftoverHoldXMatch + leftoverAssignFillX.** Nil-Zeilen nach x, Print-Assign bleibt.
- **Gate Chip Cap 6.** HASH/LOCK/NBR/FAST/INDOOR/TWIN sonst Overlay tot.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.123 (Build 149).

## Neu in 2.1.122 alpha

Twin R blieb Occupied (gleicher Spatial-Hash). leftoverOccupied others nur Live-Tick. leftoverLastHash nach empty tot.

- **`leftoverHashTwinRanked`.** Twin L Bare, Twin R `hash#101`. leftoverHoldPut/Trail/Lookup den Rank.
- **`leftoverOccupiedOthers`.** live+stored, live vor stored.
- **`leftoverLastHashWipes`.** empty → Last leer. **`leftoverRankedHashOf`.** Tick vor Last.
- **`leftoverHoldHashSpatial`.** NBR Dist nicht 99.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.122 (Build 148).

## Neu in 2.1.121 alpha

Audit 45–52: nur bestätigte Bugs. Hash-Floor 0,64 und LOCK-Hold bleiben Absicht.

- **Capture-Hist Table Cap 64.** Box-Hash ohne TTL wuchs und landete in gallery.json.
- **Hash-Trail Cap 64.** Hold hatte Cap, Trail nur TTL — Rebase-Tick skip hielt alles.
- **Twin Gleichstand Occupied.** `leftoverHashTwinLeft` strikt kleiner, sonst beide Exact.
- **Nachbar-Walk Twin aus.** Hamming-1 Veto zuerst, Grid nicht bauen. Kommentar Hamming-1.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.121 (Build 147).

## Neu in 2.1.120 alpha

Direkt laden:
- [Aegis.dmg (Latest)](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)
- [Releases](https://github.com/lolalpha00gamma/aegis-scanner/releases)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [Aegis.dmg](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI auf **macos-26** baut das Image nach jedem Push auf `main`.

## Neu in 2.1.120 alpha

Occupied tötete Hamming-0 Twins beide. leftoverLiveHashTick nach empty tot. LOCK/Adopt hart.

- **`leftoverHashTwinOccupied`.** x-order Twin L Exact, Twin R Occupied. HUD `TWIN L`/`R`.
- **`leftoverLiveHashTickWipes`.** empty → Tick leer.
- **LOCK/Adopt Slider** 0,6–2,0 / 0,6–1,4. Arm und Need lesen Pref.
- **`leftoverHoldIndoorChip` `INDOOR 4s`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.120 (Build 146).

## Neu in 2.1.119 alpha

Hold-TTL Pref Clamp ohne Slider. Occupied nur leftoverLastHash — erster Twin-Frame stiehlt Exact.

- **`leftoverHoldTTLOf` + Slider 1,2–4,0.** Indoor 4 s.
- **`leftoverOccupiedMerge`.** stored + live diesen Tick. Exact occupied ab Frame 0.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.119 (Build 145).

## Neu in 2.1.118 alpha

Hamming-1 stahl den Twin. Exact-Bin las denselben Hold. Overlay leftoverNameFromHold und leftoverLiveNameAnd held=hit.identityId tauften trotz LOCK.

- **`leftoverHoldNeighborOk` dist≥1 tot** bei zwei Gesichtern. Exact dist 0 hält. HUD `NBR` auch Hamming-1.
- **`leftoverHashOwnOccupied`.** Lookup/Trail/Pick Exact-Bin tot.
- **`leftoverNameLockKeeps`.** Overlay `leftoverJumpName` zuerst. leftoverLiveNameAnd held = liveNameLock.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.118 (Build 144).

## Neu in 2.1.117 alpha

leftoverTransfersId respektierte LOCK. Majority und Overlay tauften den Twin trotzdem. LOCK-AND nil wischt den Namen. NBR bei jedem Twin.

- **`leftoverAssignMajority(locked:)`.** LOCK: keine UUID-Taufe.
- **`leftoverLiveNameAnd(locked:, held:)`.** Overlay hält, Twin tot. Hist-Token leer.
- **`leftoverHoldNeighborDist` `NBR` nur Hamming-2.** **`leftoverHoldFastChip` `FAST`.**
- **`leftoverNameLockSecPref` / `leftoverAdoptSecLockPref`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.117 (Build 143).

## Neu in 2.1.116 alpha

Sticky blieb nach 8 s nur-24-fps. Hamming-2 stahl den Twin. IoU-JUMP tauft den Nachbarn.

- **`dropoutSeenSlow(fastFor:)`.** 8 s 24 fps setzt Indoor-Latch zurück.
- **`leftoverHoldNeighborOk`.** Zwei Gesichter, Hamming-2 tot.
- **`leftoverNameLockArm` 1,2 s.** HUD `LOCK`. leftoverHoldsTrack hält, leftoverTransfersId tot.
- **`leftoverHoldTTLPref` 1,2–4,0.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.116 (Build 142).

## Neu in 2.1.115 alpha

Indoor 8 fps Latch 4 s starb: leftoverHoldPut prune Default 1,2 s, Transfers-Prune ohne ttl, Median-Hop 8→24.

- **leftoverHoldPut / leftoverTrailPut `ttl:` leftoverHoldTTL.** Indoor 4 s.
- **Transfers-Prune leftoverHoldTTL.** Nicht leftoverAdoptSec.
- **`dropoutTTLSticky`.** 8 Samples Slow → Latch bleibt nach Licht-an.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.115 (Build 141).

## Neu in 2.1.114 alpha

Audit: Live-Uhren, 2-opt Doppel-Spalte, CI git add ignorierte DMG, codesign ohne Entitlements, Resume-Sandbox, TAR@0,1 %FAR, RTSP tot.

- **Live-Stamp immer Epoch.** Webcam-PTS und Player-Item-Zeit mischten sich mit Date() — Overlay-Chips tot, Tap-Lock nie aus.
- **leftoverAssign Snapshot mitziehen.** 2-opt schrieb dieselbe Spalte zweimal.
- **CI:** kein `git add Aegis.dmg`. codesign mit Entitlements, ohne `|| true`.
- **Resume** löst Security-Scoped Bookmark. Detect speichert Pfade, nicht RAM-UUIDs.
- **TAR** nil wenn n·FAR < 1. DevTest-Header 1 Zahl. RTSP Fehler statt AVPlayer.
- **Center Stage `.app`** vor Disable (macOS 27 Exception).
- Tests + VERSION = Models = MARKETING_VERSION 2.1.114 (Build 140).

## Neu in 2.1.113 alpha

- Hash-Hold Floor 0,64 — schwache Holds taufen nach Restart nicht den Nachbarn
- Hash-Hold Cap 64, Hold+Trail-Prune nicht im Rebase-Tick
- Capture-Hist überlebt App-Neustart (Hash-Keyed)
- Overlay `HASH 0,80` · `JPEG` · `JUMP`

## Neu in 2.1.111 alpha

2.1.110 CI: `¾ kein Trail` widersprach leftoverTrailWriteOk ohne Yaw-Block (2.1.104 Hash-Bin).

- **¾ Hash-Bin Trail.** leftoverHoldBinWriteOk schreibt Pose-Bin. Tests + VERSION 2.1.111 (Build 137).

## Neu in 2.1.110 alpha

2.1.109 JPEG-Probe nil = Taufe. Probe jede Frame auf Main. Timer .default. Cache ohne Hash. Crop-Fail Retry.

- **`leftoverBaptizeJpegOk required`.** Print da, Probe Pflicht. Gate denselben Schalter.
- **`leftoverJpegProbeReuse` 0,80 s Hash/Cosine.** Miss −1. Timer `.common`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.110 (Build 136).

## Neu in 2.1.109 alpha

2.1.108 JPEG-Gate tot ohne Probe. Hold-Bins starben mit dem Prozess. Twin stahl die Box. ¾ Adopt 0,80 s. Portrait .right bei 0°.

- **`FaceEngine.jpegProbeDelta` / leftoverJpegProbe.** Gate misst.
- **Schema 5 leftoverHoldBins persist.** leftoverIoUJump 0,40. Per-Bin Adopt. liveBufferOrientation.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.109 (Build 135).

## Neu in 2.1.108 alpha

2.1.107 Hash-Spark. Spark-Hold mutierte im SwiftUI-Body. leftoverPickLuma tot. Gate tot. Blink sticky. Name ohne 3-Tick. Thermal tot.

- **`leftoverSparkChip` peek.** Tick in stabilizeLiveMatches. Body mutiert nicht.
- **`leftoverPickLuma` / leftoverBaptizeGate / leftoverBlinkLiveness.** Frame vor Box, Gate in Transfer, Lid 2 Frames.
- **`leftoverLiveNameAnd` / leftoverScoreTickOverlay / liveMinIntervalThermal / setFacesPresent(streak:).**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.108 (Build 134).

## Neu in 2.1.107 alpha

2.1.106 Lock 0,80 s / Hunt 10 / Spark peak-hold Math. overlayChipPeakHold nicht verdrahtet. UUID-Steal verlor Hash-Spark.

- **`leftoverSparkTrailOf` / leftoverLastHashKeeps.** Hash-Trail überlebt UUID-Steal.
- **`leftoverSparkChipHold`** verdrahtet overlayChipPeakHold 2 Frames.
- **`leftoverBaptizeGate` / leftoverPickLuma / videoStabilizationApplies.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.107 (Build 133).

## Neu in 2.1.106 alpha

2.1.105 leftoverHoldTrailBins. Hunt Built-in 8 fps, Adopt hart 1,2 s bei 15 fps, Spark flackert, Poster taufen.

- **`leftoverAdoptNeedSec` Lock 0,80 s** bei 15/24 fps (12 Frames). 8 fps bleibt 1,2 s.
- **`liveMinInterval` Hunt 10 fps.** streak ≥ 1 → Lock. Built-in nicht 8.
- **`overlayChipPeakHold` 2 Frames.** JPEG-Poster-Veto. Blink 2-Frame Lid-Gap. Thermal 2 s. CS-Reconnect.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.106 (Build 132).

## Neu in 2.1.105 alpha


2.1.104 ¾-Trail Hash-Bin. Spark und HOLD roh in ¾ noch leer/EMA. Taufe ohne Blur/Blink/Profil.

- **`leftoverHoldTrailBins`.** Spark/HOLD roh je Pose-Bin, nicht Frontal-UUID.
- **`leftoverHoldOverlayChipOf` + leftoverSparkChip.** ¾ HOLD 66/64, Spark 0,64→0,66.
- **`leftoverBaptizeQuality`.** Blur / Blink / Profil keine Taufe.
- **Score-Tick / Live-Name 3-Tick** Math aus bugfix 2.1.15. Overlay bleibt liveScoreEMA / Mehrheit.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.105 (Build 131).

## Neu in 2.1.104 alpha

2.1.103 Overlay-Name. Live-Tap 5 fps, RotationCoordinator drehte den Buffer, leftoverTrailWriteOk blockte ¾, Spark mischte Frontal-UUID, Desk-View 4:3 tot.

- **`liveMinInterval` Hunt 8/10, Lock 12/15.** leftoverAdopt 1,2 s hat Frames.
- **Kein RotationCoordinator.** Capture 0°. Portrait-Buffer `.right`.
- **`leftoverTrailWriteOk` ohne Yaw-Block.** leftoverHoldTrail[id] nur frontal. leftoverSparkChip ¾ ohne UUID-Mix.
- **`leftoverHoldOverlayChipOf`.** ¾ Chip bleibt Bin-Hold, kein Frontal-Trail.
- **`captureFormatScore` 4:3** bis 1920×1440. reselectFormat CS+Format zweimal.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.104 (Build 130).

## Neu in 2.1.103 alpha

2.1.102 Match-Math grün, xcodebuild tot: Swift-Overlay ohne `availableVideoCVPixelFormatTypes`.

- **`availableVideoPixelFormatTypes`.** 420f → 420v → 422 → BGRA. Parameter `videoOut`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.103 (Build 129).

## Neu in 2.1.102 alpha

2.1.101 HOLD compact. leftoverBaptizeBoth `?? raw` taufte Dropout. overlayName zeigte Frontal-Namen in ¾. Transfer-Trail blieb UUID.

- **`leftoverBaptizeBoth` roh UND smooth.** nil Smooth keine Taufe.
- **`leftoverHoldOverlayChipOf`.** ¾ Chip ohne Frontal-Trail.
- **`leftoverTrailNowOf` / `leftoverNameFromHold`.** ¾ ohne Bin kein Name-Steal.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.102 (Build 128).

## Neu in 2.1.101 alpha

2.1.100 Overlay lang, ¾ mischte Frontal-Trail, Center Stage an, Preset clampte Continuity, Softmax nachts wie Tag.

- **`leftoverHoldChip` compact `HOLD 80/64`.** ¾-Trail nicht UUID-Mix.
- **`leftoverScoreHeatMid` Nacht 0,60.** Softmax-Floor 0,47 nachts.
- **Center Stage aus + kein Continuity-Preset.** lock 24 statt 30. 422 vor BGRA.
- **SHARP + BAND Chips.** 420v Sharp-Lift. Format-Chip in der Toolbar.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.101 (Build 127).

## Neu in 2.1.100 alpha

2.1.99 leftoverScore ramped ab 0,22. Capture lockte hart 30.

- **`leftoverScore capture:`** Nacht-Rampe ab leftoverPrintSharpOf 0,12.
- **leftoverPick Box-Capture** in leftoverScore.
- **`captureLockFrameLo` 15–30.** Continuity atmet, droppt nicht auf 8.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.100 (Build 126).

## Neu in 2.1.99 alpha

2.1.98 IEEE. Overlay las Frontal-EMA. pinByPrint `>`. LiveCapture 32BGRA = 8 fps, 420f tot. leftoverAdoptReady holdPrev vor needSec.

- **`leftoverHoldNow` leftoverHoldPrevOf.** ¾-Chip nicht Frontal 0,80.
- **`pinByPrint` ≥ 0,80.** Roh und Smooth dieselbe Sprache.
- **`leftoverPrintSharpOf` Nacht 0,12.** Genuine 0,62 mit Laplacian 0,14.
- **Capture 420f + CIImage.** Continuity 15–30, nicht BGRA@8.
- **LibraryStore leftoverAdoptReady** needSec vor holdPrev.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.99 (Build 125).

## Neu in 2.1.98 alpha

2.1.97 leftoverHoldBlocks 0,70−0,66 < 0,04 wegen IEEE. ¾-Spike ließ Twin durch.

- **`leftoverHoldBlocks` / `leftoverBaptizeSpike` +1e-9.** Exact 0,04 ist Spike.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.98 (Build 124).

## Neu in 2.1.97 alpha

2.1.96 leftoverBaptizeBoth auf `>` 0,80. Adopt 8 fps 0,6 s. Blur-Floor 0,22. ROI 0,18. CI kompiliert, Tests tot.

- **`leftoverBaptizeBoth` smooth ≥ 0,80.** EMA genau 0,80 tauft. pinByPrint bleibt `>`.
- **`leftoverAdoptNeedSec` 1,2 s auch 8 fps.** 10 Frames, Walker fällt durch.
- **`leftoverBlurBlocks` / `leftoverHoldWriteOk` sharpnessFloor 0,12.** Continuity 0,12–0,14 hält leftover.
- **`liveRoiBox` min 0,10.** HD-Gesicht 80 px Crop, nicht nil.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.97 (Build 123).

## Neu in 2.1.96 alpha

2.1.95 leftoverBaptizeBoth Math. leftoverHoldPrevOf tot im Store. CI: redeclare + imageW-Label. Twin 0,82 nach 0,64 stiehlt.

- **`leftoverTransfersId leftoverBaptizeBoth`.** Non-Spike Smooth. Spike-Trail Mean.
- **LibraryStore leftoverHoldPrevOf** holdPrev/holdNow. leftoverPick holdPrev nur leftoverHold[id].
- **Lookaway leftoverHold[id] nur Bin 0.** leftoverHoldLookupYaw `yawAbs: nil` → nil.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.96 (Build 122).

## Neu in 2.1.95 alpha

2.1.94 Frame-Luma live. Trail je Bin. HOLD roh/smooth Label. Dropout Lookup unbinned. Overlay nur EMA.

- **`leftoverHoldLookupYaw`.** Dropout/holdPrev immer Yaw-Bin. LibraryStore 4 Pfade.
- **`leftoverHoldRawOf` / `leftoverHoldOverlayChip`.** Overlay `gehalten 0,80 / 0,64` aus Trail+EMA.
- **`leftoverBaptizeBoth`.** Math roh UND smooth ≥ 0,80.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.95 (Build 121).

## Neu in 2.1.94 alpha

2.1.93 Capture-Hist je Box. CAP-Chip. Score-Softmax. HUD BIN. Frame-Luma tot im Store. Trail unbinned. HOLD eine Zahl.

- **`leftoverFrameCapture` / `leftoverFrameCaptureByte`.** 8×8 Buffer. leftoverPick `frameCapture` live.
- **`leftoverTrailPut(bin:)` / `leftoverTrailLookup(bin:)`.** ¾ liest nicht Frontal-Nachbar.
- **`leftoverHoldLabel(smooth:)`.** Overlay `gehalten 0,80 / 0,64`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.94 (Build 120).

## Neu in 2.1.93 alpha

2.1.92 leftoverHoldByHash je Bin. leftoverPick Hash-Hold. Frame-Luma-Helfer. leftoverHoldBinChip. Box-Hist erbte leftover. HUD ohne CAP. Score platt.

- **`leftoverCaptureHistOf`.** Box-Hist ≥ 3, Flash leftover.
- **`leftoverCaptureChip` + leftoverHoldLabel yawAbs.** Overlay CAP / BIN.
- **`leftoverScoreHeat` Temp 16 + `leftoverScoreSoftmax` Floor 0,55.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.93 (Build 119).

## Neu in 2.1.92 alpha

2.1.91 leftoverHold[id:bin]. Capture-Hist. ¾ erbt nicht Frontal. Hash unbinned. Dropout verliert ¾. Center Stage Box senkt Floor.

- **`leftoverHoldHashKey` / `leftoverHoldPut(bin:)` / `leftoverHoldLookup(bin:)`.** ¾ überlebt Dropout räumlich.
- **leftoverPick `holdHash`.** leftoverHoldPrevOf liest Hash-Bin.
- **`leftoverSessionCapturePrefersFrame`.** Overlay `BIN n`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.92 (Build 118).

## Neu in 2.1.91 alpha

2.1.90 Pick-EMA AE. Twin-Score. Galerie frontal. Capture-Median-Helfer. Hold-Bin-Helfer. Bin tot im Store. Hist nicht in leftoverPick. ¾ Smooth mit Frontal 0,80.

- **`leftoverHoldKey` / `leftoverHoldPrevOf`.** ¾ erbt nicht Frontal-Hold.
- **`leftoverHoldBins`.** LibraryStore Put / Survive / Drop.
- **leftoverPick `captureHist` + `holdBins`.** liveCaptureHist, Flash-Median.
- **`leftoverHoldBinWriteOk`.** ¾ schreibt Bin, leftoverHold[id] bleibt frontal.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.91 (Build 117).

## Neu in 2.1.90 alpha

2.1.89 per-Box Capture. unknownCentroid Yaw. Hold-α AE. Pick-EMA ignorierte Jump. Twin nicht im Score. ¾ in der Galerie. Flash senkte Floor.

- **`leftoverHoldSmooth(captureJump:)`.** leftoverPick reicht den AE-Jump.
- **`leftoverScore(twinPair:)`.** Same-Shot ≥ 0,88 zieht Score.
- **`leftoverCentroidOk`.** meanPrintVector nur scharf+frontal.
- **`leftoverSessionCaptureMedian` / Box(hist:).** Flash 1 Tick Floor bleibt.
- **`leftoverHoldBin`.** 0 frontal / 1 ¾ / 2 Profil.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.90 (Build 116).

## Neu in 2.1.89 alpha

2.1.88 Live-Tag über Ghost. ¾ kein Hold-EMA. Print-Floor roh. Nacht-Climb. FaceEngine Capture.

- **`leftoverSessionCaptureBox`.** per-Box Capture. Gast-Schatten senkt Annas Floor nicht.
- **`leftoverPick capture:`** `[Int: Double]` statt min(alle Live).
- **`unknownCentroid(yawAbs:)`.** Profil 0,65 unbekannt. FaceEngine reicht Yaw.
- **`leftoverHoldAlpha(captureJump:)`.** AE-Sprung ≥ 0,20 → α 0,08.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.89 (Build 115).

## Neu in 2.1.88 alpha

2.1.87 Live-min mit Ghost. ¾-EMA. Smooth-Floor. Climb=Spike. FaceEngine ohne Capture.

- **`leftoverSessionCapture`.** Live nonempty ignoriert Ghost.
- **`leftoverHoldWriteOk`.** Yaw-Skip 0,28 (Lookaway), nicht erst Profil 0,45.
- **`leftoverPickPrint`.** leftoverPrintOk auf RAW.
- **`leftoverHoldClimb`.** Nacht 0,61→0,66 kein Spike.
- **FaceEngine `unknownCentroid(capture:)`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.88 (Build 114).

## Neu in 2.1.87 alpha

2.1.86 Detector-Score. Session-Floor am Ghost. unknownCentroid 0,62 hart. Profil-EMA. Spark tot. Order 40 px auf 4K.

- **`leftoverSessionCapture(old:live:)`.** min(Ghost, Live).
- **`unknownCentroid(capture:)`.** Nacht-Floor 0,60.
- **`leftoverHoldWriteOk(yawAbs:)`.** Profil kein Hold-EMA.
- **`leftoverCosineSparkPut` / `leftoverCosineSparkLabel`.** Overlay `0,64→0,90`.
- **`leftoverBoxOrderGap` 4 % + `liveCentroidKeepsPrint`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.87 (Build 113).

## Neu in 2.1.86 alpha

2.1.85 Exact-Lookup. 4K-Nachbar an Bin 11 geclippt. leftoverPick ohne Detector. Kein L/R-Prior. Nacht-Floor tot. Centroid ohne Frontal/Yaw.

- **`leftoverBoxHashNeighbors` max(24).** Bin 11 → Nachbar 12.
- **`leftoverScore(detScore:)` / leftoverPick `detScore`.**
- **`leftoverBoxOrderKeeps`.** Anna links bleibt links.
- **`leftoverSessionFloor`.** Capture < 0,28 → Floor −0,02.
- **`centroidWeight(frontal:yawAbs:)`.** Profil weniger Gewicht.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.86 (Build 112).

## Neu in 2.1.85 alpha

2.1.84 leftoverBoxUnit. HoldLookup jüngster Nachbar = Anna erbt Gast. 12 Bins auf 4K ein Hash. ROI-Crop leer = Latch tot. Walk-in außerhalb Crop. Kalman-Q fest bei AE.

- **`leftoverHoldLookup` / `leftoverTrailLookup` Exact zuerst**, sonst Manhattan, nicht Recency.
- **`leftoverBoxHashBins`.** 12 / 16 ab 1920 / 24 ab 4K.
- **`liveRoiMissRetries` / `GoesFull` / `Expand`.** 8 fps direkt voll.
- **`liveRoiPeriodicFull` + `liveRoiSkipsForStranger`.**
- **`leftoverGhostAspectLock`.** **`boxKalmanQ(captureJump)`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.85 (Build 111).

## Neu in 2.1.84 alpha

2.1.83 Adopt-Blend. leftoverBoxHash Clamp-auf-1 — Pixel-Kisten ein Bin, Hold von Anna klebt an Gast 2.

- **`leftoverBoxUnit` / Hash imageW/H.** Pixel räumlich getrennt.
- **`leftoverLiveHash`.** Hold/Trail dieselbe Normierung.
- **`leftoverTrailPut(sharpness:)`.** Blur kein Append.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.84 (Build 110).

## Neu in 2.1.83 alpha

2.1.82 Adopt-Kalman. Overlay sprang trotzdem: Live-Box roh. Kalman-Predict nur bei found.isEmpty — Poster fror Walker. Trail-Append ohne Schärfe. Detector volles Bild. Walker-Doppelkiste.

- **`leftoverAdoptBlend`.** Live-Box durch Kalman, k=0,55.
- **`leftoverPredictOnEmptyLike`.** Fremde Kiste = Predict wie leer.
- **`leftoverTrailWriteOk`.** Blur kein Trail. **`kalmanNmsDrops`.** Twin auf Predict weg.
- **`liveRoiBox`.** Detector Crop um Kalman. **`exposureLockHold(reconnect)`** 8 fps 0,80 s.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.83 (Build 109).

## Neu in 2.1.82 alpha

2.1.81 Kalman-Predict. Adopt droppte Kalman+vx — Overlay sprang, Gast n+1. Poster im Frame wischte Annas Latch. Hold-EMA ohne dt, Blur schrieb Hold.

- **`leftoverAdoptKeepsKalman`.** Adopt hält Filter.
- **`leftoverEmptyIgnoresStranger`.** IoU < 0,18 = Latch wie leer.
- **`leftoverHoldAlpha(dt)` + `leftoverHoldWriteOk`.** 8 fps kein Spike, Blur kein Hold.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.82 (Build 108).

## Neu in 2.1.81 alpha

2.1.80 Kalman am Ghost. Velocity fehlte — Walker klebte, Gast n+1. leftoverPending blieb auf toter UUID. Latch-Ende hartes Wipe.

- **`boxKalmanPredict`.** Leerer Frame: cx += vx·dt, Ghost-Box folgt.
- **`leftoverPendingMirror`.** Namen folgen der Adopt-ID.
- **`leftoverLatchChipKeeps`.** Overlay 0,4 s nach Latch.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.81 (Build 107).

## Neu in 2.1.80 alpha

2.1.79 Overlay/Latch. Kalman starb am zweiten leeren Frame. emptyKeeps ohne Zeit. leftoverPending wischte am Frame-Start.

- **`leftoverKeepBoxes`.** Ghosts+Hold halten Kalman.
- **`leftoverLatchKeeps` + `leftoverEmptySince`.** emptyKeeps 4 s.
- **leftoverPending bleibt** am Latch.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.80 (Build 106).

## Neu in 2.1.79 alpha

2.1.78 Streak/Kalman. Overlay-Namen wischten trotzdem. Ghost 1,6 s kürzer als Continuity-AE. Profil-Floor schon bei 16°.

- **`leftoverEmptyKeepsOverlay`.** leftoverPending / Held / Auswahl bleiben am Ghost.
- **`leftoverLatch` 4 s.** 8 fps Ghost/TTL 4 s, 24 fps 1,2 s.
- **`leftoverPrintProfileYaw` 0,45.** Floor 0,70 erst ab ~26°.
- **`leftoverHoldSurvive(emptyKeeps:)`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.79 (Build 105).

## Neu in 2.1.78 alpha

2.1.77 Label/WEG/Miss. Ein leerer Detector-Frame wischte Streak und Kalman — Continuity 8 fps = Gast n+1. Profil 0,62 scharf taufte Twins. Same-shot 0,90 blieb weich.

- **`leftoverEmptyKeepsStreak`.** Dropout hält Streak/Miss/Pair/Kalman.
- **`leftoverPrintFloor(yawAbs:)`.** Profil 0,70, Frontal 0,62.
- **`leftoverTwinHardVetoNow`.** Zwei Gesichter Hard 0,88. **`leftoverPick(facesInFrame:)`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.78 (Build 104).

## Neu in 2.1.77 alpha

2.1.76 TWIN?/0,62/WEG. Overlay zeigte 0,62 nicht. WEG fiel auf den Nachbarn. Ein Miss-Tick = Gast n+1. Adopt 1,2 s bei 8 fps.

- **`leftoverHoldLabel(sharpness:)`.** 0,62 scharf = `gehalten 0,62`.
- **`leftoverLookawayPinsStranger`.** WEG nur IoU ≥ 0,12.
- **`leftoverMissClears` 3 Frames.** **`leftoverAdoptNeedSec`** 8 fps 0,6 s.
- **`leftoverTwinTint`.** TWIN? amber, TWIN hart rot.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.77 (Build 103).

## Neu in 2.1.76 alpha

2.1.75 WEG/UNBEKANNT/TWIN?. TWIN? löschte Streak. 0,62 scharf wurde Gast. WEG-Pin 0,28 tot. Kein Countdown.

- **`leftoverTwinKeepsStreak`.** TWIN? hält, TWIN 0,93 löscht.
- **`leftoverHoldsTrack(sharpness:)`.** 0,62 scharf Overlay, kein Gast.
- **`leftoverLookawayIoU` 0,12.** Atmende Kiste pinnt. `WEG in 0,8 s`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.76 (Build 102).

## Neu in 2.1.75 alpha

2.1.73 WEG/UNBEKANNT/TWIN. WEG-Chip auf Ghost-ID, Filter liveIds strippte ihn. Lookaway las Ghost-Yaw. UNBEKANNT löschte Streak. Taufe wischte Streak. TWIN 0,90 ohne ?.

- **`leftoverLookawayPin`.** WEG auf die Live-Kiste. Live-Yaw sticht Ghost. EMA freeze.
- **`leftoverUnknownKeepsStreak`.** Open-Set kein Gast n+1.
- **`leftoverStreakKeepsLive`.** Blink re-adoptiert.
- **`leftoverTwinPairLabel` `TWIN? 0,90` / `TWIN 0,93`.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.75 (Build 101).

## Neu in 2.1.74 alpha

Testdaten **in der App**: links **Testdaten holen** (LFW ~170 MB nach `Downloads/AegisBench`), dann **Test starten**. Keine Fotos auf GitHub — LFW-Lizenz.

## Neu in 2.1.73 alpha

2.1.72 Trail-Kalman/EMA/Twin/Lookaway. Streak-Box roh. Lookaway wischte Hold. TAUFEN? schrieb nicht. 0,82 tauft ohne Still. Open-Set Gast-Index.

- **`leftoverStreakBoxWrite`.** Streak- und Pick-IoU Kalman.
- **`leftoverLookawayHolds` + `WEG`.** Freeze ohne Clear.
- **`persistGuestTap`.** Zweiter Overlay-Tap tauft.
- **`leftoverBaptizeStillBlocks` 0,45 s.** Vorbeigehen tauft nicht.
- **`leftoverUnknownHard` UNBEKANNT. `leftoverTwinPairLabel` TWIN 0,93.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.73 (Build 99).

## Neu in 2.1.72 alpha

2.1.71 Trail/Kalman-Put/Tap/Burst. Trail-Lookup Roh-Box. EMA ohne dt. Twin 0,93 taufte. Ghosts unsichtbar. Rename ohne Lock.

- **`leftoverTrailWriteHash`.** Put = Lookup = Kalman.
- **`leftoverHoldAlpha(dt)`.** 8 fps Spike 0,06 dämpft.
- **`leftoverTwinHardBlocks` 0,92.** Auch Baptize tot. Rename Tap-Lock 3 s.
- **`leftoverLookawayBlocks`.** Enrolled Yaw freeze. Ghost-Overlay + `GHOST n,s`.
- **AE-HUD, Gast `TAUFEN?`, Prune nur leerer Frame.** TAP nicht leftover-orange.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.72 (Build 98).

## Neu in 2.1.71 alpha

2.1.70 Survive/TTL/Jump/Tap. printPin wischte Trail. Put auf Roh-Box. Overlay-Tap ohne Lock. AE-Burst 3 Frames schrieb Gallery. Leftover durchgezogen wie ein Name.

- **`printTrailKeepsOnGhostAdopt`.** Ghost-Adopt hält Median. Erster 0,82 tauft nicht.
- **`leftoverHoldWriteHash`.** Put = Kalman-Kiste, Lookup derselbe Bin.
- **`tapOverlay` 3 s.** Overlay-Klick auf enrolled sperrt leftover. Chip `TAP ns`.
- **`captureBurstBlocksPrint`.** 3-Frame-AE. `exposureLockHold(dt)` 8 fps 0,40 s.
- **`overlayBoxDash`.** Leftover/Ghost gestrichelt. Prune-Log eine Zeile.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.71 (Build 97).

## Neu in 2.1.70 alpha

2.1.69 leftoverDropped/Blur/Kalman. Survive nur bei leerem Frame. Trail nur `used`. printPin blendet AE-Sprung. Ghost-TTL fest 1,2 s. Tap-Name leftover tauft.

- **`leftoverHoldSurvive(..., live:)`.** Keep = Ghosts ∪ Live. Partial wischt Anna nicht.
- **Trail/Kalman/Euro für Dropped.** Median überlebt den Miss.
- **`captureJumpBlocksPrint`.** Enrolled: Belichtungssprung hält den Gallery-Print. IoU und printPin.
- **`dropoutTTL(dt)`.** 8 fps 1,6 s, 24 fps 1,2 s.
- **`tapNameLock` 3 s.** Anlegen/+ — leftover tauft nicht. Chip `TAP ns`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.70 (Build 96).

## Neu in 2.1.69 alpha


2.1.68 Cross-Slot/Hold/Survive. Partial-Dropout ghostete nicht. Enrolled auf leerem Frame verloren Hold. Blur 0,64 war Pick. Hash auf Roh-Kiste, Radius nur Bin 0/1.

- **`leftoverDropped`.** Partial und leer ghosten enrolled.
- **Kalman-Hash.** leftoverHashBox, Euro/Kalman bleiben für Dropped.
- **`leftoverBlurBlocks`.** Unscharf kein Hold-Pick. Baptize 0,80 trotz Blur.
- **Nachbar-Radius 2** bis w/h-Bin 2.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.69 (Build 95).

## Neu in 2.1.68 alpha

2.1.67 Hash/Ghost/Twin. Kopfdrehen F→¾→P: Pick nil, Streak tot. Hold 0,64 ohne Transfer machte Gast. holdPrev 0,00 skippte 1,2 s. Kleine Kiste sprang zwei Bins. Leerer Frame wischte UUID-Hold.

- **`leftoverAllowsCrossSlot`.** Print ≥ 0,64 darf Slot wechseln. 0,50 bleibt tot.
- **`leftoverHoldsTrack`.** 0,64–0,79 Overlay, kein Gast, kein UUID-Steal.
- **Adopt-Skip nur Print-Hold.**
- **Kleine-Box-Radius 2.** Hold nach Schritt nach vorn.
- **`centroidWeight` verdrahtet** (mean / partial / printWeights).
- **`leftoverHoldSurvive`.** Dropout: Hold/Trail/Slot am Ghost, nicht Wipe.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.68 (Build 94).

## Neu in 2.1.67 alpha

2.1.66 Hash überlebte Dropout, leftover las ihn nicht. Ghosts nur in pinByPrint 0,80. Größe wechselte Bin. Transfer stahl 0,82 nach Hold 0,64. Trail UUID-keyed, MAD nach Miss tot.

- **Ghost-Pool.** leftoverPinned nimmt liveGhosts.
- **Hash w/h ±1.** Hold über Größen-Kante.
- **`leftoverBaptizeSpike`.** Twin 0,80 nach 0,64 kein UUID-Steal.
- **Trail by Hash.** MAD überlebt leere Frames.
- **Adopt mit holdPrev.** Hash-Hold skippt 1,2 s.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.67 (Build 93).

## Neu in 2.1.66 alpha

2.1.65 hat Nachbar-Hash und Print-MAD nur in ANALYSE.md behauptet. Exact-Lookup, leerer Frame wischt Hash und Gast-Liste, zwei Ghosts beide „Gast 1“, MARKETING_VERSION 2.1.64.

- **`leftoverBoxHashNeighbors`.** Hold über Bin-Kante. Lookup jüngster Nachbar, ferne Bins leer.
- **Leerer Frame: Prune, kein Wipe.** Hash-Tabelle überlebt Detector-Miss.
- **`guestOrderKeeps`.** 8 s Dropout, unbekannt = Gast n+1.
- **`printMADBlocks`.** Twin 0,80 neben Median 0,64 → Overlay `MAD`.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.66 (Build 92).

## Neu in 2.1.64 alpha

2.1.63 leftover stiehlt keine UUID, Overlay Gast 1/2. leftoverHold hing an der UUID — Dropout warf Hold. Streak-Since nur RAM. Gast hätte nach 8 s leftover still in gallery.json landen können. Ampel nur Farbe.

- **`leftoverHold` per Box-Hash.** UUID stirbt, die Kiste bleibt. TTL 1,2 s.
- **gallery.json Schema 4.** `leftoverStreakSince` überlebt Restore.
- **Gast nie silent.** Nur Tauf-Button schreibt. Overlay bleibt Gast.
- **Farbenblind Ampel.** ● ◐ ✕ plus VoiceOver.
- **CLAHE-Banner.** Continuity-Nacht. `liveROI` Math.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.64 (Build 91).

## Neu in 2.1.63 alpha

2.1.62 hat Konflikt-Tick und leftover weicht Live. leftover kopierte trotzdem `old.id` plus Print bei 0,64. Overlay immer `Gast 1`. CI macos-14, Tests nach dem Build.

- **`leftoverTransfersId`.** UUID/Print nur bei Baptize 0,80. 0,64 hält, tauft nicht.
- **`Gast 1` / `Gast 2`.** `guestOrder`, Overlay vor dem Namen.
- **CI macos-26.** Tests zuerst, arm64.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.63 (Build 90).

## Neu in 2.1.62 alpha

2.1.61 hat Blink/Kalman/Split verdrahtet. leftover taufte trotzdem, wenn Print, Geo und Lock uneinig waren. Burst droppte das schärfere Incoming. Built-in-Centroid auf Continuity.

- **Konflikt-Tick.** BOX/PRINT/GEO/LOCK einig, sonst keine Taufe. Overlay `KONFLIKT`.
- **leftover weicht Live.** Schon getaufte Kiste wird nicht umgetauft.
- **Centroid je Kamera.** Built-in und Continuity getrennt.
- **Burst ersetzt unscharf.** Schärferes Ref bleibt.
- **Live-FAR** im Floor-Hint. Schema 3 (Restore warnt).
- Tests + VERSION = Models = MARKETING_VERSION 2.1.62 (Build 89).

## Neu in 2.1.61 alpha

2.1.60 hat Blink/Kalman/Split nur als Math. Poster ohne Lid-Toggle blieb, Continuity-Box hing hinter Sprüngen, leftover-Majority taufte nach 10 Kreuz-Ticks still.

- **`posterNeedsBlink` verdrahtet.** Overlay `BLINK` wenn 8 Still-Frames ohne Lid-Toggle.
- **`boxKalman` bei 8 fps** statt 1-Euro. 24 fps bleibt 1-Euro.
- **`clusterSplit` Overlay `SPLIT`** nach 10 uneinigen leftover-Ticks.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.61 (Build 88).

## Neu in 2.1.60 alpha

2.1.59 leftover taufte Zwillinge 0,89–0,94, Overlay zeigte Anna bei 0,64, Merge nur Top-1, zwei Köpfe Print-OR-Geo.

- **`leftoverTwinSuggest`.** 0,89–0,94 kein leftover, Overlay `TWIN`.
- **`Gast 1`** bis Baptize 0,80 — leftover stiehlt den Namen nicht.
- **Merge +N weitere.** Button mehrmals.
- **`twoPersonAnd`.** Zwei Personen: Print und Maße.
- **leftoverScore × Schärfe.** Blur 0,73 verliert gegen scharf 0,72.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.60 (Build 87).

## Neu in 2.1.59 alpha

2.1.58 hat Merge-Schwelle und Open-Set-Math, aber leftover taufte schmale Profil-Kisten, Poster an der Wand, AE-Sprünge und Masken-Full-Print. Merge-Wizard fehlte.

- **`leftoverPick aspectOk` / `leftoverPickAspect`.** Box-Aspekt < 0,38 nur mit Baptize 0,80.
- **`unknownCentroid` in matchLive + leftoverPick.** Open-Set Cosine-Floor, nicht nur Prozent.
- **`partialPrintMasked`.** Maske + U-Slot-Refs → Teil-Print gegen meanPartialVector.
- **Poster.** Landmark-Jitter 0 über 4 Frames blockt leftover (`POSTER`).
- **AE-Lock 200 ms** nach Capture-Sprung ≥ 0,15 — kein Print-Commit.
- **`printCommitMedian`** auf leftover-Hold-Trail vor Taufe (`MED`).
- **Merge-Banner** Centroid 0,89–0,94 + Button Zusammenführen.
- **Open-Set im Floor-Hint** (Slider 78 → 50).
- Tests + VERSION = Models = MARKETING_VERSION 2.1.59 (Build 86).

## Neu in 2.1.58 alpha

2.1.56 leftoverHoldEMA saß nach leftoverPick — Twin-Spike 0,70 taufte (EMA 0,66 ≥ Floor 0,64). Print-Cache FIFO. Open-Set Floor 50 ignorierte den Slider. 2.1.57 hat Yaw/Majority, nicht den Hold-vor-Pick.

- **`leftoverHoldSmooth` / `leftoverHoldBlocks`.** Spike ≥ 0,04 ohne Baptize 0,80 vor Pick.
- **`printCacheTouch`.** Hit ans Ende — echter LRU 512.
- **`unknownRejectFloor(slider:)`.** Slider 78 → 50. matchLive nutzt ihn.
- **`mergeSuggest` 0,89–0,94.**
- Tests + VERSION = Models = MARKETING_VERSION 2.1.58 (Build 85).

## Neu in 2.1.57 alpha

Leftover taufte den Profil-Nachbarn (Yaw ignoriert). 2-opt wechselte UUID in einem Tick. 24 fps Print fraß den Frame. Name-Lock Overlay blieb „hält“ ohne Countdown.

- **`leftoverPick yawAbs`.** Penalty 0,12 — Frontal schlägt Profil bei gleichem Print.
- **`leftoverAssignMajority` 3 Frames** bevor UUID-Switch.
- **`printBudgetSkip`.** visMs > 18 nur bei 24 fps. 8 fps nie.
- **`nameLockTTLLabel`.** Overlay `hält · TTL 3s` in den letzten 4 s.
- **`posterFaceReject` / `boxAspectFrontal` / `printCommitMedian` / `exposureLock` / `partialPrintMasked` / `unknownCentroid`.** Math+Tests.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.57 (Build 84).

## Neu in 2.1.56 alpha

Desk-View als Front gespiegelt — Zwillinge auf einem Gesicht. Ein Kamera-Dropout setzte leftover-Need auf 0,50 s. Name-Lock klebte nach Verlassen. Idle→Live 8 fps beim ersten Blinker. Print-Cache `removeAll` nach 513 Gesichtern. leftover-Hold roh 0,64/0,70 taufte. Live-NMS ignorierte `iouThresh` (duplicate 0,42 allein).

- **`mirrorAsFront`.** Desk-View nie spiegeln.
- **`medianLiveDt`.** Dropout raus, leftover-Need bleibt 8 fps.
- **`nameLockVoteTTL` 8 s.** `nameLockHolds(lastVote:now:)`.
- **`liveFacesLatch`.** 2 Frames Gesicht bevor 8 fps.
- **`liveDuplicate` / `liveNmsIoU` 0,45** plus nested 0,55. Foto bleibt 0,42.
- **`leftoverHoldEMA`.** Twin-Spike 0,70 glättet.
- **`printCacheDropCount`.** Älteste raus, nicht kalt.
- Tests + VERSION = Models = MARKETING_VERSION 2.1.56 (Build 83).

## Neu in 2.1.55 alpha

Ghost 1,8 s überlebte leftover 1,2 s — Vorbeigehen taufte den Nachbarn. leftover zählte Frames, 2 fps→8 fps tauften nach 3 Ticks. Kamerabuffer plus `CIImage.oriented` war Doppel-Drehung wie Helios vor 1.5.39. Idle-Tap 2 fps verpasste das erste Gesicht. Scores unter 50 % tauften trotzdem.

- **`liveGhostHold` = leftoverAdoptSec (1,2 s).**
- **`leftoverAdoptReady(elapsed:streak:)`.** 1,2 s **und** ≥ 3 Frames. Overlay `1/10` in Zehnteln, nicht 24-fps-`1/75`.
- **`unknownReject` 50 %.** Overlay „unbekannt“, keine Taufe.
- **RotationCoordinator** Horizon-Level, Vision `.up` — Override bleibt.
- **Idle-Tap 5 fps** (0,20 s), mit Gesicht 8 fps.
- **Wipe-Mute** nur wenn Hist < 4. Starke Locks bleiben.
- Tests: Ghost=leftover, Elapsed, Unknown, Mute-Hist.
- VERSION = Models = MARKETING_VERSION 2.1.55 (Build 82).

## Neu in 2.1.54 alpha

- **Print tot ≠ Okklusion.** Leerer Print hat Crop-Fallback auch bei EXIF-Rotation; 1:1-Zuordnung wenn nur ein Gesicht. Overlay sagt „unscharf“ / „Maske?“ nur wenn es stimmt.
- **Testmodus** sitzt links unter Anlegen (nicht mehr in der vollen Toolbar). Testdaten: `./bench/fetch.sh` → `~/Downloads/AegisBench/ident20`.

## Neu in 2.1.53 alpha

Größere Testreihe: `ident20` (~62 Personen × 20 Fotos) und `ident10` (~158 × 20). Testmodus nimmt bis 200 Personen / 20 Fotos; volle LFW filtert automatisch auf ≥10 Bilder.

## Neu in 2.1.52 alpha

**Testmodus.** LFW View-2 (6000 Paare) und Identifikation auf Personen-Ordnern. Bilder holt `bench/fetch.sh` nach `~/Downloads/AegisBench` — nicht ins Git. Toolbar **Testmodus**, Galerie bleibt unberührt. Bericht: EER, TAR@FAR, Cosine-Histogramm.

## Neu in 2.1.51 alpha

2.1.50 leftover Spread/Twin — Dropout ohne Print fiel auf IoU zurück. Ghost-Print 0,64 stahl die UUID. 2-opt leftoverAssign taufte Zwillinge (Spread in leftoverPick, nicht in der Matrix). Burst-Refs derselben Pose in 200 ms.

- **Dropout IoU tot.** Auch ohne Print-Pin keine Box-Taufe.
- **Ghost braucht Baptize.** Print < 0,80 aus Ghost kein Pin.
- **leftoverAssign Ambiguity.** Spread < 0,08 droppt die 2-opt-Zeile.
- **Enrollment-Burst Dedup.** `+` gleicher Slot + 0,95 in 400 ms.
- Tests: Assign-Drop, Skip-IoU, Ghost-Baptize, Burst.
- VERSION = Models = MARKETING_VERSION 2.1.51 (Build 78).

## Neu in 2.1.50 alpha

2.1.49 leftover 1,2 s — Zwillinge 0,70/0,69 wurden getauft. Wipe → sofort neue Stimme. Nicken F→¾. IoU nach Dropout. Gähnen als Vote. Reconnect-Print sah nur Kamera-dt.

- **leftover Ambiguity.** Spread < 0,08 kein Adopt, Schärfe darf trennen.
- **Twin-Veto.** pairCosine ≥ 0,90 nur Print ≥ 0,80.
- **Wipe-Mute 800 ms** Overlay `STUMM`.
- **Slot-Sticky** F→¾ zwei Frames. **Mund** mouthH_iod ≥ 0,42 keine Stimme.
- **Reconnect-Print** aus Ghost oder Lücke ≥ 0,40 s.
- Tests: Spread, Twin, Sticky, Mute, Mund, Ghost.
- VERSION = Models = MARKETING_VERSION 2.1.50 (Build 77).

## Neu in 2.1.49 alpha

2.1.48 leftover ~380 ms — Vorbeigehen taufte den Nachbarn. Pale Prints (≥ 90 d) zogen den Live-Centroid. Kisten-Zahl sprang unsichtbar. Centroid-Cache nur Identity+Slot, Pale invalidierte nicht.

- **leftover 1,2 s Walk.** `leftoverAdoptSec` 1,20, Cap 80. 8 fps 10 Frames, 24 fps 75. Overlay `1/10`.
- **Pale-Print drop.** `palePrintDrops` aus dem Live-Centroid, solange frische Refs bleiben.
- **Head-count Flash.** `KOPF 1→2` 0,45 s cyan, nicht beim ersten Kopf.
- **liveCentroid Cache-Key.** IDs sortiert + Slot + Pale-Count.
- Tests: Need 10/75, Pale, Cache-Key, Kopf-Blitz.
- VERSION = Models = MARKETING_VERSION 2.1.49 (Build 76).

## Neu in 2.1.48 alpha

2.1.47 leftover 3+ — Adopt im ersten Frame. Nachbar erbt UUID. `liveCentroid` 72/28 mit Profil bei leerem Slot. Vote bei Maske/Blick/Lid. leftover-Need kappte 24 fps auf 128 ms.

- **leftover 3+/~380 ms.** `leftoverAdvance` — gleiche Box, dann Adopt. Overlay `1/4`.
- **Need aus dt.** 8 fps 4 Frames, 24 fps 24 Frames. Cap 30.
- **Slot leer → Frontal.** Nie Profil im Live-Centroid.
- **Vote-Skip.** occluded / gazeAway / eyesClosed.
- Tests: Need, Streak, Same-Target, Maske/Blick/Lid, Frontal-Fallback.
- VERSION = Models = MARKETING_VERSION 2.1.48 (Build 75).

## Neu in 2.1.47 alpha

2.1.46 Freeze aus globalem `liveDt` — ein Dropout fror alle Stimmen. Spark war Hit-Prozent, nicht Centroid. leftover 2×2. SHA geschrieben, nie gelesen. Freeze ohne Achse. Swap unsichtbar. Deskew-Blur ging in den Print.

- **dt pro Track.** `trackDt` / `poseDropoutResets` — Lücke >> Kamera setzt Pose neu, nicht Freeze.
- **Freeze-Achse `FY`/`FP`/`FR`.** Overlay neben F.
- **Spark aus Centroid-Cosine.** `printDriftSample`, nicht LookOf.
- **leftover 3+.** `leftoverAssign` greedy + 2-opt.
- **SHA-Verify beim Load.** Sidecar ≠ Hash → Banner.
- **Swap-Blitz** 0,45 s gelb + `SWAP`.
- **Motion-Blur nach Deskew.** Laplacian < 0,10 kein neuer Print.
- Tests: Dropout, Achse, Spark, SHA, 2-opt, Blur.
- VERSION = Models = MARKETING_VERSION 2.1.47 (Build 74).

## Neu in 2.1.46 alpha

2.1.45 Pose-Freeze ohne Takt — Continuity 8 fps: Pitch/Roll-Rauschen 0,12/Frame fror jede Namensstimme. `identitiesCrossed` nur bei genau 2 Köpfen. Overlay zeigte Snapshot-Index, nicht Track. Print-Drift unsichtbar.

- **Freeze folgt dt.** 8 fps Yaw 0,15 / Pitch-Roll 0,18. 24 fps 0,06 / 0,10. Continuity-Rauschen tauft weiter.
- **Swap für 3+.** `pairSwapIndices` jedes Paar, nicht nur `count == 2`.
- **Track-Label `T` + 3 Hex** auf der Kiste.
- **Print-Drift-Spark** letzte 8 Print-Prozent neben P/L.
- **VERSION = Models = MARKETING_VERSION 2.1.46** (Build 73).

## Neu in 2.1.45 alpha

2.1.44 Lock-Drop / Pose-Balken — Nicken taufte trotzdem den Nachbarn (`pitch` ignoriert). Schulterzucken (Roll) ebenso. `boxesCrossed` feuerte nur wenn Keep < Pin 0,28: IoU-Hold klebte schon bei 0,30. Swap nach Zuweisung über Box: greedy IoU klebt die UUID an die Stelle, Keep hoch, Swap nie.

- **Pose-Freeze.** `poseVelocityFreeze` — |Δyaw| **oder** |Δpitch| **oder** |Δroll| > 0,15 / Frame keine neue Stimme.
- **Swap klar besser.** Kreuz-IoU ≥ Keep + 0,15 tauscht leftover-ungenutzt auch über Pin.
- **Print-Swap zugewiesen.** `identitiesCrossed` — Keep-Print niedrig, Kreuz-Print hoch.
- **VERSION = Models = MARKETING_VERSION 2.1.45** (Build 72).

## Neu in 2.1.44 alpha

2.1.43 hat Yaw-Freeze und Lock-HUD — der Name klebte trotzdem, sobald der Print der Lock-ID unter 0,50 fiel (Nachbar im selben Track). Anlegen ohne Balken/Pfeil. Crops mit Roll > 8° gingen roh in Face-Print. Galerie ohne SHA.

- **Lock-Drop.** `nameLockDrops` — Print der Lock-ID < 0,50 oder fehlend in Versus kippt den Namen. Mehrheit tauft weiter.
- **Pose-Balken** `F ██ ¾ █░ P ░░` in der Namensliste.
- **Coach-Pfeil** ‹ › · auf der Kiste.
- **Crop-Align.** |Roll| ≥ 8° dreht das Crop vor `VNGenerateFacePrint` (Canvas wächst mit).
- **gallery.json.sha256** 12 Hex neben dem Save, auch nach Fallback-Write.
- **Labor-CSV** mit Note-Spalte (`labCSVRow`).
- **Hold-Still 0,8 s** bevor ein neuer Print den alten ersetzt. Overlay `HALTEN n%`.
- **VERSION = Models = MARKETING_VERSION 2.1.44** (Build 71).

## Neu in 2.1.43 alpha

2.1.42 leftover-Lock — ¾-Drehung taufte den Nachbarn, unscharfe Ticks zählten als Stimme, Overlay nach Taufe tot, gekreuzte Köpfe erbten die UUID, Name nur in der selektierten Kiste.

- **Yaw-Freeze.** |Δyaw| > 0,15 / Frame keine neue Stimme.
- **Schärfe vor Vote.** Unter Floor (0,12 / Continuity 0,08) keine Namensstimme.
- **Lock-HUD `hält`.** Uneinig nach Taufe wirkt nicht tot.
- **Box-Swap.** IoU-Kreuz tauscht UUIDs, leftover nicht.
- **Name auf jeder getauften Kiste.**
- **VERSION = Models = MARKETING_VERSION 2.1.43** (Build 70).

## Neu in 2.1.42 alpha

2.1.41 hat Namens-Lock — leftover 0,64 taufte trotzdem. Nach Dropout bleibt dieselbe Live-UUID, `leftoverHold` **und** `liveNameLock` auf Anna. `nameLockHolds(voted:nil, locked:Anna)` schreibt den Namen ohne Vote, `leftoverHold.removeValue` macht die Kiste grün. Hold wurde dazu jeden Frame geleert — orange „gehalten 0,64“ nur ein Tick.

- **Leftover überspringt Lock.** `leftoverLocked` gibt nil solange Hold sitzt. Mehrheit tauft weiterhin.
- **Hold bleibt** bis Mehrheit oder Track weg. Pin ≥ 0,80 nimmt Hold weg.
- **VERSION = Models = MARKETING_VERSION 2.1.42** (Build 69).

## Neu in 2.1.41 alpha

2.1.40 hat Familien-Taufe und Print-führt — der Name starb trotzdem nach der Taufe. Look≠Print schreibt leere Tokens in die Hist. `nameHistCap` kappte **inklusive** Leer, `nameMajorityAgreeing` filtert sie erst danach: 10 Uneinig-Ticks (1,25 s bei 8 fps) schieben die 7 Familien-Stimmen aus dem Fenster, `identityId = nil`. Overlay wirkte getauft, dann tot.

- **Leere Tokens belegen den Cap nicht.** `nameHistAppend` hängt nur agreeing Namen an.
- **Namens-Lock.** Nach Mehrheit bleibt die UUID, bis eine *andere* ID die Mehrheit hat. Ein Uneinig-Tick setzt nicht nil.
- **VERSION = Models = MARKETING_VERSION 2.1.41** (Build 68).

## Neu in 2.1.40 alpha

2.1.39 Print-führt — Familie taufte trotzdem nie. `nameAgreeNeed(family:dt:)` verlangt 7 Stimmen bei 8 fps, `nameMajorityAgreeing` schnitt auf Window 5. Overlay zeigte „getauft“, `identityId` blieb nil. Print-führt schrieb den Print-Prozent über LookOf: 82 % unter Floor 84, obwohl Look 86 durch wäre. Margin 8 ließ Genuine mit Geo-Jacke (+4–7) tot.

- **Vote-Fenster ≥ Need.** Familie 7 bei Window 5 tauft. `stabilizeLiveMatches` reicht `cap`.
- **Print-führt behält LookOf.** decide sieht 86, nicht 82. Fremde führen ab Margin 4, Familie bleibt 8.
- **VERSION = Models = MARKETING_VERSION 2.1.40** (Build 67).

## Neu in 2.1.39 alpha

2.1.38 Coach / leftover-Farbe — Live taufte trotzdem nicht. `lookOf` hebt den Geo-Geschwister (Jacke/Haar) über den Print-Sieger, `liveNameAgree` blockt **jeden** Tick. Leftover 0,64–0,79 wischte die Namens-Hist jedes Frame — Genuine blieb orange „gehalten 0,64“.

- **Print führt.** Look≠Print und Print-Abstand ≥ 8 → der Print-Sieger, nicht tot.
- **Leftover hungert nicht.** Wipe nur am Pin. Mehrheit darf taufen, Kiste wird grün.
- **VERSION = Models = MARKETING_VERSION 2.1.39** (Build 66).

## Neu in 2.1.38 alpha

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden:
- [Aegis.dmg (Latest)](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)
- [Releases](https://github.com/lolalpha00gamma/aegis-scanner/releases)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI auf **macos-26** baut das Image nach jedem Push auf `main`.

## Neu in 2.1.38 alpha

2.1.37 leftover-Kiste orange — leftover ≥ 0,80 blieb trotzdem orange, nachdem die Taufe saß. Anlegen sagte nur „Pose fehlt ¾“, nicht wohin den Kopf.

- **Enrollment-Coach.** Overlay + Hinweis: „Kopf nach links drehen (¾)“ / „Blick zur Kamera“ / „halten — ¾ sitzt“.
- **Leftover-Kiste nur unter 0,80.** 0,81 tauft, Box nicht mehr leftover-orange.
- **VERSION = Models = MARKETING_VERSION 2.1.38** (Build 65).

## Neu in 2.1.37 alpha

2.1.36 leftover tauft nicht unter 0,80 — die Overlay-Kiste blieb grün wie eine getaufte Person. Taufe-Hold unsichtbar. Continuity still Fallback.

- **Leftover-Kiste orange**, enrolled grün. Overlay `2/3` bis die Mehrheit sitzt. „Geschwister?“ bei Centroid ≥ 0,80.
- **Slot-Farbe** F/¾/P. **Kamera-Picker** Auto / Built-in / Continuity.
- **VERSION = Models = MARKETING_VERSION 2.1.37** (Build 64).

## Neu in 2.1.36 alpha

2.1.35 hat Familien-Taufe 5 Ticks — bei 8 fps 0,6 s, das leftover 0,64 erbte trotzdem den Namen und die Hist der Vorperson. Look-Delta 8 ohne Centroid-Cosine bremste Fremde. Taufe zählte Frames, nicht Zeit.

- **Leftover tauft nicht unter 0,80.** Overlay `gehalten 0,64` bleibt. Namens-Hist wird gewischt. Nachbar erbt Anna nicht.
- **Close-Pair braucht Centroid ≥ 0,80.** Look 84 vs 80 ohne Nähe ist kein Geschwister.
- **Taufe in Sekunden.** `nameAgreeNeed(family:dt:)` — 8 fps Fremde 3 / Familie 7, nicht 80 ms bei 24 fps.
- **VERSION = Models = MARKETING_VERSION 2.1.36** (Build 63).

## Neu in 2.1.35 alpha

2.1.34 hat VERSION auf 2.1.34 gestellt, Models/pbxproj blieben 2.1.33. Taufe war 2 Ticks auch bei Geschwistern. Leftover-Pin unsichtbar. 2.1.34-Commit behauptete die Fixes, der Code nicht.

- **Familien-Taufe 5 Ticks.** `nameAgreeNeed(family:)` wenn Look-Scores enger als 8 Punkte. Fremde bleiben 2.
- **Hist-Cap `need+3`.** Leere Look≠Print-Tokens hungern die Mehrheit nicht.
- **Leftover-Hold im Overlay** `gehalten 0.64`. Statuszeile denselben Cosine.
- **Rename-Confirm nur gleiche UUID.**
- **VERSION = Models = MARKETING_VERSION 2.1.35** (Build 62).

## Neu in 2.1.33 alpha

2.1.32 hat PTS und Slot-Count — ein einzelner Look=Print-Tick taufte trotzdem. Look≠Print zählte als Stimme. Rename-Confirm klebte. `.bak` ohne fsync. Kleine Boxen rauschten. Overlay ohne Slot und ohne Uneinig-Namen.

- **Taufe 2 Ticks.** `nameMajorityAgreeing` — leere Tokens zählen nicht.
- **Rename-Confirm 8 s tot.**
- **`.bak` fsync** nach dem Copy.
- **1-Euro Cutoff aus Box-Fläche.** Kleines Gesicht rauscht mehr.
- **Overlay Slot + Uneinig-Namen** `F · P 82 · L 82` / `L Anna · P Ben`.

## Neu in 2.1.32 alpha

2.1.31 hat Look=Print und Slot-hart leftover — die Box hing trotzdem einen Frame hinterher, weil 1-Euro die Apply-Wanduhr sah (zwei coalesced Frames → dt 0). `+` ließ den Print-Trail auf dem alten Centroid.

- **1-Euro dt aus dem Kamera-Zeitstempel**, nicht aus dem Apply-Moment.
- **`+` leert den Live-Trail.** Neue Referenz mischt nicht mit der Vorperson.
- **Slot-Count** in der Namensliste `F 2 · ¾ 1 · P 0 · U 0`.

## Neu in 2.1.31 alpha

2.1.30 leftover `sameSlot` fiel auf **alle** Prints, sobald der Pose-Slot leer war — ¾-Ghost taufte den Frontal-Nachbarn. lookOf-Sieger ≠ Print-Sieger taufte trotzdem. Print-Trail mischte Frontal+¾. Namenloser Print-Pin stahl IoU-Hold. Rename ohne Duplikat-Confirm. `gallery.json` ohne fsync.

- **Leftover Slot-hart.** `sameSlot` gesetzt und kein Treffer → kein Pin.
- **Live-Name nur bei ID-Einigkeit.** Look ≠ Print → Overlay „Look und Print uneinig“, keine Taufe.
- **Print-Trail gleicher Slot.** Nicken von Frontal auf ¾ leert den Median.
- **boxPinTakePrint nur enrolled/named.**
- **Rename-Konflikt.** Gleicher Name → nochmal Return.
- **`gallery.json` fsync** nach atomarem Write.

## Neu in 2.1.30 alpha

2.1.29 hat Cap und Cache — leftover pinnt trotzdem den Frontal-Ghost, IoU und Print-Pin flackern zwei Frames, Overlay zeigt nur Print, Rename fehlt.

- **Leftover `sameSlot`.** Gleicher Yaw-Slot zuerst.
- **Print-Pin schlägt IoU-Hold** im selben Pass.
- Overlay **`P 82 · L 82`** (Print roh, Look lookOf).
- **Namen umbenennen** in der Liste (Return).

## Neu in 2.1.29 alpha

2.1.28 scored lookOf mit Pose=1 (Profil wie Frontal). Overlay zeigte den Deckel nicht. Centroids jedes Gesicht neu. Print-Hit war lookOf, nicht Sigmoid.

- **lookOf mit Pose-Gewicht.** ¾/Profil stützt Geo weniger.
- **„Print gekappt“** in der decide-Notiz, Overlay erste Klausel.
- **Centroid/ratioSheet Cache** je Identität×Slot über alle Sonden eines Ticks.
- **Print-Hit = Sigmoid**, `.aegis` = lookOf.

## Neu in 2.1.28 alpha

Live taufte weiter falsch / gar nicht, weil `matchLive` **lookOf ignorierte** (Roh-Print) und Geo-Veto 80–87 % mit Jacke/Haar kippte. Leftover 0,72 ließ Genuine 0,62–0,71 fallen. Unschärfe wanderte in den Print-Trail.

- **`matchLive` = lookOf.** Wie Still: Print führt, Geo stützt, ≥ 80 nie auf 60. Ohne gemessenes Print-Paar 0, nicht Geo.
- **Geo-Veto skip ab 80 %** (war 88). lookOf und decide sagen dasselbe.
- **Leftover 0,64**, scharfer Genuine 0,62 darf den Track halten. Ranking: Schärfe-Bonus, unscharf 0,73 verliert gegen scharf 0,72.
- **Print-Trail verwirft Laplacian unter Floor** (`skipPrint`), nicht nur Hold-Still.

## Neu in 2.1.27 alpha

2.1.26 leftover brauchte Print ≥ 0,80 — Genuine sitzt oft bei 0,62–0,85, der Track war tot. `lookOf` kappte 80–83 % auf 60. Hold-Still IoU 0,82 klebte den alten Print beim Nicken. `liveCentroid` mischte immer alle Vektoren, auch wenn der Slot traf.

- **Leftover-Print 0,72** (`leftoverPrintOk`). Pin-Print 0,80 bleibt für enrolled IoU-Steal.
- **`lookOf` ≥ 80 nie kappen.** Nur Prints < 70 bei toter Geo auf 60.
- **Hold-Still + Schärfe.** IoU 0,70; scharfes Nicken darf, Blur behält den alten Print.
- **Slot-Centroid ohne All-Mean**, wenn der Pose-Slot Refs hat.

## Neu in 2.1.26 alpha

Live-Kisten der Vorperson hingen ein Frame, Mimik-Maße liefen im Webcam-Pfad, Restore überschrieb ohne Warnung, TER-Fusion war default an obwohl `.aegis` sie nicht braucht.

- **Print-Pin gewinnt gegen Hysterese-Box.** `boxEuro` reset, neue Kiste im selben Frame.
- **Live-Maße nur Identität** (keine Mimik). Scan-Tiles cheap-graph, Jacobi bleibt Labor.
- **TER-Fusion Diagnose, default aus.** Restore bestätigt bei Backup ≥ 7 Tage / Schema < 2 / anderer Print.
- **Ampel:** Continuity-Floor als S·, Live-Geo-Spark G72 neben C/S/Y, Track „gehalten“/„neu“.
- **`enrolledAt` paler** ab 90 Tagen. Live-Kopie bekommt unsichtbare Snapshot-Media-Row (Browse zählt sie nicht).
- Labor: extra Zeile Genuine vs U-Slot.
- MARKETING_VERSION 2.1.26 (Build 54), `Models.swift` + `VERSION` gleich.

## Neu in 2.1.25 alpha

2.1.24 hat Geo je Pose-Slot — Live blieb weich, weil der **Print** 72/28 über Frontal+Profil mischte. Leftover klebte die ältere UUID. Bewegung schrieb trotzdem einen neuen (unscharfen) Print.

- **Live-Centroid je Pose-Slot.** ¾ gegen ¾, 72/28 nur Fallback.
- **Leftover nächster Print**, Statuszeile wenn ein Track pinned.
- **Yaw-Skip sichtbar** (`¾, Maße ignoriert`).
- **Hold-Still:** IoU < 0,82 behält den alten Print.
- **Pose-Meter** in der Anlegen-Statuszeile (Frontal+¾ Pflicht).

## Neu in 2.1.24 alpha

2.1.23 hat echte Geo — Namen flackerten trotzdem, weil leftover die **Galerie-UUID** suchte. Live-Tracks haben seit 2.1.17 eigene UUIDs, leftover war tot. ¾-Sonden liefen gegen den Frontal-Maß-Median, Geo-Veto kippte echte 80–87 %-Prints.

- **Leftover am named Live-Track**, nicht an `identities.faceIds`. Ohne Print kein Pin.
- **Geo je Pose-Slot** (¾ vs. ¾). Yaw ≥ 0,28 und Print ≥ 80 vetoiert nicht.
- **`gallery.json` Schema 2.**
- Track-Pin-Print-Veto gilt dem genannten Live-Track.

## Neu in 2.1.23 alpha

2.1.22 hat Track-Pin 0,28 — Live taufte trotzdem, weil **Geo-Veto tot war** (`geoAgrees` immer true, `geoMix` = Print-Prozent). Leftover klebte eingeschriebene UUIDs auf den Nachbarn. IoU setzte die ID auch bei Print-Cosine 0,45.

- **`matchLive` echte Landmark-Geo** (Median der Identitäts-Maße). Fehlende Geo vetoiert nicht.
- **Leftover nur namenlose Boxen**, plus Print-Veto wie IoU.
- **IoU stiehlt die UUID nicht**, wenn Cosine gemessen und unter 0,80 liegt. 1-Euro der falschen Kiste wird geleert.
- Overlay zeigt die **erste Klausel** der decide-Notiz, nicht den Roman.

## Neu in 2.1.22 alpha

2.1.21 hat leftover 0,28 und lookOf ohne 60-Deckel — Live taufte Nachbarn trotzdem, weil der **enrolled Track bei IoU 0,12 klebte**. Overlay schrie „andere Person“, sobald Cosine unter 0,88 lag (Genuine sitzt oft bei 0,62–0,85). `matchLive` baute den Centroid ungewichtet über alle Posen und behandelte Continuity immer als Built-in. 1-Euro hing bei 8 fps einen Frame hinter der Box. Namensmehrheit hielt eine gelöschte UUID.

- **Track-Pin 0,28** auch für eingeschriebene Live-IDs (`MatchMath.trackPin`). 0,12 hat dem Nachbarn die UUID geklaut.
- **Live-Centroid 72/28** Frontal vs. alle Refs — Profile verdünnen den Treffer nicht.
- **Overlay-Alien erst unter Cosine 0,50**, gegen denselben Live-Centroid. Genuine 0,75 ist kein „andere Person“.
- **`tinyUnreliable(continuity:)`** aus der Webcam, nicht hart `false`.
- **1-Euro Cutoff ×1,7** bei dt ≥ 0,10 s (Continuity 8 fps).
- **Namensmehrheit** überspringt leere Prints; fehlende UUID wird gelöscht, nicht als Geist gehalten.

## Neu in 2.1.21 alpha

2.1.20 hat Centroids und boxEuro-Reset — echte Live-Prints fielen trotzdem durch: `lookOf` kappte 90 % auf 60 sobald Jacke/Haar die Landmark-Geo ruiniert hat. Geo-Veto kippte 93 %. Overlay sagte nur „nicht zugeordnet“.

- **Starker Print bleibt Print.** ≥ 84 % wird nicht auf 60 gedeckelt. Geo-Veto skippt ab 88 %.
- **5-Tick-Namensmehrheit** plus Prozent der gewählten Person, nicht der Roh-Besten.
- **Leftover-IoU 0,28.** Auswahl klebt am Track.
- Overlay zeigt den decide-Grund.

## Neu in 2.1.20 alpha

Live hat jedes Galerie-Foto jedes Frame neu gescoort, Profile ohne Vision-Yaw landeten im Frontal-Slot, Crop-Prints wurden ein zweites Mal rotiert, `boxEuro` überlebte den Kamerwechsel, und der dritte Frontal hat den fehlenden ¾-Slot weiter zugemüllt.

- **Live-Match nur Centroids.** `matchLive`: eine Sonde × ein Mittelvektor pro Identität, nicht das volle Ensemble. Danach 3-Tick-Namensmehrheit aus 2.1.19.
- **Median-Blend** der letzten 5 Live-Prints statt reinem One-Euro-alpha.
- **Yaw aus Landmarks**, wenn `face.yaw` ≈ 0. Profile werden nicht mehr als Frontal eingeschrieben.
- **Crop-Print immer `.up`** auf schon aufrechten Pixeln.
- **Coverage blockt** den 3. gleichen Slot, solange Frontal oder ¾ fehlt. Warnung bleibt für den Rest.
- **`boxEuro` / Print-Trail hart leer** beim `cameraUniqueID`-Wechsel.
- **Leftover-IoU** heißt `MatchMath.leftoverIoU` (0,18). Anlegen bestätigt ab Centroid 0,82.
- Labor: Centroid-Cosine-Matrix zwischen Identitäten.

## Neu in 2.1.19 alpha

2.1.18 hat Geister-Kisten und Pin-Print 0,80 — Live taufte trotzdem Geschwister um, weil `rematchLive` jedes Frame den Roh-Namen schrieb. `.aegis` remixte lookOf nochmal mit Geo/Graph/Textur (Kleidung = Identität). Geo-Veto kippte 93 %-Prints. Jeder Live-Frame lief 4 Jacobi-Eigensolver + Floyd–Warshall. `gallery.json.bak` existierte ohne Taste.

- **3-Tick-Namensmehrheit + Score-EMA** auf Live (von `bugfix` 2.1.15, auf `main`).
- **`.aegis` print-led.** `lookOf` ist der Score, sobald ein Face-Print da ist. TER-Fusion bleibt eigene Spur, tauft nicht.
- **Geo-Veto weich.** 90 %+ Print braucht Geo < 22 zum Blocken, nicht 42/94.
- **Live-Graph billig.** Distanz-Statistik, kein Jacobi pro Webcam-Frame.
- **Gallery-Restore.** Taste „Backup“ lädt `gallery.json.bak`.
- **Burst-Prune beim +.** Cosine > 0,98 ersetzt die unschärfere Kopie.

## Neu in 2.1.18 alpha

- **Keine Geister-Kisten.** Live ohne Gesicht räumt den Track. Enrolled-Kopien bleiben in der Galerie (anderes `mediaId`).
- **Pin-Print 0,80.** 0,72 hat Geschwistern die UUID geklebt.
- **Leftover-IoU 0,18** statt 0,08 — Nachbar erbt die ID nicht.
- **Webcam: Front-Wide zuerst**, wie Helios. Continuity/Desk-View nicht als Default.
- **Labor** nutzt Continuity-Floor 0,08 für eingeschriebene Refs (0,10 fliegt nicht mehr raus).
- **Burst-Kopien** stehen in der Statuszeile, nicht still.
- **`+` bleibt aktiv** bei vollem Namensfeld — Caption sagt dasselbe wie der Button.

## Neu in 2.1.17 alpha

- **Live + Anlegen/Hinzufügen:** der Track behält seine UUID. Galerie bekommt eine Kopie. `+` sagt nicht mehr „schon Referenz“, während das Gesicht vor der Kamera sitzt.
- **Pose-Slot blockt nicht mehr.** Dritter Frontal wird gespeichert, Status warnt wenn ¾ fehlt.
- **`+` bleibt aktiv**, auch wenn das Namensfeld nicht leer ist.

## Neu in 2.1.16 alpha

- **OneEuro-Init öffentlich.** CI-Test kompiliert; erstes grünes DMG seit 2.0.3.
- **familyBump pro Paar.** Ein Geschwisterpaar hebt nicht mehr den Floor der ganzen Galerie. Obere Grenze 0,88 ist weg — Zwillinge bei 0,91 bekommen den +4-Bump.

## Neu in 2.1.15 alpha

2.1.14 stand in `Models.swift`/`VERSION`, CI taggte aber **2.1.13** (`MARKETING_VERSION`). `rematchLive` und Continuity-Blend 0,20 waren in der Liste, nicht im Live-Pfad. Von `bugfix` (Altlast, nicht fortgesetzt) nur die fehlenden Helfer auf `main`. TAR bleibt `floor(far·n)−1`.

- **Live-`rematchLive`:** nur Live-Sonden + Galerie-Refs, nicht die Scan-History jedes Frame.
- **Continuity-Blend 0,20** / Built-in 0,35 (`liveBlendAlpha`).
- **Box-Hysterese:** IoU < 0,35 hält die alte Kiste ein Frame, zweites Frame bestätigt den Sprung.
- **Ingest-Duplikat:** Cosine > 0,95 (Burst/Tile) fliegt raus, bevor die Galerie wächst.
- **Labor:** unscharfe Leave-one-out-Paare raus; Genuine/Impostor-Histogramm.
- **`gallery.json.bak`** vor jedem Save.
- **`enrolledAt`** am Face; Spark-Reset nach `pinByPrint` (Ghost-Ampel nicht erben).
- MARKETING_VERSION 2.1.15 (Build 43).

## Neu in 2.1.14 alpha

(Claim, nicht vollständig im Binary — siehe 2.1.15.) Continuity-Floor, Live-Coalesce und U-Slot aus 2.1.13 bleiben.

## Neu in 2.1.13 alpha

Continuity/Desk-View hat in 2.1.12 den Print erzeugt (Floor 0,08) und ihn in `qualityRejects` sofort verworfen (Floor 0,12). Dazu:

- **`qualityRejects(continuity:)`** teilt den Floor mit `skipPrint`. Overlay, Ampel, Enrollment, `tinyUnreliable`.
- **Live coalesct** den letzten Frame, statt ihn hinter Detect zu droppen.
- **U-Slot-Vorschlag** nach 1,2 s Maske im Track — Taste U, nie still geschrieben.
- **Labor:** Impostor frei vs Teil-Print, TAR ohne Masken-Paare, eine Orient-Zeile Auto vs Override vs EXIF.

## Neu in 2.1.12 alpha

PR #3 (`bugfix` 2.1.7–2.1.11) auf `main` gezogen, plus die offenen Kleinfixes:

- Orient-Override pro Kamera, Taste U, Live-Ampel, Schärfe vor Print
- Teil-Print gegen Teil-Centroid, Maske nicht als erste Referenz
- Live-Box 1-Euro mit Reset nach Reconnect
- TAR `floor(far·n)−1` (n=10 und n=101)
- Ampel über 8 Frames, max. 2 Extra-Tiles, Continuity-Schärfe 0,08
- Orient-Menü vor Webcam-Start, „doch Name“, Labor Genuine frei vs Maske
- TER in decide, Print-Cache, Buffer-Kopie, CSV-Quotes

## Neu in 2.1.6 alpha

- **CI wieder grün.** TAR@FAR-Index ist `floor(far·n)−1` (101 Impostoren → Schwelle 80, nicht 10). Tests laufen nach dem App-Build, nicht davor.
- **LibraryStore Live-Task** fängt `self` nicht mehr in `Task.detached` ein.
- **Live-Print: Median**, nicht Mittel. [95, 92, 5] bleibt 92.
- **Pose:** `yaw`/`pitch` optional. Fehlende Pose ≠ perfekt frontal; Frontalität 0 bekommt nicht Gewicht 1.
- **3D-Spur** ist nur noch `1/cos`-Entzerrung. Der z-Lift war Dekoration in der Bildebene.
- **TER fließt in decide**, nicht nur in die Anzeige.
- Live-Pixelbuffer und Equalize-Gray werden kopiert, bevor der Puffer recycelt wird.
- CSV mit Quoting. Scoped-Access einmal start, einmal stop. Print-Vektor-Cache.

## Neu in 2.1.4 alpha

- **Live-Print als 3-Frame-Mittel**, nicht „schärferes Frame behalten“. Ein Glücks-Frame tauft nicht mehr.
- **Box-EMA** auf dem Live-Track. Der Kasten zittert nicht mit jedem Detektor-Frame.
- **~11 fps** statt ~5,5 (0,09 s Throttle).
- **TAR@FAR-Index** `ceil(far·n)−1`. 10 % von 10 Impostoren ist der höchste, nicht der zweite.
- **toHit liest `floors.match`**, nicht hart 78.
- **Slider zeigt den effektiven Floor** (`78 → Floor 84` bei einer Person).
- **Ablehnungsgrund am Overlay**, wenn kein Name gesetzt ist.
- **Webcam: Built-in Wide** vor Continuity/Front-Treffer.
- **printHistory** bleibt RAM-only, nicht in `gallery.json`.

## Neu in 2.1.3 alpha

- **0,4 % Print ist kein „KI aus“.** Impostor-Cosine fiel auf Geometrie und taufte Fremde.
- **Name nur nach `decide`.** Prozent ≥ Slider reicht nicht mehr fürs Overlay.
- **Keine Geister-Kästen**, wenn die Kamera niemanden sieht.
- **Anlegen ohne Face-Print** (KI an) oder mit toter Qualität wird abgelehnt.
- **Labor TAR @ 0,1 % / 1 % FAR.** Floors nicht mehr process-weit.
- **Webcam:** Frontkamera, Landscape-Orientierung.

## Neu in 2.1.2 alpha

- **Print-Sigmoid ehrlich.** Mitte 0,55 statt 0,42 — Impostor-Cosine 0,45 ist ~20 %, nicht 58 %.
- **Kein Galerie-Max.** Score ist das Mittel der besseren Hälfte der Referenzen, nicht der Glückstreffer.
- **Maße vetoen wieder.** `decide` hat `geoAgrees`/`geoMix` ignoriert. Widerspruch unter 42 % → kein Name unter 94 % Print.
- **Galerie-Floor.** 1 Person 84, 2–3 80, ≥4 78. Der Slider bleibt ein Bias um 78.
- **Eine Print-Stimme.** Ensemble nimmt nicht max() über fünf Kopien desselben Embeddings.
- **Kein Jacken-Print.** Crop-Fallback nur wenn Vision auf dem ganzen Foto keinen Face-Print findet.
- **Live ~5 fps**, Overlay-Badge Print tot / 99 %, Pin-IoU 0,12, keine Geister-Kästen.

## Neu in 2.1.1 alpha

- **Kein Name ohne Face-Print**, solange die KI-Spur an ist. Leerer Print fällt nicht mehr auf Geometrie und tauft Fremde. KI aus bleibt reines Maß-Matching.
- **Print-Zuordnung IoU 0,32.** 0,20 hat Nachbar-Prints an die falsche Box gehängt.
- **NMS kennt Tile-Zwillinge.** Gleiche Mitte, zwei Detektoren → eine Person.
- **Live-Anlegen hält die ID.** Nächstes Frame überschreibt die eingeschriebene UUID nicht mehr (Geister-Person).
- **Ingest 1280 px, ohne ImageIO-Cache.** 2048er-Previews haben Ordner-Scans aufgeblasen.

## Neu in 2.1.0 alpha

- **Spuren einzeln.** Jede Erkennung hat einen Schalter. Aus = keine Stimme in der Fusion, kein Name von Aegis wenn Aegis aus ist. Gruppen KI / 2D / 3D / Fusion.
- **nicht gemessen ≠ 0 %.** Leerer Face-Print oder fehlende Landmarks stehen als Text, nicht als Null.
- **3D-Anhebung.** Yaw/Pitch heben 2D-Landmarks in die Frontalebene. Kein neuronales 3DMM — ehrlich so benannt.
- **Aussehen: Tan–Triggs + LBP** statt Helligkeitsraster.
- **Mahalanobis** auf den Gesichtsmaßen, sobald genug Referenzen da sind.
- **Laborbericht.** Leave-one-out Genuine/Impostor, EER-Schätzung. Jede Person braucht mindestens zwei Fotos.

## Neu in 2.0.8 alpha

- **Print führt, Maße stützen.** `lookOf` ist 0.75·Embedding + 0.25·Geometrie. Ein 99 %-Print hebt Profil/Brille über die Schwelle; ein 4 %-Print kann eine fremde Person mit ähnlichen Verhältnissen nicht mehr zuordnen.
- **Geometrie-Veto.** Maße unter 35 % deckeln den Score auf 60 — kein Name ohne Gesichtsübereinstimmung, aber Jacke/Pose killt die Identität nicht mehr.
- **Zwei Personen in der Galerie.** `galleryZ` fällt nicht mehr auf den Nenner 6 (stille 9-Punkte-Marge). Eine Rivalin ist Sache des Abstands, nicht eines Ein-Punkt-z-Scores.
- **Yaw/Pitch.** Vision-Pose dämpft das Geometrie-Gewicht. IOD-Verhältnisse blocken kein Profil mehr.
- **Ein Tor in `decide`.** Die fünf redundanten Geometrie-Prüfungen sind eins: Score ≥ Schwelle und Abstand.

## Neu in 2.0.7 alpha

- **Faktoren, keine Pixel.** Aegis ordnet über IOD-Verhältnisse, Procrustes-Form und Graph. Raster und Face-Print haben keine Stimme mehr bei der Namensvergabe.
- **4 % Print tötet Identität nicht.** Dieselbe Person in anderer Jacke/Pose bleibt die Person, wenn die Maße passen.
- **Schwelle 78.** Ehrliche Geometrie-Scores können zuordnen, ohne Raster-Mittelwert unter die alte 86er-Latte zu fallen.

## Neu in 2.0.5 alpha

- **Galerie persistiert.** IdentityDesk ist im Target, `gallery.json` wird geladen und nach Anlegen/+ /Löschen geschrieben.
- **Scan ohne Beachball.** Detektion in `Task.detached`, ein kaputtes Foto beendet nicht den ganzen Ordner.
- **Keine gefälschten 96 %** auf Referenzen. Was 0 gemessen hat, bleibt 0.
- **Slider wirkt.** 70…96 ist `matchFloor`, nicht nur das Overlay-Label.
- **NMS = duplicateDetection.** Zwei Leute nebeneinander bleiben zwei Detektionen.
- **Face-Print tot → Status sagt es.** Kein stilles 0 % als „gemessen“.
- ATS nur noch Local Networking. Snapshot-Polling ohne Request-Stau. EXIF-Fallback ohne 90°-Drift.

## Neu in 2.0.4 alpha

- **Echter Face-Print.** `VNGenerateFacePrintRequest` läuft auf dem ganzen Foto. Warp auf 256 px hat den Face-Print oft scheitern lassen — dann wurde still der Bild-Print der Jacke gespeichert.
- **Kein Bild-Print mehr als Identität.** Khaki vs. Warnweste war 4 %, weil Park≠Auto, nicht weil die Gesichter fremd sind. See-links 84 % gegen Lin R war dieselbe Falle.
- **Mehrere Referenzen zählen.** Jedes eingeschriebene Foto bekommt einen Gesichts-Print, nicht ein Kleidungs-Embedding.

## Neu in 2.0.3 alpha

- **Aussehen ist die Basis.** Aegis hängt den Namen an Maße, Form, Augen, Kiefer — nicht am Face-Print.
- **Print darf nicht mehr killen.** Dieselbe Person in anderer Jacke/Pose (97 % Form, 4 % Print) bleibt die Person, nicht 8 % unbekannt.
- **Raster ohne Histogram-Equalize.** Lichtausgleich hat Identität zerstört. Ein totes Raster zieht die Form nicht mehr auf 0 %.

## Neu in 2.0.2 alpha

- Version in der App, im Image und im Release heißt **2.0.2**. Nicht mehr 1.0.18.
- Eingeschriebene Gesichter bleiben gespeichert. Anlegen gilt für das sichtbare Foto.

## Neu in 1.0.18 alpha

- **Anlegen bleibt Anlegen.** Steht ein Name im Feld, erzeugt Enter und selbst ein Klick auf **+** eine neue Person — nicht eine Referenz zu Person 2.
- **Zwei Leute nebeneinander** (Riders, Freunde) sind keine Dublette. Nur echte Überlappung derselben Detektion zählt als schon benannt.
- Ein Match ohne Referenz heißt **Nähe**, nicht der Name. Person 3 bleibt unbenannt, bis du Anlegen drückst.

## Neu in 1.0.17 alpha

- **Dritte Person anlegen.** Anlegen hängt nicht mehr still an Person 2, nur weil zwei Porträts ähnliche Pixel-Boxen haben. Boxen zählen nur auf demselben Foto. Sitzt die Auswahl noch auf Person 2, nimmt Anlegen das unbenannte Gesicht auf dem sichtbaren Foto. Return legt an. `+` bleibt nur für extra Referenzen derselben Person.

## Neu in 1.0.16 alpha

- **Ordner blättern.** Nach dem Ordner wählen: Pfeile auf dem Bild, `←` `→` auf der Tastatur, Zähler in der Titelleiste (`3 / 12`). Das Filmstrip scrollt mit.

## Neu in 1.0.15 alpha

- **Face-Print statt Bildähnlichkeit.** macOS nutzt `VNGenerateFacePrintRequest` (Gesichtseinbettung, dieselbe Modellklasse wie Fotos) und Cosinus auf dem Rohvektor. Histogram-Equalize vor dem Print ist raus — das hat Identität zerstört.
- **Prozente wie 2024/25-Erkennung.** Dieselbe Person (frontal, ¾, Brille) landet bei 95–99 %, Fremde bleiben unter 10 %. Die alte Kurve hat echte Matches auf 50 % gedrückt.
- **Aussehen-Veto greift nicht mehr bei Brille/Licht**, sobald der Face-Print klar ist. Das 16×16-Raster darf nur noch echten Widerspruch blocken.

## Neu in 1.0.14 alpha

- **Schlechtes Licht.** Dunkelheit zählt nicht mehr als Unschärfe. Detektor wiederholt auf helligkeitsausgeglichenem Bild. Feature Print und Aussehen sitzen auf einem luma-ausgeglichenen Crop.
- **Prozente.** Bei dunklen, aber großen Gesichtern mischen sich Verhältnisse in die Aegis-Zahl. Winzige Crowd-Gesichter bleiben unbekannt — Embedding allein reicht dort nicht.
- **Aussehen-Veto** greift nur, wenn die Aufnahme hell genug ist, dass das Raster stimmt.

## Neu in 1.0.13 alpha

- **Gesichtsform = Verhältnisse, nicht Lage.** Nase, Kiefer, Wangen, Höhe in Einheiten des Augenabstands. Unabhängig von Position im Bild, Größe und Mimik (Mundöffnung und Lidschlag zählen nicht).
- **Feature Print ist die macOS-Identität.** Das 16×16-Helligkeitsraster darf nur widersprechen, nie zuordnen. Die Prozentkurve ist auf echte Feature-Print-Distanzen kalibriert.
- **Sichtbare Verhältnisse** in der Seitenleiste, mit Abweichung zur Referenz in Prozent.

## Neu in 1.0.12 alpha

- **macOS-Anatomie sitzt auf dem Gesicht.** Vision-Landmarks wurden fälschlich auf das ganze Bild skaliert (Augen auf der Stirn, Nase auf der Wange). Jetzt relativ zur Face-Box, wie Apple es liefert.

## Neu in 1.0.11 alpha

- **Sichtbare Anatomie** — Augen, Brauen, Nase, Nasenbreite, Mundwinkel, Mundmitte, Kinn, Kontur, Haaransatz, Ohren als Mesh auf dem Foto. Gestrichelt: eingeschriebene Referenz.
- **Echte Nähe** zwischen zwei Fotos (FaceNet + Form), unabhängig von der Zuordnung. Ein toter FaceNet-Vektor zählt nicht mehr als 0 % Identität.

## Neu in 1.0.10 alpha

- **Anatomie-Overlay** — Augen, Brauen, Nase, Nasenflügel, Mundwinkel, Mundmitte, Kinn, Kontur, Haaransatz, Ohren direkt auf dem Foto.
- Abweichung zur eingeschriebenen Referenz pro Region, wenn das zweite Bild 0 % zeigt.

## Neu in 1.0.9 alpha

Aus den Papieren (Varghese, Cheese3D, Jain, Wu/Wan, Hassan):

- **Graph-Biomarker** — KNN-6 Spektralenergie (GE, LE, DE, DistE, SLE), alterungsstabil. Jetzt auch in der macOS-App.
- **3D-Geometrie** — Distanzen, Winkel, Flächen aus Landmark-Formen (Cheese3D-Analog).
- **TER-Fusion** — Matcher-Scores → Total Error Rate, min-max nach Jain. Diagnostisch: nennt keine Personen.
- **EER / FAR / FRR** — im Laborbericht (Jain Kap. 1).
- Soft Biometrics nur als **alterungsstabile Geometrie-Veto**. Keine Geschlechts- oder Ethnizitätsklassifikation.

Aegis Ensemble bleibt beweisbasiert: Embedding muss hoch liegen. Verhältnisse und Textur dürfen nur widersprechen.

## Lizenz

MIT
