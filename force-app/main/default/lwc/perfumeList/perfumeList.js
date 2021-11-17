import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAllPerfumes from '@salesforce/apex/PerfumesController.getAllPerfumes';
import getPerfumesByKey from '@salesforce/apex/PerfumesController.getPerfumesByKey';


export default class PerfumeList extends LightningElement {
    @track perfumesList = [];
    @track dataLoaded = false;

    @track perfumesToShow = [];
    @api searchKey;
    recordsFound;
    
    connectedCallback(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1];

        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.searchKey = paramsFromURL.get('key');

        this.getRecords(type,null,this.searchKey);
        
    }  
    getRecords(type,sort,searchKey){

        if(searchKey){
            getPerfumesByKey({key:searchKey})
                        .then(result=>{
                            this.perfumesList = result;
                            this.dataLoaded = true;
                            this.recordsFound = this.perfumesList.length>0;
                         })
                         .catch(error => {
                            this.error = error;
                        }); 
        }else{
            getAllPerfumes({type: type,sortType:sort})
                .then(result => {
                    this.perfumesList = result;
                    this.dataLoaded = true;
                    this.recordsFound = this.perfumesList.length>0;
                })
                .catch(error => {
                    this.error = error;
                });      
            }
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