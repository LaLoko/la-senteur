public without sharing class CaseController {

    @AuraEnabled
    public static Boolean createNewCase(String items, String subject, String description, Id orderId) {
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,ContactId FROM User WHERE Id = :userId LIMIT 1];
        Contact contact = [SELECT Id,AccountId FROM Contact WHERE Id = :user.ContactId LIMIT 1];

        List<OrderWrapper> orderItems = OrderWrapper.parse(items);

        Case caseObj = new Case(
                ContactId = contact.Id,
                AccountId = contact.AccountId,
                Status = 'New',
                Origin = 'Web',
                Subject = subject,
                Description = description,
                Order__c = orderId);

        insert caseObj;

        List<String> names = new List<String>();
        for (OrderWrapper item : orderItems) {
            names.add(item.name);
        }

        List<Product2> products = [SELECT Id,Name FROM Product2 WHERE Name IN :names];
        System.debug(orderItems);

        for (OrderWrapper item : orderItems) {
            Case_Item__c cp = new Case_Item__c();
            cp.Case__c = caseObj.Id;
            cp.Product__c = [SELECT Id,Name FROM Product2 WHERE Name LIKE :item.name LIMIT 1].Id;
            cp.Variant__c = [SELECT Id FROM Variant__c WHERE Product__c = :cp.Product__c AND Capacity__c = :item.capacity LIMIT 1].Id;

            insert cp;
        }
        return true;
    }
    @AuraEnabled
    public static List<CaseWrapper> getAllUserCases() {
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,ContactId FROM User WHERE Id = :userId LIMIT 1];
        List<Case> cases = [SELECT Id,CaseNumber, Status, ClosedDate,CreatedDate,Order__c,Subject,Description FROM Case WHERE ContactId = :user.ContactId];

        List<CaseWrapper> out = new List<CaseWrapper>();
        for (Case c : cases) {
            CaseWrapper wrapper = new CaseWrapper();
            wrapper.objCase = c;
            wrapper.hideBool = true;
            wrapper.orderItems = getOrderItems(c.Order__c, c.Id);
            out.add(wrapper);
        }
        return out;
    }

    public static List<OrderWrapper> getOrderItems(Id orderId, Id caseId) {
        List<OrderWrapper> out = new List<OrderWrapper>();
        List<OrderItem> orderItems = [SELECT Id,OrderId, Product2Id, UnitPrice,Capacity__c FROM OrderItem WHERE OrderId = :orderId];

        List<Id> productIds = new List<Id>();
        for (OrderItem item : orderItems) {
            productIds.add(item.Product2Id);
        }
        List<Product2> products = [SELECT Id,Name,Designer__c FROM Product2 WHERE Id IN :productIds];

        List<Id> designersIds = new List<Id>();
        for (Product2 product : products) {
            designersIds.add(product.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id,Name FROM Designer__c WHERE Id IN :designersIds];
        List<Case_Item__c> caseItems = [SELECT Product__c, Variant__c, Case__c FROM Case_Item__c WHERE Case__c = :caseId];

        List<Variant__c> variants = [SELECT Id,Capacity__c,Price__c FROM Variant__c WHERE Product__c IN :productIds];

        for (Case_Item__c cs : caseItems) {
            OrderWrapper wrapper = new OrderWrapper();

            for (Variant__c variant : variants) {
                if (variant.Id == cs.Variant__c) {
                    wrapper.price = variant.Price__c;
                    wrapper.capacity = variant.Capacity__c;
                }
            }

            for (Product2 product : products) {
                if (cs.Product__c == product.Id) {
                    wrapper.name = product.Name;
                    wrapper.perfumeId = product.Id;
                    for (Designer__c designer : designers) {
                        if (designer.Id == product.Designer__c) {
                            wrapper.designer = designer.Name;
                            break;
                        }
                    }
                }
            }
            out.add(wrapper);
        }
        return out;
    }

    class CaseWrapper {
        @AuraEnabled
        public Boolean hideBool;
        @AuraEnabled
        public Case objCase;
        @AuraEnabled
        public List<OrderWrapper> orderItems;

        CaseWrapper() {
        }
    }
}