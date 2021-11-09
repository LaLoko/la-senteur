import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAllPerfumes from '@salesforce/apex/PerfumesController.getAllPerfumes';

export default class PerfumeList extends LightningElement {
    @track perfumesList = [];
    
    connectedCallback(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1]
        console.log(type)
        console.log(JSON.stringify(link))

            this.getRecords(type);
    }  
    getRecords(type){

            getAllPerfumes({type: type})
                .then(result => {
                    console.log(JSON.stringify(result));
                    this.perfumesList = result;
                    
                })
                .catch(error => {
                    this.error = error;
                });      
    }  
}