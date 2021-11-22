public with sharing class ProfileController {

    @AuraEnabled
    public static ProfileWrapper getProfileInfo(){
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,Name,AboutMe,Address,ContactId,Phone,Username,SenderEmail FROM User WHERE Id =: userId].get(0);
        List<Contact> contacts = [SELECT Id,Name,Email,Phone FROM Contact WHERE Id =: user.ContactId];

        ProfileWrapper wrapper = new ProfileWrapper();
        wrapper.id = user.Id;
        wrapper.name = user.Name;
        wrapper.username = user.Username;
        wrapper.phone = user.Phone;
        wrapper.email = contacts.size() > 0 ?contacts.get(0).Email : null;

        System.debug(wrapper);

        return wrapper;
    }
    
    @AuraEnabled
    public static List<Order> getAllOrders(){
        String userId = System.UserInfo.getUserId();
        // User user = [SELECT Id,ContactId FROM User WHERE Id =: userId].get(0);
        List<Order> orders = [SELECT Id,Name,TotalAmount,ActivatedDate FROM Order WHERE CreatedById =: userId];

        return orders;
    }
    @AuraEnabled
    public static ProfileWrapper updateProfile(ProfileWrapper profile){
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,Name,AboutMe,Address,ContactId,Phone,Username,SenderEmail FROM User WHERE Id =: userId].get(0);
        List<Contact> contacts = [SELECT Id,Name,Email,Phone FROM Contact WHERE Id =: user.ContactId];

        user.Phone = profile.phone;
        update user;

        System.debug(profile);

        return profile;
    }

     public class ProfileWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String username;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String aboutMe;
        
        public ProfileWrapper(){}
    }
}
