trigger PricebooksMenager on Variant__c (after insert,after update, after delete) {

    // PricebookMenagmentHandler handler = new PricebookMenagmentHandler(Trigger.oldMap);
    // if(Trigger.isInsert){
    //     handler.afterInsert(Trigger.new);
    // }
    // if(Trigger.isUpdate){
    //     handler.afterUpdate(Trigger.old);

    // }
    // if(Trigger.isDelete){
    //     handler.afterDelete(Trigger.old);
    // }


    // List<Pricebook2> priceBooks = [SELECT Id,Name FROM Pricebook2];

    // List<Product2> perfumes = [SELECT Id FROM Product2 WHERE IsActive = true AND Family = 'Perfumes'];
    // List<Variant__c> allVariants [SELECT Id,Capacity__c,Price__c,Product__c FROM Variant__c];
    // for(Variant__c variant : variants){
    //     PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = product.Id, UnitPrice = product.minPrice__c, IsActive = true);
    //     insert standardPBE;
    // }
}