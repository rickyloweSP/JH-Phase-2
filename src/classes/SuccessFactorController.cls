/*------------------------------------------------------------------------
 * Author:        Alex Odago
 * Company:       System Partners
 * Description:   Apex controller class for Success Factors
 *
 * Test Class:    SuccessFactorControllerTest
 * 
 * History:
 * 2017-APR-1    Alex Odago     Created
 --------------------------------------------------------------------------*/
public class SuccessFactorController {
    
	@AuraEnabled
   public static List<Success_Factor__c> getAllSuccessFactorRecords(String LessonsLearntId) {

       
       List<Success_Factor__c> allSuccessFactors = [SELECT   Id,Name,
                                                           			RecordtypeId,
                                                           			Category__c,
                                                           			Comments__c,
                                                           			Item__c,
                                                    				Lessons_Learnt_Report__c,
                                                    Score__c,
                                                    Hidden_Score_as_Number__c,
                                                    Scoring_Help__c,
                                                    Success_Factor__c
                                 							FROM     Success_Factor__c
                                 							WHERE    Lessons_Learnt_Report__c = :LessonsLearntId
                                                           	ORDER BY item__c];

       return allSuccessFactors;

    }   
    @AuraEnabled
    public static String updateSuccessFactor(List<Key_Commercial_Risks_Approvals__c> updatedSuccessFactor) {
        String resultMsg = '';
        try {
            System.debug('Empty');
            System.debug('sdsdsds'+ updatedSuccessFactor);
            if(!updatedSuccessFactor.isEmpty()) {
                System.debug('Not Empty 0');
               update updatedSuccessFactor; 
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