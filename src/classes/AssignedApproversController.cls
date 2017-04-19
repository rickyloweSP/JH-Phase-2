public class AssignedApproversController {
	/*------------------------------------------------------------------------
 * Author:        Alex Odago
 * Company:       System Partners
 * Description:   Apex controller class for Assigned Approvers 
 *
 * Test Class:    AssignedApproversControllerTest
 * 
 * History:
 * 2017-MAR-03    Alex Odago     Created
 --------------------------------------------------------------------------*/

    
	@AuraEnabled
   public static List<Assigned_Approver__c> getAllAssignedApprovers(String gateName) {

       
       List<Assigned_Approver__c> allApprovers = [SELECT Id,Approver__r.Name,Approval_Level__c,Approval_Status__c,
                                                  Wet_Signature_Received__c,Wet_Signature_Date__c,Approval_Comments__c
												   FROM Assigned_Approver__c
                                                   WHERE Gate__c = :gateName
                                                   ORDER BY Approver__r.Name]; 

       return allApprovers;

    } 

	/*
    @AuraEnabled
    public static Project_Risk_Assessment__c getPRA(Id PRAId) {
    	Project_Risk_Assessment__c pra;
        
        if(PRAId != NULL){
            pra = [SELECT Id,name,Category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Rating__c,Risk_Item__c,
                                                             		description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                             		Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                             		Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Selected_Indicators_With_Text__c
												   FROM Project_Risk_Assessment__c
                                      WHERE Id =: PRAId ORDER BY ItemNo__c ];
 			System.debug('PRA ' + pra);       
        }
        return pra;
    } 
    @AuraEnabled
    public static String updateKCRA(List<Key_Commercial_Risks_Approvals__c> updatedKCRA) {
        String resultMsg = '';
        try {
            System.debug('Empty');
            System.debug('sdsdsds'+ updatedKCRA);
            if(!updatedKCRA.isEmpty()) {
                System.debug('Not Empty 0');
               update updatedKCRA; 
               System.debug('Not Empty');
            }
                
        } catch (System.DmlException ex) {
            if(ex.getDmlType(0) == StatusCode.STRING_TOO_LONG)
                resultMsg = 'Maximum character limit (' + ex.getDmlFields(0).get(0).getDescribe().getLength() + ') has been reached for ' + 
                ex.getDmlFields(0).get(0).getDescribe().getLabel() + '';
            else
                resultMsg = 'Error in updating KCRA ' + ex.getMessage();
            System.debug(resultMsg + ': ' + ex.getMessage() + ' at line number: ' + ex.getLineNumber());
        }
        //System.debug(updatedKCRA[0]);
        return resultMsg;
    }*/

}