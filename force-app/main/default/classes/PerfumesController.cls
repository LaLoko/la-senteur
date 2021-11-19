public with sharing class PerfumesController {

    @AuraEnabled(cacheable=true)
    public static List<PerfumeWrapper> getAllPerfumes(String type,String sortType,String designersFilter,
                String accords,String topNotes,String middleNotes, String baseNotes) {
        List<Product2> perfumesList = new List<Product2>();

        String query = 'SELECT Id, Name, Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c, minPrice__c'+
                +' FROM Product2';

        if (type == 'male-perfumes') {
            query += ' WHERE Gender__c LIKE \'MALE\' ';
        } else if (type == 'female-perfumes') {
            query += ' WHERE Gender__c LIKE \'FEMALE\' ';
        } else {
            query += ' WHERE Gender__c LIKE \'UNISEX\' ';
        }

        query += ' AND Family = \'Perfumes\' ';

        if(designersFilter != null){
            List<String> desginersList = designersFilter.deleteWhitespace().split(',');
            List<Id> designersIds = new List<Id>();
            List<Designer__c> allDesigners = [SELECT Id,Name FROM Designer__c];
            
            for(String item : desginersList){
                for(Designer__c designer : allDesigners){
                    if(item == designer.Name.deleteWhitespace()){
                        designersIds.add(designer.Id);
                    }
                }
            }
            query += ' AND Designer__c IN :designersIds ';
        }
        if(accords != null){
            String condition = conditionFromList(accords.split(','));
            query += ' AND Main_accords__c INCLUDES ('+condition+') ';
        }
        if(topNotes != null){
            String condition = conditionFromList(topNotes.split(','));
            query += ' AND Top_Notes__c INCLUDES ('+condition+') ';
        }
        if(middleNotes != null){
            String condition = conditionFromList(middleNotes.split(','));
            query += ' AND Middle_Notes__c INCLUDES ('+condition+') ';
        }
        if(baseNotes != null){
            String condition = conditionFromList(baseNotes.split(','));
            query += ' AND Base_Notes__c INCLUDES ('+condition+') ';
        }

        if(sortType != null && sortType.contains('Name ASC')){
            query += ' ORDER BY Name ASC';
        }else if(sortType != null && sortType.contains('Name DESC')){
            query += ' ORDER BY Name DESC';
        }else if(sortType!= null && sortType.contains('Price ASC')){
            query += ' ORDER BY minPrice__c ASC';
        }else if(sortType!= null && sortType.contains('Price DESC')){
            query += ' ORDER BY minPrice__c DESC';
        }else if(sortType!= null && sortType.contains('Score')){
            query += ' ORDER BY Score__c ASC';
        }else{
            query += ' ORDER BY Name ASC';
        }
     
        perfumesList = database.query(query);
        System.debug(perfumesList);

        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id, Name FROM Designer__c WHERE Id IN : ids];
        Map<Id,String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers){
            designersKeys.put(designer.Id,designer.Name);
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
            wrapper.price = perfume.minPrice__c;
            out.add(wrapper);
        }

        System.debug(out);
        return out;
    }
    public static String conditionFromList(List<String> toConvert){
        String condition = '';
        for(string val : toConvert) {
            condition += ',\'' + val + '\'';
         }
         return condition.substring(1, condition.length());
    }

    @AuraEnabled
    public static List<PerfumeWrapper> getPerfumesByKey(String key){
        key = '%'+key+'%';
        List<Product2> perfumesList = [
                SELECT Id, Name,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c, minPrice__c
                FROM Product2
                WHERE Family = 'Perfumes' AND Name LIKE :key
        ];
        System.debug(perfumesList);
        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> currDesigners = [SELECT Id, Name FROM Designer__c WHERE Id IN : ids];
        Map<Id,String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : currDesigners){
            designersKeys.put(designer.Id,designer.Name);
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
            wrapper.price = perfume.minPrice__c;
            out.add(wrapper);
        }

        System.debug(out);
        return out;
    }

    @AuraEnabled
    public static List<BestsellerWrapper> getBestsellers(){
        List<Product2> perfumesList = [
                SELECT Id, Name,Photo__c,Designer__c, minPrice__c
                FROM Product2
                WHERE Family = 'Perfumes'
                ORDER BY Score__c
                LIMIT 5
        ];

        List<Id> ids = new List<Id>();
        for (Product2 perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id, Name FROM Designer__c WHERE Id IN : ids];
        Map<Id,String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers){
            designersKeys.put(designer.Id,designer.Name);
        }

        List<BestsellerWrapper> out = new List<BestsellerWrapper>();
        for (Product2 perfume : perfumesList) {
            BestsellerWrapper wrapper = new BestsellerWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designer = designersKeys.get(perfume.Designer__c);
            wrapper.photo = perfume.Photo__c;
            wrapper.bestsellerName = wrapper.designer +' '+wrapper.name;
            wrapper.price = perfume.minPrice__c + ' €';
            wrapper.URL = 'https://lasenteur-developer-edition.eu40.force.com/s/perfume-detail?id='+perfume.Id;
            out.add(wrapper);
        }
        return out;
    }

    @AuraEnabled(cacheable=false)
    public static PerfumeWrapper getDetailPerfume(String id) {
        List<Product2> perfumesList = [
                SELECT Id, Name,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
                FROM Product2
                WHERE Id = :id
        ];
        Product2 perfume = perfumesList.get(0);

        List<Variant__c> variants = [SELECT Price__c,Capacity__c FROM Variant__c WHERE Product__c =: perfume.Id ORDER BY Capacity__c];
        List<String> variantsMap = new List<String>();
        for(Variant__c variant : variants){
            variantsMap.add(variant.Capacity__c+' ml - '+variant.Price__c+' €');
        }
        System.debug(perfume);

        PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designer = perfume.Designer__c;
            wrapper.designerName = [SELECT Name FROM Designer__c WHERE Id =: perfume.Designer__c].get(0).Name;
            wrapper.score = perfume.Score__c;
            wrapper.topNotes = perfume.Top_Notes__c;
            wrapper.middleNotes = perfume.Middle_Notes__c;
            wrapper.baseNotes = perfume.Base_Notes__c;
            wrapper.gender = perfume.Gender__c;
            wrapper.mainAccords = perfume.Main_Accords__c;
            wrapper.photo = perfume.Photo__c;
            wrapper.variants = variantsMap;
            wrapper.images = [SELECT Id, URL__c FROM Product_Image__c WHERE Product__c =: id ORDER BY Id];

        return wrapper;
    }
    @AuraEnabled
    public static PerfumeWrapper addReview(String text,Integer score,Id perfume){
        try {
            String userId = System.UserInfo.getUserId();
            User currUser = [SELECT Id, Name FROM User WHERE Id = :userId];

            insert new Perfume_Review__c(Review__c=text,Score__c=score,Username__c=currUser.Name,Product__c=perfume);

            List<Perfume_Review__c> reviews = [Select Score__c FROM Perfume_Review__c WHERE Product__c =: perfume];
            List<Product2> perfumeToUpdate = [SELECT Score__c FROM Product2 WHERE Id =: perfume];

            perfumeToUpdate.get(0).Score__c = getNewPerfumeScore(perfume)/reviews.size();
            update perfumeToUpdate;
            return getDetailPerfume(perfume);
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static List<ReviewWrapper> getReviews(Id id){
        List<Perfume_Review__c> reviews = [SELECT Review__c,Score__c,Username__c,Created_date__c FROM Perfume_Review__c WHERE Product__c =: id];
        List<ReviewWrapper> out = new List<ReviewWrapper>();

        for(Perfume_Review__c review : reviews){
            ReviewWrapper wrapper = new ReviewWrapper();
            wrapper.Id = review.Id;
            wrapper.score = review.Score__c;
            wrapper.scoreName = wrapper.scoreNames.get(review.Score__c);
            wrapper.text = review.Review__c;
            wrapper.username = review.Username__c;
            wrapper.createdTime = review.Created_date__c;
            out.add(wrapper);
        }
        return out;
    }
    
    @AuraEnabled
    public static Boolean userCreatedComment(Id id){
        String userId = System.UserInfo.getUserId();
        return [SELECT Id FROM Perfume_Review__c WHERE CreatedById =: userId AND Product__c =: id].size() > 0;
    }
    @AuraEnabled
    public static PerfumeWrapper removeComment(Id perfumeId){
        try {
            String userId = System.UserInfo.getUserId();

            delete [SELECT Id FROM Perfume_Review__c WHERE CreatedById =: userId AND Product__c =: perfumeId];

            Product2 perfumeToUpdate = [SELECT Score__c FROM Product2 WHERE Id =: perfumeId].get(0);
       
            Integer reviewsSize = [Select Score__c FROM Perfume_Review__c WHERE Product__c =: perfumeId].size();
            if(reviewsSize == 0){
                perfumeToUpdate.Score__c = 0;
            }else{
                perfumeToUpdate.Score__c = getNewPerfumeScore(perfumeId)/reviewsSize;
            }
            update perfumeToUpdate;
            System.debug(perfumeToUpdate);

            return getDetailPerfume(perfumeId);
        
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static ReviewWrapper getReviewToEdit(Id perfumeId){
        String userId = System.UserInfo.getUserId();
        Perfume_Review__c review = [SELECT Id,Review__c,Score__c  FROM Perfume_Review__c WHERE CreatedById =: userId AND Product__c =: perfumeId].get(0);
        List<ReviewWrapper> out = new List<ReviewWrapper>();

            ReviewWrapper wrapper = new ReviewWrapper();
            wrapper.Id = review.Id;
            wrapper.score = review.Score__c;
            wrapper.scoreName = wrapper.scoreNames.get(review.Score__c);
            wrapper.text = review.Review__c;
        
        return wrapper;
    }

    @AuraEnabled
    public static PerfumeWrapper updateReview(String text,Integer score,Id perfumeId){
        try {
            String userId = System.UserInfo.getUserId();

            Perfume_Review__c review = [SELECT Id,Review__c,Score__c  FROM Perfume_Review__c WHERE CreatedById =: userId AND Product__c =: perfumeId].get(0);
            review.Review__c = text;
            review.Score__c = score;
            review.Created_date__c = Datetime.now();
            update review;

            Product2 perfumeToUpdate = [SELECT Score__c FROM Product2 WHERE Id =: perfumeId].get(0);
       
           perfumeToUpdate.Score__c = getNewPerfumeScore(perfumeId)/[Select Score__c FROM Perfume_Review__c WHERE Product__c =: perfumeId].size();
           update perfumeToUpdate;

            return getDetailPerfume(perfumeId);
            
        } catch (Exception e) {
            return null;
        }
    }

    public static Decimal getNewPerfumeScore(Id perfumeId){
        List<Perfume_Review__c> reviews = [Select Score__c FROM Perfume_Review__c WHERE Product__c =: perfumeId];

        Double newScore;
        if(reviews.size() == 0){
             return 0;
        }else{
        Double scoreSum = 0;
        for(Perfume_Review__c review : reviews){
            scoreSum += review.Score__c;
        }
        return scoreSum;
        }
    }

    @AuraEnabled
    public static Boolean addItemToCart(Id perfumeId,String variant,String designer,String perfumeName,String perfumePhoto){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        try{
        if (!sessionPart.contains('cart')) {
            List<CartItem> cart = new List<CartItem>();
            cart.add(new CartItem(perfumeId,variant,designer,perfumeName,perfumePhoto));
            sessionPart.put('cart', cart);
            Decimal currPrice = getPriceFromVariant(variant);
            System.debug(currPrice);
            sessionPart.put('total', currPrice);
        }else{
            List<CartItem> cart = (List<CartItem>)sessionPart.get('cart');
            cart.add(new CartItem(perfumeId,variant,designer,perfumeName,perfumePhoto));
            sessionPart.put('cart', cart);
            Decimal currPrice = getPriceFromVariant(variant) + (Decimal)sessionPart.get('total');
            sessionPart.put('total', currPrice);
            System.debug(currPrice);
        }
        return true;
    }catch(Exception e){
        return false;
    }
    }

    @AuraEnabled
    public static void deleteFromCart(Integer id){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');

        List<CartItem> currCart = (List<CartItem>)sessionPart.get('cart');
        System.debug(id);

        Decimal total = (Decimal)sessionPart.get('total') - getPriceFromVariant(currCart.get(id).variant);
        currCart.remove(id);

        sessionPart.put('cart', currCart);
        sessionPart.put('total',total);
    }

    @AuraEnabled
    public static Decimal getCartTotalPrice(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        return (Decimal)sessionPart.get('total');
    }
    
    @AuraEnabled
    public static List<CartItem> getCart(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        List<CartItem> cart = (List<CartItem>)sessionPart.get('cart');
        System.debug(cart);
        return cart;
    }

    public static Decimal getPriceFromVariant(String variant){
        String str1 = variant.split('-')[1];
        String str2 = str1.substring(1,str1.length()-1);
        return decimal.valueOf(str2.deleteWhitespace());
    }
    @AuraEnabled
    public static void addShippmentInfo(String state,String city,String country, String zip, String street){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');

        ShippmentInfo info = new ShippmentInfo(state,city,country,zip,street);
        sessionPart.put('shippmentInfo',info);
    }
    @AuraEnabled
    public static ShippmentInfo getShippingInfo(){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');

        return (ShippmentInfo)sessionPart.get('shippmentInfo');
    }
    @AuraEnabled
    public static string getCartItemId(Integer index){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
        List<CartItem> cart = (List<CartItem>)sessionPart.get('cart');
        return cart.get(index).id;
    }

    @AuraEnabled
    public static List<String> getAllDesigners(){
        List<Designer__c> designers = [Select Name FROM Designer__c];
        
        List<String> out = new List<String>();
        
        for(Designer__c designer : designers){
            out.add(designer.Name);
        }

		return out;
    }

    @AuraEnabled
    public static List<String> getAllAccords(){
        Schema.DescribeFieldResult fieldResult = Product2.Main_accords__c.getDescribe();

		return getPicklistValues(fieldResult);
    }
    
    @AuraEnabled
    public static List<String> getAllNotes(){
        Schema.DescribeFieldResult fieldResult = Product2.Top_Notes__c.getDescribe();

		return getPicklistValues(fieldResult);
    }

    public static List<String> getPicklistValues(Schema.DescribeFieldResult fieldResult){
        List<String> pickListValuesList = new List<String>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    // @AuraEnabled
    // public static Boolean createOrder(){
    //     Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.lasenteur');
    //     List<CartItem> cart = (List<CartItem>)sessionPart.get('cart');
    //     ShippmentInfo shippmentInfo = (ShippmentInfo)sessionPart.get('shippmentInfo');


    //     Order order = new Order(
	//       AccountId = acc.Id,
	//       EffectiveDate = System.today(),
	//       Status = 'Draft',
	//       PriceBook2Id = Test.getStandardPricebookId()
    //   );
    //   insert order;


    //   For(CartItem item : cart){
    //       Decimal price = getPriceFromVariant(item.variant);
    //     PricebookEntry standardPrice = new PricebookEntry();
    //     standardPrice.Pricebook2Id = Test.getStandardPricebookId();
    //     standardPrice.Product2Id = item.id;
    //     standardPrice.UnitPrice = price;
    //     standardPrice.IsActive = true;
    //     standardPrice.UseStandardPrice = false;
    //     insert standardPrice ;

    //     OrderItem lineItem = new OrderItem();
    //     lineItem.OrderId = order.id;
    //     lineItem.Quantity = 1;
    //     lineItem.UnitPrice = price;
    //     lineItem.Product2id = item.id;
    //     lineItem.PricebookEntryId=standardPrice.id;
    //     insert lineItem;
    //   }

    //   order.Status = 'Activated';
    //   update order;
    // }


    class CartItem{
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String variant {get;set;}
        @AuraEnabled
        public String designer {get;set;}
        @AuraEnabled
        public String perfumeName {get;set;}
        @AuraEnabled
        public String perfumePhoto {get;set;}

        CartItem(){}
        CartItem(Id id,String variant,String designer,String perfumeName,String perfumePhoto){
            this.id = id;
            this.variant = variant;
            this.designer = designer;
            this.perfumeName = perfumeName;
            this.perfumePhoto = perfumePhoto;
        }
    }
    class ShippmentInfo{
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String zip;
        @AuraEnabled
        public String street;

        ShippmentInfo(){}
        ShippmentInfo(String state,String city,String country, String zip, String street){
            this.state = state;
            this.city = city;
            this.country = country;
            this.zip = zip;
            this.street = street;
        }
    }

    class PerfumeWrapper{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String photo { get; set; }
        @AuraEnabled
        public Decimal score { get; set; }
        @AuraEnabled
        public String topNotes { get; set; }
        @AuraEnabled
        public String middleNotes { get; set; }
        @AuraEnabled
        public String baseNotes { get; set; }
        @AuraEnabled
        public String mainAccords { get; set; }
        @AuraEnabled
        public String gender { get; set; }
        @AuraEnabled
        public String designer { get; set; }
        @AuraEnabled
        public String designerName{get;set;}
        @AuraEnabled
        public List<String> variants{get;set;}
        @AuraEnabled
        public Decimal price {get;set;}
        @AuraEnabled
        public List<Product_Image__c> images {get;set;}


        PerfumeWrapper(){}

        PerfumeWrapper(Perfume__c perfume) {
            this.Id = perfume.Id;
            this.name = perfume.Name;
            this.photo = perfume.Photo__c;
            this.score = perfume.Score__c;
            this.topNotes = perfume.Top_Notes__c;
            this.middleNotes = perfume.Middle_Notes__c;
            this.baseNotes = perfume.Base_Notes__c;
            this.gender = perfume.Gender__c;
            this.designer = perfume.Designer__c;
        }
    }
    class BestsellerWrapper{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String photo { get; set; }
        @AuraEnabled
        public String designer { get; set; }
        @AuraEnabled
        public String designerName{get;set;}
        @AuraEnabled
        public String bestsellerName{get;set;}
        @AuraEnabled
        public String price {get;set;}
        @AuraEnabled
        public String URL {get;set;}

        BestsellerWrapper(){}
    }

    class ReviewWrapper{
        Map<Decimal,String> scoreNames;
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String username {get;set;}
        @AuraEnabled
        public String scoreName {get;set;}
        @AuraEnabled
        public Decimal score {get;set;}
        @AuraEnabled
        public String text {get;set;}
        @AuraEnabled
        public Datetime createdTime {get;set;}


        ReviewWrapper(){
            scoreNames = new Map<Decimal,String>();
            scoreNames.put(1 ,'Terrible');
            scoreNames.put(2 ,'Bad');
            scoreNames.put(3 ,'OK');
            scoreNames.put(4 ,'Nice one');
            scoreNames.put(5 ,'Gorgeous');
        }
    }
}