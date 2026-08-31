# Aegis **2.0.5 alpha**

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden:
- [Aegis.dmg (Latest)](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)
- [Releases](https://github.com/lolalpha00gamma/aegis-scanner/releases)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI baut das Image nach jedem Push auf `main`.

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
