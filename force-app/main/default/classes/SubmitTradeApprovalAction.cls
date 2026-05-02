public with sharing class SubmitTradeApprovalAction {

    public class Request {
        @InvocableVariable(required=true) public String accountId;
        @InvocableVariable(required=true) public Decimal amount;
        @InvocableVariable(required=true) public String instrument;
        @InvocableVariable                public String rationale;
    }

    public class Response {
        @InvocableVariable public String requestId;
        @InvocableVariable public String status;
        @InvocableVariable public String summary;
    }

    @InvocableMethod(
        label='Submit Trade Approval'
        description='Creates a Custom_Trade_Request__c record for manager approval and returns the request ID.'
    )
    public static List<Response> submit(List<Request> reqs) {
        List<Response> out = new List<Response>();
        List<Custom_Trade_Request__c> records = new List<Custom_Trade_Request__c>();
        for (Request r : reqs) {
            records.add(new Custom_Trade_Request__c(
                Client__c    = Id.valueOf(r.accountId),
                RM__c        = UserInfo.getUserId(),
                Amount__c    = r.amount,
                Instrument__c = r.instrument,
                Rationale__c = r.rationale,
                Status__c    = 'Pending'
            ));
        }
        insert records;

        List<Task> logs = new List<Task>();
        for (Integer i = 0; i < reqs.size(); i++) {
            Response resp = new Response();
            resp.requestId = records[i].Id;
            resp.status    = 'Pending';
            resp.summary   = 'Trade request for ₹' + (reqs[i].amount / 100000).setScale(1)
                + 'L in ' + reqs[i].instrument + ' submitted for approval. ID: ' + records[i].Id;
            out.add(resp);

            logs.add(new Task(
                WhatId      = Id.valueOf(reqs[i].accountId),
                Subject     = 'Trade Rotation Request Submitted',
                Description = 'Amount: ₹' + (reqs[i].amount / 100000).setScale(1) + 'L'
                    + ' | Instrument: ' + reqs[i].instrument
                    + ' | Rationale: ' + (reqs[i].rationale ?? '')
                    + ' | Request ID: ' + records[i].Id,
                Status       = 'Completed',
                ActivityDate = Date.today(),
                Type         = 'Other'
            ));
        }
        insert logs;
        return out;
    }
}
