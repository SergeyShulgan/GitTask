trigger MovieTrigger on Movie__c (before insert, before update, after insert, after update) {

    if (Trigger.isUpdate && Trigger.isAfter) {
        HandlerTriggerMovie.CreatePayment(Trigger.new);
    }


}