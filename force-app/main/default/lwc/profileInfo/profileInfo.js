import { LightningElement, track } from 'lwc';
import getProfileInfo from '@salesforce/apex/ProfileController.getProfileInfo';
import updateProfile from '@salesforce/apex/ProfileController.updateProfile';
export default class ProfileInfo extends LightningElement {
    @track user;
    editUser;
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
        updateProfile({profile:this.editUser})
        .then(result => {
            this.user = result;
            this.editMode = false;
        })
        .catch(error => {
            this.error = error;
        });   
    }
}