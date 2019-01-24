trigger ContractTrigger on Contract__c (before insert, before update, after insert, after update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        HandlerTriggerContract.CreatePayment(Trigger.new);
    } else if (Trigger.isInsert && Trigger.isBefore){
        HandlerTriggerContract.CheckSpaceDate(Trigger.new);
    }


}