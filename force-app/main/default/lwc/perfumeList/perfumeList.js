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

            this.getRecords(type,null);
    }  
    getRecords(type,sort){

            getAllPerfumes({type: type,sortType:sort})
                .then(result => {
                    console.log(JSON.stringify(result));
                    this.perfumesList = result;
                    
                })
                .catch(error => {
                    this.error = error;
                });      
    }
    handleSortSelected(event){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1]
        this.getRecords(type,event.detail);
    }
}