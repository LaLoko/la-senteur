import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLastOrderId from '@salesforce/apex/PerfumesController.getLastOrderId';
export default class Cart extends NavigationMixin(
    LightningElement
) {
    @track cartExist;
    @track step;
    orderId;

    oneCompleted;
    twoCompleted;
    threeCompleted;

    stepOne = true;
    stepTwo;
    stepThree;
    
    finalized = false;

    connectedCallback(){
        this.step = '1';
        this.stepOne = true;
        this.stepTwo = false;
        this.stepThree = false; 
    }

    goToOne(){
        this.step = '1';
        this.stepOne = true;
        this.stepTwo = false;
        this.stepThree = false; 
    }

    handleSecondStep(event){
        this.oneCompleted = true;
        this.goToSecond();
    }

    goToSecond(){
        if(this.oneCompleted){
        this.step = '2';
        this.stepOne = false;
        this.stepTwo = true;
        this.stepThree = false; 
        }
    }

    handleThirdStep(event){
        this.twoCompleted = true;
        this.goToThird();
    }

    goToThird(){
        if(this.twoCompleted){
            this.step = '3';
            this.stepOne = false;
            this.stepTwo = false;
            this.stepThree = true;
            }
    }
    handleFinalization(){
        this.finalized = true;
        getLastOrderId()
        .then(result => {
            this.orderId = result;
        });
    }

    get currentStep(){
        return this.step;
    }
    goToOrder(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'profile'
            },
            state: {
                'orderId': this.orderId
            }
        });
    }
}