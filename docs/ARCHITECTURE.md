# Aegis 2.1.10 alpha — Architektur

2.0.8 hat `lookOf` umgedreht. 2.1.0 macht jede Spur abschaltbar und ergänzt Pose-3D, LBP, Mahalanobis, Laborbericht. **2.1.1** schließt die Zuordnung ohne Print, Live-Geister und Tile-NMS. **2.1.2** macht den Print ehrlich (Sigmoid, kein max, Geo-Veto, Galerie-Floor) und das Live-Overlay lesbar. **2.1.3** lässt den Print den Score führen (kein 0,25-Mix mehr), hält Floors lokal, mittelt den Galerie-Vektor und blendet Live-Prints. **2.1.4** richtet Live-Frames an `videoRotationAngle` aus, wählt Video-Keyframes nach Yaw, zeigt Floor/NMS/Okklusion und schreibt Konfusion + EXIF ins Labor. **2.1.5** dreht HLS per `preferredTransform`, vetoet Enrollment-Yaw, bricht Scans ab. **2.1.6** gewichtet den Centroid nach Schärfe, cancel't den Ordner-Walk pro Datei, passt HLS-FPS an, zeigt Pose-Coverage und Print-Drift. **2.1.7** lookOf ehrlich, Crop-Orientierung, Coverage-Block, Live-Reconnect. **2.1.8** TAR ceil-1, Live-Box 1-Euro, Scan-Resume, Print-Revision. **2.1.9** Teil-Print bei Maske, 1-Euro-Reset nach Reconnect, TAR-Bootstrap-CI, Detect-Resume. **2.1.10** Teil-Print gegen Teil-Centroid, Masken-Enrollment-Veto, Portrait-Tiles aus, Schärfe-Floor 0,12, Coverage-Slot U.

## Spuren

Vier Gruppen, jede Erkennung mit Schalter. **Aus = Gewicht 0 in der Fusion.**

| Gruppe | Spuren |
|---|---|
| KI / Face-Print | Fotos-Stil, Vision Box, Quality-Gate, Temporal, Feature Print |
| 2D-Geometrie | Landmark, Maße, Form, Augen, Mittelgesicht, Kiefer, Graph, Aussehen (LBP, keine Stimme) |
| 3D | Pose-Anhebung der 2D-Landmarks (Yaw/Pitch). Kein 3DMM. |
| Fusion | TER, Aegis Ensemble |

Aegis aus → keine Namensvergabe. `nicht gemessen` ≠ `0 %`.
KI an + leerer Print → Score gedeckelt auf 49, `decide` weist ab. KI aus → Geometrie darf zuordnen.
`decide` vetoiert wenn die Maße der Print-Gewinnerin widersprechen (geoMix < 42, percent < 94).
Galerie-Floor: 1→84, 2–3→80, ≥4→78, plus Slider-Bias um 78.

## Fusion

Nur eingeschaltete Spuren. `lookOf`: Print führt, Geometrie stützt, unter 35 % Geometrie Deckel 60. Geometrie aus → nur Print. Print aus → nur Geometrie. Pose dämpft das Maß-Gewicht.

Maße: Mahalanobis sobald ≥3 Referenzvektoren, sonst MRE-Sigmoid.

## Labor

Leave-one-out auf der Galerie (mind. 2 Fotos/Person). Genuine/Impostor, EER-Schätzung, TAR bei Schwelle. n_impostor < 200 → Bootstrap-95 %-CI statt einer nackten Schwelle.

## Nicht im Bundle

Kein ArcFace-Core-ML (Lizenz/Größe). Apple Face-Print bleibt die KI-Spur. Kein 3DDFA. Drop-in `.mlmodel` wäre der nächste Schritt in `FaceEmbedder`.
