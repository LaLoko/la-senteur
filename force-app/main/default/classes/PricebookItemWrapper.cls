public class PricebookItemWrapper{
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String variantId;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String designer;
    @AuraEnabled
    public String gender;
    @AuraEnabled
    public Decimal capacity;
    @AuraEnabled
    public Decimal price;
    @AuraEnabled
    public Boolean selected;
    
    public PricebookItemWrapper(){
    }
    public static List<PricebookItemWrapper> parse(String json) {
        return (List<PricebookItemWrapper>) System.JSON.deserialize(json, List<PricebookItemWrapper>.class);
    }}