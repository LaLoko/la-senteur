import { LightningElement,api,track } from 'lwc';
import getDetailPerfume from '@salesforce/apex/PerfumesController.getDetailPerfume';

export default class PerfumePage extends LightningElement {
    id;
    @api perfume;
    topNotes = []
    middleNotes =[]
    baseNotes = []
    mainAccords;
    option = "";
    score = '1';

    connectedCallback(){
        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        this.id = paramsFromURL.get('id');
        this.getDetails(this.id);
    }

    getDetails(id){

        getDetailPerfume({id:id})
            .then(result => {
                this.perfume = result;
                this.setNotes(this.perfume);
            })
            .catch(error => {
                this.error = error;
            });      
}
    setNotes(perfume){
        this.topNotes = perfume.topNotes.split(';')
        this.middleNotes = perfume.middleNotes.split(';')
        this.baseNotes = perfume.baseNotes.split(';')
        this.mainAccords = perfume.mainAccords.split(';')
    }


    get options() {
        var returnOptions = [];
            this.perfume.variants.forEach(ele =>{
                returnOptions.push({label:ele , value:ele});
            }); 
        
        return returnOptions;
    }

    get scoreOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
        ];
    }
}