import { LightningElement, track, api } from 'lwc';
import getAllOrders from '@salesforce/apex/ProfileController.getAllOrders';
import getOrderDetails from '@salesforce/apex/ProfileController.getOrderDetails';
import getOrderedPerfumes from '@salesforce/apex/ProfileController.getOrderedPerfumes';
import getShippmentInfo from '@salesforce/apex/ProfileController.getShippmentInfo';
import { NavigationMixin } from 'lightning/navigation';
export default class UserOrders extends NavigationMixin(
    LightningElement
) {
    @track orders;
    @track detailedOrder;
    orderItems;
    @track address;
    @track isDialogVisible = false;
    @api orderid;

    connectedCallback(){
        this.getOrders();
    }

    getOrders(){
        getAllOrders()
        .then(result => {
            this.orders = result;
            console.log(this.orderId);
            if(this.orderid){
                console.log('wbija')
                let index = 0;
                for(let i=0;i<this.orders.length;i++){
                    if(this.orders[i].objOrder.Id == this.orderId){
                        index = i;
                    }
                }
                console.log(index)
               this.hs(index);
            }
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
        this.hs(indx);
    }
    hs(indx){
        if ( this.orders ) {

            let recs =  JSON.parse( JSON.stringify( this.orders ) );
            let currVal = recs[ indx ].hideBool;
            if(currVal){
                this.getDetails(this.orders[indx].objOrder);
                this.getOrderItems(this.orders[indx].objOrder);
                this.getShippmentAddress(this.orders[indx].objOrder);
            }
            recs[ indx ].hideBool = !currVal;
            this.orders = recs;
        }
    }

    getDetails(order){
        getOrderDetails({orderId:order.Id})
        .then(result => {
            this.detailedOrder = result;

        })
        .catch(error => {
            this.error = error;
        });  
    }

    getOrderItems(order){
        getOrderedPerfumes({orderId:order.Id})
        .then(result => {
            this.orderItems = result;
        })
        .catch(error => {
            this.error = error;
        });  
    }
    getShippmentAddress(order){
        getShippmentInfo({orderId:order.Id})
        .then(result => {
            this.address = result;
        })
        .catch(error => {
            this.error = error;
        });  
    }
    openDialog(event){
        console.log(event);
  
        // this.isDialogVisible = false;

        // if(event.target.name === 'openConfirmation'){
        //     this.originalMessage = 'test message';
        //     this.isDialogVisible = true;
        // }else if(event.target.name === 'confirmModal'){

        //     if(event.detail !== 1 && event.detail !== 2){
        //         this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';

        //         if(event.detail.status === 'confirm') {
        //             this.order();
        //             event.detail = 1;
        //             this.isDialogVisible = true;

        //         }else if(event.detail.status === 'cancel'){
        //             console.log('x');
        //             event.detail = 1;
        //             this.isDialogVisible = false;
        //         }
        //     }else{
        //             event.detail = 1;
        //         this.isDialogVisible = false;
                
        //     }
        // }
    }
    openCase(){
        console.log('otwieramy modala')
        this.template.querySelector('c-new-complaint').makeVisible();
        
        this.isDialogVisible = true;

    }
    goToPerfume(event){
        let index = event.target.dataset.index;
        console.log(index);
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'perfume-detail'
                    },
                    state: {
                        'id': this.orderItems[index].perfumeId
                    }
                });
    }
}