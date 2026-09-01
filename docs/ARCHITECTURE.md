# Aegis 2.0.7 alpha — Architektur-Bestandsaufnahme

Stand: Commit `be78ec68` (1. Sep 2026), vor den Opus-4.5-Patches.
Zweck: fester Ist-Zustand, damit Änderungen nicht unbemerkt Invarianten brechen.

Produkt: lokaler macOS Image-/Video-/Live-Gesichtsscanner. SwiftUI, Vision, kein Server, kein Python, kein Browser.
Lizenz: MIT. macOS 14+. Ad-hoc signiert. Universal `arm64` + `x86_64`.

---

## Dateikarte

| Datei | Zeilen | Rolle |
|---|---:|---|
| `macos/AegisScanner/FaceEngine.swift` | ~1844 | Detektion, Features, Matching, Zuordnung |
| `macos/AegisScanner/ContentView.swift` | ~652 | UI: Split-View, Overlay, Anatomie, Slider |
| `macos/AegisScanner/LibraryStore.swift` | ~437 | App-State, Scan, Galerie, Live, Persistenz |
| `macos/AegisScanner/LiveCapture.swift` | ~232 | Webcam / RTSP / HLS / MJPEG / Snapshot |
| `macos/AegisScanner/Models.swift` | ~182 | Datenmodell + 16 Strategien |
| `macos/AegisScanner/FrameExtractor.swift` | ~173 | Bilder laden, Video-Frames, Schärfe |
| `macos/AegisScanner/IdentityDesk.swift` | ~83 | `gallery.json`, Probe-Status |
| `macos/AegisScanner/AegisScannerApp.swift` | ~43 | Fenster, Menü-Shortcuts |
| `.github/workflows/release-dmg.yml` | ~94 | CI: xcodebuild → `Aegis.dmg` → Release |

Galerie: `~/Library/Application Support/Aegis/gallery.json`
Nur eingeschriebene Faces werden persistiert.

---

## Datenfluss

```
Ordner / Live
    → LibraryStore.ingest / ingestLiveFrame
    → FaceEngine.detect  (Vision Rev. 3 + Landmarks + Quality)
        optional: Luma-Equalize, 5 Tiles bei Crowd, NMS
        stampPrints: VNGenerateFacePrintRequest auf dem ganzen Foto
    → FaceEngine.match(threshold: 70…96, Default 78)
        16 StrategyHits pro Face
        nur .aegis vergibt den Namen (decide)
    → ContentView Overlay + rechte Strategie-Liste
    → Anlegen / + schreibt gallery.json
```

Scan läuft in `Task.detached`. Ein kaputtes Foto bricht den Ordner nicht ab.
Live: ein Frame gleichzeitig (`liveBusy`), Tiles aus (`tiles: false`).
Bereits eingeschriebene Live-Faces bleiben gepinnt, der Rest wird pro Frame ersetzt.

---

## Detektion (`FaceEngine.detect`)

1. `VNDetectFaceRectanglesRequest` Revision 3, Default-Konfidenz **0.15** (dunkel/leer: **0.12**).
2. Bei Dunkelheit (`mean < 78` oder `p5 < 22`) oder leerem Ergebnis: Histogram-Equalize + zweite Runde, dann NMS.
3. Crowd-Tiles wenn größtes Gesicht `< 22%` der kürzeren Kante oder Coverage `< 14%` bei ≥1000 px: 5 Crops 58% der Bildgröße.
4. Landmarks → Strokes (Augen, Brauen, Nase, Mund, Kontur, Haaransatz, Ohren, Kinn, Nasen-/Mundbreite).
5. Punkte in der Face-Box (nicht Bildraum). Procrustes-Align auf IOD = 1.
6. Appearance: 8×8-Raster nach Augen-Warp 128 px. **Keine Zuordnungsstimme.**
7. Face-Print **nicht** im Detektionsloop. `stampPrints` danach:
   - Request auf dem **ganzen Foto** (kein 256-px-Warp).
   - Match Print ↔ Detektionsbox per IoU ≥ 0.20.
   - Fallback: Crop `pad 0.55` + `identityPrint`. Niemals Image-Print der Jacke.
8. NMS: `duplicateDetection` — IoU ≥ **0.42** oder Nested ≥ **0.70**. Zwei Leute nebeneinander bleiben zwei Detektionen. (`samePerson` mit 0.28 ist nur Track/Overlap, nicht NMS.)

Qualität `capture` = 0.16 Apple + 0.30 Kante + 0.22 Größe + 0.24 Frontal + 0.08 Kantenbonus.
`qualityRejects` / `tinyUnreliable`: `capture < 0.35` **und** `size < 0.16`.

---

## Matching (`FaceEngine.match`)

Slider 70…96 setzt `matchFloor` (Default **78**). `soloFloor = matchFloor + 4` (Default **82**).

Konstanten:

| Name | Wert | Bedeutung |
|---|---|---|
| `matchFloor` | 78 (Slider) | Mindest-% mit Rivale |
| `soloFloor` | +4 | Mindest-% mit nur einer Person in der Galerie |
| `embedMargin` | 12 Pkt | Abstand für Print-Strategien |
| `landmarkMargin` | 14 Pkt | Abstand für Geometrie |
| `zFloor` | 1.5 | Galerie-Ausreißer |

`hint(...)` setzt `identityId = nil` — diagnostische Strategien **nennen niemanden**.
`toHit` für Fotos-Stil / Vision Box / Quality-Gate / Temporal / Feature Print / Aegis darf zuordnen.
**Namensvergabe in der UI hängt am Aegis-Hit**, nicht am Feature-Print.

### Geo-Mix (nur Faktoren)

```
0.20 ratios + 0.16 faceShape + 0.14 midface + 0.14 eyeRegion
+ 0.12 landmarkGeo + 0.12 jawline + 0.08 graphBio + 0.04 geom3d
```

Kein Texture, kein Face-Print in diesem Mix.

### `lookOf(geo, embed)` — tatsächlicher Aegis-Score

```
geo < 1                    → 0
embed ≥ 75 und geo ≥ 50    → 0.78*geo + 0.22*embed   (Print darf nur stützen)
sonst                      → geo                     (4%-Print zieht nicht nach unten)
```

Raster (`texture`) hat **keine** Stimme. `textureReliable` wird in `decide` ignoriert.

### `decide` — wer den Namen bekommt

Ablehnung (kein Name):

- `lowCapture`
- Solo-Galerie und nicht (`score ≥ soloFloor` und `geoMix ≥ 28` und `percent ≥ 70`)
- `percent < 70` oder `score < matchFloor`
- `galleryZ < 1.5` und `percent < 92` (alle ähnlich nah)
- `geoMix < 32` und `percent < 94` (Faktoren widersprechen)
- Geo-Sieger ≠ Look-Sieger, `geoMargin ≥ 10`, `percent < 94`
- sonst zu nah (`margin < 12`, außer 94%+ mit ≥6 Pkt oder Geo trennt ≥12 Pkt)

Eingeschriebene Referenz: Hits werden auf die eigene Person umgelegt, **Prozente bleiben gemessen** (kein Fake-96%).

---

## Anlegen vs. +

| Aktion | Regel |
|---|---|
| **Anlegen** (Return / Button, Name gesetzt) | Immer neue Person. `faceForNewIdentity`: nie schon benannt, nie stilles +. Sitzt die Auswahl auf Person 2, nimm das unbenannte Gesicht auf dem **sichtbaren** Foto. |
| **+** | Extra-Referenz derselben Person. **Nur wenn das Namensfeld leer ist.** Name im Feld → Anlegen. |
| Box-Overlap | Nur auf **demselben Foto**. Zwei Porträts teilen Pixelkoordinaten — das darf Person 3 nicht schlucken. |

Nach Anlegen: nächstes unbenanntes Gesicht auf dem Foto wird selektiert.

---

## UI

`NavigationSplitView`: Identitäten | Bühne | Strategien.

- Overlay: Box + Prozent. Anatomie-Mesh (Strokes), gestrichelte Referenz.
- Slider 70…96 ruft `rematch()` beim Loslassen — wirkt auf Zuordnung, nicht nur Label.
- Match ohne Referenz heißt **Nähe**, nicht der Name.
- Shortcuts: Cmd-O Ordner, Cmd-L Live, Cmd-R Erkennen, Pfeiltasten blättern.

---

## Live

`sniffLiveKind`: webcam / rtsp / hls / mjpeg / snapshot.
ATS: nur Local Networking. Kamera-Entitlement + User-selected files.

---

## Build / Version

Version an **drei** Stellen halten:

1. `VERSION`
2. `AppVersion` in `Models.swift`
3. `MARKETING_VERSION` in `project.pbxproj` (CI liest das für den Tag `vX.Y.Z-alpha`)

Push auf `main` baut das DMG. `[skip ci]` im Commit überspringt den Build.

---

## Invarianten (nicht still ändern)

1. Raster und Image-Print entscheiden **keine** Identität.
2. Face-Print auf dem ganzen Foto, nie Warp-256 als Identität.
3. Leerer Print = 0 / nicht gemessen, nie Fake-96%.
4. NMS wirft Nachbarn auf Gruppenfotos nicht weg.
5. Anlegen ungleich +. Name im Feld erzeugt immer eine neue Person.
6. Box-Eigentum nur intra-Foto.
7. Slider ändert `matchFloor`.
8. Dunkelheit ist keine Unschärfe.
9. Mimik (Mundöffnung, Lidschlag) zählt nicht als Identität.
10. Keine Geschlechts-/Ethnizitätsklassifikation.
11. Offline, lokal, Galerie nur enrolled Faces.
12. Version in App, `VERSION` und pbxproj gleichlautend.

---

## Bekannte Spannungen im Ist-Code

Doku und Code weichen an Stellen ab — vor Patches merken, nicht still korrigieren:

- README sagt Raster und Face-Print haben keine Stimme. Code: Print stützt mit 22%, wenn `embed >= 75` und `geo >= 50`.
- `hint()` macht Geometrie namenlos, `rank()` könnte Print-Strategien zuordnen; die UI zeigt den Aegis-Namen.
- `samePerson` (IoU 0.28) existiert neben `duplicateDetection` (0.42). Nur Letzteres ist NMS.
- `fuseIdentity` existiert noch, Ensemble nutzt `lookOf`.
- `macos/README.md` Feature-Print-Zeile spricht noch von augenausgerichtetem Crop; Code ist Whole-Image-Print.

---

## Tests

Keine Unit-Tests im Repo. Regression bisher manuell: Gruppenfoto, Jacke/Pose-Wechsel, dunkles Foto, dritte Person anlegen, Slider, Galerie nach Neustart.
