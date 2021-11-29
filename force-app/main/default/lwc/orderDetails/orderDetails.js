import { LightningElement,api,track } from 'lwc';
import getOrderDetails from '@salesforce/apex/ProfileController.getOrderDetails';
import getOrderedPerfumes from '@salesforce/apex/ProfileController.getOrderedPerfumes';
import getShippmentInfo from '@salesforce/apex/ProfileController.getShippmentInfo';
export default class OrderDetails extends LightningElement {
    @api order;
    @track detailedOrder;
    orderItems;
    @track isLoading = true;
    @track address;

    connectedCallback(){
        this.getDetails();
        this.getOrderItems();
        this.getShippmentAddress();
    }

    getDetails(){
        getOrderDetails({orderId:this.order.Id})
        .then(result => {
            this.detailedOrder = result;
        })
        .catch(error => {
            this.error = error;
        });  
    }

    getOrderItems(){
        getOrderedPerfumes({orderId:this.order.Id})
        .then(result => {
            this.orderItems = result;
        })
        .catch(error => {
            this.error = error;
        });  
    }
    getShippmentAddress(){
        getShippmentInfo({orderId:this.order.Id})
        .then(result => {
            this.address = result;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
        });  
    }
    closeDetails(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}