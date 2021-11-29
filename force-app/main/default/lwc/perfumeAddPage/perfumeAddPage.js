import { LightningElement,track,api } from 'lwc';
import getAllDesigners from '@salesforce/apex/PerfumesController.getAllDesigners';
import getAllNotes from '@salesforce/apex/PerfumesController.getAllNotes';
import getAllAccords from '@salesforce/apex/PerfumesController.getAllAccords';

import createNewPerfume from '@salesforce/apex/NewPerfumeController.createNewPerfume';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PerfumeAddPage extends NavigationMixin(
  LightningElement
) {

 @track name = '';
    selGender = '';
    selDesigner ='';
    allDesigners = [];
    @track variants = [];

    variantCap = '';
    variantPrice = '';

@track selectedAccords;
@track selectedTopNotes;
@track selectedMiddleNotes;
@track selectedBaseNotes;

@track accords;
@track notes;
    @track isLoading = true;

    connectedCallback(){
        this.getDesigners();
        this.getAccords();
        this.getNotes();
    }

    getDesigners(){
        getAllDesigners()
        .then(result => {
          this.allDesigners = result;
        })
        .catch(error => {
            this.error = error;
        });   
      }

      getAccords(){
        getAllAccords()
          .then(result => {
            this.accords = result;
            })
            .catch(error => {
                this.error = error;
         });    
      }

      get accordsOptions(){
        var returnOptions = [];
        var index = 1;
        this.accords.forEach(ele =>{
            returnOptions.push({key:index , value:ele});
            index++;
        }); 
        return returnOptions;
      }
      
      getNotes(){
        getAllNotes()
          .then(result => {
            this.notes = result;
            this.isLoading = false;
            })
          .catch(error => {
               this.error = error;
          });    
      }

      get notesOptions(){
        var returnOptions = [];
        var index = 1;
        this.notes.forEach(ele =>{
            returnOptions.push({key:index , value:ele});
            index++;
        }); 
        return returnOptions;
      }

      get designers() {
        var returnOptions = [];
            this.allDesigners.forEach(ele =>{
                returnOptions.push({label:ele , value:ele});
            }); 
        
        return returnOptions;
    }
    
      handleAccordSelect(event) {
        if (event.detail) {
          this.selectedAccords = "";
          let self = this;
    
          event.detail.forEach(function (eachItem) {
            self.selectedAccords += eachItem.value + ",";
          });
        }
      }
    
      handleTopNoteSelect(event) {
        if (event.detail) {
          this.selectedTopNotes = "";
          let self = this;
    
          event.detail.forEach(function (eachItem) {
            self.selectedTopNotes += eachItem.value + ",";
          });
        }
      }
    
      handleMiddleNoteSelect(event) {
        if (event.detail) {
          this.selectedMiddleNotes = "";
          let self = this;
    
          event.detail.forEach(function (eachItem) {
            self.selectedMiddleNotes += eachItem.value + ",";
          });
        }
      }
    
      handleBaseNoteSelect(event) {
        if (event.detail) {
          this.selectedBaseNotes = "";
          let self = this;
    
          event.detail.forEach(function (eachItem) {
            self.selectedBaseNotes += eachItem.value + ",";
          });
        }
      }

    get genders(){
        return [
            { label: 'MALE', value: 'MALE' },
            { label: 'FEMALE', value: 'FEMALE' },
            { label: 'UNISEX', value: 'UNISEX' },
        ];
    }

    handleNameChange(event){
      this.name = event.target.value;
  }
    handleGenderChange(event){
        this.selGender = event.target.value;
    }
    handleDesignerChange(event){
        this.selDesigner = event.target.value;
    }
    handleCapChange(event){
        this.variantCap = event.target.value;
    }
    handlePriceChange(event){
        this.variantPrice = event.target.value;
    }

    addVariant(){
        var pom = this.variantCap+' ml - '+this.variantPrice+' €';
        this.variants.push({
            label: pom
        })
        console.log(this.variants);
    }
    handleItemRemove(event){
        let index = event.detail.index;
        let items = this.variants;
        items.splice(index, 1);
        this.variants = items;
       }
       addPerfume(){
         if((this.name !== undefined || this.name != '')||
         (this.selDesigner !== undefined || this.selDesigner != '')||
         (this.selGender !== undefined || this.selGender != '')||
         (this.selectedAccords !== undefined || this.selectedAccords != '')||
         (this.selectedTopNotes !== undefined || this.selectedTopNotes != '')||
         (this.selectedMiddleNotes !== undefined || this.selectedMiddleNotes != '')||
         (this.selectedBaseNotes !== undefined || this.selectedBaseNotes != '')||
         (this.variants !== undefined || this.variants != '')){
          createNewPerfume({
            name:this.name,
            designer: this.selDesigner,
            gender: this.selGender,
            accords: this.selectedAccords,
            topNotes: this.selectedTopNotes,
            middleNotes: this.selectedMiddleNotes,
            baseNotes: this.selectedBaseNotes,
            variants: JSON.stringify(this.variants),
          })
          .then(result => {              
              this.template.querySelector('c-file-upload-multi').uploadFiles();
              // this.clear();
              this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'Pricebook2',
                    actionName: 'view'
                }
            });
          })
          .catch(error => {
              this.error = error;
              const evt = new ShowToastEvent({
                title: 'Error',
                message: error.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
          });
         }else{
          const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Some fields are incomplete',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
         }
       }

       @api
       clear(){
         this.isLoading = true;
        this.name = '';
        this.variants = [];
        this.variantCap = '';
        this.variantPrice = '';
        this.selDesigner = '';
        this.selGender = '';
        this.selectedAccords = [];
        this.selectedTopNotes = [];
        this.selectedMiddleNotes = [];
        this.selectedBaseNotes = [];
  
         this.template
         .querySelector(".picklist2")
          .onRefreshClick();
          this.template
          .querySelector(".picklist3")
           .onRefreshClick();
           this.template
           .querySelector(".picklist4")
            .onRefreshClick();
            this.template
            .querySelector(".picklist5")
             .onRefreshClick();
        this.isLoading = false;
       }
}