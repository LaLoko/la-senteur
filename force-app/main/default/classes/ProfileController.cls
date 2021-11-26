public without sharing class ProfileController {

    @AuraEnabled
    public static ProfileWrapper getProfileInfo(){
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,Name,AboutMe,Address,ContactId,Phone,Username,SenderEmail FROM User WHERE Id =: userId].get(0);
        Contact contact = [SELECT Id,Name,Email,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE Id =: user.ContactId LIMIT 1];

        ProfileWrapper wrapper = new ProfileWrapper();
        wrapper.id = user.Id;
        wrapper.name = user.Name;
        wrapper.username = user.Username;
        wrapper.phone = user.Phone;
        wrapper.email = contact != null ?contact.Email : null;
        wrapper.city = contact.MailingCity;
        wrapper.street = contact.MailingStreet;
        wrapper.state = contact.MailingState;
        wrapper.zip = contact.MailingPostalCode;
        wrapper.country = contact.MailingCountry;

        System.debug(wrapper);

        return wrapper;
    }
    
    @AuraEnabled
    public static List<OrderWrapper> getAllOrders(){
        String userId = System.UserInfo.getUserId();
        // User user = [SELECT Id,ContactId FROM User WHERE Id =: userId].get(0);
        List<OrderWrapper> out = new List<OrderWrapper>();

        for (Order objOrder : [SELECT Id,Name,TotalAmount,ActivatedDate,OrderNumber FROM Order WHERE CreatedById =: userId]){
            OrderWrapper wrapper = new OrderWrapper();
            wrapper.objOrder = objOrder;
            wrapper.hideBool = true;
            out.add(wrapper);
        }

        return out;
    }
    @AuraEnabled
    public static ProfileWrapper updateProfile(String pro){
        String userId = System.UserInfo.getUserId();
        User user = [SELECT Id,Name,AboutMe,Address,ContactId,Phone,Username,SenderEmail FROM User WHERE Id =: userId LIMIT 1];
        Contact contact = [SELECT Id,Name,Email,Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE Id =: user.ContactId LIMIT 1];

        ProfileWrapper profile = ProfileWrapper.parse(pro);
        user.Phone = profile.phone;
        update user;

        contact.MailingStreet = profile.street;
        contact.MailingCity = profile.city;
        contact.MailingState = profile.state;
        contact.MailingPostalCode = profile.zip;
        contact.MailingCountry = profile.country;

        update contact;

        return profile;
    }
    @AuraEnabled
    public static Order getOrderDetails(Id orderId){
        return [SELECT Id,ActivatedDate,ShippingAddress ,BillToContactId ,TotalAmount,OrderNumber FROM Order WHERE Id=: orderId LIMIT 1];
    }
    @AuraEnabled
    public static List<OrderWrapper> getOrderedPerfumes(Id orderId){
        List<OrderItem> orderItems = [SELECT Id,ListPrice,OrderId,Capacity__c,Product2Id,TotalPrice,UnitPrice FROM OrderItem WHERE OrderId =: orderId];
        
        List<Id> pefumesIds = new List<Id>();
        for(OrderItem item : orderItems){
            pefumesIds.add(item.Product2Id);
        }
        List<Product2> perfumes = [SELECT Id, Name , Designer__c FROM Product2 WHERE Id IN : pefumesIds];

               
        List<Id> designerIds = new List<Id>();
        for(Product2 item : perfumes){
            designerIds.add(item.Designer__c);
        }
        List<Designer__c> designers = [SELECT Id, Name  FROM Designer__c WHERE Id IN : designerIds];

        List<OrderWrapper> out = new List<OrderWrapper>();

        for(OrderItem item : orderItems){
            OrderWrapper wrapper = new OrderWrapper();
            wrapper.price = item.UnitPrice;
            wrapper.capacity = item.Capacity__c;

            for(Product2 product : perfumes){
                if (product.Id == item.Product2Id) {
                    wrapper.perfumeId = product.Id;
                    wrapper.name = product.Name;
                    for(Designer__c designer : designers){
                        if(designer.Id == product.Designer__c){
                            wrapper.designer = designer.Name;
                            // continue;
                        }
                    }
                }
            }
            out.add(wrapper);
            System.debug(wrapper);
        }
        return out;
    }
    @AuraEnabled
    public static ShippmentInfo getShippmentInfo(id orderId){
        Order order = [SELECT Id, ShipToContactId FROM Order WHERE id =: orderId LIMIT 1];

        Contact contact = [SELECT Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry FROM Contact WHERE Id =: order.ShipToContactId LIMIT 1];
        ShippmentInfo info = new ShippmentInfo(contact.MailingState,contact.MailingCity,contact.MailingCountry,contact.MailingPostalCode,contact.MailingStreet);
        return info;
    }
}
