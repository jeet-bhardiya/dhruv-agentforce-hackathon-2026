public with sharing class MarketCommandCenterController {

    public class DashboardData {
        @AuraEnabled public String  eventHeadline;
        @AuraEnabled public String  eventSector;
        @AuraEnabled public Decimal eventPctChange;
        @AuraEnabled public String  eventSeverity;
        @AuraEnabled public String  eventTime;
        @AuraEnabled public Integer totalClients;
        @AuraEnabled public Integer impactedClients;
        @AuraEnabled public Integer myClients;
        @AuraEnabled public List<ClientRow> myImpactedClients;
    }

    public class ClientRow {
        @AuraEnabled public String  accountId;
        @AuraEnabled public String  clientName;
        @AuraEnabled public String  city;
        @AuraEnabled public Decimal aum;
        @AuraEnabled public Decimal exposurePct;
        @AuraEnabled public Decimal exposureAmount;
        @AuraEnabled public String  severity;
        @AuraEnabled public String  preferredChannel;
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData() {
        DashboardData data = new DashboardData();

        List<Market_Event__c> events = [
            SELECT Id, Event_Type__c, Sector__c, Headline__c, Pct_Change__c, Severity__c, CreatedDate
            FROM Market_Event__c ORDER BY CreatedDate DESC LIMIT 1
        ];

        Id latestEventId = null;
        if (!events.isEmpty()) {
            Market_Event__c ev = events[0];
            latestEventId        = ev.Id;
            data.eventSector     = ev.Sector__c;
            data.eventPctChange  = ev.Pct_Change__c;
            data.eventSeverity   = ev.Severity__c;
            data.eventTime       = ev.CreatedDate.format('dd MMM yyyy, HH:mm');
            data.eventHeadline   = String.isNotBlank(ev.Headline__c)
                ? ev.Headline__c
                : ev.Event_Type__c + ' — ' + ev.Sector__c + ' sector';
        }

        data.totalClients    = [SELECT COUNT() FROM Account WHERE IsPersonAccount = true];
        data.impactedClients = latestEventId != null
            ? [SELECT COUNT() FROM Market_Impact__c WHERE Event__c = :latestEventId]
            : 0;

        List<Market_Impact__c> myImpacts = [
            SELECT Account__c, Account__r.Name, Account__r.BillingCity, Account__r.AUM__c,
                   Account__r.Preferred_Channel__c,
                   Exposure_Pct_of_AUM__c, Exposure_Amount__c, Event__r.Severity__c
            FROM Market_Impact__c
            WHERE Account__r.OwnerId = :UserInfo.getUserId()
              AND Event__c = :latestEventId
            ORDER BY Exposure_Amount__c DESC NULLS LAST
            LIMIT 20
        ];
        data.myClients = myImpacts.size();

        data.myImpactedClients = new List<ClientRow>();
        for (Market_Impact__c mi : myImpacts) {
            ClientRow row        = new ClientRow();
            row.accountId        = mi.Account__c;
            row.clientName       = mi.Account__r.Name;
            row.city             = mi.Account__r.BillingCity;
            row.aum              = mi.Account__r.AUM__c;
            row.exposurePct      = mi.Exposure_Pct_of_AUM__c;
            row.exposureAmount   = mi.Exposure_Amount__c;
            row.severity         = mi.Event__r.Severity__c;
            row.preferredChannel = mi.Account__r.Preferred_Channel__c;
            data.myImpactedClients.add(row);
        }

        return data;
    }
}
