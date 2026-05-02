"""
Dhruv Agentforce Hackathon — Synthetic Seed Data Generator
===========================================================
Generates 4 deterministic CSV files for the RBI MPC rate-cut demo scenario:
  - securities.csv   : 53 rows (NIFTY50 + 3 ETFs)
  - persons.csv      : 450 rows (Personal Account holders)
  - households.csv   : 150 rows (stub grouping)
  - holdings.csv     : ~2000 rows (portfolio holdings)

Usage:
    python3 scripts/seed/seed_data.py --owner-id <18-char Salesforce User Id> [--out scripts/seed/data]

The placeholder "RM_VIKRAM" in persons.csv and holdings.csv must be replaced
with the real Salesforce User Id via `sed` before loading with Data Loader.
Re-running the script with the same arguments produces byte-identical CSVs.
"""

import argparse
import csv
import random
from pathlib import Path

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SEED = 4242

RATE_SENSITIVE_TICKERS = {
    "HDFCBANK", "ICICIBANK", "SBIN", "AXISBANK", "KOTAKBANK",
    "BAJAJFINSV", "BAJFINANCE", "BANKBEES",
}

INDIAN_FIRST_NAMES = [
    "Aarav", "Vihaan", "Aditya", "Krishna", "Reyansh", "Ayaan", "Atharv", "Ishaan",
    "Priya", "Anaya", "Diya", "Aadhya", "Saanvi", "Kiara", "Myra", "Ananya",
    "Rohit", "Vikram", "Meera", "Rajesh", "Neha", "Pooja", "Sanjay", "Karan",
]
INDIAN_LAST_NAMES = [
    "Sharma", "Verma", "Kapoor", "Desai", "Mehta", "Shah", "Patel", "Iyer", "Reddy",
    "Joshi", "Gupta", "Singh", "Khanna", "Malhotra", "Bhardwaj", "Rao",
]
MUMBAI_AREAS = [
    "Bandra", "Andheri", "Powai", "Worli", "Juhu", "Borivali", "Malad",
    "Thane", "Vashi", "Lower Parel", "BKC", "Khar", "Goregaon",
]

NIFTY50_TICKERS = [
    "RELIANCE", "TCS", "HDFCBANK", "INFY", "ICICIBANK", "SBIN", "AXISBANK", "KOTAKBANK",
    "ITC", "LT", "HINDUNILVR", "BHARTIARTL", "BAJFINANCE", "BAJAJFINSV", "HCLTECH",
    "WIPRO", "ASIANPAINT", "MARUTI", "M&M", "TITAN", "ULTRACEMCO", "NESTLEIND", "SUNPHARMA",
    "DRREDDY", "NTPC", "POWERGRID", "COALINDIA", "GRASIM", "JSWSTEEL", "TATASTEEL",
    "TATAMOTORS", "HEROMOTOCO", "BAJAJ-AUTO", "ADANIPORTS", "CIPLA", "DIVISLAB", "BPCL",
    "HDFCLIFE", "SBILIFE", "ONGC", "UPL", "BRITANNIA", "TECHM", "TATACONSUM", "INDUSINDBK",
    "EICHERMOT", "HINDALCO", "APOLLOHOSP", "ADANIENT", "SHRIRAMFIN",
]
ETFS = ["BANKBEES", "NIFTYBEES", "LIQUIDBEES"]

# Sector mapping
_SECTOR_MAP = {
    "Banking": {"HDFCBANK", "ICICIBANK", "SBIN", "AXISBANK", "KOTAKBANK", "INDUSINDBK", "BANKBEES"},
    "IT":      {"TCS", "INFY", "HCLTECH", "WIPRO", "TECHM"},
    "Auto":    {"MARUTI", "M&M", "TATAMOTORS", "HEROMOTOCO", "BAJAJ-AUTO", "EICHERMOT"},
    "Pharma":  {"SUNPHARMA", "DRREDDY", "CIPLA", "DIVISLAB", "APOLLOHOSP"},
    "FMCG":    {"HINDUNILVR", "ITC", "NESTLEIND", "BRITANNIA", "TATACONSUM"},
    "Energy":  {"RELIANCE", "NTPC", "POWERGRID", "COALINDIA", "BPCL", "ONGC"},
}


def _sector(ticker: str) -> str:
    for sector, tickers in _SECTOR_MAP.items():
        if ticker in tickers:
            return sector
    return "Other"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def _write_csv(path: Path, rows: list[dict]) -> None:
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=rows[0].keys())
        w.writeheader()
        w.writerows(rows)


def _force_exposure(holdings: list, person: dict, security: dict, pct: float) -> None:
    holdings.append({
        "Name": f"{person['ExternalId']}-{security['Ticker']}",
        "AccountExternalId": person["ExternalId"],
        "SecurityExternalId": security["ExternalId"],
        "MarketValue__c": round(person["AUM__c"] * pct),
        "Quantity__c": 100,
    })


def _sec_by_ticker(securities: list, ticker: str) -> dict:
    """Look up a security by ticker (safe alternative to positional indexing)."""
    for s in securities:
        if s["Ticker"] == ticker:
            return s
    raise ValueError(f"Ticker {ticker!r} not found in securities list")


# ---------------------------------------------------------------------------
# Generators
# ---------------------------------------------------------------------------
def _securities() -> list[dict]:
    rows = []
    for ticker in NIFTY50_TICKERS + ETFS:
        rows.append({
            "ExternalId": f"SEC_{ticker}",
            "Ticker": ticker,
            "Name": ticker,
            "Sector": _sector(ticker),
        })
    return rows


def _persons(rng: random.Random) -> list[dict]:
    rows = []
    for i in range(1, 451):
        owner = "RM_VIKRAM" if i <= 60 else f"RM_{rng.randint(1, 8):02d}"
        rows.append({
            "ExternalId": f"PA_{i:04d}",
            "FirstName": rng.choice(INDIAN_FIRST_NAMES),
            "LastName": rng.choice(INDIAN_LAST_NAMES),
            "BillingCity": "Mumbai",
            "BillingStreet": f"{rng.randint(1, 500)} {rng.choice(MUMBAI_AREAS)}",
            "BillingPostalCode": str(400000 + rng.randint(1, 99)),
            "BillingCountry": "India",
            "AUM__c": round(rng.lognormvariate(15.5, 0.7)),
            "Preferred_Channel__c": "WhatsApp" if rng.random() < 0.6 else "Email",
            "OwnerExternalId": owner,
        })

    # Override first 3 with hero data. BillingCity is set to the Mumbai
    # locality (Bandra/Andheri/Worli) so the Pre-Call Brief prompt grounds
    # on the area name the demo voiceover references.
    rows[0].update({
        "FirstName": "Priya", "LastName": "Sharma", "ExternalId": "PA_0001",
        "BillingCity": "Bandra",
        "BillingStreet": "12 Bandra West", "BillingPostalCode": "400050",
        "AUM__c": 18000000, "OwnerExternalId": "RM_VIKRAM",
        "Preferred_Channel__c": "WhatsApp",
    })
    rows[1].update({
        "FirstName": "Rohit", "LastName": "Kapoor", "ExternalId": "PA_0002",
        "BillingCity": "Andheri",
        "BillingStreet": "45 Andheri East", "BillingPostalCode": "400069",
        "AUM__c": 22000000, "OwnerExternalId": "RM_VIKRAM",
        "Preferred_Channel__c": "WhatsApp",
    })
    rows[2].update({
        "FirstName": "Meera", "LastName": "Desai", "ExternalId": "PA_0003",
        "BillingCity": "Worli",
        "BillingStreet": "8 Worli Sea Face", "BillingPostalCode": "400018",
        "AUM__c": 15000000, "OwnerExternalId": "RM_VIKRAM",
        "Preferred_Channel__c": "WhatsApp",
    })
    return rows


def _households(persons: list[dict]) -> list[dict]:
    rows = []
    for i in range(150):
        rows.append({
            "ExternalId": f"HH_{i + 1:03d}",
            "Name": f"{persons[i * 3]['LastName']} Family",
        })
    return rows


def _holdings(rng: random.Random, persons: list[dict], securities: list[dict]) -> list[dict]:
    rate_sensitive_secs = [s for s in securities if s["Ticker"] in RATE_SENSITIVE_TICKERS]
    other_secs = [s for s in securities if s["Ticker"] not in RATE_SENSITIVE_TICKERS]

    # Verify the rate_sensitive_secs ordering for safety — use ticker lookup for heroes
    hdfcbank_sec = _sec_by_ticker(securities, "HDFCBANK")
    icicibank_sec = _sec_by_ticker(securities, "ICICIBANK")
    bankbees_sec = _sec_by_ticker(securities, "BANKBEES")

    holdings: list[dict] = []

    # --- 1. Forced hero exposures ---
    _force_exposure(holdings, persons[0], hdfcbank_sec, 0.28)   # Priya: HDFCBANK 28%
    _force_exposure(holdings, persons[1], icicibank_sec, 0.22)  # Rohit: ICICIBANK 22%
    _force_exposure(holdings, persons[2], bankbees_sec, 0.21)   # Meera: BANKBEES 21%

    # Track which accounts already have forced exposures (to avoid double-counting)
    forced_ids = {persons[0]["ExternalId"], persons[1]["ExternalId"], persons[2]["ExternalId"]}

    # --- 2. Vikram's other 5 in-the-62 accounts (PA_0004..PA_0008) ---
    for k in range(4, 9):  # persons[3]..persons[7] inclusive => PA_0004..PA_0008 (5 accounts)
        _force_exposure(
            holdings, persons[k - 1],
            rng.choice(rate_sensitive_secs),
            0.20 + rng.random() * 0.10,
        )
        forced_ids.add(persons[k - 1]["ExternalId"])

    # --- 3. 54 more non-Vikram accounts with rate-sensitive >=20% ---
    # persons[8:] starts at PA_0009. Filter is still needed because Vikram owns
    # PA_0001..PA_0060 (i <= 60 in _persons), so we must exclude PA_0009..PA_0060.
    pool = [p for p in persons[8:] if p["OwnerExternalId"] != "RM_VIKRAM"]
    for p in rng.sample(pool, 54):
        _force_exposure(
            holdings, p,
            rng.choice(rate_sensitive_secs),
            0.20 + rng.random() * 0.15,
        )
        forced_ids.add(p["ExternalId"])

    # --- 4. Pad every account with 3–6 small non-rate-sensitive holdings ---
    # For forced-exposure accounts, track what rate-sensitive AUM is already booked
    # so padding with non-rate-sensitive stock doesn't dilute below 20%.
    for p in persons:
        pid = p["ExternalId"]
        existing_rate_sensitive_mv = sum(
            h["MarketValue__c"]
            for h in holdings
            if h["AccountExternalId"] == pid
        )
        existing_total_mv = existing_rate_sensitive_mv  # only rate-sensitive booked so far

        n = rng.randint(3, 6)

        if pid in forced_ids:
            # For forced accounts we must keep rate-sensitive / AUM >= 20%.
            # We know forced_mv / AUM >= 20%. We can add up to:
            #   non_rs_budget = forced_mv / 0.20 - forced_mv = forced_mv * 4
            # but we'll be conservative: cap non-rs at 3× the forced exposure so
            # exposure% = forced_mv / (forced_mv + non_rs_addition) >= 20%.
            # forced_mv / (forced_mv + budget) = 0.20 => budget = forced_mv * 4
            # We use forced_mv * 3 to stay safely above 20%.
            budget = existing_rate_sensitive_mv * 3
            per_holding = round(budget / n) if n else 0
            for _ in range(n):
                sec = rng.choice(other_secs)
                holdings.append({
                    "Name": f"{pid}-{sec['Ticker']}",
                    "AccountExternalId": pid,
                    "SecurityExternalId": sec["ExternalId"],
                    "MarketValue__c": per_holding,
                    "Quantity__c": rng.randint(10, 500),
                })
        else:
            # Regular account: distribute remaining AUM loosely
            remaining = max(p["AUM__c"] - existing_total_mv, p["AUM__c"] * 0.5)
            for _ in range(n):
                sec = rng.choice(other_secs)
                holdings.append({
                    "Name": f"{pid}-{sec['Ticker']}",
                    "AccountExternalId": pid,
                    "SecurityExternalId": sec["ExternalId"],
                    "MarketValue__c": round(remaining / n),
                    "Quantity__c": rng.randint(10, 500),
                })

    return holdings


# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
def _validate(persons: list[dict], securities: list[dict], holdings: list[dict]) -> None:
    """Assert that exactly 62 accounts have >=20% rate-sensitive exposure."""
    ticker_by_sec_id = {s["ExternalId"]: s["Ticker"] for s in securities}

    # Aggregate per account
    rs_mv: dict[str, float] = {}
    for h in holdings:
        ticker = ticker_by_sec_id.get(h["SecurityExternalId"], "")
        if ticker in RATE_SENSITIVE_TICKERS:
            rs_mv[h["AccountExternalId"]] = rs_mv.get(h["AccountExternalId"], 0) + h["MarketValue__c"]

    aum_by_id = {p["ExternalId"]: p["AUM__c"] for p in persons}
    owner_by_id = {p["ExternalId"]: p["OwnerExternalId"] for p in persons}

    # Denominator is AUM__c (the Salesforce field) — NOT the sum of all holdings,
    # which can drift above AUM__c due to padding holdings.
    impacted = [pid for pid, mv in rs_mv.items() if mv / aum_by_id[pid] >= 0.20]
    vikram_impacted = [pid for pid in impacted if owner_by_id[pid] == "RM_VIKRAM"]

    print(f"\nTotal accounts with rate-sensitive exposure >=20%: {len(impacted)}")
    print(f"Of those, owned by RM_VIKRAM: {len(vikram_impacted)}")

    if len(impacted) != 62:
        raise AssertionError(
            f"Engineering failure: expected 62 accounts with >=20% rate-sensitive exposure, "
            f"got {len(impacted)}. Check _holdings() padding logic."
        )
    if len(vikram_impacted) != 8:
        raise AssertionError(
            f"Engineering failure: expected 8 RM_VIKRAM accounts in >=20% set, "
            f"got {len(vikram_impacted)}. Check _holdings() forced-Vikram logic."
        )


# ---------------------------------------------------------------------------
# Orchestrator
# ---------------------------------------------------------------------------
def main(out_dir: Path, owner_id: str) -> None:
    rng = random.Random(SEED)

    securities = _securities()
    persons = _persons(rng)
    households = _households(persons)
    holdings = _holdings(rng, persons, securities)

    _validate(persons, securities, holdings)

    out_dir.mkdir(parents=True, exist_ok=True)
    _write_csv(out_dir / "securities.csv", securities)
    _write_csv(out_dir / "persons.csv", persons)
    _write_csv(out_dir / "households.csv", households)
    _write_csv(out_dir / "holdings.csv", holdings)

    print(
        f"\nWrote {len(persons)} persons, {len(households)} households, "
        f"{len(securities)} securities, {len(holdings)} holdings."
    )
    print(
        f"Owner externalId 'RM_VIKRAM' should map to user id {owner_id!r} on import.\n"
        f"Replace placeholder before loading:\n"
        f"  sed -i '' 's/RM_VIKRAM/{owner_id}/g' {out_dir}/persons.csv {out_dir}/holdings.csv"
    )


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate deterministic synthetic seed CSVs for the Dhruv demo."
    )
    parser.add_argument(
        "--owner-id",
        required=True,
        metavar="SALESFORCE_USER_ID",
        help="18-character Salesforce User Id for Vikram Rao (written as placeholder RM_VIKRAM).",
    )
    parser.add_argument(
        "--out",
        default="scripts/seed/data",
        metavar="DIR",
        help="Output directory for CSVs (default: scripts/seed/data).",
    )
    args = parser.parse_args()
    if len(args.owner_id) not in (15, 18):
        parser.error("--owner-id must be a 15- or 18-character Salesforce User Id")
    main(Path(args.out), args.owner_id)
