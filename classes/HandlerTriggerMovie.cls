public with sharing class HandlerTriggerMovie {

    public static void CreatePayment(List<Movie__c> ListMovies) {

        List<Id> MovieId = new List<Id>();

        for (Movie__c M : ListMovies) {
            if (M.Status__c == 'Finished') {
                MovieId.add(M.Id);
            }
        }

        List<Contract__c> AllContractsForMovie = [SELECT Id, Name, Percent__c, Contact__c, Movie__r.Gross__c, RecordTypeId, Paid__c FROM Contract__c WHERE Movie__c IN:MovieId];
        List<Payment__c> Payments = new List<Payment__c>();

        Id RecordTypeIdBoth = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Both').getRecordTypeId();
        Id RecordTypeIdPercent = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Percent').getRecordTypeId();

        for (Contract__c contract : AllContractsForMovie) {
            if (contract.RecordTypeId == RecordTypeIdPercent || contract.RecordTypeId == RecordTypeIdBoth) {
                Payments.add(new Payment__c(Contract__c = contract.Id, Payment_Date__c = Date.today(), Amount__c = (contract.Movie__r.Gross__c * contract.Percent__c) / 100));
                contract.Paid__c = true;
            }
        }
        update AllContractsForMovie;
        insert Payments;
    }
}