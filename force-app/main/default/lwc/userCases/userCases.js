import { LightningElement,track } from 'lwc';
import getAllUserCases from '@salesforce/apex/CaseController.getAllUserCases';
import { NavigationMixin } from 'lightning/navigation';
export default class UserCases extends NavigationMixin(
    LightningElement
) {
    @track cases;
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

    hideAndShow( event ) {

        let indx = event.target.dataset.recordId;

        if ( this.cases ) {

            let recs =  JSON.parse( JSON.stringify( this.cases ) );
            let currVal = recs[ indx ].hideBool;
            recs[ indx ].hideBool = !currVal;
            this.cases = recs;
        }
    }
    goToPerfume(event){
        let index = event.target.dataset.index;
        let indx = event.target.dataset.recordId;

                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'perfume-detail'
                    },
                    state: {
                        'id': this.cases[indx].orderItems[index].perfumeId
                    }
                });
    }

    goToOrder(event){
        var index = event.target.dataset.recordId;
        this.dispatchEvent(new CustomEvent('order',{detail:this.cases[index].objCase.Order__c}));

    }
}