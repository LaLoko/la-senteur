trigger minPriceSet on Variant__c (after insert, after update, after delete) {

    MinPriceTriggerHandler MinPriceTriggerHandler = new MinPriceTriggerHandler();

    if (Trigger.isDelete) {
        minPriceTriggerHandler.handleDelete(Trigger.old);
    }

    if (Trigger.isInsert) {
        minPriceTriggerHandler.handleInsert(Trigger.new);
    }
}