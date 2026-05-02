/**
 * Sends a WhatsApp nudge to a client.
 * Phase 3: logs the message as a Task (visible in Activity timeline).
 * Phase 4: swap the Task insert for a real Meta WhatsApp API callout.
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
        description='Sends a WhatsApp message to the client and logs it as a Task.'
    )
    public static List<Response> send(List<Request> reqs) {
        List<Response> out = new List<Response>();
        List<Task> tasks = new List<Task>();
        for (Request r : reqs) {
            tasks.add(new Task(
                WhatId       = Id.valueOf(r.accountId),
                Subject      = 'WhatsApp Nudge Sent',
                Description  = r.messageBody,
                Status       = 'Completed',
                ActivityDate = Date.today(),
                Type         = 'Call'
            ));
        }
        insert tasks;
        for (Integer i = 0; i < reqs.size(); i++) {
            Response resp = new Response();
            resp.status = 'sent';
            resp.logId  = tasks[i].Id;
            out.add(resp);
        }
        return out;
    }
}
