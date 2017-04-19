public class ApprovalController {
	/*------------------------------------------------------------------------
 * Author:        Alex Odago / Aditya Raj
 * Company:       System Partners
 * Description:   Apex controller class for ApprovalControlComponent 
 *
 * Test Class:    ApprovalControllerTest
 * 
 * History:
 * 2017-MAR-17    Alex Odago     Created
 --------------------------------------------------------------------------*/

    
	@AuraEnabled
   public static List<Opportunity> getOpportunityRecord(String opportunityId) {

       
       List<Opportunity> allOpps = [SELECT   Id,name,
                                                           			Gate_Status__c,
                                                           			TSF_Gate_Status__c,
                                                           			CRA_Gate_Status__c,
                                                           			StageName,
                                    								Competitor_Analysis_General_Comments__c,
                                    								Are_there_any_critical_risks__c,
                                    								Has_CRA_changed_since_last_approval__c,
                                    								Has_TSF_changed_since_last_approval__c,
                                    								Apply_Default_Bonding__c,
                                    								Conversion_Budget_Comments__c,
                                    								Is_Gate_1_To_3__c, Is_Gate_4_To_5__c,
                                    								Net_Budget_EOI_PQ__c, Net_Budget_Post_Tender__c, 
                                    								Net_Budget_Tender__c, Net_Budget_Amount__c,
                                    								Total_Budget_EOI_PQ__c, Total_Budget_Tender__c, 
                                    								Total_Budget_AUD__c, Total_Budget_Post_Tender__c, 
                                    								JH_Bid_Cost_of_JH_Revenue__c
                                 							FROM     Opportunity
                                 							WHERE    Id = :opportunityId];

       return allOpps;

    }
    

 	 @AuraEnabled
    public static String updateOpportunity(Opportunity opp) {
      System.debug(loggingLevel.Error, '*** opp: ' + opp);
        String resultMsg = '';
        try {
			System.debug('******************************');
            //if(!opp.isEmpty()) {
            System.debug('******************************' + opp.StageName);
               update opp; 
               //resultMsg='Success';
            //}
                
        } catch (System.DmlException ex) {
            if(ex.getDmlType(0) == StatusCode.STRING_TOO_LONG)
                resultMsg = 'Maximum character limit (' + ex.getDmlFields(0).get(0).getDescribe().getLength() + ') has been reached for ' + 
                ex.getDmlFields(0).get(0).getDescribe().getLabel() + '';
            else
                resultMsg = 'Error in updating Opp ' + ex.getMessage();
            System.debug(resultMsg + ': ' + ex.getMessage() + ' at line number: ' + ex.getLineNumber());
        }
        //System.debug(updatedKCRA[0]);
        return resultMsg;
    }

    @AuraEnabled
   public static List<Assigned_Approver__c> getAssignedApprovers(Opportunity opp) {
       Gate__c latestGateId = [SELECT id FROM Gate__c 
                              where Opportunity__c = : opp.Id 
                              and Gate_Number__c = :OpportunityHelper.getGateNumber(opp.StageName)
                              ORDER BY CreatedDate DESC
                              LIMIT 1];


        List<Assigned_Approver__c>  allApprovers = [SELECT Approver__r.Name, Approval_Level__c,Gate__c,Approval_Status__c,
                                                            Proxy_Approver__r.Name,Current_Approver__c,
                                                            Wet_Signature_Received__c, Wet_Signature_Date__c,
                                                            Approval_Comments__c,CreatedDate
                                                    from Assigned_Approver__c
                                                    where Gate__c = :latestGateID.id
                                                    order by Approval_Level__c asc];


         return allApprovers; 

    }
    @AuraEnabled
    public static String updateAssignedApprovers(List<Assigned_Approver__c> updatedAA) {
        String resultMsg = '';
        try {
            System.debug('Empty');
            System.debug('sdsdsds'+ updatedAA);
            if(!updatedAA.isEmpty()) {
                System.debug('Not Empty 0');
               update updatedAA; 
               System.debug('Not Empty');
            }
                
        } catch (System.DmlException ex) {
            if(ex.getDmlType(0) == StatusCode.STRING_TOO_LONG)
                resultMsg = 'Maximum character limit (' + ex.getDmlFields(0).get(0).getDescribe().getLength() + ') has been reached for ' + 
                ex.getDmlFields(0).get(0).getDescribe().getLabel() + '';
            else
                resultMsg = 'Error in updating AA ' + ex.getMessage();
            System.debug(resultMsg + ': ' + ex.getMessage() + ' at line number: ' + ex.getLineNumber());
        }
        //System.debug(updatedKCRA[0]);
        return resultMsg;
    }
    

   
}