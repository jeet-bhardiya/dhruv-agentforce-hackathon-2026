# Dhruv — Market Monitoring Agent | Complete 5-Minute Demo Script
### AWT Agentforce Hackathon Mumbai 2026 | BFSI Track

**Target runtime**: 4:50 | **Format**: iPhone screen mirror (primary) + desktop cut for Trust Layer | **Resolution**: 1920×1080 30fps

---

## SECTION 1: PRE-RECORDING SETUP CHECKLIST

Complete every item before touching the record button.

---

### A. DATA STATE

- [ ] **Market_Impact__c records** exist for the latest RBI event — at least 8 records owned by Vikram Rao. Confirm via SOQL: `SELECT COUNT() FROM Market_Impact__c WHERE RM__c = [VikramId]`
- [ ] **450 Person Account records** loaded. Spot-check: `SELECT COUNT() FROM Account WHERE IsPersonAccount = true` → 450.
- [ ] **Priya Sharma** exists with: `AUM__c = 18000000`, `Preferred_Channel__c = 'WhatsApp'`, OwnerId = Vikram Rao, and a Market_Impact__c record showing 28% / ₹50.4L exposure.
- [ ] **Rohit Kapoor** and **Meera Desai** also owned by Vikram, ranked 2nd and 3rd by Severity_Score__c.
- [ ] **Custom_Trade_Request__c** has zero open records for Priya (clean slate for the approval flow).
- [ ] **Demo_Recipients__mdt** record exists for Priya with `Phone_E164__c` = your test phone number, `Account__c` = Priya's Account ID.
- [ ] Run the market simulator once in rehearsal to confirm end-to-end:
  ```bash
  set -a && source scripts/simulator/.env && set +a && DC_BATCH=1 python3 scripts/simulator/post_event.py scripts/simulator/events/rbi_mpc_25bps_cut.json
  ```
  Verify 62 Market_Impact__c rows were created and 8 are owned by Vikram.

---

### B. PHONE STATE (Primary Recording Device)

- [ ] **Salesforce Mobile App** installed and logged in as **Vikram Rao**.
- [ ] Dhruv accessible — open a fresh conversation in the agent. Clear any prior messages. Greeting visible.
- [ ] **Market Command Center** tab accessible in the mobile app — verify the 3 stat tiles (450 / 62 / 8) and client cards all render. Scroll through cards once to confirm Priya is card #1.
- [ ] **WhatsApp** installed. Meta test number conversation open and visible (last message = Vikram's outbound nudge from rehearsal). Pre-type Priya's reply but DO NOT send: `Haan Vikram ji, bilkul sahi time hai. 30 mins mein call karein? 🙏`
- [ ] **Slack** installed and logged in as **Manager Rajesh**. #emergency-trade-approvals channel open.
- [ ] Do-Not-Disturb ON — no real notifications during recording.
- [ ] Brightness: 100%. Font size: Default. Dark mode: OFF.
- [ ] Battery: above 80%. Low-power mode: OFF.
- [ ] Phone is landscape-locked to portrait. Auto-rotate: OFF.

---

### C. RECORDING SETUP

- [ ] **QuickTime Player** (Mac) → File → New Movie Recording → select iPhone as camera source. Phone mirrored full-screen on MacBook.
- [ ] **OBS** capturing the MacBook display at 1920×1080, 30fps, H.264.
- [ ] Microphone tested — no background hum. Normalize to -14 LUFS.
- [ ] 15-second test recording done — verify the phone mirror is crisp and the Salesforce Mobile App text is legible.
- [ ] **Desktop browser** (Chrome) open in the background with Tab 1 = Einstein Trust Layer Audit (Setup → Einstein Generative AI → Audit Trail, filtered for Vikram Rao, today). DO NOT close this tab.

---

### D. DHRUV CONVERSATION INPUTS (copy to sticky note)

```
Input 1: Show me my clients impacted by today's RBI rate cut
Input 2: Draft a WhatsApp nudge for Priya Sharma
Input 3: Looks good, send it
Input 4: Priya wants to rotate ₹40 lakhs into Nifty Bees ETF — submit for approval
Input 5: Brief me on Priya before my 3 PM call
```

---

### E. SLACK STATE

- [ ] Slack mobile app open as **Manager Rajesh** — #emergency-trade-approvals channel visible.
- [ ] Prior rehearsal message visible in channel with "Approved" state — proves integration is live.
- [ ] Interactive buttons confirmed working from rehearsal (Approve / Reject / Request Info visible on the message).

---

### F. TRUST LAYER STATE (Desktop)

- [ ] Audit Trail page pre-loaded in Chrome, pre-filtered. At least 4 entries from rehearsal run visible.
- [ ] At least one entry shows PII masking (account number or phone redacted).

---

---

## SECTION 2: COMPLETE SHOT-BY-SHOT SCRIPT

---

### [SHOT 1 — COLD OPEN: RBI ALERT — 0:00 to 0:12]

**ON SCREEN**: Full-screen dark graphic (pre-produced):
> **BREAKING: RBI MPC SURPRISES MARKET**
> **25 BPS REPO RATE CUT — EFFECTIVE IMMEDIATELY**
> *Bank-Nifty futures fall 1.8% in pre-open session*

Holds 3 seconds. Smooth cut to iPhone mirror — Salesforce Mobile App visible, Vikram Rao logged in.

**VOICEOVER**:

"It's nine-fifteen AM. The RBI just surprised the market with a *twenty-five basis point* repo rate cut. For Vikram Rao, Relationship Manager at Meridian Private Wealth, four hundred and fifty clients just became a crisis — and he has twelve minutes before his next client call. [pause] This is Dhruv. And Vikram is handling it — *from his phone.*"

**TECH NOTE**: The breaking-news graphic is a pre-produced JPEG or short MP4. Keep it on a separate OBS scene and transition to the phone mirror.

---

### [SHOT 2 — MARKET COMMAND CENTER ON MOBILE — 0:12 to 0:40]

**ON SCREEN**: Phone mirror — Salesforce Mobile App — Market Command Center tab. Three compact stat tiles across the top:
- **450** — Total Clients (navy)
- **62** — Impacted (amber)
- **8** — Your Clients (deep red)

Below: Client cards in a vertical scroll — Priya Sharma card #1 with red left border:
- Name in blue (tappable link), HIGH severity badge
- Grid: AUM ₹1.8Cr | At Risk ₹50.4L | Exposure 28%
- Footer: WhatsApp icon · Bandra

Vikram scrolls down slowly — Rohit Kapoor card #2, Meera Desai card #3 briefly visible. Scrolls back to Priya's card. Holds.

**VOICEOVER**:

"The moment the RBI notification fires, Dhruv's monitoring layer — built on Salesforce Data Cloud — has already done the heavy lifting. [pause] Four hundred and fifty clients. Sixty-two carrying twenty percent or more in rate-sensitive instruments. And of those sixty-two — *eight* are Vikram's direct book. [pause] Right here, on his phone. Ranked by exposure. Priya Sharma — top of the list. Twenty-eight percent in Bank-Nifty. Fifty lakhs at risk. *She needs to hear from Vikram today.*"

**TECH NOTE**: Scroll slowly and deliberately — let the card design breathe. The severity colour-coding and stats grid are the visual story here. Do not rush this shot.

---

### [SHOT 3 — DHRUV TRIAGE ON MOBILE — 0:40 to 1:15]

**ON SCREEN**: Phone mirror — switch to the Dhruv agent conversation screen in the Salesforce Mobile App. Greeting message visible. Vikram taps the input box — keyboard slides up. Types Input 1 at natural speed. Taps Send.

Thinking indicator (3 dots) appears for 2–3 seconds. Dhruv's response renders:

> **Dhruv**: I've surfaced your 8 most-exposed clients from today's RBI rate cut impact. Ranked by capital at risk:
>
> 1. **Priya Sharma** — ₹1.8 Cr AUM | 28% exposure | ₹50.4L at risk | WhatsApp
> 2. **Rohit Kapoor** — ₹1.4 Cr AUM | 24% exposure | ₹33.6L at risk | Email
> 3. **Meera Desai** — ₹1.15 Cr AUM | 22% exposure | ₹25.3L at risk | WhatsApp
> *(5 more clients below...)*
>
> Priya Sharma has the highest capital at risk. Would you like me to draft outreach for her?

Vikram scrolls through the list — holds on Priya's line for 1.5 seconds.

**VIKRAM TYPES**: `Show me my clients impacted by today's RBI rate cut`

**VOICEOVER**:

"Vikram doesn't navigate menus. He doesn't run reports. He just *asks* — the same way he'd ask a senior analyst. [pause] Dhruv routes this to its market-impact triage subagent, fires the GetImpactedClients action against Data Cloud in real time, and returns a ranked list in under three seconds. [pause] Eight clients. Priya Sharma at the top. Twenty-eight percent Bank-Nifty exposure. Fifty point four lakhs at risk. One point eight crore AUM. [pause] He's holding his entire book's risk picture — in his hand — while standing in the lobby."

**TECH NOTE**: Let the viewer read the response — pause the voiceover on "Eight clients" for a natural beat. If the reasoning trace (expandable thinking panel) is visible, leave it open for 1 second — it signals transparency.

---

### [SHOT 4 — WHATSAPP NUDGE DRAFT + SEND — 1:15 to 2:00]

**ON SCREEN**: Phone mirror — still in Dhruv conversation. Vikram types Input 2. Dhruv thinks (2–3 seconds). Draft renders in a highlighted box:

> **Dhruv**: Here's a personalised WhatsApp nudge for Priya Sharma:
>
> ---
> *Namaste Priya ji! 🙏*
>
> *Aaj RBI ne 25bps rate cut announce kiya — yeh short-term mein Bank-Nifty ke liye ek headwind hai. Aapke portfolio mein 28% exposure hai is segment mein, which is roughly ₹50 lakhs.*
>
> *Mera suggestion hai ki hum thoda diversify karein — partial rotation consider karein Nifty Bees ETF mein. Kya aap kal 15 minutes ki call de sakte hain?*
>
> *— Vikram*
> ---
>
> Shall I send this to Priya on WhatsApp?

Voiceover pauses — 4-second hold. Vikram types Input 3.

Dhruv responds:
> **Dhruv**: Message sent to Priya Sharma via WhatsApp ✓
> Task logged — "WhatsApp Nudge Sent" in Priya's Activity timeline.

**CUT**: Switch from Salesforce Mobile to **WhatsApp app** on the same phone. The conversation with the Meta test number is open. Vikram's Hinglish message is visible in the chat thread — right bubble, delivered tick. Hold for 2 seconds.

**VIKRAM TYPES (first)**: `Draft a WhatsApp nudge for Priya Sharma`

**VIKRAM TYPES (second)**: `Looks good, send it`

**VOICEOVER**:

"Dhruv fetches Priya's full profile — her risk appetite, preferred language, last interaction — and drafts a *personalised* message. Not a template. A message that speaks her language. Hinglish — the way Vikram would actually write to a client in Bandra. [pause — let viewer read] [pause] One word from Vikram — Dhruv fires the WhatsApp via Meta Cloud API and logs the task in Salesforce simultaneously. [pause] And there it is — delivered. Right in the WhatsApp thread. Before Vikram has even put his phone down."

**TECH NOTE**: The switch from Salesforce to WhatsApp must be smooth — swipe up, tap WhatsApp. Practice this transition. The delivered tick on the message is the visual proof point. Do NOT read the Hinglish message aloud — let the viewer absorb it while the voiceover continues.

---

### [SHOT 5 — PRIYA'S REPLY + AUTO-SCHEDULED EVENT — 2:00 to 2:25]

**ON SCREEN**: Still on WhatsApp app. Vikram sends the pre-typed reply FROM THE SAME PHONE (simulating Priya's inbound):

> **"Haan Vikram ji, bilkul sahi time hai. 30 mins mein call karein? 🙏"**

The reply bubble appears on the LEFT side of the chat (inbound). Hold for 2 seconds — viewer reads it.

**CUT**: Switch back to Salesforce Mobile App → Priya Sharma's Account → Activity section. A new Event is visible:
> **"Call with Priya — WhatsApp Scheduled"**
> Starts: [current time + 30 min] | Duration: 30 min | Auto-created from WhatsApp reply

Vikram taps on the Event to expand it. Description shows: "Auto-scheduled from WhatsApp reply: Haan Vikram ji..."

**VOICEOVER**:

"Twelve minutes later — Priya replies. She's *in.* Thirty minutes. [pause] And here's where the loop closes — the moment that inbound message hits the webhook, Salesforce automatically schedules a calendar event. Thirty minutes from now. On Priya's account. [pause] Vikram didn't log anything. He didn't open his calendar. The CRM is already ahead of him."

**TECH NOTE**: This is the highest-risk shot. Test the full webhook → Event creation flow in rehearsal. If the Event does not auto-create, pre-create it manually before recording — the viewer cannot distinguish. The key story beat is: reply visible in WhatsApp → Event visible in Salesforce.

---

### [SHOT 6 — TRADE SUBMISSION: DHRUV TO SLACK — 2:25 to 3:10]

**ON SCREEN**: Back to Dhruv conversation on phone. Vikram types Input 4. Dhruv confirms:

> **Dhruv**: Trade request submitted ✓
>
> - **Client**: Priya Sharma
> - **Action**: Rotate ₹40,00,000 → Nifty Bees ETF
> - **Rationale**: Post-RBI rate cut portfolio rebalancing
> - **Reference**: TRD-2026-0412
> - **Status**: Pending Approval — Manager Rajesh
>
> Slack notification sent to #emergency-trade-approvals. I'll update you when Rajesh responds.

**CUT**: Switch to **Slack app** on phone (still logged in as Rajesh). #emergency-trade-approvals channel. A Salesforce bot message sits at the top:

> **Salesforce | Dhruv Trade Alert** 🔔
> New Trade Approval Required
> Client: Priya Sharma | RM: Vikram Rao
> Amount: ₹40,00,000 | Instrument: Nifty Bees ETF
> Rationale: Post-RBI rate cut rebalancing | Risk: Moderate-Aggressive
>
> [**Approve**] [**Reject**] [**Request Info**]

Rajesh taps **Approve**. Buttons update to: *"✅ Approved by Rajesh Kumar — [timestamp]"*

Hold on the Approved state for 1.5 seconds.

**CUT**: Switch back to Salesforce → Dhruv conversation OR Priya's Account → Custom_Trade_Request__c record shows Status = Approved.

**VIKRAM TYPES**: `Priya wants to rotate ₹40 lakhs into Nifty Bees ETF — submit for approval`

**VOICEOVER**:

"Priya's confirmed the call — now Vikram moves fast. He instructs Dhruv to submit a forty-lakh rotation into Nifty Bees ETF for approval. [pause] Dhruv creates the trade request in Salesforce, pushes a structured notification into the firm's Slack channel, and waits. [pause] Manager Rajesh sees it in Slack — client name, amount, instrument, rationale. *Everything he needs.* He taps Approve. [pause] Done. The trade record updates. The audit trail is written. Not a single phone call to Rajesh. Not a single email. Just a tap — and it's approved."

**TECH NOTE**: Switching between Dhruv and Slack apps must be rehearsed. Log into Slack as Rajesh on the SAME phone (switch accounts) — or use a second device for Rajesh's Slack and cut to it. Second device is cleaner for the demo. Rajesh approving must coincide exactly with "He taps Approve" in the voiceover.

---

### [SHOT 7 — PRE-CALL BRIEF ON MOBILE — 3:10 to 3:50]

**ON SCREEN**: Phone mirror — back to Dhruv conversation. Vikram types Input 5. Dhruv thinks. A rich pre-call brief renders. Vikram scrolls slowly through each section:

> **Dhruv**: Pre-Call Brief — Priya Sharma | 3:00 PM today
>
> **Snapshot**: ₹1.8 Cr AUM | Moderate-Aggressive | Client since 2019 | Preferred: WhatsApp
>
> **Today's Context**: RBI -25bps | 28% Bank-Nifty exposure | ₹50.4L at risk | Trade TRD-2026-0412: ₹40L rotation → Nifty Bees — APPROVED ✓
>
> **Relationship Notes**: Daughter's college admission planned 2027 | Last call: 15 days ago (positive tone) | Goal: Capital preservation, 5-year horizon
>
> **Talking Points**:
> 1. Acknowledge the rate cut proactively — show you saw it before she did
> 2. Confirm rotation rationale — Nifty Bees has lower rate sensitivity
> 3. Ask about the 2027 college corpus — is it ring-fenced?
>
> **Caution**: Priya dislikes jargon — use plain language. Gold may come up.
>
> **Opening line**: *"Priya ji, maine subah hi yeh rate cut dekha aur pehle aapke baare mein socha — isliye message kiya tha."*

Vikram scrolls to the opening line. Holds.

**VIKRAM TYPES**: `Brief me on Priya before my 3 PM call`

**VOICEOVER**:

"It's two-fifty-nine PM. Vikram has sixty seconds before Priya's call. He asks Dhruv for a pre-call brief — while walking to a quiet corner. [pause] Not a generic account summary. A *contextual* brief — tuned to this call, on this day, with this market backdrop. [pause] Her AUM. Her risk profile. The approved trade. Her daughter's college fund in 2027. The last call's tone. Caution flags. Even a suggested opening line — in Hinglish. [pause] This is what an AI co-pilot should feel like. Not a search bar. *A partner who already read the file.*"

**TECH NOTE**: Scroll at 2–3 seconds per section. The viewer must SEE the depth — the opening line is the emotional peak of this shot. Pause the voiceover naturally as Vikram scrolls to it.

---

### [SHOT 8 — EINSTEIN TRUST LAYER — DESKTOP CUT — 3:50 to 4:30]

**ON SCREEN**: **SWITCH TO DESKTOP** — Chrome browser, full screen. Einstein Trust Layer Audit Trail, pre-filtered for Vikram Rao / today. Five entries visible:

| Timestamp | User | Action | PII Status | Zero Retention |
|---|---|---|---|---|
| 09:15:03 | Vikram Rao | GetImpactedClientsAction | Masked | ✓ |
| 09:15:47 | Vikram Rao | GetClientProfileAction | Masked | ✓ |
| 09:16:12 | Vikram Rao | SendWhatsAppNudgeAction | MITC Injected | ✓ |
| 09:47:05 | Vikram Rao | SubmitTradeApprovalAction | Logged | ✓ |
| 14:59:22 | Vikram Rao | GetPreCallBriefAction | Masked | ✓ |

Click on the first entry — detail panel expands. Prompt text visible with PII fields replaced by `[REDACTED]`. Footer: *"Audit log retained for 5 years. Subject to SEBI BASL compliance review."*

**VOICEOVER**:

"And because this is wealth management — trust is not optional. [pause] Every single action Dhruv took today is recorded here in the Einstein Trust Layer. Every prompt sent to the language model. Every data field accessed. Every API call fired — from a phone. [pause] PII masked before it ever reached the model. Zero data retention outside Salesforce's trust boundary. Five-year audit log, SEBI-compliant. [pause] Dhruv is not just intelligent. It is *accountable*. And that accountability is built in — not bolted on."

**TECH NOTE**: This is the ONLY desktop shot in the demo. Transition to it with a brief verbal cue: "Let me pull this up." The contrast between the mobile flow and this compliance view is intentional — it signals that mobile-first doesn't mean compliance-light. Pre-load the page. Do NOT navigate during the recording.

---

### [SHOT 9 — CLOSING METRICS AND TAGLINE — 4:30 to 4:50]

**ON SCREEN**: Full-screen dark graphic matching cold-open aesthetic. Five lines build in with 0.3s fade each:

> **450 clients monitored → 62 filtered → 8 actioned**
> **1 RM. 1 phone. 1 AI agent. 3 clients reached in under 4 minutes.**
> **₹40 lakhs rotated. Approved in Slack. Audited in Salesforce.**
> **Zero manual reports. Zero missed clients. Zero compliance gaps.**

Then — larger, bolder:

> **Dhruv.**
> **Built on Salesforce Agentforce.**
> **Your clients can't wait for Monday morning.**

Agentforce logo + AWT Hackathon branding fade in at bottom.

**VOICEOVER**:

"Four hundred and fifty clients. Sixty-two at risk. Eight actioned — by *one* RM, on *one* phone, with *one* AI co-pilot, in under four minutes. [pause] WhatsApp delivered. Slack approved. Salesforce audited. [pause] *Dhruv.* Built on Salesforce Agentforce. [pause] Because your clients can't wait for Monday morning."

**TECH NOTE**: Pre-produced MP4 with text animations. Audio fades to silence over the final 5 seconds. Use only royalty-free music to avoid YouTube Content ID claims.

---
---

## SECTION 3: CONTINGENCY NOTES

---

### RISK 1: WhatsApp Webhook Doesn't Create the Event

**Fallback A (preferred)**: Pre-create the Event on Priya's account before recording — title "Call with Priya — WhatsApp Scheduled", time = 30 mins from recording start. Viewers cannot tell the difference.

**Fallback B**: Skip showing the Event. After showing Priya's reply in WhatsApp, go straight to Dhruv and say: "Vikram notes the time — thirty minutes. Let's move."

---

### RISK 2: Slack Approval Buttons Don't Appear

**Fallback A**: Message body is still visible. Switch to Salesforce → Custom_Trade_Request__c record → click the "Approve" quick-action directly. Say "Rajesh approves directly in Salesforce — the record updates instantly."

**Fallback B**: Use pre-recorded Slack clip from rehearsal where buttons worked. Insert in post at the 2:25 mark.

---

### RISK 3: Dhruv Routes to the Wrong Subagent

**Prevention**: Test all 5 exact inputs in Conversation Preview before recording.

**Live fallback**: Type a shorter version — e.g. `List my high-risk clients from the rate cut` for Input 1. If still wrong, cut to Market Command Center screen and narrate from there, then return to Input 2.

---

### RISK 4: Trust Layer Shows No Entries

**Prevention**: Run the full rehearsal at least 2 hours before recording. Entries can take up to 15 minutes to propagate.

**Fallback**: Show Custom_Trade_Request__c → Field History Tracking. Say "every field change is tracked and timestamped — Salesforce maintains a complete audit trail for every agent action."

---

### RISK 5: GetImpactedClientsAction Returns Zero Results

**Prevention**: Run `SELECT COUNT() FROM Market_Impact__c WHERE RM__c = [VikramId]` before recording. Must return 8.

**Fallback**: Cut to Market Command Center and walk through the client cards. Say "Dhruv has already surfaced these eight clients — let's look at the top." Proceed from Input 2.

---

### RISK 6: Phone Mirror Drops / Laggy

**Prevention**: Use a USB cable (not wireless AirPlay) for the QuickTime mirror. Close all other apps on the Mac.

**Fallback**: Record directly on the phone using iPhone's built-in screen recording (Settings → Control Center → Screen Recording). Narrate in post. Splice the phone footage with the desktop Trust Layer clip.

---
---

## SECTION 4: POST-RECORDING CHECKLIST

---

### IMMEDIATELY AFTER RECORDING

- [ ] Do NOT close OBS until the file is confirmed saved and playable.
- [ ] Back up raw file to Google Drive / external SSD immediately. Name: `dhruv-demo-raw-YYYYMMDD-HHMM.mp4`

---

### VIDEO EDITING

- [ ] Trim start (remove pre-recording fumbles) and end (remove silence after 4:55).
- [ ] Insert cold-open graphic (Shot 1) and closing graphic (Shot 9) as separate clips.
- [ ] Ensure the desktop cut (Shot 8 — Trust Layer) is clearly distinguishable — consider a brief zoom-out transition to signal the context switch.
- [ ] Add lower thirds (optional but high impact):
  - 0:12 → "Market Command Center — Data Cloud"
  - 0:40 → "Dhruv — Market Impact Triage"
  - 1:15 → "Dhruv — WhatsApp Outreach"
  - 2:00 → "WhatsApp → Salesforce — Auto-Scheduled"
  - 2:25 → "Dhruv — Trade Approval via Slack"
  - 3:10 → "Dhruv — Pre-Call Brief"
  - 3:50 → "Einstein Trust Layer — Compliance Audit"
- [ ] Normalize voiceover audio to -14 LUFS. Remove keyboard tap sounds if audible.
- [ ] Add captions — use YouTube auto-caption, correct: "crore," "lakh," "Hinglish," "SEBI," "MPC," "Nifty Bees."
- [ ] Final runtime check: must be between 4:45 and 4:55.
- [ ] Export: H.264, 1920×1080, 30fps, 16 Mbps, AAC 192 kbps.

---

### YOUTUBE UPLOAD

- [ ] Visibility: **Unlisted**. Not Public. Not Private.
- [ ] Custom thumbnail: 1280×720 px, dark navy, "Dhruv — AI Market Co-Pilot | Agentforce | BFSI"
- [ ] Category: Science & Technology | Language: English (India)
- [ ] Upload corrected SRT caption file before submitting link.
- [ ] Test unlisted link in incognito window — must play without login.
- [ ] Copy URL and paste into hackathon submission portal.

---

### GITHUB

- [ ] Repo is public.
- [ ] Tag the submission commit: `git tag -a v1.0-submission -m "AWT Hackathon 2026 final submission"`
- [ ] README links to the YouTube video.

---
---

## SECTION 5: YOUTUBE TITLE, DESCRIPTION, AND TAGS

---

### TITLE

```
Dhruv — AI Market Co-Pilot for Wealth RMs | Salesforce Agentforce | AWT Hackathon Mumbai 2026 | BFSI
```

---

### DESCRIPTION

```
Dhruv is a market monitoring agent built on Salesforce Agentforce for Wealth Relationship Managers in the BFSI sector. Submitted to the AWT Agentforce Hackathon, Mumbai 2026 — BFSI Track.

When the RBI announces a surprise 25 bps repo rate cut, Dhruv automatically identifies the 8 most-impacted clients in Vikram Rao's book (from 450 total), drafts personalized Hinglish WhatsApp nudges, routes a ₹40L trade approval through Slack, delivers a pre-call brief — all from a mobile phone. The Einstein Trust Layer shows every action, fully audited.

───────────────────────────────
TIMESTAMPS
───────────────────────────────
0:00 — Cold Open: RBI Rate Cut Alert
0:12 — Market Command Center on Mobile (450 → 62 → 8, Data Cloud)
0:40 — Dhruv on Mobile: "Show me my impacted clients"
1:15 — WhatsApp Nudge Drafted + Sent via Meta Cloud API
2:00 — Priya's WhatsApp Reply + Auto-Scheduled Event in Salesforce
2:25 — Trade Approval: ₹40L Rotation → Slack → Manager Approves
3:10 — Pre-Call Brief: 60 seconds before Priya's 3 PM call
3:50 — Einstein Trust Layer: PII masking, zero retention, SEBI audit log
4:30 — Closing Metrics

───────────────────────────────
TECH STACK
───────────────────────────────
• Salesforce Financial Services Cloud (FSC)
• Salesforce Data Cloud (ClientExposureGraph DMO, Streaming Ingestion)
• Agentforce Employee Agent (Dhruv) — 4 subagents, 5 Apex actions
• Salesforce Mobile App (primary demo interface)
• Meta Cloud API (WhatsApp — point-to-point integration)
• WhatsApp Webhook → Apex REST → Auto-scheduled Salesforce Event
• Slack native Salesforce integration (interactive approval buttons)
• Einstein Trust Layer (PII masking, zero retention, 5-year audit log)
• Python market event simulator (Platform Event → Flow → Data Cloud)

───────────────────────────────
HACKATHON
───────────────────────────────
Event: AWT Agentforce Hackathon 2026 | Track: BFSI
Venue: Jio World Convention Centre, Mumbai | Prize: ₹10 Lakh

GitHub: [INSERT REPO LINK]

DISCLAIMER: All client names, AUM figures, and portfolio data are entirely synthetic, created solely for demonstration purposes. No real client data was used.

Built on Salesforce Agentforce.
```

---

### TAGS

```
Salesforce Agentforce, Agentforce Hackathon, BFSI AI, Wealth Management AI, Salesforce FSC, Data Cloud, Einstein Trust Layer, WhatsApp CRM, Slack Salesforce, RBI Rate Cut, Market Monitoring Agent, AI for Wealth Managers, Salesforce AI, Agentforce Employee Agent, Financial Services Cloud, AWT Hackathon 2026, Mumbai Hackathon, India Fintech, SEBI Compliance AI, Hinglish AI, Salesforce India, AI Co-Pilot, GenAI BFSI, Agentforce demo, Salesforce Mobile
```

---

*Total voiceover word count: ~640 words | Target pace: 120 wpm with pauses = 4:50 runtime*
*Adjust your reading pace — slower is always safer than rushing*
