/*------------------------------------------------------------------------
 * Author:        Ricky Lowe
 * Company:       System Partners
 * Description:   Apex Trigger Handler for the Assigned Approver Object
 *
 * Test Class:    
 * 
 * History:
 * 2017-MAR-22    Ricky Lowe     Created
 * 2017-MAR-30    Ricky Lowe     Added Email Functionality
 * 2017-APR-18    Ricky Lowe     Moved logic to Service class
 --------------------------------------------------------------------------*/

public without sharing class Assigned_Approver_TriggerHandler extends TriggerHandler {
	public static boolean recursionBefore = false;
    public static boolean recursionAfter = false;

    public Assigned_Approver_TriggerHandler(){}

	public override void beforeUpdate() {
        if(recursionBefore == false){
		    Assigned_Approver_Service.findCurrentApproversThatHaveApproved((list<Assigned_Approver__c>) Trigger.new, (map<Id,Assigned_Approver__c>) Trigger.oldMap, Trigger.isBefore, Trigger.isAfter);
            Assigned_Approver_Service.setEmailDates((list<Assigned_Approver__c>) Trigger.new, (map<Id,Assigned_Approver__c>) Trigger.oldMap);
            recursionBefore = true;
        }
    }

    public override void afterUpdate() {
        if(recursionAfter == false){
            Assigned_Approver_Service.findCurrentApproversThatHaveApproved((list<Assigned_Approver__c>) Trigger.new, (map<Id,Assigned_Approver__c>) Trigger.oldMap, Trigger.isBefore, Trigger.isAfter);
            Assigned_Approver_Service.sendEmailToCurrentApprover((list<Assigned_Approver__c>) Trigger.new, (map<Id,Assigned_Approver__c>) Trigger.oldMap);
            recursionAfter = true;            
        }	
    } 

    public override void afterInsert() {
        Assigned_Approver_Service.setProxyAsShareRecord((list<Assigned_Approver__c>) Trigger.new);
    } 
}