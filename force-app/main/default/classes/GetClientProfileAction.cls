public with sharing class GetClientProfileAction {

    public class Request {
        @InvocableVariable public String accountId;
        @InvocableVariable public String clientName;
    }

    public class Response {
        @InvocableVariable public String accountId;
        @InvocableVariable public String clientName;
        @InvocableVariable public String preferredChannel;
        @InvocableVariable public String profile;
    }

    @InvocableMethod(
        label='Get Client Profile'
        description='Returns a 360-degree client profile: AUM, top holdings, recent market impacts, and city.'
    )
    public static List<Response> getProfile(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) out.add(runOne(r));
        return out;
    }

    private static Id resolveAccountId(Request r) {
        if (String.isNotBlank(r.accountId)) {
            try { return Id.valueOf(r.accountId); } catch (System.StringException e) { /* not a valid ID — fall through to name search */ }
        }
        String nameToSearch = String.isNotBlank(r.clientName) ? r.clientName : r.accountId;
        if (String.isNotBlank(nameToSearch)) {
            String q = '%' + nameToSearch + '%';
            List<Account> found = [SELECT Id FROM Account WHERE Name LIKE :q AND IsPersonAccount = true LIMIT 1];
            return found.isEmpty() ? null : found[0].Id;
        }
        return null;
    }

    private static Response runOne(Request r) {
        Response resp = new Response();
        Id acctId = resolveAccountId(r);
        if (acctId == null) { resp.profile = 'Client not found: ' + (r.clientName ?? r.accountId); return resp; }

        List<Account> accts = [
            SELECT Id, FirstName, LastName, AUM__c, BillingCity, Preferred_Channel__c
            FROM Account WHERE Id = :acctId LIMIT 1
        ];
        if (accts.isEmpty()) { resp.profile = 'Client not found.'; return resp; }
        Account a = accts[0];
        resp.accountId = String.valueOf(acctId);
        resp.clientName = a.FirstName + ' ' + a.LastName;
        resp.preferredChannel = String.isNotBlank(a.Preferred_Channel__c)
            ? a.Preferred_Channel__c : 'WhatsApp';

        List<SecuritiesHolding> holdings = [
            SELECT FinancialSecurity.Name, FinancialSecurity.Symbol, MarketValue
            FROM SecuritiesHolding
            WHERE PrimaryOwnerId = :acctId
            ORDER BY MarketValue DESC NULLS LAST LIMIT 5
        ];

        List<Market_Impact__c> impacts = [
            SELECT Event__r.Headline__c, Event__r.Sector__c,
                   Exposure_Pct_of_AUM__c, Exposure_Amount__c
            FROM Market_Impact__c
            WHERE Account__c = :acctId
            ORDER BY CreatedDate DESC LIMIT 3
        ];

        List<String> lines = new List<String>();
        lines.add('CLIENT: ' + resp.clientName);
        lines.add('City: ' + (a.BillingCity != null ? a.BillingCity : 'N/A'));
        lines.add('AUM: ₹' + (a.AUM__c != null ? (a.AUM__c / 100000).setScale(2) + 'L' : 'N/A'));
        lines.add('Preferred Channel: ' + resp.preferredChannel);

        if (!holdings.isEmpty()) {
            lines.add('\nTOP HOLDINGS:');
            for (SecuritiesHolding h : holdings) {
                lines.add('  • ' + h.FinancialSecurity.Symbol
                    + ' — ₹' + (h.MarketValue / 100000).setScale(1) + 'L');
            }
        }

        if (!impacts.isEmpty()) {
            lines.add('\nRECENT MARKET IMPACTS:');
            for (Market_Impact__c mi : impacts) {
                String headline = String.isNotBlank(mi.Event__r.Headline__c)
                    ? mi.Event__r.Headline__c : mi.Event__r.Sector__c;
                String pct = mi.Exposure_Pct_of_AUM__c != null
                    ? mi.Exposure_Pct_of_AUM__c.setScale(1) + '% exposure' : '';
                lines.add('  • ' + headline + ' — ' + pct);
            }
        }

        resp.profile = String.join(lines, '\n');
        return resp;
    }
}
