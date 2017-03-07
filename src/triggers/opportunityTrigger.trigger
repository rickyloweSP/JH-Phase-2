trigger opportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete) {
    //system.debug('---Test : OpportunityTrigger Fired');
    //OpportunityTriggerHandler.processData();
    new opportunityTriggerHandler().run();
}