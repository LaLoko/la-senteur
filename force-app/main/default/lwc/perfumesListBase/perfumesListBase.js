import { LightningElement, track } from 'lwc';
import getBestsellers from '@salesforce/apex/PerfumesController.getBestsellers';

export default class PerfumesListBase extends LightningElement {
    @track bestsellers = [];
    connectedCallback(){
        this.getRecords();
    }  
    getRecords(){
            getBestsellers()
                .then(result => {
                    console.log(JSON.stringify(result));
                    this.bestsellers = result;
                })
                .catch(error => {
                    this.error = error;
                });      
    }  
}