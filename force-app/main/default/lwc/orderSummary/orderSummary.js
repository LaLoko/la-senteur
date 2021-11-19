import { LightningElement,track } from 'lwc';
import getCart from '@salesforce/apex/PerfumesController.getCart';
import getCartTotalPrice from '@salesforce/apex/PerfumesController.getCartTotalPrice';
import getShippingInfo from '@salesforce/apex/PerfumesController.getShippingInfo';

export default class OrderSummary extends LightningElement {
    @track cart;
    @track total;
    @track shippingInfo;
    cartExist = false;

    connectedCallback(){
        this.loadShippingInfo();
        this.loadCart();
        this.getTotalPrice();
    }

    loadCart(){
        getCart()
        .then(result => {
            this.cart = result;
            this.cartExist = result.length > 0;
        })
        .catch(error => {
            this.error = error;
        });   
    }

    getTotalPrice(){
        getCartTotalPrice()
        .then(result => {
            this.total = result +' €';
        })
        .catch(error => {
            this.error = error;
        });   
    }

    loadShippingInfo(){
        getShippingInfo()
        .then(result => {
            this.shippingInfo = result;
            console.log(JSON.stringify(this.shippingInfo))
        })
        .catch(error => {
            this.error = error;
        }); 
    }

    order(){
        this.dispatchEvent(new CustomEvent('next'));
    }
}