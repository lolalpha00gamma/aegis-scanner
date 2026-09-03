# Aegis Testmodus

Misst, wie gut der Face-Print und die Identifikation auf **öffentlichen** Sätzen laufen. Die Bilder liegen nicht im Git (Lizenz der Originalfotografen).

## Datensatz

| Satz | Wofür | Größe | Quelle |
|------|--------|-------|--------|
| **LFW View 2** | Verifikation 6000 Paare (3000 gleich, 3000 fremd, 10 Folds) | 13 233 Bilder, 5 749 Personen, ~173 MB | [UMass LFW](http://vis-www.cs.umass.edu/lfw/), Spiegel [figshare/sklearn](https://ndownloader.figshare.com/files/5976018) |
| **Smoke** | schnell | 12 × 6 | `smoke-people.txt` |
| **ident20** | sklearn-Split, kalibrieren | ~62 Personen × 20 Fotos | alle LFW mit ≥20 Bildern |
| **ident10** | große Reihe | ~158 × 20 | alle LFW mit ≥10 Bildern |
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
- `smoke/` — 12 Personen × 6 Fotos (schnell)
- `ident20/` — alle LFW-Personen mit ≥20 Bildern, bis 20 Fotos (~62, sklearn-Split)
- `ident10/` — alle mit ≥10 Bildern, bis 20 Fotos (~158, große Reihe)
- `pairs.txt` — 6000 Paare

## In der App

1. **Testmodus** in der Toolbar
2. `~/AegisBench/ident20` — Kalibrieren (ca. 1 200 Fotos, Leave-one-out + passende LFW-Paare)
3. `~/AegisBench/ident10` — große Reihe (ca. 3 000 Fotos, dauert)
4. `~/AegisBench/lfw` — volle 6000-Paar-Verifikation; Identifikation filtert auf ≥10 Bilder

Die eigene Galerie wird nicht überschrieben. Cap in der App: 200 Personen × 20 Fotos.

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
