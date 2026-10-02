---
name: setup
description: >
  Use at the start of a new project or when the virtual environment is missing.
  Creates a uv virtual environment and installs core data analysis packages.
  Examples: "Set up the project", "Initialize the environment", "Install dependencies".
---

# Setup

Create a virtual environment and install packages for data analysis.

## Workflow

1. **Create virtual environment**
   ```
   uv venv
   ```

2. **Install packages**
   ```
   uv pip install \
     polars pyarrow duckdb python-dotenv \
     scipy statsmodels scikit-learn \
     altair matplotlib folium \
     geopandas pygris \
     marimo
   ```

3. **Create directory structure** (if missing)
   - `data/raw/`
   - `data/clean/`
   - `results/`
   - `notebooks/`
   - `scripts/`
   - `.tmp/`
   - `logs/`

4. **Verify**
   - Write `.tmp/check_env.py` containing `import polars, duckdb; print("OK")`,
     then run `uv run python .tmp/check_env.py` to confirm installation
