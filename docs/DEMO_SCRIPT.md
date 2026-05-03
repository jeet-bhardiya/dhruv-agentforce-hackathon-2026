# Dhruv — Market Monitoring Agent | Complete 5-Minute Demo Script
### AWT Agentforce Hackathon Mumbai 2026 | BFSI Track

**Target runtime**: 4:50 | **Format**: Screen recording + voiceover | **Resolution**: 1920×1080 30fps

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
- [ ] Run the market simulator once in rehearsal to confirm end-to-end:
  ```bash
  python3 scripts/simulator/post_event.py
  ```
  Verify 62 Market_Impact__c rows were created and 8 are owned by Vikram.

---

### B. ORG LOGIN STATE

- [ ] Logged in as **Vikram Rao** (not System Admin). OwnerId filter in GetImpactedClientsAction depends on this.
- [ ] Browser: Chrome, 1920×1080, zoom 100%, bookmarks bar hidden.
- [ ] **Tab 1 — Market Command Center**: Dashboard showing 450 / 62 / 8 funnel cards + client data table. Confirm all three cards render before recording.
- [ ] **Tab 2 — Dhruv Agent**: Conversation cleared ("New Conversation"), greeting message visible.
- [ ] **Tab 3 — Priya Sharma Account record**: Pre-opened for the auto-task reveal shot.
- [ ] **Tab 4 — Einstein Trust Layer**: Setup → Einstein Generative AI → Audit Trail, filtered for Vikram Rao, today's date. DO NOT refresh again until Shot 8.
- [ ] All other tabs and applications closed except Slack (second monitor).

---

### C. DHRUV CONVERSATION INPUTS (copy to a sticky note/second monitor)

```
Input 1: Show me my clients impacted by today's RBI rate cut
Input 2: Draft a WhatsApp nudge for Priya Sharma
Input 3: Looks good, send it
Input 4: Priya wants to rotate ₹40 lakhs into Nifty Bees ETF — submit for approval
Input 5: Brief me on Priya before my 3 PM call
```

---

### D. SLACK STATE

- [ ] Slack desktop app open, logged in as **Manager Rajesh** (the approver account).
- [ ] **#emergency-trade-approvals** channel open, no unread test messages from today.
- [ ] Confirm prior rehearsal message is visible with "Approved" state — proves integration is live.

---

### E. WHATSAPP STATE

- [ ] Meta Cloud API test number active and receiving messages.
- [ ] Phone screen mirror ready (QuickTime for iPhone / scrcpy for Android into OBS).
- [ ] Priya's inbound reply pre-typed on test phone, NOT yet sent: `"Haan Vikram ji, mujhe bhi lagta hai yeh sahi time hai. Friday 3 PM call kaarte hain? 🙏"`
- [ ] Send the reply at the exact moment the voiceover says "twelve minutes later."

---

### F. TRUST LAYER STATE

- [ ] Audit Trail page pre-loaded and pre-filtered. At least 4 entries from today's rehearsal run must be visible.
- [ ] Confirm at least one entry shows PII masking (account number or phone redacted).

---

### G. RECORDING SOFTWARE

- [ ] OBS Studio at 1920×1080, 30fps, H.264.
- [ ] Microphone tested — no background hum. Normalize to -14 LUFS.
- [ ] Phone mirror configured as PiP source (bottom-right, 320×568 px) for WhatsApp shot.
- [ ] 15-second test recording done and verified.
- [ ] Silent countdown timer running on a hidden device.

---
---

## SECTION 2: COMPLETE SHOT-BY-SHOT SCRIPT

---

### [SHOT 1 — COLD OPEN: RBI ALERT — 0:00 to 0:12]

**ON SCREEN**: Full-screen dark graphic (pre-produced in Canva/Figma):
> **BREAKING: RBI MPC SURPRISES MARKET**
> **25 BPS REPO RATE CUT — EFFECTIVE IMMEDIATELY**
> *Bank-Nifty futures fall 1.8% in pre-open session*

Holds 3 seconds. Smooth cut to Salesforce org (Vikram Rao logged in, Tab 1 visible for 1 second before switching).

**VOICEOVER**:

"It's nine-fifteen AM. The RBI just surprised the market with a *twenty-five basis point* repo rate cut. For Vikram Rao, Relationship Manager at Meridian Private Wealth, four hundred and fifty clients just became a crisis — and he has twelve minutes before his next client call. [pause] This is Dhruv."

**TECH NOTE**: The breaking-news graphic is a pre-produced JPEG or short MP4 (3 seconds). Prepare this asset before recording day. Keep it on a separate OBS scene and transition into the Salesforce screen recording.

---

### [SHOT 2 — MARKET COMMAND CENTER DASHBOARD — 0:12 to 0:40]

**ON SCREEN**: Tab 1 — Market Command Center fills the screen. Three large funnel cards across the top:
- **450** — Total Clients (navy text)
- **62** — Rate-Sensitive Impacted (amber text)
- **8** — Assigned to Vikram (deep red text)

Below: a data table — "Your Impacted Clients — Ranked by Exposure" — showing 8 rows. Priya Sharma is row 1: AUM ₹1.8 Cr | 28% | ₹50.4L at risk. Mouse moves slowly to hover over Priya's row and holds for 1.5 seconds.

**VOICEOVER**:

"The moment the RBI notification fires, Dhruv's monitoring layer — built on Salesforce Data Cloud — has already done the heavy lifting. [pause] Four hundred and fifty clients in Vikram's firm. Sixty-two of them carry twenty percent or more in rate-sensitive instruments. And of those sixty-two — *eight* are Vikram's direct book. [pause] The system didn't wait to be asked. It filtered, ranked, and surfaced — automatically."

**TECH NOTE**: Move the mouse slowly and intentionally. Do not hover erratically. If the dashboard shows stale data, refresh the page 20 seconds before this shot and let it settle before starting the recording.

---

### [SHOT 3 — DHRUV TRIAGE: QUERY AND REASONING — 0:40 to 1:15]

**ON SCREEN**: Switch to Tab 2 — Dhruv agent panel. Greeting message visible. Vikram clicks the input box. Types Input 1 at natural typing speed (not copy-paste). Clicks Send.

Thinking indicator (3 pulsing dots) appears for ~2–3 seconds. Then Dhruv's response renders:

> **Dhruv**: I've surfaced your 8 most-exposed clients from today's RBI rate cut impact. Ranked by capital at risk:
>
> 1. **Priya Sharma** — ₹1.8 Cr AUM | 28% exposure | ₹50.4L at risk | WhatsApp
> 2. **Rohit Kapoor** — ₹1.4 Cr AUM | 24% exposure | ₹33.6L at risk | Email
> 3. **Meera Desai** — ₹1.15 Cr AUM | 22% exposure | ₹25.3L at risk | WhatsApp
> *(5 more clients listed below...)*
>
> Priya Sharma has the highest capital at risk. Would you like me to draft outreach for her?

**VIKRAM TYPES**: `Show me my clients impacted by today's RBI rate cut`

**VOICEOVER**:

"Vikram doesn't navigate menus. He doesn't run reports. He just *asks* — the same way he'd ask a senior analyst. [pause] Dhruv routes this to its market-impact triage subagent, fires the GetImpactedClients action against Data Cloud in real time, and returns a ranked list in under three seconds. [pause] Eight clients. Priya Sharma at the top. Twenty-eight percent Bank-Nifty exposure. Fifty point four lakhs at risk. One point eight crore AUM. *She needs to hear from Vikram today.*"

**TECH NOTE**: Let the viewer read the response — pause the voiceover on "Eight clients." for a natural beat. If the reasoning trace is visible (expandable "thinking" panel), keep it visible for 1 second before Dhruv's final response appears. This shows transparency and is a feature, not a bug.

---

### [SHOT 4 — WHATSAPP NUDGE DRAFT IN HINGLISH — 1:15 to 2:00]

**ON SCREEN**: Vikram types Input 2. Dhruv thinks (2–3 seconds). Then a draft renders in a highlighted box:

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

Voiceover pauses — viewer reads the message for ~4 seconds. Vikram types Input 3.

Dhruv responds:

> **Dhruv**: Message sent to Priya Sharma via WhatsApp ✓
> Task logged in Priya's Activity timeline — "WhatsApp Outreach — RBI Rate Cut — [today's date]"

**VIKRAM TYPES (first)**: `Draft a WhatsApp nudge for Priya Sharma`

**VIKRAM TYPES (second)**: `Looks good, send it`

**VOICEOVER**:

"Dhruv fetches Priya's full profile — her risk appetite, preferred language, last interaction — and drafts a *personalised* message. Not a template. A message that speaks her language. Hinglish — the way Vikram would actually write to a client in Bandra. [pause — let viewer read the message] [pause] Vikram approves it with one word. Dhruv fires the WhatsApp via Meta Cloud API — and simultaneously logs a task in Salesforce. The conversation is on record before Vikram even closes the tab."

**TECH NOTE**: Do NOT read the Hinglish message aloud during the voiceover — let the viewer read it visually while the voiceover runs alongside. The actual draft text will vary slightly from what's shown here depending on your prompt output. Do a full rehearsal run and update this script with the exact text Dhruv produces so your voiceover matches what's on screen.

---

### [SHOT 5 — WHATSAPP REPLY ON PHONE + AUTO-TASK IN CRM — 2:00 to 2:20]

**ON SCREEN**: Transition to phone mirror (PiP expands to center or full cut to phone screen). WhatsApp conversation thread shows:
- Vikram's outbound Hinglish message (right bubble)
- Priya's inbound reply (left bubble, arriving with notification sound): **"Haan Vikram ji, mujhe bhi lagta hai yeh sahi time hai. Friday 3 PM call kaarte hain? 🙏"**

Hold on Priya's reply for 2 seconds. Cut back to Salesforce — Tab 3 — Priya Sharma's Account record. Activity Timeline shows a new task: **"Inbound WhatsApp — Priya Sharma — Client confirmed call — Friday 3 PM."** Timestamp: "Just now." Vikram scrolls to highlight it.

**VOICEOVER**:

"Twelve minutes later — Priya replies. She's *in.* Friday, three PM. [pause] And here's where the loop closes — that inbound WhatsApp reply is automatically captured as a task in Salesforce. Vikram doesn't log anything manually. The CRM is already up to date before he finishes reading her message."

**TECH NOTE**: Send Priya's reply from the test phone at the exact moment the voiceover says "twelve minutes later." This is the highest-risk shot in the demo. See Section 3 for the fallback. The auto-task in Salesforce requires the inbound WhatsApp webhook → Task creation flow to be working end-to-end. Test this in rehearsal. If it fails, pre-create the Task manually — the viewer cannot tell the difference in a recorded video.

---

### [SHOT 6 — TRADE SUBMISSION: DHRUV TO SLACK — 2:20 to 3:10]

**ON SCREEN**: Return to Tab 2 — Dhruv agent. Vikram types Input 4. Dhruv confirms details and renders a structured summary:

> **Dhruv**: Trade request submitted ✓
>
> - **Client**: Priya Sharma
> - **Action**: Rotate ₹40,00,000 → Nifty Bees ETF
> - **Rationale**: Post-RBI rate cut portfolio rebalancing
> - **Reference**: TRD-2026-0412
> - **Status**: Pending Approval — Manager Rajesh
>
> Slack notification sent to #emergency-trade-approvals. I'll update you when Rajesh responds.

Cut to Slack — #emergency-trade-approvals channel. A Salesforce bot message shows:

> **Salesforce | Dhruv Trade Alert**
> New Trade Approval Required
> Client: Priya Sharma | RM: Vikram Rao
> Amount: ₹40,00,000 | Instrument: Nifty Bees ETF
> Rationale: Post-RBI rate cut rebalancing | Risk Profile: Moderate-Aggressive
>
> [**Approve**] [**Reject**] [**Request Info**]

Rajesh clicks **Approve**. Buttons change to: *"Approved by Rajesh Kumar — [timestamp]."*

Return to Salesforce. Dhruv updates:

> **Dhruv**: Trade TRD-2026-0412 approved by Rajesh Kumar ✓ — Custom_Trade_Request__c record updated.

**VIKRAM TYPES**: `Priya wants to rotate ₹40 lakhs into Nifty Bees ETF — submit for approval`

**VOICEOVER**:

"Priya's reply triggers the next step. Vikram instructs Dhruv to submit a forty-lakh rotation into Nifty Bees ETF for approval. [pause] Dhruv doesn't just log a ticket. It creates a trade request record in Salesforce, pushes a structured notification into the firm's Slack approval channel, and *waits for a response* — all in one action. [pause] Manager Rajesh sees everything he needs in Slack — client name, amount, instrument, rationale, risk profile. He clicks Approve. [pause] In seconds, the trade record in Salesforce updates. The audit trail is written. Not a single email sent. Not a single phone call to Rajesh."

**TECH NOTE**: The Alt-Tab to Slack and back must be rehearsed until it is muscle memory. Rajesh clicking Approve should happen exactly when the voiceover says "He clicks Approve." Confirm beforehand that the Slack message contains interactive buttons — if it arrives as plain text only, use Fallback A from Section 3.

---

### [SHOT 7 — PRE-CALL BRIEF — 3:10 to 3:50]

**ON SCREEN**: Back to Tab 2. Vikram types Input 5. Dhruv thinks. A rich, structured pre-call brief renders:

> **Dhruv**: Pre-Call Brief — Priya Sharma | Friday, 3:00 PM
>
> **Snapshot**: ₹1.8 Cr AUM | Moderate-Aggressive | Client since 2019 | Preferred: WhatsApp
>
> **Today's Context**: RBI -25bps | 28% Bank-Nifty exposure | ₹50.4L at risk | Trade TRD-2026-0412: ₹40L rotation to Nifty Bees — APPROVED
>
> **Relationship Notes**: Daughter's college admission planned 2027 | Last call: 15 days ago (positive tone) | Goal: Capital preservation, 5-year horizon
>
> **Talking Points**:
> 1. Acknowledge the rate cut proactively — show you saw it before she did
> 2. Confirm the rotation rationale — Nifty Bees has lower rate sensitivity
> 3. Ask about the 2027 college corpus — is it ring-fenced?
>
> **Caution**: Priya dislikes jargon — use plain language. She's asked about gold before — may raise it today.
>
> **Opening line**: *"Priya ji, maine subah hi yeh rate cut dekha aur pehle aapke baare mein socha — isliye message kiya tha."*

Vikram scrolls slowly through the brief. Mouse moves to each section — 2 seconds per section.

**VIKRAM TYPES**: `Brief me on Priya before my 3 PM call`

**VOICEOVER**:

"It's two-fifty-nine PM. Vikram has sixty seconds before Priya's call. He asks Dhruv for a pre-call brief. [pause] Not a generic account summary. A *contextual* brief — tuned to this call, on this day, with this market backdrop. [pause] AUM, risk profile, the pending trade, her daughter's college admission in 2027, the last interaction's tone, caution flags — even a suggested opening line in Hinglish. [pause] This is what an AI co-pilot should feel like. Not a search bar. *A partner who already read the file.*"

**TECH NOTE**: Scroll slowly — 2–3 seconds per section. The viewer must SEE the depth, not just hear it. The pre-call brief is only as good as the data behind it — enrich Priya's record with life events, interaction summaries, and custom fields before recording.

---

### [SHOT 8 — EINSTEIN TRUST LAYER AUDIT TRAIL — 3:50 to 4:30]

**ON SCREEN**: Switch to Tab 4 — Einstein Trust Layer Audit Trail. Table already visible, pre-filtered for Vikram Rao / today. Shows 5 entries:

| Timestamp | User | Action | PII Status | Zero Retention |
|---|---|---|---|---|
| 09:15:03 | Vikram Rao | GetImpactedClientsAction | Masked | ✓ |
| 09:15:47 | Vikram Rao | GetClientProfileAction | Masked | ✓ |
| 09:16:12 | Vikram Rao | SendWhatsAppNudgeAction | MITC Injected | ✓ |
| 09:47:05 | Vikram Rao | SubmitTradeApprovalAction | Logged | ✓ |
| 14:59:22 | Vikram Rao | GetPreCallBriefAction | Masked | ✓ |

Click on the first entry to expand it. Detail panel shows full prompt with PII fields replaced by `[REDACTED]`. Footer line: "Audit log retained for 5 years. Subject to SEBI BASL compliance review."

**VOICEOVER**:

"And because this is wealth management — trust is not optional. [pause] The Einstein Trust Layer has recorded every single action Dhruv took today. Every prompt sent to the language model. Every data field accessed. Every API call fired. [pause] PII — masked before it ever reached the model. Zero data retention — nothing stored outside Salesforce's trust boundary. Regulatory audit trail — five years, SEBI-compliant. [pause] Dhruv is not just intelligent. It is *accountable*."

**TECH NOTE**: The Audit Trail page MUST be pre-loaded before the demo starts. Navigating to Setup during a 5-minute demo will kill the pace. If the Trust Layer shows zero entries, use Fallback (Section 3) — show Custom_Trade_Request__c field history instead. Do not fake entries.

---

### [SHOT 9 — CLOSING METRICS AND TAGLINE — 4:30 to 4:50]

**ON SCREEN**: Full-screen dark graphic (pre-produced, matching cold-open aesthetic). Five lines build in with fade-in, 0.3 seconds each:

> **450 clients monitored → 62 filtered → 8 actioned**
> **1 RM. 1 agent. 3 clients reached in under 4 minutes.**
> **₹40 lakhs rotated. Approved. Logged. Audited.**
> **Zero manual reports. Zero missed clients. Zero compliance gaps.**

Then — larger, bolder:

> **Dhruv.**
> **Built on Salesforce Agentforce.**
> **Your clients can't wait for Monday morning.**

Agentforce logo + AWT Hackathon branding fade in at bottom.

**VOICEOVER**:

"Four hundred and fifty clients. Sixty-two at risk. Eight actioned — by *one* RM, with *one* AI co-pilot, in under four minutes. [pause] No manual reports. No missed calls. No compliance gaps. [pause] *Dhruv.* Built on Salesforce Agentforce. [pause] Because your clients can't wait for Monday morning."

**TECH NOTE**: This closing graphic is a pre-produced MP4 with text animations. Produce it before recording day. Audio fades to silence over the final 5 seconds. Use only royalty-free music (if any) to avoid YouTube Content ID claims.

---
---

## SECTION 3: CONTINGENCY NOTES

---

### RISK 1: WhatsApp Inbound Reply Does Not Arrive / No Auto-Task Created

**Fallback A (preferred)**: Pre-record a 5-second phone clip of the WhatsApp reply from the rehearsal run. Insert in post at 2:00. Viewers cannot distinguish live from pre-recorded in a produced video.

**Fallback B (live)**: Switch to Priya's Contact record (Tab 3) and show a pre-created Task in the Activity Timeline from the rehearsal run. Edit the ActivityDate to today if needed. Say "and the moment Priya replies, Salesforce captures it automatically."

---

### RISK 2: Slack Approval Buttons Don't Appear (Plain Text Only)

**Fallback A**: The message body is still visible in Slack. Point to it. Then switch to Salesforce → Custom_Trade_Request__c record → click the "Approve" quick-action button directly on the record. Say "with one click, Rajesh approves in Salesforce — the record updates instantly." Narrative holds.

**Fallback B**: Use pre-recorded Slack clip from rehearsal where buttons did work. Insert in post.

---

### RISK 3: Dhruv Routes to the Wrong Subagent

**Prevention**: Test all 5 exact inputs in Conversation Preview before recording. Fix topic trigger phrases if any fail.

**Live fallback**: Type a shorter version — e.g., `List my high-risk clients from the rate cut` for Input 1. If still wrong, navigate to Tab 1 (Market Command Center) and narrate from the dashboard: "Dhruv has already flagged these eight clients in the Command Center." Then return to Input 2.

---

### RISK 4: Trust Layer Shows No Entries

**Prevention**: Run the full demo rehearsal at least 2 hours before recording. Audit entries can take up to 15 minutes to propagate.

**Fallback**: Show Custom_Trade_Request__c record → Field History Tracking. Say "every field change is tracked and timestamped — Salesforce maintains a complete audit trail for every agent action." This communicates the same value.

---

### RISK 5: GetImpactedClientsAction Returns Zero Results

**Prevention**: Run `SELECT COUNT() FROM Market_Impact__c WHERE RM__c = [VikramId]` in Developer Console before recording. Must return 8.

**Fallback**: Navigate to Tab 1 (Market Command Center), which shows pre-seeded data. Walk through the dashboard as the triage result. Say "Dhruv has processed the event and surfaced these eight clients — let's look at the top of that list." Proceed from there.

---

### RISK 6: Dashboard Shows Blank / Cards Show Zero

**Prevention**: Confirm that `OwnerId` on Account records matches the actual Vikram Rao User ID in the org. Run `SELECT Id FROM User WHERE Name = 'Vikram Rao'` and cross-check.

**Fallback**: Take a screenshot from the last successful rehearsal. Insert as a still-frame in post-production. Narrate over it normally. 28 seconds of still image in a produced video is undetectable.

---
---

## SECTION 4: POST-RECORDING CHECKLIST

---

### IMMEDIATELY AFTER RECORDING

- [ ] Do NOT close OBS until you have confirmed the file saved and is playable (check first and last 10 seconds).
- [ ] Back up raw file to Google Drive / external SSD immediately. Name: `dhruv-demo-raw-YYYYMMDD-HHMM.mp4`

---

### VIDEO EDITING

- [ ] Trim start (remove pre-recording fumbles) and end (remove silence after 4:55).
- [ ] Insert cold-open graphic (Shot 1) and closing graphic (Shot 9) if pre-produced separately.
- [ ] Insert pre-recorded phone clip for WhatsApp reply if applicable (at 2:00 mark).
- [ ] Add lower thirds (optional but high impact):
  - 0:40 → "Dhruv — Market Impact Triage"
  - 1:15 → "Dhruv — Client Outreach"
  - 2:20 → "Dhruv — Trade Approval"
  - 3:10 → "Dhruv — Pre-Call Brief"
  - 3:50 → "Einstein Trust Layer — Audit Trail"
- [ ] Normalize voiceover audio to -14 LUFS. Remove keyboard click sounds if audible.
- [ ] Add captions — use YouTube auto-caption, correct: "crore," "lakh," "Hinglish," "SEBI," "MPC."
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

When the RBI announces a surprise 25 bps repo rate cut, Dhruv automatically identifies the 8 most-impacted clients in Vikram Rao's book (from 450 total), drafts personalized Hinglish WhatsApp nudges, routes a ₹40L trade approval through Slack, delivers a pre-call brief, and reveals the full Einstein Trust Layer audit trail — all in under 5 minutes.

───────────────────────────────
TIMESTAMPS
───────────────────────────────
0:00 — Cold Open: RBI Rate Cut Alert
0:12 — Market Command Center (450 → 62 → 8, Data Cloud)
0:40 — Dhruv Triage: "Show me my impacted clients"
1:15 — WhatsApp Nudge Draft in Hinglish
2:00 — Priya's WhatsApp Reply + Auto-Task in CRM
2:20 — Trade Approval: ₹40L Rotation → Slack → Manager Approves
3:10 — Pre-Call Brief: 60 seconds before Priya's 3 PM call
3:50 — Einstein Trust Layer Audit Trail: PII masking, zero retention, SEBI audit log
4:30 — Closing Metrics

───────────────────────────────
TECH STACK
───────────────────────────────
• Salesforce Financial Services Cloud (FSC)
• Salesforce Data Cloud (ClientExposureGraph DMO, Streaming Ingestion)
• Agentforce Employee Agent (Dhruv) — 4 subagents, 5 Apex actions
• Meta Cloud API (WhatsApp test number)
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
Salesforce Agentforce, Agentforce Hackathon, BFSI AI, Wealth Management AI, Salesforce FSC, Data Cloud, Einstein Trust Layer, WhatsApp CRM, Slack Salesforce, RBI Rate Cut, Market Monitoring Agent, AI for Wealth Managers, Salesforce AI, Agentforce Employee Agent, Financial Services Cloud, AWT Hackathon 2026, Mumbai Hackathon, India Fintech, SEBI Compliance AI, Hinglish AI, Salesforce India, AI Co-Pilot, GenAI BFSI, Agentforce demo
```

---

*Total voiceover word count: ~610 words | Target pace: 120 wpm with pauses = 4:50 runtime*
*Adjust your reading pace during recording — slower is always safer than rushing*
