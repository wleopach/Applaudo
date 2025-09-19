#!/usr/bin/env python3
"""
Export all Jupyter notebooks in the notebooks/ folder to PDF, excluding code cells.

By default, saves PDFs next to each .ipynb (e.g., notebooks/foo.ipynb -> notebooks/foo.pdf).
Requires nbconvert[webpdf] and a Chromium/Chrome installation for the WebPDF exporter.

Usage:
  python scripts/export_notebooks_to_pdf.py
  python scripts/export_notebooks_to_pdf.py --output-dir outputs/pdfs
  python scripts/export_notebooks_to_pdf.py --overwrite

Options:
  --notebooks-dir PATH   Directory containing notebooks (default: notebooks)
  --output-dir PATH      Directory to write PDFs (default: same as notebooks)
  --overwrite            Overwrite existing PDFs if present
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import List

from traitlets.config import Config
from nbconvert.exporters import WebPDFExporter


def find_notebooks(nb_dir: Path) -> List[Path]:
    return sorted([p for p in nb_dir.glob("*.ipynb") if not p.name.startswith("._")])


essay = """
Note: The WebPDF exporter renders HTML and prints to PDF using a headless browser. You need a recent
Chromium or Chrome installed and discoverable. If you see errors about Chromium, install it and try again.
"""


def export_notebook_to_pdf(nb_path: Path, out_dir: Path, overwrite: bool = False) -> Path:
    cfg = Config()
    # Exclude code cell inputs
    cfg.TemplateExporter.exclude_input = True
    # Slightly bigger margins for readability when printing
    cfg.WebPDFExporter.allow_chromium_download = True  # last resort: nbconvert may download a compatible chromium
    cfg.WebPDFExporter.paginate = True

    exporter = WebPDFExporter(config=cfg)

    output_basename = nb_path.stem + ".pdf"
    out_path = out_dir / output_basename
    if out_path.exists() and not overwrite:
        return out_path

    body, _ = exporter.from_filename(str(nb_path))
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(body)
    return out_path


def main(argv: List[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Export notebooks to PDF without code cells.")
    parser.add_argument("--notebooks-dir", default="notebooks", type=Path, help="Directory with .ipynb files (default relative to project root)")
    parser.add_argument("--output-dir", default=None, type=Path, help="Directory to write PDFs (default: same as notebooks)")
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing PDFs if they exist")
    args = parser.parse_args(argv)

    nb_dir = args.notebooks_dir
    # If the notebooks dir is relative and not found from the current working directory,
    # also try resolving it relative to the repository root (parent of this script's directory).
    if not nb_dir.is_absolute() and (not nb_dir.exists() or not nb_dir.is_dir()):
        script_dir = Path(__file__).resolve().parent
        repo_root = script_dir.parent  # scripts/ is inside the repo root
        candidate = (repo_root / nb_dir).resolve()
        if candidate.exists() and candidate.is_dir():
            nb_dir = candidate

    if not nb_dir.exists() or not nb_dir.is_dir():
        print(f"Error: notebooks directory not found: {args.notebooks_dir}", file=sys.stderr)
        return 2

    out_dir = args.output_dir if args.output_dir is not None else nb_dir

    notebooks = find_notebooks(nb_dir)
    if not notebooks:
        print(f"No notebooks found in {nb_dir}")
        return 0

    print(f"Exporting {len(notebooks)} notebooks from {nb_dir} to {out_dir} (exclude code cells)")
    successes = 0
    failures = []
    for nb in notebooks:
        try:
            pdf_path = export_notebook_to_pdf(nb, out_dir, overwrite=args.overwrite)
            print(f"✓ {nb.name} -> {pdf_path}")
            successes += 1
        except Exception as e:
            print(f"! Failed to export {nb.name}: {e}", file=sys.stderr)
            failures.append((nb, e))

    if failures:
        print("\nSome notebooks failed to export:", file=sys.stderr)
        for nb, e in failures:
            print(f" - {nb}: {e}", file=sys.stderr)
        print(essay.strip(), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
