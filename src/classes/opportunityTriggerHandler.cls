public class opportunityTriggerHandler extends TriggerHandler{
    public static Boolean runOnce = true;
    public static final String KCRATemplateRecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA Template').getRecordTypeId();
    public static final String KCRARecordTypeID           = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA').getRecordTypeId();
    public static final String PRATemplateRecordTypeID    = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA Template').getRecordTypeId();
    public static final String PRARecordTypeID            = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA').getRecordTypeId();
    
    public OpportunityTriggerHandler() {
        //this.setMaxLoopCount(1);
    }
    
    public override void afterInsert() {
        insertKCRAitems();  //Create KCRA Related List Records from KCRA Template Records
        insertPRAitems();   //Create PRA Related List Records from PRA Template Records
    }

    /**
     * @description Create KCRA Related List Records from KCRA Template Records
     * @return void
     **/
    private void insertKCRAitems(){
        List<Key_Commercial_Risks_Approvals__c> KCRAItemsToCreate = new List<Key_Commercial_Risks_Approvals__c>();
        List<Key_Commercial_Risks_Approvals__c> KCRATemplateItems = [SELECT name,ItemNo__c,Approved__c,KCRA_Item__c,Applicable__c
                                                                  FROM Key_Commercial_Risks_Approvals__c
                                                                  WHERE RecordTypeId =: KCRATemplateRecordTypeID];    
         for(Opportunity opp: (List<Opportunity>) Trigger.new){
             for(Key_Commercial_Risks_Approvals__c KCRATemplateItem : KCRATemplateItems){
                 Key_Commercial_Risks_Approvals__c newKCRA = new Key_Commercial_Risks_Approvals__c(ItemNo__c=KCRATemplateItem.ItemNo__c,
                                                                                                    KCRA_Item__c=KCRATemplateItem.KCRA_Item__c ,
                                                                                                    Applicable__c=KCRATemplateItem.Applicable__c,
                                                                                                    Approved__c = KCRATemplateItem.Approved__c,
                                                                                                    RecordTypeId = KCRARecordTypeID,
                                                                                                    Opportunity__c=opp.id);
                 KCRAItemsToCreate.add(newKCRA);
             }   
         }
         if(!KCRAItemsToCreate.isEmpty())
            insert KCRAItemsToCreate;
    }

    /**
     * @description Create PRA Related List Records from PRA Template Records
     * @return void
     **/
    private void insertPRAitems(){
        List<Project_Risk_Assessment__c> PRAItemsToCreate = new List<Project_Risk_Assessment__c>();
        List<Project_Risk_Assessment__c> PRATemplateItems = [SELECT name,category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Rating__c,Risk_Item__c
                                                             FROM Project_Risk_Assessment__c
                                                             WHERE RecordTypeId =: PRATemplateRecordTypeID];    
         for(Opportunity opp: (List<Opportunity>) Trigger.new){
             for(Project_Risk_Assessment__c PRATemplateItem : PRATemplateItems){
                 Project_Risk_Assessment__c newPRA = new Project_Risk_Assessment__c(ItemNo__c=PRATemplateItem.ItemNo__c,
                                                                                    Risk_Item__c=PRATemplateItem.Risk_Item__c ,
                                                                                    Category__c=PRATemplateItem.Category__c,
                                                                                    Is_Critical_Risk__c = PRATemplateItem.Is_Critical_Risk__c ,
                                                                                    Mitigation_Strategy__c = PRATemplateItem.Mitigation_Strategy__c,
                                                                                    Rating__c = PRATemplateItem.Rating__c,
                                                                                    RecordTypeId = PRARecordTypeID,
                                                                                    Opportunity__c=opp.id);
                 PRAItemsToCreate.add(newPRA);
             }   
         }
         if(!PRAItemsToCreate.isEmpty())
            insert PRAItemsToCreate;
    }


}