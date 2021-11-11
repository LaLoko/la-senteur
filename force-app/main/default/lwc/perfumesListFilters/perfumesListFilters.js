import { LightningElement } from 'lwc';

export default class PerfumesListFilters extends LightningElement {
    productType = '';

    get productTypes() {
        return [
            { label: 'Price Ascending', value: 'Prisce Ascending' },
            { label: 'Price Descending', value: 'Prisce Descending' },
            { label: 'Name Ascending', value: 'Name Ascending' },
        ];
    }

    handleChange(event) {
        this.productType = event.detail.value;
    }
}