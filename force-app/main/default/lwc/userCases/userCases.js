import { api, LightningElement,track } from 'lwc';
import getAllUserCases from '@salesforce/apex/CaseController.getAllUserCases';
import { NavigationMixin } from 'lightning/navigation';
export default class UserCases extends NavigationMixin(
    LightningElement
) {
    @track cases;
    @track address;
    @track isDialogVisible = false;
    @track isLoading = true;
    @api caseid;
    responsesExist = false;

    connectedCallback(){
        this.getAllCases();
    }

    getAllCases(){
        getAllUserCases()
        .then(result => {
            this.cases = result;
            this.isLoading = false;
            if(this.caseid){
                console.log(this.caseid)
                let index;
                console.log(JSON.stringify(this.cases[0]))
                for(let i=0;i<this.cases.length;i++){
                    if(this.cases[i].objCase.Id == this.caseid){
                        index = i;
                    }
                }
               this.hs(index);
            }
        })
        .catch(error => {
            this.error = error;
        });   
    }

    hs(indx){
        if(indx === undefined){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Case cannot be found',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        if ( this.cases ) {

            let recs =  JSON.parse( JSON.stringify( this.cases ) );
            let currVal = recs[ indx ].hideBool;
            recs[ indx ].hideBool = !currVal;
            this.cases = recs;
            if(this.responsesExist === undefined){
                this.responsesExist = this.cases[indx].caseFeed.length > 0;
            }else{
                this.responsesExist = undefined;
            }
        }
    }

    hideAndShow( event ) {
        let indx = event.target.dataset.recordId;

        if ( this.cases ) {

            let recs =  JSON.parse( JSON.stringify( this.cases ) );
            let currVal = recs[ indx ].hideBool;
            recs[ indx ].hideBool = !currVal;
            this.cases = recs;
            if(this.responsesExist === undefined){
                this.responsesExist = this.cases[indx].caseFeed.length > 0;
            }else{
                this.responsesExist = undefined;
            }
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