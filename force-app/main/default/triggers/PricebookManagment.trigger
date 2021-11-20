trigger PricebookManagment on Product2 (after insert,after update) {
    List<Pricebook2> priceBooks = [SELECT Id FROM Pricebook2];
    if(priceBooks.size() > 0){

    }else{
    Pricebook2 pb = new Pricebook2(Name = 'Perfume Pricebook', Description = 'Price Book for perfumes', IsActive = true );
    insert pb;
    Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
    List<Product2> perfumes = [SELECT Id FROM Product2 WHERE IsActive = true AND Family = 'Perfumes'];
    for(Product2 product : perfumes){
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = product.Id, UnitPrice = product.minPrice__c, IsActive = true);
        insert standardPBE;
    }
    }
}