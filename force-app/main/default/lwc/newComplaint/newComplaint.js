import { LightningElement,api } from 'lwc';
import createNewCase from '@salesforce/apex/ProfileController.createNewCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewComplaint extends LightningElement {
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

    handleClick(event){
        let finalEvent = {
            originalMessage: this.originalMessage,
            status: event.target.name
        };
        if(event.target.name == 'confirm'){
            this.createCase();
        }

        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
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
            if(element.hideBool === undefined || element.hideBool == true){
                caseItems.push(element);
            }
        });
        createNewCase({items:JSON.stringify(caseItems),subject:this.subject,description:this.description})
        .then(result => {
            if(result == true){
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Case created succesfully',
                    variant: 'succes',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Cannot create case',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
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