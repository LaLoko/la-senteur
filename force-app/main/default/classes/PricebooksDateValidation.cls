public class PricebooksDateValidation implements Database.Batchable<sObject>{
     
        public Database.QueryLocator start(Database.BatchableContext BC){
            String query = 'SELECT Id, IsStandard, IsActive,ValidFrom,ValidTo FROM Pricebook2 WHERE IsStandard = false';
           return Database.getQueryLocator(query);
        }
     
        public void execute(Database.BatchableContext BC, List<Pricebook2> scope){
          for(Pricebook2 s : scope){
            if(s.ValidFrom >= date.today() && s.ValidTo <= date.today()){
                s.IsActive = true;
            }else{
                s.IsActive = false;
            }
        }
    }
        public void finish(Database.BatchableContext BC){
        }
}