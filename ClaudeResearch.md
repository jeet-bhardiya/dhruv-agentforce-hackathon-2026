# Dhruv: the market monitoring agent that wins Mumbai

**Pitch in one sentence.** Build **Dhruv** ("north star" in Hindi) — a voice-first, vernacular, compliance-grade mobile co-pilot that auto-detects market events, hyper-segments impacted clients in seconds via Data Cloud, drafts Hinglish WhatsApp nudges, and orchestrates a Slack approval workflow with a Tableau Pulse impact heatmap — all from the same Agentforce 360 agent running across Salesforce Mobile, Slack, and WhatsApp. You will win the **BFSI industry track at AWT Mumbai 2026 (May 19, Jio World Convention Center, ₹10 lakh prize)** by combining five things almost no other team will have together: **Agentforce Voice + Hinglish code-switching + multi-agent A2A orchestration + SEBI-compliant human-in-the-loop + a regulator-grade Einstein Trust Layer audit trail reveal**. This report is your build plan, demo script, and judging playbook.

---

## A. Executive summary — why this wins

The BFSI track at AWT Mumbai will be the most crowded and the most politically weighted (Arundhati Bhattacharya has publicly named BFSI, retail, manufacturing as her 2026 priorities and specifically calls out "grievance portals, transactions, pilots in banks"). Winning requires being both **more Indian** and **more technically advanced** than any US-templated demo.

Our extrapolated rubric is **Creativity 35%, Business Relevance 30%, Demo Delivery 20%, Technical Implementation 15%** (based on TDX Bengaluru 2025's published 40/40/20 plus Devpost Virtual Hackathon criteria). Two past winners tell us everything: **Team Agent Halo** ($100K TDX 2025) won by (a) aligning explicitly with Salesforce's current GTM story — multi-agent networks — and (b) submitting a 20-page appendix deck alongside the 5-minute video. **Team 4DS** (AWT NYC 2024) won by keeping UX brutally simple. We will do both: simple UX for Vikram the RM, multi-agent orchestration under the hood, and a supplementary deck on standby for the live Showdown Q&A.

Our anchor scenario is an **RBI MPC surprise 25bps rate cut** — macro, universally understood in Mumbai, and crucially **SEBI-safe** because it's information-about-macro, not a stock-specific recommendation. The secondary scenario is an **IT sector selloff on US H-1B news**, which lets us demo named-stock impact on Infosys/TCS/Wipro holders while staying grounded in licensed RA research. These two give us enough narrative range to fill five minutes without drifting into regulated advisory territory.

The three differentiating moves that judges will not see in any other submission: **(1)** an **Agent2Agent handoff** from Dhruv (the RM-facing agent) to a Compliance Agent that reviews every client message against SEBI's January 2025 AI guidelines before it goes out, visible on screen as an agent card exchange; **(2)** a **Hindi voice trigger from the Salesforce Mobile App via Siri Shortcut** ("Hey Siri, Talk to Agentforce") with an Atlas-routed response in code-switched Hinglish — this is GA in April 2026 and demonstrably Indian; **(3)** a closing **Einstein Trust Layer audit reveal** showing PII-masked tokens, zero-retention LLM call, SEBI MITC disclosure injected, and a 5-year retention stamp — regulator-grade proof that a Mumbai BFSI judge will love.

---

## B. Solution architecture

### The agent mesh
Three Agentforce 360 agents, orchestrated via native topic-pass-through plus one external A2A handshake:

**Dhruv (RM Co-Pilot Agent)** — Employee Agent type, default surface is Salesforce Mobile App + Slack. Clones the GA **Financial Advisor Assistance** template (which already ships the Client Meeting Preparation topic with Client/Household Summary, Portfolio Performance, Allocation, Life Events, Financial Plan Summary actions) and extends it with four new topics: Market Event Briefing, Client Outreach Drafting, Approval Routing, Pre-Call Brief Assembly.

**Vigil (Market Monitoring Agent)** — Headless Agent type, no UI. Triggered by Data Cloud Data Actions on streaming market-event DMOs. Its job: detect threshold breach, call the ClientExposure Data Graph, rank impacted clients, publish a platform event that Dhruv subscribes to. This is the Agentforce 2dx "Ambient Agent" archetype.

**Paalak (Compliance Agent)** — Headless Employee Agent. Invoked via A2A protocol by Dhruv whenever a client-bound message is drafted. Validates against SEBI January 2025 AI guidelines (no personalized buy/sell language, MITC disclosure present, RA-report citation if named-stock), returns approve/revise/block with reasons. Shown visually as a second agent card during the demo.

### Data model additions to FSC Core
You use FSC Core (not the managed package — all Agentforce innovation targets Core). Build on the standard model: Person Account + Household (Party Relationship Group), Financial Account, Financial Account Party (junction for multi-owner), Securities Holding, Security, Financial Goal, Financial Plan, Interaction Summary, Life Event, Record Alert, Action Plan.

Three custom additions in Salesforce Core:
- `Market_Event__c` — lightweight mirror of the Data Cloud DMO for RM-visible timeline (Symbol, Event Type, Pct Change, Sector, Severity, Trigger Time, Source).
- `Market_Impact__c` — junction between Market_Event and Account, with Exposure_Amount, Exposure_Pct_of_AUM, RM_Action_Required, and a rolled-up severity score.
- `Custom_Trade_Request__c` — for the Slack approval workflow, fields Client, Instrument, Amount, Rationale, RM, Approver, Status (Draft/Pending/Approved/Rejected), Slack_Channel_Id, Approval_Work_Item_Id.

In Data Cloud (Data 360), five DMOs: `UnifiedIndividual` (standard), `FinancialAccount__dlm`, `SecuritiesHolding__dlm`, custom `Security__dlm` (ticker master), custom `MarketEvent__dlm` (streamed events). One **Data Graph** named `ClientExposureGraph` rooted on UnifiedIndividual → Account → FinancialAccount → SecuritiesHolding → Security; this is the single grounding source for every Dhruv prompt that needs client portfolio context — one ~10ms JSON call replaces multi-step SOQL/retriever chains.

### Event-to-outreach pipeline
A Python simulator (Heroku or local) POSTs a market event JSON to Data Cloud's **Streaming Ingestion API** → `MarketEvent__dlm`. A **Data Action** with filter `pctChange ≤ -0.05 OR eventType = 'RBI_MPC'` targets a Salesforce Platform Event `Market_Impact_Event__e`. A platform-event-triggered Flow queries the `ClientExposureGraph` for all Accounts with holdings in the affected Symbol or sector, creates `Market_Impact__c` junctions for the 62 hits, fires Custom Notifications to each RM's Salesforce Mobile and posts to each RM's Slack via the Send a Slack Direct Message standard action. Simultaneously, the same Flow publishes a second platform event that Vigil (headless) subscribes to, which invokes Dhruv proactively on Vikram's mobile with a pre-assembled briefing.

### Communication surfaces
WhatsApp via **Salesforce Enhanced WhatsApp Channel** (Meta-direct WABA, not Twilio — Twilio numbers cannot power the enhanced channel). Outbound proactive messages use a pre-approved UTILITY template `portfolio_alert_hindi_v1` sent through the `Send Conversation Messages` Flow action wrapped as a custom Agent Action "Send Client Nudge". Inbound replies land in `ConversationEntry` records; an Omni-Channel Flow routes to Dhruv which auto-logs the reply as a Task on the Client's Contact timeline.

Slack via the **Slack Platform Connector** + **Salesforce Channels for Records** (GA April 2026). Every `Custom_Trade_Request__c` auto-creates a Salesforce channel mapped to the record; RM + approving Manager + Research Desk bot are auto-added. Approval posts a Block Kit card with Approve/Reject buttons that hit the standard approval URL; approval writes back to the record and auto-creates a Task on the Client Contact. Research collaboration uses **Slack Canvas with live Salesforce fields** inside the same channel so the team sees real-time exposure numbers.

Tableau via **Tableau Pulse** metric "Firmwide Exposure to Affected Positions" followed by each RM, plus a **Tableau embedded heatmap** (Advisor × Sector, color = Σ exposure × |pct change|) on a new "Market Command Center" Lightning app home page.

### Flows, prompts, custom actions
Six Flows: `MarketImpact_Detect_Segment_Flow` (platform-event triggered), `Draft_Client_Outreach_Flow` (invoked by agent, per-client), `Send_WhatsApp_Template_Flow` (wraps Send Conversation Messages), `Slack_Trade_Approval_Flow` (record-triggered on Custom_Trade_Request__c), `Compliance_Check_A2A_Flow` (HTTP callout to Paalak via Agent Card), `Pre_Call_Brief_Flow` (triggered 10 min before a scheduled Event, uses Data Graph + recent Interaction Summaries).

Four Prompt Builder templates (all Flex type): `Market Event Talking Points`, `Personalized Client Nudge (Hindi/English)`, `360° Pre-Call Brief`, `Post-Outreach Summary`. All grounded on `ClientExposureGraph` plus unstructured RA research PDFs ingested via **Intelligent Context** (the Dreamforce '25 low-code unstructured-data pipeline).

Five custom Agent Actions (Reference Action Type = Flow or Prompt): `Get Impacted Clients`, `Draft Client Outreach`, `Send WhatsApp Nudge`, `Request Trade Approval`, `Assemble Pre-Call Brief`.

---

## C. The seven wow moments

These are the spine of the 5-minute video, ranked by impact-to-effort ratio.

**Wow 1 — Voice-triggered agent launch (0:15–0:30).** Vikram says "Hey Siri, Talk to Agentforce" on his iPhone (Siri Shortcut, GA in Salesforce Mobile App since Dreamforce '25). The Ask Agentforce bar opens in voice mode. He speaks in Hinglish: *"Market mein kya chal raha hai aaj, kaunse clients ko call karna chahiye?"* The agent transcript renders in real time with Devanagari characters mixed with English. **What the judge sees:** a genuinely Indian RM interaction, not a Californian one.

**Wow 2 — Synthetic RBI MPC event injection with live hyper-segmentation (0:45–1:30).** Teammate off-camera triggers a Postman request (or a scheduled Flow fires at T+45s). An RBI MPC press-release event lands in Data Cloud; Vigil's Data Action fires; 450 clients are queried; **62 are returned in ~2 seconds**. On screen: Dhruv streams its reasoning trace — "Querying ClientExposureGraph... 62 clients hold Bank Nifty or rate-sensitive NBFC exposure ≥20% of AUM... 8 are assigned to you." Below, a **Tableau Pulse card animates** the firmwide exposure metric in real time. **What the judge sees:** the hyper-segmentation promise literally executed on stage.

**Wow 3 — Hinglish WhatsApp draft with compliance A2A handoff (1:30–2:30).** Vikram taps "Draft outreach for top 3 by exposure." Dhruv drafts a Hinglish WhatsApp message for Priya Sharma (Bandra, ₹1.8 Cr AUM, 28% Bank Nifty exposure). **Simultaneously on a small A2A panel**, Paalak the Compliance Agent receives an agent card, validates against SEBI Jan 2025 AI guidelines, injects the MITC disclaimer, returns "Approved with disclosure appended" — visible as a second agent card exchange. The final message renders in Hindi Devanagari + English code-switch. **What the judge sees:** regulated-industry-grade multi-agent orchestration, not a toy demo.

**Wow 4 — One-tap WhatsApp send + live reply (2:30–3:15).** Vikram taps "Send to all 3 via WhatsApp." The message fires through the Enhanced WhatsApp channel. Cut to a physical phone in frame — the WhatsApp message arrives. A teammate (playing Priya) replies "Call me at 3pm." The reply appears on screen inside the Contact timeline **within 5 seconds** as an auto-logged Task. **What the judge sees:** the full WhatsApp round-trip working, which ~0% of hackathon demos pull off reliably.

**Wow 5 — Slack approval with Salesforce channel + Canvas (3:15–3:50).** Priya wants to rotate ₹40L from a debt fund into equity. Vikram says to Dhruv: "Request approval for Priya's custom trade." Dhruv creates a `Custom_Trade_Request__c`, which auto-provisions a Salesforce channel in Slack, auto-adds Vikram + his Manager Rajesh + the Research Desk. A Block Kit approval card posts; the channel's **Canvas shows live Salesforce fields** (exposure %, risk profile, last interaction). Rajesh clicks Approve; within 2 seconds the record status flips, a Task logs on Priya's Contact, and Dhruv announces back in voice: *"Approved by Rajesh at 3:47 PM. Next step — book the trade."* **What the judge sees:** the DF25 "humans + agents together in Slack" theme executed cleanly.

**Wow 6 — Pre-Call Brief push 60 seconds before the simulated call (3:50–4:20).** At 2:59 PM the RM's phone buzzes with a Custom Notification: "Pre-Call Brief ready — Priya Sharma in 60s". Tap opens a full-screen brief: household (spouse Rohan, 2 kids in JNV), last 3 interactions, current holdings heatmap, active life events (daughter's admission to MIT — flagged as upcoming education goal), two suggested talking points referencing yesterday's outreach. Generated in ~3 seconds by the Pre_Call_Brief_Flow + Flex prompt grounded on the Data Graph. **What the judge sees:** the "360° brief delivered moments before the call" spec literally realized.

**Wow 7 — Einstein Trust Layer audit reveal (4:20–4:45).** Final beat before the close. Full-screen view of the Trust Layer audit trail for one message: prompt token count, **PII tokens masked** (Priya → [CLIENT_001], ₹1.8 Cr → [AMOUNT_NNNN]), zero-retention flag on the Claude-via-Bedrock LLM call, SEBI MITC disclosure line detected, toxicity score 0.02, A2A handshake with Paalak logged, final output retention stamped **5 years per SEBI master circular**. **What the judge sees:** a regulator-grade audit trail that makes this ship-ready for any Indian bank's CISO and Chief Compliance Officer. This single 15-second beat will distinguish you from every flashy-but-non-compliant submission.

---

## D. Shot-by-shot 5-minute video script

**Format:** 1920×1080 recording, content framed in centered 1080×1080 safe area for mobile rewatch, burned-in English captions (judges often watch on mute), scripted voiceover by one calm narrator (Indian accent, female preferred — echoes Arundhati), a persistent bottom system bar that lights up each system as touched: **FSC | Data 360 | Agentforce | Slack | WhatsApp | Tableau**.

**0:00–0:12 — Cold open.** Split-screen. Left: Vikram Rao, RM at "Meridian Private Wealth Mumbai," on a crowded BKC sidewalk checking his phone; overlay "09:57 AM, April 2026". Right: a text alert "RBI MPC cuts repo 25bps — UNEXPECTED." Voiceover: *"Every Mumbai RM manages 450 clients. When the RBI surprises the market, Vikram has seven minutes before his first client calls. In those seven minutes he must know which of his 450 are exposed, what to say to them, and in which language. Today, Dhruv does it for him."*

**0:12–0:30 — Voice launch.** Vikram raises his phone: *"Hey Siri, Talk to Agentforce."* Salesforce Mobile App opens directly into the Ask Agentforce voice modal. He says, in Hinglish: *"Aaj market mein kya hua? Kaunse clients impact hue?"* The agent avatar pulses; transcription streams in Devanagari + English.

**0:30–1:30 — Hyper-segmentation reveal.** Dhruv's reasoning trace panel slides up: *"Detecting event... RBI MPC 25bps cut... querying ClientExposureGraph across 450 assigned clients... 62 clients exposed, 8 assigned to you."* A ranked list renders: Priya Sharma (28% Bank Nifty), Rohit Kapoor (22% NBFCs), Meera Desai (19% rate-sensitive autos)... Cut-away 2 seconds to a Tableau Pulse card animating "Firmwide Exposure" from ₹0 to ₹847 Cr with a red trend arrow. Voiceover: *"In 2.1 seconds, 450 clients filtered to the 62 who matter, ranked by exposure."*

**1:30–2:30 — Draft + compliance.** Vikram taps "Draft Hinglish nudge for top 3." Dhruv streams the draft in Devanagari script. Split-screen shows Paalak agent card arriving, validating SEBI compliance, returning approval with MITC disclosure injected. Voiceover: *"Every client-bound message is reviewed agent-to-agent by our Compliance Agent, Paalak, against SEBI's January 2025 AI guidelines — before a human ever sees it."*

**2:30–3:15 — WhatsApp round-trip.** Vikram taps Send. Picture-in-picture: a physical iPhone receives the WhatsApp. A teammate types a reply "Call me at 3 PM please." Back to Salesforce: the reply appears on Priya's Contact timeline as an auto-logged Task. Voiceover: *"One tap. Three clients. Three languages. The reply is auto-logged to Salesforce in five seconds."*

**3:15–3:50 — Slack approval.** Priya (via reply) requests a ₹40L rotation. Vikram says: "Request approval for Priya's trade." A Salesforce channel auto-provisions in Slack, Canvas populates with live fields, Block Kit card posts. Manager Rajesh clicks Approve. Dhruv announces in voice: *"Approved by Rajesh at 3:47 PM."* Voiceover: *"Humans and agents, same channel, full audit trail."*

**3:50–4:20 — Pre-call brief push.** Phone buzzes at 2:59. Full-screen brief unfolds with household, holdings heatmap, life events, talking points. Voiceover: *"Sixty seconds before every call, Dhruv delivers the brief Vikram used to spend forty minutes building."*

**4:20–4:45 — Trust Layer reveal.** PII masking, zero retention, MITC injected, 5-year audit stamp. Voiceover: *"Every prompt masked, every reply de-masked, every action logged for five years per SEBI. This is agentic AI a Mumbai Chief Compliance Officer can sign off on Monday."*

**4:45–5:00 — Metric + team.** Full-screen: *"40 min → 47 sec per event. 62 clients reached in 3 min instead of 3 hours. Built in 21 days on Agentforce 360 by Team [Name], Ahmedabad."* Hold on the Dhruv logo with tagline: *"Dhruv. Your north star, on every market day."*

---

## E. Build plan — MVP first, then de-risk, then wow

**Day-ordered build sequence designed so the demo works end-to-end by Day 5 and every subsequent day adds polish, not risk.**

**Days 1–2 — Org foundation (must finish by Sunday night).** Spin up a Developer Edition org with FSC Core + Agentforce + Data Cloud enabled (Partner Trailblazer org if available). Load 450 Person Accounts + 150 Households via Data Loader from a seeded CSV with Indian names, Mumbai addresses, realistic AUM distribution. Load 50 securities (Nifty 50 + 3 ETFs) and ~2,000 Securities Holding records engineered so that exactly 62 Accounts have Bank Nifty exposure >20% and exactly 8 of those are assigned to user "Vikram Rao". Install FSC Data Kit if your org allows it; otherwise build the five DMOs manually.

**Day 3 — Data pipeline.** Create the Streaming Ingestion API connector + `MarketEvent__dlm` DLO; write the Python simulator to post events. Build the Data Action with filter, target Platform Event `Market_Impact_Event__e`. Build the platform-event-triggered Flow that queries Data Cloud (use `Get Data Cloud DMO Records` invocable action), creates `Market_Impact__c` junctions, and fires Custom Notifications. Build the `ClientExposureGraph` Data Graph. **Milestone: fire event → 62 notifications land on test user's mobile.**

**Day 4 — Agent core.** Clone Financial Advisor Assistance template. Add four custom topics. Wire the five custom Agent Actions (Flow-based). Build the four Flex prompt templates. Test all actions in Agent Builder Conversation Preview. **Milestone: Dhruv responds end-to-end in text to "Show me clients impacted by RBI rate cut" with correct list.**

**Day 5 — MVP end-to-end (DEMO-VIABLE STATE).** Build Slack integration: Salesforce Channels on `Custom_Trade_Request__c`, approval Flow with Block Kit card, user mappings. Build WhatsApp enhanced channel (start Meta WABA onboarding Day 1 — it takes 24–72 hrs), submit `portfolio_alert_hindi_v1` UTILITY template, wire `Send Conversation Messages` Flow action. Build Tableau Pulse metric + embedded heatmap. **Milestone: 80% of the demo script runs end-to-end.** If you are time-short, stop here and polish — this alone beats most submissions.

**Day 6 — Wow layer.** Build Paalak the Compliance Agent (headless) and wire the A2A handshake from Dhruv via HTTP callout to Paalak's exposed Agent Card endpoint. Wire up Agentforce Voice click-to-talk (GA). Configure the Siri Shortcut "Talk to Agentforce" on the demo iPhone. Wire Pre-Call Brief Flow triggered 10 minutes before an Event; script one scheduled Event. Write the Prompt Builder prompt for Hinglish code-switching, backed by Claude via Bedrock (inside Salesforce trust boundary — regulated-industry-grade).

**Day 7 — Demo polish.** Record all screens in 1920×1080. Record voiceover separately on a decent mic (Blue Yeti or similar, not laptop). Edit in Descript or CapCut with zoom on critical moments, system-bar overlay, burned captions. Build the **20-page appendix deck** (Agent Halo move): architecture diagram, challenge mapping, ROI calculation (₹ per RM-hour × 450 RMs × 250 market days = ₹X Cr annual productivity), roadmap, security/compliance summary, team bios. Dry-run the live pitch 3 times with 60-second Q&A drills.

**Stretch features — ONLY if core demo is rock-solid by Day 6:**
- MCP server that exposes a mock NSE/BSE Kite Connect-style tool, registered in AgentExchange, shown being discovered by Dhruv live.
- Tableau Next Concierge natural-language Q&A cutaway ("Which sector has the highest firmwide exposure this quarter?" answered in natural language).
- Offline-first low-bandwidth mode (Chrome throttled to 2G) showing the agent still queuing actions — unique Indian angle.
- Agentforce Grid bulk invocation — draft messages for all 62 clients in a spreadsheet view.

**Risk register and mitigations.** WhatsApp template approval queue: start Day 1, have Meta test number as fallback (5 free recipients, instant templates). Stage wifi failure on live Showdown day: pre-cache a local Heroku endpoint that serves the simulated event. Agentforce LLM latency variance: record the best take for the video; for live pitch, warm the session. SEBI compliance wording: have an advisor (ex-Kotak Wealth, ex-HDFC Securities RM on LinkedIn) review the scripts before filming.

---

## F. Products, features, tools, APIs used (for the submission form)

**Salesforce platform.** Agentforce 360 Platform (Agentforce Builder Canvas view, Atlas Reasoning Engine, Agent Script, Topics, Actions, Instructions, Testing Center, Agentforce Observability, Agentforce Voice click-to-talk, Agentforce Experience Layer, Intelligent Context, Agent Gateway). Salesforce Mobile App with Ask Agentforce voice input and iOS Siri Shortcut "Talk to Agentforce". Financial Services Cloud Core (Person Account, Household via Party Relationship Group, Financial Account, Financial Account Party, Securities Holding, Security, Financial Goal, Financial Plan, Interaction Summary, Life Event, Action Plan, Record Alert, Actionable Relationship Center). Agentforce for Financial Services pre-built template: Financial Advisor Assistance (Client Meeting Preparation topic, Client and Household Summaries, Portfolio Performance Summary, Current vs Target Allocation, Life Events, Financial Plan Summary). Data Cloud / Data 360 (Streaming Ingestion API, Data Lake Objects, Data Model Objects, Data Graph, Calculated Insights, Streaming Insights, Data Actions, Platform Event target). Prompt Builder (Flex templates, Data Graph grounding, merge fields). Einstein Trust Layer (PII masking, zero-retention, prompt defense, audit trail, toxicity detection). Flow (Platform Event-triggered, Record-triggered, Autolaunched, Screen Flow; AI Agent Action invocation). Apex (optional Agent API invocation). Custom objects Market_Event__c, Market_Impact__c, Custom_Trade_Request__c.

**Slack.** Slack Platform Connector, Agentforce in Slack (Employee Agent), Slack Canvas with live Salesforce fields, Salesforce Channels for Records, Slack Block Kit, Slack standard Agent Actions (Create Canvas, Send Direct Message, Post to Channel, Search Slack).

**WhatsApp.** Salesforce Enhanced WhatsApp Channel, Meta Cloud API WABA (direct), Messaging Components (Template-Based Notification), Send Conversation Messages Flow action, MessagingSession / MessagingEndUser / ConversationEntry objects, Omni-Channel Flow routing to Agentforce.

**Tableau.** Tableau Pulse (metric + followed metric + mobile notifications), Tableau Embedded Analytics LWC on FSC Market Command Center page, Tableau Semantics for shared KPI definitions.

**Protocols and open standards.** Agent2Agent (A2A) protocol (Agent Card, HTTP transport, JSON-RPC) for Dhruv ↔ Paalak handoff. Model Context Protocol (MCP) — optional stretch, MuleSoft Flex Gateway MCP Support for the NSE/BSE mock tool. Salesforce Pub/Sub API for event fan-out.

**LLM choice.** Anthropic Claude Sonnet 4.5 via Amazon Bedrock inside Salesforce trust boundary (regulated-industry-grade, first LLM fully contained within Salesforce VPC as of October 2025). Fallback: OpenAI GPT-5 via the Salesforce partnership. Both chosen specifically for superior Hinglish code-switch quality over the default Atlas xGen model.

**External services.** Python simulator on Heroku for market event injection (used only during demo). A mock research PDF corpus ingested via Intelligent Context to ground named-stock commentary. iOS native Hindi dictation for voice input.

---

## G. Further improvements with more time

Production-grade NSE/BSE tick-data pipeline via Kafka Confluent Cloud → Data Cloud MSK connector, replacing the demo simulator with real-time feeds at sub-minute latency. Full Gupshup BSP onboarding with INR billing and DLT template registration for India-compliant scaled WhatsApp sends. Marathi, Tamil, Bengali and Gujarati expansion of the Hinglish prompt templates once Agentforce Wave 3 language support reaches GA for those locales; Language IO third-party layer as safety net. Predictive propensity model in Einstein Studio BYOM (trained on historical RM outreach → client response outcomes) to rank which of the 62 impacted clients will actually benefit from a call versus a WhatsApp nudge versus waiting. Account Aggregator (AA) consent-based integration for real-time aggregated holdings across held-away assets at other banks — uniquely Indian financial rail that no other submission will have. Agentforce Grid spreadsheet-style bulk operations so Vikram can review and approve 62 drafts in one grid view. MCP server exposing a Zerodha Kite Connect wrapper for live quotes and optional order placement (with four-eyes approval). Apromore process mining layer tracking RM-agent interactions to continuously auto-tune which topics/actions actually produce client response — "agents teaching agents" loop. Headless Agent API embedded inside the bank's existing mobile app so Dhruv lives not only in Salesforce Mobile but inside the bank's own branded wealth app. Offline-first caching for Tier-2/3 India low-bandwidth scenarios. Tableau Next Concierge natural-language Q&A on the exposure data. Compliance Agent Paalak expanded from SEBI into an RBI/IRDAI-aware cross-regulatory gate suitable for cross-selling insurance and credit.

---

## H. Groundbreaking differentiators

**The regulator-grade agent.** Almost no hackathon submission leads with compliance; we will. The Einstein Trust Layer audit reveal, the A2A handoff to Paalak for SEBI validation, and the MITC disclosure auto-injection together tell the story that this is **not a prototype but a product a Mumbai bank's CISO can approve on Monday**. Arundhati Bhattacharya's publicly stated priority — "pilots in banks" — is exactly this.

**True Indian vernacular voice.** Hinglish code-switching with Claude Sonnet 4.5 inside Salesforce trust boundary, triggered by "Hey Siri, Talk to Agentforce" from the iOS home screen, with Devanagari-script streaming transcription. This is not translation, it is native code-switching — how real Indian RMs actually speak. Zero other BFSI submissions will have this.

**Multi-agent A2A orchestration visible as agent cards on screen.** Agent Halo won TDX 2025's $100K grand prize with this exact narrative — cross-org agent networks. We mirror it in a single-screen, easy-to-grasp two-agent handoff (Dhruv ↔ Paalak) that demonstrates the $10B+ Salesforce "agent mesh" thesis in 8 seconds of video. Mechanically straightforward, rhetorically devastating.

**The "agents teaching agents" meta-moment (stretch).** If we have time to add it: show Paalak observing one of Dhruv's earlier outputs flagged by a user 👎 via the Feedback API, then using Session Tracing to auto-draft a new instruction added to Dhruv's topic. This is the Benioff keynote line literally executed, and Session Tracing is brand-new in TDX 2026 Headless 360 — virtually no submission will have integrated it.

**The unexpected angle: offline-first for Tier-2/3 India.** Throttle Chrome DevTools to 2G, show Dhruv queueing actions and syncing when the connection returns. India's next 500M wealth clients are not on fiber; a Mumbai BFSI judge will recognize this as the difference between a demo and a product. If time permits, this single moment wins the "Creative/Innovation" 35% alone.

---

## I. Judging criteria and how to hit each

**Creativity / Innovation — ~35% weight.** Hit it with (a) the A2A compliance handoff visible on screen, (b) vernacular voice trigger via Siri Shortcut, (c) the optional "agents teaching agents" meta-moment, and (d) if built, the offline-first Tier-2/3 angle. Judges at AWT Mumbai will watch 40+ demos; only the ones with at least one "I have never seen that before" beat advance. We have three stacked.

**Business Relevance / Usefulness — ~30% weight.** Hit it by (a) mapping explicitly to the provided BFSI challenge statement wording in slide 2 of the appendix deck, (b) quoting Marcellus India Wealth Survey 2025's finding that 40% of affluent investors are dissatisfied with proactive communication despite the bull run, (c) computing and showing the ROI math: 40 min → 47 sec per event × ~50 material events/yr × 450 clients × ~5 RM-hours/week saved = tangible ₹ crore productivity at a 200-RM wealth firm like 360 ONE or Motilal Oswal Private Wealth. Arundhati's stated priority (BFSI pilots in banks) is echoed back verbatim.

**Demo Delivery / Presentation — ~20% weight.** Hit it with scripted calm voiceover, burned captions, 4:50 runtime (not 4:59 — judges respect teams that respect the limit), cold-open on pain not branding, cinematic system-bar overlay, a metric reveal in the final ten seconds, and a 20-page appendix deck ready for the live Showdown Q&A on May 19. Rehearse the live pitch three times with 60-second Q&A drills covering: "How does this scale to 10 million users?", "How are you handling RBI data localization?", "What's the LLM cost per interaction?", "Where's the human in the loop?", "What if the agent makes a wrong SEBI call?".

**Technical Implementation — ~15% weight.** Hit it by visibly using eight of the Agentforce 360 platform products on camera (Agent Builder, Data 360, Trust Layer, Slack, WhatsApp Enhanced Channel, Tableau Pulse, Mobile App with voice, Prompt Builder) — mention A2A and MCP by name in voiceover. GitHub repo with clean README, deployment scripts (SFDX source format), seeded test data script, admin credentials for judges to log in and poke. The judges won't run the code but the existence of a clean repo signals professional-grade execution.

**Mandatory submission hygiene.** Admin login credentials for a dedicated Judging User in a Partner Trailblazer org with Agentforce Flex Credits allocated. GitHub public repo with source, README, architecture diagram, screenshots. Text description under the hackathon portal's word count. Products/APIs list from Section F above. Further improvements list from Section G above. 4:45–4:55 video on YouTube (unlisted), exported in 1080p H.264, captions burned in, filename `Dhruv_Market_Monitoring_Agent_Team[Name]_AWT_Mumbai_2026.mp4`.

## A final word on positioning

Most teams will pitch **a cool agent**. You will pitch **the first regulator-grade, vernacular, voice-first agent Indian wealth firms can actually deploy.** The difference is the Trust Layer audit reveal, the A2A compliance handoff, the Hinglish code-switch, and the "pilot on Monday" framing. Pick the BFSI track — it is the most crowded but also the one Arundhati most cares about and the one with the highest halo value when Salesforce India markets the winner. Build the MVP end-to-end by Day 5, add wow features on Day 6, polish on Day 7, and submit with the 20-page appendix deck. Then on May 19 at the Jio World Convention Center, walk on stage, open with Marathi — *"नमस्कार मुंबई"* — and do not stop until the ₹10 lakh cheque is in your hands.

Dhruv. Your north star, on every market day.