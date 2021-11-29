public class NewPerfumeController {
    @AuraEnabled
    public static String uploadFiles(String recordId, String filedata) {
        try {
            if (String.isNotBlank(FileData)) {
                recordId = [SELECT Id FROM Product2 WHERE Family = 'Perfumes' ORDER BY Id DESC LIMIT 1].Id;
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                List<Id> docIds = new List<Id>();

                for (FileDataWP file : files) {
                    Document doc = new Document();
                    doc.FolderId = '00l09000002RzWJ';
                    doc.Name = file.fileName;
                    doc.body = EncodingUtil.base64Decode(file.fileContent);
                    doc.IsPublic = true;
                    insert doc;
                    docIds.add(doc.Id);
                }
                Product2 product = [SELECT Id,Photo__c FROM Product2 WHERE Id = :recordId LIMIT 1];
                product.Photo__c = 'https://britenet-bb-dev-ed--c.documentforce.com/servlet/servlet.ImageServer?id=' + docIds.get(0) + '&oid=00D09000007z4Sw&lastMod=1637830151000';
                update product;

                for (Id id : docIds) {
                    String url = 'https://britenet-bb-dev-ed--c.documentforce.com/servlet/servlet.ImageServer?id=' + id + '&oid=00D09000007z4Sw&lastMod=1637830151000';

                    Product_Image__c pi = new Product_Image__c(
                            Product__c = recordId,
                            URL__c = url
                    );
                    insert pi;
                }
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static string createNewPerfume(String name, String designer, String gender, String accords, String topNotes, String middleNotes, String baseNotes, String variants) {
        Id designerId = [SELECT Id, Name FROM Designer__c WHERE Name LIKE :designer LIMIT 1].Id;

        List<String> varts = stringToVariants(variants);
        Decimal minPrice = 90000000;

        for (String var : varts) {
            if (PerfumesController.getPriceFromVariant(var) < minPrice) {
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

        for (String var : varts) {
            Variant__c variant = new Variant__c(
                    Product__c = prod.Id,
                    Capacity__c = PerfumesController.getCapacityFromVariant(var),
                    Price__c = PerfumesController.getPriceFromVariant(var)
            );
            insert variant;
        }

        return prod.Id;
    }

    public static String stringToPicklist(String input) {
        return input.substring(0, input.length() - 1).replace(',', ';');
    }

    public static List<String> stringToVariants(String input) {
        String pom = input.substring(1, input.length() - 1);
        List<String> preVals = pom.split(',');

        List<String> variants = new List<String>();
        for (String text : preVals) {
            String variant = text.substring(10, text.length() - 2);
            variants.add(variant);
        }
        return variants;
    }

    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}
