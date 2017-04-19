public class LessonsLearntTriggerHandler extends TriggerHandler {

	public static Boolean runOnce = true; 
    public static final String EOITemplateRecordTypeID   = Success_Factor__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Success Factor Template - EOI').getRecordTypeId();
    public static final String EOIRecordTypeID           = Lessons_Learnt_Report__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('EOI').getRecordTypeId();
    public static final String TenderTemplateRecordTypeID    = Success_Factor__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Success Factor Template - Tender').getRecordTypeId();
    public static final String TenderRecordTypeID            = Lessons_Learnt_Report__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Tender').getRecordTypeId();
    public static final String SuccessFactorRecordTypeID            = Success_Factor__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Success Factor').getRecordTypeId();
    public static boolean recursionBefore = false;
    public static boolean recursionAfter = false;
    public static boolean isTest = false;
    public list<opportunityTeamMember> OppTeamMembers = new list<opportunityTeamMember>();

    public LessonsLearntTriggerHandler() {
        //this.setMaxLoopCount(1);
    }
    public override void beforeInsert() {
        System.debug(loggingLevel.Error, '*** BEFORE INSERT **');
    }  

    public override void afterInsert() {
        System.debug(loggingLevel.Error, '*** AFTER INSERT **');
        insertSuccessFactorItems();  
       
    }

    public override void beforeUpdate() {
        System.debug(loggingLevel.Error, '*** BEFORE UPDATE **');
        if(recursionBefore == false){
            recursionBefore = true;
        }
    }   

    public override void AfterUpdate(){
        System.debug(loggingLevel.Error, '*** AFTER UPDATE **');
        if(recursionAfter == false){
            recursionAfter = true;
        }
    }
     /**
     * @description Create Success Factors Related List Records from Success Factor Template Records
     * @return void
     **/
    private void insertSuccessFactorItems(){
        List<Success_Factor__c> SuccessFactorItemsToCreate = new List<Success_Factor__c>();
        List<Success_Factor__c> SuccessFactorEOITemplateItems = [SELECT Category__c,Comments__c,Item__c,Score__c,
        																Hidden_Score_as_Number__c,Scoring_Help__c,Success_Factor__c
                                                                  FROM Success_Factor__c
                                                                  WHERE RecordTypeId =: EOITemplateRecordTypeID];    

        List<Success_Factor__c> SuccessFactorTenderTemplateItems = [SELECT Category__c,Comments__c,Item__c,Score__c,
        																Hidden_Score_as_Number__c,Scoring_Help__c,Success_Factor__c
                                                                  FROM Success_Factor__c
                                                                  WHERE RecordTypeId =: TenderTemplateRecordTypeID];   
         for(Lessons_Learnt_Report__c llrep: (List<Lessons_Learnt_Report__c>) Trigger.new){
         	if(llrep.RecordTypeId==EOIRecordTypeID){
         		for(Success_Factor__c SuccessFactorItem : SuccessFactorEOITemplateItems){
                 Success_Factor__c newSuccessFactor = new Success_Factor__c(Item__c=SuccessFactorItem.Item__c,
                                                                                                    Category__c=SuccessFactorItem.Category__c ,
                                                                                                    Comments__c=SuccessFactorItem.Comments__c,
                                                                                                    Score__c = SuccessFactorItem.Score__c,
                                                                                                    Scoring_Help__c = SuccessFactorItem.Scoring_Help__c,
                                                                                                    Success_Factor__c = SuccessFactorItem.Success_Factor__c,
                                                                                                    RecordTypeId = SuccessFactorRecordTypeID,
                                                                                                    Lessons_Learnt_Report__c=llrep.id);
                 System.debug('***************************************' + SuccessFactorItem.Scoring_Help__c);
                 SuccessFactorItemsToCreate.add(newSuccessFactor);
             	}  	
         	}
         	if(llrep.RecordTypeId==TenderRecordTypeID){
         		for(Success_Factor__c SuccessFactorItem : SuccessFactorTenderTemplateItems){
                 Success_Factor__c newSuccessFactor = new Success_Factor__c(Item__c=SuccessFactorItem.Item__c,
                                                                                                    Category__c=SuccessFactorItem.Category__c ,
                                                                                                    Comments__c=SuccessFactorItem.Comments__c,
                                                                                                    Score__c = SuccessFactorItem.Score__c,
                                                                                                    Scoring_Help__c = SuccessFactorItem.Scoring_Help__c,
                                                                                                    Success_Factor__c = SuccessFactorItem.Success_Factor__c,
                                                                                                    RecordTypeId = SuccessFactorRecordTypeID,
                                                                                                    Lessons_Learnt_Report__c=llrep.id);
                 SuccessFactorItemsToCreate.add(newSuccessFactor);
             	}  	
         	}
              
         }
         if(!SuccessFactorItemsToCreate.isEmpty())
            insert SuccessFactorItemsToCreate;

         SuccessFactorItemsToCreate.clear();
    }

}