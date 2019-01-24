public with sharing class HandlerTriggerContract {

    public static void CreatePayment(List<Contract__c> ListContracts){
        Id RecordTypeIdBoth = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Both').getRecordTypeId();
        Id RecordTypeIdFixed = Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId();

        List<Contract__c> ContractsList = [SELECT Id, Name, Amount__c, RecordTypeId FROM Contract__c WHERE Id IN: ListContracts];
        List<Payment__c> payments = new List<Payment__c>();

        for (Contract__c contracts: ContractsList) {
            if(contracts.RecordTypeId == RecordTypeIdBoth){
                payments.add(new Payment__c(Payment_Date__c = Date.today(), Amount__c = contracts.Amount__c, Contract__c = contracts.Id));
                contracts.Paid__c = false;
            } else if (contracts.RecordTypeId == RecordTypeIdFixed){
                payments.add(new Payment__c(Payment_Date__c = Date.today(), Amount__c = contracts.Amount__c, Contract__c = contracts.Id));
                contracts.Paid__c = true;
            }
        }
        update ContractsList;
        insert payments;
    }


    public static void CheckSpaceDate(List<Contract__c> ListContracts){
        List<Contract__c> AllContracts = [SELECT Id, Name, Start_Date__c, End_Date__c, Contact__c, Movie__c, Amount__c FROM Contract__c];
        List<Movie__c> MovieStatus = [SELECT  Id, Status__c, Budget__c FROM Movie__c];
        Decimal CountBudget = 0, RealBudget = 0;

        for(Contract__c inserted: ListContracts){
            for(Movie__c movie: MovieStatus){
                if (inserted.Movie__c == movie.Id){
                    if (movie.Status__c !='New'){
                        inserted.addError('Not correct Movie. Movie has not "New" status');
                    }
                    RealBudget = movie.Budget__c;

                    for (Contract__c present: AllContracts) {
                        if (inserted.Movie__c == present.Movie__c) {
                            CountBudget = CountBudget + present.Amount__c;
                        }
                    }
                    CountBudget = CountBudget + inserted.Amount__c;
                    if(CountBudget > RealBudget){
                        inserted.addError('Not correct Budget. Sum Budget Contracts more that films budget');
                    }
                }
            }
            RealBudget = 0;
            CountBudget = 0;
        }

        for(Contract__c inserted: ListContracts){
            for(Contract__c present: AllContracts){
                if(inserted.Contact__c == present.Contact__c){
                    if(inserted.Movie__c == present.Movie__c){
                        inserted.addError('Not correct Movie. Actor has this Movie!');
                    }

                    system.debug('Insert Date: ' + inserted.Start_Date__c + ' ' + inserted.End_Date__c);
                    system.debug('present Date: ' + present.Start_Date__c + ' ' + present.End_Date__c);

                    if((inserted.Start_Date__c <= present.End_Date__c && inserted.Start_Date__c >= present.Start_Date__c)
                            || (inserted.End_Date__c <= present.End_Date__c && inserted.End_Date__c >= present.Start_Date__c)
                            || (inserted.Start_Date__c <= present.Start_Date__c && inserted.End_Date__c >= present.End_Date__c)){
                        inserted.addError('Not correct date. This date is busy!');
                    }
                }
            }
        }
    }



}