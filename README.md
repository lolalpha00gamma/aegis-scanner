# Aegis **1.0.5 alpha**

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden:
- [Aegis.dmg (Code)](https://github.com/lolalpha00gamma/aegis-scanner/raw/main/Aegis.dmg)
- [Release 1.0.5 alpha](https://github.com/lolalpha00gamma/aegis-scanner/releases/tag/v1.0.5-alpha)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert.

## Neu in 1.0.5 alpha

- Vergleich gegen das **nächste eingeschriebene Foto**, nicht gegen einen verschmierten Mittelwert — Lookalikes bleiben getrennt
- Drei neue Klassifizierer: **Augenregion**, **Mittelgesicht**, **Kieferlinie**
- Enge Rennen bleiben offen und werden erklärt (z. B. „Elena 78 % und Lena 74 % zu nah“)
- Geometrie entscheidet, wenn FaceNet zwei Personen fast gleich bewertet
- Video-Tracks folgen dem Gesicht, nicht nur der Box — Kreuzer tauschen nicht mehr die Identität

## Strategien

| Strategie | Signal |
|---|---|
| **Fotos-Stil** | Einzelnes Best-Frame, harte Qualitätsgrenze |
| **Vision Box** | Nächstes Feature-Print-Exemplar |
| **Landmark-Geometrie** | Landmark-Form, Procrustes-normalisiert |
| **Gesichtsmaße** | Nase zu Augen, Augenbreite, Mund, Philtrum |
| **Gesichtsform** | Kiefer, Wangen, Aspekt, Kinn |
| **Augenregion** | Augenbreite, Lidöffnung, Brauen |
| **Mittelgesicht** | Nase, Philtrum, Mund |
| **Kieferlinie** | Kieferbreite, Wangen, Kinn |
| **Quality-Gate** | Nächstes Exemplar × Capture-Qualität |
| **Temporal** | Nächstes Video-Exemplar, Tracks ohne Kreuzer-Tausch |
| **Feature Print** | `VNGenerateImageFeaturePrintRequest` |
| **Aegis Ensemble** | Fusion. Enge Rennen bleiben offen und werden erklärt |

## Lizenz

MIT
