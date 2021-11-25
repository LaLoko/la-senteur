public class DiscountController {

    @AuraEnabled
    public static List<PricebookItemWrapper> getPricebookItems(){
        List<Variant__c> allVariants = [SELECT Id,Product__c,Capacity__c,Price__c FROM Variant__c ORDER BY Product__c];
        List<Product2> allProducts = [SELECT Id,Name, Designer__c,Gender__c FROM Product2 WHERE Family = 'Perfumes' AND isActive = true];
        List<Designer__c> allDesigners = [SELECT Id, Name FROM Designer__c];

        List<PricebookItemWrapper> out = new List<PricebookItemWrapper>();
        for(Variant__c variant : allVariants){
            PricebookItemWrapper wrapper = new PricebookItemWrapper();
            wrapper.selected = false;
            wrapper.variantId = variant.Id;
            wrapper.price = variant.Price__c;
            wrapper.capacity = variant.Capacity__c;

            for(Product2 product : allProducts){
                if(variant.Product__c == product.Id){
                    wrapper.name = product.Name;
                    wrapper.gender = product.Gender__c;
                    wrapper.productId = product.Id;
                    for(Designer__c designer : allDesigners){
                        if(product.Designer__c == designer.Id){
                            wrapper.designer = designer.Name;
                        }
                    }
                }
            }
            out.add(wrapper);
        }
        System.debug(out);
        return out;
    }

    @AuraEnabled
    public static Boolean createNewPricebook(String products,String name,String description,Date startDate,Date endDate){
        List<PricebookItemWrapper> productsList = PricebookItemWrapper.parse(products);
        System.debug(productsList);

        List<Pricebook2> pricebooks = [SELECT Id,isActive,IsStandard FROM Pricebook2 WHERE isStandard != true];
        for(Pricebook2 pricebook : pricebooks){
            pricebook.isActive = false;
        }
        update pricebooks;

        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = name;
        pricebook.Description = description;
        pricebook.ValidFrom = startDate;
        pricebook.ValidTo = endDate;
        pricebook.isActive = true;
        insert pricebook;


        List<Pricebook_entry_variant__c> variants = new List<Pricebook_entry_variant__c>();

        for(PricebookItemWrapper item : productsList){
            if(item.selected){
                Pricebook_entry_variant__c variant = new Pricebook_entry_variant__c();
                variant.Price_Book__c = pricebook.Id;
                variant.New_price__c = item.price;
                variant.Variant__c = item.variantId;
                variants.add(variant);
            }
        }
        insert variants;
        return true;

        // List<PricebookEntry> entries = new List<PricebookEntry>();

        // for(PricebookItemWrapper item : products){
        //     if(item.selected){
        //         if(entries.size()>0){
        //             for(PricebookEntry entry : entries){
        //                 if(entry.Product2Id == item.)
        //             }
        //         }else{
        //             PricebookEntry entry = new PricebookEntry();
        //             entry.Pricebook2Id = pricebook.Id;
        //             entry.Product2Id = item.productId;
        //             entry.IsActive = true;
        //             insert entry;

        //             Pricebook_entry_variant__c variant = 


        //             entry.Pricebook_entry_variant__c = variant.Id;
        //             update entry
        //         }

        //     }
        // }
   
    }
}
