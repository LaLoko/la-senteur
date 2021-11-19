import { LightningElement, api, wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAllPerfumes from '@salesforce/apex/PerfumesController.getAllPerfumes';
import getPerfumesByKey from '@salesforce/apex/PerfumesController.getPerfumesByKey';

import getAllAccords from '@salesforce/apex/PerfumesController.getAllAccords';
import getAllDesigners from '@salesforce/apex/PerfumesController.getAllDesigners';
import getAllNotes from '@salesforce/apex/PerfumesController.getAllNotes';
export default class PerfumeList extends LightningElement {
    @track perfumesList = [];
    @track dataLoaded = false;

    @track perfumesToShow = [];
    @api searchKey;
    recordsFound;
    searchSucces = false;

    @track allDesigners = []
    @track allAccords = [];
    @track allNotes = [];
    
    connectedCallback(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1];

        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.searchKey = paramsFromURL.get('key');

        this.getRecords(type,null,this.searchKey);
        this.setFilters();
    }  
    getRecords(type,sort,searchKey){

        if(searchKey){
            getPerfumesByKey({key:searchKey})
                        .then(result=>{
                            this.perfumesList = result;
                            this.dataLoaded = true;
                            this.recordsFound = this.perfumesList.length>0;
                            if(this.recordsFound === true){
                                this.searchSucces = true;
                            }
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
        this.perfumesToShow = [...event.detail.records]
    }
    setFilters(){
        this.getDesigners();
        this.getAccords();
        this.getNotes();
    }
    getDesigners(){
        getAllDesigners()
        .then(result => {
            var returnOptions = [];
            result.forEach(ele =>{
                returnOptions.push({key:index , value:ele});
                index++;
            }); 
            this.allDesigners = returnOptions;

            console.log(JSON.stringify(returnOptions))
        })
        .catch(error => {
            this.error = error;
        });   
      }
      
      getAccords(){
        getAllAccords()
          .then(result => {
            this.allAccords = result;

            })
                  .catch(error => {
                      this.error = error;
                  });    
      }
      
      getNotes(){
        getAllNotes()
          .then(result => {
            this.allNotes = result;
            })
                  .catch(error => {
                      this.error = error;
                  });    
      }
}