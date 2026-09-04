# Aegis

Lokaler Image- & Video-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**  
Version **2.1.75 alpha**.

## Image-Datei

[**Aegis.dmg herunterladen**](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)

1. Image öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Die Datei ist ad-hoc signiert (kein Apple-Developer-Account) — deshalb der Rechtsklick beim ersten Start.

## Neu in 2.1.75 alpha

WEG auf Live-Kiste, Live-Yaw, UNBEKANNT hält Streak, Taufe hält Streak, TWIN? 0,90.

## Neu in 2.1.74 alpha

Testdaten holen in der App (LFW nach Downloads/AegisBench). Keine Fotos im Git.

## Neu in 2.1.55 alpha

Print-Crop-Fallback unabhängig von EXIF. Testmodus-Knopf in der Identitäten-Leiste.

## Neu in 2.1.53 alpha

Testmodus ident10/ident20 — bis 200 Personen × 20 Fotos.

## Neu in 2.1.52 alpha

Testmodus: LFW-Paare + Leave-one-out. `bench/fetch.sh` lädt den Satz nach `~/AegisBench`.

## Neu in 2.1.51 alpha

Dropout IoU tot auch ohne Print, Ghost-Print braucht Baptize 0,80, leftoverAssign Twin-Spread, Enrollment-Burst auf `+`. VERSION = Models = MARKETING 2.1.51 (Build 78).

## Neu in 2.1.50 alpha

leftover Spread/Twin-Veto, Wipe-Mute 800 ms, Slot-Sticky, Mund-Skip, Reconnect-Print aus Ghost. VERSION = Models = MARKETING 2.1.50 (Build 77).

## Neu in 2.1.49 alpha

leftover 1,2 s Walk, Pale-Print raus aus dem Centroid, Kopf-Zahl-Blitz, Centroid-Cache-Key. VERSION = Models = MARKETING 2.1.49 (Build 76).

## Neu in 2.1.48 alpha

leftover erst nach gleicher Box ~380 ms, Slot leer → Frontal, Vote skippt Maske/Blick/Lid. VERSION = Models = MARKETING 2.1.48 (Build 75).

## Neu in 2.1.47 alpha

dt pro Track, Freeze-Achse, Spark aus Centroid, leftover 3+ 2-opt, SHA-Verify, Swap-Blitz, Motion-Blur nach Deskew. VERSION = Models = MARKETING 2.1.47 (Build 74).

## Neu in 2.1.43 alpha

Yaw-Freeze, Schärfe vor Vote, Lock-HUD `hält`, Box-Swap, Name auf jeder getauften Kiste. VERSION = Models = MARKETING 2.1.43 (Build 70).

## Neu in 2.1.35 alpha

Familien-Taufe 5 Ticks bei close Pair. Hist-Cap need+3. Leftover-Hold `gehalten 0.64`. Rename nur gleiche UUID. VERSION = Models = MARKETING 2.1.35 (Build 62).

## Neu in 2.1.33 alpha

Taufe 2 agreeing Ticks. Rename-Confirm 8 s. `.bak` fsync. 1-Euro aus Box-Fläche. Overlay Slot + Uneinig-Namen.

## Neu in 2.1.32 alpha

1-Euro dt aus PTS. `+` leert den Live-Trail. Slot-Count in der Namensliste.

## Neu in 2.1.31 alpha

Leftover Slot-hart (kein Fallback auf anderen Pose-Slot). Live-Name nur bei Look=Print. Print-Trail gleicher Slot. boxPinTakePrint nur enrolled. Rename-Confirm. gallery.json fsync.

## Neu in 2.1.30 alpha

Leftover gleicher Pose-Slot. Print-Pin gegen IoU-Hold im selben Pass. Overlay P/L. Namen umbenennen.

## Neu in 2.1.29 alpha

lookOf mit Pose-Gewicht. Overlay „Print gekappt“. Centroid-Cache. Print-Hit bleibt Sigmoid.

## Neu in 2.1.28 alpha

`matchLive` nutzt lookOf (nur gemessenes Print-Paar). Geo-Veto skip ab 80 %. Leftover 0,64 plus Schärfe-Ranking. Unscharfe Prints nicht in den Trail.

## Neu in 2.1.27 alpha

Leftover-Print 0,72 (Genuine 0,75 pinnt). lookOf ≥ 80 nie auf 60. Hold-Still + Schärfe. Slot-Centroid ohne All-Mean.

## Neu in 2.1.26 alpha

Print-Pin gewinnt gegen Hysterese-Box. TER default aus. Restore-Dialog. Ampel Continuity-Floor, Geo-Spark, Track gehalten.

## Neu in 2.1.24 alpha

Leftover am named Live-Track (nicht Galerie-UUID). Leftover ohne Print tot. Geo je Pose-Slot; ¾ + Print ≥ 80 kein Veto. gallery.json Schema 2.

## Neu in 2.1.23 alpha

Live-Geo ist echt (Median der Identitäts-Maße, nicht Print-Prozent). Leftover nur namenlose Boxen. IoU setzt keine UUID bei Print-Cosine unter 0,80. Overlay erste Klausel.

## Neu in 2.1.21 alpha

Starker Face-Print wird nicht mehr von toter Landmark-Geo auf 60 % gedeckelt. Geo-Veto skippt ab 88 %. Live 5-Tick-Mehrheit mit Score der gewählten ID. Leftover-IoU 0,28. Overlay zeigt den decide-Grund.

## Neu in 2.1.20 alpha

Live-Match nur Centroids. Median der letzten 5 Prints. Yaw aus Landmarks wenn Vision 0. Crop-Print `.up`. Coverage blockt 3. Slot ohne Frontal/¾. boxEuro-Reset bei uniqueID. Leftover-IoU benannt. Anlegen-Confirm 0,82. Labor Centroid-Matrix.

## Neu in 2.1.19 alpha

3-Tick-Namensmehrheit + Score-EMA. `.aegis` print-led (lookOf). Geo-Veto weich. Cheap-Graph Live. Backup-Taste. Burst-Prune beim +.

## Neu in 2.1.18 alpha

Geister-Kisten weg wenn die Cam niemanden sieht. Pin-Print 0,80. Leftover-IoU 0,18. Front-Wide zuerst. Labor Continuity-Floor für Refs. Burst-Kopien in der Statuszeile.

## Neu in 2.1.17 alpha

Live-`+` speichert eine Kopie, nicht die Track-UUID. Pose-Coverage warnt, blockt nicht.

## Neu in 2.1.16 alpha

OneEuro-Init öffentlich. familyBump nur für das Vergleichspaar, Zwillinge ≥ 0,80 inklusive.

## Neu in 2.1.15 alpha

Live-`rematchLive`, Continuity-Blend 0,20, Box-Hysterese, Ingest-Duplikat 0,95, Labor ohne Unschärfe-Paare plus Histogramm, `gallery.json.bak`, `enrolledAt`, Spark-Reset nach Reconnect. TAR bleibt floor−1. MARKETING_VERSION 2.1.15.

## Neu in 2.1.13 alpha

`qualityRejects` teilt den Continuity-Floor (0,08) mit `skipPrint`. Live coalesct den letzten Frame. U-Slot-Vorschlag nach 1,2 s Maske. Labor trennt Impostor frei/Teil-Print und schreibt Orient Auto vs Override.

## Neu in 2.1.12 alpha

2.1.7–2.1.11 von `bugfix` auf `main`. Ampel-Spark 8 Frames, Tile-Budget 2, Continuity-Schärfe 0,08, Orient vor Live, Labor Teil-Print getrennt.

## Neu in 2.1.11 alpha

Per-Kamera Orient-Override, expliziter U-Slot, Live-Ampel C/S/Y, Schärfe-Gate vor dem Print.

## Neu in 2.1.10 alpha

Teil-Print gegen Teil-Centroid, Maske als erste Referenz veto, Portrait-Tiles aus, Schärfe-Floor 0,12, Coverage U.

## Neu in 2.1.7 alpha

0,4 %-Print fällt nicht mehr auf Geometrie. Crop mit Orientierung. Coverage-Slot blockt. Live-Reconnect über Print. Familien-Floor. Hard-Negativ-Taste.

## Neu in 2.1.6 alpha

Gewichteter Galerie-Centroid, Walk-Cancel pro Datei, HLS-FPS 2/8, Pose-Coverage F/¾/P, Print-Drift am Overlay, Enrollment-Vorschau vor Commit.

## Neu in 2.1.4 alpha

Live-Frames kommen mit der Capture-Orientierung bei Vision an. Video-Keyframes sind yaw-divers. Overlay nennt Okklusion/Profil, der Slider den effektiven Floor, NMS-Twins sind optional sichtbar.

## Neu in 2.1.1 alpha

Leerer Face-Print tauft niemanden, solange KI an ist. Print-IoU 0,32. Live-IDs bleiben kleben. NMS merge Tile-Zwillinge. Ingest 1280 px.

## Neu in 2.1.0 alpha

Jede Spur ist abschaltbar. Fusion nutzt nur die aktiven. 3D ist Pose-Anhebung, nicht 3DMM. Laborbericht über Leave-one-out. Nicht gemessen ≠ 0 %.

## Neu in 2.0.8 alpha

Face-Print führt, Geometrie stützt und vetoiert. Profil/Brille mit 99 % Print kommt durch; fremde Verhältnisse plus 4 % Print nicht. `galleryZ` bei zwei Identitäten verlangt nicht mehr still 9 Punkte. Yaw/Pitch dämpfen die Maße.

## Neu in 2.0.7 alpha

Zuordnung nur über reproduzierbare Faktoren: IOD-Verhältnisse, Procrustes-Form, Graph. Unabhängig von Blickwinkel, Größe, Ausschnitt und Kleidung. Pixelraster und Face-Print stimmen nicht mehr ab — Khaki-Jacke vs. Warnweste darf denselben Menschen nicht mehr auf 4 % ziehen.

## Neu in 2.0.5 alpha

Galerie bleibt gespeichert (IdentityDesk kompiliert und verdrahtet). Scan läuft nicht mehr auf dem Main-Thread. Referenzen zeigen gemessene Werte, nicht 96 %. Der Schwellwert-Slider ändert die Zuordnung. Face-Print-Ausfall wird in der Statuszeile gesagt. NMS wirft Nachbarn auf Gruppenfotos nicht mehr weg.

## Neu in 2.0.4 alpha

Face-Print kommt vom **ganzen Foto**, nicht von einem verzerrten 256-px-Ausschnitt. Der stille Fallback auf den Bild-Print (Jacke, Hintergrund) ist raus — der hat dieselbe Person bei 4 % und einen Fremden bei 84 % geliefert. Mehrere Referenzen sind echte Gesichts-Prints, nicht Kleidung.

## Neu in 2.0.3 alpha

Zuordnung hängt an **Aussehen** (Gesichtsmaße, Form, Augen, Kiefer), nicht am Face-Print. Der Print darf 97 % Form nicht mehr auf 8 % drücken. Raster ohne Equalize. Fremde bleiben unbenannt, wenn die Teile nicht passen.

## Neu in 2.0.2 alpha

Version heißt 2.0.2, nicht 1.0.18. Eingeschriebene Gesichter bleiben gespeichert.

## Neu in 1.0.18 alpha

Name im Feld → immer neue Person, auch wenn du **+** triffst. Zwei Gesichter nebeneinander auf einem Gruppenfoto werden nicht mehr zusammengeworfen. Ein Treffer ohne Referenz heißt „Nähe“, nicht der Name.

## Neu in 1.0.17 alpha

Anlegen erzeugt eine neue Person. Zwei Porträts auf verschiedenen Fotos werden nicht mehr zusammengeworfen, nur weil die Boxen ähnlich liegen. Sitzt die Auswahl noch auf Person 2, nimmt Anlegen das unbenannte Gesicht auf dem sichtbaren Foto. Return legt an. `+` hängt nur extra Referenzen an dieselbe Person.

## Neu in 1.0.16 alpha

Ordner blättern: Pfeile links/rechts auf dem Bild, Tastatur `←` `→`, Zähler in der Titelleiste. Filmstrip scrollt zum aktuellen Foto.

## Neu in 1.0.15 alpha

Echte Gesichtserkennung statt Bildähnlichkeit. Aegis nutzt `VNGenerateFacePrintRequest` (dieselbe Klasse von Modell wie Fotos), Cosinus auf dem Rohvektor, und eine Kurve, auf der dieselbe Person 95–99 % landet. Histogram-Equalize vor dem Print ist raus — das hat Identität zerstört. Brille und Licht dürfen das Aussehen-Veto nicht mehr killen.

## Neu in 1.0.14 alpha

Erkennung bei schlechtem Licht: Dunkelheit ist keine Unschärfe. Das Gesicht wird vor der Detektion helligkeitsausgeglichen. Verhältnisse zählen im Dunkeln stärker in der Prozentzahl. Winzige Crowd-Gesichter bleiben unbekannt.

## Neu in 1.0.13 alpha

Gesichtsform aus **reproduzierbaren Verhältnissen** (Augenabstand = 1), nicht aus Lage im Bild, Boxgröße oder Punktzählung. Feature Print ist das Identitäts-Embedding; das Helligkeitsraster darf nur widersprechen. Mimik (Mundöffnung, Lidschlag) zählt nicht als Identität.

## Neu in 1.0.12 alpha

Anatomie-Overlay sitzt auf Augen, Nase und Mund. Vision-Punkte liegen in der Face-Box, nicht im ganzen Bild — der Fehler, der Augen auf die Stirn gelegt hat.

## Neu in 1.0.11 alpha

Sichtbare Anatomie mit Nasenbreite, Mundbreite, Ohren und Haaransatz. Gestrichelte Referenz auf dem zweiten Foto. Ein leerer FaceNet-Vektor ist kein 0 %-Match mehr, sondern „nicht gemessen“.

## Neu in 1.0.10 alpha

Anatomie-Overlay: Augen, Brauen, Nase, Mundwinkel, Mundmitte, Kinn, Kontur, Haaransatz und Ohren direkt auf dem Foto. Abweichung zur Referenz wird sichtbar, wenn das zweite Frontalbild 0 % zeigt.

## Neu in 1.0.9 alpha

Graph-Biomarker (jetzt nativ), 3D-Geometrie, TER-Fusion (diagnostisch). Keine demografische Klassifikation.

## Was die App macht

Ordner mit Fotos und Videos wählen, oder einen Live-Stream (Webcam, RTSP, HLS, MJPEG, Snapshot) einspeisen. Aegis zieht Frames, erkennt Gesichter und zeigt Übereinstimmung in Prozent für mehrere Strategien — offline auf dem Gerät.

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Best-Frame Face-Print, harte Qualitätsgrenze (Baseline) |
| **Vision Box** | Nächstes Face-Print-Exemplar, Vision Rev. 3 |
| **Landmark-Geometrie** | Anatomische Punkte, Augen-Procrustes IOD=1 (diagnostisch) |
| **Gesichtsmaße** | Verhältnisse zur Augenabstands-Einheit, unabhängig von Lage/Größe/Mimik |
| **Gesichtsform** | Kiefer/Höhe, Wangen/Höhe, Kiefer/Wangen — keine Box |
| **Augenregion** | Lidspalten und Augenwinkel / IOD, nicht Lidöffnung |
| **Mittelgesicht** | Nasenlänge, Nasenbreite, Nasenindex, Philtrum/Nase |
| **Kieferlinie** | Kieferbreite/IOD, Untergesicht/Höhe, Kinn |
| **Graph-Biomarker** | KNN-6 über feste Knochenpunkte, ohne Mund |
| **3D-Geometrie** | IOD-Verhältnisse, Kieferwinkel, Nasenfläche |
| **Aussehen** | Helligkeitsraster; darf nur vetoen, und nur bei klarem Widerspruch |
| **Quality-Gate** | Face-Print, Dunkelheit zählt nicht als Unschärfe |
| **Temporal** | Video-Face-Print über Tracks, ohne Kreuzer-Tausch |
| **Feature Print** | `VNGenerateFacePrintRequest` auf augenausgerichtetem Crop — das macOS-Identitäts-Embedding |
| **TER-Fusion** | Scores → Total Error Rate, min-max nach Jain |
| **Aegis Ensemble** | Print führt (0.75), Geometrie stützt (0.25) und vetoiert unter 35 %. |

## Lizenz

MIT
