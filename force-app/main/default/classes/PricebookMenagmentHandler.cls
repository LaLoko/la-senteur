public with sharing class PricebookMenagmentHandler {

    public PricebookMenagmentHandler() {
    }

    public  void afterInsert(List<Pricebook2> pricebooks){
        minPriceUpdate(pricebooks);
    }
    public  void afterUpdate(List<Pricebook2> pricebooks){
        minPriceUpdate(pricebooks);
    }

    public void afterDelete(List<Pricebook2> pricebooks){
        List<Id> delIds = new List<Id>();
        for(Pricebook2 pricebook : pricebooks){
            delIds.add(pricebook.Id);
        }
        List<Pricebook_entry_variant__c> pVatiants = [SELECT Id FROM Pricebook_entry_variant__c WHERE Price_Book__c IN : delIds];
        delete pVatiants;
        minPriceUpdate(pricebooks);
    }

    public static void minPriceUpdate(List<Pricebook2> pricebooks){
        List<Id> activeIds = new List<Id>();
        for(Pricebook2 pricebook : pricebooks){
            if(pricebook.ValidFrom >= date.today() && pricebook.ValidTo <= date.today()){
                pricebook.IsActive = true;
                activeIds.add(pricebook.Id);                
            }else{
                pricebook.IsActive = false;
            }
        }
        if(activeIds.size() > 0 ){
        List<Pricebook_entry_variant__c> pricebookVariants = [SELECT New_price__c,Variant__c FROM Pricebook_entry_variant__c WHERE Price_Book__c IN : activeIds];

        List<Id> variantIds = new List<Id>();

        for(Pricebook_entry_variant__c variant : pricebookVariants){
            variantIds.add(variant.Variant__c);
        }
        List<Variant__c> variants = [SELECT Id,Product__c FROM Variant__c WHERE Id IN : variantIds];
        List<Id> productIds = new List<Id>();

        for(Variant__c variant : variants){
            productIds.add(variant.Product__c);
        }
        List<Product2> products = [SELECT Id,minPrice__c FROM Product2 WHERE Id IN : productIds];

        for(Product2 product : products){
            for(Variant__c variant : variants){
                if(variant.Product__c == product.Id){
                    for(Pricebook_entry_variant__c pVariant : pricebookVariants){
                        if(pVariant.Variant__c == variant.Id){
                            if(pVariant.New_price__c < product.minPrice__c){
                                product.minPrice__c = pVariant.New_price__c;
                            }
                        }
                    }
                }
            }

        }
    }else{
        List<Pricebook2> activePricebooks = [SELECT Id, IsStandard, IsActive FROM Pricebook2 WHERE IsStandard = false];
        if(activePricebooks.size() == 0){
            Pricebook2 standard = [SELECT Id, IsStandard FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
            List<PricebookEntry> entries = [SELECT UnitPrice,Pricebook2Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id =: standard.Id];
            List<Product2> products = [SELECT minPrice__c,Id FROM Product2 WHERE Family = 'Perfumes'];

            for(PricebookEntry entry : entries){
                for(Product2 product : products){
                    if(entry.Product2Id == product.Id){
                        product.minPrice__c = entry.UnitPrice;
                    }
                }
            }
            update products;
        }
    }
    }
}
