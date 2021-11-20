public with sharing class ProfileController {

    @AuraEnabled
    public static User getProfileInfo(){
        String userId = System.UserInfo.getUserId();

    }
}
