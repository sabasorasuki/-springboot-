# Huagao LTR Pipeline

This directory contains the v1 offline recommendation pipeline for `sys_huagao`.

## Setup

```powershell
python -m pip install -r recsys/huagao_ltr/requirements.txt
```

Database connection is read from:

- `ARTISTSION_DB_HOST` or `DB_HOST`, default `127.0.0.1`
- `ARTISTSION_DB_PORT` or `DB_PORT`, default `3306`
- `ARTISTSION_DB_NAME` or `DB_NAME`, default `artistsion`
- `ARTISTSION_DB_USER` or `DB_USERNAME`, default `root`
- `ARTISTSION_DB_PASS` or `DB_PASSWORD`, default empty

## Run

```powershell
python recsys/huagao_ltr/run_pipeline.py --source synthetic --top-k 50
```

The synthetic run mutates the configured database. It deletes previous synthetic rows by default, writes request/impression/action logs with `syn_` prefixes, creates synthetic catalog rows tagged with `fujin='synthetic_ltr'` only when the active huagao catalog is too small for a useful demo, and stores offline recommendations for `u:*`, `v:*`, and `global` actors.
