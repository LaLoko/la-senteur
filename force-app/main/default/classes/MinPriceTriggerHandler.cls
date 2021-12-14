public class MinPriceTriggerHandler {
    Pricebook2 standard;
    List<Id> productIdsWhichIsNotInStandard;

    public MinPriceTriggerHandler() {
        standard = [
            SELECT Id
            FROM Pricebook2
            WHERE IsStandard = true
    ];
    }

    public void handleDelete(List<Variant__c> variants) {
        List<Id> delVariantIds = new List<Id>();
        for (Variant__c variant : variants) {
            delVariantIds.add(variant.Id);
        }
        List<Pricebook_entry_variant__c> variantsToDel = [
                SELECT Id
                FROM Pricebook_entry_variant__c
                WHERE Variant__c IN :delVariantIds
        ];
        delete variantsToDel;
        handleRest();
    }

    public void handleInsert(List<Variant__c> variants) {
        List<Id> productIds = new List<Id>();

        for (Variant__c variant : variants) {
            productIds.add(variant.Product__c);
        }
        List<PricebookEntry> entries = [
                SELECT Id, Pricebook2Id, Product2Id, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :standard.Id AND Product2Id IN :productIds
        ];
        if (entries.size() == 0) {
            productIdsWhichIsNotInStandard = productIds;
        } else {
            for (Variant__c variant : variants) {
                for (PricebookEntry entry : entries) {
                    if (variant.Product__c == entry.Product2Id && variant.Price__c < entry.UnitPrice) {
                        entry.UnitPrice = variant.Price__c;
                        update entry;
                    }
                }
            }
        }
        handleRest();
    }
    
    public void handleRest() {
     
        List<AggregateResult> allPrices = [
                SELECT MIN(Price__c),Product__c
                FROM Variant__c
                GROUP BY Product__c
        ];
        Map<Id, Decimal> prices = new Map<Id, Decimal>();
        for (AggregateResult variant : allPrices) {
            prices.put((Id) variant.get('Product__c'), (Decimal) variant.get('expr0'));
        }
        List<Product2> allProducts = [
                SELECT Id, minPrice__c, IsActive,Family
                FROM Product2
                WHERE Family = 'Perfumes'
        ];

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

        List<Variant__c> allVariants = [
                SELECT Id, Product__c
                FROM Variant__c
        ];
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
}
