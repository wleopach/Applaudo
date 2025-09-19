# Applaudo

A small analytics and optimization project with Jupyter notebooks, SQL snippets, and a utility script to export notebooks to PDF with code cells hidden while preserving markdown and plots.

## Project structure
- `notebooks/` — Jupyter notebooks for analysis and visualization.
- `scripts/` — Utility scripts, including notebook-to-PDF export.
- `sql/` — SQL files used by notebooks or data preparation steps.
- `data/` — Datasets or sources; may contain its own README.
- `outputs/` — Suggested location for generated outputs (e.g., exported PDFs).
- `pyproject.toml` — Project metadata and Python dependencies.
- `uv.lock` — Dependency lockfile (for the `uv` package manager).

## Requirements
- Python 3.13
- Dependencies listed in `pyproject.toml` (notably: duckdb, pandas, plotly, nbconvert[webpdf], notebook, statsmodels, kaleido, gurobipy)
- For exporting PDFs via nbconvert’s WebPDFExporter, you need a Chromium/Chrome installation discoverable on your system.
- For optimization features using `gurobipy`, you need a valid Gurobi installation and license.

## Setup
You can use the `uv` tool (recommended if you have it) or plain `pip`.

### Option A: Using uv (recommended)
1. Install uv if needed: https://docs.astral.sh/uv/
2. From the repo root, create and sync an environment:
   - `uv venv`
   - `uv sync`
3. Activate the environment (Linux/macOS): `source .venv/bin/activate` (Windows PowerShell: `.venv\Scripts\Activate.ps1`)

### Option B: Using pip
Create a virtual environment and install the dependencies from `pyproject.toml` manually:

- Linux/macOS
  - `python3 -m venv .venv`
  - `source .venv/bin/activate`
  - `pip install --upgrade pip wheel`
  - `pip install duckdb==1.4.0 gurobipy==12.0.3 kaleido>=1.1.0 nbconvert[webpdf]>=7.16.6 notebook>=7.4.5 pandas==2.3.2 plotly==6.3.0 statsmodels==0.14.5`

- Windows (PowerShell)
  - `py -m venv .venv`
  - `.\.venv\Scripts\Activate.ps1`
  - `pip install --upgrade pip wheel`
  - `pip install duckdb==1.4.0 gurobipy==12.0.3 kaleido>=1.1.0 nbconvert[webpdf]>=7.16.6 notebook>=7.4.5 pandas==2.3.2 plotly==6.3.0 statsmodels==0.14.5`

## Export notebooks to PDF (code hidden, markdown and plots included)
This repository includes a script that will:
- Execute each notebook (by default) so that plots and outputs are generated;
- Export to PDF using nbconvert’s WebPDFExporter;
- Hide code cell inputs while preserving markdown and outputs.

Usage examples:
- Export PDFs next to the notebooks:
  - `python scripts/export_notebooks_to_pdf.py`
- Export to a dedicated folder (creates it if missing):
  - `python scripts/export_notebooks_to_pdf.py --output-dir outputs/pdfs`
- Overwrite existing PDFs:
  - `python scripts/export_notebooks_to_pdf.py --overwrite`
- Skip executing notebooks and use existing outputs only:
  - `python scripts/export_notebooks_to_pdf.py --no-execute`

Notes:
- The WebPDF exporter renders HTML to PDF using a headless browser. Ensure Chromium/Chrome is installed and discoverable. The script enables automatic Chromium download as a fallback on some platforms.
- Interactive Plotly figures are converted to static images via `kaleido` to ensure they appear in the PDFs.

## Troubleshooting
- Chromium not found: Install Chromium or Google Chrome. On Debian/Ubuntu: `sudo apt-get install chromium-browser`. On macOS (Homebrew): `brew install chromium`. Ensure it’s on your PATH.
- Plotly images missing: Ensure `kaleido` is installed (it is specified in dependencies). The export script injects a setup cell to force static image rendering.
- Notebook execution issues: The export process executes notebooks in their own folder. If your notebook depends on environment variables or external files, confirm they are available.
- Gurobi license: If using `gurobipy`, make sure your Gurobi installation and license are correctly set up.

## License
Not specified. Add a license here if needed.
