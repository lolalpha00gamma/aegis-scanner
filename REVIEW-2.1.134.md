# Aegis Review 2.1.134 — 2026-09-06

Stand: **2.1.133 alpha Build 159**. Kein Merge von `bugfix` (2.1.15). Nur `main`.

## Warum es schlecht funktioniert

Aegis ist kein Tracker mit einem Zustand, sondern ein Stapel aus leftover-Maps. Jeder Fehlfall seit 2.1.100 hat eine neue Funktion bekommen (Solo-Hash, Twin-Rank, Occupied, AssignLiveGate, Baptize, JPEG-Probe). Zwei Gesichter plus Restart plus AssignLive laufen durch vier Schluesselraeume: Live-UUID, Hamming-Hash, Pose-Bin, PairLast.

Konkret:

1. leftoverHoldByHashSolo rettet den Restart, stiehlt aber den ersten Twin-Frame, wenn leftoverLastHash leer ist.
2. leftoverHoldMove schreibt nur wenn das Ziel leer ist. leftoverLiveHashTickCopy ueberschreibt immer. Nach AssignLive sind Hash und Hold desynchron.
3. leftoverHashTwinLeft bei gleicher x setzt beide Occupied — Center-Stage-Zwillinge sterben beide.
4. leftoverOccupiedMerge haengt Ghost-Hashes vor Live. Exact-Hold trifft Tote.
5. FaceEngine liefert CGImage ueber den Main-Thread. 15 fps Continuity plus Slider = Jank und schiefe leftoverSessionCapture.
6. Baptize-Gate kennt JPEG 70 Prozent, FaceEngine reextractet den Print nicht. Cosine-Drop wirkt wie Personenwechsel.
7. MatchMath.swift ~193 kB, Tests ~184 kB Orakel auf Flags. LiveCapture, FaceEngine, LibraryStore ohne Tests.
8. Gallery linear ueber alle Prints pro Frame. Doppelte Pixelpipeline 420v zu BGRA zu JPEG.

Das ist die Ineffizienz: nicht fehlende Flags, sondern zu viele Maps fuer dasselbe Gesicht.

## Bugfix-Protokoll

Pass 1–n auf MatchMath waere Flag-auf-Flag. Drei saubere Paesse ohne neuen Bug brauchen zuerst einen Split und eine State-Maschine. Ohne macOS-Toolchain hier kein Binary, kein XCTest.

Naechster sinnvoller Code-Schritt, nicht der 134. Schalter:

- Ein Schluessel pro Frame: liveUUID.
- Hash und Bin nur Features.
- AssignLive atomar (Hash + Hold + PairLast).
- Twin-Tie: kleinerer yawAbs, nicht beide tot.
- Detect auf outputQueue.
- JPEG-Reextract gegen denselben Buffer.

## Erweiterung

- Hold-SM: Unseen / Tentative / Held / Named.
- MatchMath split: Hold, Hash, Baptize, Assign.
- Print-Index Pose-Bin + Name.
- Shared XPC `helios.aegis.camera` mit Helios 1.5.123.
- RTSP 420f, Reconnect Exponential-Backoff.
- Watch-Folder PhotoKit, Export `.aegis` verschluesselt.
- P-Slot Maske/Schal, Brille-Slot als Twin-Veto.
- Temporal ReID-Graph ueber Hold-Trail.
- Overlay 60 Hz CAMetalLayer, Detect 8–24 fps.
- VNTrackObjectRequest statt nur Rectangles.
- Temperature-skalierte Cosine statt hart 0,80.
- gallery.json.bak Rotate 3, printRevision je Identity.

`VORSCHLAEGE-NEU.md` auf main kurz ueberschrieben in 0fd4fec — Inhalt hier und in der lokalen Kopie. Wiederherstellen aus dem Parent-Commit der Datei.

Nur main.
