global class PricebookValidationBatch implements Schedulable{

    global void execute(SchedulableContext sc) {
        PricebooksDateValidation validation = new PricebooksDateValidation();
        Database.executeBatch(validation);
    }
}