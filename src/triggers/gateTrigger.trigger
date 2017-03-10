trigger gateTrigger on gate__c (before insert, after insert, before update, after update, before delete, after delete) {
    new gateTriggerHandler().run();
}