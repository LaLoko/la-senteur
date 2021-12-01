import { LightningElement, api, track } from 'lwc';

export default class PerfumeListPagination extends LightningElement {
    page = 1; 
    allPerfumes; 
    toShow = [];
    @api searchsucces;

    @api
    set records(data){
        if(data){
            this.allPerfumes = data;
            this.toShow = data.slice(0,this.pageSize);
            this.totalPage = Math.ceil(data.length/this.pageSize);
            this.updateRecords();
        }
    }
    get records(){
        return this.toShow;
    }

    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 12; 
    @track totalRecountCount = 0;
    @track totalPage;

    value = '';

    get options() {
        return [
            { label: 'Price Ascending', value: 'Price ASC' },
            { label: 'Price Descending', value: 'Price DESC' },
            { label: 'Name Ascending', value: 'Name ASC' },
            { label: 'Name Descending', value: 'Name DESC' },
            { label: 'Score Ascending', value: 'Score ASC' },
            { label: 'Score Descending', value: 'Score DESC' },
            { label: 'Most popular', value: 'popular DESC' },
            { label: 'The least popular', value: 'popular ASC' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('sort',{detail:this.value}));
    }

    get disablePrev(){
       return this.page <= 1;
    }

    get disableNext(){
        return this.page >= this.totalPage;
    }

    toFirst(){
        if (this.page > 1) {
            this.page = 1;
            this.updateRecords();            
        }
    }
    toPrev(){
        if (this.page > 1) {
            this.page = this.page - 1;
            this.updateRecords();            
        }
    }
    toNext(){
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1;
            this.updateRecords();            
        }  
    }
    toLast(){
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.totalPage;
            this.updateRecords();            
        }  
    }
    updateRecords(){
        const start = (this.page-1)*this.pageSize;
        const end = this.pageSize*this.page;
        this.toShow = this.allPerfumes.slice(start,end);

        this.dispatchEvent(new CustomEvent('update',{
            detail:{
                records:this.toShow
            }
        }))
    }  
}