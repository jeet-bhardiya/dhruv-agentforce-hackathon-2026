# Seed Data Generator — Dhruv Demo

Generates 4 deterministic CSV files of synthetic Indian wealth-management data
for the Dhruv RBI MPC rate-cut demo scenario.

## Prerequisites

- Python 3.11+ (stdlib only — no third-party packages required)

## How to run

```bash
# Replace 005XXXXXXXXXXXXXXX with the 18-char Salesforce User Id for Vikram Rao.
# --out defaults to scripts/seed/data; pass a different path if needed.
python3 scripts/seed/seed_data.py \
    --owner-id 005XXXXXXXXXXXXXXX \
    --out scripts/seed/data
```

## Output files

| File | Rows | Description |
|---|---|---|
| `securities.csv` | 53 | NIFTY50 + 3 ETFs with sector tags |
| `persons.csv` | 450 | Personal Account holders (RM-owned) |
| `households.csv` | 150 | Stub household groupings |
| `holdings.csv` | ~2000 | Portfolio holdings (engineered for demo) |

## Demo engineering guarantees

- Exactly **62** of 450 clients have ≥20% rate-sensitive exposure
- Exactly **8** of those 62 are owned by `RM_VIKRAM`
- Hero clients Priya Sharma (PA_0001), Rohit Kapoor (PA_0002), Meera Desai (PA_0003)
  appear at rows 1–3 with fixed AUM and high exposure percentages

## Determinism

Re-running with identical arguments produces byte-identical CSVs. `SEED = 4242`
is fixed in the script.

## Loading into Salesforce

The placeholder `RM_VIKRAM` in `persons.csv` and `holdings.csv` must be replaced
with the real Salesforce User Id before loading with Data Loader:

```bash
sed -i '' 's/RM_VIKRAM/005XXXXXXXXXXXXXXX/g' \
    scripts/seed/data/persons.csv \
    scripts/seed/data/holdings.csv
```

See `docs/superpowers/plans/2026-04-28-dhruv-implementation.md` (Task 1.7 onwards)
for the full Data Loader import sequence and object load order.
