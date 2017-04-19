public without sharing class OpportunityService {

    /**
     * @description Create KCRA Related List Records from KCRA Template Records
     * @return void
     **/
    public static void insertKCRAitems(List<Opportunity> newList){
        List<Key_Commercial_Risks_Approvals__c> KCRAItemsToCreate = new List<Key_Commercial_Risks_Approvals__c>();
        List<Key_Commercial_Risks_Approvals__c> KCRATemplateItems = [SELECT name,ItemNo__c,Approved__c,KCRA_Item__c,Applicable__c
                                                                  FROM Key_Commercial_Risks_Approvals__c
                                                                  WHERE RecordTypeId =: Constants.KCRATemplateRecordTypeID];    
         for(Opportunity opp: newList){
             for(Key_Commercial_Risks_Approvals__c KCRATemplateItem : KCRATemplateItems){
                 Key_Commercial_Risks_Approvals__c newKCRA = new Key_Commercial_Risks_Approvals__c(ItemNo__c=KCRATemplateItem.ItemNo__c,
                                                                                                    KCRA_Item__c=KCRATemplateItem.KCRA_Item__c ,
                                                                                                    Applicable__c=KCRATemplateItem.Applicable__c,
                                                                                                    Approved__c = false,
                                                                                                    RecordTypeId = Constants.KCRARecordTypeID,
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
    public static void insertPRAitems(List<Opportunity> newList){
        List<Project_Risk_Assessment__c> PRAItemsToCreate = new List<Project_Risk_Assessment__c>();
        List<Project_Risk_Assessment__c> PRATemplateItems = [SELECT name,category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Rating__c,Risk_Item__c,
                                                                    description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                                    Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                                    Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Selected_Indicators_With_Text__c
                                                             FROM Project_Risk_Assessment__c
                                                             WHERE RecordTypeId =: Constants.PRATemplateRecordTypeID];    
         for(Opportunity opp: newList){
             for(Project_Risk_Assessment__c PRATemplateItem : PRATemplateItems){
                 Project_Risk_Assessment__c newPRA = new Project_Risk_Assessment__c(ItemNo__c=PRATemplateItem.ItemNo__c,
                                                                                    Risk_Item__c=PRATemplateItem.Risk_Item__c ,
                                                                                    Category__c=PRATemplateItem.Category__c,
                                                                                    Is_Critical_Risk__c = PRATemplateItem.Is_Critical_Risk__c ,
                                                                                    Mitigation_Strategy__c = PRATemplateItem.Mitigation_Strategy__c,
                                                                                    Mitigation_Advice__c = PRATemplateItem.Mitigation_Advice__c,
                                                                                    //Rating__c = PRATemplateItem.Rating__c,
                                                                                    RecordTypeId = Constants.PRARecordTypeID,
                                                                                    Opportunity__c=opp.id,
                                                                                    Description__c = PRATemplateItem.Description__c,
                                                                                    Help_Text_0A__c = PRATemplateItem.Help_Text_0A__c ,Help_Text_0B__c = PRATemplateItem.Help_Text_0B__c,
                                                                                    Help_Text_0C__c = PRATemplateItem.Help_Text_0C__c ,Help_Text_1A__c = PRATemplateItem.Help_Text_1A__c,
                                                                                    Help_Text_1B__c = PRATemplateItem.Help_Text_1B__c ,Help_Text_1C__c = PRATemplateItem.Help_Text_1C__c,
                                                                                    Help_Text_2A__c = PRATemplateItem.Help_Text_2A__c ,Help_Text_2B__c = PRATemplateItem.Help_Text_2B__c,
                                                                                    Help_Text_2C__c = PRATemplateItem.Help_Text_2C__c ,Help_Text_3A__c = PRATemplateItem.Help_Text_3A__c,
                                                                                    Help_Text_3B__c = PRATemplateItem.Help_Text_3B__c ,Help_Text_3C__c = PRATemplateItem.Help_Text_3C__c
                                                                                    //Selected_Indicators__c= PRATemplateItem.Selected_Indicators__c 
                                                                                   );
                 PRAItemsToCreate.add(newPRA);
             }   
         }
         if(!PRAItemsToCreate.isEmpty())
            insert PRAItemsToCreate;
    }

	/**
     * @description manage the revenue records if the duration or start date changes (or insert)
     * @return void
     **/
    public static void manageRevenueRecords(List<Opportunity> newList, map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate){
        //gather together a list of opps that meet the criteria for revenue recalc (Insert or duration change or start date change)
        set<ID> OppsToRecalculateRevenue = new set<ID>();
        for(Opportunity opp: newList){
            if(IsInsert){
                OppsToRecalculateRevenue.add(opp.ID);
            }
            else if(IsUpdate){
                Opportunity oldOpp = oldMap.get(opp.ID);
                if((opp.Project_Duration_Months__c != null && opp.Project_Duration_Months__c != oldOpp.Project_Duration_Months__c) || (opp.Anticipated_Revenue_Start_Date__c != null && opp.Anticipated_Revenue_Start_Date__c != oldOpp.Anticipated_Revenue_Start_Date__c)){
                    OppsToRecalculateRevenue.add(opp.ID); 
                }
            }
        }

        //apply changes to the revenue records
        list<Percentage_Revenue__c> RevToUpsert = new list<Percentage_Revenue__c>();
        for(Opportunity opp: OpportunityHelper.getOpportunitiesAndRevenue(OppsToRecalculateRevenue)){
            list<Percentage_Revenue__c> Rev = opp.Percentage_Revenues__r;
            decimal numberOfMonths = opp.Project_Duration_Months__c;
            date firstRevenueDate = OpportunityHelper.getFirstRevenueStartDate(opp);

            decimal existingRevCount = 0;
            decimal maxLoop = numberOfMonths;
            
            if(Rev != null){
                existingRevCount = Rev.Size();
            }

            //set the max loop
            if(existingRevCount > numberOfMonths){
                maxLoop = existingRevCount;
            }

            for(Integer i = 0; i < maxLoop; i++) {
                decimal monthNumber = i + 1;
                string monthName = 'M' + monthNumber;
                date periodDate = firstRevenueDate.addMonths(i);

                //if the current month is a record and lower than the number of months then these are existing records that need to be active
                if(monthNumber <= existingRevCount && monthNumber <= numberOfMonths){
                    Percentage_Revenue__c PR = Rev[i];
                    PR.Period_Date__c = periodDate;
                    PR.Inactive__c = FALSE;
                    PR.Period__c = monthName;
                    RevToUpsert.add(PR);
                }
                //if the current month is above the number of months but lower than the total existing Revenue records then these need to be made inactive
                else if(monthNumber <= existingRevCount && monthNumber > numberOfMonths){
                    Percentage_Revenue__c PR = Rev[i];
                    PR.Period_Date__c = null;
                    PR.Inactive__c = TRUE;
                    PR.Period__c = null;
                    PR.Allocated__c = 0;
                    RevToUpsert.add(PR);
                }
                //if the current month is above the existing Revenue records count but below the required number of months then new records need to be created
                else if(monthNumber > existingRevCount && monthNumber <= numberOfMonths){
                    Percentage_Revenue__c PR = new Percentage_Revenue__c();
                    PR.Period_Date__c = periodDate;
                    PR.Inactive__c = FALSE;
                    PR.Period__c = monthName;
                    PR.Allocated__c = 0;
                    PR.opportunity__c = opp.Id;
                    RevToUpsert.add(PR);
                }
            }

        }

        upsert RevToUpsert;
    }

    /**
     * @description Sends the Initiate Gate Approval Notification email and the Approval Outcome email
     * @return void 
     **/
    public static void sendEmails(List<Opportunity> newList, map<Id, Opportunity> oldMap){
        Email_Alert_Class EA = new Email_Alert_Class();

        for(Opportunity Opp : newList){
            Opportunity oldOpp = oldMap.get(Opp.ID);

            //Check in progress has just been set and send in Gate started email
            if(Opp.Gate_status__c == Constants.InProgressStatus && oldOpp.Gate_status__c != Constants.InProgressStatus){
                EA.registerNewEmail(Constants.ApprovalSubmissionEmail, Opp.ID);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
            else if(Opp.TSF_Gate_status__c == Constants.InProgressStatus && oldOpp.TSF_Gate_status__c != Constants.InProgressStatus){
                EA.registerNewEmail(Constants.TSF_ApprovalSubmissionEmail, Opp.ID);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
            else if(Opp.CRA_Gate_status__c == Constants.InProgressStatus && oldOpp.CRA_Gate_status__c != Constants.InProgressStatus){
                EA.registerNewEmail(Constants.CRA_ApprovalSubmissionEmail, Opp.ID);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
                
            //Check decision made has just been set and send the Decision made email
            if(oldOpp.Previous_Gate_Status__c == Constants.NotApplicableStatus && (Opp.Previous_Gate_Status__c == Constants.ApprovedStatus || Opp.Previous_Gate_Status__c == Constants.ConditionallyApprovedStatus || Opp.Previous_Gate_Status__c == Constants.DeclinedStatus || Opp.Previous_Gate_Status__c == Constants.RestartedStatus)){
                EA.registerNewEmail(Constants.ApprovalOutcomeNotificationEmail, Opp.ID);
                EA.setCurrentEmailField_sendToBDM(TRUE);
                EA.setCurrentEmailField_sendToPDM(TRUE);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
            else if(oldOpp.Previous_Gate_TSF_Status__c == Constants.NotApplicableStatus && (Opp.Previous_Gate_TSF_Status__c == Constants.ApprovedStatus || Opp.Previous_Gate_TSF_Status__c == Constants.ConditionallyApprovedStatus || Opp.Previous_Gate_TSF_Status__c == Constants.DeclinedStatus || Opp.Previous_Gate_TSF_Status__c == Constants.RestartedStatus)){
                EA.registerNewEmail(Constants.TSF_ApprovalOutcomeNotificationEmail, Opp.ID);
                EA.setCurrentEmailField_sendToPDM(TRUE);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
            else if(oldOpp.Previous_Gate_CRA_Status__c == Constants.NotApplicableStatus && (Opp.Previous_Gate_CRA_Status__c == Constants.ApprovedStatus || Opp.Previous_Gate_CRA_Status__c == Constants.ConditionallyApprovedStatus || Opp.Previous_Gate_CRA_Status__c == Constants.DeclinedStatus || Opp.Previous_Gate_CRA_Status__c == Constants.RestartedStatus)){
                EA.registerNewEmail(Constants.CRA_ApprovalOutcomeNotificationEmail, Opp.ID);
                EA.setCurrentEmailField_sendToPDM(TRUE);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }

            //check if the Prospect has been won
            if(opp.Prospect_Status__c == Constants.TenderWonStatus && oldOpp.Prospect_Status__c != Constants.TenderWonStatus){
                EA.registerNewEmail(Constants.TenderWonEmail, Opp.ID);
                EA.setCurrentEmailField_sendToPDM(TRUE);
                EA.setCurrentEmailField_sendToBDM(TRUE);
                EA.setCurrentEmailField_sendToAllApprovers(TRUE);
            }
        }
        //Send emails
        EA.sendEmails();
    } 

    
}