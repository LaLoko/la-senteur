public with sharing class PerfumesController {

        @AuraEnabled(cacheable=true)
        public static List<Perfume__c> getAllPerfumes(String type){
            List<Perfume__c> perfumesList = new List<Perfume__c>();

            if(type == 'male-perfumes'){
                perfumesList = [SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c FROM Perfume__c WHERE Gender__c LIKE 'MALE'];
            }else if(type == 'female-perfumes'){
                perfumesList = [SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c FROM Perfume__c WHERE Gender__c LIKE 'FEMALE'];
            }else{
                perfumesList = [SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c FROM Perfume__c WHERE Gender__c LIKE 'UNISEX'];
            }
            List<PerfumeWraper> out = new List<PerfumeWraper>();
            for (Perfume__c perfume : perfumesList) {
                
            }

        }
        @AuraEnabled(cacheable=true)
        public static PerfumeWraper getDetailPerfume(String id){
            List<Perfume__c> perfumesList = [SELECT Name__c,Photo__c,Score__c,Top_Notes__c,Main_accords__c,Middle_Notes__c,Gender__c,Designer__c,Base_Notes__c 
                                             FROM Perfume__c
                                             WHERE Id =: id];
            return null;
        }


    class PerfumeWraper{
        String name {get;set;}
        String photo {get;set;}
        Decimal score {get;set;}
        String topNotes {get;set;}
        String middleNotes{get;set;}
        String baseNotes {get;set;}
        String mainAccords {get;set;}
        String gender {get;set;}
        String designer {get;set;}
        PerfumeWraper(){}
    }
}