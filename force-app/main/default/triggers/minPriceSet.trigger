trigger minPriceSet on Variant__c (after insert, after update, after delete) {
    Pricebook2 standard = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];

    if (Trigger.isDelete) {
        List<Id> delVariantIds = new List<Id>();
        for (Variant__c variant : Trigger.old) {
            delVariantIds.add(variant.Id);
        }
        List<Pricebook_entry_variant__c> variantsToDel = [SELECT Id FROM Pricebook_entry_variant__c WHERE Variant__c IN :delVariantIds];
        delete variantsToDel;
    }
    List<Id> productIdsWhichIsNotInStandard;

    if (Trigger.isInsert) {

        List<Id> productIds = new List<Id>();
        for (Variant__c variant : Trigger.new) {
            productIds.add(variant.Product__c);
        }
        List<PricebookEntry> entries = [SELECT Id, Pricebook2Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standard.Id AND Product2Id IN :productIds];
        if (entries.size() == 0) {
            productIdsWhichIsNotInStandard = productIds;
        } else {
            for (Variant__c variant : Trigger.new) {
                for (PricebookEntry entry : entries) {
                    if (variant.Product__c == entry.Product2Id && variant.Price__c < entry.UnitPrice) {
                        entry.UnitPrice = variant.Price__c;
                        update entry;
                    }
                }
            }
        }
    }
    List<AggregateResult> allPrices = [SELECT MIN(Price__c),Product__c FROM Variant__c GROUP BY Product__c];
    Map<Id, Decimal> prices = new Map<Id, Decimal>();
    for (AggregateResult variant : allPrices) {
        prices.put((Id) variant.get('Product__c'), (Decimal) variant.get('expr0'));
    }
    List<Product2> allProducts = [SELECT Id,minPrice__c, IsActive,Family FROM Product2 WHERE Family = 'Perfumes'];

    for (Product2 product : allProducts) {
        if (productIdsWhichIsNotInStandard != null) {
            for (Id id : productIdsWhichIsNotInStandard) {
                if (id == product.Id) {
                    PricebookEntry entry = new PricebookEntry();
                    entry.Product2Id = id;
                    entry.UnitPrice = prices.get(id);
                    entry.Pricebook2Id = standard.Id;
                    insert entry;
                }
            }
        }

        if (product.minPrice__c == null) {
            product.minPrice__c = prices.get(product.Id);
        }
        if (prices.get(product.Id) < product.minPrice__c) {
            product.minPrice__c = prices.get(product.Id);
        }
    }
    update allProducts;

    List<Variant__c> allVariants = [SELECT Id, Product__c FROM Variant__c];
    for (Product2 product : allProducts) {
        Boolean active = false;
        for (Variant__c variant : allVariants) {
            if (variant.Product__c == product.Id) {
                active = true;
            }
        }
        if (!active) {
            product.IsActive = false;
            product.minPrice__c = null;
            update product;
        }
    }
}