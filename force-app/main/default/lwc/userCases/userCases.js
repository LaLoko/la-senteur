import { LightningElement,track } from 'lwc';
import getAllUserCases from '@salesforce/apex/CaseController.getAllUserCases';


export default class UserCases extends LightningElement {

    @track cases;
    @track detailedOrder;
    orderItems;
    @track address;
    @track isDialogVisible = false;
    @track isLoading = true;

    connectedCallback(){
        this.getAllCases();
    }

    getAllCases(){
        getAllUserCases()
        .then(result => {
            this.cases = result;
            this.isLoading = false;
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

        if ( this.cases ) {

            let recs =  JSON.parse( JSON.stringify( this.cases ) );
            let currVal = recs[ indx ].hideBool;
            recs[ indx ].hideBool = !currVal;
            this.cases = recs;
        }
    }

    // getDetails(order){
    //     getOrderDetails({orderId:order.Id})
    //     .then(result => {
    //         this.detailedOrder = result;

    //     })
    //     .catch(error => {
    //         this.error = error;
    //     });  
    // }

    // getOrderItems(order){
    //     getOrderedPerfumes({orderId:order.Id})
    //     .then(result => {
    //         this.orderItems = result;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //     });  
    // }
    // getShippmentAddress(order){
    //     getShippmentInfo({orderId:order.Id})
    //     .then(result => {
    //         this.address = result;
    //     })
    //     .catch(error => {
    //         this.error = error;
    //     });  
    // }
}