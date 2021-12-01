import { LightningElement,api,track } from 'lwc';
import createNewCase from '@salesforce/apex/CaseController.createNewCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class NewComplaint extends NavigationMixin(
    LightningElement
) {
    @api visible; 
    @api title; 
    @api name; 
    @api message; 
    @api confirmLabel; 
    @api cancelLabel; 
    @api originalMessage; 
    @api order
    @api items
    subject;
    description;
    @track caseId;

    @api
    makeVisible(){
        this.visible = true;
    }
    close(){
        this.visible = false;
    }
    saveCase(){
        this.createCase();
        this.visible = false;
    }
    changeSelectedItem(event){
        let indx = event.target.dataset.recordId;

        if ( this.items ) {
            let recs =  JSON.parse( JSON.stringify( this.items ) );
            let currVal = recs[ indx ].hideBool;
            recs[ indx ].hideBool = !currVal;
            this.items = recs;
        }
    }
    subjectChange(event) {
        this.subject= event.target.value;
    }
    descriptionChange(event) {
        this.description= event.target.value;
    }

    createCase(){
        let caseItems = [];
        this.items.forEach(element => {
            if(element.hideBool == true){
                caseItems.push(element);
            }
        });
        if(caseItems.length == 0){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'No case items selected',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }
        if(this.subject === undefined || this.subject == ''){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'No case subject',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }
        if(this.description === undefined || this.description == ''){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'No case description',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }

        createNewCase({items:JSON.stringify(caseItems),subject:this.subject,description:this.description,orderId:this.order.Id})
        .then(result => {
            console.log(JSON.stringify(result))
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        pageName: 'profile'
                    },
                    state: {
                        'caseId': result
                    }
                });
    
        })
        .catch(error => {
            this.error = error;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Cannot create case',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });   
    }
}