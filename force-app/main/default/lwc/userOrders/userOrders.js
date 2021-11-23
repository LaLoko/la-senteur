import { LightningElement, track } from 'lwc';
import getAllOrders from '@salesforce/apex/ProfileController.getAllOrders';
import getOrderDetails from '@salesforce/apex/ProfileController.getOrderDetails';
import getOrderedPerfumes from '@salesforce/apex/ProfileController.getOrderedPerfumes';
import getShippmentInfo from '@salesforce/apex/ProfileController.getShippmentInfo';

export default class UserOrders extends LightningElement {
    @track orders;
    @track detailedOrder;
    orderItems;
    @track address;

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
    goToOrder(event){
        let index = event.target.dataset.index;
        this.dispatchEvent(new CustomEvent('select',{detail:this.orders[index]}));
    }
    hideAndShow( event ) {

        let indx = event.target.dataset.recordId;
        console.log( 'Index is ' + indx );

        if ( this.orders ) {

            let recs =  JSON.parse( JSON.stringify( this.orders ) );
            let currVal = recs[ indx ].hideBool;
            if(currVal){
                this.getDetails(this.orders[indx].objOrder);
                this.getOrderItems(this.orders[indx].objOrder);
                this.getShippmentAddress(this.orders[indx].objOrder);
            }
            console.log( 'Current Val ' + currVal );
            recs[ indx ].hideBool = !currVal;
            this.orders = recs;
            console.log( 'After Change ' + this.orders[ indx ].hideBool );

        }

    }

    getDetails(order){
        console.log(JSON.stringify(order));
        getOrderDetails({orderId:order.Id})
        .then(result => {
            this.detailedOrder = result;
            console.log(JSON.stringify(result));

        })
        .catch(error => {
            this.error = error;
        });  
    }

    getOrderItems(order){
        getOrderedPerfumes({orderId:order.Id})
        .then(result => {
            this.orderItems = result;
            console.log(JSON.stringify(result));
        })
        .catch(error => {
            this.error = error;
        });  
    }
    getShippmentAddress(order){
        getShippmentInfo({orderId:order.Id})
        .then(result => {
            this.address = result;
            console.log(JSON.stringify(result));
        })
        .catch(error => {
            this.error = error;
        });  
    }
}