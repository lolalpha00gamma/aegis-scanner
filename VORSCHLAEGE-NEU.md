# Nachtrag 2026-09-06 (2.1.135)

Siehe ANALYSE.md. **2.1.135** leftoverStoredHashMerge, leftoverHoldByHashRescue. Review 2.1.134 in `REVIEW-2.1.134.md`.

## In 2.1.135 gelandet

1. leftoverStoredHashMerge — Tick füllt Last, Last bleibt
2. leftoverHoldByHashRescue — Hash-Match zuerst, Twin tot, Nachbar nicht stehlen
3. leftoverHoldByHashSolo ruft Rescue
4. leftoverHoldRemint / RemintBins Rescue + storedHash
5. VERSION = Models = MARKETING_VERSION 2.1.135 (Build 160)

## Nächste, zusätzlich

- leftoverFillXRescue Pref 0,16–0,36. Hart 0,28.
- leftoverFillXPad Pref 0,06–0,20.
- leftoverHold UUID persist Schema 7 neben leftoverHoldByHash — App-Restart hat sonst nichts zu reminten.
- leftoverHoldTrailByHash analog Rescue.
- leftoverLiveHashTick vor leftoverMirrorPending schreiben.
- leftoverAssignLive atomar (Hash + Hold + PairLast) — REVIEW 2.1.134.
- Twin-Tie: kleinerer yawAbs, nicht beide Occupied.
- FaceEngine Detect auf outputQueue. JPEG-Reextract gegen denselben Buffer.
- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Hamming-1 Rescue nur Solo (faces=1), Twin bleibt Exact-only.
- Helios Frame-Pump, eine TCC. Shared XPC mit Helios 1.5.125.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80 Baptize.
- gallery.json.bak Rotate 3, printRevision je Identity.
- Watch-Folder PhotoKit, Export `.aegis` verschlüsselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph über Hold-Trail.
- Per-Box CLAHE statt Full-Frame.
- Continuity Desk-View yaw-floor 0,36.
- Print-Bank 5 Pose-Slots. DBSCAN vor Merge.
- leftoverJpegProbeReuse TTL Pref 0,25–1,2.
- leftoverNameLockHeld persist Schema 7.
- Schema 7 leftoverLastHash persist.

Die historische Liste bis 2.1.133: Commit `ce39283`. Review: `REVIEW-2.1.134.md`.

Nur main.

# Aegis Vorschlaege


Die laufende Review-Liste fuer 2.1.134 steht in `REVIEW-2.1.134.md`.

Die historische Liste bis 2.1.133 liegt im Commit vor `0fd4fec` (Blob `00b233bb7844f1e317ba134127e5c172ad873e95`).
Wiederherstellen:

`git checkout ce3928397bef69068db8cd1b66c6bf789160c69b -- VORSCHLAEGE-NEU.md`

Dann den Kopf aus REVIEW-2.1.134.md oben drauf.

Nur main.
