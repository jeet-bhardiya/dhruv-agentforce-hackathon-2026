# Market Event Simulator

Posts synthetic market events to the Data Cloud Streaming Ingestion endpoint
that feeds the `MarketEvent__dlm` DMO. Used to trigger the
`MarketImpact_Detect_Segment` Flow on demand for the demo.

## Prerequisites

- Python 3.11+ (stdlib only)
- A Streaming Ingestion connector (`MarketEventStream`) created in Data Cloud
- An OAuth bearer token for the Data Cloud Ingestion API

## Setup

```bash
cp scripts/simulator/.env.example scripts/simulator/.env
# Edit .env with your DC_INGEST_URL and DC_TOKEN
```

## Run

```bash
set -a && source scripts/simulator/.env && set +a
python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json
```

Expected: `HTTP 202 Accepted`.

## Available events

| File | Scenario |
|---|---|
| `rbi_mpc_25bps_cut.json` | Anchor demo — RBI cuts repo by 25 bps, BANKNIFTY −1.25% |
| `it_selloff.json` | Fallback scenario — NIFTYIT −3.4%, Medium severity |

## Verification chain after firing

1. Data Cloud → Data Explorer → `MarketEvent__dlm` shows new row
2. Setup → Platform Events → `Market_Impact_Event__e` Streaming Monitor shows event
3. Object Manager → `Market_Impact__c` row count = ~62 (one per impacted account)
4. Mobile / Desktop notification arrives on Vikram (and any other impacted RM)
