import { LightningElement,track } from 'lwc';
export default class PerfumesListFilters extends LightningElement {

@track selectedDesigner;
@track selectedAccords;
@track selectedTopNotes;
@track selectedMiddleNotes;
@track selectedBaseNotes;

@track designers;
@track accords;
@track notes;

// get allAccords() {
//   var returnOptions = [];
//   var index = 1;

//   this.accords.forEach(ele =>{
//       returnOptions.push({key:index , value:ele});
//       index++;
//   }); 

//  return returnOptions;
// }
connectedCallback(){
  console.log(this.accords)
  console.log(this.notes);
}
get allDesigners(){
  return [
    { key: 1, value: "Dior" },
    { key: 2, value: "Prada" },
    { key: 3, value: "Yves Saint Laurent" },
    { key: 4, value: "Banglore" },
    { key: 5, value: "Giorgio Armani" },
    { key: 6, value: "Dolce&Gabbana" },
    { key: 7, value: "Chanel" },
  ];
}
  get msOptions() {

    var ala = [
      { key: 1, value: "Jaipur" },
      { key: 2, value: "Pune" },
      { key: 3, value: "Hyderabad" },
      { key: 4, value: "Banglore" },
      { key: 5, value: "Gurgaon" },
      { key: 6, value: "Mumbai" },
      { key: 7, value: "Chennai" },
      { key: 8, value: "Noida" },
      { key: 9, value: "Delhi" },
    ];

    // var returnOptions = [];
    
    // var index = 1;
    // this.designers.forEach(ele =>{
    //     returnOptions.push({ key: index, value: ele },);
    //     index++;
    // }); 
    // console.log(returnOptions);

   return ala;
  }

  getSelectedDesigners() {
    this.selectedDesigner = "";
    let self = this;
    this.template
      .querySelector("c-multi-pick-list")
      .getSelectedItems()
      .forEach(function (eachItem) {
        self.selectedDesigner += eachItem.value + ", ";
      });
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

  getSelectedAccords() {
    this.selectedAccords = "";
    let self = this;
    this.template
      .querySelector("c-multi-pick-list")
      .getSelectedItems()
      .forEach(function (eachItem) {
        self.selectedAccords += eachItem.value + ", ";
      });
  }

  handleAccordSelect(event) {
    if (event.detail) {
      this.selectedAccords = "";
      let self = this;

      event.detail.forEach(function (eachItem) {
        self.selectedAccords += eachItem.value + ", ";
      });
    }
  }

  getSelectedTopNotes() {
    this.selectedTopNotes = "";
    let self = this;
    this.template
      .querySelector("c-multi-pick-list")
      .getSelectedItems()
      .forEach(function (eachItem) {
        self.selectedTopNotes += eachItem.value + ", ";
      });
  }

  handleTopNoteSelect(event) {
    if (event.detail) {
      this.selectedTopNotes = "";
      let self = this;

      event.detail.forEach(function (eachItem) {
        self.selectedTopNotes += eachItem.value + ", ";
      });
    }
  }

  getSelectedMiddleNotes() {
    this.selectedMiddleNotes = "";
    let self = this;
    this.template
      .querySelector("c-multi-pick-list")
      .getSelectedItems()
      .forEach(function (eachItem) {
        self.selectedMiddleNotes += eachItem.value + ", ";
      });
  }

  handleMiddleNoteSelect(event) {
    if (event.detail) {
      this.selectedMiddleNotes = "";
      let self = this;

      event.detail.forEach(function (eachItem) {
        self.selectedMiddleNotes += eachItem.value + ", ";
      });
    }
  }

  getSelectedBaseNotes() {
    this.selectedBaseNotes = "";
    let self = this;
    this.template
      .querySelector("c-multi-pick-list")
      .getSelectedItems()
      .forEach(function (eachItem) {
        self.selectedBaseNotes += eachItem.value + ", ";
      });
  }

  handleBaseNoteSelect(event) {
    if (event.detail) {
      this.selectedBaseNotes = "";
      let self = this;

      event.detail.forEach(function (eachItem) {
        self.selectedBaseNotes += eachItem.value + ", ";
      });
    }
  }
  filter(){

  }
}