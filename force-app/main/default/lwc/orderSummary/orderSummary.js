import { LightningElement,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCart from '@salesforce/apex/PerfumesController.getCart';
import getCartTotalPrice from '@salesforce/apex/PerfumesController.getCartTotalPrice';
import getShippingInfo from '@salesforce/apex/PerfumesController.getShippingInfo';
import getCartItemId from '@salesforce/apex/PerfumesController.getCartItemId';
import createOrder from '@salesforce/apex/PerfumesController.createOrder';
export default class OrderSummary extends NavigationMixin(
    LightningElement
) {
    @track cart;
    @track total;
    @track shippingInfo;
    cartExist = false;
    @track isDialogVisible = false;

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

    confirmDialog(){
        this.isDialogVisible = true;
    }

    order(){
        createOrder()
        .then(result => {
            if(result == true){
                this.dispatchEvent(new CustomEvent('next'));
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Cannot place an order',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Cannot place an order',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.error = error;
        });
    }

    openDialog(event){
        if(event.target.name === 'openConfirmation'){
            this.originalMessage = 'test message';
            this.isDialogVisible = true;
        }else if(event.target.name === 'confirmModal'){

            if(event.detail !== 1){
                this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';

                if(event.detail.status === 'confirm') {
                    this.order();
                    event.detail = 1;
                }else if(event.detail.status === 'cancel'){
                    event.detail = 1;
                }
            }
            this.isDialogVisible = false;
        }
    }
}