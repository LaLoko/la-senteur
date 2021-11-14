public with sharing class PerfumesController {

    @AuraEnabled(cacheable=true)
    public static List<PerfumeWrapper> getAllPerfumes(String type,String sortType) {
        List<Perfume__c> perfumesList = new List<Perfume__c>();

        String query = 'SELECT Id, Name__c, Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c'+
                +' FROM Perfume__c';
        if (type == 'male-perfumes') {
            query += ' WHERE Gender__c LIKE \'MALE\' ';
        } else if (type == 'female-perfumes') {
            query += ' WHERE Gender__c LIKE \'FEMALE\' ';
        } else {
            query += ' WHERE Gender__c LIKE \'UNISEX\' ';
        }

        if(sortType == null || !sortType.contains('Name')){
            query += ' ORDER BY Name__c ASC';
        }else{
            query += ' ORDER BY '+sortType;
        }

        perfumesList = database.query(query);

        List<Id> ids = new List<Id>();
        for (Perfume__c perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id, Name FROM Designer__c WHERE Id IN : ids];
        Map<Id,String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers){
            designersKeys.put(designer.Id,designer.Name);
        }

        List<PerfumeWrapper> out = new List<PerfumeWrapper>();
        for (Perfume__c perfume : perfumesList) {
            PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name__c;
            wrapper.designer = designersKeys.get(perfume.Designer__c);
            wrapper.score = perfume.Score__c;
            wrapper.topNotes = perfume.Top_Notes__c;
            wrapper.middleNotes = perfume.Middle_Notes__c;
            wrapper.baseNotes = perfume.Base_Notes__c;
            wrapper.gender = perfume.Gender__c;
            wrapper.mainAccords = perfume.Main_Accords__c;
            wrapper.photo = perfume.Photo__c;
            out.add(wrapper);
        }
        if(sortType!= null && sortType.contains('Price')){
            List<Id> perfumeIds = new List<Id>();
            for (Perfume__c perfume : perfumesList) {
                perfumeIds.add(perfume.Id);
            }
            List<Variant__c> variants;
                 variants = [SELECT Perfume__c,Price__c FROM Variant__c WHERE Perfume__c IN : perfumeIds ORDER BY Price__c];

            
            System.debug(variants);
            out = sortByPrice(out,variants,sortType);
        }
        System.debug(out);
        return out;
    }
    @AuraEnabled
    public static List<PerfumeWrapper> getBestsellers(){
        List<Perfume__c> perfumesList = new List<Perfume__c>();

        perfumesList = [
                SELECT Id, Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
                FROM Perfume__c
                ORDER BY Score__c
                LIMIT 5
        ];

        List<Id> ids = new List<Id>();
        for (Perfume__c perfume : perfumesList) {
            ids.add(perfume.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id, Name FROM Designer__c WHERE Id IN : ids];
        Map<Id,String> designersKeys = new Map<Id, String>();
        for (Designer__c designer : designers){
            designersKeys.put(designer.Id,designer.Name);
        }

        List<PerfumeWrapper> out = new List<PerfumeWrapper>();
        for (Perfume__c perfume : perfumesList) {
            PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name__c;
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
        List<Perfume__c> perfumesList = [
                SELECT Id, Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
                FROM Perfume__c
                WHERE Id = :id
        ];
        Perfume__c perfume = perfumesList.get(0);

        List<Variant__c> variants = [SELECT Price__c,Capacity__c FROM Variant__c WHERE Perfume__c =: perfume.Id ORDER BY Capacity__c];
        List<String> variantsMap = new List<String>();
        for(Variant__c variant : variants){
            variantsMap.add(variant.Capacity__c+' ml - '+variant.Price__c+' €');
        }
        System.debug(variantsMap);

        PerfumeWrapper wrapper = new PerfumeWrapper();
            wrapper.Id = perfume.Id;
            wrapper.name = perfume.Name__c;
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
            insert new Perfume_Review__c(Review__c=text,Score__c=score,Username__c=currUser.Name,Perfume__c=perfume);

            List<Perfume_Review__c> reviews = [Select Score__c FROM Perfume_Review__c WHERE Perfume__c =: perfume];
            List<Perfume__c> perfumeToUpdate = [SELECT Score__c FROM Perfume__c WHERE Id =: perfume];
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
        return [SELECT Review__c,Score__c,Username__c FROM Perfume_Review__c WHERE Perfume__c =: id];
    }


    public static List<PerfumeWrapper> sortByPrice(List<PerfumeWrapper> perfumes,List<Variant__c> variants,String type){
            for (PerfumeWrapper perfume : perfumes) {
                for (Variant__c variant : variants) {
                    if(variant.Perfume__c == perfume.Id){
                        perfume.price = variant.Price__c;
                        break;
                    }
                }
            }
            // if(type.contains('ASC')){
            //     List<PerfumeWrapper> out = new List<PerfumeWrapper>();
            //     while (out.size()< perfumes.size()) {
            //         for (PerfumeWrapper perfume : perfumes) {

            //         }
            //     }
            // }else{

            // }
            perfumes.sort();
            if(type.contains('DESC')){
                List<PerfumeWrapper> out = new List<PerfumeWrapper>();

                for(Integer i = perfumes.size() - 1; i >= 0; i--){
                    out.add(perfumes[i]);
                }
                return out;
            }else{
                return perfumes;
            }
    }

    class PerfumeWrapper implements Comparable{
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
        public Decimal price {get;set;}

        PerfumeWrapper(){}

        PerfumeWrapper(Perfume__c perfume) {
            this.Id = perfume.Id;
            this.name = perfume.Name__c;
            this.photo = perfume.Photo__c;
            this.score = perfume.Score__c;
            this.topNotes = perfume.Top_Notes__c;
            this.middleNotes = perfume.Middle_Notes__c;
            this.baseNotes = perfume.Base_Notes__c;
            this.gender = perfume.Gender__c;
            this.designer = perfume.Designer__c;
        }

        public Integer compareTo(Object compareTo) {
            PerfumeWrapper compareToEmp = (PerfumeWrapper)compareTo;
            if (price == compareToEmp.price) return 0;
            if (price > compareToEmp.price) return 1;
            return -1;        
        }
    }
}