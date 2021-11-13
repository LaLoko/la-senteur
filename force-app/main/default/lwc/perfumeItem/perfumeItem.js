import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class PerfumeItem extends NavigationMixin(
    LightningElement
) {
    @api item;
    tileClick(){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'perfume-detail'
                },
                state: {
                    'id': this.item.Id
                }
            });
    }
}