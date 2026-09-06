# Aegis + Helios — Analyse 2026-09-06 (2.1.168)

Aegis **2.1.168 alpha** (Build 193). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.167: livePrintEmpty, Continuity nie skip, Yaw-Snapshot. Coast speicherte die Zahl. printBudget |yaw| nicht Δ.

## Warum leftover nach 2.1.167 weiter Twin taufte

1. **printBudget |yaw| < 8°.** Frontal 0° → 5° skippt Print. leftoverHold 0,85 vom Frontal-Tick.
2. **livePrintEmpty → leftoverHold-Zahl.** Kein Print-Vec. Twin im Kalman-Kasten erbt 0,85.
3. **Helios Hist-Veto tot.** Bind-EMA 0,21 unter 0,28.

## Was 2.1.168 ändert

1. **leftoverPrintBudgetYawDelta.** Drehung seit letztem Print. leftoverPrintYaw nur nach Print.
2. **leftoverCoastPrintSkipCosine.** skipPrints Cache ≥32 gegen Twin, ohne `v.count ≥ 32`.
3. **printBudgetSkip(yawDelta:).** |Δ| ≥ 8° → Print trotz |yaw| 5°.
4. Tests + VERSION = Models = MARKETING 2.1.168 (Build 193).

`bugfix` mergen: nein.

# Helios + Aegis — Analyse 2026-09-06 (2.1.167)

Helios **1.5.165** (Build 184). Aegis **2.1.167 alpha** (Build 192). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.166: FaceTrack remintete Hold/Pending/Streak/Yaw. Name-Hist, Print-Trail, Blink, Still, 1-Euro nur `filter keepBoxes` — nach UUID-Remint tot. Overlay Gast 3 Ticks. Continuity printBudget über liveDt-Jitter.

## Warum Taufe nach 2.1.166 weiter riss

1. **Live-Maps nur gefiltert.** liveNameHist / livePrintTrail / liveStillFor / liveBlinkSeen / boxEuro blieben auf der Source-UUID. keepBoxes hält Live-IDs — Mehrheit, Median-Print, Still-Hold, Blink-Liveness, 1-Euro tot.
2. **leftoverCoastCosine live vor Hold.** skipPrints + leerer Print: embedding leer, aber ein Rest-liveCos überschrieb leftoverHold.
3. **printBudget ohne Continuity-Gate.** liveDt 16 ms (Burst) skippte Desk-View-Prints.
4. **Task.detached las liveYaw.** MainActor-Map im Detached-Task — Yaw-Gate raste.

## Was 2.1.167 ändert

1. **FaceTrack Yaw/Still/EMA/Blink/Vote.** Pack+RemintDropMaps. LibraryStore verdrahtet.
2. **leftoverHoldRemintDrop** auf Name-Hist, Print-Trail, Drift, Score-Ticks, 1-Euro, Landmark, Capture-Hist, Tap-Lock.
3. **leftoverCoastCosine(livePrintEmpty:).** Skip ohne Print nimmt Hold, nicht Müll-Cosine.
4. **printBudgetSkip(continuity:).** Continuity nie skip.
5. **Yaw-Snapshot vor Task.detached.**
6. Tests + VERSION = Models = MARKETING 2.1.167 (Build 192). Schema 15 bleibt.

`bugfix` mergen: nein.

# Helios + Aegis — Analyse 2026-09-06 (2.1.166)

Helios **1.5.164** (Build 183). Aegis **2.1.166 alpha** (Build 191). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.165: FaceTrack-Pack saß, Store rief ihn nie. printBudgetSkip nur dt. liveYaw nach Remint tot.

## Warum Taufe nach 2.1.165 weiter riss

1. **24 Maps einzeln remintet.** liveYaw blieb auf Source-UUID.
2. **printBudgetSkip ohne IoU/Yaw.** 24 fps skippte Print bei Kopfdrehung.
3. **expected-gen tot.** Aegis Claim ohne Fail-Zähler.

## Was 2.1.166 ändert

1. **leftoverFaceTrackRemintDropMaps** verdrahtet. Unpack ohne Defaults.
2. **liveYaw/Pitch/Roll reminten.**
3. **printBudgetSkip(minIoU:yawAbs:).** Skip nur IoU ≥ 0,92 und |yaw| < 8°.
4. **cameraMutexCasAllows / ClaimChip / mutexClaimFails.**
5. Tests + VERSION = Models = MARKETING 2.1.166 (Build 191). Schema 15 bleibt.

`bugfix` mergen: nein.

# Helios + Aegis — Analyse 2026-09-06 (2.1.165)

Helios **1.5.163** (Build 182). Aegis **2.1.165 alpha** (Build 190). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.164: leftoverCoastCosine existierte, skipDetect nicht in applyLiveFaces. skipPrints wischte leftoverHold. Models.build 188 vs Binary 189.

## Warum Taufe nach 2.1.164 weiter riss

1. **skipDetect out of scope.** Coast nie am Pin.
2. **skipPrints ohne Coast.** 24 fps printBudget, live-Print leer, leftoverHold tot.
3. **leftoverPickPrint `{ raw }`.** cosine nil → leftoverPrintOk / Gallery-Floor tot.

## Was 2.1.165 ändert

1. **applyLiveFaces(skipDetect:skipPrints:).**
2. **leftoverCoastCosine skipPrints.** leftoverPickPrint raw ?? Hold.
3. **FaceTrack StreakBox/Kalman/Pair + pairLast-Value-Remint.**
4. **ClaimBackoff + Models.build 190.**
5. Tests + VERSION = Models = MARKETING 2.1.165 (Build 190). Schema 15 bleibt.

`bugfix` mergen: nein.

# Helios + Aegis — Analyse 2026-09-06 (2.1.161)

Helios **1.5.158** (Build 177). Aegis **2.1.161 alpha** (Build 186). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.160: HungarianX n>8 Greedy+2-opt, Mutex Claim-Gate, Detect-Skip. 2-opt hängt 4-Zyklus. Yield stoppt nur den Timer. 25 leftover-Maps. Lock in `/tmp`.

## Warum Taufe und Live nach 2.1.160 weiter riss

1. **Greedy+2-opt 4-Zyklus.** Paar-Swap teurer, Vierer-Tausch billiger. Twin-Print im Crowd bleibt auf der Diagonale.
2. **Yield nur Heartbeat.** Helios startet mitten im Aegis-Tick: Continuity bleibt, 1–2 s Kampf, 8 fps.
3. **Yield klebt.** `wasYielded` nie false wenn Holder Aegis — Session kommt nicht zurück, Config bleibt falsch.
4. **25 leftover-Maps.** Remint-Plan sitzt, Identität ist immer noch UUID-Key-Salat.
5. **`/tmp` ohne flock.** Gleicher Riss wie Helios.

## Was 2.1.161 ändert

1. **leftoverAssignHungarianXKuhn + Munkres O(n³)** für n>8 / Wide-Pad. 3-opt + 4-opt poliert. 4-Zyklus tot.
2. **YieldReconfigure.** Heartbeat stoppt *und* Session auf Built-in. `YieldsNow` löst wenn wir selbst halten.
3. **FaceTrack + leftoverFaceTrackPack/Remint.** Eine Remint-Funktion, Maps bleiben bis LibraryStore umzieht.
4. **Caches + flock + Dual-Read/Write.** Gleicher Pfad wie Helios 1.5.158.
5. Tests + VERSION = Models = MARKETING 2.1.161 (Build 186). Schema 15 bleibt.

`bugfix` mergen: nein. CameraBroker, Open-Set Energy, Enrollment-HUD, gallery WAL bleiben Liste.

# Helios + Aegis — Analyse 2026-09-06 (2.1.160)

Helios **1.5.152** (Build 171). Aegis **2.1.160 alpha** (Build 185). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.159: HungarianX Print-Cost n≤8, Spark Hash persist. n>8 fiel auf FillX |Δx|. Mutex `Int(now)`. Aegis-Heartbeat überschrieb Helios. Detect jedes Tick, auch wenn Kalman-IoU 0,95.

## Warum Taufe und Live nach 2.1.159 weiter riss

1. **HungarianX n>8 = FillX.** Crowd 9: Recursion tot, Greedy nur |Δx|. Print 0,90 vs 0,20 an Twins mit Δx 0,02 verliert.
2. **Mutex-Stamp Sekunden + PID tot.** Crash 12 s. Helios-Claim, Aegis-Timer schreibt zurück.
3. **Yield nur Configure.** Helios startet während Aegis läuft: Lock-Kampf, Continuity 8 fps.
4. **Detect jedes Frame.** Kalman sitzt (IoU 0,95), trotzdem VNDetect + Print. Jank auf Continuity.

## Was 2.1.160 ändert

1. **leftoverAssignHungarianXGreedy + 2-opt.** n>8 und Wide-Pad: Cost (IoU+Print), nicht FillX. Twin-Print überlebt Crowd.
2. **cameraMutexLine %.3f, Pid, pidLive, ClaimWrites, YieldsNow.** Aegis-Heartbeat weicht live, stoppt Timer. Toter PID gibt Lock frei.
3. **leftoverDetectSkip / SkipAll / SkipTick.** Kalman-IoU ≥ 0,92: skipPrints, kein Full-Retry. Tick % 8 voll.
4. Tests + VERSION = Models = MARKETING 2.1.160 (Build 185). Schema 15 bleibt.

Helios 1.5.152: Mutex-Stamp, PID, Claim-Vorrang. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`. FaceTrack-Struct, flock, CameraBroker bleiben auf der Liste.

# Helios + Aegis — Analyse 2026-09-06 (2.1.159)

Helios **1.5.150** (Build 169). Aegis **2.1.159 alpha** (Build 184). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.158: Remint-Plan, Spark Hash RAM, Quality-Produkt. HungarianX Cost = |Δx|. Spark-Hash nicht in gallery.json. Twin mit ähnlichem X ignoriert Print 0,90.

## Warum Taufe nach 2.1.158 weiter riss

1. **HungarianX nur |Δx|.** leftoverAssignCost sitzt, wird nicht benutzt. Twins 0,02 vs 0,04: näherer X gewinnt. Spread-Veto nilt Print-Zuweisung. Steal braucht Gap ≥ 0,15 und Floor 0,80 — 0,72 vs 0,55 fällt.
2. **Spark Hash RAM-only.** leftoverSparkChipEncode nur UUID. Restart: Chip weg, Overlay Gast 2 Ticks. Overlay-Lookup ohne Hash-Fallback.

## Was 2.1.159 ändert

1. **leftoverAssignHungarianXCost.** IoU + PrintW 0,8 wenn Scores da. Spread-Veto tot sobald Print > 0. leftoverAssignLive reicht Scores in den Remint-Pass.
2. **leftoverSparkChipPack/Unpack.** Hash→Chip in demselben leftoverSparkChip-Dict (keine UUID-Keys). Restart hält Chip. Overlay-Lookup Hash-Fallback.
3. Tests + VERSION = Models = MARKETING 2.1.159 (Build 184). Schema 15 bleibt.

Helios 1.5.150: Dest-Warp, Layout-Rearm, Connection-Winkel. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.158)

Helios **1.5.149** (Build 168). Aegis **2.1.158 alpha** (Build 183). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.157: MissCoast return, Spark Hash-Rebind. leftoverHoldRemint 20× dieselben Args — Hold A→C, Streak B→C. Spark Chip nur UUID. Taufe hart 0,80 auf Continuity 8 fps. Overlay Gast statt Unsure. Helios+Aegis reißen Continuity.

## Warum Taufe nach 2.1.157 weiter riss

1. **20× leftoverHoldRemint.** Jede Map matched allein. Hold remintet A→C, Streak remintet B→C. Namen-Leak, PairCommit fällt.
2. **Spark Chip UUID-only.** Hash-Rebind sitzt RAM-Tick. Restart / Remint-Miss: Chip tot, Gast-Flash.
3. **Taufe 0,80 hart.** Continuity Laplacian 0,10–0,14, Print 0,76–0,79 hält ewig Unbekannt.
4. **Quality OR.** Blur-Gate und Yaw-Gate unabhängig. Weicher Blur + 12° Yaw tauft.
5. **Kein Unsure-Chip.** Mehrheit < Need = Overlay Gast. Majority tauft Tick 1.
6. **Kamera ohne Mutex.** Helios hält Continuity, Aegis startet dieselbe Session — 8 fps.

## Was 2.1.158 ändert

1. **leftoverHoldRemintMap einmal**, Apply auf alle Hold-Maps **und Bins**. Identity-Skip im Remap (sonst Dictionary-Order schreibt stored→stored über stored→live).
2. **leftoverSparkChipHashPut/Get.** hash→chip neben UUID. TickKeeps liest die Tabelle.
3. **leftoverBaptizeFloor(continuity)** 0,76 / 0,80 — **durch TransfersId / HoldsTrack / WipeHist verdrahtet**, nicht nur Math.
4. **leftoverBaptizeQualityProduct** Blur × Pose. Continuity Floor 0,06 (Webcam 0,18). Blink 0.
5. **leftoverUnsureChip** `?` **in ContentView overlayName** statt Gast.
6. **cameraMutex** — Yield **vor** Auto-Early-Return (war tot). Aegis überschreibt Helios-Lock nicht. Heartbeat 2 s, Stale 12 s.
7. Tests + VERSION = Models = MARKETING 2.1.158 (Build 183). Schema 15 bleibt.

Helios 1.5.149: DisplayPulse je Screen + Cursor-Gate, MCP-Fächer, Bind-EMA, Mutex-Heartbeat. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`. Pairwise-Heatmap, Identity-Merge Wizard, Drop-in `.mlmodel` bleiben auf der Liste.

# Helios + Aegis — Analyse 2026-09-06 (2.1.157)

Helios **1.5.147** (Build 166). Aegis **2.1.157 alpha** (Build 182). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.156: Steal 2-opt, Held emptyKeeps, CostIoU. leftoverHoldMissCoast ohne `return`. Spark-Chip UUID-only nach Remint.

## Warum Taufe nach 2.1.156 weiter riss

1. **leftoverHoldMissCoast ohne return.** `let n = …` plus Ausdruck. Swift 6: Missing return. MatchMath.swift kompiliert nicht — CI rot, Binary 2.1.154–156 ggf. Altlast.
2. **Spark-Chip UUID-only.** leftoverSparkChipTickKeeps hold = leftoverLastHash.keys. Remint-Miss: Overlay liest Live-UUID, Chip sitzt alt. Gast-Flash.

## Was 2.1.157 ändert

1. **leftoverHoldMissCoast return.** Swift 6 kompiliert. Tests Miss 1/2 hält, 3 tot.
2. **leftoverSparkChipTickKeeps lastHash + leftoverSparkChipTickDest.** Live-Hash hält Chip, Rebind alt→Live.
3. Tests + VERSION = Models = MARKETING 2.1.157 (Build 182). Schema 15 bleibt.

Helios 1.5.147: Smooth dt, Span max-Paar, DisplayLink max-Screen. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.156)

Helios **1.5.146** (Build 165). Aegis **2.1.156 alpha** (Build 181). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.155: Print-Steal, Ghost-HOLD, Held Survive. Survive auf Live-Tick: Until leer nach Ablauf hält Namen ewig. Steal ein Pass: 3-Zyklus hängt wenn Zeile 0 nicht stiehlt. leftoverAssignCost ungenutzt — PrintW 0,3 verliert gegen dx>Pad.

## Warum Taufe nach 2.1.155 weiter riss

1. **HeldSurvive Live emptyKeeps.** UntilRestore arm≥0,6 deckt Schema-7. Live-Tick Until leer = Lock abgelaufen, Survive hielt Held — Overlay-Namen Leak.
2. **PrintSteal ein Pass.** 3-Zyklus [1,2,0]: Zeile 0 Gap tot, Zeile 1 stiehlt, Zeile 0 nie erneut. Majority tauft.
3. **Cost aus |Δx|.** PrintW 0,3, dx>Pad → IoU 0, Cost ≥ 1. Steal bleibt der Override.

## Was 2.1.156 ändert

1. **leftoverNameLockHeldSurvive emptyKeeps.** Decode Schema-7 hält. Live-Tick Until leer wischt.
2. **leftoverAssignPrintSteal2opt.** Bis 16 Pässe. 3-Zyklus landet.
3. **leftoverAssignCostIoU.** |Δx|/Pad → IoU. Dokumentiert warum Steal bleibt.
4. Tests + VERSION = Models = MARKETING 2.1.156 (Build 181). Schema 15 bleibt.

Helios 1.5.146: Finger-Paare, Tip-Conf, Frozen-Write. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`. Pairwise-Heatmap, Identity-Merge Wizard, Drop-in `.mlmodel` bleiben auf der Liste.

# Helios + Aegis — Analyse 2026-09-06 (2.1.155)

Helios **1.5.145** (Build 164). Aegis **2.1.155 alpha** (Build 180). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.154: DropHold Ghosts+Miss, CI macos-15. Remint (x) zuerst — Print stiehlt keine Spalte. Geschwister bei Crowd taufen. Overlay HOLD stirbt, missCoast false, PairCommit fällt. Schema-7 Backup Until leer wischt Held.

## Warum Taufe nach 2.1.154 weiter riss

1. **leftoverAssignLive X-first.** Remint sperrt die Spalte. Print 0,82 vs Remint 0,40 darf nicht tauschen. Geschwister gleiche X.
2. **DropHold missKeys nur missCoast.** Ghost-Overlay tot, PairCommitMiss 1–2, missCoast false — dest fällt, Majority tauft Tick 1.
3. **NameLockHeld filter Until.** Schema-7 Backup Until leer: Held weg, Overlay Gast.

## Was 2.1.155 ändert

1. **leftoverAssignCost / leftoverAssignPrintSteals.** 1−IoU + 0,3·(1−print). Print stiehlt Remint wenn Gap ≥ 0,15 und ≥ leftoverPrintCosine. Twin-Veto-nil bleibt.
2. **leftoverGhostHoldsCommit.** DropHold commitMiss hält PairCommit während HOLD 1/3 und 2/3, auch ohne Ghost.
3. **leftoverNameLockHeldSurvive.** Until leer hält Held (Schema-7). Until gesetzt filtert.
4. Tests + VERSION = Models = MARKETING 2.1.155 (Build 180). Schema 15 bleibt.

Helios 1.5.145: Fingerkette hart, Conf-Gate, Chirality, ROI-Totpfad. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`. Pairwise-Heatmap, Identity-Merge Wizard, Drop-in `.mlmodel` bleiben auf der Liste.

# Helios + Aegis — Analyse 2026-09-06 (2.1.154)

Helios **1.5.144** (Build 163). Aegis **2.1.154 alpha** (Build 179). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.153: Spark persist, Capture-Hist remaining, DropDangling keep leer. Hold = leftoverHold.keys. Twin-Session-UUID sitzt in ghostIds, nicht leftoverHold. PairCommit tot, Majority tauft Tick 1. CI nur macos-26.

## Warum Taufe nach 2.1.153 weiter riss

1. **DropHold nur leftoverHold.keys.** Ghost-Twin nicht im Hold. DropDangling dest tot. PairCommit fällt. Majority tauft Tick 1.
2. **Miss-Coast Keys tot.** leftoverPairCommit.keys während Dropout nicht in hold. Coast-Return tauft.
3. **CI macos-26 allein.** macos-26 startet oft nicht. Helios 1.5.142 baut auf 15.

## Was 2.1.154 ändert

1. **leftoverUUIDUUIDMapDropHold** hold ∪ ghosts ∪ missKeys.
2. **DropDangling destOk** Key|Dest — `hold.contains(k)` redundant nach Union.
3. **CI matrix macos-15+26**, fail-fast false. Publish macos-15 zuerst, Artifact analog Helios.
4. Tests + VERSION = Models = MARKETING 2.1.154 (Build 179). Schema 15 bleibt.

Helios 1.5.144: HandCount 4, Fingerkette, Span-Veto Prop, Smooth 0,35. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.153)

Helios **1.5.143** (Build 162). Aegis **2.1.153 alpha** (Build 178). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.152: DropDangling Hold-Key. Spark-Chip RAM-only. Capture-Hist ohne remaining. DropDangling keep leer gibt die ganze Tabelle.

## Warum Taufe nach 2.1.152 weiter riss

1. **leftoverSparkChipHeld RAM-only.** Restart: Overlay flackert 2 Ticks Gast, dann Name. Chip-Tuple nicht in gallery.json.
2. **tickLeftoverSparkChips nur live.** persist UUID tot nach Restart. stabilize vor Remint wischt Chip, lastHash ungenutzt.
3. **Capture-Hist ohne remaining.** Indoor-Blur 0,70 überlebt Restart, Baptize-Floor tot.
4. **DecodeFresh Key fehlt = tot.** Rank-Rebase: remaining ohne Key droppt Hist.
5. **DropDangling keep leer.** `guard !keep.isEmpty else { return table }` — keine Live+Identität: Dangling bleibt, Twin-dest falsch.

## Was 2.1.153 ändert

1. **leftoverSparkChip persist.** Encode Chip, Decode Hold = 2. Restart Overlay hält.
2. **leftoverSparkChipTickKeeps.** live ∪ lastHash. Remint-Miss kein Gast-Flash.
3. **leftoverCaptureHist remaining.** Expired tot. Schema 15 ohne remaining hält (Compat). Key ohne remaining hält.
4. **leftoverUUIDUUIDMapDropDangling keep leer.** Nur Hold-Keys.
5. Tests + VERSION = Models = MARKETING 2.1.153 (Build 178). Schema 15 bleibt.

Helios 1.5.143: Sparse/Close-Hand, Bind denser, Gitarre 0,29 tot. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.152)

Helios **1.5.141** (Build 160). Aegis **2.1.152 alpha** (Build 177). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.151: Rank-Rebase Yaw, DropDangling Key|Dest, Jump Cam, PairCommitMiss persist. DropDangling Key muss live sein — leftoverHold-Ghost fällt, Twin-dest tot, Taufe Tick 1.

## Warum Taufe nach 2.1.151 weiter riss

1. **DropDangling Key|Dest ohne Hold.** Overlay-Hold A nicht in remintLive, dest Twin-B ghost. PairCommit tot, Majority tauft.

## Was 2.1.152 ändert

1. **leftoverUUIDUUIDMapDropDangling hold.** Key im leftoverHold hält dest.
2. Tests + VERSION = Models = MARKETING 2.1.152 (Build 177). Schema 15 bleibt.

Helios 1.5.141: Bind lastS1, Freeze-Clock, Scale-Pass ROI-Map. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.151)

Helios **1.5.140** (Build 159). Aegis **2.1.151 alpha** (Build 176). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.150: PairCommit Hold, Remint Dest Twin, Bins Rank-Rebase, Jump Slider. leftoverHashRankRebase strippt `#0`. DropDangling nur dest. PairCommitMiss RAM-only. Jump Pref 0,40 auf Continuity 8 fps. leftoverLastHashRankRebase strippt Yaw. leftoverHoldsTrack IoU 0,40.

## Warum Taufe und Restart nach 2.1.150 weiter rissen

1. **leftoverHashRankRebase `#0`.** Spatial-Strip killt leftoverHoldHashKey. Yaw-Bin nach Restore tot, Exact liest Frontal.
2. **DropDangling nur dest.** leftoverHoldRemint dest Live-UUID die kein Hold-Key ist, Twin-weg: PairCommit tot, Majority tauft.
3. **leftoverPairCommitMiss RAM-only.** Restart wischt Overlay HOLD, miss=0 Label tot, 3 Ticks still dann Gast.
4. **Jump Pref ein Wert.** Continuity 8 fps Box 0,32–0,38, Webcam 24 fps 0,50. Pref 0,40 zittert Indoor. leftoverHoldsTrack / NameLock / JUMP-Chip hart 0,40 — Walker fällt.
5. **leftoverLastHashRankRebase `#0`.** LastHash Spatial-Strip, Exact nach Restore Frontal.

## Was 2.1.151 ändert

1. **leftoverHashIsTwinRank.** leftoverHashRankRebase nur `#101+`. Yaw `#0`/`#1`/`#2` hält. leftoverLastHashRankRebase analog.
2. **leftoverUUIDUUIDMapDropDangling Key|Dest.** PairCommit hält wenn Key live, Dest Twin-weg.
3. **leftoverPairCommitMiss + leftoverLastIoU persist.** gallery.json Extra, Restart HOLD.
4. **leftoverHoldKalmanJumpCam.** Continuity min(pref, 0,34), Webcam pref. leftoverIoUJumpBlocks / Chip / HoldsTrack / TransfersId / NameLock.
5. Tests + VERSION = Models = MARKETING 2.1.151 (Build 176). Schema 15 bleibt.

Helios 1.5.140: ROI Thaw Prop, Freeze TTL, S1 Laterality, Coast Click. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.150)

Helios **1.5.139** (Build 158). Aegis **2.1.150 alpha** (Build 175). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.149: Pair dest==key persist, Occupied Twin-weg, KeepBoxes PredictOnly. leftoverHoldRemintId dest=self. Majority ohne Overlay nach Remint-Miss. Bins `#101` Decode roh. Jump Pref ohne HUD.

## Warum Taufe und Restart nach 2.1.149 weiter rissen

1. **leftoverHoldRemintId dest=self.** PairCommit Value = Live-self. Twin-proposed tot. Majority-Streak 0, Remint-Miss tauft Twin nach 3 Ticks neu.
2. **leftoverAssignMajority nur Keeps.** committed ≠ proposed nach Remint: 3 Ticks Overlay fehlen, Gast-Taufe.
3. **leftoverHoldBins `#101`.** leftoverHoldByHash rebase sitzt, Bins Decode roh. Rank nach Restore tot.
4. **Jump Pref ohne Slider.** Continuity 8 fps Box 0,32–0,38, Pref 0,40 hart im HUD.

## Was 2.1.150 ändert

1. **leftoverHoldRemintId Dest.** leftoverHoldRemintMap + leftoverUUIDUUIDMapRemintDest. Twin-proposed hält.
2. **leftoverPairCommitHold.** 3 Ticks Overlay, leftoverPairCommitMiss Latch, HOLD n/3.
3. **leftoverHoldBinsDecode Rank-Rebase.** leftoverHoldKalmanJumpPref Slider 0,30–0,50.
4. Tests + VERSION = Models = MARKETING 2.1.150 (Build 175). Schema 15 bleibt.

Helios 1.5.139: ROI Thaw Same-Tick/Expand, FullAfter 24 fps, Bind Hands-First. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.149)

Helios **1.5.138** (Build 157). Aegis **2.1.149 alpha** (Build 174). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.148: PairCommit Keeps, Kalman PredictOnly Ghost, KeepBoxes Ghost-Kalman, Jump Pref 0,30–0,50. Decode droppt dest==key. Occupied hält stored `#101` wenn Twin weg. KeepBoxes droppt Restore-Kalman ohne Ghost.

## Warum Taufe und Restart nach 2.1.148 weiter rissen

1. **PairCommit dest==key tot.** leftoverHoldRemintId setzt dest=key. leftoverUUIDUUIDMapDecode `dest != id` droppt. Restore: Majority nil, 3 Ticks, Taufe Gast n+1.
2. **Occupied stored `#101` nach Twin-weg.** leftoverOccupiedMergeYaw hängt Rank an, obwohl Live nur 1 Exact hat. Exact blockt, Twin-Slot tot, nächster Gast.
3. **KeepBoxes ohne PredictOnly.** leftoverHoldKalmanKeep hält Restore-Kalman, KeepBoxes missCoast=false ghosts=[] droppt. Erster leerer Tick nach Restart: Box-Sprung.
4. **KeepBoxes Kalman ∩ Ghosts.** Survive Hold allein: Kalman-IDs in Hold, Filter ohne Hold-Schnitt droppt wenn Ghosts leer — Hold-Union saß, Kalman extra nicht.

## Was 2.1.149 ändert

1. **leftoverUUIDUUIDMapDecode dest==key.** PairCommit/PairLast überleben Restart. Majority Keeps.
2. **leftoverOccupiedTwinGone.** stored Rank tot wenn liveOfSpatial==1. Restore live 0 hält Rank.
3. **leftoverKeepBoxes predictOnly.** Restore/Miss/Ghost-only Kalman bleibt. Kalman ∩ (Ghosts ∪ Hold).
4. Tests + VERSION = Models = MARKETING 2.1.149 (Build 174). Schema 15 bleibt.

Helios 1.5.138: Overlay Extrapolate, Lerp 24 fps, ROI Thaw 2 Frozen-Miss, Scale-Ring nur S1. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.148)

Helios **1.5.137** (Build 156). Aegis **2.1.148 alpha** (Build 173). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.147: Backup remaining, HashTrail remaining Schema 15, KeepBoxes nach Survive, Hungarian wide FillX. Majority committed==proposed inline. Kalman Keep nur missCoast. KeepBoxes droppt Ghost-Kalman ohne missCoast. IoU-Reset hart 0,40.

## Warum Taufe und Restart nach 2.1.147 weiter rissen

1. **leftoverPairCommit nach Remint.** leftoverHoldRemintId setzt Value auf Live-UUID. Majority-Streak 0 wenn proposed ≠ committed. Inline `committed == proposed` nicht testbar, Remint-Miss tauft Twin nach 3 Ticks neu.
2. **Kalman Keep nur missCoast.** Survive hält Ghosts, miss > need: leftoverHoldKalmanKeep live=[] wischt. leftoverPredictHeld tot. Ghost-Box freeze, nächster Tick IoU-Reset.
3. **KeepBoxes Kalman nur missCoast.** Ghost-IDs in Survive, Filter droppt Kalman ohne Miss. Ghost-only Hold tot.
4. **IoU-Reset hart 0,40.** Continuity 8 fps Box zittert 0,32–0,38. Pref 0,30–0,50 fehlte.

## Was 2.1.148 ändert

1. **leftoverPairCommitKeeps.** Majority hält wenn committed == proposed nach Remint.
2. **leftoverHoldKalmanPredictOnly.** Restore / Miss-Coast / Live-leer+Ghost → Keep Predict, kein Wipe.
3. **leftoverKeepBoxes Ghost-Kalman** auch ohne missCoast.
4. **leftoverHoldKalmanJumpPref** 0,30–0,50. leftoverHoldKalmanResets clamped.
5. Tests + VERSION = Models = MARKETING 2.1.148 (Build 173). Schema 15 bleibt.

Helios 1.5.137: Overlay 90 Hz Bezier, Wrist–MCP Median, Span-Veto. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.147)

Helios **1.5.136** (Build 155). Aegis **2.1.147 alpha** (Build 172). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.146: skipKalmanReset Compile, KeepBoxes Miss-Kalman, HashHold remaining. Restore las Live-Remaining. Trail at=now. KeepBoxes vor Survive. Hungarian n=8 Pad 0,40 Recursion.

## Warum Taufe und Restart nach 2.1.146 weiter rissen

1. **restoreFromBackup live Remaining.** leftoverHoldHashRemaining aus gallery.json, nicht `.bak`. Backup-TTL tot.
2. **HashTrail Decode at=now.** Schema 14 remaining nur Hold. Trail-TTL startet nach Restore neu.
3. **KeepBoxes vor Survive.** Hold-IDs nach Remint, Filter droppt Survive-Keep.
4. **HungarianX Pad 0,40 n=8.** Recursion explodiert, Crowd tot.

## Was 2.1.147 ändert

1. **loadBackupPayload remaining.** Restore HashHold + HashTrail aus `.bak`.
2. **leftoverHashTrail remaining Schema 15.** leftoverHashTrailRemainingEncode. Decode remaining analog Hold.
3. **leftoverKeepBoxes nach Survive.** leftoverKeepHoldIds Hold∪Bins.
4. **leftoverAssignHungarianWide.** Pad > 0,20 → FillX.
5. Tests + VERSION = Models = MARKETING 2.1.147 (Build 172). Schema 15.

Helios 1.5.136: ROI Thaw FullNext, Coast Follow, FullNext Lock. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.146)

Helios **1.5.135** (Build 154). Aegis **2.1.146 alpha** (Build 171). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.145: Miss-Need 2 Auto, JPEG Schema-11 stale, Kalman Restore, Occupied Yaw. skipKalmanReset doppelt. KeepBoxes droppt Miss-Kalman. HashHold at=now. Hungarian n=6. Stored Rank tot.

## Warum Taufe und Restart nach 2.1.145 weiter rissen

1. **skipKalmanReset Redeclaration.** Zwei `let` in applyLiveFaces. Compile tot. Advance vor dem Loop kürzte den Skip um 1 Tick.
2. **leftoverKeepBoxes ohne Miss-Kalman.** leftoverHoldKalmanKeep missCoast hält, Filter danach droppt IDs wenn Hold nach Remint leer.
3. **HashHold Rebase at=now.** Decode at=Load, erstes Gesicht setzt at neu. Indoor-TTL 4 s startet nach der ersten Box, nicht nach Restore.
4. **leftoverOccupiedMergeYaw stored Spatial-strip.** `#101` wird Spatial, Twin-Rank nach Restore tot.
5. **HungarianX n>6 FillX greedy.** 7. Person tot.

## Was 2.1.146 ändert

1. **skipKalmanReset einmal.** Advance nach dem IoU-Loop. Compile + 2 Ticks Skip.
2. **leftoverKeepBoxes missCoast + kalman.** Miss hält Box-Filter.
3. **leftoverHashHold remaining Schema 14.** leftoverHashHoldRemainingEncode. Rebase keepAt. Decode remaining analog JPEG.
4. **leftoverOccupiedMergeYaw stored Rank.** `#101` bleibt `#101`.
5. **leftoverAssignHungarianX n≤8.** leftoverAssignHungarianN.
6. Tests + VERSION = Models = MARKETING 2.1.146 (Build 171). Schema 14.

Helios 1.5.135: ROI FullNext, Empty-Coast, Kalman Clamp, Pulse-Alive. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.145)

Helios **1.5.134** (Build 153). Aegis **2.1.145 alpha** (Build 170). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.144: Miss-Coast Kalman/Streak/Faces, JPEG remaining Schema 13. Miss hart 1. Schema-11 at=now. Kalman IoU-Reset Tick 1. Ranked Occupied blockt Exact. Hungarian n=5.

## Warum Taufe und Restart nach 2.1.144 weiter rissen

1. **Miss-Coast need hart 1.** Indoor 8 fps Dropout 2 Ticks. Tick 2 Survive wischt, Taufe Gast n+1.
2. **JPEG Schema-11 Decode at=now.** 2er-Array remaining fehlt. Restore: Probe 0,80 s zu frisch, Indoor reextract tot.
3. **Kalman IoU-Reset Tick 1 nach Restore.** Meas weit, Reset statt Kriechen. Schema 12 sitzt, erster Live-Tick droppt.
4. **leftoverHashOwnOccupied Spatial-stript `#101`.** Ranked Occupied = Exact tot. Spatial-emit unvollständig.
5. **Occupied Merge ohne Yaw.** Zwei Live gleiches Spatial, x-Tie: beide Occupied bis TwinOccupied. liveYaw nach Restore leer.
6. **Kalman-v voll während Miss.** PredictOnMissCoast sitzt, Halt läuft mit last-v weiter.
7. **HungarianX n>5 FillX greedy.** 6. Person tot.

## Was 2.1.145 ändert

1. **leftoverHoldMissNeedPref 1–3 Default 2.** leftoverHoldMissNeedAuto dt ≥ 0,20 → 3. Slider.
2. **leftoverJpegRestoreAt.** Schema 11 stale = now − TTL. Erster Tick reextract.
3. **leftoverHoldKalmanSkipReset** 2 Ticks nach Restore. leftoverHoldKalmanRestoredAdvance.
4. **leftoverOccupiedRankBlocks.** Ranked `#101` blockt Exact nicht.
5. **leftoverOccupiedMergeYaw.** Kleinerer yawAbs Exact, Rest `#101`.
6. **leftoverHoldKalmanVelDecay** Miss 1 voll, α 0,82. leftoverPredictHeld miss:.
7. **leftoverAssignHungarianX n≤6.** leftoverAssignHungarianN.
8. Tests + VERSION = Models = MARKETING 2.1.145 (Build 170). Schema 13 bleibt.

Helios 1.5.134: WarpWriter Token, Need Auto, Vel-Decay, ROI Freeze. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.144)

Helios **1.5.133** (Build 152). Aegis **2.1.144 alpha** (Build 169). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.143: Miss-Coast 1 Frame, Occupied Spatial-emit, JPEG Cap, Kalman Schema 12, HungarianX n=5.

## Warum Taufe und Restart nach 2.1.143 weiter rissen

1. **KalmanKeep empty live wischt.** leftoverHoldKalmanKeep `keep.isEmpty → [:]`. Miss-Coast Survive hält Hold, Keep davor tot. Predict ohne Box.
2. **found.isEmpty wischt Streak/Pair/Kalman/Faces.** leftoverEmptyKeepsStreak ohne missCoast. Overlay-Flash, Twin-Taufe, Box-Sprung.
3. **JPEG decode at=now.** Remaining fehlte. Restore: Probe 1,2 s zu frisch, Indoor 8 fps reextract-Burst wenn TTL fällt.

## Was 2.1.144 ändert

1. **leftoverHoldKalmanKeep missCoast.** Empty live hält Kalman.
2. **leftoverHoldMissHit** live ∪ adopted. MissAdvance vor Keep.
3. **leftoverEmptyWipesMaps / Overlay.** found.isEmpty skippt Streak/Pair/Kalman/Faces 1 Tick.
4. **leftoverJpegRemaining.** Encode [delta, cosine, left]. Decode at aus remaining. Schema 11 2er-Array at=now.
5. Tests + VERSION = Models = MARKETING 2.1.144 (Build 169). Schema 13.

Helios 1.5.133: Coast-Vel Return, Joint-Shift, Inject-Skip. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.143)

Helios **1.5.132** (Build 151). Aegis **2.1.143 alpha** (Build 168). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.142: Remint vor Survive, Occupied Spatial unique, JPEG persist Schema 11, Spread-Veto Twin-Mitte.

## Warum Taufe und Restart nach 2.1.142 weiter rissen

1. **1-Face-Miss ohne Ghost.** Detect-Drop: live=[], ghosts=[], leftoverHold persist. Survive wischt. Restart erster dunkler Tick = Taufe.
2. **Occupied live Rank.** leftoverOccupiedMerge unique-by-spatial, emit Original. Tick `#101` bleibt Occupied-Key. Exact Spatial tot.
3. **JPEG persist ungekürzt.** leftoverJpegProbeStore Cap 64, Encode dumpte alles.
4. **Kalman RAM-only.** Restart Box-Sprung 3 Frames. Remint sitzt, Persist fehlte.
5. **HungarianX n>4 FillX greedy.** 5. Person tot.

## Was 2.1.143 ändert

1. **leftoverHoldMissCoast 1 Tick.** leftoverHoldSurvive / Bins / LastHash / Tick halten. leftoverPredictOnMissCoast.
2. **leftoverOccupiedMerge Spatial-emit.** live Rank → Spatial.
3. **leftoverJpegByHashCapped** Encode Cap 64.
4. **Schema 12 leftoverHoldKalman persist.** x/y/w/h/p + vel. Restore wischt nicht.
5. **leftoverAssignHungarianX n≤5.** leftoverAssignHungarianN.
6. Tests + VERSION = Models = MARKETING 2.1.143 (Build 168).

Helios 1.5.132: Press-Skip, Fill Press, Coast Predict, Coast Pref, Ghost Alpha, Writer-Chip. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.142)

Helios **1.5.131** (Build 150). Aegis **2.1.142 alpha** (Build 167). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.141: leftoverHoldXMatch Call-Order. Survive vor Remint. Occupied exact. JPEG RAM-only. Twin-Mitte Hungarian nur Unassigned.

## Warum Taufe und Restart nach 2.1.141 weiter rissen

1. **Survive vor Remint.** Nach Restart: `faces` Gallery-mediaId, Live neue UUIDs, Ghosts leer. Survive wischt persist leftoverHold. Remint `hold[old]==nil`. Taufe Gast n+1.
2. **leftoverOccupiedMerge exact.** Rank `#101` + Spatial nach Restore zwei Occupied. Twin Exact tot oder Steal.
3. **JPEG per Hash RAM-only.** Restart: Probe-Cache tot, 8 fps Indoor reextract jedes Frame.
4. **HungarianX Spread nur Unassigned.** Twin-Mitte 1-Live saß, Assigned-Twins nicht.

## Was 2.1.142 ändert

1. **Remint vor Survive.** leftoverHoldRemintRows (Streak + Hold + Ghosts). Survive live ∪ adopted.
2. **leftoverOccupiedMerge Spatial unique.** leftoverHashOwnOccupied Spatial. leftoverLastHashRankRebase.
3. **Schema 11 leftoverJpegByHash persist.** Spatial-Key, at=now Restore.
4. **leftoverAssignSpreadVeto.** Unassigned + Twin-Mitte. n=2 Unique hält.
5. Tests + VERSION = Models = MARKETING 2.1.142 (Build 167).

Helios 1.5.131: Palm-Coast 2 Ticks, ein Warp-Writer. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.141)

Helios **1.5.130** (Build 149). Aegis **2.1.141 alpha** (Build 166). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.140: Schema 10, Kalman Remint, JPEG Hash, HungarianX n=4. CI rot seit 2.1.139: leftoverHoldXMatch `occupied:` vor `pad:` — Swift Default-Args.

## Warum 2.1.140 nicht baute

1. **leftoverHoldXMatch Call-Order.** Signatur `pad:` dann `occupied:`. Remint/RemintBins riefen `occupied:, pad:`. swiftc: argument 'pad' must precede argument 'occupied'. 4 Stellen. Hold-Remint tot, kein DMG seit 2.1.139.
2. **HungarianX `var used`.** Nie mutiert, Warning. `let`.

## Was 2.1.141 ändert

1. **leftoverHoldXMatch** `pad:, occupied:` an 4 Call-Sites (Remint + RemintBins, firstPad + Rescue).
2. **leftoverAssignHungarianX** `let used`.
3. Tests unverändert. VERSION = Models = MARKETING 2.1.141 (Build 166).

Helios 1.5.130: Scale-Jump-Veto, Fill-Cap UUID, Slot-Kalman, DisplayLink Hz. CI Helios: Billing/Spending-Limit, nicht Compile.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.140)

Helios **1.5.130** (Build 149). Aegis **2.1.140 alpha** (Build 165). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.139: Rank Spatial Dist, HungarianX n=3, Hamming Solo, JPEG TTL Pref. leftoverStreakBox RAM-only. Kalman nach Remint tot. JPEG per UUID. Hungarian n>3 FillX. AssignLiveGate nur UserDefaults.

## Warum Taufe und Restart nach 2.1.139 weiter rissen

1. **leftoverStreakBox nicht persist.** Restart: Remint nur per Hash. x-Pad 18 cm tot ohne Box.
2. **boxKalman nach Remint auf alter UUID.** keepBoxes filtert alt, Live hat kein Kalman — Box springt, Hash-Bin falsch.
3. **JPEG-Probe per UUID.** Twin fallback `old.id` teilt die Probe. Spatial-Hash fehlte.
4. **HungarianX n>3 → FillX greedy.** Drei-plus Crowd: 4. Person tot.
5. **AssignLiveGate nur UserDefaults.** gallery.json.bak Restore setzt Gate 1, Crowd tauft.

## Was 2.1.140 ändert

1. **Schema 10 leftoverStreakBox persist.** Encode x/y/w/h. Restore wischt nicht.
2. **leftoverHoldKalmanRemint + Reset.** IoU < 0,40 drop, Keep live UUIDs.
3. **leftoverJpegProbeByHash.** Spatial-Key, Twin teilt nicht. Rank `#` strip.
4. **leftoverAssignHungarianX n≤4.** 4. Person min-cost.
5. **leftoverAssignLiveGate in gallery.json.** Restore + persist().
6. Tests + VERSION = Models = MARKETING 2.1.140 (Build 165).

Helios 1.5.130: Scale-Jump-Veto, Fill-Cap UUID, Slot-Kalman, DisplayLink Hz. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.139)

Helios **1.5.129** (Build 148). Aegis **2.1.139 alpha** (Build 164). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.138: Schema 9 PairStreak/Commit/Streak, Hungarian n=3 Print, Hash Twin Exact, FillX Pad UI, Trail Cap 4. Rank-Key `#101` Dist 99. Lookup nach Restore tot. AssignLive x greedy. JPEG TTL hart 0,80.

## Warum Taufe und Restart nach 2.1.138 weiter rissen

1. **leftoverBoxHashDistance auf Rank-Key `#101`.** Split `"."` → `Int("6#101")` nil → Dist 99. Neighbor/Hamming tot, Hold nach 1-Bin-Jitter verloren.
2. **leftoverHashRankRebase fehlte.** Persist Rank-Key, Lookup Spatial: nach Restart tot. Dictionary-Order: Rank 0,81 schlug Spatial 0,70.
3. **leftoverHoldLookup Spatial stiehlt Twin.** Twin R `#101` las Twin L Hold. leftoverHoldSpatialOccupied fehlte.
4. **leftoverAssignFillX greedy n=2.** Naher Twin sperrt Hold 0 (0,00/0,10 vs 0,09/0,20). Hungarian nur auf Print-Scores.
5. **leftoverHoldRemint erster Pass padRescue auch bei Twin.** Crowd tauft Far. Hamming-1 fehlte, Solo 18 cm + 1-Bin tot.
6. **leftoverHoldTrail unbeschränkt vs persist Cap 4.** Spark 8, Restore 4. JPEG TTL hart 0,80: Indoor 8 fps Probe tot, 24 fps Jank.
7. **leftoverMirrorPending ohne JPEG/Streak/Wipe.** AssignLive: Probe und Streak auf alter UUID. leftoverLiveHashTick nicht in leftoverLastHash persist.

## Was 2.1.139 ändert

1. **leftoverHoldHashSpatial vor Dist/Neighbors/BinsInferred.** Rank Dist 0, Hamming 1.
2. **leftoverHashRankRebase Spatial-first** zwei Passes. Init + restoreFromBackup. leftoverHoldMoveRankKey live.
3. **leftoverHoldHashLookupKeys + leftoverHoldSpatialOccupied.** Twin kein Spatial-Steal.
4. **leftoverAssignHungarianX n≤3.** leftoverAssignRemint / leftoverAssignLive nutzen HungarianX, nicht FillX.
5. **leftoverHoldRemintPad** Solo Rescue / Twin Pad. leftoverHoldHashHammingRescue faces==1. leftoverHoldRemintId `pad:`.
6. **leftoverHoldTrailEMA Cap 4.** leftoverJpegProbeTTLPref 0,25–1,2 + Slider. leftoverStoredHashMerge persist. leftoverMirrorPending JPEG/Streak/Wipe/IoU/Spark/Miss.
7. Tests + VERSION = Models = MARKETING 2.1.139 (Build 164).

Helios 1.5.129: Fill-Cap Slider, Pinch Click/Drag Cursor-px, Keep-Bit je Slot. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.138)

Helios **1.5.128** (Build 147). Aegis **2.1.138 alpha** (Build 163). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.137: Schema 8 PairLast/NameLock remaining/HoldTrail, AssignAtomic, FillX Pref. PairStreak/Commit/Streak RAM-only. leftoverStreakSince absolute Epoch. Assign greedy. FillX Pad ohne Slider. Gate Crowd max 2.

## Warum Taufe und Restart nach 2.1.137 weiter rissen

1. **leftoverPairStreak / leftoverPairCommit / leftoverStreak nicht persist.** Majority und Streak nach App-Restart tot. Schema 8 hatte PairLast, nicht die Stimmen.
2. **leftoverStreakSince absolute Epoch.** Survive nach Restart: Hold-TTL abgelaufen, Remint hat nichts. Schema 8 >100 = Epoch, jetzt remaining analog NameLockUntil.
3. **leftoverAssign greedy + 2-opt.** n=3 Crowd: 3-Zyklus unbehandelt. Hungarian nach leftoverAssign.
4. **Hash-Rescue Spatial auch bei Twin.** Hamming-1 / `#101` stiehlt den Nachbarn. facesInFrame ≥ 2 Exact-only.
5. **leftoverHoldRemint erster Pass hart Pad 0,12.** Walker 18 cm tot, dritter Pass padRescue kam zu spät.
6. **FillX Pad Pref ohne UI.** Math 0,06–0,20, Slider fehlte. Gate Crowd max 2 trotz Hungarian n=3.
7. **HoldTrail unbeschränkt.** RAM. leftoverUUIDUUIDMap dest tot nach Vision-Restart.
8. **restoreFromBackup wischte Schema-9-Maps.** extra load, dann `leftoverStreak = [:]`.

## Was 2.1.138 ändert

1. **Schema 9.** leftoverPairStreak, leftoverPairCommit, leftoverStreak persist. Backup restore lädt extra nach den Transient-Wipes.
2. **leftoverSeenRemainingEncode / leftoverSeenRestore.** Remaining seconds. Schema 8 Epoch (>100) rebase auf now.
3. **leftoverAssignHungarian** 3-Zyklus nach leftoverAssign. leftoverAssignLive Hungarian + padFill.
4. **leftoverHoldHashRescue facesInFrame.** Twin Exact, Solo Spatial. leftoverHoldRemint erster Pass padRescue.
5. **leftoverFillXPad Pref UI 0,06–0,20.** Gate Crowd 3.
6. **leftoverHoldTrailCap 4.** leftoverUUIDUUIDMapDropDangling, Decode dest==key tot.
7. Tests + VERSION = Models = MARKETING 2.1.138 (Build 163).

Helios 1.5.128: CADisplayLink 120, Kalman-Scale, Pad-UUID, Keep je Hand. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.137)

Helios **1.5.127** (Build 146). Aegis **2.1.137 alpha** (Build 162). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.136: leftoverHoldMove overwrite, Twin-Yaw-Tie, Schema 7 leftoverHold/LastHash/NameLockHeld. PairLast, NameLockUntil, HoldTrail RAM-only. AssignLive Hold nicht atomar. FillX Rescue 0,28 hart.

## 2.1.136 → 2.1.137

1. **leftoverPairLast / leftoverNameLockUntil / leftoverHoldTrail nicht persist.** App-Restart: Twin-Taufe, NameLock tot, Trail-ReID tot.
2. **leftoverNameLockUntilRestore nur now+Arm.** Absolute Epoch nach Restart in der Vergangenheit. Survive wischt vor Remint.
3. **leftoverAssignLive nicht atomar.** leftoverMirrorPending bewegte Pair/Hash, nicht leftoverHold. Hold/Bins desync.
4. **leftoverHoldMoveBins fehlte.** AssignLive leftoverHoldBins bleiben auf alter UUID.
5. **leftoverFillXRescue hart 0,28.** 18 cm Kopf tot oder Crowd tauft Far.
6. leftoverHoldTrail RAM nach stopLive blieb, leftoverHold leer — Desync.

## Was 2.1.137 ändert

1. **Schema 8.** leftoverPairLast, leftoverNameLockUntil remaining, leftoverHoldTrail persist.
2. **leftoverNameLockUntil remaining-first.** Encode left seconds, Decode now:0, Restore remaining dann Arm.
3. **leftoverAssignAtomic** = leftoverHoldMove. leftoverMirrorPending leftoverHold/Trail/NameLock/Bins.
4. **leftoverHoldMoveBins.** UUID.bin Keys analog leftoverHoldMove, Dest overwrite.
5. **leftoverFillXRescuePref 0,16–0,36 + UI.** leftoverAssignLive pad, leftoverHoldRemint padRescue.
6. leftoverHoldTrail wipe mit leftoverHold. Backup restore wäscht PairLast nicht.
7. Tests + VERSION = Models = MARKETING 2.1.137 (Build 162).

Helios 1.5.127: screenKeySeed folgt, Overlap auto, Faust 2-Frame, Reanchor, bugfix-Prefs. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.136)

Helios **1.5.126** (Build 145). Aegis **2.1.136 alpha** (Build 161). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.135: leftoverStoredHashMerge, leftoverHoldByHashRescue. leftoverHoldMove droppte Dest. Center-Stage-Twins beide Occupied. leftoverHold/LastHash RAM-only nach App-Restart.

## 2.1.135 → 2.1.136

1. **leftoverHoldMove nur wenn Dest leer.** AssignLive: TickCopy überschreibt, HoldMove droppt from ohne to. Pair/Streak/Commit tot, Hash und Hold desync.
2. **leftoverHashTwinLeft Gleichstand beide Occupied.** Center-Stage x gleich: Exact tot, Majority tauft. Rank beide 0, beide Bare.
3. **leftoverHold / leftoverLastHash / leftoverNameLockHeld nicht in gallery.json.** App-Restart: leftoverHoldSurvive trifft neue UUIDs, Remint hat nichts zu kopieren. ByHash-Rescue ohne storedHash.
4. leftoverOccupiedMerge stored-first: Ghost-Hashes vor Live.

## Was 2.1.136 ändert

1. **`leftoverHoldMove` overwrite** wie TickCopy. DestClash Test.
2. **Twin-Yaw-Tie.** kleinerer yawAbs Exact + Rank 0, größerer `#101`. Ohne Yaw bleibt Gleichstand Occupied (alte Tests).
3. **Schema 7.** leftoverLastHash, leftoverHold, leftoverNameLockHeld persist. Until = now+Arm, sonst Survive wischt vor Remint.
4. **leftoverOccupiedMerge live-first.**
5. leftoverHashTwinRanked / Occupied in LibraryStore mit liveYaw.
6. Tests + VERSION = Models = MARKETING 2.1.136 (Build 161).

Helios 1.5.126: lastScreenID Relativ-Seed, Prop-Alloc keep:false. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.135)

Helios **1.5.125** (Build 144). Aegis **2.1.135 alpha** (Build 160). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.133: leftoverHoldByHashSolo, AssignLiveGate UI. 2.1.134 Review. Solo stiehlt den Nachbarn, Last∪Tick fehlt.

## 2.1.133 → 2.1.135

1. **leftoverHoldByHashSolo nur `holdIDs.count == 1`.** 2 Holds + unique Hash = tot. 1 Hold + fremder Hash = stiehlt den Nachbarn (REVIEW 2.1.134).
2. **leftoverHoldByHash Bins `#0`/`#1`.** Spatial gleich, Solo zählt Keys nicht — das saß. Hash-Match bei 2 Holds fehlte.
3. **remintStoredHash = leftoverLastHash.** Mirror vor Tick-Write: Last leer, Tick hat den Hash, Hash-Rescue tot.
4. **leftoverHoldByHashSolo ohne storedHash.** Unique Hash-Match trotz Twin-Holds unmöglich.

## Was 2.1.135 ändert

1. **`leftoverStoredHashMerge`.** Tick füllt Last-Löcher, Last nicht überschreiben.
2. **`leftoverHoldByHashRescue`.** Unique Hash-Match zuerst. Twin tot. 1-open nur wenn alle storedHashes leer. Nachbar mit anderem Hash nicht stehlen. Bins zählen als eins.
3. leftoverHoldByHashSolo bleibt, ruft Rescue (leere Hashes).
4. leftoverHoldRemint / RemintBins hashTable-Pass nutzt Rescue + storedHash.
5. Tests + VERSION = Models = MARKETING 2.1.135 (Build 160).

Helios 1.5.125: destClampMap Latch, Keep 0,03, Naht-Hold Pref. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.133)


Helios **1.5.123** (Build 143). Aegis **2.1.133 alpha** (Build 159). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.132: Pair bleibt nach AssignLive, Value-Remint, AssignLive x-Rescue. leftoverLastHash leer nach Restart: Hash-Rescue tot. AssignLiveGate Pref ohne UI.

## 2.1.132 → 2.1.133

1. **leftoverHoldRemint Hash nur leftoverLastHash.** Restart wischt LastHash. leftoverHoldByHash persistiert im gallery.json — ungenutzt. Solo-Walk 18 cm ohne LastHash = neue UUID, Name springt.
2. **leftoverAssignLiveGate hart 1.** Crowd: Twin-Taufe nach Restart. Pref-Clamp 1–2 saß, niemand konnte umschalten.

## Was 2.1.133 ändert

1. **`leftoverHoldByHashSolo`.** Spatial-Match auf leftoverHoldByHash Keys. Nur 1 Hold. Twin tot.
2. **leftoverHoldRemint / Bins / RemintId `hashTableKeys`.** Vierter Pass nach x/Hash/x-Rescue.
3. **AssignLiveGate Pref + UI.** Solo 1 / Crowd 2, UserDefaults `aegis.assignLiveGate`.
4. Tests + VERSION = Models = MARKETING 2.1.133 (Build 159).

Helios 1.5.123: Prop nie S1, 40 px Overlap 5K. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.132)

Helios **1.5.122** (Build 142). Aegis **2.1.132 alpha** (Build 158). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.131: Pair HoldMove + Value-Remint, x-Rescue 0,28. AssignLive ClearStreak vor Mirror. PairLast/Commit Key-only Remint.

## 2.1.131 → 2.1.132

1. **leftoverClearStreak vor leftoverMirrorPending.** AssignLive setzt PairCommit, ClearStreak löscht ihn, Mirror findet Pair auf newId nicht. Majority nach Transfer 0 — Name springt.
2. **leftoverHoldRemint Pair Value.** Key new, Value old. Overlay keyed live.id, Majority keyed old.id. 1 Frame tot.
3. **leftoverAssignFillX nur Pad 0,12.** Kopf 18 cm: AssignLive tot, nur Remint-Hold rettete. Overlay ohne Transfer.

## Was 2.1.132 ändert

1. **`leftoverClearDropsPair`.** Transfer: leftoverClearStreak(pair: false). Adopt-Streak tot, Pair bleibt.
2. **`leftoverHoldRemintId`.** PairLast/Commit Value = Live-UUID nach x-Remint.
3. **leftoverAssignLive FillX Rescue 0,28.** Dritter Pass, Far 0,90 tot.
4. Tests + VERSION = Models = MARKETING 2.1.132 (Build 158).

Helios 1.5.122: Prop-S2 Crop, Clamp kein Laptop-first. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.131)

Helios **1.5.121** (Build 141). Aegis **2.1.131 alpha** (Build 157). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.130: Hash-Rescue, Tick-Copy, Gate Need. Pair* nach Transfer tot. x-Pad 0,12 ohne Hash tot wenn Person ging.

## 2.1.130 → 2.1.131

1. **leftoverLiveHashTickCopy String-only.** leftoverMirrorPending kopiert Tick/LastHash, nicht PairLast/Streak/Commit/Disagree. Swap + AssignLive: Majority-Streak auf newId, Overlay keyed old.id.
2. **leftoverHoldRemint nur x 0,12 dann Hash.** Hash leer, Kopf 18 cm: d=0,18 > 0,12, Remint tot, Name springt.
3. **PairCommit Value ist Live-UUID.** Key-Move allein lässt Commit auf newId nach Transfer.

## Was 2.1.131 ändert

1. **`leftoverFillXRescue` 0,28.** Dritter Pass nach x 0,12 und Hash. 0,90 vs 0,20 bleibt tot (d=0,70).
2. **leftoverHoldRemint / RemintBins** x-Rescue nach Hash-Miss.
3. **`leftoverHoldMove` generic.** leftoverMirrorPending bewegt PairLast/Streak/Commit/Disagree.
4. **`leftoverHoldMoveId`.** PairLast/Commit Value new→old.
5. Tests (walked 0,40 vs 0,22, Pair HoldMove, Value-Remint) + VERSION = Models = MARKETING 2.1.131 (Build 157).

Helios 1.5.121: Prop-S1 Full, Zweit-Hand Full. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-06 (2.1.130)

Helios **1.5.120** (Build 140). Aegis **2.1.130 alpha** (Build 156). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.129: AssignLive 1+1, Pair/Streak Remint, StreakBox Live. x-Match Pad 0,12. Transfer ohne Tick-Copy.

## 2.1.129 → 2.1.130

1. **leftoverHoldRemint nur x.** Kopf 20 cm zur Seite während Vision-Restart: d > 0,12, Remint tot, neue UUID, Name springt.
2. **leftoverLiveHashTick nach Transfer.** `adopted.id = old.id`, Tick bleibt auf newId. Rank/Occupied 1 Frame tot, Twin stiehlt Exact.
3. **leftoverLastHash analog.** Overlay keyed live.id, Last keyed old.id.
4. **AssignLiveGate hart 1.** Crowd default 2 fehlt als Pref-Clamp.

## Was 2.1.130 ändert

1. **`leftoverHoldHashRescue`.** Spatial Hamming-0, Occupied skip, Twin (2 Hits) tot.
2. **leftoverHoldRemint / RemintBins** liveHash+storedHash. x zuerst, Hash wenn Pad miss.
3. **`leftoverLiveHashTickCopy`.** leftoverMirrorPending kopiert Tick + LastHash new→old, überschreibt (Live frischer). leftoverPendingMirror hält Namen.
4. **`leftoverAssignLiveGateNeed` 1–2.**
5. **Remint-Hash `leftoverLiveHash` + imageW.** leftoverBoxHash ohne Bildmaß ist 12-Bin, Continuity 16 — Rescue tot.
6. Tests + VERSION = Models = MARKETING_VERSION 2.1.130 (Build 156).

Helios 1.5.120: destEdgeSkip 160 ms, Blend/Predict tot nach Cross. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.129)

Helios **1.5.115** (Build 135). Aegis **2.1.129 alpha** (Build 155). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.128: AssignLive Remint, leftoverHold UUID/Bins Remint. AssignLive erst ab 2 Gesichtern. Pair/Streak nicht reminted. StreakBox tot nach Restart.

## 2.1.128 → 2.1.129

1. **AssignLive ≥2.** Vision-Restart, eine Person: unnamed=1 unused=1. ID-Transfer tot. Overlay hält neuen UUID, Galerie den alten.
2. **leftoverPairCommit/Streak/Last/Disagree nicht reminted.** Overlay keyed live.id, AssignLive keyed old.id. Majority-Streak nach Restart 0.
3. **leftoverStreakBox nur leftoverAdvance.** Ohne AssignLive bleibt x auf old — nächster Hitch matched tot.

## Was 2.1.129 ändert

1. **`leftoverAssignLiveGate` 1+1.** LibraryStore nicht mehr ≥2.
2. **leftoverHoldRemint** PairLast/Streak/Commit, Disagree, Streak, StreakBox, StreakSince.
3. **`leftoverStreakBoxLive`.** Hold-Keys bekommen die Live-Box nach Remint.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.129 (Build 155).

Helios 1.5.115: destEdgeCrosses innerster, Cross-Hold 80 ms. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.128)

Helios **1.5.113** (Build 133). Aegis **2.1.128 alpha** (Build 154). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.127: leftoverXAmbiguous relativ 2·d, FillX Spread. AssignLive Print vor x. leftoverHold tot auf neuer UUID.

## 2.1.127 → 2.1.128

1. **leftoverAssignLive Print zuerst.** Restart-UUIDs, schwache Cosine, x-Match erst auf leeren Zeilen. Falscher Twin bleibt.
2. **leftoverHold UUID tot nach Restart.** leftoverHold[old] überlebt Survive, Live hat neue UUID. holdPrev leer bis Adopt. leftoverHoldBins/NameLock/JPEG bleiben auf old.
3. **leftoverHoldRemint stored = leftoverStreakBox roh.** Stale-Streak näher als Hold → Remint tot.

## Was 2.1.128 ändert

1. **`leftoverAssignRemint` vor Print** in leftoverAssignLive. Print füllt Rest, stiehlt keine Remint-Spalte.
2. **`leftoverHoldRemint`.** stored nur Hold-Keys. Live-UUID schon im Hold = occupied. leftoverStreakBox ∪ liveGhosts.
3. **`leftoverHoldRemintBins`.** leftoverHoldBins/TrailBins. LibraryStore: NameLock, Pending, Miss, JPEG, LastHash, Spark, Wipe, LiveHashTick.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.128 (Build 154).

Nicht: leftoverHoldsTrack LOCK vor JUMP — Tests verlangen `JUMP Frame kein Hold` während LOCK. leftoverTransfersId sitzt.

Helios 1.5.113: destEdgeNearest innerster, FillAxis toward, Seam still. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.127)

Helios **1.5.109** (Build 129). Aegis **2.1.127 alpha** (Build 153). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.126: FillX Dist-greedy, HoldX Occupied+Spread, Gate Original-Lage. leftoverHoldXMatch `d2-d<=0,08` tötete 0,02 vs 0,08. FillX ohne Spread.

## 2.1.126 → 2.1.127

1. **leftoverHoldXMatch Spread zu grob.** Live 0,22, Holds 0,20 und 0,30: d=0,02 d2=0,08, `d2-d=0,06<=0,08` → nil. Test „näherer“ widersprach der Math. Twin nach Restart hungert, FillX greedy tauft trotzdem.
2. **leftoverAssignFillX ohne Spread.** Twin-Mitte 0,50 zwischen Holds 0,45/0,55: greedy nimmt den Index. leftoverHoldXMatch wäre nil — FillX nicht.

## Was 2.1.127 ändert

1. **`leftoverXAmbiguous`.** d2 < 2·d, nicht nur d2−d ≤ 0,08. 0,02 vs 0,08 eindeutig. Twin-Mitte d=d2 tot.
2. **`leftoverHoldXMatch` / `leftoverAssignFillX` dieselbe Regel.** Occupied bleibt. FillX skippt Twin-Mitte.
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.127 (Build 153).

Nicht: Hash-Floor 0,64. leftoverHold UUID-Remint Dictionary verdrahtet. Schema 7 Name-Lock persist.

Helios 1.5.109: destEdgeHasNeighbor, Coast toward, Y-Coast. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.126)

Helios **1.5.108** (Build 128). Aegis **2.1.126 alpha** (Build 152). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.125: FillX Pad 0,12, TWIN 1/2/3, Gate Keep. leftoverAssignFillX zeilenweise greedy. leftoverHoldXMatch ohne Occupied.

## 2.1.125 → 2.1.126

1. **leftoverAssignFillX Hold-Index.** Hold[0] bei 0,30 nimmt Live 0,22 (d=0,08), Hold[1] bei 0,20 (d=0,02) bleibt leer. Twin-Taufe nach Restart.
2. **leftoverHoldXMatch ohne Occupied.** Zwei Lives claimen denselben Hold. Spread 0,08 fehlt — Mitte zwischen Twins tauft falsch.
3. **overlayChipCap ranked.prefix.** TWIN/NBR überleben, springen aber nach vorn.

## Was 2.1.126 ändert

1. **`leftoverAssignFillX` Dist-greedy.** Alle Paare nach d, unique. Nächster Hold gewinnt.
2. **`leftoverHoldXMatch(occupied:spread:)`.** Occupied skip. Spread-Veto wie leftoverAmbiguousSpread.
3. **`overlayChipCap` Keep-Set, Original-Reihenfolge.**
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.126 (Build 152).

Nicht: Hash-Floor 0,64. leftoverHold UUID-Remint Dictionary verdrahtet. Schema 7 Name-Lock persist.

Helios 1.5.108: destEdge toward, Fill-Lead, Gap-Cross. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.125)

Helios **1.5.107** (Build 127). Aegis **2.1.125 alpha** (Build 151). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.124: AssignLive, Capture-Hist Rank-Lookup, Cap Keep. FillX ohne Dist-Cap. Gate prefix droppt TWIN/NBR. Twin-Chip nur L/R.

## 2.1.124 → 2.1.125

1. **leftoverAssignFillX / leftoverHoldXMatch ohne Pad.** AssignLive rettet Twin-Veto, nicht Far: 0,90 tauft Hold 0,10 nach Restart.
2. **overlayChipCap prefix.** HASH/JPEG/FAST/INDOOR füllen 6, TWIN/NBR tot.
3. **leftoverHashTwinChip L/R.** Drei Gesichter: Mitte und Rechts beide `TWIN R`.

## Was 2.1.125 ändert

1. **`leftoverFillXPad` 0,12.** leftoverHoldXMatch + leftoverAssignFillX. Far tot. AssignLive erbt das.
2. **`overlayChipKeep`.** JUMP/LOCK/TWIN/NBR zuerst, unique.
3. **`leftoverHashTwinChip`.** Zwei Gesichter L/R, Crowd `TWIN 1/2/3`.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.125 (Build 151).

Nicht: Hash-Floor 0,64. leftoverHold UUID-Remint Dictionary. Schema 7 Name-Lock persist.

Helios 1.5.107: destEdge exact+Cross, Laterality-Veto, Chip-Keep. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.124)

Helios **1.5.106** (Build 126). Aegis **2.1.124 alpha** (Build 150). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.123: FillX nach DropAmbiguous, Twin-Spread 0,08 wieder zu. Capture-Hist schreibt Rank, liest Spatial. Cap ohne `at`.

## 2.1.123 → 2.1.124

1. **leftoverAssignFillX nach DropAmbiguous.** Twin-Zeile nil, FillX nach x wieder voll.
2. **Capture-Hist Lookup boxHash.** Twin R `bare#101` geschrieben, Spatial gelesen.
3. **leftoverCaptureHistTableCapped** Dictionary-Reihenfolge. Decode ohne Keep.

## Was 2.1.124 ändert

1. **`leftoverAssignLive`.** Assign → FillX → DropAmbiguous.
2. **`leftoverCaptureHistLookup`.** holdHash, Fallback Spatial.
3. **Cap Keep + sortierte Keys.** Persist Keep leftoverLastHash. Decode Keep Hold-Keys.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.124 (Build 150).

Helios 1.5.106: destEdge Screen-At, Chip-Cap, slotLateralityDist. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.123)

Helios **1.5.106** (Build 126). Aegis **2.1.123 alpha** (Build 149). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.122: Twin-Rank Exact `#101`, Occupied others, LastHash empty-Wipe. leftoverAssign Print tot nach Restart. Gate-Chips unbegrenzt.

## 2.1.122 → 2.1.123

1. **leftoverAssign nur Print.** Restart mintet IDs, Embedding leer, Nil-Zeilen bleiben tot. Nächster Hold ist der nach x.
2. **Gate-Chip-String wuchs.** HASH/LOCK/NBR/FAST/INDOOR/TWIN/JPEG deckt die Box.

## Was 2.1.123 ändert

1. **`leftoverHoldXMatch` + `leftoverAssignFillX`.** Nil-Zeilen nach x, Print-Assign bleibt.
2. **`overlayChipCap` 6** in leftoverGateChip.
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.123 (Build 149).

Nicht: Hash-Floor 0,64. dropoutTTLSticky tot. leftoverHoldsTrack während LOCK. Schema 7 Name-Lock persist.

Helios 1.5.106: destEdge Screen-At, Chip-Cap, slotLateralityDist. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.122)

Helios **1.5.105** (Build 125). Aegis **2.1.122 alpha** (Build 148). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.121: Capture-Hist/Trail Cap 64, Twin-Gleichstand Occupied, Nachbar-Walk aus. Twin R blieb Occupied (gleicher Spatial-Hash). leftoverOccupied others nur Live-Tick. leftoverLastHash nach empty tot.

## 2.1.121 → 2.1.122 (warum Twin R namenlos / Ghost blockt Re-Entry)

1. **Hamming-0 gleicher Key.** `leftoverHashTwinOccupied` gibt Twin R Occupied. Exact tot. Majority tauft. leftoverHoldPut schrieb Spatial `boxHash` — Rank nie persist.
2. **Occupied others nur `leftoverLiveHashTick`.** Twin aus leftoverLastHash unsichtbar. Erster Frame / Ghost steals.
3. **`leftoverLiveHashTickWipes` ohne leftoverLastHash.** empty wischt Tick, Last bleibt. `leftoverHashOwnOccupied` blockt Re-Entry in derselben Bin.

## Was 2.1.122 ändert

1. **`leftoverHashTwinRanked` / `leftoverHoldHashTwinKey`.** Twin L Bare, Twin R `hash#101`. leftoverHoldPut/Trail/Lookup/LastHash den Rank.
2. **`leftoverOccupiedOthers`.** live+stored, live vor stored, except-self.
3. **`leftoverLastHashWipes`.** empty → Last leer, außer Overlay-Keep. **`leftoverRankedHashOf`.** Tick vor Last vor Spatial.
4. **`leftoverHoldHashSpatial`.** NBR Dist nicht 99 bei Rank+Bin.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.122 (Build 148).

Helios 1.5.105: Laterality kein Claim-Flip, OCC Tip folgt Palm, Pad max-Screen. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.121)

Helios **1.5.104** (Build 124). Aegis **2.1.121 alpha** (Build 147). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.120: Twin x-order, empty Hash-Wipe, LOCK/Adopt Slider. Capture-Hist und Hash-Trail ohne Key-Cap. Twin-Gleichstand beide Exact. Nachbar-Walk trotz Hamming-1 Veto.

## 2.1.120 → 2.1.121

1. **leftoverCaptureHistByHash unbounded.** Pro Frame ein Box-Hash, persist, kein Cap.
2. **leftoverHoldTrailByHash nur TTL.** Hold Cap 64, Trail nicht. Rebase-Skip hält alles.
3. **leftoverHashTwinLeft `<=`.** Identisches x: beide links, beide Exact.
4. **leftoverHoldNeighborOk nach dem Grid.** Twin dist≥1 tot, 625 Keys trotzdem.

## Was 2.1.121 ändert

1. **leftoverCaptureHistTableCapped/Put 64.**
2. **leftoverHashTrailCapped 64** Put/Prune/Encode/Decode.
3. **leftoverHashTwinLeft strikt `<`.** Gleichstand Occupied.
4. **leftoverHoldNeighborScans** — Twin kein Nachbar-Walk. Kommentar Hamming-1.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.121 (Build 147).

Nicht: Hash-Floor 0,64 (kein Sharpness, sonst 2.1.113 Twin nach Restart). dropoutTTLSticky tot — App nimmt leftoverHoldTTLOf. leftoverHoldsTrack während LOCK — JUMP bricht, Tests verlangen Overlay halten.

Helios 1.5.104: Occlusion 2-Tick, Relativ-Snap, JUMP-Slow, Laterality 3 Ticks. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.120)

Helios **1.5.104** (Build 124). Aegis **2.1.120 alpha** (Build 146). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.119: Hold-TTL Slider, Occupied live diesen Tick. Occupied tötete beide Hamming-0 Twins. leftoverLiveHashTick nach empty tot. LOCK/Adopt Clamp ohne Slider. INDOOR unsichtbar.

## 2.1.119 → 2.1.120 (warum Twins noch beide tot / Holds nach Dropout / LOCK 1,2 hart)

1. **Occupied Hamming-0 beide.** leftoverHashOwnOccupied true für links und rechts. Exact tot, Majority tauft.
2. **leftoverLiveHashTick nach empty.** found.isEmpty wischte nicht. Occupied-Geister blocken Re-Entry.
3. **LOCK/Adopt Pref Clamp ohne Arm.** leftoverNameLockArm hart 1,20. leftoverAdoptNeedSec hart 0,80. Slider tot.
4. **Indoor-Latch ohne HUD.** FAST nur nach Hop, 4 s unsichtbar.

## Was 2.1.120 ändert

1. **`leftoverHashTwinOccupied`.** x-order: Twin L Exact, Twin R Occupied. HUD `TWIN L`/`TWIN R`.
2. **`leftoverLiveHashTickWipes`.** empty → Tick leer.
3. **`leftoverNameLockArm(sec:)` + Slider 0,6–2,0. `leftoverAdoptNeedSec(lockPref:)` + Slider 0,6–1,4.**
4. **`leftoverHoldIndoorChip` HUD `INDOOR 4s`.**
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.120 (Build 146).

Helios 1.5.104: Occlusion 2-Tick, Relativ-Snap, JUMP-Slow, Laterality 3 Ticks. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.119)

Helios **1.5.103** (Build 123). Aegis **2.1.119 alpha** (Build 145). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.118: Hamming-1 Veto, Exact occupied, Name-Lock Overlay. leftoverHoldTTLPref Clamp um Sticky 1,2/4,0 — Slider tot. Occupied nur leftoverLastHash — erster Twin-Frame stiehlt Exact.

## 2.1.118 → 2.1.119 (warum Holds nach 1,2 s und beim ersten Twin noch sprangen)

1. **leftoverHoldTTLPref tot.** Clamp um dropoutTTLSticky 1,2 oder 4,0. Kein Slider. 24 fps Hold stirbt nach 1,2 s.
2. **Occupied nur Vor-Tick.** leftoverLastHash leer beim ersten Twin-Frame. leftoverHashOwnOccupied false → Exact 0,80 tauft.

## Was 2.1.119 ändert

1. **`leftoverHoldTTLOf`.** Indoor 4 s, 24 fps Slider 1,2–4,0 persist.
2. **`leftoverOccupiedMerge`.** stored + live diesen Tick. Exact occupied ab Frame 0.
3. Tests + VERSION = Models = MARKETING_VERSION 2.1.119 (Build 145).

Helios 1.5.103: Tip-Restore tot, live PAD, Wi-Fi-Veto. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.118)

Helios **1.5.102** (Build 122). Aegis **2.1.118 alpha** (Build 144). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.117: Majority LOCK, Overlay leftoverLiveNameAnd, HUD NBR/FAST. Hamming-1 blieb erlaubt. Exact-Key vor Occupied. Overlay leftoverNameFromHold tauft. leftoverLiveNameAnd held = hit.identityId (Twin).

## 2.1.117 → 2.1.118 (warum Twins noch tauschen)

1. **Hamming-1 Neighbor.** dist≥2 tot, dist 1 (Nachbar-Bin) erlaubt — näher als Hamming-2.
2. **Exact-Key vor Occupied.** Twin in derselben Bin liest `hash#0` 0,80.
3. **Overlay leftoverNameFromHold / leftoverLiveNameAnd held=hit.identityId.** LOCK sitzt, Name springt auf den Twin.

## Was 2.1.118 ändert

1. **`leftoverHoldNeighborOk` dist≥1 tot** bei faces≥2. Exact dist 0 hält. HUD `NBR` auch Hamming-1.
2. **`leftoverHashOwnOccupied`.** Lookup/Trail/Pick/PrevOf nil bei fremder Exact-Bin.
3. **`leftoverNameLockKeeps`.** Overlay `leftoverJumpName` zuerst. leftoverLiveNameAnd held = liveNameLock. leftoverNameLockHeld.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.118 (Build 144).

Helios 1.5.102: Warp-Snap Restore. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.117)

Helios **1.5.101** (Build 121). Aegis **2.1.117 alpha** (Build 143). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.116: Sticky-Reset, Hamming-2 Veto, Twin-name lock. leftoverTransfersId respektiert LOCK. leftoverPairCommit Majority und leftoverLiveNameAnd tauften trotzdem. NBR/FAST unsichtbar. leftoverLiveNameAnd(locked) nil wischt Overlay. NBR-HUD dist=2 sobald zwei Köpfe live.

## 2.1.116 → 2.1.117 (warum Namen nach JUMP noch sprangen)

1. **`leftoverAssignMajority` ohne LOCK.** leftoverTransfersId tot 1,2 s, Ghost-2-opt nach 3 Frames (~0,2–0,4 s) schreibt leftoverPairCommit. Twin bekommt die UUID.
2. **`leftoverLiveNameAnd` ohne LOCK.** Overlay-Mehrheit wechselt den Namen während leftoverHoldsTrack den Track hält.
3. **Hamming-2 Veto ohne HUD.** Twin-Steal tot, Nutzer sieht nur HASH/LOCK.
4. **Sticky FAST unsichtbar.** Indoor-Latch nach Hop 4 s ohne Chip.
5. **`leftoverLiveNameAnd(locked) → nil`.** nameLockHolds(voted:nil) + leftoverLocked(holding) = Overlay-Name tot 1,2 s, danach Twin.
6. **NBR-HUD `faces≥2 → dist 2`.** Chip bei jedem Twin-Frame, nicht nur Hamming-2 Miss.

## Was 2.1.117 ändert

1. **`leftoverAssignMajority(locked:)`.** LOCK: streak 0, ready tot.
2. **`leftoverLiveNameAnd(locked:, held:)`.** LOCK hält Overlay-Namen, tauft nicht.
3. **Hist-Token leer während LOCK.** 3× Bert nach Unlock tot.
4. **`leftoverHoldNeighborDist` / `leftoverHoldHashBare`.** HUD `NBR` nur Lookup Hamming-2.
5. **`leftoverHoldFastChip` HUD `FAST`.** Sticky nach Hop.
6. **`leftoverNameLockSecPref` 0,6–2,0. `leftoverAdoptSecLockPref` 0,6–1,4.**
7. Tests + VERSION = Models = MARKETING_VERSION 2.1.117 (Build 143).

Helios 1.5.101: Warp-Hold JUMP, MUTE bis Release, Laterality HUD, USB transportType. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.116)


Helios **1.5.100** (Build 120). Aegis **2.1.116 alpha** (Build 142). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.115: Indoor-TTL 4 s, Sticky nach fps-Hop. Sticky blieb Session-ewig nach 8 s nur-24-fps. Hamming-2 Nachbar stahl den Twin. IoU-JUMP ohne Namens-Lock.

## 2.1.115 → 2.1.116 (warum Namen nach Licht-an und bei Twins noch sprangen)

1. **`dropoutSeenSlow` ohne Reset.** 8 Samples Slow → Latch 4 s für immer, auch nach 8 s nur-24-fps. Holds 4 s in heller Szene, Gast n+1 stirbt langsam.
2. **Hamming-2 Neighbor-Steal.** Zwei Gesichter live, Hash-Nachbar dist 2 erbt Annas Hold. Twin tauft.
3. **IoU-JUMP ohne Namens-Lock.** leftoverTransfersId 0,82 tauft den Nachbarn sobald IoU wieder hoch ist. Chip `JUMP` sitzt, Lock nicht.
4. **leftoverHoldTTL nur Takt.** Pref 1,2–4,0 fehlte — Slider/Clamp tot.

## Was 2.1.116 ändert

1. **`dropoutSeenSlow(fastFor:)`.** 8 s nur-24-fps setzt Sticky zurück.
2. **`leftoverHoldNeighborOk`.** faces≥2 und dist≥2 = kein Neighbor-Hold.
3. **`leftoverNameLockArm` 1,2 s nach JUMP.** leftoverTransfersId tot, leftoverHoldsTrack hält Overlay. HUD `LOCK`. leftoverHoldSurvive locked.
4. **`leftoverHoldTTLPref` 1,2–4,0.** Clamp um leftoverHoldTTL.
5. Tests + VERSION = Models = MARKETING_VERSION 2.1.116 (Build 142).

Helios 1.5.100: Fill-Mute, Laterality, destEdgePad Slider, Joint-EMA, USB/WIFI. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.115)

Helios **1.5.99** (Build 119). Aegis **2.1.115 alpha** (Build 141). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.114: Audit-Fixes, leftoverTrailPut nil-Bin. leftoverHoldPut und leftoverTrailPut prune Default 1,2 s. Transfers-Prune ohne ttl. Median-Hop 8→24 wischt Indoor-Latch.

## 2.1.114 → 2.1.115 (warum Namen indoor nach 1,2 s noch sprangen)

1. **`leftoverHoldPut` prune Default 1,2 s.** Jede Taufe wischt Holds älter als 1,2 s, obwohl dropoutTTL 8 fps = 4 s.
2. **Transfers-Prune ohne ttl.** 1,2 s nochmal nach leftoverTransfersId.
3. **`leftoverTrailPut` prune Default 1,2 s.** Spark-Trail indoor tot.
4. **Median-Hop 8→24.** liveDt 8 Samples unter 0,08 → TTL 1,2 s. Holds von vor 2 s tot, Licht an = Gast n+1.

## Was 2.1.115 ändert

1. **`leftoverHoldPut` / leftoverTrailPut `ttl:` leftoverHoldTTL.** Indoor 4 s. Key-Logik 2.1.114 (nil-Bin unbinned) bleibt.
2. **Transfers-Prune leftoverHoldTTL.** Nicht leftoverAdoptSec.
3. **`dropoutTTLSticky` / dropoutSeenSlow.** 8 Samples Slow → Latch 4 s bleibt nach Hop. Fallback 0,125 kein Sticky.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.115 (Build 141).

Helios 1.5.99: Vel-TTL 0,40 s, JUMP, Fill lastMapped2. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.



Helios **1.5.98** (Build 118). Aegis **2.1.114 alpha** (Build 140). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.113: Prune-Skip Rebase, Hash-Floor 0,64, Cap 64, Capture-Hist persist, HUD HASH/JPEG/JUMP. Audit 44 Punkte — nur bestätigte Bugs.

## 2.1.113 → 2.1.114

1. **Drei Uhren.** Webcam-PTS / Player-Item / Epoch. Overlay-Chips und Tap-Lock tot oder klebten.
2. **leftoverAssign 2-opt** schrieb dieselbe Spalte zweimal (Snapshot vs result).
3. **CI** `git add Aegis.dmg` trotz gitignore, Job rot nach Release. codesign ohne Entitlements.
4. **Resume** ohne Bookmark, Detect-UUIDs nach Neustart tot.
5. **TAR@0,1 %FAR** bei n·FAR < 1 = höchster Impostor.
6. **RTSP** → AVPlayer, spielt nicht. Center Stage `.user` Setter Exception.
7. **retainAccess** stoppte denselben URL. restoreFromBackup ließ Live-Dicts.

## Was 2.1.114 ändert

1. **Live-Stamp immer Epoch.** Webcam und Player stempeln `Date().timeIntervalSince1970`.
2. **leftoverAssign Snapshot mitziehen** nach 2-opt-Tausch.
3. **CI:** kein `git add Aegis.dmg`. codesign `--entitlements`, ohne `|| true`.
4. **Resume** löst Security-Scoped Bookmark. Detect speichert Pfade, nicht RAM-UUIDs.
5. **tar()** nil wenn n·FAR < 1. DevTest-Header 1 Zahl. RTSP Fehler statt AVPlayer.
6. **Center Stage `.app`** vor Disable.
7. leftoverHoldPut nur `hash#bin` + Cap 64. Lookup fällt auf `#0`.
8. Tests + VERSION = Models = MARKETING_VERSION 2.1.114 (Build 140).

`bugfix` mergen: nein. Nur `main`.

# Helios + Aegis — Analyse 2026-09-05 (2.1.112)

Helios **1.5.97** (Build 117). Aegis **2.1.112 alpha** (Build 138). Nur `main`. `bugfix` ist 2.1.15 — nichts mergen.

2.1.111: Hash-Bin Trail-Test. Schema 5 persistiert UUID-Bins. Hash-Hold blieb RAM. Nach Restart neue Vision-UUIDs, Bins tot, Twin tauft den Nachbarn. Hash `at` nach Decode = App-Start, leftoverHoldPrune 1,2 s. Aegis.dmg im Git.

## 2.1.111 → 2.1.112 (warum Namen nach Restart noch sprangen)

1. **leftoverHoldByHash nur RAM.** Schema 5 UUID-Bins. Restart = neue Track-IDs, Hash-Steal hungert.
2. **Hash `at` nach Decode = App-Start.** TTL 1,2 s — Live nach 2 s Galerie = Hold weg. Rebase fehlte.
3. **Aegis.dmg im Quellbaum.** CI-Artefakt, nicht Quelle.

## Was 2.1.112 ändert

1. **gallery.json Schema 6.** leftoverHoldHash + leftoverHoldTrailHash.
2. **leftoverHashHoldEncode/Decode + Rebase** am ersten applyLiveFaces.
3. **Aegis.dmg untrack** + `.gitignore`.
4. Tests + VERSION = Models = MARKETING_VERSION 2.1.112 (Build 138).

Helios 1.5.97: Slow-TTL 2 s. Siehe `bpms9cmnxc-debug/Helios`.

`bugfix` mergen: nein. Nur `main`.

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
