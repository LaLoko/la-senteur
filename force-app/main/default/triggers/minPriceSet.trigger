trigger minPriceSet on Variant__c (after insert,after update,after delete) {
    List<AggregateResult> allPrices = [SELECT MIN(Price__c),Product__c FROM Variant__c GROUP BY Product__c];
    Map<Id,Decimal> prices = new Map<Id, Decimal>();
    for (AggregateResult variant : allPrices){
        prices.put((Id)variant.get('Product__c') ,(Decimal)variant.get('expr0'));
    }
    List<Product2> allProducts = [SELECT Id,minPrice__c FROM Product2];

    for(Product2 product : allProducts){
        product.minPrice__c = prices.get(product.Id);
    }
    update allProducts;
}