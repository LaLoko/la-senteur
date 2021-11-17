import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CustomHeader extends NavigationMixin(
    LightningElement
) {
    searchKey;

    home(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
    male(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'male-perfumes'
            }
        });
    }
    female(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'female-perfumes'
            }
        });
    }
    unisex(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'unisex-perfumes'
            }
        });
    }
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
}