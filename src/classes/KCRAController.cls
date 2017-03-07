/*------------------------------------------------------------------------
 * Author:        Alex Odago
 * Company:       System Partners
 * Description:   Apex controller class for KCRA 
 *
 * Test Class:    KCRAControllerTest
 * 
 * History:
 * 2017-FEB-23    Alex Odago     Created
 --------------------------------------------------------------------------*/
public class KCRAController {
    
	@AuraEnabled
   public static List<Key_Commercial_Risks_Approvals__c> getAllKCRARecords(String opportunityId) {

       
       List<Key_Commercial_Risks_Approvals__c> allKCRAs = [SELECT   Id,name,
                                                           			recordtypeId,
                                                           			applicable__c,
                                                           			approved__c,
                                                           			itemno__c,
                                                           			KCRA_Item__c,Opportunity__c 
                                 							FROM     Key_Commercial_Risks_Approvals__c 
                                 							WHERE    Opportunity__c = :opportunityId
                                                           	ORDER BY itemno__c];

       return allKCRAs;

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
    }
}