public class ShippmentInfo{
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String country;
    @AuraEnabled
    public String zip;
    @AuraEnabled
    public String street;

    public ShippmentInfo(){}
    public ShippmentInfo(String state,String city,String country, String zip, String street){
        this.state = state;
        this.city = city;
        this.country = country;
        this.zip = zip;
        this.street = street;
    }
}