/**
 * Sends a WhatsApp nudge to a client via Meta Cloud API.
 *
 * Prerequisites:
 *   - Named Credential "Meta_WhatsApp_API" → https://graph.facebook.com, No Auth
 *   - Custom Label "Meta_WA_Token"    → Meta access token
 *   - Custom Label "Meta_WA_Phone_Id" → Meta Phone Number ID
 *   - Demo_Recipients__mdt record for each demo client with Active__c = true
 *     and Phone_E164__c set to the recipient's WhatsApp number
 */
public with sharing class SendWhatsAppNudgeAction {

    public class Request {
        @InvocableVariable(required=true) public String accountId;
        @InvocableVariable(required=true) public String messageBody;
    }

    public class Response {
        @InvocableVariable public String status;
        @InvocableVariable public String logId;
    }

    @InvocableMethod(
        label='Send WhatsApp Nudge'
        description='Sends a WhatsApp message to the client via Meta Cloud API and logs it as a Task.'
    )
    public static List<Response> send(List<Request> reqs) {
        List<Response> out   = new List<Response>();
        List<Task>     tasks = new List<Task>();

        String phoneNumberId = System.Label.Meta_WA_Phone_Id;
        String accessToken   = System.Label.Meta_WA_Token;

        for (Request r : reqs) {
            // Look up recipient phone from Custom Metadata
            List<Demo_Recipients__mdt> recs = [
                SELECT Phone_E164__c
                FROM   Demo_Recipients__mdt
                WHERE  Account__c = :r.accountId
                LIMIT  1
            ];

            String sendStatus = 'skipped – no recipient configured';
            if (!recs.isEmpty()) {
                sendStatus = sendViaMetaApi(
                    phoneNumberId,
                    accessToken,
                    recs[0].Phone_E164__c,
                    r.messageBody
                );
            }

            tasks.add(new Task(
                WhatId       = Id.valueOf(r.accountId),
                Subject      = 'WhatsApp Nudge Sent',
                Description  = r.messageBody,
                Status       = 'Completed',
                ActivityDate = Date.today(),
                Type         = 'Call'
            ));

            Response resp = new Response();
            resp.status = sendStatus;
            out.add(resp);
        }

        insert tasks;
        for (Integer i = 0; i < reqs.size(); i++) {
            out[i].logId = tasks[i].Id;
        }
        return out;
    }

    private static String sendViaMetaApi(
        String phoneNumberId,
        String token,
        String toPhone,
        String body
    ) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:Meta_WhatsApp_API/v25.0/' + phoneNumberId + '/messages'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setTimeout(10000);

            req.setBody(JSON.serialize(new Map<String, Object>{
                'messaging_product' => 'whatsapp',
                'to'                => toPhone,
                'type'              => 'text',
                'text'              => new Map<String, Object>{ 'body' => body }
            }));

            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                return 'sent';
            }
            System.debug('WhatsApp API error ' + res.getStatusCode() + ': ' + res.getBody());
            return 'error: ' + res.getStatusCode();

        } catch (Exception e) {
            System.debug('WhatsApp send exception: ' + e.getMessage());
            return 'error: ' + e.getMessage();
        }
    }
}
