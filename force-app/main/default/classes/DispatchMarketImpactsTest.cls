@isTest
private class DispatchMarketImpactsTest {

    @TestSetup
    static void seed() {
        Id paRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount').getRecordTypeId();

        insert new Account(
            RecordTypeId = paRtId,
            FirstName    = 'Hero',
            LastName     = 'Test',
            BillingCity  = 'Mumbai',
            AUM__c       = 1000000
        );

        insert new Market_Event__c(
            Symbol__c       = 'BANKNIFTY',
            Event_Type__c   = 'RBI_MPC',
            Pct_Change__c   = -1.25,
            Sector__c       = 'Banking',
            Severity__c     = 'High',
            Trigger_Time__c = System.now()
        );
    }

    @isTest
    static void createsImpactsAndNotifiesOwner() {
        Account hero = [SELECT Id FROM Account WHERE FirstName = 'Hero' LIMIT 1];
        Market_Event__c evt = [SELECT Id FROM Market_Event__c LIMIT 1];

        DispatchMarketImpacts.Request r = new DispatchMarketImpacts.Request();
        r.marketEventId    = evt.Id;
        r.accountIds       = new List<Id>{ hero.Id };
        r.exposurePcts     = new List<Decimal>{ 28.0 };
        r.exposureAmounts  = new List<Decimal>{ 280000 };
        r.headline         = 'RBI cut 25 bps';

        Test.startTest();
        List<DispatchMarketImpacts.Response> out =
            DispatchMarketImpacts.dispatch(new List<DispatchMarketImpacts.Request>{ r });
        Test.stopTest();

        System.assertEquals(1, out[0].impactCount);
        System.assertEquals(1, out[0].notifiedRMs);

        List<Market_Impact__c> impacts = [
            SELECT Account__c, Event__c, Exposure_Pct_of_AUM__c
            FROM Market_Impact__c
        ];
        System.assertEquals(1, impacts.size());
        System.assertEquals(hero.Id, impacts[0].Account__c);
        System.assertEquals(evt.Id, impacts[0].Event__c);
        System.assertEquals(28.0, impacts[0].Exposure_Pct_of_AUM__c);
    }

    @isTest
    static void emptyAccountListIsNoOp() {
        Market_Event__c evt = [SELECT Id FROM Market_Event__c LIMIT 1];

        DispatchMarketImpacts.Request r = new DispatchMarketImpacts.Request();
        r.marketEventId    = evt.Id;
        r.accountIds       = new List<Id>();
        r.exposurePcts     = new List<Decimal>();
        r.exposureAmounts  = new List<Decimal>();

        Test.startTest();
        List<DispatchMarketImpacts.Response> out =
            DispatchMarketImpacts.dispatch(new List<DispatchMarketImpacts.Request>{ r });
        Test.stopTest();

        System.assertEquals(0, out[0].impactCount);
        System.assertEquals(0, out[0].notifiedRMs);
        System.assertEquals(0, [SELECT COUNT() FROM Market_Impact__c]);
    }
}
