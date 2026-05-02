@isTest
private class QueryClientExposureGraphTest {

    @TestSetup
    static void seed() {
        Id paRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount').getRecordTypeId();

        Account hero = new Account(
            RecordTypeId    = paRtId,
            FirstName       = 'Hero',
            LastName        = 'Test',
            BillingCity     = 'Mumbai',
            AUM__c          = 1000000,
            External_Id__c  = 'TEST_PA_HERO'
        );
        Account zero = new Account(
            RecordTypeId    = paRtId,
            FirstName       = 'NoExp',
            LastName        = 'Test',
            BillingCity     = 'Mumbai',
            AUM__c          = 1000000,
            External_Id__c  = 'TEST_PA_ZERO'
        );
        insert new List<Account>{ hero, zero };

        // Use a real Banking-sector ticker (HDFCBANK) so the sector lookup
        // path resolves it via the hardcoded SECTOR_TICKERS map.
        FinancialSecurity bankSec = new FinancialSecurity(
            Name   = 'HDFCBANK Test',
            Symbol = 'HDFCBANK'
        );
        FinancialSecurity itSec = new FinancialSecurity(
            Name   = 'TCS Test',
            Symbol = 'TCS'
        );
        insert new List<FinancialSecurity>{ bankSec, itSec };

        // Hero: 25% Banking exposure (250k of 1M AUM).
        // Zero: 25% IT exposure — used to confirm sector filtering excludes it from Banking queries.
        insert new List<SecuritiesHolding>{
            new SecuritiesHolding(
                Name                = 'HERO-HDFCBANK',
                PrimaryOwnerId      = hero.Id,
                FinancialSecurityId = bankSec.Id,
                MarketValue         = 250000,
                Shares              = 100
            ),
            new SecuritiesHolding(
                Name                = 'ZERO-TCS',
                PrimaryOwnerId      = zero.Id,
                FinancialSecurityId = itSec.Id,
                MarketValue         = 250000,
                Shares              = 100
            )
        };
    }

    @isTest
    static void filtersBySymbolAtThreshold() {
        Id heroId = [SELECT Id FROM Account WHERE External_Id__c = 'TEST_PA_HERO' LIMIT 1].Id;

        QueryClientExposureGraph.Request r = new QueryClientExposureGraph.Request();
        r.sector = 'Banking';
        r.symbol = 'HDFCBANK';
        r.minExposurePct = 20;

        Test.startTest();
        List<QueryClientExposureGraph.Response> out =
            QueryClientExposureGraph.query(new List<QueryClientExposureGraph.Request>{ r });
        Test.stopTest();

        System.assertEquals(1, out[0].accountIds.size(), 'Only hero account meets threshold');
        System.assertEquals(heroId, out[0].accountIds[0]);
        System.assert(out[0].exposurePcts[0] >= 20, 'Pct meets threshold');
    }

    @isTest
    static void excludesAccountsBelowThreshold() {
        QueryClientExposureGraph.Request r = new QueryClientExposureGraph.Request();
        r.sector = 'Banking';
        r.symbol = 'HDFCBANK';
        r.minExposurePct = 30;  // hero is 25%, should be excluded

        Test.startTest();
        List<QueryClientExposureGraph.Response> out =
            QueryClientExposureGraph.query(new List<QueryClientExposureGraph.Request>{ r });
        Test.stopTest();

        System.assertEquals(0, out[0].accountIds.size(), 'No account meets 30% threshold');
    }

    @isTest
    static void sectorLookupResolvesBankingTickers() {
        Id heroId = [SELECT Id FROM Account WHERE External_Id__c = 'TEST_PA_HERO' LIMIT 1].Id;

        QueryClientExposureGraph.Request r = new QueryClientExposureGraph.Request();
        r.sector = 'Banking';
        r.minExposurePct = 20;
        // No symbol set — exercises the sector→tickers map path.

        Test.startTest();
        List<QueryClientExposureGraph.Response> out =
            QueryClientExposureGraph.query(new List<QueryClientExposureGraph.Request>{ r });
        Test.stopTest();

        System.assertEquals(1, out[0].accountIds.size(), 'Banking sector lookup finds hero (HDFCBANK)');
        System.assertEquals(heroId, out[0].accountIds[0]);
    }

    @isTest
    static void unknownSectorReturnsEmpty() {
        QueryClientExposureGraph.Request r = new QueryClientExposureGraph.Request();
        r.sector = 'UnknownSector';
        r.minExposurePct = 20;

        Test.startTest();
        List<QueryClientExposureGraph.Response> out =
            QueryClientExposureGraph.query(new List<QueryClientExposureGraph.Request>{ r });
        Test.stopTest();

        System.assertEquals(0, out[0].accountIds.size(), 'Unmapped sector returns no results');
    }
}
