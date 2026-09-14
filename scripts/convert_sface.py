#!/usr/bin/env python3
"""ONNX SFace (Apache-2, OpenCV Zoo) → CoreML für Aegis.

Quelle: https://github.com/opencv/opencv_zoo/tree/main/models/face_recognition_sface
Pfad: ONNX → onnx2torch → TorchScript → neuralnetwork .mlmodel
Eingang: 1×3×112×112 RGB, (x-127.5)/128. Ausgang: 128-d.

coremltools ≥7 hat kein ONNX-Frontend mehr. numpy<2, coremltools 6.3.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ONNX = ROOT / "models" / "face_recognition_sface_2021dec.onnx"
DEFAULT_OUT = ROOT / "macos" / "AegisScanner" / "Models" / "SFace.mlmodel"
ONNX_URL = (
    "https://huggingface.co/opencv/face_recognition_sface/resolve/main/"
    "face_recognition_sface_2021dec.onnx"
)


def download(dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    import urllib.request

    print(f"download {ONNX_URL} → {dst}", file=sys.stderr)
    urllib.request.urlretrieve(ONNX_URL, dst)


def convert(src: Path, dst: Path) -> None:
    import coremltools as ct
    import torch
    from onnx2torch import convert as onnx_to_torch

    model = onnx_to_torch(str(src))
    model.eval()
    x = torch.randn(1, 3, 112, 112)
    traced = torch.jit.trace(model, x)
    dst.parent.mkdir(parents=True, exist_ok=True)
    ml = ct.convert(
        traced,
        inputs=[ct.TensorType(name="data", shape=(1, 3, 112, 112))],
        convert_to="neuralnetwork",
        minimum_deployment_target=ct.target.macOS11,
    )
    ml.short_description = "SFace 128-d face embedding (Apache-2, OpenCV Zoo 2021dec)"
    ml.author = "OpenCV Zoo / SFace"
    ml.license = "Apache-2.0"
    ml.save(str(dst))
    print(f"wrote {dst} ({dst.stat().st_size} bytes)")


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--onnx", type=Path, default=DEFAULT_ONNX)
    p.add_argument("--out", type=Path, default=DEFAULT_OUT)
    p.add_argument("--skip-download", action="store_true")
    args = p.parse_args()
    if not args.onnx.exists():
        if args.skip_download:
            print(f"missing {args.onnx}", file=sys.stderr)
            return 1
        download(args.onnx)
    convert(args.onnx, args.out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
