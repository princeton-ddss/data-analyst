---
name: ingest
description: >
  Use when the user wants to add a new data source or ingest data.
  Builds a pipeline: fetch raw data → save to data/raw/ → clean → load into DuckDB.
  Examples: "Add census data", "Set up the election results", "Ingest ACS 5-year data".
---

# Data Manager

Build and run data ingestion pipelines.

A **source** is a dataset that may span multiple years, geographies, or subsets
(e.g., "Census ACS 5-Year" is one source, not one source per year). A source is
registered once. Fetching new years or subsets reuses the same source, cleaning
script, and pipeline.

## Workflow

1. **Check if source already exists**
   - Read `data/sources.yaml` to see whether the source is already registered
   - Either way, continue to step 2; new sources get registered in step 5

2. **Fetch raw data**
   - Download/query the requested subset (years, geography, variables)
   - Save to `data/raw/` with clear naming: `{source}_{subset}.{format}`
   - Never modify raw files after saving — they are the source of truth

3. **Clean**
   - If a cleaning script already exists for this source (`scripts/clean_{source}.py`), run it
   - If not, build one:
     - Standardize column names (snake_case)
     - Parse dates, fix encodings, normalize categories
     - Handle missing data (document decisions in the script)
   - The cleaning script should handle all subsets/years for this source
   - Output to `data/clean/{source}.parquet`

4. **Load into DuckDB**
   - Register the cleaned parquet as a table in the project database, `data/data.duckdb`
   - Verify the table: row count, schema, sample rows

5. **Register the source** (new sources only)
   - Add an entry to `data/sources.yaml`:
     ```yaml
     {name}:
       origin: {url, path, or API}
       format: {format}
       key: [{key columns}]
       cleaning: scripts/clean_{name}.py
     ```
   - Create this file if it doesn't exist

## Parallel fetching

When multiple sources or subsets need to be fetched (e.g., "get census and
election data for 2016-2020"), spawn general-purpose agents in parallel — one
per source or API call. Each agent downloads its data and saves to `data/raw/`.
Then clean and load sequentially after all fetches complete.

## Credentials

- Read API keys from the shell environment first via `os.environ.get(...)`, falling back to `python-dotenv` only if the var is not set
- Never read, cat, or echo shell environment variables. They should not enter conversation context.
- Expected naming: `{SOURCE}_API_KEY` or `{SOURCE}_DB_URL` (e.g., `CENSUS_API_KEY`)
- Never echo, print, or log credential values
- Never read, cat, or open `.env` files directly — only access credentials at runtime via `os.environ` or `dotenv.load_dotenv()`
- If a key is not set anywhere, proceed without it when the API allows unauthenticated access; otherwise, tell the user which env var to set

## Re-running

If raw data already exists and the user wants to re-clean or update:
- Run the cleaning script directly: `python scripts/clean_{source}.py`
