# CLAUDE.md — Project context anchor

This file is auto-loaded into every Claude Code session. Keep it tight; link out to deeper docs.

## What we are building

**Dhruv — Market Monitoring Agent** for the **Agentforce Hackathon at AWT Mumbai 2026** (BFSI track, submission deadline **2026-05-03**, event **2026-05-19** at Jio World Convention Centre, prize **₹10 lakh**).

A mobile-first Agentforce co-pilot for Wealth Relationship Managers (RMs) that:
1. Auto-detects market events (RBI MPC rate cut as anchor scenario)
2. Hyper-segments impacted clients via Data Cloud (450 → 62 → 8 in seconds)
3. Drafts personalized WhatsApp nudges (Hinglish best-effort, English fallback)
4. Routes custom-trade approvals through Slack
5. Pushes a 360° pre-call brief 60 seconds before each call
6. Reveals Einstein Trust Layer audit trail at the end

## Hackathon constraints (read first, every session)

- **Team**: Solo (the user). Claude is the implementation partner.
- **Time**: 5 days total to submission (today is **2026-04-28**).
- **Deliverable**: 5-minute video on YouTube unlisted + GitHub repo + 20-page appendix deck. **Not a live demo on stage** in the first cut.
- **Ambition**: Win ₹10 lakh — push every wow moment, but stage shots and stub creatively where needed.
- **Org access**: FSC + Data Cloud + Agentforce all enabled (provided by organisers, connected to this session).
- **User credentials**: Agentforce certified.

## Architectural choice: Approach B (Dhruv + lightweight Paalak)

Two real Agentforce agents:
- **Dhruv** — RM-facing Employee Agent, cloned from GA Financial Advisor Assistance template, 4 new topics + 5 actions + 4 prompts.
- **Paalak** — Compliance Agent, single topic + action + prompt, called via A2A (HTTP callout to Agent API) from Dhruv.

"Vigil" from the research is **not a separate agent** — it is a Flow + Data Action + Platform Event. Calling it an agent in the demo voiceover is fine; building it as one is wasted effort.

## Non-goals (explicit YAGNI cuts — do NOT build these)

- Real NSE/BSE feed (Python simulator only)
- Vigil as a separate agent
- MCP server, offline-first mode, agents-teaching-agents
- Tableau Pulse (use embedded Lightning dashboard or CRM Analytics)
- Marathi/Tamil/Bengali/Gujarati expansion
- Account Aggregator (AA), Apromore, Zerodha Kite Connect
- Production WhatsApp via WABA (Meta test number only)
- Bedrock-Claude on critical path (default Atlas; Hinglish is best-effort)
- Live Showdown stage-demo wiring

## Demo scenario (anchor)

RBI MPC surprises with a **25 bps rate cut** → 450 clients filtered to **62** by exposure → **8** assigned to RM **Vikram Rao** → top 3 by AUM-weighted exposure get WhatsApp nudges → **Priya Sharma** (Bandra, ₹1.8 Cr AUM, 28% Bank-Nifty exposure) replies asking to call → ₹40L rotation request triggers Slack approval → Manager Rajesh approves → pre-call brief pushes 60s before her 3 PM call → Trust Layer audit shown.

## Day-by-day milestones (hard targets)

| Day | Date | Milestone |
|---|---|---|
| 1 | 2026-04-28 evening + 04-29 | Org foundation; 450 PA + holdings loaded; custom objects created; Meta test number application started |
| 2 | 2026-04-30 | Data Cloud DMOs + ClientExposureGraph + Streaming Ingestion + simulator + Detect/Segment Flow → 62 hits + Custom Notifications |
| 3 | 2026-05-01 | Dhruv agent (4 topics, 5 actions, 4 prompts) → "show impacted clients" works in Conversation Preview |
| 4 | 2026-05-02 | WhatsApp + Slack + Paalak A2A + Pre-Call Brief + dashboard. **Hard cut date — anything not working tonight gets cut.** |
| 5 | 2026-05-03 | Polish + record + appendix deck + submit |

## Sacrifice order if behind

If we slip on Day 3 or Day 4, cut in this order (each cut buys ~3–6 hours):
1. Voice/Siri Shortcut shot (lose 15s of video, no narrative loss)
2. Paalak A2A protocol — inline validation as a prompt step in Dhruv (still on screen, no agent-card handshake)
3. Tableau / dashboard polish (replace with a static screenshot)
4. Pre-Call Brief schedule trigger (manual trigger instead)
5. (Last resort) Hinglish — drop to English-only

## Where to find more

- **Full design spec**: [docs/superpowers/specs/2026-04-28-dhruv-design.md](docs/superpowers/specs/2026-04-28-dhruv-design.md)
- **Data model details**: [docs/design/data-model.md](docs/design/data-model.md)
- **Original problem statement**: [ProblemStatement.md](ProblemStatement.md)
- **Original Claude research**: [ClaudeResearch.md](ClaudeResearch.md)
- **Implementation plan** (created next via writing-plans skill): `docs/superpowers/plans/...`

## Working agreement with Claude

1. **YAGNI ruthlessly** against the non-goals list above.
2. **Always ask** before adding any feature not in the design spec.
3. **Verification before completion**: never claim a Salesforce component works without a screenshot of the Conversation Preview / Flow run / Custom Notification arriving.
4. **Code-only output** for Apex/LWC/Flow XML/Python; in-org clicks are owned by the user with a checklist.
5. **The user is Agentforce certified** — skip basic-Salesforce tutorials; assume domain knowledge.
