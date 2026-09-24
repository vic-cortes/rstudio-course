# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal R workspace combining coursework from a "Bases de datos y técnicas de gráficación" diploma course with real personal-finance/data-analysis scripts. It's not a package — there is no `DESCRIPTION`, test suite, or build system. Scripts are run interactively (e.g., in RStudio) or via `Rscript`.

## Repository layout

- `code/course/` — diploma course exercises (`session_*.R`, `subject_*.R`). Each is a standalone, top-to-bottom script that starts with `rm(list = ls())`, conditionally installs `pacman`, then `pacman::p_load(...)` the packages it needs. These are learning scripts, not shared modules — don't refactor them to share code with `code/finance` or `code/src`.
- `code/finance/` — personal finance analysis (e.g. `electrical_bill.R`), pulling data from a Google Sheet via `googlesheets4`.
- `code/src/` — scripts for querying a SQL Server database (electrical/mechanical equipment error logs), built around `DBI`/`odbc`.
- `db/`, `data/`, `maps/`, `output/` — local data directories. `data/` holds SQL Server `.mdf`/`.ldf` database files (used by the Docker SQL Server setup below); `db/` holds sample CSV/XLSX inputs used by course exercises. Most data file types (`*.csv`, `*.xlsx`, `*.mdf`, `*.ldf`, `*.bin`) are gitignored — treat anything of these types as local/untracked, not part of the reviewable codebase.
- `Dockerfile` / `docker-compose.yml` / `attach_db.sh` — spin up a local SQL Server 2022 Linux container and attach the `real_db.mdf`/`.ldf` files from `data/` as a database named `real_db`.
- `docs/` — standalone reference docs not tied to any script. `docs/vscode-r-syntax-highlighting-fix.md` documents how to fix broken R syntax highlighting in VS Code (stale TextMate scope overrides, plus a local extension for ALL_CAPS-as-constant and `library`/`setwd` coloring) — check it before re-diagnosing VS Code R highlighting issues on a new machine.
- `.vscode/r-caps-constant/` — source for a local (unpublished) VS Code extension that adds TextMate scopes the `REditorSupport.r-syntax` grammar doesn't cover. Not auto-installed by cloning the repo — see `docs/vscode-r-syntax-highlighting-fix.md` for how to package (`vsce`) and install it.

## Running things

There's no package manager lockfile; dependencies are declared inline per-script via `pacman::p_load(...)`, which installs-if-missing then loads. To run a script:

```sh
Rscript code/finance/electrical_bill.R
Rscript code/course/session_7.R
```

Many scripts `setwd()` to their own directory at the top (e.g. `code/finance/electrical_bill.R` does `setwd("./code/finance/")`) and expect to be run with the repo root as the working directory, or run interactively from RStudio with that file's directory as the project root.

### Local SQL Server (for `code/src/`)

```sh
docker compose up --build
```

This builds a SQL Server 2022 container, copies `data/real_db.mdf`/`.ldf` in, and `attach_db.sh` runs `CREATE DATABASE ... FOR ATTACH` on startup to mount it as `real_db`. Connection settings for R scripts come from `code/src/.env` (gitignored) via `code/src/config.R`, read with `dotenv::load_dot_env`. Expected vars: `DB_PASSWORD`, `DB_SERVER`, `DB_DATABASE`, `DB_USER`, `DB_PORT`. `code/src/connection.R` connects using the `ODBC Driver 18 for SQL Server` (`Encrypt = "yes"`, `TrustServerCertificate = "yes"` — required for Driver 18). `code/src/main.R` is the entry point (`source('connection.R')`).

### Finance scripts

`code/finance/config.R` reads `code/finance/.env` (gitignored) for `GOOGLE_SHEET_ID` and `GOOGLE_SHEET_CFE`, used by `googlesheets4::read_sheet()` in `electrical_bill.R` to pull raw CFE (electricity) billing data, then computes daily/weekly consumption stats and plots them with `ggplot2`.

## Architecture notes

- `code/src/queries.R` defines both free functions (`get_checksum_data_by_date`, `get_data_by_date`, `get_datos_by_date`) and an `R6` class `DbDataFetcher` that generalizes the same date-range query pattern across the `checksum`, `data`, and `datos` tables (see the `SUPPORTED_TABLES` allowlist in its private method). The free functions predate the R6 class and are kept for a couple of one-off queries at the top of the file — this file is written as an exploratory analysis script (queries interleaved with data wrangling), not a clean library, so expect module-level side effects (e.g. `db_object <- DbDataFetcher$new()` and query calls execute at source time).
- SQL queries in `code/src/queries.R` are built with `sprintf`/`glue` string interpolation directly from date arguments — there's no parameterized-query layer. Any change that accepts less-trusted input here should move to parameterized queries (`DBI::dbBind`) rather than extending the interpolation pattern.
- Date-range filtering conventions differ by table: `checksum`/`datos` filter on `fechasvr`, `data` filters on `fecha`.
- No formal test suite, linter config, or CI exists in this repo.
