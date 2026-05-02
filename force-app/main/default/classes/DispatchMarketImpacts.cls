/**
 * Invocable that consumes the impacted-accounts list from
 * QueryClientExposureGraph and:
 *   1. Bulk-creates Market_Impact__c rows linked to the parent Market_Event__c
 *   2. Sends a single Custom Notification to all unique RMs (Account.OwnerId)
 *
 * Used by MarketImpact_Detect_Segment Flow as the dispatch step. Returns
 * counts so the Flow can log/display them.
 */
public with sharing class DispatchMarketImpacts {

    public class Request {
        @InvocableVariable(required=true) public Id marketEventId;
        @InvocableVariable(required=true) public List<Id> accountIds;
        @InvocableVariable(required=true) public List<Decimal> exposurePcts;
        @InvocableVariable(required=true) public List<Decimal> exposureAmounts;
        @InvocableVariable                public String headline;
    }

    public class Response {
        @InvocableVariable public Integer impactCount;
        @InvocableVariable public Integer notifiedRMs;
    }

    @InvocableMethod(
        label='Dispatch Market Impacts'
        description='Bulk-creates Market_Impact__c records and sends Custom Notifications to impacted RMs.'
    )
    public static List<Response> dispatch(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            out.add(runOne(r));
        }
        return out;
    }

    private static Response runOne(Request r) {
        Response resp = new Response();
        resp.impactCount = 0;
        resp.notifiedRMs = 0;

        Integer n = (r.accountIds == null) ? 0 : r.accountIds.size();
        if (n == 0) return resp;

        List<Market_Impact__c> impacts = new List<Market_Impact__c>();
        for (Integer i = 0; i < n; i++) {
            impacts.add(new Market_Impact__c(
                Account__c             = r.accountIds[i],
                Event__c               = r.marketEventId,
                Exposure_Amount__c     = r.exposureAmounts[i],
                Exposure_Pct_of_AUM__c = r.exposurePcts[i]
            ));
        }
        insert impacts;
        resp.impactCount = impacts.size();

        Set<Id> ownerIds = new Set<Id>();
        for (Account a : [SELECT OwnerId FROM Account WHERE Id IN :r.accountIds]) {
            ownerIds.add(a.OwnerId);
        }

        if (!ownerIds.isEmpty()) {
            sendNotification(ownerIds, r.marketEventId, r.headline, n);
            resp.notifiedRMs = ownerIds.size();
        }
        return resp;
    }

    private static void sendNotification(
        Set<Id> recipients, Id targetId, String headline, Integer count
    ) {
        List<CustomNotificationType> types = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = 'Market_Impact_Notification' LIMIT 1
        ];
        if (types.isEmpty()) {
            System.debug(LoggingLevel.WARN,
                'Market_Impact_Notification type not found — skipping notification.');
            return;
        }

        Messaging.CustomNotification notif = new Messaging.CustomNotification();
        notif.setNotificationTypeId(types[0].Id);
        notif.setTitle('Market alert' + (String.isBlank(headline) ? '' : ' — ' + headline));
        notif.setBody(count + ' of your clients have exposure to this event. Tap to triage.');
        notif.setTargetId(targetId);

        Set<String> recipientStrs = new Set<String>();
        for (Id rid : recipients) recipientStrs.add(String.valueOf(rid));

        try {
            notif.send(recipientStrs);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'Custom notification send failed: ' + e.getMessage());
        }
    }
}
