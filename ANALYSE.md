# Helios + Aegis — Analyse 2026-09-05 (2.1.111)

Helios **1.5.95** (Build 115). Aegis **2.1.111 alpha** (Build 137). CI 2.1.109: `¾ kein Trail` — leftoverTrailWriteOk schreibt Pose-Bin seit 2.1.104. Test auf Hash-Bin.

# Helios + Aegis — Analyse 2026-09-05 (2.1.110)


Helios **1.5.94** (Build 114). Aegis **2.1.110 alpha** (Build 136). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.109: JPEG-Probe, Schema 5, IoU-Jump, Per-Bin Adopt, 0° Orient. Probe-nil taufte Poster. JPEG jede Frame auf Main. RTSP-Timer .default. Cache ohne Hash. Crop-Fail nicht gecacht. Gate ohne jpegRequired.

## 2.1.109 → 2.1.110 (warum Namen nach Poster und bei 15 fps noch sprangen)

1. **`leftoverBaptizeJpegOk(nil) = true`.** Gate misst, Crop/Print-Fail = nil = Taufe. Poster durch.
2. **`FaceEngine.jpegProbeDelta` jede Taufe-Kandidat-Frame auf Main.** JPEG 70 % + Vision-Print = 15 fps Jank, Hunt hungert.
3. **LiveCapture Timer .default.** Grab coalesced während SwiftUI-Paint.
4. **JPEG-Cache nur Treffer.** Crop-Fail = nil nicht merken = jede Frame reextract.
5. **Cache ohne Hash/Cosine.** Poster in derselben Box erbt 0,03 für 0,80 s.
6. **`leftoverBaptizeGate` ohne jpegRequired.** Spike-Pfad umging das Transfer-Gate.

## Was 2.1.110 ändert

1. **`leftoverBaptizeJpegOk(_, required:)`.** Print da → Probe Pflicht. leftoverTransfersId `jpegRequired`. Gate denselben Schalter.
2. **`leftoverJpegProbeReuse` 0,80 s.** Hash- oder Cosine-Sprung 0,04 = Miss. `leftoverJpegProbePut` merkt Crop-Fail (−1).
3. **Timer `.common`** analog Helios Fill.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.110 (Build 136).

Helios 1.5.94: Ghost-Hochpass, AX 16 px, Ring kein Sturm, Enhance nur Nacht, destEdge 5K, Timer .common, PREDICT, Wrist-Abort. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.


# Helios + Aegis — Analyse 2026-09-05 (2.1.109)

Helios **1.5.93** (Build 113). Aegis **2.1.109 alpha** (Build 135). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.108: Spark-Peek, PickLuma, BaptizeGate, Blink-Streak, Name-AND. JPEG-Gate tot ohne Probe. Hold-Bins sterben mit dem Prozess. Box-Steal tauft. ¾ Adopt 0,80 s. Portrait .right bei 0°.

## 2.1.108 → 2.1.109 (warum Namen nach Restart und bei Twins noch sprangen)

1. **`leftoverBaptizeJpegOk(nil) = true`.** Gate sitzt, FaceEngine misst nicht — Poster taufen.
2. **leftoverHoldTrailBins nur RAM.** Schema 4, App-Neustart = Spark/HOLD tot, erste Taufe hungert.
3. **IoU-Sprung keine Taufe-Sperre.** Twin stiehlt die Box, leftoverTransfersId 0,82 tauft den Nachbarn.
4. **`leftoverAdoptNeedSec` ignoriert Yaw.** ¾ bei 15 fps 0,80 s = 12 Frames, Twin in Pose.
5. **`liveOrientationRaw` height>width → .right.** Capture 0°, Box 90° nach Desk-View.

## Was 2.1.109 ändert

1. **`FaceEngine.jpegProbeDelta`.** JPEG 70 % Reextract, `leftoverJpegProbe` in leftoverTransfersId.
2. **gallery.json Schema 5.** leftoverHoldBins + leftoverHoldTrailBins persist.
3. **`leftoverIoUJumpBlocks` 0,40.** Box-Steal keine Taufe, HoldsTrack auch tot.
4. **`leftoverAdoptNeedSec(dt:yawAbs:)`.** ¾ 1,2 s, frontal Lock 0,80 s.
5. **`liveBufferOrientation`.** 0° Capture .up.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.109 (Build 135).

Helios 1.5.93: STEAL-HUD, 0° Vision, Hochpass je Hand. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.108)

Helios **1.5.92** (Build 112). Aegis **2.1.108 alpha** (Build 134). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.107: Hash-Spark, Spark-Hold mutierte im SwiftUI-Body. leftoverPickLuma tot. leftoverBaptizeGate tot. Blink sticky. Name-Mehrheit ohne 3-Tick. Thermal-Math tot. Hunt ignorierte leftoverStreak.

## 2.1.107 → 2.1.108 (warum Namen noch sprangen / Spark flackerte / Indoor tot)

1. **`leftoverSparkChip` mutierte `leftoverSparkChipHeld` im Body.** SwiftUI 8 fps Peak-Hold zählt jedes Paint, Overlay flackert.
2. **Frame-Luma nil → Capture-Box 0,18.** Center Stage, Indoor 420v Nacht-Softmax. leftoverPickLuma ungenutzt.
3. **`leftoverTransfersId` rief leftoverBaptizeBoth, nicht leftoverBaptizeGate.** JPEG-Veto tot.
4. **`liveBlinkSeen` sticky true nach einem Lid.** leftoverBaptizeQuality blink:true blockt Taufe danach für immer. Lid-Gap 2 Frames offen fehlte.
5. **Name-Mehrheit 5 ohne 3-Tick-AND.** Geschwister springen Overlay. leftoverLiveNameHolds tot.
6. **Overlay liveScoreEMA ohne Score-Tick.** Ein Twin-Frame 0,90 bleibt 3 Ticks im HUD.
7. **`liveThermalHolds` tot.** Hunt 10 / Lock 15 gegen thermal 8 fps.
8. **`setFacesPresent` ohne leftoverStreak.** Hunt 10 bis facesPresent-Latch, nicht erste Begegnung.

## Was 2.1.108 ändert

1. **`leftoverSparkChip` peek.** Tick in `stabilizeLiveMatches`. Body mutiert nicht.
2. **`leftoverPickLuma` in leftoverSessionCapturePrefersFrame + applyLiveFaces.**
3. **`leftoverBaptizeGate` in leftoverTransfersId** inkl. leftoverBaptizeJpegOk.
4. **`leftoverBlinkLiveness` open-streak.** Taufe erst nach 2 offenen Lidern.
5. **`leftoverLiveNameAnd`** Mehrheit UND 3-Tick.
6. **`leftoverScoreTickOverlay`** 3-Tick-Mittel, sonst EMA.
7. **`liveMinIntervalThermal` in FrameTap.** 2 s unter 12 → Floor 8 fps.
8. **`setFacesPresent(streak:)`** leftoverStreak ≥ 1 = Lock.
9. Tests + VERSION = Models = MARKETING_VERSION 2.1.108 (Build 134).

Helios 1.5.92: Enhance 420, Slot-Steal, ROI 8 fps, Hochpass-Slider. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.107)

Helios **1.5.91** (Build 111). Aegis **2.1.107 alpha** (Build 133). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.106: leftoverAdopt Lock 0,80 s, Hunt 10 fps, overlayChipPeakHold Math. Spark-HUD nicht verdrahtet. UUID-Steal leert Bin-Trail.

## 2.1.106 → 2.1.107 (warum Spark nach Steal und 8 fps noch tot/flackerte)

1. **leftoverSparkChip nur leftoverHoldTrailBins[id.bin].** UUID-Steal: neuer id, leerer Bin. leftoverLastHash + leftoverSparkTrailOf halten Hash.
2. **overlayChipPeakHold nicht in leftoverSparkChip.** 8 fps Overlay flackert.
3. **Frame-Luma nil.** Capture-Luma ungenutzt.

## Was 2.1.107 ändert

1. **`leftoverSparkTrailOf` / leftoverLastHashKeeps.** Hash überlebt UUID-Steal.
2. **`leftoverSparkChipHold`** verdrahtet overlayChipPeakHold.
3. **`leftoverBaptizeGate` / leftoverPickLuma / videoStabilizationApplies** (`#if os(iOS)`).
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.107 (Build 133).

Helios 1.5.91: native 420-Ring, flingFromTrail, Klappe-Wake. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.106)


Helios **1.5.90** (Build 110). Aegis **2.1.106 alpha** (Build 132). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen, Ideen nachgezogen.

## 2.1.105 → 2.1.106 (warum Namen bei Hunt und 15 fps noch hungerten)

2.1.105: leftoverHoldTrailBins, BaptizeQuality, Score-Tick. leftoverAdoptNeedSec ignorierte dt — hart 1,2 s bei 15 fps = 18 Frames, erste Taufe stirbt. Hunt Built-in 8 fps. Spark 8 fps ein Frame, Overlay flackert. JPEG-Poster und 1-Frame-Blink taufen. Center Stage kommt mit Continuity-Reconnect zurück. Thermal-Hop analog Helios fehlte.

## Was 2.1.106 ändert

1. **`leftoverAdoptNeedSec` Lock 0,80 s** bei 15/24 fps (12 Frames). 8 fps bleibt 1,2 s. dt ≤ 0 = Continuity-Takt 1,2.
2. **`liveMinInterval` Hunt 10 fps.** streak ≥ 1 → Lock 12/15. Built-in nicht mehr 8.
3. **`overlayChipPeakHold` 2 Frames.** Spark 8 fps nicht flackern.
4. **`leftoverBaptizeJpeg` / `leftoverBlinkLiveness`.** Poster und Lid-Gap vor Taufe.
5. **`liveThermalHolds` 2 s unter 12.** Analog Helios.
6. **`reconnectCenterStageOff`.** setFacesPresent Continuity CS nochmal aus.
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.106 (Build 132).

Helios 1.5.90: Fill-Coast je Achse, Pinch-Uhren, Dead-Man HUD. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.105)

Helios **1.5.89** (Build 109). Aegis **2.1.105 alpha** (Build 131). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen, Ideen nachgezogen.

## 2.1.104 → 2.1.105 (warum Namen in ¾ noch sprangen)

2.1.104: leftoverTrailWriteOk ohne Yaw-Block, Hash-Bin schreibt, leftoverHoldTrail[id] frontal. Spark las leftoverHoldTrailOf ohne binTrail → [] in ¾. HOLD-Chip roh = EMA. leftoverBaptize nur Cosine: Blur/Blink/Profil tauften. Score-Tick und Live-Name 3-Tick lagen auf bugfix 2.1.15.

## Was 2.1.105 ändert

1. **`leftoverHoldTrailBins`.** Spark und HOLD roh je Pose-Bin.
2. **`leftoverHoldOverlayChipOf` / leftoverCosineSparkLabelOf.** ¾ nicht Frontal-UUID.
3. **`leftoverBaptizeQuality`.** Blur, Blink, Profil ≥ 0,45 keine Taufe.
4. **`leftoverScoreTickPut` / `leftoverLiveNameHolds`.** Math aus bugfix 2.1.15. Overlay bleibt liveScoreEMA, Vote bleibt Mehrheit.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.105 (Build 131).

Helios 1.5.89: destEdgeFillAxis, Dead-Man Faust, USB-Hysterese. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.104)

Helios **1.5.88** (Build 108). Aegis **2.1.104 alpha** (Build 130). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26. Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

## 2.1.103 → 2.1.104

2.1.103 (main): CI-Fix. Swift-Overlay `availableVideoPixelFormatTypes`, Parameter `videoOut` (nicht `output` / AVPlayerItemVideoOutput). Live: Tap 5 fps, RotationCoordinator dreht den Buffer, leftoverTrailWriteOk blockt Yaw ≥ 0,28, Spark liest Frontal-UUID in ¾, Desk-View 4:3 tot, reselectFormat Queue-Hop.

## Warum Namen nach 2.1.103 noch sprangen / tot wirkten

1. **`FrameTap minInterval` 0,20 / 0,125.** Hunt 5 fps, Lock 8 fps. leftoverAdoptNeedSec 1,2 s = 6–10 Frames. EMA und Taufe hungern. Helios pumpt jeden Frame.
2. **`RotationCoordinator` Horizon-Level.** Helios 1.5.58 hat das getötet: physisches Drehen, Box 90°, leftover stiehlt. Aegis hatte denselben Pfad noch.
3. **`leftoverTrailWriteOk` Yaw ≥ 0,28.** leftoverHoldBinWriteOk schreibt ¾-Hold, Trail nicht. leftoverTrailNowOf ¾ = [] — Taufe ohne Bin-Trail.
4. **`leftoverSparkChip` ohne Yaw.** Overlay ¾ zeigt Frontal-UUID-Spark `0,80→0,82`.
5. **`captureFormatScore` height ≤ 1080.** Desk-View 1920×1440 Score −1.
6. **`reselectFormat` outputQueue → MainActor.** Device-Lock nach Sample, CS nicht zweimal.

`bugfix` (familyBump / Score-EMA / Gallery-Prune) hinter main, nichts nachziehen.

## Was 2.1.104 wirklich ändert

1. liveMinInterval Hunt 8/10, Lock 12/15. Continuity 15 fps sobald ein Track sitzt.
2. physicalCaptureRotation aus. Capture 0°. Portrait-Buffer `.right`, sonst `.up`.
3. leftoverTrailWriteOk ohne Yaw-Block. leftoverHoldTrail[id] nur frontal. leftoverSparkChip ¾ leer statt UUID-Mix.
4. leftoverHoldOverlayChipOf bleibt ¾-Chip (Bin-Hold, kein Frontal-Trail).
5. captureFormatScore 4:3 1920×1440. reselectFormat CS+Format zweimal auf Main.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.104 (Build 130).

2.1.103 bleibt: `availableVideoPixelFormatTypes` + `videoOut`.
2.1.102 bleibt: leftoverBaptizeBoth roh UND smooth, leftoverHoldOverlayChipOf, leftoverTrailNowOf, leftoverNameFromHold.

Helios 1.5.88: 15-fps-Pinch, 420v-Luma, Desk-View 4:3, Enhance-Skip, WARP-HUD. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.
