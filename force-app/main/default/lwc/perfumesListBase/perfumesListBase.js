import { LightningElement, track } from 'lwc';
import getBestsellers from '@salesforce/apex/PerfumesController.getBestsellers';
import getAdv from '@salesforce/apex/PerfumesController.getAdv';
import { NavigationMixin } from 'lightning/navigation';
export default class PerfumesListBase extends NavigationMixin(
    LightningElement
) {
    @track bestsellers = [];
    @track adv;
    @track showModal = false;

    connectedCallback(){
        this.getModal();

        this.getRecords();
    }  

    getRecords(){
            getBestsellers()
                .then(result => {
                    this.bestsellers = result;
                })
                .catch(error => {
                    this.error = error;
                });      
    }

    getModal(){
        getAdv()
                .then(result => {
                    console.log(JSON.stringify(result))
                    this.adv = result;
                    this.showModal = true;
                })
                .catch(error => {
                    this.error = error;
                });      
    }

    closeModal(){
        this.showModal = false;
    }

    goToSale(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'male-perfumes'
            }
        });
    }
}