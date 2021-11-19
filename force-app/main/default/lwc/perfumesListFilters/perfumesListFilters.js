import { LightningElement,track, wire, api } from 'lwc';
import getAllAccords from '@salesforce/apex/PerfumesController.getAllAccords';
import getAllDesigners from '@salesforce/apex/PerfumesController.getAllDesigners';
import getAllNotes from '@salesforce/apex/PerfumesController.getAllNotes';
export default class PerfumesListFilters extends LightningElement {

@track selectedDesigner;
@track selectedAccords;
@track selectedTopNotes;
@track selectedMiddleNotes;
@track selectedBaseNotes;

@track designers;
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
      this.designers = result;
    })
    .catch(error => {
        this.error = error;
    });   
  }

  get designersOptions(){
    var returnOptions = [];
    var index = 1;
    this.designers.forEach(ele =>{
        returnOptions.push({key:index , value:ele});
        index++;
    }); 
    return returnOptions;
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

  handleDesignerSelect(event) {
    if (event.detail) {
      this.selectedDesigner = "";
      let self = this;

      event.detail.forEach(function (eachItem) {
        self.selectedDesigner += eachItem.value + ", ";
      });
    }
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

  filter(){
    var filters = {designers:this.selectedDesigner,
      accords:this.selectedAccords,
      topNotes:this.selectedTopNotes,
      middleNotes:this.selectedMiddleNotes,
      baseNotes:this.selectedBaseNotes
    };

    this.dispatchEvent(new CustomEvent('filter',{detail:filters}));
  }
  clear(){
    this.clearComboboxes();
    this.dispatchEvent(new CustomEvent('clear'));
  }
  clearComboboxes(){
    this.template
      .querySelector(".picklist1")
       .onRefreshClick();

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
  }

}