import { LightningElement, track } from 'lwc';
import getProfileInfo from '@salesforce/apex/ProfileController.getProfileInfo';
import updateProfile from '@salesforce/apex/ProfileController.updateProfile';
export default class ProfileInfo extends LightningElement {
    @track user;
    @track editUser;
    @track isLoading = true;
    editMode = false;

    connectedCallback(){
        this.getUserInfo();
    }

    getUserInfo(){
        getProfileInfo()
        .then(result => {
            this.user = result;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
        });   
    }

    editProfile(){
        this.editUser = this.user;
        this.editMode = true;
    }

    exitEdit(){
        this.editMode = false;
    }

    saveEdit(){
        updateProfile({pro:JSON.stringify(this.editUser)})
        .then(result => {
            this.user = result;
            this.editMode = false;
        })
        .catch(error => {
            this.error = error;
        });   
    }

    phoneChange(event){
        this.editUser.phone= event.target.value;
    }

    cityChange(event){
        this.editUser.city= event.target.value;
    }

    stateChange(event){
        this.editUser.state= event.target.value;
    }

    zipChange(event){
        this.editUser.zip= event.target.value;
    }

    countryChange(event){
        this.editUser.country= event.target.value;
    }
    
    streetChange(event){
        this.editUser.street= event.target.value;
    }
}