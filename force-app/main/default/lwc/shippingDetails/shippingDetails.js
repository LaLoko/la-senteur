import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addShippmentInfo from '@salesforce/apex/PerfumesController.addShippmentInfo';
import getAddress from '@salesforce/apex/PerfumesController.getAddress';s
export default class ShippingDetails extends LightningElement {
    street;
    city;
    zip;
    country;
    state;
    @track address;

    connectedCallback(){
        this.getSavedAddress();
    }

    getSavedAddress(){
        getAddress()
        .then(result => {
            this.address = result;
        })
        .catch(error => {
            this.error = error;
        }); 
    }

    streetChange(event) {
        this.address.street= event.target.value;
    }

    cityChange(event) {
        this.address.city= event.target.value;
    }

    zipChange(event) {
        this.address.zip= event.target.value;
    }

    countryChange(event) {
        this.address.country= event.target.value;
    }
    
    stateChange(event) {
        this.address.state= event.target.value;
    }

    goToSummary(){
        if((this.address.street === undefined || this.address.street == '')||
        (this.address.city === undefined || this.address.city == '')||
        (this.address.zip === undefined || this.address.zip == '')||
        (this.address.country === undefined || this.address.country == '')||
        (this.address.state === undefined || this.address.state == '')){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'One or more fields are empty',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{
            addShippmentInfo({street:this.address.street,country:this.address.country,zip:this.address.zip,state:this.address.state,city:this.address.city})
            .then(result => {
                this.dispatchEvent(new CustomEvent('next',{step:'3'}));
            })
            .catch(error => {
                this.error = error;
            });      
        }
    }
}