public class NewPerfumeController {
    @AuraEnabled
    public static String uploadFiles(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) {
                recordId = [SELECT Id  FROM  Product2 WHERE Family = 'Perfumes' ORDER BY Id DESC LIMIT 1].Id;
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug(files);
 
                // List<ContentVersion> cvList = new List<ContentVersion>();
                List<Id> docIds = new List<Id>();

                for(FileDataWP file : files) {
                    Document doc = new Document();
                    doc.FolderId='00l09000002RzWJ';
                    doc.Name = file.fileName;
                    doc.body = EncodingUtil.base64Decode(file.fileContent);
                    doc.IsPublic = true;
                    insert doc;
                    docIds.add(doc.Id);

                    // ContentVersion conVer = new ContentVersion();
                    // conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    // conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    // conVer.Title = file.fileName;
                    // conVer.PathOnClient = file.fileName;

                    // cvList.add(conVer);
                }
                // Insert cvList;

                Product2 product = [SELECT Id,Photo__c FROM Product2 WHERE Id =: recordId LIMIT 1];
                product.Photo__c = 'https://britenet-bb-dev-ed--c.documentforce.com/servlet/servlet.FileDownload?file='+docIds.get(0);
                update product;

                for(ID id : docIds){
                    // cvIds.add(cv.Id);

                    String url = 'https://britenet-bb-dev-ed--c.documentforce.com/servlet/servlet.FileDownload?file='+id;

                    Product_Image__c pi = new Product_Image__c(
                        Product__c = recordId,
                        URL__c = url
                    );
                    insert pi;
                }
                // List<ContentVersion> cvPhotoList = [SELECT Id,]
 
                // List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                // for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                //     ContentDocumentLink conDocLink = New ContentDocumentLink();
                //     conDocLink.LinkedEntityId = recordId;
                //     conDocLink.ContentDocumentId = cv.ContentDocumentId;
                //     conDocLink.Visibility = 'AllUsers';
                //     conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    
                //     insert conDocLink;


                    
                    // cdList.add(conDocLink);
                // }
                // Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static string createNewPerfume(String name, String designer, String gender, String accords, String topNotes, String middleNotes, String baseNotes, String variants){
        Id designerId = [SELECT Id, Name FROM Designer__c WHERE Name LIKE :designer LIMIT 1].Id;

        List<String> varts = stringToVariants(variants);
        Decimal minPrice = 90000000;

        for(String var : varts){
            if(PerfumesController.getPriceFromVariant(var) < minPrice){
                minPrice = PerfumesController.getPriceFromVariant(var);
            }
        }

        Product2 prod = new Product2(
            Family = 'Perfumes',
            IsActive = true,
            Name = name,
            minPrice__c = minPrice,
            Designer__c = designerId,
            Gender__c = gender,
            Main_accords__c = stringToPicklist(accords),
            Top_Notes__c = stringToPicklist(topNotes),
            Middle_Notes__c = stringToPicklist(middleNotes),
            Base_Notes__c = stringToPicklist(baseNotes)
        );

        Insert prod;

        Pricebook2 standard = [SELECT Id,Name FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standard.Id, Product2Id = prod.Id, UnitPrice = prod.minPrice__c, IsActive = true);
        insert standardPBE;

        for(String var : varts){
            Variant__c variant = new Variant__c(
                Product__c = prod.Id,
                Capacity__c = PerfumesController.getCapacityFromVariant(var),
                Price__c = PerfumesController.getPriceFromVariant(var)
            );
            insert variant;
            System.debug(variant);
        }

        return 'git';
    }

    public static String stringToPicklist(String input){
        return input.substring(0,input.length()-1).replace(',',';');
    }

    public static List<String> stringToVariants(String input){
      String pom = input.substring(1,input.length()-1);
      List<String> preVals = pom.split(',');

     List<String> variants = new List<String>();
      for(String text : preVals){
        String variant = text.substring(10,text.length()-2);
        variants.add(variant);
      }
    return variants;
}
 
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}
