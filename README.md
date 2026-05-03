# Dhruv — AI Market Monitoring Co-Pilot for Wealth RMs

**AWT Agentforce Hackathon Mumbai 2026 | BFSI Track**

> Built on Salesforce Agentforce. Designed for Wealth Relationship Managers who can't afford to miss a market event.

---

## What Is Dhruv?

Dhruv is an Agentforce Employee Agent that acts as a real-time market monitoring co-pilot for Wealth Relationship Managers (RMs) in the BFSI sector. When a market event like an RBI rate cut fires, Dhruv automatically identifies which clients are most at risk, drafts personalised WhatsApp outreach in Hinglish, routes trade approvals through Slack, auto-schedules meetings from client replies, and delivers a contextual pre-call brief — all from the RM's mobile phone, in under 4 minutes.

---

## Demo Scenario

- **Event**: RBI MPC surprises with a 25 bps repo rate cut
- **RM**: Vikram Rao, Meridian Private Wealth
- **Book**: 450 clients → 62 rate-sensitive → 8 assigned to Vikram
- **Focus client**: Priya Sharma — ₹1.8 Cr AUM, 28% Bank-Nifty exposure, ₹50L at risk

**Full flow (mobile-first):**

```
RBI alert notification
  → Market Event record in Salesforce Mobile
    → Dhruv: "Who are my impacted clients?"
      → Ranked list from Data Cloud (real-time)
        → Dhruv drafts Hinglish WhatsApp for Priya → sent via Meta API
          → Priya replies on WhatsApp
            → Webhook auto-creates calendar Event in Salesforce
              → Dhruv submits ₹50L rebalancing request → Slack approval to manager
                → Dhruv: pre-call brief before Priya's call
```

---

## Demo Video

> [INSERT YOUTUBE UNLISTED LINK]

Recorded natively on iPhone via Salesforce Mobile App. No AI-generated video, audio, or image tools used.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Salesforce Platform                   │
│                                                         │
│  Data Cloud          Agentforce (Dhruv)    FSC          │
│  ─────────────       ─────────────────     ────         │
│  ClientExposure  ←── GetImpactedClients    Account      │
│  Graph DMO           GetClientProfile      Activity     │
│  Streaming           SendWhatsApp          Custom_Trade │
│  Ingestion           SubmitApproval        _Request__c  │
│                      GetPreCallBrief                    │
│                                                         │
│  Flow Builder        Einstein Trust Layer  LWC          │
│  Platform Events     PII Masking           Market       │
│  Apex REST           Zero Retention        Command      │
│  (Webhook)           Audit Trail           Center       │
└──────────────────────┬──────────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
    Meta Cloud      Slack         Salesforce
    API (WhatsApp)  Approval      Mobile App
    Outbound +      Notifications  (RM Interface)
    Inbound Webhook
```

---

## Products, Features, Tools & APIs

| Category | Component |
|---|---|
| **Platform** | Salesforce Financial Services Cloud (FSC) |
| **AI Agent** | Agentforce Employee Agent (Dhruv) — 4 topics, 5 Apex actions |
| **AI Model** | Einstein Generative AI — Atlas model via Prompt Builder |
| **Data** | Salesforce Data Cloud — DMOs, Streaming Ingestion API, Data Actions |
| **Trust** | Einstein Trust Layer — PII masking, zero retention, 5-year audit log |
| **Mobile** | Salesforce Mobile App — primary RM interface |
| **Frontend** | Lightning Web Components — Market Command Center dashboard |
| **Messaging** | Meta Cloud API — WhatsApp Business (outbound + inbound webhook) |
| **Approvals** | Slack + Salesforce Integration — interactive trade approval messages |
| **Automation** | Flow Builder — Platform Event-triggered automations |
| **Backend** | Apex REST, Apex Invocable Actions, Named Credentials, Custom Labels |
| **Data Model** | Custom Objects: `Market_Impact__c`, `Custom_Trade_Request__c` |
| **Config** | Custom Metadata Types: `Demo_Recipients__mdt` |
| **Simulator** | Python — market event simulator posting Salesforce Platform Events |

---

## Repository Structure

```
force-app/main/default/
├── classes/
│   ├── GetImpactedClientsAction.cls       ← Data Cloud query, ranked list
│   ├── GetClientProfileAction.cls         ← 360° client profile fetch
│   ├── SendWhatsAppNudgeAction.cls        ← Meta Cloud API callout + Task log
│   ├── SubmitTradeApprovalAction.cls      ← Trade record + Slack notification
│   ├── GetPreCallBriefAction.cls          ← Contextual pre-call brief
│   ├── WhatsAppWebhookHandler.cls         ← Inbound webhook → Event creation
│   └── MarketCommandCenterController.cls  ← LWC backend
├── lwc/
│   └── marketCommandCenter/               ← Mobile-first dashboard component
├── objects/
│   ├── Market_Impact__c/                  ← Per-client market impact record
│   └── Custom_Trade_Request__c/           ← Trade approval workflow object
├── flows/
│   └── Data_Cloud_Triggered_Flow.flow-meta.xml
├── bots/
│   └── Dhruv/                             ← Agentforce agent definition
├── labels/
│   └── CustomLabels.labels-meta.xml       ← Meta API credentials
└── permissionsets/

scripts/
├── simulator/
│   ├── post_event.py                      ← Fires market event to Salesforce
│   └── events/rbi_mpc_25bps_cut.json      ← RBI rate cut event payload
└── seed/                                  ← Demo data generators

docs/
├── DEMO_SCRIPT.md                         ← Full shot-by-shot demo script
└── superpowers/specs/                     ← Design specification
```

---

## Setup for Judges

### Prerequisites

- Salesforce CLI (`sf`) installed
- Node.js 18+
- Access to the provided org (credentials in `SUBMISSION.md`)

### Deploy to Org

```bash
# Authenticate
sf org login web --alias dhruv-demo

# Deploy all metadata
sf project deploy start --source-dir force-app

# Run Apex tests
sf apex run test --test-level RunLocalTests --wait 10
```

### Run the Market Event Simulator

```bash
cd scripts/simulator
pip3 install -r requirements.txt
cp .env.example .env   # Fill in org credentials

# Fire the RBI rate cut event
set -a && source .env && set +a && DC_BATCH=1 python3 post_event.py events/rbi_mpc_25bps_cut.json
```

This creates 62 `Market_Impact__c` records, 8 owned by Vikram Rao.

### Key Pages for Judges

| Page | URL path |
|---|---|
| Market Command Center | Lightning App → Market Command Center tab |
| Dhruv Agent | Agentforce → Dhruv → Preview |
| Priya Sharma Account | Accounts → Priya Sharma |
| Audit Trail | Setup → Einstein Generative AI → Audit Trail |

---

## Further Improvements

1. **Live market data feed** — replace the Python simulator with a real NSE/BSE streaming feed via MuleSoft
2. **Multi-language support** — extend Hinglish drafting to Marathi, Tamil, Gujarati using client profile language detection
3. **Voice interface** — Siri Shortcut integration so the RM can invoke Dhruv hands-free
4. **Account Aggregator (AA) integration** — pull real-time consolidated portfolio data from the RBI's AA framework
5. **Manager mobile approval** — allow the manager to approve trades directly from the Slack message without switching apps
6. **Predictive churn scoring** — Data Cloud AI to flag clients likely to move assets post-event before they call a competitor
7. **Automated SEBI/AMFI reporting** — auto-generate regulatory reports of all agent-triggered client communications
8. **Branch manager view** — multi-RM portfolio command center for branch managers to reallocate clients during a crisis

---

## Submission Notes

- **Original work**: Built entirely by Jeet Bhardiya for the AWT Agentforce Hackathon 2026
- **No AI-generated media**: Demo video recorded natively on iPhone. No AI video, audio, or image generation tools used
- **No third-party trademarks**: All client names, AUM figures, and portfolio data are entirely synthetic
- **Admin credentials**: See `SUBMISSION.md` (not committed to repo — provided separately to judges)

---

*Built on Salesforce Agentforce. AWT Hackathon Mumbai 2026 — BFSI Track.*
