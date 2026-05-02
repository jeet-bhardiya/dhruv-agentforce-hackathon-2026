public with sharing class GetPreCallBriefAction {

    public class Request {
        @InvocableVariable public String accountId;
        @InvocableVariable public String clientName;
    }

    public class Response {
        @InvocableVariable public String clientName;
        @InvocableVariable public String brief;
    }

    @InvocableMethod(
        label='Get Pre-Call Brief'
        description='Returns a structured pre-call brief for the RM: client snapshot, top holdings, recent market impacts, open trade requests, and suggested talking points.'
    )
    public static List<Response> getBrief(List<Request> reqs) {
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
        if (acctId == null) { resp.brief = 'Client not found: ' + (r.clientName ?? r.accountId); return resp; }

        List<Account> accts = [
            SELECT Id, FirstName, LastName, AUM__c, BillingCity, Preferred_Channel__c
            FROM Account WHERE Id = :acctId LIMIT 1
        ];
        if (accts.isEmpty()) { resp.brief = 'Client not found.'; return resp; }
        Account a = accts[0];
        resp.clientName = a.FirstName + ' ' + a.LastName;

        List<SecuritiesHolding> holdings = [
            SELECT FinancialSecurity.Name, FinancialSecurity.Symbol, MarketValue
            FROM SecuritiesHolding
            WHERE PrimaryOwnerId = :acctId
            ORDER BY MarketValue DESC NULLS LAST LIMIT 5
        ];

        List<Market_Impact__c> impacts = [
            SELECT Event__r.Headline__c, Event__r.Sector__c, Event__r.Severity__c,
                   Exposure_Pct_of_AUM__c, Exposure_Amount__c
            FROM Market_Impact__c
            WHERE Account__c = :acctId
            ORDER BY CreatedDate DESC LIMIT 5
        ];

        List<Custom_Trade_Request__c> openRequests = [
            SELECT Id, Amount__c, Instrument__c, Status__c, CreatedDate
            FROM Custom_Trade_Request__c
            WHERE Client__c = :acctId AND Status__c = 'Pending'
            ORDER BY CreatedDate DESC LIMIT 3
        ];

        List<String> lines = new List<String>();
        lines.add('PRE-CALL BRIEF — ' + resp.clientName);
        lines.add('='.repeat(40));
        lines.add('City: ' + (a.BillingCity != null ? a.BillingCity : 'N/A'));
        lines.add('AUM: ₹' + (a.AUM__c != null ? (a.AUM__c / 100000).setScale(2) + 'L' : 'N/A'));
        lines.add('Preferred Channel: ' + (String.isNotBlank(a.Preferred_Channel__c)
            ? a.Preferred_Channel__c : 'WhatsApp'));

        if (!holdings.isEmpty()) {
            lines.add('\nPORTFOLIO SNAPSHOT:');
            for (SecuritiesHolding h : holdings) {
                lines.add('  • ' + h.FinancialSecurity.Symbol
                    + ' — ₹' + (h.MarketValue / 100000).setScale(1) + 'L');
            }
        }

        if (!impacts.isEmpty()) {
            lines.add('\nRECENT MARKET ALERTS:');
            for (Market_Impact__c mi : impacts) {
                String headline = String.isNotBlank(mi.Event__r.Headline__c)
                    ? mi.Event__r.Headline__c : mi.Event__r.Sector__c + ' event';
                String pct = mi.Exposure_Pct_of_AUM__c != null
                    ? mi.Exposure_Pct_of_AUM__c.setScale(1) + '%' : '';
                String amt = mi.Exposure_Amount__c != null
                    ? '₹' + (mi.Exposure_Amount__c / 100000).setScale(1) + 'L' : '';
                lines.add('  • ' + headline + ' | Exposure: ' + pct + ' (' + amt + ')'
                    + ' | Severity: ' + (mi.Event__r.Severity__c != null ? mi.Event__r.Severity__c : 'N/A'));
            }
        }

        if (!openRequests.isEmpty()) {
            lines.add('\nOPEN TRADE REQUESTS:');
            for (Custom_Trade_Request__c tr : openRequests) {
                lines.add('  • ₹' + (tr.Amount__c / 100000).setScale(1) + 'L in '
                    + tr.Instrument__c + ' — ' + tr.Status__c);
            }
        }

        lines.add('\nSUGGESTED TALKING POINTS:');
        if (!impacts.isEmpty()) {
            Market_Impact__c top = impacts[0];
            String sector = top.Event__r.Sector__c;
            String amt = top.Exposure_Amount__c != null
                ? '₹' + (top.Exposure_Amount__c / 100000).setScale(1) + 'L' : '';
            lines.add('  1. Discuss impact of recent ' + sector + ' event on their portfolio (' + amt + ' exposure).');
        }
        lines.add('  2. Review rebalancing options given current rate environment.');
        if (!openRequests.isEmpty()) {
            lines.add('  3. Follow up on pending trade request of ₹'
                + (openRequests[0].Amount__c / 100000).setScale(1) + 'L.');
        }

        resp.brief = String.join(lines, '\n');
        return resp;
    }
}
