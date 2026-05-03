/**
 * Public REST webhook that Meta calls when Priya replies on WhatsApp.
 * Exposed via Force.com Site (no auth required).
 *
 * GET  → webhook verification handshake with Meta
 * POST → parse incoming message, create Event on matching Account
 *
 * Setup required (see docs):
 *   1. Force.com Site with this class in Guest User's Apex access
 *   2. Guest User profile: Events → Create enabled
 *   3. Meta Webhook: callback URL + verify token "dhruv_hackathon_2026"
 *   4. Meta Webhook: subscribe to "messages" field
 */
@RestResource(urlMapping='/whatsapp/webhook/*')
global without sharing class WhatsAppWebhookHandler {

    private static final String VERIFY_TOKEN = 'dhruv_hackathon_2026';

    @HttpGet
    global static void doGet() {
        RestRequest  req       = RestContext.request;
        RestResponse res       = RestContext.response;
        String       mode      = req.params.get('hub.mode');
        String       token     = req.params.get('hub.verify_token');
        String       challenge = req.params.get('hub.challenge');
        if (mode == 'subscribe' && token == VERIFY_TOKEN) {
            res.statusCode   = 200;
            res.responseBody = Blob.valueOf(challenge);
        } else {
            res.statusCode = 403;
        }
    }

    @HttpPost
    global static void doPost() {
        RestContext.response.statusCode = 200; // Meta requires 200 regardless
        try {
            Map<String, Object> payload = (Map<String, Object>)
                JSON.deserializeUntyped(RestContext.request.requestBody.toString());

            // Drill: entry[0].changes[0].value.messages[0]
            List<Object> entries = (List<Object>) payload.get('entry');
            if (entries == null || entries.isEmpty()) return;
            List<Object> changes = (List<Object>)
                ((Map<String, Object>) entries[0]).get('changes');
            if (changes == null || changes.isEmpty()) return;
            Map<String, Object> value = (Map<String, Object>)
                ((Map<String, Object>) changes[0]).get('value');
            if (value == null) return;
            List<Object> messages = (List<Object>) value.get('messages');
            if (messages == null || messages.isEmpty()) return;

            Map<String, Object> msg = (Map<String, Object>) messages[0];
            if (!'text'.equals(msg.get('type'))) return;

            String fromPhone = '+' + (String) msg.get('from'); // Meta sends without +
            String msgBody   = (String)((Map<String, Object>) msg.get('text')).get('body');

            // Parse "30 min(s)" — default 30
            Integer minutes = 30;
            Matcher mt = Pattern.compile('(\\d+)\\s*min').matcher(msgBody.toLowerCase());
            if (mt.find()) minutes = Integer.valueOf(mt.group(1));

            List<Demo_Recipients__mdt> recs = [
                SELECT Account__c
                FROM   Demo_Recipients__mdt
                WHERE  Phone_E164__c = :fromPhone
                LIMIT  1
            ];
            if (recs.isEmpty()) return;

            insert new Event(
                WhatId        = Id.valueOf(recs[0].Account__c),
                Subject       = 'Call with Priya — WhatsApp Scheduled',
                StartDateTime = DateTime.now().addMinutes(minutes),
                EndDateTime   = DateTime.now().addMinutes(minutes + 30),
                Description   = 'Auto-scheduled from WhatsApp reply: ' + msgBody,
                Type          = 'Call'
            );
        } catch (Exception e) {
            System.debug('WhatsApp webhook error: ' + e.getMessage());
        }
    }
}
