public class ReviewWrapper {
    public Map<Decimal, String> scoreNames;
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String username { get; set; }
    @AuraEnabled
    public String scoreName { get; set; }
    @AuraEnabled
    public Decimal score { get; set; }
    @AuraEnabled
    public String text { get; set; }
    @AuraEnabled
    public Boolean currUserReview { get; set; }
    @AuraEnabled
    public Datetime createdTime { get; set; }

    public ReviewWrapper() {
        scoreNames = new Map<Decimal, String>();
        scoreNames.put(1, 'Terrible');
        scoreNames.put(2, 'Bad');
        scoreNames.put(3, 'OK');
        scoreNames.put(4, 'Nice one');
        scoreNames.put(5, 'Gorgeous');
    }
}