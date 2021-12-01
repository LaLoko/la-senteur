import { LightningElement,track } from 'lwc';

export default class ProfilePage extends LightningElement {
    @track showDetails = false;
    order;
    orderId;
    caseId;
    currTab;

    connectedCallback(){
        let incomeURL = window.location.href;
        let paramsFromURL = new URL(incomeURL).searchParams;
        if(paramsFromURL != undefined){
            this.orderId = paramsFromURL.get('orderId');
            this.caseId = paramsFromURL.get('caseId');
            if(this.orderId != null){
                this.currTab = 'Orders history';
            }else if (this.caseId != null){
                this.currTab = 'Complaint history';
            }else{
                this.currTab = 'Profile';
            }
        }else{
            this.currTab = 'Profile';
        }
    }

    handleOrderSelect(event){
        this.order = event.detail;
        this.showDetails = true;
    }
    handleDetailsClose(event){
        this.showDetails = false;
    }
    goToOrder(event){
        this.orderId = event.detail;
        this.template.querySelector('lightning-tabset').activeTabValue = 'Orders history';
    }
}