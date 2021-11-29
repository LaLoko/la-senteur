import { LightningElement, api,track } from 'lwc';
import getAllPerfumes from '@salesforce/apex/PerfumesController.getAllPerfumes';
import getPerfumesByKey from '@salesforce/apex/PerfumesController.getPerfumesByKey';
export default class PerfumeList extends LightningElement {
    @track perfumesList = [];
    @track dataLoaded = false;
    @track loaded = false;

    @track perfumesToShow = [];
    @api searchKey;
    recordsFound;
    searchSucces = false;

    @track allDesigners = []
    @track allAccords = [];
    @track allNotes = [];

    @track isLoading = true;
    
    connectedCallback(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1];

        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.searchKey = paramsFromURL.get('key');

        this.getRecords(type,null,this.searchKey,null,null,null,null,null);
    }  

    getRecords(type,sort,searchKey,designers,accords,topNotes,middleNotes,baseNotes){
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
            getAllPerfumes({type: type,sortType:sort,designersFilter:designers,accords:accords,topNotes,topNotes,middleNotes:middleNotes,baseNotes,baseNotes})
                .then(result => {
                    this.perfumesList = result;
                    this.dataLoaded = true;
                    this.recordsFound = this.perfumesList.length>0;
                })
                .catch(error => {
                    this.error = error;
                });      
            }
            this.isLoading = false;
    }

    handleSortSelected(event){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1]
        this.getRecords(type,event.detail,null,null,null,null,null);
    }

    paginationHandler(event){
        this.perfumesToShow = [...event.detail.records]
    }

    handleFilters(event){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1]

        this.getRecords(type,null,null,
            event.detail.designers,event.detail.accords,event.detail.topNotes,event.detail.middleNotes,event.detail.baseNotes);
    }

    clearFilters(){
        let link = String(window.location.href).split('/');
        let type = link[link.length-1]
        this.getRecords(type);
    }

    handleLoad(event){
        this.loaded = true;
    }
    
    get everythingLoaded(){
        return this.loaded && this.dataLoaded;
    }
}