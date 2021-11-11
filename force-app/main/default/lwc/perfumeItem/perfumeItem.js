import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class PerfumeItem extends LightningElement {
    @api item;
    tileClick(){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.item.Id,
                    objectApiName: 'Account',
                    actionName: 'view'
                },
            });
        
    }
}