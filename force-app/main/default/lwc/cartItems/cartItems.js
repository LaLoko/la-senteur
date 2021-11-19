import { LightningElement, track } from 'lwc';
import getCart from '@salesforce/apex/PerfumesController.getCart';
import getCartTotalPrice from '@salesforce/apex/PerfumesController.getCartTotalPrice';
import deleteFromCart from '@salesforce/apex/PerfumesController.deleteFromCart';

export default class CartItems extends LightningElement {
    @track cart;
    @track total;
    cartExist = false;

    connectedCallback(){
        this.loadCart();
        this.getTotalPrice();
    }

    loadCart(){
        getCart()
        .then(result => {
            this.cart = result;
            this.cartExist = result.length > 0;

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
}