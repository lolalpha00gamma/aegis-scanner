#!/usr/bin/env bash
# LFW nach ~/AegisBench und drei Identifikationssätze:
#   smoke    12 Personen × 6 Fotos     — schnell
#   ident20  alle mit ≥20 Bildern ×20  — sklearn-Split (~62 Personen)
#   ident10  alle mit ≥10 Bildern ×20  — große Reihe (~158 Personen)
# Bilder nicht ins Git — nur pairs.txt liegt im Repo.
set -euo pipefail

DEST="${AEGIS_BENCH:-$HOME/AegisBench}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DEST"
cp -f "$SCRIPT_DIR/pairs.txt" "$DEST/pairs.txt"
cp -f "$SCRIPT_DIR/smoke-people.txt" "$DEST/smoke-people.txt"

TGZ="$DEST/lfw.tgz"
LFW="$DEST/lfw"

download() {
  local url="$1"
  echo "Lade $url"
  if command -v curl >/dev/null; then
    curl -L --fail --retry 3 -o "$TGZ" "$url"
  else
    wget -O "$TGZ" "$url"
  fi
}

if [[ ! -d "$LFW/George_W_Bush" ]]; then
  if [[ ! -f "$TGZ" ]]; then
    set +e
    download "https://ndownloader.figshare.com/files/5976018"
    if [[ $? -ne 0 ]]; then
      download "http://vis-www.cs.umass.edu/lfw/lfw.tgz"
    fi
    set -e
    if [[ ! -f "$TGZ" ]]; then
      echo "Download fehlgeschlagen. LFW selbst nach $TGZ legen:" >&2
      echo "  http://vis-www.cs.umass.edu/lfw/lfw.tgz" >&2
      echo "  https://ndownloader.figshare.com/files/5976018" >&2
      exit 1
    fi
  fi
  echo "Entpacke nach $DEST"
  tar -xzf "$TGZ" -C "$DEST"
  if [[ -d "$DEST/lfw" ]]; then
    LFW="$DEST/lfw"
  elif [[ -d "$DEST/lfw_funneled" ]]; then
    mv "$DEST/lfw_funneled" "$DEST/lfw"
    LFW="$DEST/lfw"
  fi
fi

jpg_count() {
  find "$1" -maxdepth 1 -iname '*.jpg' 2>/dev/null | wc -l | tr -d ' '
}

slice() {
  local dest="$1"
  local min="$2"
  local maxphotos="$3"
  local list="$4"
  rm -rf "$dest"
  mkdir -p "$dest"
  local n=0
  local photos=0
  if [[ -n "$list" && -f "$list" ]]; then
    while IFS= read -r person || [[ -n "$person" ]]; do
      [[ -z "$person" || "$person" == \#* ]] && continue
      local src="$LFW/$person"
      [[ -d "$src" ]] || continue
      mkdir -p "$dest/$person"
      find "$src" -maxdepth 1 -iname '*.jpg' | sort | head -n "$maxphotos" | while read -r f; do
        cp -n "$f" "$dest/$person/"
      done
      local c
      c=$(jpg_count "$dest/$person")
      n=$((n + 1))
      photos=$((photos + c))
      echo "  $person  $c"
    done < "$list"
  else
    for src in "$LFW"/*/; do
      [[ -d "$src" ]] || continue
      local person
      person="$(basename "$src")"
      local have
      have=$(jpg_count "$src")
      if [[ "$have" -ge "$min" ]]; then
        mkdir -p "$dest/$person"
        find "$src" -maxdepth 1 -iname '*.jpg' | sort | head -n "$maxphotos" | while read -r f; do
          cp -n "$f" "$dest/$person/"
        done
        local c
        c=$(jpg_count "$dest/$person")
        n=$((n + 1))
        photos=$((photos + c))
      fi
    done
    echo "  $n Personen, $photos Fotos  (min $min, max $maxphotos/Person)"
  fi
  cp -f "$DEST/pairs.txt" "$dest/pairs.txt"
}

echo "— smoke (12 × 6)"
slice "$DEST/smoke" 6 6 "$SCRIPT_DIR/smoke-people.txt"

echo "— ident20 (≥20 Bilder, bis 20 Fotos)  sklearn-Split"
slice "$DEST/ident20" 20 20 ""

echo "— ident10 (≥10 Bilder, bis 20 Fotos)  große Reihe"
slice "$DEST/ident10" 10 20 ""

{
  echo "AegisBench $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "lfw      $(find "$LFW" -iname '*.jpg' | wc -l | tr -d ' ') Bilder, $(find "$LFW" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') Personen"
  echo "smoke    $(find "$DEST/smoke" -iname '*.jpg' | wc -l | tr -d ' ') Bilder, $(find "$DEST/smoke" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') Personen"
  echo "ident20  $(find "$DEST/ident20" -iname '*.jpg' | wc -l | tr -d ' ') Bilder, $(find "$DEST/ident20" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') Personen"
  echo "ident10  $(find "$DEST/ident10" -iname '*.jpg' | wc -l | tr -d ' ') Bilder, $(find "$DEST/ident10" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') Personen"
} | tee "$DEST/MANIFEST.txt"

echo
echo "In Aegis → Testmodus:"
echo "  $DEST/smoke     schnell"
echo "  $DEST/ident20   ~62 Personen  (empfohlen zum Kalibrieren)"
echo "  $DEST/ident10   ~158 Personen (große Reihe, dauert)"
echo "  $DEST/lfw       6000-Paar-Verifikation + Identifikation min-10"
