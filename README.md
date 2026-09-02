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

macOS 14 Sonoma oder neuer. Ad-hoc signiert. CI baut das Image nach jedem Push auf `main` oder `bugfix`.

## Neu in 2.1.15 alpha

Warum 2.1.14 trotz Box-Hysterese Live-Namen und Floors trotzdem verzerrte: irgendein Geschwister-Paar in der Galerie hat den Floor für alle um +4 angehoben. `rematch()` jeden Live-Frame hat Overlay-Namen zwischen Geschwistern springen lassen. Percent ohne EMA flackerte. Burst-Refs Cosine > 0,98 derselben Person blieben beide im Centroid.

- **Familien-Bump nur Best-Paar.** +4 Floor nur wenn die zwei Besten 0,80–0,88 Cosine haben, nicht weil irgendwer in der Galerie verwandt ist.
- **Namens-Mehrheit 3 Frames.** Overlay tauft nicht am einzelnen Tick.
- **Live-Score-EMA 0,35.** Badge flackert nicht mehr jedes Frame.
- **Gallery-Prune Cosine > 0,98.** Schärfere Ref derselben Person gewinnt.

## Neu in 2.1.14 alpha

Warum 2.1.13 trotz Spark-Reset und Labor-Filter Live-Box und TAR trotzdem verzerrte: 1-Euro kroch bei IoU 0,12–0,35 über das Bild. Burst-Kopien wurden zweite Refs. Leave-one-out ließ unscharfe Gallery-Refs im Centroid.

- **Box-Hysterese 2 Frames.** IoU < 0,35 hält die alte Kiste; erst das zweite ähnliche Frame darf springen (1-Euro reset). Unabhängig von der Ampel.
- **Ingest-Duplikat Cosine > 0,95.** Tile-/Burst-Kopien derselben Datei oder schon gesehener Prints fallen raus.
- **Labor qualityRejects auf der Gallery-Seite.** Unscharfe Refs im Leave-one-out zählen nicht in TAR.

## Neu in 2.1.13 alpha

Warum 2.1.12 trotz Spark und U-Taste Live-Masken und alte Refs trotzdem falsch anfühlte: `pinByPrint` resetete 1-Euro, nicht die Ampel-History. Maske im Track schrieb nichts und schlug auch nichts vor. 90-Tage-Refs sahen aus wie frische.

- **Spark-Reset nach Reconnect.** `lampHist` stirbt mit der Ghost-Box.
- **U-Slot-Vorschlag nach 1,2 s Maske.** Overlay `U?`, Taste U, nie still schreiben. Snapshot beim Hold, nicht der wackelige Tick.
- **Print-Alter 90 Tage.** `enrolledAt`, nicht Foto-mtime. Paler + Badge `90d`.
- **Labor ohne qualityRejects.** Unscharfe Leave-one-out-Paare zählen nicht in TAR.
- **gallery.json.bak** vor jedem persist.

## Neu in 2.1.12 alpha

Warum 2.1.11 trotz Ampel und Orient-Override Crowd, Masken-Labor und Continuity trotzdem verzerrte:

- **Tile-Budget 2.** Crowd bekommt Diagonale statt 5 Origins — weniger NMS-Zwillinge.
- **Labor trennt Maske/Voll.** Genuine-Paare `genuine-mask` vs `genuine-full`, TAR ohne Masken-Dämpfung extra.
- **Score-Histogramm** Genuine/Impostor als ASCII-Spark im Labor.
- **Ampel-Spark 8 Frames.** Live-History, nicht der einzelne Tick.
- **Continuity-Schärfe 0,08.** Desk-View darf 0,10–0,14 noch zum Print, Built-in bleibt 0,12.
- **Orient-Konflikt** einmal loggen, wenn Override und `videoRotationAngle` auseinanderliegen.
- **„doch Name“.** Hard-Negativ-Deckel 35 wieder aufheben.
- **Orient-Menü ohne Live.** Letzte `uniqueID` bleibt gespeichert, Override vor Webcam-Start.

## Neu in 2.1.11 alpha

Warum 2.1.10 trotz Schärfe-Floor und U-Slot Live und Masken trotzdem falsch drehte:

- **Per-Kamera Orientierungs-Override.** Continuity/`videoRotationAngle` lügt oft — Menü Auto/0/90/180/270 pro `uniqueID`.
- **Taste „U“ = Teil-Print.** Expliziter Masken-Slot, nicht nur Auto wenn der Mund fehlt.
- **Live-Quality-Ampel.** Capture / Schärfe / Yaw als drei Punkte am Overlay, bevor der Name kommt.
- **Schärfe vor dem Print.** Laplacian < 0,12 → `VNGenerateFacePrint` läuft nicht. Spart Vision, tauft niemanden unscharf.

## Neu in 2.1.10 alpha

Warum 2.1.9 trotz Teil-Print immer noch Masken und Portraits verzerrte:

- **Teil-Print gegen Teil-Centroid.** Maskierte Probe nicht mehr gegen den vollen Galerie-Mean (Stoff vs. Gesicht). Ohne U-Slot in der Galerie nur Dämpfung, kein Domain-Mix.
- **Maske als erste Referenz veto.** Stoff vergiftet den Centroid nicht. Extra-Foto ohne Maske, U-Slot nur als Zusatz.
- **Portrait-Tiles.** Ein großes Gesicht (≥ 28 % der kurzen Kante) wird nicht gekachelt — keine NMS-Zwillinge, keine falsche Print-IoU.
- **Schärfe < 0,12 hart.** Unscharfe Frames taufen niemanden und gehen nicht als Referenz rein.
- **Coverage-Slot U.** F / ¾ / P / U (Teil-Print). `partialPrint` überlebt den Galerie-Reload.

## Neu in 2.1.9 alpha

Warum 2.1.8 trotz 1-Euro und ceil-1 Labor und Live trotzdem verzerrte:

- **Live-Box nach Reconnect reset.** `pinByPrint` verwirft den 1-Euro der UUID — die Kiste klebt nicht am Ghost.
- **Teil-Print bei Maske.** Okkludierte untere Hälfte matcht Stirn/Augen, voller Print wird gedämpft (Deckel 88). Overlay „Maske · Teil-Print“.
- **TAR@FAR Bootstrap-CI**, wenn n_impostor < 200. Eine Schwelle bei n=10 lügt nicht mehr still.
- **Detect-Resume.** Abbruch nach Ingest merkt restliche Media-IDs, nicht nur Dateipfade.

## Neu in 2.1.8 alpha

Warum 2.1.7 trotz ehrlichem Score Labor und Live trotzdem verzerrte:

- **TAR@FAR ceil-1.** n=10 / FAR 10 % nimmt den höchsten Impostor, nicht den zweithöchsten. Labor ruft `MatchMath.tar`.
- **Live-Box 1-Euro** statt EMA 0,62/0,38 — die Kiste zittert nicht mit jedem Frame.
- **Print-Revision sichtbar.** Galerie unter anderem Vision-Modell → Warnung, nicht stilles Drift.
- **Scan-Resume.** Letzter Ordner als Bookmark, restliche Pfade nach Abbruch, Taste Fortsetzen.
- **Yaw-Slot-Print.** ¾-Probe gegen ¾-Refs, gemischt mit dem Gesamt-Centroid.
- **Labor listet Centroid-Gewichte** (capture · sharpness) pro Referenz.

## Neu in 2.1.7 alpha

Warum 2.1.6 trotz gewichtetem Centroid noch Fremde taufte und Live-IDs verlor:

- **`lookOf` 0,4 % Print ist kein „KI aus“.** `embed < 1 → geo` ist weg. Gemessener Impostor-Print bleibt Impostor, Geometrie tauft niemanden.
- **Crop-Print mit Orientierung.** Fallback-Crop in `stampPrints` läuft nicht mehr als `.up`.
- **Coverage-Slot blockt.** + auf einen vollen Frontal-Slot ohne ¾ wird abgelehnt, nicht nur gewarnt.
- **Live-Reconnect hält UUID.** Nach Kamera-Drop matcht der Print (Cosine > 0,72) gegen Ghosts 1,8 s — nicht nur IoU.
- **Built-in-Webcam zuerst.** Continuity ist Fallback, analog Helios.
- **Familien-Floor +4**, wenn zwei Galerie-Centroids Cosine 0,80–0,88 haben.
- **„nicht Name“.** Hard-Negativ-Vektor, Score-Deckel 35 für diese Person.
- **Anlegen-Bestätigung** bei Duplikat-Cosine > 0,88.
- **MatchMath** wieder im Target und im CI. Overlay „Maske?“ / „Sonnenbrille?“.

## Neu in 2.1.6 alpha

2.1.5 hat HLS gedreht und Scans abbrechbar gemacht — unscharfe Refs haben den Centroid trotzdem gezogen, große Ordner liefen nach Cancel weiter, HLS blieb bei 4,5 fps, und fünf Frontals haben keinen ¾-Slot gefüllt.

- **Qualitätsgewichteter Centroid.** Refs zählen mit `capture * sharpness`, nicht 1/n.
- **Walk-Cancel pro Datei.** `FileManager.enumerator` prüft ein Sendable-Flag, nicht nur zwischen Ordnern.
- **HLS-FPS an Last.** Player-Timer 2 fps leer / 8 fps bei Track, wie die Webcam.
- **Pose-Coverage.** Pro Identität F / ¾ / P. Warnung, wenn derselbe Slot schon 2× voll ist und ein anderer leer.
- **Print-Drift-Alarm.** Live-EMA weicht >0,12 Cosine vom Galerie-Centroid ab → Overlay „andere Person oder Brille?“.
- **Referenz-Vorschau** unter Anlegen: Print-% gegen Rivalen und Slot, bevor die UUID geschrieben wird.
- **`printVec` beim Stamp.** Face-Print füllt den Vektor sofort, nicht erst im Live-EMA.

## Neu in 2.1.5 alpha

2.1.4 hat Live-Orientierung und Yaw-Keyframes — HLS, Enrollment und große Ordner haben trotzdem gelogen oder die UI festgenagelt.

- **HLS/Player-Transform.** `AVAssetTrack.preferredTransform` dreht den Pixel-Buffer, bevor Vision ihn sieht — nicht nur die Webcam-Connection.
- **Enrollment-Veto bei Yaw > 0,7** auf der *ersten* Referenz. Ein Profil verdreht den Galerie-Centroid nicht mehr.
- **Duplikat-Warnung** beim Anlegen, wenn Centroid-Cosine zu einer existierenden Person > 0,88.
- **Print-% bleibt am Badge**, auch wenn der Hinweis „Profil“ / „unscharf“ ist.
- **Scan abbrechen.** Ordner-Walk läuft off-Main, Detect prüft eine Generation — große Mediatheken blocken die Statuszeile nicht mehr minutenlang ohne Ausweg.
- **Live-FPS an Last.** 2 fps ohne Gesicht, 8 fps sobald ein Track sitzt (war fest ~5 fps).
- **HEIC-Burst.** Schärfstes der ersten 8 Frames, nicht Index 0 eines Live Photos.

## Neu in 2.1.4 alpha

2.1.3 hat den Score ehrlich gemacht — Live und Video haben ihn trotzdem verdreht: Vision las jedes Frame als `.up`, der Ingest behielt 20× dieselbe Pose, der Slider log den Floor.

- **Live-Orientierung** aus der Capture-Connection, wiederverwendeter CIContext.
- **Yaw-diverse Keyframes** beim Video (Δyaw ≥ 0,22).
- **Overlay-Grund** (Okklusion / z / Profil / unscharf), **NMS-Twins** optional gestrichelt.
- **Slider zeigt effektiven Floor**, Labor **Konfusion + EXIF**, Live-Box **EMA**.

## Neu in 2.1.3 alpha

2.1.2 hat den Print ehrlich gemacht — und ihn danach in `lookOf` mit Geometrie *gemischt*, sodass 1-Personen-Galerien unter dem Floor blieben.

- **Print ist der Score.** Geo vetoiert oder gibt bis +4, zieht aber nie unter den Print.
- **Floors lokal** (kein Static-Global mehr zwischen Labor und Live). Solo-Zuschlag +2.
- **Galerie-Centroid** (L2-Mittel der Embeddings) statt nur Score-Hälfte.
- **Live-Print EMA** über die UUID, Qualitätssieb beim Anlegen, Labor **TAR@0,1 % / 1 % FAR**.

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
