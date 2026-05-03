import { LightningElement, wire, track } from 'lwc';
import getDashboardData from '@salesforce/apex/MarketCommandCenterController.getDashboardData';

const COLUMNS = [
    {
        label: 'Client', fieldName: 'accountUrl', type: 'url',
        typeAttributes: { label: { fieldName: 'clientName' }, target: '_self' },
        sortable: true
    },
    { label: 'City', fieldName: 'city', type: 'text' },
    { label: 'AUM', fieldName: 'aumFormatted', type: 'text', sortable: true },
    {
        label: 'Exposure %', fieldName: 'exposurePct', type: 'number',
        typeAttributes: { minimumFractionDigits: 1, maximumFractionDigits: 1 },
        cellAttributes: { alignment: 'left' },
        sortable: true
    },
    { label: 'At Risk (₹)', fieldName: 'exposureFormatted', type: 'text', sortable: true },
    { label: 'Severity', fieldName: 'severity', type: 'text' },
    { label: 'Channel', fieldName: 'preferredChannel', type: 'text' }
];

export default class MarketCommandCenter extends LightningElement {
    @track _isMobile = window.matchMedia('(max-width: 480px)').matches;
    _mql;
    _mqHandler;

    connectedCallback() {
        this._mql = window.matchMedia('(max-width: 480px)');
        this._mqHandler = (e) => { this._isMobile = e.matches; };
        this._mql.addEventListener('change', this._mqHandler);
    }

    disconnectedCallback() {
        if (this._mql) this._mql.removeEventListener('change', this._mqHandler);
    }

    get isMobile()  { return this._isMobile; }
    get isDesktop() { return !this._isMobile; }
    get columns()   { return COLUMNS; }

    @wire(getDashboardData)
    wiredResult;

    get data() {
        return (this.wiredResult && this.wiredResult.data) ? this.wiredResult.data : null;
    }

    get totalClients()    { return this.data ? this.data.totalClients    : '—'; }
    get impactedClients() { return this.data ? this.data.impactedClients : '—'; }
    get myClients()       { return this.data ? this.data.myClients       : '—'; }

    get hasEvent() {
        return this.data && this.data.eventHeadline;
    }

    get hasClients() {
        return this.data && this.data.myImpactedClients && this.data.myImpactedClients.length > 0;
    }

    get eventBannerClass() {
        const sev = (this.data && this.data.eventSeverity) || '';
        if (sev === 'High')   return 'event-banner event-banner--high';
        if (sev === 'Medium') return 'event-banner event-banner--medium';
        return 'event-banner event-banner--low';
    }

    get tableData() {
        if (!this.hasClients) return [];
        return this.data.myImpactedClients.map(row => {
            const sev = (row.severity || '').toLowerCase();
            const sevKey = sev === 'high' ? 'high' : sev === 'medium' ? 'medium' : 'low';
            return {
                ...row,
                accountUrl:           '/' + row.accountId,
                aumFormatted:         row.aum != null
                    ? '₹' + (row.aum / 100000).toFixed(1) + 'L' : '—',
                exposureFormatted:    row.exposureAmount != null
                    ? '₹' + (row.exposureAmount / 100000).toFixed(1) + 'L' : '—',
                exposurePctFormatted: row.exposurePct != null
                    ? row.exposurePct.toFixed(1) + '%' : '—',
                severityBadgeClass:   'sev-badge sev-badge--' + sevKey,
                cardClass:            'client-card client-card--' + sevKey,
                channelIcon:          row.preferredChannel === 'WhatsApp' ? 'utility:chat'
                                    : row.preferredChannel === 'Email'    ? 'utility:email'
                                    :                                       'utility:call'
            };
        });
    }
}
