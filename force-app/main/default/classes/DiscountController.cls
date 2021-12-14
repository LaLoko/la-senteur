public class DiscountController {

    @AuraEnabled
    public static List<PricebookItemWrapper> getPricebookItems() {
        List<Variant__c> allVariants = [
                SELECT Id, Product__c, Capacity__c, Price__c
                FROM Variant__c
                ORDER BY Product__c, Capacity__c
        ];
        List<Product2> allProducts = [
                SELECT Id, Name, Designer__c, Gender__c
                FROM Product2
                WHERE Family = 'Perfumes' AND isActive = true
        ];
        List<Designer__c> allDesigners = [
                SELECT Id, Name
                FROM Designer__c
        ];

        List<PricebookItemWrapper> pricebookItems = new List<PricebookItemWrapper>();
        for (Variant__c variant : allVariants) {
            PricebookItemWrapper wrapper = new PricebookItemWrapper();
            wrapper.selected = false;
            wrapper.variantId = variant.Id;
            wrapper.price = variant.Price__c;
            wrapper.capacity = variant.Capacity__c;

            for (Product2 product : allProducts) {
                if (variant.Product__c == product.Id) {
                    wrapper.name = product.Name;
                    wrapper.gender = product.Gender__c;
                    wrapper.productId = product.Id;
                    for (Designer__c designer : allDesigners) {
                        if (product.Designer__c == designer.Id) {
                            wrapper.designer = designer.Name;
                        }
                    }
                }
            }
            pricebookItems.add(wrapper);
        }
        return pricebookItems;
    }

    @AuraEnabled
    public static String createNewPricebook(String products, String name, String description, Date startDate, Date endDate) {
        List<PricebookItemWrapper> productsList = PricebookItemWrapper.parse(products);

        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = name;
        pricebook.Description = description;
        pricebook.ValidFrom = startDate;
        pricebook.ValidTo = endDate;
        pricebook.isActive = true;
        insert pricebook;

        List<Pricebook_entry_variant__c> variants = new List<Pricebook_entry_variant__c>();

        for (PricebookItemWrapper item : productsList) {
            if (item.selected) {
                Pricebook_entry_variant__c variant = new Pricebook_entry_variant__c();
                variant.Price_Book__c = pricebook.Id;
                variant.New_price__c = item.price;
                variant.Variant__c = item.variantId;
                variants.add(variant);
            }
        }
        insert variants;
        return pricebook.Id;
    }

    @AuraEnabled
    public static List<Pricebook2> getCustomPricebooks() {
        return [
                SELECT Id, Name, ValidFrom, ValidTo, IsStandard, isActive
                FROM Pricebook2
                WHERE Name NOT IN('Standard Price Book', 'Standard')
        ];
    }

    @AuraEnabled
    public static PricebookWrapper getPricebookDetails(Id pricebookId) {
        PricebookWrapper wrapper = new PricebookWrapper();
        wrapper.pricebook = [
                SELECT Id, Name, Description, ValidFrom, ValidTo, IsStandard, isActive
                FROM Pricebook2
                WHERE Id = :pricebookId
        ];
        wrapper.pricebookItems = getSelectedPricebookItems(pricebookId);
        return wrapper;
    }

    public static List<DetailPricebookItem> getSelectedPricebookItems(Id PricebookId) {
        List<Pricebook_entry_variant__c> entries = [
                SELECT Id, Price_Book__c, New_price__c, Variant__c
                FROM Pricebook_entry_variant__c
                WHERE Price_Book__c = :pricebookId
        ];

        List<Id> variantsIds = new List<Id>();
        for (Pricebook_entry_variant__c entry : entries) {
            variantsIds.add(entry.Variant__c);
        }
        List<Variant__c> variants = [
                SELECT Id, Capacity__c, Product__c
                FROM Variant__c
                WHERE Id IN :variantsIds
        ];

        List<Id> productsIds = new List<Id>();
        for (Variant__c variant : variants) {
            productsIds.add(variant.Product__c);
        }
        List<Product2> products = [
                SELECT Id, Name, Designer__c
                FROM Product2
                WHERE Id IN :productsIds
        ];

        List<Id> designersIds = new List<Id>();
        for (Product2 product : products) {
            designersIds.add(product.Designer__c);
        }
        List<Designer__c> designers = [
                SELECT Id, Name
                FROM Designer__c
                WHERE Id IN :designersIds
        ];

        List<DetailPricebookItem> detailPricebookItems = new List<DetailPricebookItem>();
        for (Pricebook_entry_variant__c entry : entries) {
            DetailPricebookItem wrapper = new DetailPricebookItem();
            wrapper.entry = entry;
            for (Variant__c variant : variants) {
                if (variant.Id == entry.Variant__c) {
                    wrapper.capacity = variant.Capacity__c;

                    for (Product2 product : products) {
                        if (product.Id == variant.Product__c) {
                            wrapper.productName = product.Name;

                            for (Designer__c designer : designers) {
                                if (designer.Id == product.Designer__c) {
                                    wrapper.designerName = designer.Name;
                                }
                            }
                        }
                    }
                }
            }
            detailPricebookItems.add(wrapper);
        }
        return detailPricebookItems;
    }

    @AuraEnabled
    public static PricebookWrapper saveEditedPricebook(Id pricebookId, String name, String description, Date validfrom, Date validto, Boolean active) {
        Pricebook2 pricebook = [
                SELECT Id, Name, Description, ValidFrom, ValidTo, IsStandard, isActive
                FROM Pricebook2
                WHERE Id = :pricebookId
        ];
        pricebook.Name = name;
        pricebook.Description = description;
        pricebook.ValidFrom = validfrom;
        pricebook.ValidTo = validto;
        pricebook.isActive = active;
        update pricebook;

        return getPricebookDetails(pricebookId);
    }

    @AuraEnabled
    public static List<Pricebook2> deleteSelectedPricebook(Id pricebookId) {
        Pricebook2 pricebook = [
                SELECT Id
                FROM Pricebook2
                WHERE Id = :pricebookId
        ];
        delete pricebook;

        List<Pricebook_entry_variant__c> entries = [
                SELECT Id, Price_Book__c
                FROM Pricebook_entry_variant__c
                WHERE Price_Book__c = :pricebookId
        ];
        delete entries;

        return getCustomPricebooks();
    }

    @AuraEnabled
    public static PricebookWrapper deleteEntry(Id entryId, Id pricebookId) {
        Pricebook_entry_variant__c entry = [
                SELECT Id
                FROM Pricebook_entry_variant__c
                WHERE Id = :entryId
                LIMIT 1
        ];
        delete entry;

        return getPricebookDetails(pricebookId);
    }

    @AuraEnabled
    public static PricebookWrapper editEntry(String entries, Id pricebookId) {
        List<Pricebook_entry_variant__c> originalEntries = [
                SELECT Id, New_price__c, Price_Book__c
                FROM Pricebook_entry_variant__c
                WHERE Price_Book__c = :pricebookId
        ];
        List<DetailPricebookItem> inEntries = DetailPricebookItem.parse(entries);

        for (Pricebook_entry_variant__c entry : originalEntries) {
            for (DetailPricebookItem item : inEntries) {
                if (entry.Id == item.entry.Id) {
                    entry.New_price__c = item.entry.New_price__c;
                }
            }
        }
        update originalEntries;

        return getPricebookDetails(pricebookId);
    }

    class PricebookWrapper {
        @AuraEnabled
        public Pricebook2 pricebook;
        @AuraEnabled
        public List<DetailPricebookItem> pricebookItems;

        public PricebookWrapper() {
        }
    }
}