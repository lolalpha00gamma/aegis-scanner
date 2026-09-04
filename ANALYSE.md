# Helios + Aegis — Analyse 2026-09-04 (Pass 2.1.65)

Helios **1.5.50** (Build 70 geplant). Aegis **2.1.65 alpha** (Build 92). Kein Xcode-Lauf in der Linux-Sandbox; CI auf macos-26.

## Bugfix-Protokoll

### Pass 1 — neu gefunden

1. **leftoverHoldLookup nur Exact-Hash.** leftoverBoxHash rastert 12x12. Ein Schritt über die Bin-Kante wechselt 1.2.3.4 nach 1.3.3.4. Hold tot, obwohl dieselbe Kiste. Gleicher Klasse wie UUID-Dropout in 2.1.63.
   Fix: leftoverBoxHashNeighbors (cx/cy +/-1), Lookup nimmt den jüngsten gültigen Nachbarn.

2. **Print-Trail ohne MAD.** Median 0,64 neben einem Twin-Frame 0,80 commitet trotzdem, wenn der Median über Floor liegt.
   Fix: printMAD / printMADBlocks auf dem 5er-Trail in LibraryStore. Overlay MAD.

### Pass 2 — neu gefunden

3. **Nachbar-Lookup darf ferne Bins nicht erben.** Test 9.9.9.9 bleibt leer. Nur 8-Nachbarschaft auf Position, nicht auf Breite/Höhe.

4. **MAD braucht >= 3 Samples.** Ein oder zwei Cosines haben kein MAD.

### Pass 3

Keine neuen Bugs in den geänderten Pfaden. Loop für diesen Slice fertig.

Matching ist Pipeline, nicht eine Zahl. 2.1.64 hat UUID-Hold und stilles Gast-Persist geschlossen. 2.1.65 schließt den Hash-Kantensprung und den Trail-Spike.

Nur main.
