public with sharing class opportunityService {
 static final String KCRATemplateRecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA Template').getRecordTypeId();
 static final String KCRARecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA').getRecordTypeId();
 public static void createKCRARelatedList(List<Opportunity> newOpportunities) {
     List<Key_Commercial_Risks_Approvals__c> KCRAItemsToCreate = new List<Key_Commercial_Risks_Approvals__c>();
     List<Key_Commercial_Risks_Approvals__c> KCRATemplateItems = [SELECT name,ItemNo__c,Approved__c,KCRA_Item__c,Applicable__c
                                                                  FROM Key_Commercial_Risks_Approvals__c
                                                                  WHERE RecordTypeId =: KCRATemplateRecordTypeID];
     for(Opportunity opp: newOpportunities){
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
}