import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Cart extends NavigationMixin(
    LightningElement
) {
    @track cartExist;
    @track step;

    oneCompleted;
    twoCompleted;
    threeCompleted;

    stepOne = true;
    stepTwo;
    stepThree;

    finalized = false;

    connectedCallback(){
        this.step = '1';
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
    }

    get currentStep(){
        return this.step;
    }
    goToHome(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}