# Dhruv — Market Monitoring Agent — Design Spec

**Project**: Agentforce Hackathon, AWT Mumbai 2026, BFSI track
**Spec date**: 2026-04-28
**Submission deadline**: 2026-05-03
**Event date**: 2026-05-19, Jio World Convention Centre
**Approach**: B — Dhruv + lightweight Paalak (two real Agentforce agents)

---

## 1. Vision and scope

A mobile-first Agentforce co-pilot for Wealth Relationship Managers that:

1. Auto-detects a market event the moment it streams in
2. Hyper-segments the impacted client subset via Data Cloud
3. Drafts personalized, compliance-checked outreach
4. Sends the outreach on the client's preferred channel (WhatsApp on the demo path)
5. Routes any follow-up custom-trade approval through Slack
6. Pushes a 360° pre-call brief 60 seconds before each scheduled call
7. Exposes a regulator-grade Einstein Trust Layer audit trail on every action

### Anchor scenario

RBI MPC surprises the market with a **25 bps repo cut**. Vikram Rao (RM at Meridian Private Wealth Mumbai) has 450 clients. Within seconds, Dhruv segments to the **62 clients** with rate-sensitive exposure ≥20% of AUM, of whom **8 are owned by Vikram**. The top 3 by exposure (Priya Sharma, Rohit Kapoor, Meera Desai — all have **`PreferredChannel = WhatsApp`** on their Account) get a Hinglish WhatsApp nudge. Priya replies asking to call. Vikram requests approval for a ₹40L equity rotation; the request auto-creates a Slack channel where Manager Rajesh approves it via Block Kit card. 60 seconds before Priya's 3 PM call, Vikram's phone buzzes with a full pre-call brief. Demo closes on the Trust Layer audit revealing PII masking, zero retention, MITC injection, and a 5-year retention stamp.

> **Preferred-channel field**: use the standard FSC `PreferredCommunicationChannel` field on Person Account if available; otherwise add a custom `Preferred_Channel__c` picklist (`WhatsApp` / `Email` / `SMS`). The `Send_WhatsApp_Template` Flow gates on this field — it only sends WhatsApp if the value is `WhatsApp`. This satisfies the problem-statement requirement that "the agent captures and uses the client's preferred channel."

### Non-goals (do NOT build these)

- Real NSE/BSE tick-data feed (Python simulator only)
- "Vigil" as a separate agent — it is a Flow + Data Action
- MCP server, offline-first, agents-teaching-agents, Tableau Pulse, Marathi/Tamil/Bengali expansion, Account Aggregator, Apromore, Zerodha Kite, Agentforce Grid
- Production WhatsApp via WABA — Meta test number only
- Bedrock-Claude on critical path — default Atlas; Hinglish is best-effort
- Live stage-demo reliability — first cut is video only

### Success criteria

- Anchor scenario runs end-to-end on the live org during recording
- All 5 mandatory wow moments work; Voice/Siri and Paalak A2A are stretch shots
- Video is 4:45–4:55, 1080p, captions burned, on YouTube unlisted
- GitHub repo with SFDX source, README, architecture diagram, seed-data script
- 20-page appendix deck for Showdown Q&A backup

---

## 2. Architecture

```
                                                       ┌─────────────────────┐
                                                       │ Python simulator    │
                                                       │ (local / Heroku)    │
                                                       └──────────┬──────────┘
                                                                  │ HTTP POST
                                                                  ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                       SALESFORCE ORG (FSC + DC + AF)                         │
│                                                                              │
│  ┌─────────────────────  Data Cloud (Data 360)  ──────────────────────────┐ │
│  │  Streaming Ingestion API → MarketEvent__dlm                            │ │
│  │  Mapped DMOs: UnifiedIndividual, FinancialAccount__dlm,                │ │
│  │               SecuritiesHolding__dlm, Security__dlm                    │ │
│  │  Data Graph: ClientExposureGraph (root: UnifiedIndividual)             │ │
│  │  Data Action: filter(pctChange ≤ -0.05 OR eventType='RBI_MPC')         │ │
│  │              → Platform Event Market_Impact_Event__e                   │ │
│  └────────────────────────────┬───────────────────────────────────────────┘ │
│                               ▼                                              │
│  ┌─────────────────────  Salesforce Core  ────────────────────────────────┐ │
│  │                                                                        │ │
│  │  Platform Event ──▶ MarketImpact_Detect_Segment Flow                   │ │
│  │     ├── Query ClientExposureGraph (Get Data Cloud DMO Records)         │ │
│  │     ├── Insert ~62 Market_Impact__c junction rows                      │ │
│  │     └── Custom Notification → Mobile + Slack DM (per assigned RM)      │ │
│  │                                                                        │ │
│  │  ┌──────────────────────┐                ┌─────────────────────────┐  │ │
│  │  │  AGENT: DHRUV        │                │  AGENT: PAALAK          │  │ │
│  │  │  (Employee Agent,    │                │  (Employee Agent,       │  │ │
│  │  │   RM-facing)         │  ── A2A ───▶  │   compliance,           │  │ │
│  │  │  Cloned from FAA     │  HTTP callout  │   minimal)              │  │ │
│  │  │  4 new topics        │  to Agent API  │  1 topic                │  │ │
│  │  │  5 custom actions    │  ◀───────────  │  1 action               │  │ │
│  │  │  4 Flex prompts      │  JSON verdict  │  1 prompt               │  │ │
│  │  └──────────┬───────────┘                └─────────────────────────┘  │ │
│  │             │                                                          │ │
│  │             ├── WhatsApp Enhanced Channel (Meta test #)                │ │
│  │             ├── Slack: Salesforce Channels for Records,                │ │
│  │             │   Block Kit approval, Canvas with live SF fields         │ │
│  │             ├── Tasks / Interaction Summary auto-log                   │ │
│  │             └── LWC dashboard on Market Command Center                 │ │
│  │                                                                        │ │
│  │  Einstein Trust Layer: PII mask, zero-retention,                       │ │
│  │  MITC injection, 5-year retention, audit trail                         │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Key architectural choices

1. **Data Graph as single grounding source** for prompts that need portfolio context. One ~10ms JSON fetch replaces SOQL/retriever chains.
2. **Platform Event as the contract between Data Cloud and Salesforce Core** — async, durable, replayable.
3. **A2A handoff via HTTP callout to Paalak's Agent API endpoint** — real protocol, two agent cards visible on demo screen.
4. **Default Atlas LLM** on critical path; Hinglish quality is a best-effort prompt-engineering attempt, not an architectural dependency.
5. **WhatsApp test number (Meta Cloud API)** — bypasses 24–72 h WABA approval; demo recipients hardcoded.

---

## 3. Data model

### FSC standard objects (no schema changes)

Person Account, Household (via Party Relationship Group), Financial Account, Financial Account Party (junction for multi-owner), Securities Holding, Security, Financial Goal, Interaction Summary, Life Event, Action Plan, Record Alert, Actionable Relationship Center.

### Custom Salesforce objects (3)

#### `Market_Event__c`
RM-visible mirror of a Data Cloud streaming event.
| Field | Type | Notes |
|---|---|---|
| Name | Auto-Number | `MEVT-{0000}` |
| Symbol__c | Text(20) | e.g. `BANKNIFTY` |
| Event_Type__c | Picklist | `RBI_MPC`, `IT_SELLOFF`, `EARNINGS_BEAT`, `EARNINGS_MISS`, `OTHER` |
| Pct_Change__c | Number(5,2) | Negative = down |
| Sector__c | Picklist | `Banking`, `IT`, `Auto`, `Pharma`, `FMCG`, `Energy`, `Macro` |
| Severity__c | Picklist | `Low`, `Medium`, `High`, `Critical` |
| Trigger_Time__c | DateTime | |
| Source__c | Text | e.g. `RBI Press Release` |

#### `Market_Impact__c`
Junction: Account ↔ Market_Event.
| Field | Type | Notes |
|---|---|---|
| Account__c | Lookup(Account) | |
| Event__c | Lookup(Market_Event__c) | |
| Exposure_Amount__c | Currency | Absolute INR |
| Exposure_Pct_of_AUM__c | Number(5,2) | |
| RM_Action_Required__c | Checkbox | True if Pct_of_AUM ≥ 20 |
| Severity_Score__c | Number(5,2) | `Exposure_Pct_of_AUM × abs(Event.Pct_Change)` |

#### `Custom_Trade_Request__c`
Slack approval target.
| Field | Type | Notes |
|---|---|---|
| Client__c | Lookup(Account) | |
| Instrument__c | Text | e.g. `Nifty Bees ETF` |
| Amount__c | Currency | |
| Rationale__c | Long Text Area | RM-supplied or agent-drafted |
| RM__c | Lookup(User) | |
| Approver__c | Lookup(User) | |
| Status__c | Picklist | `Draft`, `Pending`, `Approved`, `Rejected` |
| Slack_Channel_Id__c | Text(80) | Set by Slack flow |

### Data Cloud DMOs (5) + Data Graph (1)

| DMO | Source | Notes |
|---|---|---|
| `UnifiedIndividual` | Standard, mapped from Person Account | |
| `FinancialAccount__dlm` | FSC `FinancialAccount` | |
| `SecuritiesHolding__dlm` | FSC `SecuritiesHolding` | |
| `Security__dlm` | Custom, seeded CSV | 50 securities (NIFTY 50 + 3 ETFs) |
| `MarketEvent__dlm` | Streaming Ingestion API | Real-time inbound |

**Data Graph: `ClientExposureGraph`**
Root: `UnifiedIndividual` → `FinancialAccount__dlm` → `SecuritiesHolding__dlm` → `Security__dlm` → (related) `MarketEvent__dlm` (via Symbol/Sector match).

Single grounding source for all portfolio-aware prompts.

### Test data plan

- **450 Person Accounts** with Indian names + Mumbai addresses, AUM distributed log-normal ₹50L–₹15Cr
- **150 Households** (via Party Relationship Group) — average 3 members
- **50 Securities** = NIFTY 50 + 3 ETFs (Bank Bees, Nifty Bees, Liquid Bees)
- **~2,000 Securities Holdings** engineered so:
  - Exactly **62 accounts** have ≥20% Bank-Nifty / rate-sensitive exposure
  - Exactly **8 of those 62** are owned by user `Vikram Rao`
  - **Priya Sharma** (Bandra, ₹1.8 Cr AUM, **28% Bank Nifty**) is the named hero client owned by Vikram
  - Rohit Kapoor and Meera Desai also owned by Vikram, top-3 by Severity Score
- Generated by a Python script in `scripts/seed/seed_data.py`; loaded via Data Loader

---

## 4. Agent design

### Dhruv (RM Co-Pilot)

- **Type**: Employee Agent
- **Cloned from**: GA Financial Advisor Assistance template (which already ships *Client Meeting Preparation* topic with Client/Household Summary, Portfolio Performance, Allocation, Life Events, Financial Plan Summary actions)

#### Topics (4 new)

| Topic | Trigger phrasing | Actions |
|---|---|---|
| **Market Event Briefing** | "What happened in the market?" / "Brief me on today's event" / proactive on platform event | `Get Impacted Clients` |
| **Client Outreach Drafting** | "Draft a nudge for top 3" / "Draft a message for Priya" | `Draft Client Outreach` → `Validate Compliance` (A2A to Paalak) → `Send WhatsApp Nudge` |
| **Approval Routing** | "Request approval for Priya's ₹40L rotation" | `Request Trade Approval` |
| **Pre-Call Brief Assembly** | "Brief me on Priya before the call" / proactive 10 min before scheduled Event | `Assemble Pre-Call Brief` |

#### Custom Actions (5)

| Action | Reference type | Purpose |
|---|---|---|
| `Get Impacted Clients` | Flow | Query `Market_Impact__c` for current user, ranked by `Severity_Score`. Returns top N. |
| `Draft Client Outreach` | Prompt (Flex) | Per-client message generation, grounded on `ClientExposureGraph` + `Market_Event__c` |
| `Send WhatsApp Nudge` | Flow | Wraps Enhanced WhatsApp Channel `Send Conversation Messages` |
| `Request Trade Approval` | Flow | Creates `Custom_Trade_Request__c` (which auto-triggers Slack flow) |
| `Assemble Pre-Call Brief` | Prompt (Flex) + Flow | Pulls Household + Holdings + last 3 Interaction Summaries + active Life Events |

#### Flex Prompt templates (4)

| Prompt | Grounding | Output |
|---|---|---|
| `Market Event Talking Points` | `Market_Event__c` + `ClientExposureGraph` (firm-wide aggregate) | 3 bullet talking points + 1 risk callout |
| `Personalized Client Nudge` | `Account` + `ClientExposureGraph` + RA snippet (Intelligent Context) | Hinglish WhatsApp message body, ≤220 chars |
| `360° Pre-Call Brief` | `Account` + `Household` + `Interaction Summary` + `Life Event` | Structured brief: holdings heatmap, life events, last 3 interactions, 2 talking points |
| `Compliance Validation` | (Paalak's prompt) Input message + SEBI Jan 2025 rules | JSON: `{verdict, reason, message_with_disclosure}` |

### Paalak (Compliance)

- **Type**: Employee Agent (no UI; called via Agent API)
- **Single topic**: Compliance Validation
- **Single action**: `Validate Message` — takes a draft outreach + client context, returns approve/revise/block + reason + message with MITC disclosure injected if needed
- **Single prompt**: `Compliance Validation` (above)
- **Validation checks** (rules embedded in prompt):
  1. No personalized buy/sell language (only "consider," "review," "discuss")
  2. MITC disclosure present in messages mentioning specific instruments
  3. RA-report citation if a stock is named
  4. Toxicity / PII safety

A2A is implemented as: Dhruv's `Draft Client Outreach` Flow does an HTTP callout to Paalak's published Agent API endpoint, passing the draft + context, awaiting verdict, then routing.

---

## 5. Pipelines (Flows + events)

### Flows (6)

| Flow | Type | Purpose |
|---|---|---|
| `MarketImpact_Detect_Segment` | Platform-Event-triggered (`Market_Impact_Event__e`) | Query Data Graph; insert `Market_Impact__c` rows; fire Custom Notifications + Slack DMs to assigned RMs |
| `Draft_Client_Outreach` | Autolaunched (called by Dhruv action) | Per-client: invoke prompt → call `Compliance_Check_A2A` → return final message |
| `Send_WhatsApp_Template` | Autolaunched (called by Dhruv action) | Wraps `Send Conversation Messages` standard action with `portfolio_alert_v1` UTILITY template |
| `Slack_Trade_Approval` | Record-triggered on `Custom_Trade_Request__c` insert | Auto-create Salesforce Channel in Slack; post Block Kit approval card; populate Canvas with live SF fields |
| `Compliance_Check_A2A` | Autolaunched | HTTP callout to Paalak Agent API; parse JSON verdict |
| `Pre_Call_Brief` | Schedule-triggered (10 min before Event) | Build brief via prompt; fire Custom Notification |

### Platform events (1)

`Market_Impact_Event__e` — fields: `Event_Id__c`, `Symbol__c`, `Sector__c`, `Pct_Change__c`, `Severity__c`. Published by Data Cloud Data Action; subscribed by `MarketImpact_Detect_Segment` Flow.

### WhatsApp inbound

Omni-Channel Flow on incoming `ConversationEntry` → identifies the contact → routes to Dhruv → auto-creates a Task on the Contact timeline. Closes the round-trip in <5 s.

---

## 6. Channel surfaces

| Surface | What lives there | Setup window |
|---|---|---|
| **Salesforce Mobile App (iPhone)** | "Ask Agentforce" voice/text modal, Custom Notifications, Pre-Call Brief modal, Market Command Center home page | Day 1, ~30 min |
| **WhatsApp** | Meta Cloud API test number, 1 pre-approved UTILITY template (`portfolio_alert_v1`), real outbound + inbound | Day 1 evening (~2 h) — ASYNC dependency, start early |
| **Slack** | Free workspace, Salesforce for Slack app, Salesforce Channels for Records on `Custom_Trade_Request__c`, Block Kit approval card, Canvas with live SF fields | Day 2, ~1 h |
| **Dashboard / Tableau stand-in** | Embedded Lightning dashboard ("Firmwide Exposure" by sector × advisor) on Market Command Center page. CRM Analytics if available; else stock LWC + Apex bar chart | Day 5 polish, ~1 h |
| **Einstein Trust Layer** | Setup → Einstein Generative AI Audit Trail. Navigate during demo to one entry showing PII mask + zero-retention + MITC + 5-year retention | Day 5, ~15 min |

---

## 7. Five-minute video shot list (matches research's 7 wow moments)

| Time | Wow # | Shot | Risk |
|---|---|---|---|
| 0:00–0:12 | — | Cold open: Vikram on BKC sidewalk, RBI alert on phone | Low (B-roll) |
| 0:12–0:30 | **#1** | "Hey Siri, Talk to Agentforce" → Hinglish voice query | **Stretch** — film last |
| 0:30–1:30 | **#2** | Reasoning trace: 450 → 62 → 8; dashboard animates in B-roll | Low |
| 1:30–2:30 | **#3** | Hinglish draft + Paalak A2A panel showing two agent cards | **Stretch** — film last |
| 2:30–3:15 | **#4** | WhatsApp send + reply on real phone + auto-task in CRM | Medium (Meta test #) |
| 3:15–3:50 | **#5** | Slack channel + Canvas + Block Kit approve | Low |
| 3:50–4:20 | **#6** | Phone buzzes; pre-call brief unfolds | Low |
| 4:20–4:45 | **#7** | Trust Layer audit reveal | Low |
| 4:45–5:00 | — | Metric reveal + tagline | Low |

**Recording strategy**: Record the must-work set (#2, #4, #5, #6, #7) first. Voice/Siri (#1) and Paalak A2A (#3) are filmed last — if blocked, edit them out and use the remaining 4:30 of footage. The cold open + closing tagline are B-roll filmed any time.

---

## 8. Five-day build sequence

> Today is **2026-04-28**. Submission is **2026-05-03**.

### Day 1 — 04-28 evening + 04-29 — Org foundation

- Verify org has Agentforce + Data Cloud + FSC enabled (sanity check)
- **Verify Einstein Trust Layer audit trail is enabled** — Setup → Einstein Generative AI → Audit Trail. If off, enable it now (Wow #7 depends on this)
- Create user `Vikram Rao` (or designate self as Vikram for demo)
- **Start Meta WhatsApp test number setup TONIGHT** — async dependency
- Generate seeded CSVs via `scripts/seed/seed_data.py`; load via Data Loader
- Create custom objects: `Market_Event__c`, `Market_Impact__c`, `Custom_Trade_Request__c`
- Add `Preferred_Channel__c` to Account if standard FSC field is unavailable; default the 3 hero clients to `WhatsApp`
- Build a basic Market Command Center Lightning app + home page (placeholder)
- ✅ **Milestone**: 450 Person Accounts visible; 8 owned by Vikram; Priya Sharma exists with correct holdings; Trust Layer audit trail confirmed on

### Day 2 — 04-30 — Data pipeline

- Map 5 DMOs in Data Cloud
- Build `ClientExposureGraph` Data Graph; verify JSON output
- Build Streaming Ingestion connector for `MarketEvent__dlm`
- Write Python event simulator (`scripts/simulator/post_event.py`)
- Build Data Action with filter → Platform Event `Market_Impact_Event__e`
- Build `MarketImpact_Detect_Segment` Flow
- Side-task: create Slack workspace, install Salesforce for Slack, complete user mappings
- ✅ **Milestone**: fire event → 62 `Market_Impact__c` rows + Custom Notifications arrive

### Day 3 — 05-01 — Agent core (Dhruv)

- Clone Financial Advisor Assistance template into `Dhruv`
- Add 4 topics; wire 5 custom actions (Flow-based for deterministic, Prompt-based for LLM)
- Build 4 Flex prompt templates with Data Graph grounding
- Test in Conversation Preview
- ✅ **Milestone**: Dhruv answers "Show me clients impacted by RBI rate cut" with the correct 8 names

### Day 4 — 05-02 — Channels + Paalak — HARD CUT DAY

- Build WhatsApp Enhanced Channel + `portfolio_alert_v1` template + `Send_WhatsApp_Template` Flow + Omni-Channel inbound flow
- Build `Custom_Trade_Request__c` record-triggered Flow + Slack Block Kit approval card + Canvas with live fields
- Build `Pre_Call_Brief` schedule-triggered Flow
- Build **Paalak agent** (1 topic, 1 action, 1 prompt) + `Compliance_Check_A2A` Flow with HTTP callout
- Build embedded dashboard on Market Command Center
- ✅ **Milestone**: end-to-end anchor scenario runs at least once on the org

### Day 5 — 05-03 — Polish + record + submit

- Setup Siri Shortcut "Talk to Agentforce" on demo iPhone (try Voice)
- Test full 5-min end-to-end in the org **3 times**
- Record video (Descript or CapCut). Voiceover separately on a decent mic
- Edit, burn captions, export 1080p H.264
- Write README + architecture diagram + screenshots in repo
- Build 20-page appendix deck
- Submit to hackathon portal (YouTube unlisted link + GitHub URL)

---

## 9. Risk register

| Risk | Probability | Impact | Mitigation / cut |
|---|---|---|---|
| Bedrock Claude not enabled in org | High | Low | Use default Atlas (already non-critical) |
| Meta test number not provisioned in time | Medium | High | Mock WhatsApp PiP overlay in editor |
| Data Graph performance >2s | Low | Medium | Pre-cache via Calculated Insight |
| Voice / Siri Shortcut fails on demo iPhone | Medium | Low | Cut shot, lose 15 s of video |
| Paalak A2A endpoint flaky | Medium | Medium | Inline validation as a prompt step inside Dhruv (still on screen, no agent-card handshake) |
| Day 3 or Day 4 slips | High | Critical | Sacrifice order: Voice → A2A → Tableau dashboard polish → Pre-Call Brief schedule trigger (replace with manual trigger) → Hinglish (drop to English-only) |
| Custom Notifications not arriving on iPhone | Low | Medium | Fall back to in-app toast in Salesforce Mobile |
| Conversation Preview behaves differently from Mobile | Medium | Medium | Test on Mobile by Day 4 evening; keep Conversation Preview as fallback recording surface |
| Org credentials revoked by organisers mid-build | Low | Critical | Daily SFDX `force:source:retrieve` to GitHub repo |

### Hard rule

If anything is not working by **end of Day 4 (2026-05-02 night)**, it is cut. **Day 5 is recording, not building.**

---

## 10. Submission checklist

- [ ] YouTube unlisted video, 4:45–4:55, 1080p H.264, captions burned, filename `Dhruv_Market_Monitoring_Agent_Team[Name]_AWT_Mumbai_2026.mp4`
- [ ] GitHub public repo with: SFDX source, README, architecture diagram (PNG), screenshots, seed-data script, Python simulator
- [ ] Admin login credentials for a dedicated Judging User
- [ ] Text description under hackathon portal word count
- [ ] Products / APIs list (see appendix in research)
- [ ] Further improvements list (see appendix in research)
- [ ] 20-page appendix deck, on standby for live Showdown Q&A

---

## 11. Pointers and conventions

- All custom objects, flows, prompts use the prefix `Dhruv_` or live in the `force-app/main/default/` SFDX folder
- Agent name: `Dhruv` (literal); compliance agent name: `Paalak`
- LLM calls go through Einstein Trust Layer; no direct LLM calls from Apex
- Apex callouts go through Named Credential `Paalak_AgentAPI`
- Demo recipient phone numbers stored in custom metadata `Demo_Recipients__mdt` (NEVER hardcode in Flow XML)
- Seed data CSVs live in `scripts/seed/data/` (gitignored if PII; allowed if synthetic — these are synthetic so committed)
