# Aegis **2.1.15 alpha**

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
