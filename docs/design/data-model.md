# Data Model — Dhruv

Detailed reference. The canonical schema lives here; the spec links here.

## 1. Salesforce Core (FSC) — standard objects (no schema changes)

| Object | Used for |
|---|---|
| `Account` (Person Account) | Each client |
| `AccountContactRelation` (via Party Relationship Group) | Household membership |
| `FinancialAccount` | Demat / mutual fund accounts |
| `FinancialAccountParty` | Multi-owner junction |
| `SecuritiesHolding` | Position rows |
| `Security` | Ticker master (also mirrored in DC) |
| `FinancialGoal` | Education / retirement goals (Pre-Call Brief input) |
| `InteractionSummary` | Last 3 interactions for Pre-Call Brief |
| `LifeEvent` | Active life events (e.g. daughter's MIT admission) |
| `RecordAlert` | Optional, RM banner |
| `Event` | Scheduled calls — triggers Pre-Call Brief 10 min prior |
| `Task` | Auto-created from WhatsApp inbound replies |

## 2. Custom Salesforce objects (3)

### Market_Event__c

| API Name | Type | Required | Purpose |
|---|---|---|---|
| `Name` | Auto-Number `MEVT-{0000}` | Y | |
| `Symbol__c` | Text(20) | N | e.g. `BANKNIFTY`, `INFY` |
| `Event_Type__c` | Picklist | Y | `RBI_MPC` / `IT_SELLOFF` / `EARNINGS_BEAT` / `EARNINGS_MISS` / `OTHER` |
| `Pct_Change__c` | Number(5,2) | N | Negative = down |
| `Sector__c` | Picklist | Y | `Banking` / `IT` / `Auto` / `Pharma` / `FMCG` / `Energy` / `Macro` |
| `Severity__c` | Picklist | Y | `Low` / `Medium` / `High` / `Critical` |
| `Trigger_Time__c` | DateTime | Y | |
| `Source__c` | Text(80) | N | e.g. `RBI Press Release` |
| `Headline__c` | Text(255) | N | One-line summary for RM-facing UI |

### Market_Impact__c

Junction.

| API Name | Type | Required | Purpose |
|---|---|---|---|
| `Name` | Auto-Number `MIMP-{0000}` | Y | |
| `Account__c` | Lookup(Account) | Y | |
| `Event__c` | Lookup(Market_Event__c) | Y | |
| `Exposure_Amount__c` | Currency | Y | Absolute INR |
| `Exposure_Pct_of_AUM__c` | Number(5,2) | Y | |
| `RM_Action_Required__c` | Checkbox (formula) | Y | `Exposure_Pct_of_AUM__c >= 20` |
| `Severity_Score__c` | Number(7,2) (formula) | Y | `Exposure_Pct_of_AUM__c * ABS(Event__r.Pct_Change__c)` |
| `RM__c` | Lookup(User) (formula) | Y | `Account__r.OwnerId` |

### Custom_Trade_Request__c

Slack approval target.

| API Name | Type | Required | Purpose |
|---|---|---|---|
| `Name` | Auto-Number `CTR-{0000}` | Y | |
| `Client__c` | Lookup(Account) | Y | |
| `Instrument__c` | Text(80) | Y | e.g. `Nifty Bees ETF` |
| `Amount__c` | Currency | Y | |
| `Rationale__c` | Long Text Area(1024) | N | |
| `RM__c` | Lookup(User) | Y | |
| `Approver__c` | Lookup(User) | N | Manager — set by Slack flow |
| `Status__c` | Picklist | Y | `Draft` / `Pending` / `Approved` / `Rejected` |
| `Slack_Channel_Id__c` | Text(80) | N | Set by Slack flow |
| `Approval_Work_Item_Id__c` | Text(80) | N | Standard Approval Work Item Id (if used) |

## 3. Data Cloud (Data 360)

### DMOs (5)

| DMO | Source mapping | Refresh |
|---|---|---|
| `UnifiedIndividual` (standard) | Person Account → Individual | Real-time CDC |
| `FinancialAccount__dlm` (custom) | FSC `FinancialAccount` | Real-time CDC |
| `SecuritiesHolding__dlm` (custom) | FSC `SecuritiesHolding` | Real-time CDC |
| `Security__dlm` (custom) | Seeded CSV (50 rows) | One-shot bulk |
| `MarketEvent__dlm` (custom) | Streaming Ingestion API | Streaming |

### Data Graph: ClientExposureGraph

```
UnifiedIndividual
  └── FinancialAccount__dlm (FK: PrimaryOwnerId)
        └── SecuritiesHolding__dlm (FK: FinancialAccountId)
              └── Security__dlm (FK: SecurityId)
                    ↳ MarketEvent__dlm (related by Symbol or Sector match)
```

Used for grounding all portfolio-aware prompts. Single fetch returns the entire client portfolio + relevant market events.

### Data Action

Filter expression:
```
pctChange <= -0.05 OR eventType IN ('RBI_MPC', 'IT_SELLOFF')
```

Target: Salesforce Platform Event `Market_Impact_Event__e`.

## 4. Platform event

### Market_Impact_Event__e

| Field | Type |
|---|---|
| `Event_Id__c` | Text(80) |
| `Symbol__c` | Text(20) |
| `Sector__c` | Text(40) |
| `Pct_Change__c` | Number(5,2) |
| `Severity__c` | Text(20) |
| `Trigger_Time__c` | DateTime |

Published by: Data Cloud Data Action.
Subscribed by: `MarketImpact_Detect_Segment` Flow.

## 5. Test data targets

- 450 Person Accounts (Indian names, Mumbai pincodes)
- 150 Households via Party Relationship Group
- 50 Securities (NIFTY 50 + Bank Bees + Nifty Bees + Liquid Bees)
- ~2,000 Securities Holdings, distribution engineered so:
  - **62 accounts** have ≥20% Bank-Nifty / rate-sensitive exposure
  - **8 of those 62** are owned by `Vikram Rao`
  - **Priya Sharma** (Bandra, ₹1.8 Cr AUM, 28% Bank Nifty) is the named hero
  - Rohit Kapoor (22% NBFCs) and Meera Desai (19% rate-sensitive autos) are owned by Vikram and rank #2 / #3 by Severity Score

Generator: `scripts/seed/seed_data.py` (to be written Day 1). Loaded via Data Loader.

## 6. Custom metadata

### Demo_Recipients__mdt

Stores the (synthetic) WhatsApp test recipient numbers so they don't get hardcoded in Flow XML.

| Field | Type |
|---|---|
| `DeveloperName` | Text |
| `Account__c` | Text (Account External Id) |
| `Phone_E164__c` | Text |
| `Active__c` | Checkbox |
