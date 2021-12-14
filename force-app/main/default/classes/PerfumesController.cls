public without sharing class PerfumesController {

    @AuraEnabled(cacheable=true)
    public static List<PerfumeWrapper> getAllPerfumes(String type, String sortType, String designersFilter,
            String accords, String topNotes, String middleNotes, String baseNotes) {
        List<Product2> perfumesList = new List<Product2>();

        String query = 'SELECT Id, Name, Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c, minPrice__c' +
                +' FROM Product2';

        if (type == 'male-perfumes') {
            query += ' WHERE Gender__c LIKE \'MALE\' ';
        } else if (type == 'female-perfumes') {
            query += ' WHERE Gender__c LIKE \'FEMALE\' ';
        } else {
            query += ' WHERE Gender__c LIKE \'UNISEX\' ';
        }

        query += ' AND Family = \'Perfumes\' ';

        if (designersFilter != null) {
            List<String> designersList = designersFilter.deleteWhitespace().split(',');
            List<Id> designersIds = new List<Id>();
            List<Designer__c> allDesigners = [
                    SELECT Id, Name
                    FROM Designer__c
            ];

            for (String item : designersList) {
                for (Designer__c designer : allDesigners) {
                    if (item == designer.Name.deleteWhitespace()) {
                        designersIds.add(designer.Id);
                    }
                }
            }
            query += ' AND Designer__c IN :designersIds ';
        }

        if (accords != null && accords != '') {
            String condition = conditionFromList(accords.split(','));
            query += ' AND Main_accords__c INCLUDES (' + condition + ') ';
        }
        if (topNotes != null && topNotes != '') {
            String condition = conditionFromList(topNotes.split(','));
            query += ' AND Top_Notes__c INCLUDES (' + condition + ') ';
        }
        if (middleNotes != null && middleNotes != '') {
            String condition = conditionFromList(middleNotes.split(','));
            query += ' AND Middle_Notes__c INCLUDES (' + condition + ') ';
        }
        if (baseNotes != null && baseNotes != '') {
            String condition = conditionFromList(baseNotes.split(','));
            query += ' AND Base_Notes__c INCLUDES (' + condition + ') ';
        }

        if (sortType != null && sortType.contains('Name ASC')) {
            query += ' ORDER BY Name ASC';
        } else if (sortType != null && sortType.contains('Name DESC')) {
            query += ' ORDER BY Name DESC';
        } else if (sortType != null && sortType.contains('Price ASC')) {
            query += ' ORDER BY minPrice__c ASC';
        } else if (sortType != null && sortType.contains('Price DESC')) {
            query += ' ORDER BY minPrice__c DESC';
        } else if (sortType != null && sortType.contains('Score ASC')) {
            query += ' ORDER BY Score__c ASC';
        } else if (sortType != null && sortType.contains('Score DESC')) {
            query += ' ORDER BY Score__c DESC';
        } else {
            query += ' ORDER BY Name ASC';
        }
        perfumesList = database.query(query);

        perfumesList = popularOrder(perfumesList, sortType);

        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [
                SELECT Id, Name
                FROM Designer__c
                WHERE Id IN :ids
        ];
        Map<Id, String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers) {
            designersKeys.put(designer.Id, designer.Name);
        }

        List<PerfumeWrapper> perfumesWrapperList = new List<PerfumeWrapper>();
        for (Product2 perfume : perfumesList) {
            PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designerName = designersKeys.get(perfume.Designer__c);
            wrapper.score = perfume.Score__c;
            wrapper.topNotes = perfume.Top_Notes__c;
            wrapper.middleNotes = perfume.Middle_Notes__c;
            wrapper.baseNotes = perfume.Base_Notes__c;
            wrapper.gender = perfume.Gender__c;
            wrapper.mainAccords = perfume.Main_Accords__c;
            wrapper.photo = perfume.Photo__c;
            wrapper.price = getPerfumePrice(perfume.Id);
            perfumesWrapperList.add(wrapper);
        }
        return perfumesWrapperList;
    }

    public static List<Product2> popularOrder(List<Product2> perfumesList, String sortType) {
        if (sortType != null && sortType.contains('popular')) {
            List<AggregateResult> orderItems;

            if (sortType.contains('DESC')) {
                orderItems = [
                        SELECT Product2Id, COUNT(Id)
                        FROM OrderItem
                        GROUP BY Product2Id
                        ORDER BY COUNT(Id) DESC
                ];
            } else {
                orderItems = [
                        SELECT Product2Id, COUNT(Id)
                        FROM OrderItem
                        GROUP BY Product2Id
                        ORDER BY COUNT(Id) ASC
                ];
            }
            List<Product2> products = new List<Product2>();
            for (AggregateResult item : orderItems) {
                for (Product2 product : perfumesList) {
                    if (item.get('Product2Id') == product.Id) {
                        products.add(product);
                    }
                }
            }

            for (Product2 product : perfumesList) {
                Boolean notInList = true;
                for (Product2 inOut : products) {
                    if (inOut.Id == product.Id) {
                        notInList = false;
                    }
                }
                if (notInList) {
                    products.add(product);
                }
            }
            return products;
        } else {
            return perfumesList;
        }
    }

    public static String getPerfumePrice(Id perfumeId) {
        List<Variant__c> variants = getVariantsWithPricebook([
                SELECT Price__c, InPromo__c
                FROM Variant__c
                WHERE Product__c = :perfumeId
        ]);
        Decimal newPrice = variants.get(0).Price__c;
        Boolean promo = false;

        for (Variant__c variant : variants) {
            if (variant.Price__c < newPrice) {
                newPrice = variant.Price__c;
            }
            if (variant.InPromo__c) {
                promo = true;
            }
        }
        Decimal minPrice = [
                SELECT UnitPrice
                FROM PricebookEntry
                WHERE Product2Id = :perfumeId
                LIMIT 1
        ].UnitPrice;
        if (!promo) {
            return String.valueOf(minPrice);
        } else {
            return 'SALE ' + String.valueOf(newPrice);
        }
    }

    public static String conditionFromList(List<String> toConvert) {
        String condition = '';
        for (string val : toConvert) {
            condition += ',\'' + val + '\'';
        }
        return condition.substring(1, condition.length());
    }

    @AuraEnabled
    public static List<PerfumeWrapper> getPerfumesByKey(String key) {
        System.debug('|' + key + '|');
        if (key == null || key.deleteWhitespace() == '') {
            return null;
        }
        key = '%' + key + '%';
        List<Product2> perfumesList = [
                SELECT Id, Name, Photo__c, Score__c, Top_Notes__c, Main_accords__c, Middle_Notes__c, Gender__c, Designer__c, Base_Notes__c, minPrice__c
                FROM Product2
                WHERE Family = 'Perfumes' AND Name LIKE :key
        ];
        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> currDesigners = [
                SELECT Id, Name
                FROM Designer__c
                WHERE Id IN :ids
        ];
        Map<Id, String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : currDesigners) {
            designersKeys.put(designer.Id, designer.Name);
        }

        List<PerfumeWrapper> out = new List<PerfumeWrapper>();
        for (Product2 perfume : perfumesList) {
            PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designerName = designersKeys.get(perfume.Designer__c);
            wrapper.score = perfume.Score__c;
            wrapper.topNotes = perfume.Top_Notes__c;
            wrapper.middleNotes = perfume.Middle_Notes__c;
            wrapper.baseNotes = perfume.Base_Notes__c;
            wrapper.gender = perfume.Gender__c;
            wrapper.mainAccords = perfume.Main_Accords__c;
            wrapper.photo = perfume.Photo__c;
            wrapper.price = getPerfumePrice(perfume.Id);
            out.add(wrapper);
        }

        return out;
    }

    @AuraEnabled
    public static List<BestsellerWrapper> getBestsellers() {
        List<AggregateResult> orderItems = [
                SELECT Product2Id, COUNT(Id)
                FROM OrderItem
                GROUP BY Product2Id
                ORDER BY COUNT(Id) DESC
        ];
        List<Product2> allPerfumes = [
                SELECT Id, Name, Photo__c, Designer__c, minPrice__c
                FROM Product2
                WHERE Family = 'Perfumes'
        ];
        Integer currNumber = 1;
        List<Product2> perfumesList = new List<Product2>();
        for (AggregateResult item : orderItems) {
            for (Product2 product : allPerfumes) {
                if (item.get('Product2Id') == product.Id) {
                    perfumesList.add(product);
                    currNumber++;
                }
                if (currNumber == 6) break;
            }
        }

        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [
                SELECT Id, Name
                FROM Designer__c
                WHERE Id IN :ids
        ];
        Map<Id, String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers) {
            designersKeys.put(designer.Id, designer.Name);
        }

        List<BestsellerWrapper> out = new List<BestsellerWrapper>();
        for (Product2 perfume : perfumesList) {
            BestsellerWrapper wrapper = new BestsellerWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designer = designersKeys.get(perfume.Designer__c);
            wrapper.photo = perfume.Photo__c;
            wrapper.bestsellerName = wrapper.designer + ' ' + wrapper.name;
            wrapper.price = getPerfumePrice(perfume.Id) + ' €';
            wrapper.URL = 'https://lasenteur-developer-edition.eu40.force.com/s/perfume-detail?id=' + perfume.Id;
            out.add(wrapper);
        }
        return out;
    }

    @AuraEnabled(cacheable=false)
    public static PerfumeWrapper getDetailPerfume(String id) {
        List<Product2> perfumesList = [
                SELECT Id, Name, Photo__c, Score__c, Top_Notes__c, Main_accords__c, Middle_Notes__c, Gender__c, Designer__c, Base_Notes__c
                FROM Product2
                WHERE Id = :id
        ];
        Product2 perfume = perfumesList.get(0);

        List<Variant__c> variants = [
                SELECT Price__c, Capacity__c, InPromo__c
                FROM Variant__c
                WHERE Product__c = :perfume.Id
                ORDER BY Capacity__c
        ];
        variants = getVariantsWithPricebook(variants);

        List<String> variantsMap = new List<String>();
        for (Variant__c variant : variants) {
            if (variant.InPromo__c) {
                variantsMap.add(variant.Capacity__c + ' ml - ' + variant.Price__c + ' € SALE');

            } else {
                variantsMap.add(variant.Capacity__c + ' ml - ' + variant.Price__c + ' €');
            }
        }

        PerfumeWrapper wrapper = new PerfumeWrapper();
        wrapper.Id = perfume.Id;
        wrapper.name = perfume.Name;
        wrapper.designer = perfume.Designer__c;
        wrapper.designerName = [
                SELECT Name
                FROM Designer__c
                WHERE Id = :perfume.Designer__c
        ].get(0).Name;
        wrapper.score = perfume.Score__c;
        wrapper.topNotes = perfume.Top_Notes__c;
        wrapper.middleNotes = perfume.Middle_Notes__c;
        wrapper.baseNotes = perfume.Base_Notes__c;
        wrapper.gender = perfume.Gender__c;
        wrapper.mainAccords = perfume.Main_Accords__c;
        wrapper.photo = perfume.Photo__c;
        wrapper.variants = variantsMap;
        wrapper.images = [
                SELECT Id, URL__c
                FROM Product_Image__c
                WHERE Product__c = :id
                ORDER BY Id
        ];
        return wrapper;
    }

    public static List<Variant__c> getVariantsWithPricebook(List<Variant__c> preVariants) {
        List<Pricebook2> pricebooks = [
                SELECT Id
                FROM Pricebook2
                WHERE IsStandard = false AND IsActive = true
        ];
        List<Id> pricebooksIds = new List<Id>();
        for (Pricebook2 var : pricebooks) {
            pricebooksIds.add(var.Id);
        }

        List<Id> variantIds = new List<Id>();
        for (Variant__c var : preVariants) {
            variantIds.add(var.Id);
        }
        List<Pricebook_entry_variant__c> variants = [
                SELECT Id, Price_Book__c, New_Price__c, Variant__c
                FROM Pricebook_entry_variant__c
                WHERE Price_Book__c IN :pricebooksIds AND Variant__c IN :variantIds
        ];

        if (variants.size() > 0) {
            for (Variant__c variant : preVariants) {
                Decimal min;
                for (Pricebook_entry_variant__c priceVariant : variants) {
                    if (priceVariant.Variant__c == variant.Id) {
                        if (min == null) {
                            min = priceVariant.New_Price__c;
                        }
                        if (priceVariant.New_Price__c < min) {
                            min = priceVariant.New_Price__c;
                        }
                    }
                }
                if (min != null) {
                    variant.Price__c = min;
                    variant.InPromo__c = true;
                }
            }
            return preVariants;
        } else {
            return preVariants;
        }
    }

    @AuraEnabled
    public static PerfumeWrapper addReview(String text, Integer score, Id perfume) {
        try {
            String userId = System.UserInfo.getUserId();
            User currUser = [SELECT Id, Name FROM User WHERE Id = :userId];

            insert new Perfume_Review__c(Review__c = text, Score__c = score, Username__c = currUser.Name, Product__c = perfume);

            List<Perfume_Review__c> reviews = [Select Score__c FROM Perfume_Review__c WHERE Product__c = :perfume];
            List<Product2> perfumeToUpdate = [SELECT Score__c FROM Product2 WHERE Id = :perfume];

            perfumeToUpdate.get(0).Score__c = getNewPerfumeScore(perfume) / reviews.size();
            update perfumeToUpdate;
            return getDetailPerfume(perfume);
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static List<ReviewWrapper> getReviews(Id id) {
        List<Perfume_Review__c> reviews = [
                SELECT Review__c, Score__c, Username__c, Created_date__c, CreatedById
                FROM Perfume_Review__c
                WHERE Product__c = :id
        ];
        List<ReviewWrapper> reviewsWrapperList = new List<ReviewWrapper>();
        String userId = System.UserInfo.getUserId();

        for (Perfume_Review__c review : reviews) {
            ReviewWrapper wrapper = new ReviewWrapper();
            wrapper.Id = review.Id;
            wrapper.score = review.Score__c;
            wrapper.scoreName = wrapper.scoreNames.get(review.Score__c);
            wrapper.text = review.Review__c;
            wrapper.currUserReview = review.CreatedById == userId ? true : false;
            wrapper.username = review.Username__c;
            wrapper.createdTime = review.Created_date__c;
            reviewsWrapperList.add(wrapper);
        }
        return reviewsWrapperList;
    }

    @AuraEnabled
    public static Boolean userCreatedComment(Id id) {
        String userId = System.UserInfo.getUserId();
        return [
                SELECT Id
                FROM Perfume_Review__c
                WHERE CreatedById = :userId AND Product__c = :id
        ].size() > 0;
    }

    @AuraEnabled
    public static PerfumeWrapper removeComment(Id perfumeId) {
        try {
            String userId = System.UserInfo.getUserId();
            delete [
                    SELECT Id
                    FROM Perfume_Review__c
                    WHERE CreatedById = :userId AND Product__c = :perfumeId
            ];

            Product2 perfumeToUpdate = [
                    SELECT Score__c
                    FROM Product2
                    WHERE Id = :perfumeId
                    LIMIT 1
            ];
            Integer reviewsSize = [
                    Select Score__c
                    FROM Perfume_Review__c
                    WHERE Product__c = :perfumeId
            ].size();

            if (reviewsSize == 0) {
                perfumeToUpdate.Score__c = 0;
            } else {
                perfumeToUpdate.Score__c = getNewPerfumeScore(perfumeId) / reviewsSize;
            }

            update perfumeToUpdate;
            return getDetailPerfume(perfumeId);

        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static ReviewWrapper getReviewToEdit(Id perfumeId) {
        String userId = System.UserInfo.getUserId();
        Perfume_Review__c review = [
                SELECT Id, Review__c, Score__c
                FROM Perfume_Review__c
                WHERE CreatedById = :userId AND Product__c = :perfumeId
                LIMIT 1
        ];
        List<ReviewWrapper> out = new List<ReviewWrapper>();

        ReviewWrapper wrapper = new ReviewWrapper();
        wrapper.Id = review.Id;
        wrapper.score = review.Score__c;
        wrapper.scoreName = wrapper.scoreNames.get(review.Score__c);
        wrapper.text = review.Review__c;

        return wrapper;
    }

    @AuraEnabled
    public static PerfumeWrapper updateReview(String text, Integer score, Id perfumeId) {
        try {
            String userId = System.UserInfo.getUserId();

            Perfume_Review__c review = [
                    SELECT Id, Review__c, Score__c
                    FROM Perfume_Review__c
                    WHERE CreatedById = :userId AND Product__c = :perfumeId
                    LIMIT 1
            ];
            review.Review__c = text;
            review.Score__c = score;
            review.Created_date__c = Datetime.now();
            update review;

            Product2 perfumeToUpdate = [
                    SELECT Score__c
                    FROM Product2
                    WHERE Id = :perfumeId
                    LIMIT 1
            ];

            perfumeToUpdate.Score__c = getNewPerfumeScore(perfumeId) / [
                    Select Score__c
                    FROM Perfume_Review__c
                    WHERE Product__c = :perfumeId
            ].size();
            update perfumeToUpdate;

            return getDetailPerfume(perfumeId);
        } catch (Exception e) {
            return null;
        }
    }

    public static Decimal getNewPerfumeScore(Id perfumeId) {
        List<Perfume_Review__c> reviews = [
                Select Score__c
                FROM Perfume_Review__c
                WHERE Product__c = :perfumeId
        ];

        Double newScore;
        if (reviews.size() == 0) {
            return 0;
        } else {
            Double scoreSum = 0;
            for (Perfume_Review__c review : reviews) {
                scoreSum += review.Score__c;
            }
            return scoreSum;
        }
    }

    @AuraEnabled
    public static Boolean addItemToCart(Id perfumeId, String variant, String designer, String perfumeName, String perfumePhoto) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        try {
            if (!sessionPart.contains('cart')) {
                List<CartItem> cart = new List<CartItem>();
                cart.add(new CartItem(perfumeId, variant, designer, perfumeName, perfumePhoto));
                sessionPart.put('cart', cart);
                Decimal currPrice = getPriceFromVariant(variant);
                sessionPart.put('total', currPrice);
            } else {
                List<CartItem> cart = (List<CartItem>) sessionPart.get('cart');
                cart.add(new CartItem(perfumeId, variant, designer, perfumeName, perfumePhoto));
                sessionPart.put('cart', cart);
                Decimal currPrice = getPriceFromVariant(variant) + (Decimal) sessionPart.get('total');
                sessionPart.put('total', currPrice);
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static void deleteFromCart(Integer id) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');

        List<CartItem> currCart = (List<CartItem>) sessionPart.get('cart');
        Decimal total = (Decimal) sessionPart.get('total') - getPriceFromVariant(currCart.get(id).variant);
        currCart.remove(id);

        sessionPart.put('cart', currCart);
        sessionPart.put('total', total);
    }

    @AuraEnabled
    public static Decimal getCartTotalPrice() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        return (Decimal) sessionPart.get('total');
    }

    @AuraEnabled
    public static List<CartItem> getCart() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        List<CartItem> cart = (List<CartItem>) sessionPart.get('cart');
        return cart;
    }

    public static Decimal getPriceFromVariant(String variant) {
        if (variant.contains('SALE')) {
            return decimal.valueOf(variant.split(' ')[3].deleteWhitespace());
        } else {
            String str1 = variant.split('-')[1];
            String str2 = str1.substring(1, str1.length() - 1);
            return decimal.valueOf(str2.deleteWhitespace());
        }
    }

    public static Integer getCapacityFromVariant(String variant) {
        if (variant.contains('SALE')) {
            return Integer.valueOf(variant.split(' ')[0].deleteWhitespace());
        } else {
            String str1 = variant.split('-')[0];
            String str2 = str1.split(' ')[0];
            return Integer.valueOf(str2.deleteWhitespace());
        }
    }

    @AuraEnabled
    public static void addShippmentInfo(String state, String city, String country, String zip, String street) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        ShippmentInfo info = new ShippmentInfo(state, city, country, zip, street);
        sessionPart.put('shippmentInfo', info);
    }

    @AuraEnabled
    public static void addInvoiceData(String companyName, String state, String city, String country, String zip, String street) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        ShippmentInfo info = new ShippmentInfo(companyName, state, city, country, zip, street);
        sessionPart.put('invoiceData', info);
    }

    @AuraEnabled
    public static ShippmentInfo getShippingInfo() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        return (ShippmentInfo) sessionPart.get('shippmentInfo');
    }

    @AuraEnabled
    public static string getCartItemId(Integer index) {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        List<CartItem> cart = (List<CartItem>) sessionPart.get('cart');
        return cart.get(index).id;
    }

    public static void clearBasket() {
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        sessionPart.put('shippmentInfo', null);
        sessionPart.put('cart', null);
        sessionPart.put('total', null);
        sessionPart.put('invoiceData', null);
    }

    @AuraEnabled
    public static List<String> getAllDesigners() {
        List<Designer__c> designers = [
                Select Name
                FROM Designer__c
        ];
        List<String> out = new List<String>();

        for (Designer__c designer : designers) {
            out.add(designer.Name);
        }
        return out;
    }

    @AuraEnabled
    public static List<String> getAllAccords() {
        Schema.DescribeFieldResult fieldResult = Product2.Main_accords__c.getDescribe();
        return getPicklistValues(fieldResult);
    }

    @AuraEnabled
    public static List<String> getAllNotes() {
        Schema.DescribeFieldResult fieldResult = Product2.Top_Notes__c.getDescribe();
        return getPicklistValues(fieldResult);
    }

    public static List<String> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
        List<String> pickListValuesList = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static ShippmentInfo getAddress() {
        String userId = System.UserInfo.getUserId();

        User user = [
                SELECT Id, ContactId
                FROM User
                WHERE Id = :userId
                LIMIT 1
        ];
        Contact contact = [
                SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                FROM Contact
                WHERE Id = :user.ContactId
                LIMIT 1
        ];
        ShippmentInfo info = new ShippmentInfo(contact.MailingState, contact.MailingCity, contact.MailingCountry, contact.MailingPostalCode, contact.MailingStreet);
        return info;
    }

    @AuraEnabled
    public static string getLastOrderId() {
        return [
                SELECT Id
                FROM Order
                ORDER BY Id DESC
                LIMIT 1
        ].Id;
    }

    @AuraEnabled
    public static Boolean createOrder() {
        try {
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
            List<CartItem> cart = (List<CartItem>) sessionPart.get('cart');
            ShippmentInfo shippmentInfo = (ShippmentInfo) sessionPart.get('shippmentInfo');
            ShippmentInfo invoiceData = (ShippmentInfo) sessionPart.get('invoiceData');

            String userId = System.UserInfo.getUserId();

            User user = [
                    SELECT Id, ContactId
                    FROM User
                    WHERE Id = :userId
                    LIMIT 1
            ];
            Contact contact = [
                    SELECT Id, AccountId
                    FROM Contact
                    WHERE Id = :user.ContactId
                    LIMIT 1
            ];
            Account accounts = [
                    SELECT Id
                    FROM Account
                    WHERE Id = :contact.AccountId
                    LIMIT 1
            ];
            Pricebook2 priceBook = [
                    SELECT Id
                    FROM Pricebook2
                    WHERE isStandard = true
                    LIMIT 1
            ];

            contact.MailingStreet = shippmentInfo.street;
            contact.MailingCity = shippmentInfo.city;
            contact.MailingState = shippmentInfo.state;
            contact.MailingPostalCode = shippmentInfo.zip;
            contact.MailingCountry = shippmentInfo.country;

            update contact;

            Order order = new Order(
                    AccountId = contact.AccountId,
                    ShipToContactId = contact.Id,
                    EffectiveDate = System.today(),
                    Status = 'Draft',
                    PriceBook2Id = priceBook.Id,
                    ContractId = '80009000000Z0GVAA0'
            );
            insert order;

            if (invoiceData != null) {
                Invoice__c invoice = new Invoice__c();
                invoice.Company_name__c = invoiceData.companyName;
                invoice.Order__c = order.Id;
                invoice.Shipping_City__c = invoiceData.city;
                invoice.Shipping_Country__c = invoiceData.country;
                invoice.Shipping_State__c = invoiceData.state;
                invoice.Shipping_Street__c = invoiceData.street;
                invoice.Shipping_Zip_Code__c = invoiceData.zip;
                insert invoice;
            }

            List<PricebookEntry> pricebookEntries = [SELECT Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id = :priceBook.Id];
            For (CartItem item : cart) {
                Decimal price = getPriceFromVariant(item.variant);
                Integer capacity = getCapacityFromVariant(item.variant);
                for (PricebookEntry entry : pricebookEntries) {
                    if (entry.Product2Id == item.id) {
                        OrderItem lineItem = new OrderItem();
                        lineItem.OrderId = order.id;
                        lineItem.Quantity = 1;
                        lineItem.UnitPrice = price;
                        lineItem.Product2id = item.id;
                        lineItem.PricebookEntryId = entry.id;
                        lineItem.Capacity__c = capacity;
                        insert lineItem;
                    }
                }
            }
            order.Status = 'Activated';
            update order;
            clearBasket();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static AdvWrapper getAdv() {
        AdvWrapper wrapper = new AdvWrapper();
        Pricebook2 pricebook = [
                SELECT Name
                FROM Pricebook2
                WHERE IsStandard = false AND isActive = true
                LIMIT 1
        ];
        wrapper.title = pricebook.Name;
        Product_Image__c image = [
                SELECT URL__c
                FROM Product_Image__c
                LIMIT 1
        ];
        wrapper.photo = image.URL__c;
        System.debug(wrapper);
        return wrapper;
    }

    public class AdvWrapper {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String photo;

        AdvWrapper() {
        }
    }

    class CartItem {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String variant { get; set; }
        @AuraEnabled
        public String designer { get; set; }
        @AuraEnabled
        public String perfumeName { get; set; }
        @AuraEnabled
        public String perfumePhoto { get; set; }

        CartItem() {
        }
        CartItem(Id id, String variant, String designer, String perfumeName, String perfumePhoto) {
            this.id = id;
            this.variant = variant;
            this.designer = designer;
            this.perfumeName = perfumeName;
            this.perfumePhoto = perfumePhoto;
        }
    }

    class BestsellerWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String photo { get; set; }
        @AuraEnabled
        public String designer { get; set; }
        @AuraEnabled
        public String designerName { get; set; }
        @AuraEnabled
        public String bestsellerName { get; set; }
        @AuraEnabled
        public String price { get; set; }
        @AuraEnabled
        public String URL { get; set; }

        BestsellerWrapper() {
        }
    }
}