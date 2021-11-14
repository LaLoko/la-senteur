import { LightningElement,api,track } from 'lwc';
import getDetailPerfume from '@salesforce/apex/PerfumesController.getDetailPerfume';
import addReview from '@salesforce/apex/PerfumesController.addReview';
import getReviews from '@salesforce/apex/PerfumesController.getReviews';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PerfumePage extends LightningElement {
    id;
    @api perfume;
    @track reviews = [];
    reviesExists;
    topNotes = []
    middleNotes =[]
    baseNotes = []
    mainAccords;
    option = "";
    @track score = '1';
    @track reviewText = "";

    connectedCallback(){
        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.id = paramsFromURL.get('id');
        this.getDetails(this.id);
    }

    getDetails(id){

        getDetailPerfume({id:id})
            .then(result => {
                this.perfume = result;
                this.setNotes(this.perfume);
                this.getAllReviews();
            })
            .catch(error => {
                this.error = error;
            });      
}
    setNotes(perfume){
        this.topNotes = perfume.topNotes.split(';')
        this.middleNotes = perfume.middleNotes.split(';')
        this.baseNotes = perfume.baseNotes.split(';')
        this.mainAccords = perfume.mainAccords.split(';')
    }
    getAllReviews(){
        console.log('wchodzi')
        getReviews({id:this.id})
            .then(result => {
                this.reviews = result;
                this.reviesExists = result.length > 0;
                console.log(JSON.stringify(result))
            })
            .catch(error => {
                this.error = error;
            });   
    }

    get options() {
        var returnOptions = [];
            this.perfume.variants.forEach(ele =>{
                returnOptions.push({label:ele , value:ele});
            }); 
        
        return returnOptions;
    }

    get scoreOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
        ];
    }

    scoreChange(event) {
        this.score= event.target.value;
    }

    reviewChange(event) {
        this.reviewText= event.target.value;
    }

    addReview(){
        console.log(this.reviewText)
        console.log(this.score)
        if(this.reviewText != ""){
            addReview({text:this.reviewText,score:this.score,perfume:this.id})
            .then(result => {
                if(result == true){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Review added succesfully',
                        variant: 'succes',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.getDetails(this.id);
                    this.getAllReviews();
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Cannot add review',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.error = error;
            }); 
        }else{
            const evt = new ShowToastEvent({
                title: 'Wrong Review',
                message: 'Review cannot be empty',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
}