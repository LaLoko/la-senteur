import { LightningElement, track } from 'lwc';
import getCustomPricebooks from '@salesforce/apex/DiscountController.getCustomPricebooks';
import getPricebookDetails from '@salesforce/apex/DiscountController.getPricebookDetails';
import saveEditedPricebook from '@salesforce/apex/DiscountController.saveEditedPricebook';
import deleteSelectedPricebook from '@salesforce/apex/DiscountController.deleteSelectedPricebook';
import deleteEntry from '@salesforce/apex/DiscountController.deleteEntry';
import editEntry from '@salesforce/apex/DiscountController.editEntry';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PricebooksMenager extends LightningElement {
    @track pricebooks;
    @track detailsVisible = false;
    detailedPircebook;
    @track pricebookInEdit = false;
    @track variantsChanged;
    editId;
    editPricebookName;
    editPricebookDesc;
    editPricebookValidFrom;
    editPricebookValidTo;
    editPricebookActive;
    delVariantId;
    @track isDialogVisible = false;

    connectedCallback(){
        this.getPricebooks();
    }

    getPricebooks(){
        getCustomPricebooks()
        .then(result => {
            this.pricebooks = result;
        })
        .catch(error => {
            this.error = error;
        });   
    }

    showModal(event){
        let index = event.target.dataset.recordId;
        this.editId = this.pricebooks[index].Id;

        getPricebookDetails({pricebookId:this.editId})
        .then(result => {
            this.detailedPircebook = result;
            this.detailsVisible = true;
            this.variantsChanged = false;
        })
        .catch(error => {
            this.error = error;
        });  
    }

    closeModal(){
        this.detailsVisible = false;
    }

    openEdit(){
        this.pricebookInEdit = true;

        this.editPricebookActive = this.detailedPircebook.pricebook.IsActive;
        this.editPricebookName = this.detailedPircebook.pricebook.Name;
        this.editPricebookDesc = this.detailedPircebook.pricebook.Description;
        this.editPricebookValidFrom = this.detailedPircebook.pricebook.ValidFrom;
        this.editPricebookValidTo = this.detailedPircebook.pricebook.ValidTo;
    }

    closeEdit(){
        this.pricebookInEdit = false;
    }

    saveEdit(){
        saveEditedPricebook({pricebookId:this.editId,name:this.editPricebookName,description:this.editPricebookDesc,
            validfrom:this.editPricebookValidFrom,validto:this.editPricebookValidTo,active:this.editPricebookActive})
        .then(result => {
            this.detailedPircebook = result;
            this.pricebookInEdit = false;

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Pricebook edited successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            this.error = error;
        });  
    }

    deletePricebook(){
        deleteSelectedPricebook({pricebookId:this.editId})
        .then(result => {
            this.pricebooks = result;
            this.pricebookInEdit = false;
            this.showModal = false;
            this.detailsVisible = false;

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Pricebook deleted successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            this.error = error;
        });  
    }

    handleActiveChange(){
        this.editPricebookActive = !this.editPricebookActive;
    }

    handleEndDateChange(event){
        this.editPricebookValidTo = event.target.value;
    }

    handleStartDateChange(event){
        this.editPricebookValidFrom = event.target.value;
    }

    handleDescriptionChange(event){
        this.editPricebookDesc = event.target.value;
    }

    handleNameChange(event){
        this.editPricebookName = event.target.value;
    }

    handleVariantPriceChange(event){
        let index = event.target.dataset.recordId;

        this.detailedPircebook.pricebookItems[index].entry.New_price__c = event.target.value;
        this.variantsChanged = true;
    }

    openDelVariantModal(event){
        let index = event.target.dataset.recordId;
        this.delVariantId = this.detailedPircebook.pricebookItems[index].entry.Id
        this.isDialogVisible = true;
    }

    openDelPricebookModal(){
        this.isDialogVisible = true;
    }

    deleteVariant(){
        deleteEntry({entryId: this.delVariantId,pricebookId:this.editId})
        .then(result => {
            this.detailedPircebook = result;
            this.delVariantId = undefined;

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Variant deleted successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            this.error = error;
        });  
    }

    saveEditedVariants(){
        editEntry({entries:JSON.stringify(this.detailedPircebook.pricebookItems),pricebookId:this.editId})
        .then(result => {
            this.detailedPircebook = result;
            this.variantsChanged = false;

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Variants edited successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .catch(error => {
            this.error = error;
        });  
    }

    cancel(){
        this.isDialogVisible = false;
    }

    confirm(){
        if(this.delVariantId){
            this.deleteVariant();
        }else{
            this.deletePricebook();
        }
        this.cancel();
    }
}