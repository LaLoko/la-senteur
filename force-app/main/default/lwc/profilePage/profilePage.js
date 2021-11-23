import { LightningElement,track } from 'lwc';

export default class ProfilePage extends LightningElement {
    @track showDetails = false;
    order;

    handleOrderSelect(event){
        this.order = event.detail;
        this.showDetails = true;
    }
    handleDetailsClose(event){
        this.showDetails = false;
    }
}