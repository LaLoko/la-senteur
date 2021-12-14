import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addShippmentInfo from '@salesforce/apex/PerfumesController.addShippmentInfo';
import getAddress from '@salesforce/apex/PerfumesController.getAddress';
export default class ShippingDetails extends LightningElement {
    street;
    city;
    zip;
    country;
    state;
    companyName;
    @track address;
    @track wantInvoice = false;
    @track sameAdress = false;

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
        if(!this.validAddress()){
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
                if(this.wantInvoice == true){
                    this.addInvoiceInfoToOrder();
                }else{
                    this.dispatchEvent(new CustomEvent('next',{step:'3'}));
                }
            })
            .catch(error => {
                this.error = error;
            });
     
        }
    }
    addInvoiceInfoToOrder(){
        addInvoiceData({companyName:this.companyName,street:this.street,country:this.country,zip:this.zip,state:this.state,city:this.city})
        .then(result => {
            this.dispatchEvent(new CustomEvent('next',{step:'3'}));
        })
        .catch(error => {
            this.error = error;
        });
    }

    get validAddress(){
        return ((this.address.street === undefined || this.address.street == '')||
        (this.address.city === undefined || this.address.city == '')||
        (this.address.zip === undefined || this.address.zip == '')||
        (this.address.country === undefined || this.address.country == '')||
        (this.address.state === undefined || this.address.state == ''));
    }

    clickInvoice(){
        this.wantInvoice = !this.wantInvoice;
    }

    companyAddressChange(){
        this.sameAdress = !this.sameAdress;
        console.log(this.sameAdress)

        if(this.sameAdress == true){
            this.street = this.address.street;
            this.city = this.address.city;
            this.country = this.address.country;
            this.zip = this.address.zip;
            this.state = this.address.state;
        }
    }

    handleCompanyNameChange(event){
        this.companyName= event.target.value;
    }

    companyStreetChange(event) {
        this.street= event.target.value;
    }

    companyCityChange(event) {
        this.city= event.target.value;
    }

    companyZipChange(event) {
        this.zip= event.target.value;
    }

    companyCountryChange(event) {
        this.country= event.target.value;
    }
    
    companyStateChange(event) {
        this.state= event.target.value;
    }
    
}