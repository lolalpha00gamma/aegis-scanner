# Aegis Testmodus

Misst, wie gut der Face-Print und die Identifikation auf **öffentlichen** Sätzen laufen. Die Bilder liegen nicht im Git (Lizenz der Originalfotografen).

## Datensatz

| Satz | Wofür | Größe | Quelle |
|------|--------|-------|--------|
| **LFW View 2** | Verifikation 6000 Paare (3000 gleich, 3000 fremd, 10 Folds) | 13 233 Bilder, 5 749 Personen, ~173 MB | [UMass LFW](http://vis-www.cs.umass.edu/lfw/), Spiegel [figshare/sklearn](https://ndownloader.figshare.com/files/5976018) |
| **Smoke** | Identifikation 12 Personen × 6 Fotos | ~2 MB, aus LFW | `smoke-people.txt` — die 12 LFW-Personen mit den meisten Bildern |
| Eigener Ordner | Jede Person = Unterordner mit ≥2 Fotos | beliebig | du |

`pairs.txt` im Ordner ist das offizielle LFW-Protokoll (Huang et al., 2007). Hugging Face hat Kopien (`marcelohaps/lfw`), IJB-B/C und CFP-FP sind größer und für später — erst LFW, sonst ist die Zahl nicht vergleichbar.

Literatur zum Einordnen (ArcFace-Klasse, nicht Aegis): LFW oft > 99 %. CFP-FP und IJB-C sind härter. Apple-Face-Print liegt darunter; der Laborbericht sagt um wie viel.

## Einmal holen

```bash
chmod +x bench/fetch.sh
./bench/fetch.sh
```

schreibt nach `~/AegisBench/`:

- `lfw/` — ganzer Satz
- `smoke/` — 12 Personen, 6 Fotos
- `pairs.txt` — 6000 Paare

Ohne Netz: `lfw.tgz` selbst nach `~/AegisBench/lfw.tgz` legen und das Skript nochmal starten.

## In der App

1. **Testmodus** in der Toolbar
2. `~/AegisBench/smoke` wählen → Identifikation (Leave-one-out) + alle LFW-Paare, deren beide Bilder im Ordner liegen
3. `~/AegisBench/lfw` wählen → volle 6000-Paar-Verifikation (dauert, Status zählt hoch)

Die eigene Galerie wird nicht überschrieben. Der Bericht landet als Textdatei (TAR@FAR, EER, Histogramme, Cosines).

Was die Zahlen heißen:

- **Genuine cosine / Impostor cosine** — daraus `printSigmoidMid` und `printSigmoidSlope` setzen, nicht aus dem Bauch
- **TAR @ 1 % FAR** — wie viele Echte noch durchkommen, wenn 1 % Fremde durchrutschen
- **EER** — Punkt wo Falsch-Zurückweisung = Falsch-Akzeptanz
- **Identifikation Rang-1** — Probe gegen Galerie der anderen Fotos derselben Person plus Impostoren

## Ohne App, nur Protokoll

```bash
# Paare zählen (ohne Bilder)
python3 - <<'PY'
from pathlib import Path
text = Path("bench/pairs.txt").read_text()
print(len(text.splitlines())-1, "Zeilen nach Header")
PY
```
