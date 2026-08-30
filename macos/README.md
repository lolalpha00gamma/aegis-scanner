# Aegis

Lokaler Image- & Video-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**  
Version **1.0.17 alpha**.

## Image-Datei

[**Aegis.dmg herunterladen**](https://github.com/lolalpha00gamma/aegis-scanner/releases/latest/download/Aegis.dmg)

1. Image öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Die Datei ist ad-hoc signiert (kein Apple-Developer-Account) — deshalb der Rechtsklick beim ersten Start.

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
| **Aegis Ensemble** | Beweis-Identifikation. Dieselbe Person landet bei 95–99 % |

## Lizenz

MIT
