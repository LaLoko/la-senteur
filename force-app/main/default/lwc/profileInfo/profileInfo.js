import { LightningElement, track } from 'lwc';
import getProfileInfo from '@salesforce/apex/ProfileController.getProfileInfo';
import updateProfile from '@salesforce/apex/ProfileController.updateProfile';
export default class ProfileInfo extends LightningElement {
    @track user;
    @track editUser;
    editMode = false;

    connectedCallback(){
        this.getUserInfo();
    }

    getUserInfo(){
        getProfileInfo()
        .then(result => {
            this.user = result;
            console.log(JSON.stringify(result));
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
        console.log(JSON.stringify(this.editUser))
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