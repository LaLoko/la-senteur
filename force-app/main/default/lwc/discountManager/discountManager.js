import { LightningElement, track } from 'lwc';
import getPricebookItems from '@salesforce/apex/DiscountController.getPricebookItems';
import createNewPricebook from '@salesforce/apex/DiscountController.createNewPricebook';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DiscountManager extends LightningElement {
    pricebookName = '';
    description = '';
    startDate;
    endDate;
    @track isLoading = true;
    products = [];
    rowOffset = 0;
    draftValues = []

    connectedCallback(){
        this.getAllProducts();
    }

    get columns(){
        return [
            {label: 'Designer',fieldName: 'designer',editable: false},
            {label: 'Perfume Name',fieldName: 'name',editable: false},
            {label: 'Gender',fieldName: 'gender',editable: false},
            {label: 'Capacity',fieldName: 'capacity',type: 'decimal',editable: false},
            {label: 'Price',fieldName: 'price',type: 'currency',editable: true},
        ];
    }

    handleNameChange(event){
        this.pricebookName = event.target.value;
    }
    handleDescriptionChange(event){
        this.description = event.target.value;
    }
    handleStartDateChange(event){
        this.startDate = event.target.value;
    }
    handleEndDateChange(event){
        this.endDate = event.target.value;
    }

    getAllProducts(){
        getPricebookItems()
        .then(result => {
            this.products = result;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
        });   
    }
    handlePriceChange(event){
        this.draftValues = event.target.draftValues;
        // let indx = event.target.dataset.recordId;
        console.log(JSON.stringify(event.target.draftValues))
  

        // if ( this.products ) {
        //     let price =  event.target.value;

        //     let recs =  JSON.parse( JSON.stringify( this.products ) );
        //     recs[ indx ].price = price;
        //     this.products = recs;
        // }
    }

    handlePerfumeSelection(event){
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
           selectedRows[i].selected = true;
           console.log(selectedRows[i].name);
        }

        // let indx = event.target.dataset.recordId;

        // if ( this.products ) {

        //     let recs =  JSON.parse( JSON.stringify( this.products ) );
        //     let currVal = recs[ indx ].selected;
        //     recs[ indx ].selected = !currVal;
        //     this.products = recs;
        // }
    }
    savePricebook(){
        var priceBelowZero = false;
        var somethingSelected = false;

        this.products.forEach(element => {
            this.draftValues.forEach(el => {
                if(element.variantId == el.variantId){
                    element.price = el.price;
                    console.log(el.price);
                }
            });
        });
        console.log(this.products)

        this.products.forEach(element => {
            if(element.selected){
                somethingSelected = true;
                if(element.price <= 0){
                    priceBelowZero = true;
                }            
            }
        });
        console.log(priceBelowZero)
        if(somethingSelected){
            if(!priceBelowZero){
                createNewPricebook({products:JSON.stringify(this.products),name:this.pricebookName,description:this.description,startDate:this.startDate,endDate:this.endDate})
                .then(result => {
                    // this.products = result;
                    // this.isLoading = false;
                })
                .catch(error => {
                    this.error = error;
                });   
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Price of some products is below 0 EUR',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'No products selected',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }

    }
}