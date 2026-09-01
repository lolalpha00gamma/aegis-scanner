# Aegis 2.0.8 alpha — Architektur

2.0.7-Bestandsaufnahme war Commit `be78ec68`. 2.0.8 dreht `lookOf` um (Opus-5 Phase 1a).

Produkt: lokaler macOS Image-/Video-/Live-Gesichtsscanner. SwiftUI, Vision, kein Server, kein Python, kein Browser.
Lizenz: MIT. macOS 14+. Ad-hoc signiert. Universal `arm64` + `x86_64`.

---

## Dateikarte

| Datei | Rolle |
|---|---|
| `macos/AegisScanner/FaceEngine.swift` | Detektion, Features, Matching, Zuordnung |
| `macos/AegisScanner/ContentView.swift` | UI: Split-View, Overlay, Anatomie, Slider |
| `macos/AegisScanner/LibraryStore.swift` | App-State, Scan, Galerie, Live, Persistenz |
| `macos/AegisScanner/LiveCapture.swift` | Webcam / RTSP / HLS / MJPEG / Snapshot |
| `macos/AegisScanner/Models.swift` | Datenmodell + 16 Strategien |
| `macos/AegisScanner/FrameExtractor.swift` | Bilder laden, Video-Frames, Schärfe |
| `macos/AegisScanner/IdentityDesk.swift` | `gallery.json`, Probe-Status |
| `macos/AegisScanner/AegisScannerApp.swift` | Fenster, Menü-Shortcuts |
| `.github/workflows/release-dmg.yml` | CI: xcodebuild → `Aegis.dmg` → Release |

Galerie: `~/Library/Application Support/Aegis/gallery.json` — nur eingeschriebene Faces. Alte JSON ohne `yaw`/`pitch` bleibt lesbar.

---

## Datenfluss

```
Ordner / Live
    → LibraryStore.ingest / ingestLiveFrame
    → FaceEngine.detect  (Vision Rev. 3 + Landmarks + Quality + yaw/pitch)
        optional: Luma-Equalize, 5 Tiles bei Crowd, NMS
        stampPrints: VNGenerateFacePrintRequest auf dem ganzen Foto
    → FaceEngine.match(threshold: 70…96, Default 78)
        16 StrategyHits pro Face
        nur .aegis vergibt den Namen (decide)
    → ContentView Overlay + rechte Strategie-Liste
    → Anlegen / + schreibt gallery.json
```

---

## Matching 2.0.8 (`lookOf` + `decide`)

Slider 70…96 setzt `matchFloor` (Default **78**). `soloFloor = matchFloor + 4`.

### Geo-Mix (nur Faktoren, unverändert)

```
0.20 ratios + 0.16 faceShape + 0.14 midface + 0.14 eyeRegion
+ 0.12 landmarkGeo + 0.12 jawline + 0.08 graphBio + 0.04 geom3d
```

### `lookOf(geo, embed, pose)` — Aegis-Score

```
embed < 1                  → geo                    (kein Print: Maße allein)
geo ≥ 1 und geo < 35       → min(embed, 60)         (Maße widersprechen → deckeln)
sonst                      → (1-geoW)*embed + geoW*geo
                             geoW = 0.25 * pose
```

Frontal (`pose=1`): **0.75·Print + 0.25·Geometrie**.
Profil: Print-Anteil steigt, IOD-Maße können ein 99 %-Print nicht mehr unter 78 drücken.
Fremde mit geo=80 und embed=4: lookOf ≈ 23 → kein Name.

`pose` aus Vision yaw/pitch (Radians): `cos(min(hypot(yaw,pitch), π/2))`. Fehlt die Pose: `quality.frontal`.

Raster hat keine Stimme.

### `galleryZScore`

Braucht **mindestens zwei Rivalen** (drei Identitäten). Ein Rivale ist Sache von `margin`. Der alte Nenner `max(σ, 6)` verlangte still 9 Punkte Abstand — genau dann, wenn zwei ähnliche Leute das Embedding gebraucht hätten.

### `decide` — ein Tor

Ablehnung:

- keine Vergleichsperson / `lowCapture`
- Solo: `percent < soloFloor`
- Rivale: `percent < matchFloor`
- `galleryZ < 1.5` und `percent < 92` (nur ab 3 Identitäten)
- sonst zu nah (`margin < 12`, außer 94 %+ mit ≥6 Pkt)

Geometrie-Widerspruch sitzt in `lookOf` (Deckel 60), nicht als zweites Tor.

Eingeschriebene Referenz: Prozente bleiben gemessen (kein Fake-96 %).

### Nachrechnung der drei Fehlermodi (2.0.8, frontal)

| Fall | lookOf | Ergebnis |
|---|---|---|
| Gleiche Person, Profil/Brille · G=64, E=99 | 0.75·99+0.25·64 = **90.3** | zugeordnet (≥78) |
| Ähnlicher Rivale · G=80/E=96 vs G=79/E=12 | 92 vs 28.8, margin 63 | zugeordnet; galleryZ greift bei 2 Personen nicht |
| Fremde · G=80, E=4 | 0.75·4+0.25·80 = **23** | nicht zugeordnet |

---

## Invarianten

1. Raster und Image-Print entscheiden **keine** Identität.
2. Face-Print auf dem ganzen Foto, nie Warp-256 als Identität.
3. Leerer Print = 0 / „nicht gemessen“, nie Fake-96 %.
4. NMS wirft Nachbarn auf Gruppenfotos nicht weg.
5. Anlegen ≠ +. Name im Feld erzeugt immer eine neue Person.
6. Box-Eigentum nur intra-Foto.
7. Slider ändert `matchFloor`.
8. Dunkelheit ist keine Unschärfe.
9. Mimik zählt nicht als Identität.
10. Keine Geschlechts-/Ethnizitätsklassifikation.
11. Offline, lokal, Galerie nur enrolled Faces.
12. Version in App, `VERSION` und pbxproj gleichlautend.
13. **Print führt, Geometrie stützt/vetoiert.** Ein 4 %-Print darf nicht zuordnen.

---

## Nicht in 2.0.8 (spätere Phasen)

- Phase 0: beschriftetes Evaluationsset, EER/TAR
- Phase 1b: ArcFace/AdaFace Core ML
- Phase 2: echte 3D (3DDFA); `geom3d` ist weiter 2D-Verhältnisse
- Phase 3–5: Mahalanobis, LBP/HOG, LLR-Fusion, UI auf 3 Spuren

---

## Tests

Keine Unit-Tests. Nach 2.0.8 manuell: gleiche Person Profil/Brille, zwei ähnliche Leute, Fremde mit ähnlichen Maßen, Slider, Galerie nach Neustart, dritte Person anlegen.
