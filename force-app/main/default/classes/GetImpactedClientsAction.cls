public with sharing class GetImpactedClientsAction {

    public class Request {
        @InvocableVariable public String marketEventId;
        @InvocableVariable public Integer maxResults;
    }

    public class Response {
        @InvocableVariable public Integer clientCount;
        @InvocableVariable public String clientSummary;
    }

    @InvocableMethod(
        label='Get Impacted Clients'
        description='Returns impacted clients for the running RM sorted by exposure amount. Pass marketEventId to filter to a specific event.'
    )
    public static List<Response> getImpacted(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) out.add(runOne(r));
        return out;
    }

    private static Response runOne(Request r) {
        Integer lim = (r.maxResults != null && r.maxResults > 0) ? r.maxResults : 10;
        Id userId = UserInfo.getUserId();

        List<Market_Impact__c> impacts;
        if (String.isNotBlank(r.marketEventId)) {
            Id evtId = Id.valueOf(r.marketEventId);
            impacts = [
                SELECT Account__c, Account__r.Name, Account__r.AUM__c,
                       Account__r.BillingCity, Account__r.Preferred_Channel__c,
                       Exposure_Pct_of_AUM__c, Exposure_Amount__c
                FROM Market_Impact__c
                WHERE Account__r.OwnerId = :userId AND Event__c = :evtId
                ORDER BY Exposure_Amount__c DESC NULLS LAST LIMIT :lim
            ];
        } else {
            impacts = [
                SELECT Account__c, Account__r.Name, Account__r.AUM__c,
                       Account__r.BillingCity, Account__r.Preferred_Channel__c,
                       Exposure_Pct_of_AUM__c, Exposure_Amount__c
                FROM Market_Impact__c
                WHERE Account__r.OwnerId = :userId
                ORDER BY Exposure_Amount__c DESC NULLS LAST LIMIT :lim
            ];
        }

        Response resp = new Response();
        resp.clientCount = impacts.size();

        if (impacts.isEmpty()) {
            resp.clientSummary = 'No impacted clients found for your portfolio.';
            return resp;
        }

        List<String> lines = new List<String>();
        lines.add('You have ' + impacts.size() + ' impacted client(s):');
        Integer rank = 1;
        for (Market_Impact__c mi : impacts) {
            String aum = mi.Account__r.AUM__c != null
                ? '₹' + (mi.Account__r.AUM__c / 100000).setScale(1) + 'L AUM' : '';
            String pct = mi.Exposure_Pct_of_AUM__c != null
                ? mi.Exposure_Pct_of_AUM__c.setScale(1) + '% exposed' : '';
            String amt = mi.Exposure_Amount__c != null
                ? '₹' + (mi.Exposure_Amount__c / 100000).setScale(1) + 'L at risk' : '';
            String channel = String.isNotBlank(mi.Account__r.Preferred_Channel__c)
                ? mi.Account__r.Preferred_Channel__c : 'WhatsApp';
            lines.add(rank + '. ' + mi.Account__r.Name
                + ' | ' + mi.Account__r.BillingCity
                + ' | ' + aum + ' | ' + pct + ' (' + amt + ')'
                + ' | Channel: ' + channel
                + ' | AccountId: ' + mi.Account__c);
            rank++;
        }
        resp.clientSummary = String.join(lines, '\n');
        return resp;
    }
}
