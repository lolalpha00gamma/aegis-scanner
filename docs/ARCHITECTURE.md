# Aegis 2.1.0 alpha — Architektur

2.0.8 hat `lookOf` umgedreht. 2.1.0 macht jede Spur abschaltbar und ergänzt Pose-3D, LBP, Mahalanobis, Laborbericht.

## Spuren

Vier Gruppen, jede Erkennung mit Schalter. **Aus = Gewicht 0 in der Fusion.**

| Gruppe | Spuren |
|---|---|
| KI / Face-Print | Fotos-Stil, Vision Box, Quality-Gate, Temporal, Feature Print |
| 2D-Geometrie | Landmark, Maße, Form, Augen, Mittelgesicht, Kiefer, Graph, Aussehen (LBP, keine Stimme) |
| 3D | Pose-Anhebung der 2D-Landmarks (Yaw/Pitch). Kein 3DMM. |
| Fusion | TER, Aegis Ensemble |

Aegis aus → keine Namensvergabe. `nicht gemessen` ≠ `0 %`.

## Fusion

Nur eingeschaltete Spuren. `lookOf`: Print führt, Geometrie stützt, unter 35 % Geometrie Deckel 60. Geometrie aus → nur Print. Print aus → nur Geometrie. Pose dämpft das Maß-Gewicht.

Maße: Mahalanobis sobald ≥3 Referenzvektoren, sonst MRE-Sigmoid.

## Labor

Leave-one-out auf der Galerie (mind. 2 Fotos/Person). Genuine/Impostor, EER-Schätzung, TAR bei Schwelle.

## Nicht im Bundle

Kein ArcFace-Core-ML (Lizenz/Größe). Apple Face-Print bleibt die KI-Spur. Kein 3DDFA. Drop-in `.mlmodel` wäre der nächste Schritt in `FaceEmbedder`.
