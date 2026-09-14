# Aegis 2.2.0 alpha — Architektur

2.0.8 hat `lookOf` umgedreht. 2.1.0 macht jede Spur abschaltbar und ergänzt Pose-3D, LBP, Mahalanobis, Laborbericht. **2.1.1** schließt die Zuordnung ohne Print, Live-Geister und Tile-NMS. **2.1.2** macht den Print ehrlich (Sigmoid, kein max, Geo-Veto, Galerie-Floor) und das Live-Overlay lesbar. **2.1.3** unterscheidet gemessenen Print von „KI aus“ (`printMeasured`), hält Floors lokal, und räumt Live-Boxen wenn niemand da ist.

## Spuren

Vier Gruppen, jede Erkennung mit Schalter. **Aus = Gewicht 0 in der Fusion.**

| Gruppe | Spuren |
|---|---|
| KI / Embedder | SFace 128-d (5-Punkt 112×112), Face-Print, Vision Box, Quality-Gate, Temporal |
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

Leave-one-out auf der Galerie (mind. 2 Fotos/Person). Genuine/Impostor, EER-Schätzung, TAR bei Schwelle.

## Nicht im Bundle

SFace (Apache-2) ist der 1:N-Embedder, Face-Print die zweite 2D-KI. 2D-Maße und Pose-3D stützen. buffalo_l nur Research. `scripts/convert_sface.py` schreibt `SFace.mlmodel`.
