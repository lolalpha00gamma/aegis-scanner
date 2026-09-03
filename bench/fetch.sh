#!/usr/bin/env bash
# LFW nach ~/AegisBench laden und eine 12-Personen-Rauchwolke bauen.
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

SMOKE="$DEST/smoke"
rm -rf "$SMOKE"
mkdir -p "$SMOKE"
while IFS= read -r person || [[ -n "$person" ]]; do
  [[ -z "$person" || "$person" == \#* ]] && continue
  src="$LFW/$person"
  if [[ ! -d "$src" ]]; then
    echo "fehlt: $person"
    continue
  fi
  mkdir -p "$SMOKE/$person"
  # erste 6 JPEGs — genug für Leave-one-out, klein genug für einen Lauf
  find "$src" -maxdepth 1 -iname '*.jpg' | sort | head -n 6 | while read -r f; do
    cp -n "$f" "$SMOKE/$person/"
  done
  echo "smoke  $person  $(find "$SMOKE/$person" -iname '*.jpg' | wc -l | tr -d ' ') Fotos"
done < "$SCRIPT_DIR/smoke-people.txt"

echo
echo "Fertig."
echo "  Voll  $LFW"
echo "  Smoke $SMOKE"
echo "  Paare $DEST/pairs.txt"
echo
echo "In Aegis: Testmodus → $SMOKE  (schnell) oder $LFW (6000 LFW-Paare, dauert)."
