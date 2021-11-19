import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getCart from '@salesforce/apex/PerfumesController.getCart';
import getCartTotalPrice from '@salesforce/apex/PerfumesController.getCartTotalPrice';
import deleteFromCart from '@salesforce/apex/PerfumesController.deleteFromCart';
import getCartItemId from '@salesforce/apex/PerfumesController.getCartItemId';
export default class CartItems extends NavigationMixin(
    LightningElement
) {
    @track cart;
    @track total;
    cartExist = false;
    @track isLoading = true;

    connectedCallback(){
        this.loadCart();
        this.getTotalPrice();
    }

    loadCart(){
        getCart()
        .then(result => {
            this.cart = result;
            if(result != null){
            this.cartExist = result.length > 0;
            }
            this.isLoading = false;
            console.log(JSON.stringify(result))
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
    deleteItemFormCart(event){
        let index = event.target.dataset.index;
        console.log(index);

        deleteFromCart({id:index})
        .then(result => {
            this.loadCart();
            this.getTotalPrice();
        })
        .catch(error => {
            this.error = error;
        });   
    }
    goToShippment(){
        this.dispatchEvent(new CustomEvent('next',{step:'2'}));
    }
    goToPerfume(event){
        let index = event.target.dataset.index;
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
}