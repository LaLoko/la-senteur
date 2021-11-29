import { LightningElement, track } from 'lwc';
import getPricebookItems from '@salesforce/apex/DiscountController.getPricebookItems';
import createNewPricebook from '@salesforce/apex/DiscountController.createNewPricebook';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class DiscountManager extends NavigationMixin(
    LightningElement
  ) {
    pricebookName = '';
    description = '';
    startDate;
    endDate;
    @track isLoading = true;
    products = [];
    rowOffset = 0;
    draftValues = [];

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

    handlePerfumeSelection(event){
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
           selectedRows[i].selected = true;
        }
    }
    savePricebook(event){
        let rows = this.template.querySelector("lightning-datatable").getSelectedRows()
        let products = event.detail.draftValues;
        let priceBelowZero = false;
    
        if(rows.length > 0){
        products.forEach(prod => {
            rows.forEach(row => {
                if(row.variantId == prod.variantId){
                    row.price = prod.price;
                }
            });  
        });
    }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'No rows selected',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        
    }
        products = rows;

        products.forEach(element => {
                if(element.price <= 0){
                    priceBelowZero = true;
                }            
        });
        console.log(priceBelowZero);
        if(this.pricebookName === undefined || this.pricebookName == ''){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Name cannot be empty',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }
            if(!priceBelowZero){
                createNewPricebook({products:JSON.stringify(products),name:this.pricebookName,description:this.description,startDate:this.startDate,endDate:this.endDate})
                .then(result => {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    });
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
    }
}