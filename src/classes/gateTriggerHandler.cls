/*------------------------------------------------------------------------
 * Author:        Ricky Lowe
 * Company:       System Partners
 * Description:   Apex Trigger Handler for the Gate Object
 *
 * Test Class:    
 * 
 * History:
 * 2017-MAR-10    Ricky Lowe     Created
 * 2017-MAR-13    Ricky Lowe     Commented out so no issues arise while I am away
 * 2017-MAR-22    Ricky Lowe     Added logic for gates 4 + 5


 * Funtionality:
 - Adds the PDM, BDM and the Approvers to the Gate Sharing rules
 - Adds the Approvers to the Opportunity Team (and clears the previous opp team members)
 - 
 --------------------------------------------------------------------------*/

public with sharing class GateTriggerHandler extends TriggerHandler {
    public static boolean recursionBefore = false;
    public static boolean recursionAfter = false;


    public gateTriggerHandler() {
        
    }

    public override void afterInsert() {
        GateService.reevaluateOppTeamMembers((list<Gate__c>) Trigger.new);  //delete the old Approver Opp Team members.
        GateService.DetermineApprovers((list<Gate__c>) Trigger.new, (map<Id,Gate__c>) Trigger.newMap);

    }

    public override void afterUpdate() {
        GateService.findGatesSetToInProgressOrRestarted((list<Gate__c>) Trigger.new, (map<Id,Gate__c>) Trigger.oldMap);
    }
}