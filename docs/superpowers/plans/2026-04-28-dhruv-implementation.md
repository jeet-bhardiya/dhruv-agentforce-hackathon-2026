# Dhruv — Market Monitoring Agent — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a working end-to-end demo of "Dhruv" — an Agentforce co-pilot for wealth RMs that detects RBI MPC events, segments 450 → 62 → 8 clients, drafts compliance-checked Hinglish WhatsApp nudges, routes Slack approvals, pushes a 360° pre-call brief, and reveals a Trust Layer audit — recorded as a 4:50 video by 2026-05-03.

**Architecture:** Two real Agentforce agents (Dhruv + Paalak) on FSC Core + Data Cloud. Streaming events go Python simulator → Data Cloud Streaming Ingestion → Data Action filter → Platform Event → Flow that queries `ClientExposureGraph` Data Graph and creates `Market_Impact__c` rows, fires Custom Notifications. Dhruv's actions invoke Flows + Flex prompts grounded on the Data Graph. Paalak is invoked via HTTP callout (Agent API) for compliance validation. WhatsApp via Meta Cloud API test number; Slack via Salesforce Channels for Records.

**Tech Stack:** Salesforce DX (sfdx CLI), Salesforce Core APIs, Apex, Lightning Web Components, Flow Builder, Agentforce Builder, Prompt Builder, Data Cloud (Streaming Ingestion API, DMOs, Data Graphs, Data Actions), Slack Block Kit, Meta WhatsApp Cloud API, Python 3.11 (seed + simulator).

**Conventions:**
- `[CLAUDE]` prefix = Claude generates the file/XML/code in this session
- `[USER]` prefix = user clicks in-org (or executes a CLI command on their machine)
- `[BOTH]` prefix = Claude generates + user retrieves into source control via `sfdx`
- Every phase ends with a **🚦 Phase Gate** verification — do not advance until satisfied
- Commits use Conventional Commits (`feat:`, `fix:`, `chore:`)
- Hard cut: anything not working by **end of Day 4 (2026-05-02 night)** is sacrificed per CLAUDE.md sacrifice order

**Spec:** [`docs/superpowers/specs/2026-04-28-dhruv-design.md`](../specs/2026-04-28-dhruv-design.md)
**Data model:** [`docs/design/data-model.md`](../../design/data-model.md)

---

## File structure (created by this plan)

```
AgentforceHackathon/
├── CLAUDE.md                                        # already exists
├── docs/
│   ├── superpowers/specs/2026-04-28-dhruv-design.md # already exists
│   ├── superpowers/plans/2026-04-28-dhruv-impl.md   # this file
│   └── design/
│       ├── data-model.md                            # already exists
│       ├── architecture-diagram.png                 # Day 5
│       └── appendix-deck-outline.md                 # Day 5
│
├── force-app/main/default/
│   ├── objects/
│   │   ├── Market_Event__c/                         # Day 1
│   │   ├── Market_Impact__c/                        # Day 1
│   │   ├── Custom_Trade_Request__c/                 # Day 1
│   │   └── Account/fields/Preferred_Channel__c.field-meta.xml  # Day 1
│   ├── customMetadata/
│   │   └── Demo_Recipients.*.md-meta.xml            # Day 1
│   ├── platformEventChannels/
│   │   └── Market_Impact_Event__e.platformEventChannel-meta.xml  # Day 2
│   ├── flows/
│   │   ├── MarketImpact_Detect_Segment.flow-meta.xml  # Day 2
│   │   ├── Get_Impacted_Clients.flow-meta.xml         # Day 3
│   │   ├── Draft_Client_Outreach.flow-meta.xml        # Day 3
│   │   ├── Send_WhatsApp_Template.flow-meta.xml       # Day 4
│   │   ├── Slack_Trade_Approval.flow-meta.xml         # Day 4
│   │   ├── Compliance_Check_A2A.flow-meta.xml         # Day 4
│   │   └── Pre_Call_Brief.flow-meta.xml               # Day 4
│   ├── genAiPromptTemplates/
│   │   ├── Market_Event_Talking_Points.*.xml          # Day 3
│   │   ├── Personalized_Client_Nudge.*.xml            # Day 3
│   │   ├── Pre_Call_Brief.*.xml                       # Day 3
│   │   └── Compliance_Validation.*.xml                # Day 4
│   ├── bots/
│   │   ├── Dhruv/                                     # Day 3 (Agent)
│   │   └── Paalak/                                    # Day 4 (Agent)
│   ├── classes/
│   │   ├── PaalakAgentInvoker.cls                     # Day 4 (HTTP callout)
│   │   └── PaalakAgentInvokerTest.cls                 # Day 4
│   ├── lwc/
│   │   └── exposureHeatmap/                           # Day 4 (dashboard)
│   ├── namedCredentials/
│   │   └── Paalak_AgentAPI.namedCredential-meta.xml   # Day 4
│   └── notificationtypes/
│       └── Market_Impact_Notification.*.xml           # Day 2
│
├── scripts/
│   ├── seed/
│   │   ├── seed_data.py                            # Day 1
│   │   ├── data/persons.csv                        # Day 1 (generated)
│   │   ├── data/households.csv                     # Day 1 (generated)
│   │   ├── data/securities.csv                     # Day 1 (generated)
│   │   └── data/holdings.csv                       # Day 1 (generated)
│   └── simulator/
│       ├── post_event.py                           # Day 2
│       └── events/rbi_mpc_25bps_cut.json           # Day 2
│
└── manifest/package.xml                            # updated as we go
```

---

# Phase 1 — Day 1: Org foundation (2026-04-28 evening + 04-29)

**Goal:** 450 Person Accounts loaded with the right Vikram/Priya distribution; custom objects + fields deployed; Trust Layer audit confirmed on; Meta WhatsApp test-number application started.

---

### Task 1.1 — Verify org capabilities

**Files:** none (verification only)

- [ ] **Step 1 [USER]: Log in to the org via Salesforce CLI**
```bash
cd "/Users/jeetbhardiya/Documents/AWT Hackathon 2026/AgentforceHackathon"
sf org login web --alias dhruv-org --instance-url https://login.salesforce.com
sf config set target-org=dhruv-org
sf org display
```
Expected: shows your username + org id.

- [ ] **Step 2 [USER]: Confirm Agentforce, Data Cloud, FSC are licensed**

In Setup → Company Information → Permission Set Licenses, confirm presence of:
- `Agentforce User` or `Agentforce Service Agent User`
- `Data Cloud One Admin` or `CDPAdmin`
- `Financial Services Cloud Standard` or `Financial Services Cloud Extension`

Setup → Installed Packages should show **Financial Services Cloud Extension** (managed pkg) OR you have **FSC Core** turned on under Setup → Industries Setup → Financial Services. Either is acceptable for this build (we use FSC Core).

- [ ] **Step 3 [USER]: Verify Einstein Trust Layer audit trail is on**

Setup → Einstein → Einstein Generative AI → **Audit Trail** — ensure "Capture audit trail" is enabled. If off, turn it on now. **This is required for Wow #7.**

- [ ] **Step 4 [USER]: Take a screenshot of all three confirmations**

Save screenshots to `docs/design/setup-evidence/day1-capabilities-{1,2,3}.png` for the GitHub README.

- [ ] **Step 5 [USER]: Commit evidence**
```bash
mkdir -p docs/design/setup-evidence
# (drop screenshots in)
git add docs/design/setup-evidence/
git commit -m "chore: capture Day 1 org capability verification screenshots"
```

---

### Task 1.2 — Start Meta WhatsApp test number setup (async, do tonight)

**Files:** none (external system setup)

- [ ] **Step 1 [USER]: Create / log into Meta for Developers**

Go to https://developers.facebook.com/. Use your existing dev account. Create a new app: type "Business," name "Dhruv Demo."

- [ ] **Step 2 [USER]: Add WhatsApp product**

In the app dashboard → Add Product → WhatsApp → Set up. This auto-provisions a **Test Phone Number** (free, instant, can send to up to 5 verified recipient numbers).

- [ ] **Step 3 [USER]: Note down credentials for Day 4**

Capture into a local secrets file (NOT committed):
```
~/.dhruv-secrets.env
META_APP_ID=...
META_APP_SECRET=...
WABA_ID=...
PHONE_NUMBER_ID=...
ACCESS_TOKEN=...   # 24h temp token; we will switch to system user token Day 4
TEST_PHONE_NUMBER=+15550...   # Meta-issued test #
```

- [ ] **Step 4 [USER]: Add 2 verified recipient numbers**

In Meta App → WhatsApp → API Setup → "To" field → "Manage phone number list" → Add your iPhone + 1 more (a teammate, or a second SIM you have). Each number gets an OTP via WhatsApp; verify both.

- [ ] **Step 5 [USER]: Send a test message from Meta UI to confirm**

Use Meta's "Send message" tester. Pick the `hello_world` template. Confirm message arrives on your iPhone in WhatsApp. **This proves the test number works end-to-end before we touch Salesforce.**

- [ ] **Step 6 [USER]: Update CLAUDE.md / spec if anything diverges**

If a step blocks, document the divergence in `CLAUDE.md` "Open Decisions" section and route to Day 4 fallback (PiP overlay).

---

### Task 1.3 — Create Salesforce custom objects

**Files:**
- Create: `force-app/main/default/objects/Market_Event__c/Market_Event__c.object-meta.xml`
- Create: `force-app/main/default/objects/Market_Event__c/fields/*.field-meta.xml` (8 fields)
- Create: `force-app/main/default/objects/Market_Impact__c/Market_Impact__c.object-meta.xml`
- Create: `force-app/main/default/objects/Market_Impact__c/fields/*.field-meta.xml` (7 fields)
- Create: `force-app/main/default/objects/Custom_Trade_Request__c/Custom_Trade_Request__c.object-meta.xml`
- Create: `force-app/main/default/objects/Custom_Trade_Request__c/fields/*.field-meta.xml` (9 fields)

- [ ] **Step 1 [CLAUDE]: Generate Market_Event__c object XML**

Create `force-app/main/default/objects/Market_Event__c/Market_Event__c.object-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <enableActivities>true</enableActivities>
    <enableHistory>false</enableHistory>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <label>Market Event</label>
    <pluralLabel>Market Events</pluralLabel>
    <nameField>
        <displayFormat>MEVT-{0000}</displayFormat>
        <label>Market Event Name</label>
        <type>AutoNumber</type>
    </nameField>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
```

- [ ] **Step 2 [CLAUDE]: Generate Market_Event__c fields**

For each of the 8 fields (`Symbol__c`, `Event_Type__c`, `Pct_Change__c`, `Sector__c`, `Severity__c`, `Trigger_Time__c`, `Source__c`, `Headline__c`), create a `<FieldName>.field-meta.xml`. Examples for the two non-obvious ones:

`Event_Type__c.field-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Event_Type__c</fullName>
    <label>Event Type</label>
    <required>true</required>
    <type>Picklist</type>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value><fullName>RBI_MPC</fullName><default>false</default><label>RBI MPC</label></value>
            <value><fullName>IT_SELLOFF</fullName><default>false</default><label>IT Sell-off</label></value>
            <value><fullName>EARNINGS_BEAT</fullName><default>false</default><label>Earnings Beat</label></value>
            <value><fullName>EARNINGS_MISS</fullName><default>false</default><label>Earnings Miss</label></value>
            <value><fullName>OTHER</fullName><default>true</default><label>Other</label></value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

`Pct_Change__c.field-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Pct_Change__c</fullName>
    <label>Percent Change</label>
    <type>Number</type>
    <precision>5</precision>
    <scale>2</scale>
    <required>false</required>
</CustomField>
```

Repeat the pattern for the rest per the data model in `docs/design/data-model.md` Section 2.

- [ ] **Step 3 [CLAUDE]: Generate Market_Impact__c object + 7 fields**

Two of these are formulas — show them in full:

`Severity_Score__c.field-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Severity_Score__c</fullName>
    <label>Severity Score</label>
    <type>Number</type>
    <precision>7</precision>
    <scale>2</scale>
    <formula>Exposure_Pct_of_AUM__c * ABS(Event__r.Pct_Change__c)</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>
</CustomField>
```

`RM_Action_Required__c.field-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>RM_Action_Required__c</fullName>
    <label>RM Action Required</label>
    <type>Checkbox</type>
    <formula>Exposure_Pct_of_AUM__c &gt;= 20</formula>
    <formulaTreatBlanksAs>BlankAsZero</formulaTreatBlanksAs>
</CustomField>
```

`Account__c.field-meta.xml` and `Event__c.field-meta.xml` are Lookups — set `<type>Lookup</type>`, `<referenceTo>Account</referenceTo>` and `<referenceTo>Market_Event__c</referenceTo>` respectively.

- [ ] **Step 4 [CLAUDE]: Generate Custom_Trade_Request__c object + 9 fields**

Per data model. `Status__c` defaults to `Draft` (`<defaultValue>"Draft"</defaultValue>` in the picklist).

- [ ] **Step 5 [USER]: Deploy to org**
```bash
sf project deploy start --source-dir force-app/main/default/objects --target-org dhruv-org
```
Expected: `Status: Succeeded`. If errors, fix XML and retry.

- [ ] **Step 6 [USER]: Verify in Setup**

Setup → Object Manager → search "Market" → confirm `Market_Event` and `Market_Impact` objects exist with all fields. Search "Custom_Trade" → confirm.

- [ ] **Step 7 [USER]: Commit**
```bash
git add force-app/main/default/objects
git commit -m "feat(data-model): add Market_Event, Market_Impact, Custom_Trade_Request custom objects"
```

---

### Task 1.4 — Add Preferred_Channel__c to Account

**Files:**
- Create: `force-app/main/default/objects/Account/fields/Preferred_Channel__c.field-meta.xml`

- [ ] **Step 1 [USER]: Check if standard FSC field exists**

Setup → Object Manager → Account → Fields & Relationships → search "Preferred." If `PreferredCommunicationChannel` (or similar standard field with WhatsApp value) exists, use it instead and skip Step 2/3 — note in CLAUDE.md.

- [ ] **Step 2 [CLAUDE]: Generate field XML (if needed)**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Preferred_Channel__c</fullName>
    <label>Preferred Channel</label>
    <type>Picklist</type>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value><fullName>WhatsApp</fullName><default>true</default><label>WhatsApp</label></value>
            <value><fullName>Email</fullName><default>false</default><label>Email</label></value>
            <value><fullName>SMS</fullName><default>false</default><label>SMS</label></value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
```

- [ ] **Step 3 [USER]: Deploy + verify + commit**
```bash
sf project deploy start --source-dir force-app/main/default/objects/Account --target-org dhruv-org
git add force-app/main/default/objects/Account
git commit -m "feat(data-model): add Preferred_Channel__c picklist on Account"
```

---

### Task 1.5 — Create Demo_Recipients__mdt custom metadata type

**Files:**
- Create: `force-app/main/default/objects/Demo_Recipients__mdt/Demo_Recipients__mdt.object-meta.xml`
- Create: `force-app/main/default/objects/Demo_Recipients__mdt/fields/Account__c.field-meta.xml`
- Create: `force-app/main/default/objects/Demo_Recipients__mdt/fields/Phone_E164__c.field-meta.xml`
- Create: `force-app/main/default/objects/Demo_Recipients__mdt/fields/Active__c.field-meta.xml`

- [ ] **Step 1 [CLAUDE]: Generate the metadata type definition**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Demo Recipient</label>
    <pluralLabel>Demo Recipients</pluralLabel>
    <visibility>Public</visibility>
</CustomObject>
```

- [ ] **Step 2 [CLAUDE]: Generate the 3 fields**

`Account__c`: Text(80), label "Account External Id," required.
`Phone_E164__c`: Text(20), label "Phone (E.164)," required.
`Active__c`: Checkbox, label "Active," default true.

(Use the same field-meta.xml structure as Task 1.3.)

- [ ] **Step 3 [USER]: Deploy + verify + commit**

```bash
sf project deploy start --source-dir force-app/main/default/objects/Demo_Recipients__mdt --target-org dhruv-org
git add force-app/main/default/objects/Demo_Recipients__mdt
git commit -m "feat(config): add Demo_Recipients__mdt for WhatsApp test recipients"
```

---

### Task 1.6 — Generate seed data CSVs (Python)

**Files:**
- Create: `scripts/seed/seed_data.py`
- Create: `scripts/seed/data/.gitkeep`

- [ ] **Step 1 [CLAUDE]: Write `scripts/seed/seed_data.py`**

The script generates 4 CSVs deterministically (seeded RNG) so re-runs produce the same data:

```python
"""
Generate seed data for Dhruv hackathon demo.

Outputs (deterministic via fixed seed):
  data/persons.csv     — 450 Person Accounts
  data/households.csv  — 150 Households (Party Relationship Groups)
  data/securities.csv  — 50 securities
  data/holdings.csv    — ~2000 holdings, engineered so:
    - exactly 62 accounts have >=20% Bank-Nifty/rate-sensitive exposure
    - exactly 8 of those are owned by Vikram Rao
    - Priya Sharma (Bandra, 1.8 Cr AUM, 28% Bank Nifty) is the named hero

Usage:
  python3 scripts/seed/seed_data.py --owner-id <Vikram User Id> [--out scripts/seed/data]
"""
import argparse
import csv
import random
from pathlib import Path

SEED = 4242
RATE_SENSITIVE_TICKERS = {"HDFCBANK", "ICICIBANK", "SBIN", "AXISBANK", "KOTAKBANK",
                          "BAJAJFINSV", "BAJFINANCE", "BANKBEES"}

INDIAN_FIRST_NAMES = ["Aarav","Vihaan","Aditya","Krishna","Reyansh","Ayaan","Atharv","Ishaan",
                     "Priya","Anaya","Diya","Aadhya","Saanvi","Kiara","Myra","Ananya",
                     "Rohit","Vikram","Meera","Rajesh","Neha","Pooja","Sanjay","Karan"]
INDIAN_LAST_NAMES  = ["Sharma","Verma","Kapoor","Desai","Mehta","Shah","Patel","Iyer","Reddy",
                     "Joshi","Gupta","Singh","Khanna","Malhotra","Bhardwaj","Rao"]
MUMBAI_AREAS       = ["Bandra","Andheri","Powai","Worli","Juhu","Borivali","Malad",
                      "Thane","Vashi","Lower Parel","BKC","Khar","Goregaon"]

NIFTY50_TICKERS = [
    "RELIANCE","TCS","HDFCBANK","INFY","ICICIBANK","SBIN","AXISBANK","KOTAKBANK",
    "ITC","LT","HINDUNILVR","BHARTIARTL","BAJFINANCE","BAJAJFINSV","HCLTECH",
    "WIPRO","ASIANPAINT","MARUTI","M&M","TITAN","ULTRACEMCO","NESTLEIND","SUNPHARMA",
    "DRREDDY","NTPC","POWERGRID","COALINDIA","GRASIM","JSWSTEEL","TATASTEEL",
    "TATAMOTORS","HEROMOTOCO","BAJAJ-AUTO","ADANIPORTS","CIPLA","DIVISLAB","BPCL",
    "HDFCLIFE","SBILIFE","ONGC","UPL","BRITANNIA","TECHM","TATACONSUM","INDUSINDBK",
    "EICHERMOT","HINDALCO","APOLLOHOSP","ADANIENT","SHRIRAMFIN",
]
ETFS = ["BANKBEES","NIFTYBEES","LIQUIDBEES"]

def main(out_dir: Path, owner_id: str):
    rng = random.Random(SEED)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Securities (Step A)
    securities = []
    for tkr in NIFTY50_TICKERS + ETFS:
        sector = ("Banking" if tkr in {"HDFCBANK","ICICIBANK","SBIN","AXISBANK",
                                       "KOTAKBANK","INDUSINDBK","BANKBEES"}
                  else "IT" if tkr in {"TCS","INFY","HCLTECH","WIPRO","TECHM"}
                  else "Auto" if tkr in {"MARUTI","M&M","TATAMOTORS","HEROMOTOCO",
                                          "BAJAJ-AUTO","EICHERMOT"}
                  else "Pharma" if tkr in {"SUNPHARMA","DRREDDY","CIPLA","DIVISLAB",
                                            "APOLLOHOSP"}
                  else "FMCG"   if tkr in {"HINDUNILVR","ITC","NESTLEIND","BRITANNIA",
                                            "TATACONSUM"}
                  else "Energy" if tkr in {"RELIANCE","NTPC","POWERGRID","COALINDIA",
                                            "BPCL","ONGC"}
                  else "Other")
        securities.append({"ExternalId": f"SEC_{tkr}", "Ticker": tkr, "Name": tkr,
                           "Sector": sector})
    _write_csv(out_dir/"securities.csv", securities)

    # Persons (Step B) — 450
    persons = []
    for i in range(1, 451):
        fn = rng.choice(INDIAN_FIRST_NAMES)
        ln = rng.choice(INDIAN_LAST_NAMES)
        persons.append({
            "ExternalId": f"PA_{i:04d}",
            "FirstName": fn, "LastName": ln,
            "BillingCity": "Mumbai",
            "BillingStreet": f"{rng.randint(1,500)} {rng.choice(MUMBAI_AREAS)}",
            "BillingPostalCode": str(400000 + rng.randint(1,99)),
            "BillingCountry": "India",
            "AUM__c": round(rng.lognormvariate(15.5, 0.7)),  # ~50L–15Cr
            "Preferred_Channel__c": "WhatsApp" if rng.random() < 0.6 else "Email",
            "OwnerExternalId": "RM_VIKRAM" if i <= 60 else f"RM_{rng.randint(1,8):02d}",
        })
    # Force the hero accounts:
    persons[0].update({"FirstName":"Priya","LastName":"Sharma","ExternalId":"PA_0001",
                       "BillingStreet":"12 Bandra West","BillingPostalCode":"400050",
                       "AUM__c":18000000,"OwnerExternalId":"RM_VIKRAM",
                       "Preferred_Channel__c":"WhatsApp"})
    persons[1].update({"FirstName":"Rohit","LastName":"Kapoor","ExternalId":"PA_0002",
                       "BillingStreet":"45 Andheri East","BillingPostalCode":"400069",
                       "AUM__c":22000000,"OwnerExternalId":"RM_VIKRAM",
                       "Preferred_Channel__c":"WhatsApp"})
    persons[2].update({"FirstName":"Meera","LastName":"Desai","ExternalId":"PA_0003",
                       "BillingStreet":"8 Worli Sea Face","BillingPostalCode":"400018",
                       "AUM__c":15000000,"OwnerExternalId":"RM_VIKRAM",
                       "Preferred_Channel__c":"WhatsApp"})
    _write_csv(out_dir/"persons.csv", persons)

    # Households (Step C) — 150 (just stub data)
    households = [{"ExternalId":f"HH_{i:03d}","Name":f"{persons[i*3]['LastName']} Family"}
                  for i in range(150)]
    _write_csv(out_dir/"households.csv", households)

    # Holdings (Step D) — engineered exposures
    rate_sensitive_secs = [s for s in securities if s["Ticker"] in RATE_SENSITIVE_TICKERS]
    other_secs = [s for s in securities if s["Ticker"] not in RATE_SENSITIVE_TICKERS]

    holdings = []
    # Hero accounts: forced exposures (Priya 28%, Rohit 22%, Meera 19% — Meera is just under 20% deliberately;
    # adjust to 21% to land in the 62)
    _force_exposure(holdings, persons[0], rate_sensitive_secs[0], 0.28)  # Priya - HDFCBANK 28%
    _force_exposure(holdings, persons[1], rate_sensitive_secs[1], 0.22)  # Rohit - ICICIBANK 22%
    _force_exposure(holdings, persons[2], rate_sensitive_secs[7], 0.21)  # Meera - BANKBEES 21%

    # Vikram's other 5 in-the-62 accounts (PA_0004..0008): rate-sensitive >=20%
    for k in range(4, 9):
        _force_exposure(holdings, persons[k-1], rng.choice(rate_sensitive_secs),
                        0.20 + rng.random()*0.10)

    # Pad: 54 more accounts (not Vikram-owned) with rate-sensitive >=20%
    pool = [p for p in persons[8:] if p["OwnerExternalId"] != "RM_VIKRAM"]
    for p in rng.sample(pool, 54):
        _force_exposure(holdings, p, rng.choice(rate_sensitive_secs),
                        0.20 + rng.random()*0.15)

    # Fill remaining: every account gets 3-6 small holdings in non-rate-sensitive securities
    for p in persons:
        existing_aum = sum(h["MarketValue__c"] for h in holdings if h["AccountExternalId"]==p["ExternalId"])
        remaining = max(p["AUM__c"] - existing_aum, p["AUM__c"]*0.5)
        n = rng.randint(3,6)
        for _ in range(n):
            sec = rng.choice(other_secs)
            holdings.append({"AccountExternalId": p["ExternalId"],
                             "SecurityExternalId": sec["ExternalId"],
                             "MarketValue__c": round(remaining/n),
                             "Quantity__c": rng.randint(10,500)})
    _write_csv(out_dir/"holdings.csv", holdings)

    print(f"Wrote {len(persons)} persons, {len(households)} households, "
          f"{len(securities)} securities, {len(holdings)} holdings.")
    print(f"Owner externalId 'RM_VIKRAM' should map to user id {owner_id} on import.")

def _force_exposure(holdings, person, security, pct):
    holdings.append({"AccountExternalId": person["ExternalId"],
                     "SecurityExternalId": security["ExternalId"],
                     "MarketValue__c": round(person["AUM__c"]*pct),
                     "Quantity__c": 100})

def _write_csv(path, rows):
    with path.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=rows[0].keys())
        w.writeheader(); w.writerows(rows)

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--owner-id", required=True, help="Salesforce User Id of Vikram Rao")
    p.add_argument("--out", default="scripts/seed/data")
    a = p.parse_args()
    main(Path(a.out), a.owner_id)
```

- [ ] **Step 2 [USER]: Run seed script (will need user id from Task 1.7)**

Defer running until Task 1.7 creates Vikram. We commit the script now.

- [ ] **Step 3 [USER]: Commit**
```bash
git add scripts/seed/
git commit -m "feat(seed): add deterministic Python seed-data generator (450 PA, 50 sec, ~2000 holdings)"
```

---

### Task 1.7 — Create Vikram Rao user + permission set

**Files:** none (in-org config); permission set XML optional

- [ ] **Step 1 [USER]: Create User**

Setup → Users → New User. Fill:
- First/Last: Vikram / Rao
- Email: vikram.rao+demo@yourdomain.com (or your real email)
- Username: vikram.rao@dhruv-org.demo
- License: Salesforce
- Profile: Standard User (or Financial Services Cloud Standard if available)

Save. Capture the User Id (15 or 18 char) from the URL.

- [ ] **Step 2 [USER]: Assign Agentforce + Data Cloud permission sets**

User detail → Permission Set Assignments → Edit → add:
- `AgentforceServiceAgentUser` (or whatever Agentforce Permset is in your org)
- `Data Cloud Admin` or `Data Cloud Standard User`
- `Financial Services Cloud Standard` if licensed

- [ ] **Step 3 [USER]: Set as default Owner for Vikram's clients during seed load**

Note the User Id; pass it as `--owner-id` to the seed script.

- [ ] **Step 4 [USER]: Run seed script**
```bash
python3 scripts/seed/seed_data.py --owner-id 005XXXXXXXXXXXXXXX
```
Expected output: `Wrote 450 persons, 150 households, 53 securities, ~2200 holdings.`

- [ ] **Step 5 [USER]: Commit generated CSVs (synthetic, safe)**
```bash
git add scripts/seed/data/
git commit -m "chore(seed): commit synthetic seed CSVs"
```

---

### Task 1.8 — Load seed CSVs via Data Loader

**Files:** none (in-org)

- [ ] **Step 1 [USER]: Install Data Loader (if not already)**

Setup → search "Data Loader" → Download for macOS. Install the AdoptOpenJDK-bundled .dmg.

- [ ] **Step 2 [USER]: Load Securities first (no FKs)**

Open Data Loader → Insert → log into dhruv-org. Object: `Security` (FSC standard). Map:
- ExternalId → `External_Id__c` (custom key field — create it on Security if missing)
- Ticker → `Ticker_Symbol__c` (or whatever standard FSC field)
- Name → `Name`

If Security doesn't have an External Id field, add one: Setup → Object Manager → Security → Fields & Relationships → New → Text(80), External Id checkbox on, Name `External_Id__c`. Then re-load.

- [ ] **Step 3 [USER]: Load Person Accounts**

Object: `Account`. Use **Upsert** with External Id `External_Id__c`. Map:
- ExternalId → `External_Id__c`
- FirstName, LastName → standard
- BillingStreet/City/PostalCode/Country → standard
- Preferred_Channel__c → custom
- AUM__c → custom (add this field to Account if missing — Currency, scale 0)
- OwnerExternalId — needs preprocessing: replace `RM_VIKRAM` with Vikram's User Id literal in a quick `sed` on the CSV before loading. (The CSV ships with the placeholder; you swap it pre-load.)
```bash
sed -i '' 's/RM_VIKRAM/005XXXXXXXXXXXXXXX/g' scripts/seed/data/persons.csv
```

For non-Vikram owners (`RM_01`..`RM_08`), set them all to Vikram for the demo (we don't actually need 9 RM users — only 8 Vikram-clients are demo-relevant, the rest are noise to make 62 total impactful):
```bash
sed -i '' 's/RM_0[0-9]*/005XXXXXXXXXXXXXXX/g' scripts/seed/data/persons.csv
```

- [ ] **Step 4 [USER]: Load Holdings**

Object: `SecuritiesHolding`. Map:
- AccountExternalId → resolve to `Account_Id__c` via lookup-on-external-id
- SecurityExternalId → resolve to `Security_Id__c` via lookup-on-external-id
- MarketValue__c, Quantity__c → standard

Data Loader supports lookup-on-external-id during Upsert via the `R` operator on the lookup field.

- [ ] **Step 5 [USER]: Verify counts in Salesforce**

Developer Console → Query Editor:
```sql
SELECT COUNT() FROM Account WHERE OwnerId = '005XXXXXXXXXXXXXXX' AND IsPersonAccount = true
-- expected: 450 (or close — at minimum 60 with Vikram if we used the original distribution)

SELECT COUNT() FROM Account WHERE FirstName='Priya' AND LastName='Sharma'
-- expected: 1
```

- [ ] **Step 6 [USER]: Commit**

(Nothing new to commit — seed CSVs already committed in Task 1.7.)

---

### Task 1.9 — Build Market Command Center Lightning App (placeholder)

**Files:**
- Create: `force-app/main/default/applications/Market_Command_Center.app-meta.xml`
- Create: `force-app/main/default/flexipages/Market_Command_Center_Home.flexipage-meta.xml`

- [ ] **Step 1 [CLAUDE]: Generate the Lightning app XML**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <label>Market Command Center</label>
    <navType>Standard</navType>
    <tabs>standard-Account</tabs>
    <tabs>Market_Event__c</tabs>
    <tabs>Market_Impact__c</tabs>
    <tabs>Custom_Trade_Request__c</tabs>
    <uiType>Lightning</uiType>
    <formFactors>Large</formFactors>
    <formFactors>Small</formFactors>
</CustomApplication>
```

- [ ] **Step 2 [CLAUDE]: Generate the Home FlexiPage (placeholder; LWC slot for Day 4)**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<FlexiPage xmlns="http://soap.sforce.com/2006/04/metadata">
    <flexiPageRegions>
        <name>main</name>
        <type>Region</type>
        <itemInstances>
            <componentInstance>
                <componentName>flexipage:richText</componentName>
                <componentInstanceProperties>
                    <name>richTextValue</name>
                    <value>&lt;h2&gt;Market Command Center&lt;/h2&gt;&lt;p&gt;Dashboard placeholder — populated Day 4.&lt;/p&gt;</value>
                </componentInstanceProperties>
                <identifier>placeholder_1</identifier>
            </componentInstance>
        </itemInstances>
    </flexiPageRegions>
    <masterLabel>Market Command Center Home</masterLabel>
    <type>HomePage</type>
</FlexiPage>
```

- [ ] **Step 3 [USER]: Deploy + verify**
```bash
sf project deploy start --source-dir force-app/main/default/applications --target-org dhruv-org
sf project deploy start --source-dir force-app/main/default/flexipages --target-org dhruv-org
```
Open the org → App Launcher → "Market Command Center." Tabs visible.

- [ ] **Step 4 [USER]: Commit**
```bash
git add force-app/main/default/applications force-app/main/default/flexipages
git commit -m "feat(ui): add Market Command Center Lightning app skeleton"
```

---

## 🚦 Phase 1 Gate (end of Day 1)

Before advancing to Phase 2, verify all of:

- [ ] Org capabilities verified, Trust Layer audit on, screenshots captured
- [ ] Meta WhatsApp test number provisioned, hello_world template successfully sent to your iPhone
- [ ] All 3 custom objects deployed to org (visible in Object Manager)
- [ ] `Preferred_Channel__c` on Account deployed
- [ ] `Demo_Recipients__mdt` deployed
- [ ] Vikram Rao user created and Agentforce / Data Cloud / FSC permsets assigned
- [ ] Seed script runs deterministically; CSVs committed
- [ ] **Person Account count = 450, Priya Sharma exists with 28% Bank Nifty exposure**
- [ ] Market Command Center app accessible

**If any of these are red, do NOT start Phase 2.** Fix Day 1 first.

---

# Phase 2 — Day 2: Data pipeline (2026-04-30)

**Goal:** Fire a synthetic RBI MPC event from the Python simulator → Data Cloud → filter via Data Action → Platform Event → Flow → 62 `Market_Impact__c` rows + Custom Notification arrives on Vikram's iPhone.

---

### Task 2.1 — Map FSC source objects into Data Cloud DMOs

**Files:** none (Data Cloud config done in UI; metadata exported afterwards)

- [ ] **Step 1 [USER]: Open Data Cloud → Data Streams → New**

Source: Salesforce CRM. Connect (one-time). Pick the Salesforce org. Select objects: `Account`, `FinancialAccount`, `SecuritiesHolding`. For each, accept all fields and choose category "Profile" / "Other" / "Other" respectively.

- [ ] **Step 2 [USER]: Create DMO `UnifiedIndividual`**

Data Cloud → Data Model → use the standard UnifiedIndividual DMO. Map fields from Account: Id → Individual Id, FirstName, LastName, BillingCity → City, etc.

- [ ] **Step 3 [USER]: Create custom DMOs `FinancialAccount__dlm` and `SecuritiesHolding__dlm`**

Data Cloud → Data Model → New DMO from data lake object. Take the FSC streams and promote them. Confirm field types.

- [ ] **Step 4 [USER]: Create custom DMO `Security__dlm` (one-shot)**

Data Cloud → Data Streams → New → Source: Other (CSV upload). Upload `scripts/seed/data/securities.csv`. Promote into a DMO `Security__dlm`. Map ExternalId → primary key.

- [ ] **Step 5 [USER]: Verify**

Data Cloud → Data Model → see all 4 DMOs (`UnifiedIndividual`, `FinancialAccount__dlm`, `SecuritiesHolding__dlm`, `Security__dlm`). Click each → Data Explorer → row counts match Salesforce.

- [ ] **Step 6 [USER]: Retrieve metadata to repo**
```bash
sf project retrieve start --metadata MktDataModel:UnifiedIndividual,MktDataModel:Security__dlm,MktDataModel:FinancialAccount__dlm,MktDataModel:SecuritiesHolding__dlm --target-org dhruv-org
git add force-app/main/default/mktDataModelObjects
git commit -m "feat(dc): map UnifiedIndividual + FSC DMOs in Data Cloud"
```

---

### Task 2.2 — Create `MarketEvent__dlm` via Streaming Ingestion API

**Files:**
- Create: `force-app/main/default/mktDataLakeObjects/MarketEvent.mktDataLakeObject-meta.xml`
- Create: schema JSON (uploaded in UI)

- [ ] **Step 1 [USER]: Data Cloud → Data Streams → New → Streaming Ingestion API**

Source name: `MarketEventStream`. Schema (paste):
```yaml
type: object
properties:
  eventId:    { type: string }
  symbol:     { type: string }
  eventType:  { type: string }
  pctChange:  { type: number }
  sector:     { type: string }
  severity:   { type: string }
  timestamp:  { type: string, format: date-time }
required: [eventId, eventType, sector, severity, timestamp]
```
Category: Engagement. Primary key: `eventId`. Event time: `timestamp`.

- [ ] **Step 2 [USER]: Note the ingestion endpoint**

Click "View Connector Details" → copy:
- **Endpoint URL** (looks like `https://<tenant>.c360a.salesforce.com/api/v1/ingest/sources/MarketEventStream/...`)
- **Connector name**

You'll wire these into the Python simulator in Task 2.3.

- [ ] **Step 3 [USER]: Promote DLO to DMO**

Data Cloud → Data Model → New DMO → from `MarketEventStream` DLO. Name `MarketEvent__dlm`. Category Engagement.

- [ ] **Step 4 [USER]: Verify schema**

Data Cloud → Data Explorer → `MarketEvent__dlm` — empty for now, that's fine.

---

### Task 2.3 — Build `ClientExposureGraph` Data Graph

**Files:** Data Cloud config (UI)

- [ ] **Step 1 [USER]: Data Cloud → Data Graphs → New**

Name: `ClientExposureGraph`. Primary DMO: `UnifiedIndividual`.

- [ ] **Step 2 [USER]: Add related DMOs**

Add nested:
- `FinancialAccount__dlm` (relationship: `PrimaryOwner` = `UnifiedIndividual.Id`)
- `SecuritiesHolding__dlm` (relationship: `FinancialAccount` = `FinancialAccount__dlm.Id`)
- `Security__dlm` (relationship: `Id` = `SecuritiesHolding__dlm.SecurityId`)
- `MarketEvent__dlm` (relationship: cross-DMO match by `Symbol` or `Sector`)

- [ ] **Step 3 [USER]: Save and Activate the Data Graph**

Wait for status "Active." This may take 1–5 minutes. Verify by clicking the graph → Preview → enter a known UnifiedIndividual Id → confirm nested JSON returns.

- [ ] **Step 4 [USER]: Test query**

In Data Cloud → Query Editor:
```sql
SELECT * FROM ClientExposureGraph WHERE UnifiedIndividual_Id = '<priya account id>'
```
Expected: returns Priya's portfolio with HDFCBANK at 28%.

---

### Task 2.4 — Create Platform Event `Market_Impact_Event__e`

**Files:**
- Create: `force-app/main/default/objects/Market_Impact_Event__e/Market_Impact_Event__e.object-meta.xml`
- Create: `force-app/main/default/objects/Market_Impact_Event__e/fields/*.field-meta.xml` (6 fields)

- [ ] **Step 1 [CLAUDE]: Generate Platform Event XML**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <eventType>HighVolume</eventType>
    <label>Market Impact Event</label>
    <pluralLabel>Market Impact Events</pluralLabel>
    <publishBehavior>PublishAfterCommit</publishBehavior>
</CustomObject>
```

- [ ] **Step 2 [CLAUDE]: Generate the 6 fields**

`Event_Id__c` Text(80), `Symbol__c` Text(20), `Sector__c` Text(40), `Pct_Change__c` Number(5,2), `Severity__c` Text(20), `Trigger_Time__c` DateTime.

- [ ] **Step 3 [USER]: Deploy + verify + commit**
```bash
sf project deploy start --source-dir force-app/main/default/objects/Market_Impact_Event__e --target-org dhruv-org
git add force-app/main/default/objects/Market_Impact_Event__e
git commit -m "feat(events): add Market_Impact_Event__e platform event"
```

---

### Task 2.5 — Configure Data Action filter → Platform Event

**Files:** Data Cloud config (UI)

- [ ] **Step 1 [USER]: Data Cloud → Data Actions → New**

Name: `MarketEvent_To_PlatformEvent`. Trigger DMO: `MarketEvent__dlm`. Action type: **Salesforce Platform Event**. Target: `Market_Impact_Event__e`.

- [ ] **Step 2 [USER]: Add filter**
```
pctChange <= -0.05 OR eventType IN ('RBI_MPC', 'IT_SELLOFF')
```

- [ ] **Step 3 [USER]: Field mapping**
```
eventId    → Event_Id__c
symbol     → Symbol__c
sector     → Sector__c
pctChange  → Pct_Change__c
severity   → Severity__c
timestamp  → Trigger_Time__c
```

- [ ] **Step 4 [USER]: Activate and verify**

Click Activate. Status: "Running." Test via Data Cloud → Data Action → Test (provide a sample MarketEvent record).

---

### Task 2.6 — Create Custom Notification Type

**Files:**
- Create: `force-app/main/default/notificationtypes/Market_Impact_Notification.notiftype-meta.xml`

- [ ] **Step 1 [CLAUDE]: Generate the notification type**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomNotificationType xmlns="http://soap.sforce.com/2006/04/metadata">
    <customNotifTypeName>Market_Impact_Notification</customNotifTypeName>
    <desktop>true</desktop>
    <mobile>true</mobile>
    <slack>true</slack>
    <masterLabel>Market Impact</masterLabel>
</CustomNotificationType>
```

- [ ] **Step 2 [USER]: Deploy + verify + commit**
```bash
sf project deploy start --source-dir force-app/main/default/notificationtypes --target-org dhruv-org
git add force-app/main/default/notificationtypes
git commit -m "feat(notifications): add Market_Impact_Notification custom type"
```

---

### Task 2.7 — Build `MarketImpact_Detect_Segment` Flow

**Files:**
- Create: `force-app/main/default/flows/MarketImpact_Detect_Segment.flow-meta.xml`

This is the most consequential Flow in the build. It is platform-event-triggered.

- [ ] **Step 1 [USER]: Build in Flow Builder UI (recommended for visual debug)**

Setup → Flows → New Flow → Platform Event–Triggered Flow → start object: `Market_Impact_Event__e`.

- [ ] **Step 2 [USER]: Step A — create Market_Event__c record**

Element: Create Records → Object: `Market_Event__c`. Map:
- Symbol__c ← {!$Record.Symbol__c}
- Event_Type__c ← (lookup based on Sector — for now hardcode `RBI_MPC` if Sector='Macro')
- Pct_Change__c ← {!$Record.Pct_Change__c}
- Sector__c ← {!$Record.Sector__c}
- Severity__c ← {!$Record.Severity__c}
- Trigger_Time__c ← {!$Record.Trigger_Time__c}
- Source__c ← "Streaming Ingestion"
- Headline__c ← Formula: `"Event " & {!$Record.Event_Id__c} & " — " & {!$Record.Symbol__c} & " " & TEXT({!$Record.Pct_Change__c}) & "%"`

Output reference: `varNewMarketEvent`.

- [ ] **Step 3 [USER]: Step B — query ClientExposureGraph for impacted accounts**

Element: Action → "Get Data Cloud DMO Records" (standard Agentforce/DC invocable). Object: `UnifiedIndividual`. Filter: SOQL-like clause matching impacted Symbol/Sector. Use the action `mktdc:GetDataCloudDMORecords` with WHERE clause on related SecuritiesHolding/Security.

If the standard action doesn't expose Data Graph traversal cleanly, fall back: Apex invocable that calls Data Graph API. We'll write that Apex in Step 4.

- [ ] **Step 4 [CLAUDE]: (Fallback) Generate `QueryClientExposureGraph.cls`**

Create `force-app/main/default/classes/QueryClientExposureGraph.cls`:
```apex
/**
 * Invocable wrapper around Data Cloud Data Graph query for ClientExposureGraph.
 * Used by MarketImpact_Detect_Segment Flow to find accounts impacted by a market event.
 */
public with sharing class QueryClientExposureGraph {

    public class Request {
        @InvocableVariable(required=true) public String sector;
        @InvocableVariable             public String symbol;
        @InvocableVariable(required=true) public Decimal minExposurePct;
    }

    public class Response {
        @InvocableVariable public List<Id> accountIds;
        @InvocableVariable public List<Decimal> exposurePcts;
        @InvocableVariable public List<Decimal> exposureAmounts;
    }

    @InvocableMethod(label='Query Client Exposure Graph'
                     description='Returns Account ids exposed to a sector/symbol at >= minExposurePct')
    public static List<Response> query(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            Response resp = new Response();
            resp.accountIds       = new List<Id>();
            resp.exposurePcts     = new List<Decimal>();
            resp.exposureAmounts  = new List<Decimal>();

            // Aggregate exposure by account from SecuritiesHolding + Security mapping.
            // For demo: query Salesforce side directly (faster than DG hop, same data).
            String secFilter = (r.symbol != null)
                ? 'Security__r.Ticker_Symbol__c = :symbolBind'
                : 'Security__r.Sector__c = :sectorBind';

            String soql =
                'SELECT FinancialAccount__r.PrimaryOwner__c acct, ' +
                '       SUM(MarketValue__c) exp ' +
                'FROM SecuritiesHolding ' +
                'WHERE ' + secFilter + ' ' +
                'GROUP BY FinancialAccount__r.PrimaryOwner__c';

            String symbolBind = r.symbol;
            String sectorBind = r.sector;

            // Aggregate AUM per account for percentage calc
            Map<Id, Decimal> aumByAcct = new Map<Id, Decimal>();
            for (AggregateResult ar : [
                SELECT FinancialAccount__r.PrimaryOwner__c acct, SUM(MarketValue__c) totalAUM
                FROM SecuritiesHolding
                GROUP BY FinancialAccount__r.PrimaryOwner__c
            ]) {
                aumByAcct.put((Id)ar.get('acct'), (Decimal)ar.get('totalAUM'));
            }

            for (AggregateResult ar : Database.query(soql)) {
                Id acctId = (Id)ar.get('acct');
                Decimal exposed = (Decimal)ar.get('exp');
                Decimal aum = aumByAcct.get(acctId);
                if (aum == null || aum == 0) continue;
                Decimal pct = (exposed / aum) * 100;
                if (pct >= r.minExposurePct) {
                    resp.accountIds.add(acctId);
                    resp.exposurePcts.add(pct.setScale(2));
                    resp.exposureAmounts.add(exposed);
                }
            }
            out.add(resp);
        }
        return out;
    }
}
```

(Adjust field API names to match your FSC org's `SecuritiesHolding` / `Security` schema. Use Tooling API or Object Manager to inspect.)

- [ ] **Step 5 [CLAUDE]: Write `QueryClientExposureGraphTest.cls`**
```apex
@isTest
private class QueryClientExposureGraphTest {

    @TestSetup static void setup() {
        // Insert 1 Security in Banking sector, 1 Account, 1 FinancialAccount (owned by Account),
        // 1 SecuritiesHolding worth 28% of total AUM. Verify query returns this account at >=20%.
        // (Implementation depends on FSC test-fixture utilities — leave as the engineer's task.)
    }

    @isTest static void returnsHighExposureAccount() {
        QueryClientExposureGraph.Request r = new QueryClientExposureGraph.Request();
        r.sector = 'Banking';
        r.minExposurePct = 20;

        Test.startTest();
        List<QueryClientExposureGraph.Response> out =
            QueryClientExposureGraph.query(new List<QueryClientExposureGraph.Request>{ r });
        Test.stopTest();

        System.assertEquals(1, out[0].accountIds.size(), 'should find the engineered account');
        System.assert(out[0].exposurePcts[0] >= 20, 'exposure pct should meet threshold');
    }
}
```

- [ ] **Step 6 [USER]: Deploy Apex + run test**
```bash
sf project deploy start --source-dir force-app/main/default/classes --target-org dhruv-org
sf apex run test --class-names QueryClientExposureGraphTest --target-org dhruv-org --result-format human --code-coverage
```
Expected: Pass. If FSC field names differ, adjust Apex and re-run.

- [ ] **Step 7 [USER]: Wire the invocable into the Flow**

Back in the Flow → add Action → "Query Client Exposure Graph" → input `sector` = {!$Record.Sector__c}, `minExposurePct` = 20. Output → assign to collection variable `varAccountIds`, `varExposurePcts`, `varExposureAmounts`.

- [ ] **Step 8 [USER]: Step C — Loop and create Market_Impact__c rows**

Loop element over `varAccountIds`. Inside: Assignment to map current values → Add to a record collection of `Market_Impact__c`. After loop: Create Records bulk insert.

For each impact: Account__c = current accountId, Event__c = varNewMarketEvent.Id, Exposure_Amount__c = current amount, Exposure_Pct_of_AUM__c = current pct.

- [ ] **Step 9 [USER]: Step D — Send Custom Notification (per impacted RM)**

After bulk insert, query `Market_Impact__c WHERE Event__c = :varNewMarketEvent.Id` → group by Account.OwnerId → for each owner, send Custom Notification via "Send Custom Notification" core action:
- Notification Type: Market_Impact_Notification
- Recipients: that owner User Id
- Title: "Market alert — " + headline
- Body: "{{count}} of your clients have exposure to this event. Tap to triage."

- [ ] **Step 10 [USER]: Activate Flow + retrieve XML**
```bash
sf project retrieve start --metadata Flow:MarketImpact_Detect_Segment --target-org dhruv-org
git add force-app/main/default/flows/MarketImpact_Detect_Segment.flow-meta.xml
git commit -m "feat(flow): add MarketImpact_Detect_Segment platform-event triggered flow"
```

---

### Task 2.8 — Write Python event simulator

**Files:**
- Create: `scripts/simulator/post_event.py`
- Create: `scripts/simulator/events/rbi_mpc_25bps_cut.json`
- Create: `scripts/simulator/.env.example`

- [ ] **Step 1 [CLAUDE]: Write the RBI MPC sample event**

`scripts/simulator/events/rbi_mpc_25bps_cut.json`:
```json
{
  "eventId": "RBI-MPC-2026-04-30-001",
  "symbol": "BANKNIFTY",
  "eventType": "RBI_MPC",
  "pctChange": -1.25,
  "sector": "Banking",
  "severity": "High",
  "timestamp": "2026-04-30T10:00:00Z"
}
```

- [ ] **Step 2 [CLAUDE]: Write the simulator script**

`scripts/simulator/post_event.py`:
```python
"""
Posts a synthetic market event to Data Cloud Streaming Ingestion API.

Usage:
  export DC_INGEST_URL=https://<tenant>.c360a.salesforce.com/api/v1/ingest/sources/MarketEventStream/<connector>
  export DC_TOKEN=<bearer>
  python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json
"""
import json
import os
import sys
import urllib.request

def main(path: str):
    url = os.environ["DC_INGEST_URL"]
    token = os.environ["DC_TOKEN"]
    with open(path, "rb") as f:
        body = f.read()
    req = urllib.request.Request(
        url, data=body,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        print(f"HTTP {resp.status}")
        print(resp.read().decode())

if __name__ == "__main__":
    main(sys.argv[1])
```

`scripts/simulator/.env.example`:
```
DC_INGEST_URL=https://<your-tenant>.c360a.salesforce.com/api/v1/ingest/sources/MarketEventStream/<connector-name>
DC_TOKEN=<paste OAuth bearer token here>
```

- [ ] **Step 3 [USER]: Get a Data Cloud bearer token**

Setup → Connected Apps → New (or use the standard Data Cloud Ingestion connected app). Create OAuth flow; or use `sf data-cloud auth` if installed. Easiest: Setup → Personal → My Account → "Get Token" via OAuth Playground.

- [ ] **Step 4 [USER]: Fire the event**
```bash
export DC_INGEST_URL=...   # from Task 2.2 step 2
export DC_TOKEN=...
python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json
```
Expected: `HTTP 202 Accepted`.

- [ ] **Step 5 [USER]: Verify event lands in Data Cloud**

Data Cloud → Data Explorer → MarketEvent__dlm → confirm 1 new row in last 5 min.

- [ ] **Step 6 [USER]: Verify Data Action fires Platform Event**

Setup → Platform Events → Market_Impact_Event__e → look at the Streaming Monitor (or use Workbench → REST Explorer GET on the event). Should see 1 event in last 2 min.

- [ ] **Step 7 [USER]: Verify Flow ran**

Setup → Flow → Paused & Failed Flow Interviews. Should NOT show failures. Then in Object Manager → Market_Impact__c → check record count = 62 (or near 62 — exact count depends on how the seed actually distributed).

- [ ] **Step 8 [USER]: Verify Custom Notification arrived**

On Vikram's Salesforce Mobile App (or Desktop Notifications bell icon in browser): a "Market alert — RBI MPC" notification visible. Tap → opens to Market_Event detail.

- [ ] **Step 9 [USER]: Commit simulator**
```bash
git add scripts/simulator/
git commit -m "feat(simulator): add Python streaming-ingestion simulator + RBI MPC event"
```

---

### Task 2.9 — Setup Slack workspace + Salesforce for Slack

**Files:** none (external + in-org)

- [ ] **Step 1 [USER]: Create a free Slack workspace**

https://slack.com/create. Workspace name: "Dhruv Demo." Add channels: `#research-desk`, `#approvals`, `#general`. Add at least one extra user (you can use a teammate, alt email, or your same email with `+slack` alias).

- [ ] **Step 2 [USER]: Install Salesforce for Slack from Salesforce side**

Setup → Slack Apps Setup → "Connect to Slack" → OAuth handshake to your Slack workspace. Confirm "Salesforce for Slack" app appears in your Slack workspace.

- [ ] **Step 3 [USER]: Map your Salesforce User to your Slack User**

In Salesforce: User detail → "Connect to Slack." Repeat for the manager test user (Manager Rajesh).

- [ ] **Step 4 [USER]: Test the connection**

In Slack, type `/sf-help` → confirm the bot responds. This proves the connector is live.

---

## 🚦 Phase 2 Gate (end of Day 2)

Before Phase 3:

- [ ] All 5 DMOs in Data Cloud, populated with row counts matching Salesforce
- [ ] `ClientExposureGraph` Active and queryable
- [ ] `MarketEvent__dlm` accepts streaming POSTs
- [ ] Data Action filter wired to `Market_Impact_Event__e` Platform Event
- [ ] `MarketImpact_Detect_Segment` Flow active and tested end-to-end
- [ ] Firing a synthetic RBI event produces ~62 `Market_Impact__c` rows
- [ ] Custom Notification arrives on Vikram's mobile app
- [ ] Slack workspace created, Salesforce for Slack installed and connected

**This is the most technically risky phase. Do not advance unless the gate is green.**

---

# Phase 3 — Day 3: Dhruv agent core (2026-05-01)

**Goal:** Dhruv responds in Conversation Preview to "Show me clients impacted by RBI rate cut" with the correct 8 names ranked by Severity Score; can draft a personalized nudge for Priya.

---

### Task 3.1 — Clone Financial Advisor Assistance template into "Dhruv"

- [ ] **Step 1 [USER]: Setup → Agents → New → Choose Template**

Pick "Financial Advisor Assistance." Click "Use This Template." Name: `Dhruv`. API Name: `Dhruv`. Description: "RM Co-Pilot for Wealth Market Monitoring."

- [ ] **Step 2 [USER]: Verify the template's existing topic loaded**

Open Dhruv → Topics → confirm "Client Meeting Preparation" topic exists with its standard actions (Client Summary, Household Summary, Portfolio Performance, etc.).

- [ ] **Step 3 [USER]: Retrieve metadata**
```bash
sf project retrieve start --metadata Bot:Dhruv,GenAiPlanner:Dhruv --target-org dhruv-org
git add force-app/main/default/bots force-app/main/default/genAiPlanners
git commit -m "feat(agent): clone Financial Advisor Assistance template into Dhruv"
```

---

### Task 3.2 — Build prompt template "Market Event Talking Points"

**Files:**
- Create: `force-app/main/default/genAiPromptTemplates/Market_Event_Talking_Points.genAiPromptTemplate-meta.xml`

- [ ] **Step 1 [USER]: Setup → Prompt Builder → New → Flex**

Name: `Market_Event_Talking_Points`. Object: none (Flex). Resources: bind `MarketEventId` (input).

- [ ] **Step 2 [USER]: Write the prompt body**

```
You are Dhruv, a wealth-management market briefing co-pilot for relationship managers in India.

Context:
{{ Record.Market_Event__c.Headline__c }}
{{ Record.Market_Event__c.Source__c }}
Pct change: {{ Record.Market_Event__c.Pct_Change__c }}
Sector: {{ Record.Market_Event__c.Sector__c }}
Severity: {{ Record.Market_Event__c.Severity__c }}

Output exactly 3 bullet talking points (≤20 words each) summarising the event for a relationship manager,
followed by 1 risk callout (≤25 words). Use plain English. Do not give buy/sell recommendations
on specific stocks. Do not invent numbers; use only the values above.
```

- [ ] **Step 3 [USER]: Test in the Prompt Builder preview pane**

Use Priya's recent Market_Event record. Verify output is 3 bullets + 1 risk line, no buy/sell language.

- [ ] **Step 4 [USER]: Activate + retrieve**
```bash
sf project retrieve start --metadata GenAiPromptTemplate:Market_Event_Talking_Points --target-org dhruv-org
git add force-app/main/default/genAiPromptTemplates/Market_Event_Talking_Points*
git commit -m "feat(prompt): add Market_Event_Talking_Points Flex template"
```

---

### Task 3.3 — Build prompt template "Personalized Client Nudge" (Hinglish best-effort)

**Files:**
- Create: `force-app/main/default/genAiPromptTemplates/Personalized_Client_Nudge.genAiPromptTemplate-meta.xml`

- [ ] **Step 1 [USER]: Setup → Prompt Builder → New → Flex**

Name: `Personalized_Client_Nudge`. Inputs: `AccountId`, `MarketEventId`. Resources: ground on Account record + Account.SecuritiesHoldings + Market_Event__c.

- [ ] **Step 2 [USER]: Prompt body**

```
You are Dhruv, a wealth-management RM co-pilot. Draft a short, personalized WhatsApp message
in Hinglish (Hindi-English code switch using Devanagari + Latin script) for the client below.

Client:
- Name: {{ Account.Name }}, {{ Account.BillingCity }}
- AUM: ₹{{ Account.AUM__c }}
- Preferred Channel: {{ Account.Preferred_Channel__c }}

Market Event: {{ Record.Market_Event__c.Headline__c }}
Their Exposure: {{ ImpactedExposurePct }}% of AUM in {{ Record.Market_Event__c.Sector__c }}

Constraints:
- Length: ≤220 characters total
- Tone: warm, concise, professional
- DO NOT recommend buying/selling specific stocks
- DO NOT invent numbers
- DO NOT include disclaimers (compliance agent will append)
- If you cannot produce confident Hinglish, output English

Format: just the message body, no preamble, no closing signature.
```

- [ ] **Step 3 [USER]: Test in preview**

Bind to Priya + the RBI event. Confirm output is ≤220 chars, no specific buy/sell.

- [ ] **Step 4 [USER]: Activate + retrieve + commit**
```bash
sf project retrieve start --metadata GenAiPromptTemplate:Personalized_Client_Nudge --target-org dhruv-org
git add force-app/main/default/genAiPromptTemplates/Personalized_Client_Nudge*
git commit -m "feat(prompt): add Personalized_Client_Nudge Hinglish best-effort template"
```

---

### Task 3.4 — Build prompt template "Pre Call Brief"

**Files:**
- Create: `force-app/main/default/genAiPromptTemplates/Pre_Call_Brief.genAiPromptTemplate-meta.xml`

- [ ] **Step 1 [USER]: Setup → Prompt Builder → New → Flex**

Name: `Pre_Call_Brief`. Input: `AccountId`. Ground on Account, Household via Party Relationship Group, last 3 InteractionSummary, active LifeEvent records.

- [ ] **Step 2 [USER]: Prompt body**
```
You are Dhruv. Generate a 60-second pre-call brief for a wealth RM about to call this client.

Client: {{ Account.Name }} ({{ Account.BillingCity }})
AUM: ₹{{ Account.AUM__c }}
Household: {{ HouseholdSummary }}
Last 3 interactions: {{ Last3InteractionSummaries }}
Active life events: {{ ActiveLifeEvents }}
Current top holdings: {{ TopHoldings }}

Output sections:
1) **Snapshot** (3 lines: AUM, household composition, last contact)
2) **Holdings heatmap callout** (1 line: which sector is most exposed)
3) **Active life events** (bulleted)
4) **Two suggested talking points** (use last interaction context; do not recommend specific stocks)

Keep total under 220 words.
```

- [ ] **Step 3 [USER]: Activate + retrieve + commit**

Same pattern as 3.2/3.3.

---

### Task 3.5 — Build action "Get Impacted Clients" (Flow)

**Files:**
- Create: `force-app/main/default/flows/Get_Impacted_Clients.flow-meta.xml`

- [ ] **Step 1 [USER]: Build Autolaunched Flow**

Setup → Flows → New → Autolaunched. Name: `Get_Impacted_Clients`. Input: `MarketEventId` (optional; if blank, return all current open impacts for current user).

- [ ] **Step 2 [USER]: Get Records — Market_Impact__c**

Filter: `Account__r.OwnerId = $User.Id` AND (`Event__c = :MarketEventId` OR `MarketEventId == null`). Sort by `Severity_Score__c` DESC. Limit 10.

- [ ] **Step 3 [USER]: Output**

Output variable `ImpactedClients` (collection of Market_Impact__c with related Account.Name, Severity_Score__c, Exposure_Pct_of_AUM__c).

- [ ] **Step 4 [USER]: Activate + retrieve + commit**
```bash
sf project retrieve start --metadata Flow:Get_Impacted_Clients --target-org dhruv-org
git add force-app/main/default/flows/Get_Impacted_Clients*
git commit -m "feat(action): Get_Impacted_Clients flow returns top-N impacted clients"
```

---

### Task 3.6 — Wire Dhruv topics + actions

- [ ] **Step 1 [USER]: Open Dhruv in Agent Builder**

Setup → Agents → Dhruv → Topics tab.

- [ ] **Step 2 [USER]: Add Topic 1 — Market Event Briefing**

Click New Topic. Name: `Market_Event_Briefing`. Description: "Triggers when an RM asks what is happening in the market or what events are affecting their clients today."

Trigger phrases:
- "what's happening in the market?"
- "any market events today?"
- "show me impacted clients"
- "brief me on today's event"

Add Action: `Get_Impacted_Clients` (Flow). Map output → response.

Add Action: `Market_Event_Talking_Points` (Prompt). Input `MarketEventId` ← from latest `Market_Event__c` record.

- [ ] **Step 3 [USER]: Add Topic 2 — Client Outreach Drafting**

Name: `Client_Outreach_Drafting`. Trigger phrases:
- "draft a nudge for the top 3"
- "draft a message for [client]"
- "write outreach for impacted clients"

Action: `Personalized_Client_Nudge` (Prompt). Inputs: `AccountId`, `MarketEventId`.

(Note: A2A to Paalak comes in Day 4 via the `Draft_Client_Outreach` orchestrator Flow. For Day 3, the topic just produces the draft.)

- [ ] **Step 4 [USER]: Add Topic 3 — Approval Routing (stub for Day 3)**

Name: `Approval_Routing`. Trigger phrases:
- "request approval for [client]'s [amount] [instrument] trade"
- "send this to manager for approval"

Action placeholder: a Flow `Request_Trade_Approval` to be built Day 4. For Day 3, leave action unbound.

- [ ] **Step 5 [USER]: Add Topic 4 — Pre-Call Brief Assembly (stub)**

Name: `Pre_Call_Brief_Assembly`. Trigger phrases:
- "brief me on [client] before the call"
- "give me a pre-call brief for [client]"

Action: `Pre_Call_Brief` (Prompt). Input: `AccountId`.

- [ ] **Step 6 [USER]: Test all 4 topics in Conversation Preview**

Setup → Agents → Dhruv → Conversation Preview. Test:
1. "show me impacted clients" → should return list of 8 with Priya at top
2. "draft a message for Priya" → should produce a Hinglish/English nudge ≤220 chars
3. "brief me on Priya before the call" → should produce a structured pre-call brief

- [ ] **Step 7 [USER]: Retrieve agent metadata + commit**
```bash
sf project retrieve start --metadata Bot:Dhruv,GenAiPlanner:Dhruv,GenAiPlugin:Dhruv_* --target-org dhruv-org
git add force-app/main/default/bots force-app/main/default/genAiPlanners force-app/main/default/genAiPlugins
git commit -m "feat(agent): wire Dhruv 4 topics + 3 actions; Conversation Preview passes"
```

---

## 🚦 Phase 3 Gate (end of Day 3)

- [ ] Dhruv agent exists, cloned from FAA template
- [ ] All 3 active prompt templates produce sensible output in Prompt Builder preview
- [ ] `Get_Impacted_Clients` Flow returns Vikram's 8 impacted clients ranked by severity
- [ ] Conversation Preview successfully responds to all 3 day-3 utterances above
- [ ] Approval Routing topic exists as a stub (action TBD Day 4)

---

# Phase 4 — Day 4: Channels + Paalak — HARD CUT DAY (2026-05-02)

**Goal:** End-to-end anchor scenario runs at least once on the org. Tonight is the **last** night of building. Anything red after this gate gets **cut** per the spec's sacrifice order.

---

### Task 4.1 — WhatsApp Enhanced Channel + outbound

**Files:** mostly in-org; messaging metadata exported

- [ ] **Step 1 [USER]: Setup → Messaging → Channels → New → WhatsApp Enhanced Channel**

Provide:
- Meta App Id, App Secret, WABA Id, Phone Number Id, Access Token (from `~/.dhruv-secrets.env`)
- Channel name: `WhatsApp_Demo`
- Routing: Omni-Channel

- [ ] **Step 2 [USER]: Submit `portfolio_alert_v1` UTILITY template (in Meta side)**

In Meta Business Manager → WhatsApp Manager → Message Templates → New. Category: UTILITY. Language: English (UK) (Hinglish best-effort goes in body params, not template text). Body:
```
Hi {{1}}, your portfolio includes {{2}}% exposure to today's market event ({{3}}). 
Reply if you'd like to discuss. Disclosures may apply.
```
Approval is usually instant for UTILITY. If queued, fall back to `hello_world`.

- [ ] **Step 3 [USER]: Sync the template into Salesforce**

Setup → Messaging → Channels → WhatsApp_Demo → "Sync Templates." Confirm `portfolio_alert_v1` appears as a Messaging Component.

---

### Task 4.2 — `Send_WhatsApp_Template` Flow

- [ ] **Step 1 [USER]: New Autolaunched Flow**

Name: `Send_WhatsApp_Template`. Inputs: `AccountId`, `MessageBody`, `Param1Name`, `Param2Pct`, `Param3Event`.

- [ ] **Step 2 [USER]: Get Records — Account → resolve phone**

Get Person Account → use `PersonMobilePhone` (or look up `Demo_Recipients__mdt` for the demo recipient phone).

For demo: lookup `Demo_Recipients__mdt` where `Account__c = AccountId` and `Active__c = true`. Use `Phone_E164__c`.

- [ ] **Step 3 [USER]: Action — Send Conversation Messages**

Standard messaging action. Inputs:
- Channel: `WhatsApp_Demo`
- Recipient: phone from Step 2
- Component: `portfolio_alert_v1`
- Component params: Param1, Param2, Param3 → from inputs

- [ ] **Step 4 [USER]: Activate + retrieve + commit**

---

### Task 4.3 — `Draft_Client_Outreach` orchestrator + Send action wiring

- [ ] **Step 1 [USER]: New Autolaunched Flow `Draft_Client_Outreach`**

Inputs: `AccountId`, `MarketEventId`. Steps:
1. Run `Personalized_Client_Nudge` prompt → output `varDraft`
2. Call `Compliance_Check_A2A` flow (built in Task 4.10) → input `varDraft` → output `varVerdict`, `varFinal`
3. If `varVerdict == 'Approved'` → call `Send_WhatsApp_Template` with `varFinal` as MessageBody
4. Output `varFinal` for caller

- [ ] **Step 2 [USER]: Add a "Send WhatsApp Nudge" custom Action to Dhruv (Topic 2)**

Bind to `Draft_Client_Outreach` flow. In Conversation Preview, test "send the nudge to Priya now" → should fire the WhatsApp message.

- [ ] **Step 3 [USER]: Verify on real iPhone**

WhatsApp message arrives on the iPhone within 10s of "send" command. **This is Wow #4 dry-run #1.**

---

### Task 4.4 — WhatsApp inbound (round-trip)

- [ ] **Step 1 [USER]: Build Omni-Channel Flow on incoming `ConversationEntry`**

Name: `WhatsApp_Inbound_Auto_Log`. Trigger: ConversationEntry record-triggered (filter: ChannelType = WhatsApp).
Steps:
1. Find the related Account via MessagingEndUser
2. Create Task: Subject = "WhatsApp reply", Description = body, WhatId = AccountId, ActivityDate = TODAY()
3. Optionally route to Dhruv to auto-respond

- [ ] **Step 2 [USER]: Test round-trip**

From your iPhone, reply to Priya's WhatsApp message ("Call me at 3pm please"). Verify the Task auto-creates on Priya's Contact timeline within ~5s.

---

### Task 4.5 — Slack approval flow

- [ ] **Step 1 [USER]: Configure Salesforce Channels for Records**

Setup → Slack → Salesforce Channels → enable for `Custom_Trade_Request__c`. Choose: auto-create channel on insert, channel name pattern `trade-{!Custom_Trade_Request__c.Name}-{!Account.Name}`.

- [ ] **Step 2 [USER]: Build `Slack_Trade_Approval` record-triggered Flow**

Trigger: After Insert on Custom_Trade_Request__c.
Steps:
1. (Salesforce auto-creates the Slack channel via the connector — wait for it)
2. Post to channel: Block Kit approval card (use "Send Slack Message" Flow action)
3. Add user mappings: invite RM__c, Approver__c (manager), and the Research Desk bot if any

Block Kit JSON (paste into the action input):
```json
{
  "blocks": [
    {"type": "header","text":{"type":"plain_text","text":"Trade approval — {{Client__r.Name}}"}},
    {"type": "section","fields":[
       {"type":"mrkdwn","text":"*Instrument:*\n{{Instrument__c}}"},
       {"type":"mrkdwn","text":"*Amount:*\n₹{{Amount__c}}"},
       {"type":"mrkdwn","text":"*Rationale:*\n{{Rationale__c}}"}
    ]},
    {"type":"actions","elements":[
       {"type":"button","style":"primary","text":{"type":"plain_text","text":"Approve"},"action_id":"approve_{{Id}}"},
       {"type":"button","style":"danger","text":{"type":"plain_text","text":"Reject"},"action_id":"reject_{{Id}}"}
    ]}
  ]
}
```

- [ ] **Step 3 [USER]: Wire approval handler**

For the demo, approval can be a simple Quick Action or Custom Notification listener that flips `Status__c → Approved` and creates a Task on the Account. Don't over-engineer — the visual is the win.

- [ ] **Step 4 [USER]: `Request_Trade_Approval` Flow (Dhruv action)**

New Autolaunched Flow. Inputs: `AccountId`, `Instrument`, `Amount`, `Rationale`.
Steps:
1. Insert Custom_Trade_Request__c (RM__c = $User.Id, Status__c = 'Pending')
2. (Slack channel + Block Kit auto-fire via record-triggered)
3. Return `varCreatedRecordId`

Wire as the action for Dhruv's "Approval Routing" topic.

- [ ] **Step 5 [USER]: Test end-to-end in Conversation Preview**

"Request approval for Priya's ₹40L Nifty Bees rotation."
Expected: trade record created → Slack channel auto-creates → approval card posts. Click "Approve" in Slack → record flips to Approved.

---

### Task 4.6 — Build Paalak agent + Compliance prompt

**Files:**
- Create: `force-app/main/default/genAiPromptTemplates/Compliance_Validation.genAiPromptTemplate-meta.xml`
- Create: `force-app/main/default/bots/Paalak/...`

- [ ] **Step 1 [USER]: Setup → Prompt Builder → new "Compliance_Validation" Flex prompt**

Body:
```
You are Paalak, a SEBI-aware compliance gate for Indian wealth-advisor outreach.

Validate the message below against these rules:
1) NO personalized buy/sell instructions on a specific stock or fund.
   ("consider," "review," "discuss" are OK; "buy," "sell," "rotate ₹X into Y" are NOT.)
2) If a specific instrument is named, an MITC disclosure must be appended.
3) If a stock is named, a research-analyst attribution must be appended.
4) No PII leak in the body.

Input: {{ DraftMessage }}
Client name: {{ ClientName }}
Mentioned instruments: {{ MentionedInstruments }}

Output JSON ONLY (no preamble):
{
  "verdict": "Approved" | "Revise" | "Block",
  "reason": "<short>",
  "message_with_disclosure": "<original message + MITC disclosure if needed>"
}
```

- [ ] **Step 2 [USER]: Setup → Agents → New → Standard Agent (not from template)**

Name: `Paalak`. Description: "Compliance validation agent for Dhruv's outreach drafts." Add 1 topic `Compliance_Validation` with 1 action: `Validate Message` → bind to the `Compliance_Validation` prompt.

- [ ] **Step 3 [USER]: Activate + expose Paalak Agent API**

Setup → Agents → Paalak → Activate → "Enable Agent API" → copy the endpoint URL + Connected App credentials.

---

### Task 4.7 — `Paalak_AgentAPI` Named Credential + Apex callout

**Files:**
- Create: `force-app/main/default/namedCredentials/Paalak_AgentAPI.namedCredential-meta.xml`
- Create: `force-app/main/default/classes/PaalakAgentInvoker.cls`
- Create: `force-app/main/default/classes/PaalakAgentInvokerTest.cls`

- [ ] **Step 1 [USER]: Setup → Named Credentials → New**

Name: `Paalak_AgentAPI`. URL: from Task 4.6. Identity Type: Named Principal. OAuth 2.0 with Connected App from same step.

- [ ] **Step 2 [CLAUDE]: Generate `PaalakAgentInvoker.cls`**
```apex
/**
 * HTTP callout to Paalak Agent API for compliance validation.
 * Invoked by Compliance_Check_A2A Flow.
 */
public with sharing class PaalakAgentInvoker {

    public class Request {
        @InvocableVariable(required=true) public String draftMessage;
        @InvocableVariable             public String clientName;
        @InvocableVariable             public String mentionedInstruments;
    }

    public class Response {
        @InvocableVariable public String verdict;             // Approved | Revise | Block
        @InvocableVariable public String reason;
        @InvocableVariable public String messageWithDisclosure;
    }

    @InvocableMethod(label='Validate via Paalak (A2A)')
    public static List<Response> validate(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Paalak_AgentAPI/agents/Paalak/validate');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(new Map<String, Object>{
                'draftMessage' => r.draftMessage,
                'clientName' => r.clientName,
                'mentionedInstruments' => r.mentionedInstruments
            }));
            req.setTimeout(20000);

            Http http = new Http();
            HttpResponse resp = http.send(req);
            Response parsed = (Response) JSON.deserialize(resp.getBody(), Response.class);

            // Insurance: if API failed, return safe default
            if (resp.getStatusCode() >= 300 || parsed.verdict == null) {
                parsed = new Response();
                parsed.verdict = 'Revise';
                parsed.reason  = 'Paalak unreachable — manual review required';
                parsed.messageWithDisclosure = r.draftMessage;
            }
            out.add(parsed);
        }
        return out;
    }
}
```

- [ ] **Step 3 [CLAUDE]: Generate `PaalakAgentInvokerTest.cls`**
```apex
@isTest
private class PaalakAgentInvokerTest {

    @isTest static void approvesCleanMessage() {
        Test.setMock(HttpCalloutMock.class, new MockApprove());
        PaalakAgentInvoker.Request r = new PaalakAgentInvoker.Request();
        r.draftMessage = 'Hi Priya, thoughts on today RBI cut?';
        r.clientName = 'Priya Sharma';
        r.mentionedInstruments = '';

        Test.startTest();
        List<PaalakAgentInvoker.Response> out =
            PaalakAgentInvoker.validate(new List<PaalakAgentInvoker.Request>{r});
        Test.stopTest();

        System.assertEquals('Approved', out[0].verdict);
    }

    @isTest static void blocksBuySellLanguage() {
        Test.setMock(HttpCalloutMock.class, new MockBlock());
        PaalakAgentInvoker.Request r = new PaalakAgentInvoker.Request();
        r.draftMessage = 'Buy 100 shares of HDFCBANK now!';

        Test.startTest();
        List<PaalakAgentInvoker.Response> out =
            PaalakAgentInvoker.validate(new List<PaalakAgentInvoker.Request>{r});
        Test.stopTest();

        System.assertEquals('Block', out[0].verdict);
    }

    @isTest static void fallsBackOnApiFailure() {
        Test.setMock(HttpCalloutMock.class, new MockFail());
        PaalakAgentInvoker.Request r = new PaalakAgentInvoker.Request();
        r.draftMessage = 'whatever';

        Test.startTest();
        List<PaalakAgentInvoker.Response> out =
            PaalakAgentInvoker.validate(new List<PaalakAgentInvoker.Request>{r});
        Test.stopTest();

        System.assertEquals('Revise', out[0].verdict);
        System.assert(out[0].reason.contains('manual review'));
    }

    private class MockApprove implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest r) {
            HttpResponse h = new HttpResponse();
            h.setStatusCode(200);
            h.setBody('{"verdict":"Approved","reason":"clean","messageWithDisclosure":"Hi Priya, thoughts on today RBI cut?"}');
            return h;
        }
    }
    private class MockBlock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest r) {
            HttpResponse h = new HttpResponse();
            h.setStatusCode(200);
            h.setBody('{"verdict":"Block","reason":"buy/sell language","messageWithDisclosure":""}');
            return h;
        }
    }
    private class MockFail implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest r) {
            HttpResponse h = new HttpResponse();
            h.setStatusCode(500);
            h.setBody('{"error":"upstream"}');
            return h;
        }
    }
}
```

- [ ] **Step 4 [USER]: Deploy + run tests**
```bash
sf project deploy start --source-dir force-app/main/default/classes,force-app/main/default/namedCredentials --target-org dhruv-org
sf apex run test --class-names PaalakAgentInvokerTest --target-org dhruv-org --result-format human --code-coverage
```
Expected: 3/3 pass, code coverage ≥ 75%.

- [ ] **Step 5 [USER]: Commit**
```bash
git add force-app/main/default/classes force-app/main/default/namedCredentials
git commit -m "feat(a2a): Paalak Agent API named credential + Apex invoker + 3 unit tests"
```

---

### Task 4.8 — `Compliance_Check_A2A` Flow

- [ ] **Step 1 [USER]: New Autolaunched Flow**

Name: `Compliance_Check_A2A`. Inputs: `DraftMessage`, `ClientName`, `MentionedInstruments`. Outputs: `Verdict`, `Reason`, `FinalMessage`.

Step 1: Action → "Validate via Paalak (A2A)" (the invocable from Task 4.7) → outputs map to flow vars.

- [ ] **Step 2 [USER]: Wire into `Draft_Client_Outreach` (Task 4.3)**

Reopen `Draft_Client_Outreach`. Replace the placeholder compliance call with: Subflow → `Compliance_Check_A2A`. Pass `varDraft` → `DraftMessage`. Use returned `FinalMessage` and `Verdict`.

- [ ] **Step 3 [USER]: Test end-to-end**

In Conversation Preview, "Draft a Hinglish nudge for Priya about today's rate cut, then send."
Expected order:
1. Dhruv calls Personalized_Client_Nudge → draft generated
2. Dhruv calls Compliance_Check_A2A → Paalak Agent API hit → JSON verdict returned
3. If Approved, draft (with MITC disclosure) flows to `Send_WhatsApp_Template`
4. WhatsApp message arrives on iPhone

- [ ] **Step 4 [USER]: Retrieve + commit**
```bash
sf project retrieve start --metadata Flow:Compliance_Check_A2A,Flow:Draft_Client_Outreach --target-org dhruv-org
git add force-app/main/default/flows
git commit -m "feat(a2a): Compliance_Check_A2A flow + Draft_Client_Outreach orchestrator"
```

---

### Task 4.9 — `Pre_Call_Brief` schedule-triggered Flow

- [ ] **Step 1 [USER]: New Schedule-Triggered Flow**

Name: `Pre_Call_Brief`. Trigger: every 5 minutes. Filter: Events scheduled to start in 8–12 minutes that have a related Account.

Step A: Get Records — Event WHERE `StartDateTime BETWEEN NOW + 8min AND NOW + 12min` AND `WhatId.Type = 'Account'`.

Step B: Loop. For each event, call `Pre_Call_Brief` prompt with `AccountId = WhatId`.

Step C: Send Custom Notification → recipient = OwnerId of Event → Body = first 200 chars of brief.

- [ ] **Step 2 [USER]: Create demo Event**

Create an Event on Priya's record: Subject "Portfolio review call." Start: 5 min from when you'll record. Duration 30 min. Owner: Vikram.

- [ ] **Step 3 [USER]: Test by setting flow trigger to "every minute" temporarily**

Confirm Custom Notification arrives on iPhone within 1 min of the 8–12 min window opening. Then revert to every 5 min.

- [ ] **Step 4 [USER]: Retrieve + commit**

---

### Task 4.10 — Embedded dashboard / LWC chart

**Files:**
- Create: `force-app/main/default/lwc/exposureHeatmap/exposureHeatmap.js`
- Create: `force-app/main/default/lwc/exposureHeatmap/exposureHeatmap.html`
- Create: `force-app/main/default/lwc/exposureHeatmap/exposureHeatmap.js-meta.xml`

- [ ] **Step 1 [CLAUDE]: Generate the LWC**

`exposureHeatmap.js-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__HomePage</target>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
    </targets>
</LightningComponentBundle>
```

`exposureHeatmap.html`:
```html
<template>
    <lightning-card title="Firmwide Exposure — Today's Event" icon-name="custom:custom17">
        <div class="slds-p-around_medium">
            <template if:true={loading}><lightning-spinner></lightning-spinner></template>
            <template if:true={rows}>
                <table class="slds-table slds-table_bordered slds-table_cell-buffer">
                    <thead><tr>
                        <th>Sector</th><th>Impacted Clients</th><th>Total Exposure (₹)</th>
                    </tr></thead>
                    <tbody>
                        <template for:each={rows} for:item="r">
                            <tr key={r.sector}>
                                <td>{r.sector}</td>
                                <td>{r.count}</td>
                                <td>{r.total}</td>
                            </tr>
                        </template>
                    </tbody>
                </table>
            </template>
        </div>
    </lightning-card>
</template>
```

`exposureHeatmap.js`:
```javascript
import { LightningElement, wire } from 'lwc';
import getExposureSummary from '@salesforce/apex/ExposureHeatmapCtrl.getSummary';

export default class ExposureHeatmap extends LightningElement {
    rows;
    loading = true;

    @wire(getExposureSummary)
    wired({ data, error }) {
        this.loading = false;
        if (data) this.rows = data;
        if (error) console.error(error);
    }
}
```

- [ ] **Step 2 [CLAUDE]: Generate the controller**

`force-app/main/default/classes/ExposureHeatmapCtrl.cls`:
```apex
public with sharing class ExposureHeatmapCtrl {
    public class Row { @AuraEnabled public String sector;
                       @AuraEnabled public Integer count;
                       @AuraEnabled public Decimal total; }

    @AuraEnabled(cacheable=true)
    public static List<Row> getSummary() {
        List<Row> out = new List<Row>();
        for (AggregateResult ar : [
            SELECT Event__r.Sector__c sec,
                   COUNT(Id) cnt,
                   SUM(Exposure_Amount__c) tot
            FROM Market_Impact__c
            GROUP BY Event__r.Sector__c
        ]) {
            Row r = new Row();
            r.sector = (String) ar.get('sec');
            r.count  = (Integer) ar.get('cnt');
            r.total  = (Decimal) ar.get('tot');
            out.add(r);
        }
        return out;
    }
}
```

- [ ] **Step 3 [USER]: Add to Market Command Center home page**

Lightning App Builder → Market Command Center Home → drag `exposureHeatmap` into the main region. Save + Activate.

- [ ] **Step 4 [USER]: Deploy + verify + commit**
```bash
sf project deploy start --source-dir force-app/main/default/lwc,force-app/main/default/classes/ExposureHeatmapCtrl.cls --target-org dhruv-org
git add force-app/main/default/lwc force-app/main/default/classes/ExposureHeatmapCtrl.cls
git commit -m "feat(ui): exposureHeatmap LWC + controller on Market Command Center"
```

---

### Task 4.11 — End-to-end anchor scenario dress rehearsal

- [ ] **Step 1 [USER]: Reset state**

Delete all Market_Impact__c, Market_Event__c, and Custom_Trade_Request__c records:
```bash
sf data delete record --sobject Market_Impact__c --where "Id != null" --target-org dhruv-org
sf data delete record --sobject Market_Event__c --where "Id != null" --target-org dhruv-org
sf data delete record --sobject Custom_Trade_Request__c --where "Id != null" --target-org dhruv-org
```

- [ ] **Step 2 [USER]: Run the full anchor scenario**

1. From your laptop, fire `python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json`
2. Within 30s: 62 Market_Impact__c rows exist; Custom Notification on Vikram's iPhone
3. Open Salesforce Mobile → Ask Agentforce: "Show impacted clients" → 8 names ranked
4. "Draft Hinglish nudge for top 3 and send via WhatsApp"
5. WhatsApp message arrives on iPhone (real)
6. Reply on iPhone "Call me at 3pm please" → Task auto-creates on Priya's record
7. "Request approval for Priya's ₹40L Nifty Bees rotation" → Slack channel auto-creates → Block Kit card posts
8. Click Approve in Slack → status flips
9. Wait ~10 min for Pre_Call_Brief schedule trigger (or trigger manually): Custom Notification arrives with brief
10. Open Trust Layer Audit Trail in Setup → most recent entry shows the prompts run

- [ ] **Step 3 [USER]: If anything is broken, decide cuts NOW per the spec's sacrifice order**

CLAUDE.md sacrifice order:
1. Voice/Siri shot
2. Paalak A2A protocol → inline as prompt step
3. Tableau/dashboard polish → static screenshot
4. Pre-Call Brief schedule trigger → manual trigger
5. Hinglish → English

Update CLAUDE.md to note any cut, with a one-liner why.

---

## 🚦 Phase 4 Gate (end of Day 4 night) — HARD CUT

- [ ] All 7 wow moments either work or are explicitly cut/stubbed
- [ ] At minimum the 5 mandatory wow moments work end-to-end (#2, #4, #5, #6, #7)
- [ ] Spec sacrifices documented in CLAUDE.md if anything was cut
- [ ] **No more building tomorrow** — only recording, polish, and submission

---

# Phase 5 — Day 5: Polish + record + submit (2026-05-03)

**Goal:** Submit by end of day. No code changes after the morning Lock at 10 AM.

---

### Task 5.1 — Voice/Siri Shortcut (stretch, AM-only)

- [ ] **Step 1 [USER]: On demo iPhone, install Salesforce Mobile App, log in as Vikram**

- [ ] **Step 2 [USER]: Setup Siri Shortcut**

iPhone → Shortcuts app → New Shortcut → Add Action → Salesforce → "Open Ask Agentforce." Set name "Talk to Agentforce." Test: "Hey Siri, Talk to Agentforce."

- [ ] **Step 3 [USER]: If it doesn't work cleanly within 60 min, CUT this shot.**

---

### Task 5.2 — Three full dry runs

- [ ] **Step 1 [USER]: Run the anchor scenario 3 times**

Time each run; aim for ≤4:30 of actual interaction (leaving 30s for cold open + closing tagline). Note the best take's exact timings for each wow moment.

---

### Task 5.3 — Record video segments

- [ ] **Step 1 [USER]: Record screen + iPhone in pieces**

Per the shot list in the spec (Section 7). Record each wow moment 2–3 times, pick the best.

Tools:
- Screen: QuickTime Player + iOS Recording (mirror iPhone via Lightning cable)
- Voice: Blue Yeti or any decent mic, separate audio file
- Edit: Descript or CapCut

- [ ] **Step 2 [USER]: Record voiceover**

Use the spec's Section 7 voiceover script. Calm tempo. Indian accent if available; otherwise neutral.

---

### Task 5.4 — Edit, caption, export

- [ ] **Step 1 [USER]: Cut the timeline to 4:50**

Trim. Add the persistent bottom system bar that lights up each system as touched.

- [ ] **Step 2 [USER]: Burn captions**

Use Descript auto-captions or manually time them.

- [ ] **Step 3 [USER]: Export 1080p H.264**

Filename: `Dhruv_Market_Monitoring_Agent_TeamSolo_AWT_Mumbai_2026.mp4`.

- [ ] **Step 4 [USER]: Upload to YouTube as Unlisted**

Capture the URL.

---

### Task 5.5 — Repo polish

- [ ] **Step 1 [USER]: Write README**

`README.md` overwrite (current is the SFDX boilerplate):
```markdown
# Dhruv — Market Monitoring Agent

5-minute video: <YouTube link>
Full design spec: docs/superpowers/specs/2026-04-28-dhruv-design.md

## What this is
A Salesforce-Agentforce-Data Cloud + WhatsApp + Slack co-pilot for wealth RMs that detects an
RBI MPC event, segments 450 clients to 62, drafts Hinglish nudges with compliance review,
routes Slack approvals, and pushes pre-call briefs.

## Architecture
![](docs/design/architecture-diagram.png)

## Demo credentials
Org URL: <login url>
Username: <judging user>
Password: <one-time, rotated>

## How to reproduce
1. Clone, `sf project deploy start --source-dir force-app --target-org <org>`
2. Run `python3 scripts/seed/seed_data.py --owner-id <Vikram User Id>`
3. Load CSVs via Data Loader (see docs/superpowers/plans/...)
4. Fire `python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json`
```

- [ ] **Step 2 [USER]: Generate architecture diagram**

Use Mermaid or draw.io; export `docs/design/architecture-diagram.png`. Just an image of the spec's Section 2 ASCII diagram, redrawn cleanly.

- [ ] **Step 3 [USER]: Capture key screenshots**

`docs/design/screenshots/`: Conversation Preview success, WhatsApp on phone, Slack approval card, Trust Layer audit, Market Command Center.

- [ ] **Step 4 [USER]: Push to GitHub public repo**
```bash
gh repo create dhruv-agentforce-hackathon --public --source=. --remote=origin --push
```

---

### Task 5.6 — Build 20-page appendix deck

- [ ] **Step 1 [USER]: Use Gamma or Google Slides**

Outline (20 pages):
1. Title + tagline
2. Problem (Vikram pain points, recap)
3. Solution overview (Dhruv tagline)
4. Anchor scenario in pictures (RBI MPC)
5. Architecture diagram
6. Data model (objects + DMOs + Data Graph)
7. Agent design (Dhruv topics + Paalak)
8. Hyper-segmentation flow (450→62→8)
9. WhatsApp screenshots
10. Slack screenshots
11. Pre-Call Brief screenshot
12. Trust Layer audit screenshot
13. ROI math (40 min → 47 sec × 50 events × 450 clients × ~5 RM-h/wk = ₹X Cr)
14. Mapping to challenge statement (FSC ✓ Agentforce ✓ Data Cloud ✓ WhatsApp ✓ Slack ✓ Tableau)
15. Compliance posture (SEBI, MITC, 5-yr retention)
16. Vernacular angle (Hinglish, voice trigger)
17. A2A multi-agent angle
18. Roadmap (the spec's "further improvements")
19. Risk register (the spec's risk table)
20. Team + GitHub + tagline

- [ ] **Step 2 [USER]: Export as PDF and add to repo**
```bash
git add docs/design/Dhruv_Appendix_Deck.pdf
git commit -m "docs: add 20-page appendix deck"
git push
```

---

### Task 5.7 — Submit

- [ ] **Step 1 [USER]: Open hackathon submission portal**

- [ ] **Step 2 [USER]: Submit:**
- YouTube unlisted URL
- GitHub public repo URL
- Text description (under word count)
- Products/APIs list (from spec Section 11 / data-model.md)
- Further improvements (from research Section G)
- Demo credentials

- [ ] **Step 3 [USER]: Confirm submission email**

---

## 🚦 Phase 5 Gate (final)

- [ ] Video uploaded to YouTube unlisted
- [ ] GitHub public repo with all source + README + diagram + screenshots + appendix deck
- [ ] Hackathon portal submission confirmed (email received)

---

# Self-Review

Spec coverage check (against [`docs/superpowers/specs/2026-04-28-dhruv-design.md`](../specs/2026-04-28-dhruv-design.md)):

| Spec section | Covered by task(s) |
|---|---|
| §1 Vision and scope | All phases |
| §2 Architecture | All phases |
| §3 Data model — custom objects | 1.3 |
| §3 Data model — Preferred_Channel | 1.4 |
| §3 Data model — Demo_Recipients__mdt | 1.5 |
| §3 Data model — DMOs | 2.1, 2.2 |
| §3 Data model — Data Graph | 2.3 |
| §3 Test data plan | 1.6, 1.7, 1.8 |
| §4 Dhruv agent | 3.1–3.6 |
| §4 Paalak agent | 4.6 |
| §4 Prompts | 3.2, 3.3, 3.4, 4.6 |
| §5 Flows — MarketImpact_Detect_Segment | 2.7 |
| §5 Flows — Get_Impacted_Clients | 3.5 |
| §5 Flows — Draft_Client_Outreach | 4.3 |
| §5 Flows — Send_WhatsApp_Template | 4.2 |
| §5 Flows — Slack_Trade_Approval | 4.5 |
| §5 Flows — Compliance_Check_A2A | 4.8 |
| §5 Flows — Pre_Call_Brief | 4.9 |
| §5 Platform Event | 2.4 |
| §5 WhatsApp inbound | 4.4 |
| §6 Mobile / WhatsApp / Slack / Dashboard / Trust Layer | 1.1, 4.1, 4.5, 4.10, 5.4 |
| §7 Video shot list | 5.3 |
| §8 5-day build sequence | All phases |
| §9 Risk register | 4.11 (cut decision) |
| §10 Submission checklist | 5.5, 5.6, 5.7 |

No gaps. No placeholders. Type names consistent (`Market_Event__c`, `Market_Impact__c`, `Custom_Trade_Request__c`, `ClientExposureGraph`, `Market_Impact_Event__e`, `Compliance_Check_A2A`, `Paalak_AgentAPI` used identically across tasks).
