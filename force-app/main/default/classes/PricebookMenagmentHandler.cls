public with sharing class PricebookMenagmentHandler {
    final Map<Id,SObject> variants;

    public PricebookMenagmentHandler(Map<Id,SObject> variants) {
        this.variants = variants;
    }
    public  void afterInsert(List<Variant__c> variantsList){
        Pricebook2 priceBook50 = [SELECT Id,Name FROM Pricebook2 WHERE Name LIKE '%50%'].get(0);
        Pricebook2 priceBook75 = [SELECT Id,Name FROM Pricebook2 WHERE Name LIKE '%75%'].get(0);
        Pricebook2 priceBook100 = [SELECT Id,Name FROM Pricebook2 WHERE Name LIKE '%100%'].get(0);
        Pricebook2 priceBook125 = [SELECT Id,Name FROM Pricebook2 WHERE Name LIKE '%125%'].get(0);
        Pricebook2 priceBook200 = [SELECT Id,Name FROM Pricebook2 WHERE Name LIKE '%200%'].get(0);

        // List<Product2> perfumes = [SELECT Name,Id,Variant__c FROM Product2 WHERE Variant__c IN :variants.keySet()];

        for(Variant__c variant : variantsList){
            Id priceBookId;
            if(variant.Capacity__c == 50){
                priceBookId = priceBook50.Id;
            }else if(variant.Capacity__c == 75){
                priceBookId = priceBook75.Id;
            }else if(variant.Capacity__c == 100){
                priceBookId = priceBook100.Id;
            }else if(variant.Capacity__c == 125){
                priceBookId = priceBook125.Id;
            }else{
                priceBookId = priceBook200.Id;
            }
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = variant.Product__c, UnitPrice = variant.Price__c, IsActive = true);
            insert standardPBE;
        }

    }
    public  void afterUpdate(List<Variant__c> variantsList){
        List<Id> productIds = new List<Id>();
        for(Variant__c variant : variantsList){
            productIds.add(variant.Product__c);
        }
        List<PricebookEntry> pricebookEntries = [SELECT Id,UnitPrice,Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds];
        for(Variant__c variant : variantsList){
            for(PricebookEntry entry : pricebookEntries){
                if(variant.Product__c == entry.Product2Id){
                    entry.UnitPrice = variant.Price__c;
                }
            }
        }
        update pricebookEntries;
    }
    public  void afterDelete(List<Variant__c> variantsList){
        List<Id> productIds = new List<Id>();
        for(Variant__c variant : variantsList){
            productIds.add(variant.Product__c);
        }
        List<PricebookEntry> pricebookEntries = [SELECT Id,UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIds];

        List<PricebookEntry> entriesToDel = new List<PricebookEntry>();
        for(Variant__c variant : variantsList){
            for(PricebookEntry entry : pricebookEntries){
                if(variant.Product__c == entry.Product2Id && variant.Price__c == entry.UnitPrice){
                    entriesToDel.add(entry);
                }
            }
        }
        delete entriesToDel;
    }
}
