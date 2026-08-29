# Aegis **1.0.8 alpha**

**Die Image-Datei liegt im Repo:** [`Aegis.dmg`](./Aegis.dmg)

Direkt laden:
- [Aegis.dmg (Code)](https://github.com/lolalpha00gamma/aegis-scanner/raw/main/Aegis.dmg)
- [Release 1.0.8 alpha](https://github.com/lolalpha00gamma/aegis-scanner/releases/tag/v1.0.8-alpha)

Lokaler Image-, Video- und Live-Stream-Scanner für macOS. **Kein Xcode, kein Python, kein Browser.**

## Installieren

1. [`Aegis.dmg`](./Aegis.dmg) öffnen
2. **Aegis** in den Ordner Programme ziehen
3. Beim ersten Start: Rechtsklick auf Aegis → **Öffnen**

macOS 14 Sonoma oder neuer. Ad-hoc signiert.

## Neu in 1.0.8 alpha

Aus NIST FRVT, InsightFace und MagFace:

- Ein Treffer muss ein **Ausreißer gegen die ganze Galerie** sein (Z-Norm). Wenn alle angelegten Personen ähnlich nah sind, bleibt das Gesicht offen.
- Aussehen wird über die **Augen ausgerichtet** (5-Punkt / Similarity-Transform), nicht über die lose Box.
- Unbekannt bleibt der Normalzustand.

## Lizenz

MIT
