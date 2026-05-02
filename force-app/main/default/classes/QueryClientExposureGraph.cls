/**
 * Invocable wrapper that returns Person Account Ids exposed to a sector or
 * symbol at >= minExposurePct of their AUM__c.
 *
 * Used by MarketImpact_Detect_Segment Flow on the platform-event path.
 *
 * Sector → tickers mapping is hardcoded here because FinancialSecurity.Sector
 * is not queryable in this org's FSC profile. Extend SECTOR_TICKERS as new
 * scenarios are added.
 */
public with sharing class QueryClientExposureGraph {

    private static final Map<String, Set<String>> SECTOR_TICKERS =
        new Map<String, Set<String>>{
            'Banking' => new Set<String>{
                'HDFCBANK', 'ICICIBANK', 'SBIN', 'AXISBANK', 'KOTAKBANK',
                'BAJFINANCE', 'BAJAJFINSV', 'BANKBEES'
            },
            'IT' => new Set<String>{
                'TCS', 'INFY', 'HCLTECH', 'WIPRO', 'TECHM'
            }
        };

    public class Request {
        @InvocableVariable(required=true)
        public String sector;

        @InvocableVariable
        public String symbol;

        @InvocableVariable(required=true)
        public Decimal minExposurePct;
    }

    public class Response {
        @InvocableVariable public List<Id> accountIds;
        @InvocableVariable public List<Decimal> exposurePcts;
        @InvocableVariable public List<Decimal> exposureAmounts;
    }

    @InvocableMethod(
        label='Query Client Exposure Graph'
        description='Returns Account ids whose sector/symbol exposure as % of AUM__c >= minExposurePct.'
    )
    public static List<Response> query(List<Request> reqs) {
        List<Response> out = new List<Response>();
        for (Request r : reqs) {
            out.add(runOne(r));
        }
        return out;
    }

    private static Response runOne(Request r) {
        Response resp = new Response();
        resp.accountIds      = new List<Id>();
        resp.exposurePcts    = new List<Decimal>();
        resp.exposureAmounts = new List<Decimal>();

        Set<String> targetSymbols = resolveTargetSymbols(r);
        if (targetSymbols.isEmpty()) {
            return resp;
        }

        Map<Id, Decimal> exposureByAcct = aggregateExposure(targetSymbols);
        if (exposureByAcct.isEmpty()) {
            return resp;
        }

        Map<Id, Decimal> aumByAcct = fetchAum(exposureByAcct.keySet());

        for (Id acctId : exposureByAcct.keySet()) {
            Decimal aum = aumByAcct.get(acctId);
            if (aum == null || aum == 0) continue;
            Decimal exp = exposureByAcct.get(acctId);
            Decimal pct = (exp / aum) * 100;
            if (pct >= r.minExposurePct) {
                resp.accountIds.add(acctId);
                resp.exposurePcts.add(pct.setScale(2));
                resp.exposureAmounts.add(exp);
            }
        }
        return resp;
    }

    private static Set<String> resolveTargetSymbols(Request r) {
        if (String.isNotBlank(r.symbol)) {
            return new Set<String>{ r.symbol };
        }
        Set<String> tickers = SECTOR_TICKERS.get(r.sector);
        return tickers != null ? tickers : new Set<String>();
    }

    private static Map<Id, Decimal> aggregateExposure(Set<String> symbols) {
        Map<Id, Decimal> exposure = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT PrimaryOwnerId acct, SUM(MarketValue) total
            FROM SecuritiesHolding
            WHERE FinancialSecurity.Symbol IN :symbols
            GROUP BY PrimaryOwnerId
        ]) {
            exposure.put((Id) ar.get('acct'), (Decimal) ar.get('total'));
        }
        return exposure;
    }

    private static Map<Id, Decimal> fetchAum(Set<Id> acctIds) {
        Map<Id, Decimal> aum = new Map<Id, Decimal>();
        for (Account a : [
            SELECT Id, AUM__c FROM Account WHERE Id IN :acctIds
        ]) {
            if (a.AUM__c != null) aum.put(a.Id, a.AUM__c);
        }
        return aum;
    }
}
