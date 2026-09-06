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
