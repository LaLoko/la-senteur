import { LightningElement,api } from 'lwc';
import createNewCase from '@salesforce/apex/CaseController.createNewCase';
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

    // handleClick(event){
    //     let finalEvent = {
    //         originalMessage: this.originalMessage,
    //         status: event.target.name
    //     };
    //     if(event.target.name == 'confirm'){
    //         this.createCase();
    //         this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
    //     }
    //     if(event.target.name == 'cancel'){
    //         this.dispatchEvent(new CustomEvent('click', {detail: 2}));
    //     }

    // }
    @api
    makeVisible(){
        this.visible = true;
    }
    close(){
        this.visible = false;
        console.log('close')
        // dispatchEvent(new CustomEvent('click', {detail: 2}));
    }
    saveCase(){
        console.log('save')
        this.createCase();
        this.visible = false;
        // dispatchEvent(new CustomEvent('click', {detail: 2}));
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
        console.log('create case')

        createNewCase({items:JSON.stringify(caseItems),subject:this.subject,description:this.description,orderId:this.order.Id})
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