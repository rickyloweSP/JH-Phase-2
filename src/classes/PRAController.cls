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

       //Rating__c,Selected_Indicators_With_Text_Combined__c
       List<Project_Risk_Assessment__c> allPRAs = [SELECT Id,name,Category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Risk_Item__c,
                                                             		Description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                             		Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                             		Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Rating__c,Selected_Indicators_With_Text_Combined__c
												   FROM Project_Risk_Assessment__c
                                                   WHERE Opportunity__c = :opportunityId
                                                   ORDER BY ItemNo__c]; 

       return allPRAs;

    } 

    @AuraEnabled
    public static Project_Risk_Assessment__c getPRAOffset(String opportunityId, integer offset){
        return [SELECT Id,name,Category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Risk_Item__c,
                        Description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                        Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                        Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Rating__c,Selected_Indicators_With_Text_Combined__c
       FROM Project_Risk_Assessment__c
       WHERE Opportunity__c = :opportunityId
       ORDER BY ItemNo__c 
       LIMIT 1
       OFFSET :offset]; 
    }


    @AuraEnabled
    public static Project_Risk_Assessment__c getPRA(Id PRAId) {
    	Project_Risk_Assessment__c pra;
        
        if(PRAId != NULL){
            pra = [SELECT Id,name,Category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Risk_Item__c,
                                                             		Description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                             		Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                             		Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Rating__c,Selected_Indicators_With_Text_Combined__c
												   FROM Project_Risk_Assessment__c
                                      WHERE Id =: PRAId ORDER BY ItemNo__c ];
 			System.debug('PRA ' + pra);       
        }
        return pra;
    } 
    @AuraEnabled
    public static String updatePRA(Project_Risk_Assessment__c updatedPRA) {
        Project_Risk_Assessment__c testEmptyPRA = new Project_Risk_Assessment__c();
        String resultMsg = '';
        try {
            System.debug('Empty');
            System.debug('sdsdsds'+ updatedPRA);
            if(updatedPRA!=testEmptyPRA) {

               update updatedPRA; 

            }
                
        } catch (System.DmlException ex) {
            if(ex.getDmlType(0) == StatusCode.STRING_TOO_LONG)
                resultMsg = 'Maximum character limit (' + ex.getDmlFields(0).get(0).getDescribe().getLength() + ') has been reached for ' + 
                ex.getDmlFields(0).get(0).getDescribe().getLabel() + '';
            else
                resultMsg = 'Error in updating PRA ' + ex.getMessage();
            System.debug(resultMsg + ': ' + ex.getMessage() + ' at line number: ' + ex.getLineNumber());
        }
        //System.debug(updatedKCRA[0]);
        return resultMsg;
    }
    @AuraEnabled
    public static String[] getIndicators() {
        List<String> results = new List<String>();
        //results.add('A');
        
        //results.add('X');
        Schema.DescribeFieldResult fieldResult = Project_Risk_Assessment__c.Selected_Indicators__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple)
            results.add(f.getValue());
        return results;
    }
    /*
    @AuraEnabled
   public static string getIndicators(String opportunityId) {

       //Rating__c,Selected_Indicators_With_Text_Combined__c
       List<Project_Risk_Assessment__c> allPRAs = [SELECT Id,name,Category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Risk_Item__c,
                                                                    Description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                                    Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                                    Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Rating__c,Selected_Indicators_With_Text_Combined__c
                                                   FROM Project_Risk_Assessment__c
                                                   WHERE Opportunity__c = :opportunityId
                                                   ORDER BY ItemNo__c]; 

       return allPRAs;

    } */

}