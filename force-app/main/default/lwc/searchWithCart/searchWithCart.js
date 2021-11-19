import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SearchWithCart extends NavigationMixin(
    LightningElement
) {
    search(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'search-results'
            },
            state: {
                'key': this.searchKey
            }
        });
}
keyChanged(event) {
    this.searchKey= event.target.value;
}
toCart(){
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            pageName: 'cart'
        }
    });
}
}