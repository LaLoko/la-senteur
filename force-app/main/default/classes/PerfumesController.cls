public with sharing class PerfumesController {

    @AuraEnabled(cacheable=true)
    public static List<PerfumeWrapper> getAllPerfumes(String type,String sortType) {
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

        if(sortType != null && sortType.contains('Name ASC')){
            query += ' ORDER BY Name ASC';
        }else if(sortType != null && sortType.contains('Name ASC')){
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
    @AuraEnabled
    public static List<PerfumeWrapper> getBestsellers(){
        List<Product2> perfumesList = new List<Product2>();

        perfumesList = [
                SELECT Id, Name,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
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

        List<PerfumeWrapper> out = new List<PerfumeWrapper>();
        for (Product2 perfume : perfumesList) {
            PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name;
            wrapper.designer = designersKeys.get(perfume.Designer__c);
            wrapper.score = perfume.Score__c;
            wrapper.topNotes = perfume.Top_Notes__c;
            wrapper.middleNotes = perfume.Middle_Notes__c;
            wrapper.baseNotes = perfume.Base_Notes__c;
            wrapper.gender = perfume.Gender__c;
            wrapper.mainAccords = perfume.Main_Accords__c;
            wrapper.photo = perfume.Photo__c;
            wrapper.bestsellerName = wrapper.designer +' '+wrapper.name;
            out.add(wrapper);
        }
        return out;
    }

    @AuraEnabled(cacheable=true)
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
        System.debug(variantsMap);

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

        return wrapper;
    }
    @AuraEnabled
    public static Boolean addReview(String text,Integer score,Id perfume){
        try {
            String userId = System.UserInfo.getUserId();
            User currUser = [SELECT Id, Name FROM User WHERE Id = :userId];
            System.debug(text);
            System.debug(score);
            System.debug(perfume);
            System.debug(currUser.Name);
            insert new Perfume_Review__c(Review__c=text,Score__c=score,Username__c=currUser.Name,Product__c=perfume);

            List<Perfume_Review__c> reviews = [Select Score__c FROM Perfume_Review__c WHERE Product__c =: perfume];
            List<Product2> perfumeToUpdate = [SELECT Score__c FROM Product2 WHERE Id =: perfume];
            Double newScore = (perfumeToUpdate.get(0).Score__c + score)/reviews.size();
            perfumeToUpdate.get(0).Score__c = newScore;
            update perfumeToUpdate;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static List<Perfume_Review__c> getReviews(Id id){
        return [SELECT Review__c,Score__c,Username__c FROM Perfume_Review__c WHERE Product__c =: id];
    }
    
    // @AuraEnabled
    // public static Boolean UserCreatedComment(Id id){
    //     try {
            
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

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
        public String bestsellerName{get;set;}
        @AuraEnabled
        public List<String> variants{get;set;}
        @AuraEnabled
        public Decimal price {get;set;}

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
}