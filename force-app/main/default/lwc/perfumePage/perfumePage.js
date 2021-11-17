import { LightningElement,api,track } from 'lwc';
import getDetailPerfume from '@salesforce/apex/PerfumesController.getDetailPerfume';
import addReview from '@salesforce/apex/PerfumesController.addReview';
import getReviews from '@salesforce/apex/PerfumesController.getReviews';
import userCreatedComment from '@salesforce/apex/PerfumesController.userCreatedComment';
import removeComment from '@salesforce/apex/PerfumesController.removeComment';
import getReviewToEdit from '@salesforce/apex/PerfumesController.getReviewToEdit';
import updateReview from '@salesforce/apex/PerfumesController.updateReview';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class PerfumePage extends LightningElement {
    id;
    @track perfume;
    @track reviews = [];
    reviesExists;
    topNotes = []
    middleNotes =[]
    baseNotes = []
    mainAccords;
    option = "";
    @track score = '1';
    @track reviewText = "";
    @track comentCreated = false;
    editingComment = false;
    @api commentToEdit;
    @track editScore;

    currPhoto;
    photoIndex = 0;
    disableNextPhoto = false;
    disablePrevPhoto = true;

    @track isDialogVisible = false;
    @track originalMessage;
    @track displayMessage = 'Click on the \'Open Confirmation\' button to test the dialog.';

    connectedCallback(){
        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.id = paramsFromURL.get('id');
        this.getDetails();
    }

    getDetails(){
        getDetailPerfume({id:this.id})
            .then(result => {
                this.perfume = result;
                console.log(JSON.stringify(result))
                this.setNotes(this.perfume);
                this.getAllReviews();
                if(this.currPhoto === undefined){
                    this.currPhoto = this.perfume.images[this.photoIndex].URL__c;
                }
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
        getReviews({id:this.id})
            .then(result => {
                this.reviews = result;
                this.reviesExists = result.length > 0;
                if(result.length > 0){
                    this.isCommentCreated();
                }
            })
            .catch(error => {
                this.error = error;
            });   
    }
    isCommentCreated(){
        userCreatedComment({id:this.id})
            .then(result => {
                this.comentCreated = result;
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

    get perfumeScore(){
        return this.perfume.score;
    }
    get reviewsExist(){
        return this.reviesExists;
    }
    optionChange(event){
        this.option= event.target.value;
    }

    scoreChange(event) {
        this.score= event.target.value;
    }

    reviewChange(event) {
        this.reviewText= event.target.value;
    }

    addReview(){
        if(this.reviewText != ""){
            addReview({text:this.reviewText,score:this.score,perfume:this.id})
            .then(result => {
                if(result){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Review added succesfully',
                        variant: 'succes',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.getDetails();
                    this.getAllReviews();
                    console.log(JSON.stringify(this.perfume))

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

    removeComment(){
        removeComment({perfumeId:this.id})
            .then(result => {
                this.comentCreated = false;
                this.getDetails();
                console.log(JSON.stringify(this.perfume))
            })
            .catch(error => {
                this.error = error;
            });   
    }

    editScoreChange(event) {
        this.editScore= event.target.value;
    }

    editReviewChange(event) {
        this.commentToEdit.Review__c= event.target.value;
    }

    editComment(){
        getReviewToEdit({perfumeId:this.id})
        .then(result => {
            console.log(JSON.stringify(result))
            this.commentToEdit = result;
            this.editingComment = true;
            this.editScore = result.Score__c.toString();
        })
        .catch(error => {
            this.error = error;
        });   
    }

    cancelEdit(){
        this.editingComment = false;
    }
    
    editReview(event){
        console.log(this.commentToEdit.Review__c)
        updateReview({text:this.commentToEdit.Review__c,score:this.editScore,perfumeId:this.id})
        .then(result => {
            this.getAllReviews();
            this.getDetails();
            this.editingComment = false;
        })
        .catch(error => {
            this.error = error;
        }); 
    }

    openDialog(event){
        if(event.target.name === 'openConfirmation'){
            this.originalMessage = 'test message';
            this.isDialogVisible = true;
        }else if(event.target.name === 'confirmModal'){

            if(event.detail !== 1){
                this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';

                if(event.detail.status === 'confirm') {
                    this.removeComment();
                    event.detail = 1;
                }else if(event.detail.status === 'cancel'){
                    event.detail = 1;
                }
            }
            this.isDialogVisible = false;
        }
    }
    nextPhoto(){
        if(this.photoIndex + 1 <= this.perfume.images.length){
            this.photoIndex += 1;
            this.currPhoto = this.perfume.images[this.photoIndex].URL__c;
            if(this.photoIndex == this.perfume.images.length-1){
                this.disableNextPhoto = true;
            }
            this.disablePrevPhoto = false;
        }
    }

    prevPhoto(){
        if(this.photoIndex - 1 >= 0){
            this.photoIndex -= 1;
            this.currPhoto = this.perfume.images[this.photoIndex].URL__c;
            if(this.photoIndex == 0){
                this.disablePrevPhoto = true;
            }
            this.disableNextPhoto = false;
        }
    }

    addToCart(){
        let message = this.perfume.designerName +' ' + this.perfume.name + ' ' + this.option + ' added to cart';
        const evt = new ShowToastEvent({
            title: 'Product added to cart',
            message: message,
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}