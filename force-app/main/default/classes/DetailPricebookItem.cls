public class DetailPricebookItem{
    @AuraEnabled
        public Pricebook_entry_variant__c entry;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String designerName;
        @AuraEnabled
        public Decimal capacity;

        public DetailPricebookItem(){
        }

        public static List<DetailPricebookItem> parse(String json) {
            return (List<DetailPricebookItem>) System.JSON.deserialize(json, List<DetailPricebookItem>.class);
        }
}
