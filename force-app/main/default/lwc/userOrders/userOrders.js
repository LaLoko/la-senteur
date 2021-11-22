import { LightningElement, track } from 'lwc';
import getAllOrders from '@salesforce/apex/ProfileController.getAllOrders';

export default class UserOrders extends LightningElement {
    @track orders;

    connectedCallback(){
        this.getOrders();
    }

    getOrders(){
        getAllOrders()
        .then(result => {
            this.orders = result;
            console.log(JSON.stringify(result));
        })
        .catch(error => {
            this.error = error;
        });   
    }
}