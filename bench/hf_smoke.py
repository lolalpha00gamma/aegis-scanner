#!/usr/bin/env python3
"""LFW-Smoke von Hugging Face (marcelohaps/lfw). Fotos nie ins Git.

Exit:
  0  Protokoll ok, optional Download ok
  1  Protokoll- oder JPEG-Fehler
  2  Netz (CI darf FacePrint dann skippen)
"""
from __future__ import annotations

import argparse
import csv
import io
import os
import re
import ssl
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

HF_BASE = "https://huggingface.co/datasets/marcelohaps/lfw/resolve/main"
UA = "AegisBench/2.1 (+https://github.com/lolalpha00gamma/aegis-scanner)"
JPEG_MAGIC = b"\xff\xd8\xff"
NAME_RE = re.compile(r"^(.+)_(\d{4})\.jpe?g$", re.I)
CTX = ssl.create_default_context()


class NetError(Exception):
    pass


class Fail(Exception):
    pass


def here() -> Path:
    return Path(__file__).resolve().parent


def split_cols(line: str) -> list[str]:
    return [c for c in re.split(r"[\t ]+", line.strip()) if c]


def parse_pairs_txt(text: str) -> list[tuple]:
    lines = [ln for ln in text.splitlines() if ln.strip() != ""]
    if not lines:
        return []
    head = split_cols(lines[0])
    nums = []
    for h in head:
        try:
            nums.append(int(h))
        except ValueError:
            nums = []
            break
    i = 0
    if len(nums) >= 2:
        folds, per = max(1, nums[0]), max(1, nums[1])
        i = 1
    elif len(nums) == 1:
        folds, per = 1, max(1, nums[0])
        i = 1
    else:
        folds, per = 1, 300
    out = []
    for fold in range(folds):
        for _ in range(per):
            if i >= len(lines):
                return out
            cols = split_cols(lines[i])
            i += 1
            if len(cols) < 3:
                continue
            try:
                n1, n2 = int(cols[1]), int(cols[2])
            except ValueError:
                continue
            out.append((True, cols[0], n1, cols[0], n2, fold))
        for _ in range(per):
            if i >= len(lines):
                return out
            cols = split_cols(lines[i])
            i += 1
            if len(cols) < 4:
                continue
            try:
                n1, n2 = int(cols[1]), int(cols[3])
            except ValueError:
                continue
            out.append((False, cols[0], n1, cols[2], n2, fold))
    return out


def parse_name_index(filename: str) -> tuple[str, int] | None:
    m = NAME_RE.match(filename.strip())
    if not m:
        return None
    return m.group(1), int(m.group(2))


def parse_pairs_csv(text: str) -> list[tuple]:
    rows = csv.DictReader(io.StringIO(text))
    out = []
    for row in rows:
        a = parse_name_index(row.get("image_a", ""))
        b = parse_name_index(row.get("image_b", ""))
        if a is None or b is None:
            continue
        same = str(row.get("is_same", "")).strip() in ("1", "true", "True")
        try:
            fold = int(row.get("fold_id", "1")) - 1
        except ValueError:
            fold = 0
        out.append((same, a[0], a[1], b[0], b[1], fold))
    return out


def fetch(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    last = None
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=timeout, context=CTX) as resp:
                status = getattr(resp, "status", 200)
                if status >= 500 or status == 429:
                    raise NetError("HTTP %s %s" % (status, url))
                if status >= 400:
                    raise Fail("HTTP %s %s" % (status, url))
                return resp.read()
        except urllib.error.HTTPError as e:
            last = e
            if e.code in (429, 500, 502, 503, 504):
                time.sleep(0.4 * (attempt + 1))
                continue
            if e.code in (401, 403, 404):
                raise Fail("HTTP %s %s" % (e.code, url)) from e
            raise NetError("HTTP %s %s" % (e.code, url)) from e
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            last = e
            time.sleep(0.4 * (attempt + 1))
            continue
    raise NetError(str(last) if last else url)


def is_jpeg(data: bytes) -> bool:
    return len(data) >= 128 and data[:3] == JPEG_MAGIC


def smoke_people(path: Path) -> list[str]:
    names = []
    for line in path.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        names.append(s)
    return names


def local_protocol(pairs_path: Path, people_path: Path) -> list[tuple]:
    if not pairs_path.is_file():
        raise Fail("bench/pairs.txt fehlt")
    pairs = parse_pairs_txt(pairs_path.read_text(encoding="utf-8"))
    genuine = sum(1 for p in pairs if p[0])
    impostor = len(pairs) - genuine
    folds = {p[5] for p in pairs}
    if len(pairs) != 6000:
        raise Fail("pairs.txt: %d Paare, erwartet 6000" % len(pairs))
    if genuine != 3000 or impostor != 3000:
        raise Fail("pairs.txt: %d/%d genuine/impostor, erwartet 3000/3000" % (genuine, impostor))
    if folds != set(range(10)):
        raise Fail("pairs.txt: Folds %s, erwartet 0..9" % sorted(folds))
    people = smoke_people(people_path)
    if len(people) != 12:
        raise Fail("smoke-people.txt: %d Namen, erwartet 12" % len(people))
    print("pairs.txt  6000 Paare  3000 genuine  3000 impostor  10 Folds")
    print("smoke      %d Personen  (%s …)" % (len(people), people[0]))
    return pairs


def hf_protocol(local_pairs: list[tuple]) -> None:
    raw = fetch(HF_BASE + "/pairs.csv").decode("utf-8")
    hf = parse_pairs_csv(raw)
    if len(hf) != 6000:
        raise Fail("HF pairs.csv: %d Paare, erwartet 6000" % len(hf))
    mismatch = 0
    for a, b in zip(local_pairs, hf):
        if a[:5] != b[:5]:
            mismatch += 1
            if mismatch <= 3:
                print("abweichung  lokal=%s  hf=%s" % (a[:5], b[:5]), file=sys.stderr)
    if len(hf) != len(local_pairs):
        raise Fail("HF pairs.csv Länge %d ≠ pairs.txt %d" % (len(hf), len(local_pairs)))
    if mismatch:
        raise Fail("HF pairs.csv weicht in %d Paaren von bench/pairs.txt ab" % mismatch)
    print("huggingface  marcelohaps/lfw pairs.csv  deckungsgleich mit pairs.txt")


def load_meta(text: str) -> dict[str, list[tuple[str, str, int]]]:
    by: dict[str, list[tuple[str, str, int]]] = {}
    for row in csv.DictReader(io.StringIO(text)):
        ident = (row.get("identity") or row.get("label_name") or "").strip()
        rel = (row.get("file_name") or "").strip()
        src = (row.get("source_filename") or os.path.basename(rel)).strip()
        try:
            num = int(row.get("image_num") or "0")
        except ValueError:
            parsed = parse_name_index(src)
            num = parsed[1] if parsed else 0
        if not ident or not rel:
            continue
        by.setdefault(ident, []).append((rel, src, num))
    for ident in by:
        by[ident].sort(key=lambda t: t[2])
    return by


def download_smoke(out: Path, people: list[str], per: int) -> int:
    out.mkdir(parents=True, exist_ok=True)
    meta = load_meta(fetch(HF_BASE + "/train/metadata.csv").decode("utf-8"))
    missing = [p for p in people if p not in meta or len(meta[p]) < 2]
    if missing:
        raise Fail("HF metadata ohne Smoke-Personen: %s" % ", ".join(missing))
    saved = 0
    for person in people:
        dest = out / person
        dest.mkdir(parents=True, exist_ok=True)
        for rel, src, _num in meta[person][:per]:
            target = dest / src
            if target.is_file():
                existing = target.read_bytes()
                if is_jpeg(existing) and len(existing) >= 1000:
                    saved += 1
                    continue
            url = HF_BASE + "/train/" + rel.lstrip("/")
            data = fetch(url)
            if not is_jpeg(data) or len(data) < 1000:
                raise Fail("kein JPEG: %s (%d Byte)" % (url, len(data)))
            target.write_bytes(data)
            saved += 1
        print("  %s  %d" % (person, len(list(dest.glob("*.jpg")))))
    jpgs = list(out.rglob("*.jpg"))
    if len(jpgs) < len(people) * min(2, per):
        raise Fail("Smoke unvollständig: %d JPEGs" % len(jpgs))
    print("smoke-fotos  %d JPEGs in %s  (nicht committen)" % (len(jpgs), out))
    return saved


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Aegis LFW-Smoke von Hugging Face")
    ap.add_argument("--protocol", action="store_true", help="pairs.txt gegen HF pairs.csv")
    ap.add_argument("--download", action="store_true", help="12 Personen × N JPEGs holen")
    ap.add_argument("--out", default="", help="Zielordner für Fotos (gitignore)")
    ap.add_argument("--per", type=int, default=3, help="Fotos je Person (default 3)")
    args = ap.parse_args(argv)

    try:
        local = local_protocol(here() / "pairs.txt", here() / "smoke-people.txt")
        if args.protocol:
            hf_protocol(local)
        if args.download:
            dest = Path(args.out) if args.out else here() / "data" / "smoke"
            download_smoke(dest, smoke_people(here() / "smoke-people.txt"), max(2, args.per))
        return 0
    except NetError as e:
        print("netz  %s" % e, file=sys.stderr)
        return 2
    except Fail as e:
        print(e, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
