public class PRAController {
	/*------------------------------------------------------------------------
 * Author:        Alex Odago
 * Company:       System Partners
 * Description:   Apex controller class for PRA 
 *
 * Test Class:    PRAControllerTest
 * 
 * History:
 * 2017-MAR-03    Alex Odago     Created
 --------------------------------------------------------------------------*/

    
	@AuraEnabled
   public static List<Project_Risk_Assessment__c> getAllPRARecords(String opportunityId) {

       
       List<Project_Risk_Assessment__c> allPRAs = [SELECT Id,name,
                                                   		  category__c,
                                                   		  Is_Critical_Risk__c,
                                                        ItemNo__c,
                                                   		  Mitigation_Strategy__c,
                                                   		  Rating__c,
                                                   		  Risk_Item__c
												   FROM Project_Risk_Assessment__c
                                                   WHERE Opportunity__c = :opportunityId
                                                   ORDER BY ItemNo__c]; 

       return allPRAs;

    }   
    /*@AuraEnabled
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