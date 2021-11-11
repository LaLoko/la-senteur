import { LightningElement } from 'lwc';

export default class PerfumeListPagination extends LightningElement {
    value = '';

    get options() {
        return [
            { label: 'Price Ascending', value: 'Price__c ASC' },
            { label: 'Price Descending', value: 'Price__c DESC' },
            { label: 'Name Ascending', value: 'Name__c ASC' },
            { label: 'Name Descending', value: 'Name__c DESC' },
            { label: 'Score', value: 'Score__c' },
            { label: 'Most popular', value: 'Most popular' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('sort',{detail:this.value}));
    }
}