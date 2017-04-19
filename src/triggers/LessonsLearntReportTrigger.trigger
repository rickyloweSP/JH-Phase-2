trigger LessonsLearntReportTrigger on Lessons_Learnt_Report__c (before insert, after insert, before update, after update, before delete, after delete) {
//if the turn off trigger setting is not set to TRUE then run
    if(Constants.Approvers.Turn_Off_Triggers__c != true){
    	new LessonsLearntTriggerHandler().run();
    }
}