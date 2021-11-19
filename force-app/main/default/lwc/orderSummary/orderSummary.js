import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getCart from '@salesforce/apex/PerfumesController.getCart';
import getCartTotalPrice from '@salesforce/apex/PerfumesController.getCartTotalPrice';
import getShippingInfo from '@salesforce/apex/PerfumesController.getShippingInfo';
import getCartItemId from '@salesforce/apex/PerfumesController.getCartItemId';
export default class OrderSummary extends NavigationMixin(
    LightningElement
) {
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
    goToPerfume(event){
        let index = event.target.dataset.index;
        console.log(index);
            getCartItemId({index:index})
            .then(result => {
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'perfume-detail'
                    },
                    state: {
                        'id': result
                    }
                });
            })
            .catch(error => {
                this.error = error;
            });
    }

    order(){
        this.dispatchEvent(new CustomEvent('next'));
    }
}