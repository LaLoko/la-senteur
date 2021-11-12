import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAllPerfumes from '@salesforce/apex/PerfumesController.getAllPerfumes';

export default class PerfumeList extends LightningElement {
    @track perfumesList = [];
    @track dataLoaded = false;

    @track perfumesToShow = [];
    
    connectedCallback(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1];

        this.getRecords(type,null);
    }  
    getRecords(type,sort){

            getAllPerfumes({type: type,sortType:sort})
                .then(result => {
                    this.perfumesList = result;
                    this.dataLoaded = true;
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
    paginationHandler(event){
        console.log('event')
        console.log(event.detail.records)
        this.perfumesToShow = [...event.detail.records]
    }
}