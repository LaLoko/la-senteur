public class ProfileWrapper{
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String username;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String aboutMe;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String street;
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String zip;
    @AuraEnabled
    public String country;
    
    public static ProfileWrapper parse(String json) {
        return (ProfileWrapper) System.JSON.deserialize(json, ProfileWrapper.class);
    }

    public ProfileWrapper(){}
}