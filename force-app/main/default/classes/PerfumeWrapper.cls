public class PerfumeWrapper {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String photo { get; set; }
    @AuraEnabled
    public Decimal score { get; set; }
    @AuraEnabled
    public String topNotes { get; set; }
    @AuraEnabled
    public String middleNotes { get; set; }
    @AuraEnabled
    public String baseNotes { get; set; }
    @AuraEnabled
    public String mainAccords { get; set; }
    @AuraEnabled
    public String gender { get; set; }
    @AuraEnabled
    public String designer { get; set; }
    @AuraEnabled
    public String designerName { get; set; }
    @AuraEnabled
    public List<String> variants { get; set; }
    @AuraEnabled
    public String price { get; set; }
    @AuraEnabled
    public List<Product_Image__c> images { get; set; }

    public PerfumeWrapper() {
    }

    public PerfumeWrapper(Perfume__c perfume) {
        this.Id = perfume.Id;
        this.name = perfume.Name;
        this.photo = perfume.Photo__c;
        this.score = perfume.Score__c;
        this.topNotes = perfume.Top_Notes__c;
        this.middleNotes = perfume.Middle_Notes__c;
        this.baseNotes = perfume.Base_Notes__c;
        this.gender = perfume.Gender__c;
        this.designer = perfume.Designer__c;
    }
}