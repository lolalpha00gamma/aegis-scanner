# Aegis **1.0.13 alpha**

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
