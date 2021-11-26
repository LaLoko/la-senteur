import { LightningElement,track } from 'lwc';

export default class ProfilePage extends LightningElement {
    @track showDetails = false;
    order;
    orderId;

    handleOrderSelect(event){
        this.order = event.detail;
        this.showDetails = true;
    }
    handleDetailsClose(event){
        this.showDetails = false;
    }
    goToOrder(event){
        this.orderId = event.detail;
        this.template.querySelector('lightning-tabset').activeTabValue = 'Orders history';
    }
}