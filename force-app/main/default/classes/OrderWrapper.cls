public class OrderWrapper{
    @AuraEnabled
    public Decimal price;
    @AuraEnabled
    public Decimal capacity;
    @AuraEnabled
    public String designer;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public Id perfumeId;
    @AuraEnabled
    public Boolean hideBool;
    @AuraEnabled
    public Order objOrder;

    public OrderWrapper(){}

    public static List<OrderWrapper> parse(String json) {
        return (List<OrderWrapper>) System.JSON.deserialize(json, List<OrderWrapper>.class);
    }
}