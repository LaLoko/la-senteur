trigger PricebooksMenager on Pricebook2 (after insert, after delete) {

    PricebookMenagmentHandler handler = new PricebookMenagmentHandler();
    if(Trigger.isInsert){
        handler.afterInsert(Trigger.old);
    }
    if(Trigger.isUpdate){
        handler.afterUpdate(Trigger.old);

    }
    if(Trigger.isDelete){
        handler.afterDelete(Trigger.old);
    }
}