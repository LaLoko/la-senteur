public with sharing class PerfumesController {

    @AuraEnabled(cacheable=true)
    public static List<PerfumeWrapper> getAllPerfumes(String type,String sortType) {
        List<Perfume__c> perfumesList = new List<Perfume__c>();

        if(sortType == null || !sortType.contains('Name')){
            sortType = 'Name__c ASC';
        }
        String query = 'SELECT Id, Name__c, Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c'+
                +' FROM Perfume__c';
        if (type == 'male-perfumes') {
            query += ' WHERE Gender__c LIKE \'MALE\' ';
//            perfumesList = [
//                    SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
//                    FROM Perfume__c
//                    WHERE Gender__c LIKE 'MALE'
//            ];
        } else if (type == 'female-perfumes') {
            query += ' WHERE Gender__c LIKE \'FEMALE\' ';

//            perfumesList = [
//                    SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
//                    FROM Perfume__c
//                    WHERE Gender__c LIKE 'FEMALE'
//            ];
        } else {
            query += ' WHERE Gender__c LIKE \'UNISEX\' ';

//            perfumesList = [
//                    SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c
//                    FROM Perfume__c
//                    WHERE Gender__c LIKE 'UNISEX'
//            ];
        }
        query += ' ORDER BY '+sortType;
        System.debug(query);
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
        System.debug(designersKeys);
        System.debug(perfumesList);

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
        return null;
    }

    class PerfumeWrapper {
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
        public String bestsellerName{get;set;}

        PerfumeWrapper() {
        }
    }
}