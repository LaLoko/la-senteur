import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addShippmentInfo from '@salesforce/apex/PerfumesController.addShippmentInfo';


export default class ShippingDetails extends LightningElement {
    street;
    city;
    zip;
    country;
    state;

    streetChange(event) {
        this.street= event.target.value;
    }
    cityChange(event) {
        this.city= event.target.value;
    }
    zipChange(event) {
        this.zip= event.target.value;
    }
    countryChange(event) {
        this.country= event.target.value;
    }
    stateChange(event) {
        this.state= event.target.value;
    }
    goToSummary(){
        if((this.street === undefined || this.street == '')||
        (this.city === undefined || this.city == '')||(this.zip === undefined || this.zip == '')||
        (this.country === undefined || this.country == '')||
        (this.state === undefined || this.state == '')){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'One or more fields are empty',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{
            addShippmentInfo({street:this.street,country:this.country,zip:this.zip,state:this.state,city:this.city})
            .then(result => {
                this.dispatchEvent(new CustomEvent('next',{step:'3'}));
            })
            .catch(error => {
                this.error = error;
            });      
        }
    }
}