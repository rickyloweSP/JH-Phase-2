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
     * @description Controls the PDM and the BDM as Opportunity Team Members
     * @return void
     **/
    public static void BDM_PDM_Opp_Team_Manager(List<Opportunity> newList, map<Id, Opportunity> oldMap, Boolean IsInsert, Boolean IsUpdate){
        list<opportunityTeamMember> OppTeamMembers = new list<opportunityTeamMember>();
        Debug_Log_Service Debug = new Debug_Log_Service('Opportunity Team Members');

        for(Opportunity opp: newList){
            boolean BDMChange = false;
            boolean PDMChange = false;

            if(IsInsert){
                BDMChange = true;
                PDMChange = true;
            }
            else if(IsUpdate){
                Opportunity oldOpp = oldMap.get(opp.ID);
                if(opp.Project_Development_Manager__c != oldOpp.Project_Development_Manager__c){
                    PDMChange = true;
                }
                if(opp.Business_Development_Manager__c != oldOpp.Business_Development_Manager__c){
                    BDMChange = true;
                }
            }

            if(opp.Project_Development_Manager__c != null && PDMChange == true){
                OpportunityTeamMember PDM = new OpportunityTeamMember(OpportunityId = opp.ID, UserId = opp.Project_Development_Manager__c, TeamMemberRole = 'PDM');
                OppTeamMembers.add(PDM);
            }
            if(opp.Business_Development_Manager__c != null && BDMChange == true && opp.stageName != Constants.Gate4Stage && opp.stageName != Constants.Gate5Stage){
                OpportunityTeamMember BDM = new OpportunityTeamMember(OpportunityId = opp.ID, UserId = opp.Business_Development_Manager__c, TeamMemberRole = 'BDM');
                OppTeamMembers.add(BDM);
            }
        }

        try{
            if(OppTeamMembers.size() > 0){
                insert OppTeamMembers;
                manageSharingForOppTeamMembers(OppTeamMembers);
            }
        }
        catch(exception e){
            debug.logError(e);
        }
        finally{
            debug.finishLogging();
        }
        
    }

    /**
     * @description manages the OpportunityShare records for the OpportunityTeamMembers This is required because the access level for the OpportunityTeamMembers is not editable
     * @return void
     **/
    public static void manageSharingForOppTeamMembers(list<OpportunityTeamMember> OppTeamMembers){
        //Get opportunities and users
        set<ID> oppIDs = new set<ID>();
        set<ID> UserIds = new set<ID>();
        for(OpportunityTeamMember OTM: OppTeamMembers) {
            oppIDs.add(OTM.OpportunityId);
            UserIds.add(OTM.UserId);
        } 

        //Update current Sharing rules to edit
        List<OpportunityShare> shares = new List<OpportunityShare>();
        for(OpportunityShare OS : OpportunityHelper.getTheOppTeamShareRules(oppIDs, UserIds)){
            OS.OpportunityAccessLevel = 'Edit';
            shares.add(OS);
        }

        update shares;
    }



    /**
     * @description Determine the gate from new
     * @return void
     **/
    public static void determineFirstGateFromNew(opportunity opp){
        //if RT = new then set the Stage to New
        if(opp.RecordTypeId == Constants.getNewRecordType()){
            opp.stageName = Constants.NewDandCStage;
        }

        //Most new Opps will be loaded as New
        if(opp.stageName == Constants.NewDandCStage){
            //determine whether gate 1 or 3
            determineGateOneOrThree(opp);
        }
        //Include logic for loading record as a specific gate. Required for Data Migration
        else if(opp.stageName == Constants.Gate1Stage || opp.stageName == Constants.Gate2Stage || opp.stageName == Constants.Gate3Stage){
            opp.TSF_Gate_Status__c = Constants.NotApplicableStatus;
            opp.CRA_Gate_Status__c = Constants.NotApplicableStatus;
            opp.Gate_Status__c = Constants.NotStartedStatus;
        }
        else if(opp.stageName == Constants.Gate4Stage || opp.stageName == Constants.Gate5Stage){
            opp.TSF_Gate_Status__c = Constants.NotStartedStatus;
            opp.CRA_Gate_Status__c = Constants.NotStartedStatus;
            opp.Gate_Status__c = Constants.NotApplicableStatus;
        }
    }

    /**
     * @description Determine whether the record goes into gate 1 or gate 3
     * @return void
     **/
    public static void determineGateOneOrThree(opportunity opp){
        //if OPV above gate 1 threshold OR below and Is Minor works not true then go to gate 1
        if(opp.Overall_Prospect_Value__c > Constants.Approvers.Gate_1_Entry_Threshold__c || opp.Is_Minor_Works__c == false){
            opp.StageName = Constants.Gate1Stage;
            opp.Gate_Status__c = Constants.NotStartedStatus;
        }
        //If the OPV is less than the gate 1 threshold and Is Minor works is checked then take to gate 3
        else if(opp.Overall_Prospect_Value__c < Constants.Approvers.Gate_1_Entry_Threshold__c && opp.Is_Minor_Works__c == true){
            opp.StageName = Constants.Gate3Stage;
            opp.Gate_Status__c = Constants.NotStartedStatus;
        }
        opp.TSF_Gate_Status__c = Constants.NotApplicableStatus;
        opp.CRA_Gate_Status__c = Constants.NotApplicableStatus;
    }
    

    /**
     * @description controls the owner of the opportunity 
     * @return void
     **/
    public static void BDM_PDM_Owner_Manager(opportunity opp){
        if(opp.stageName == Constants.Gate1Stage || opp.stageName == Constants.Gate2Stage){
            if(opp.Business_Development_Manager__c != null){
                opp.ownerId = opp.Business_Development_Manager__c;
            }
        }
        else if(opp.stageName == Constants.Gate3Stage || opp.stageName == Constants.Gate4Stage || opp.stageName == Constants.Gate5Stage){
            if(opp.Project_Development_Manager__c != null){
                opp.ownerId = opp.Project_Development_Manager__c;
            }
        }
    }


    /**
     * @description validation rule to prevent users changing the stage
     * @return void
     **/
    public static void validationRuleOnStageChange(opportunity opp, opportunity oldOpp){   
        //Validation rule doesn't apply to sys admins
        if(UserInfo.getProfileId() != Constants.getProfileID('System Administrator')){

            if( (oldOpp.stageName == Constants.Gate5Stage && opp.stageName == Constants.Gate4Stage) ||
                (oldOpp.stageName == Constants.Gate4Stage && opp.stageName == Constants.Gate3Stage) ||
                (oldOpp.stageName == Constants.Gate3Stage && opp.stageName == Constants.Gate2Stage) ||
                (oldOpp.stageName == Constants.Gate2Stage && opp.stageName == Constants.Gate1Stage)){
                //do nothing as these are the accepted gate changes
            }
            else{
                //any other change is rejected
                opp.addError('You can only change the Gate Stage backwards. The approver lifecycle will determine the next Gate Stage');
            }
        }
    }

    /**
     * @description Determine the next gate. 
     * @return void          
     **/
    public static void determineGate(opportunity opp, opportunity oldOpp){
        System.debug(loggingLevel.Error, '*** TEST Determine Gate opp: ' + opp);
        System.debug(loggingLevel.Error, '*** TEST Determine Gate OLD opp Stage: ' + oldopp.stageName);
        System.debug(loggingLevel.Error, '*** TEST Determine Gate opp Stage: ' + opp.stageName);
        System.debug(loggingLevel.Error, '*** TEST Determine Gate OLD oppGate Status: ' + oldOpp.Gate_Status__c);
        System.debug(loggingLevel.Error, '*** TEST Determine Gate oppGate Status: ' + opp.Gate_Status__c);
     

        //If new then check if meets the criteria for Gate 1
        if(Opp.StageName == Constants.NewDandCStage){
            Opp.Previous_Stage__c = Constants.NewDandCStage;
            determineFirstGateFromNew(opp);
        }
        //If gate 1 then if approved then either set to gate 2 or gate 3 depending on whether EOI/PQ/Non-Bonding required.
        else if(Opp.StageName == Constants.Gate1Stage){
            if(opp.Gate_Status__c == Constants.ApprovedStatus || opp.Gate_Status__c == Constants.ConditionallyApprovedStatus){
                Opp.Previous_Stage__c = Constants.Gate1Stage;   //When a gate is approved the Previous stage is set to the previous stage. This is to support the email notification that goes out for approval.
                if(opp.Non_Binding_Proposal_Required__c){
                    opp.StageName = Constants.Gate2Stage;
                }
                else{
                    opp.StageName = Constants.Gate3Stage;
                }
                opp.Gate_Status__c = Constants.NotStartedStatus;
            }
            //If Gate Declined then set the previous stage to current stage. To support the Outcome notification
            else if(opp.Gate_Status__c == Constants.DeclinedStatus || opp.Gate_Status__c == Constants.ResubmittedStatus || opp.Gate_Status__c == Constants.RestartedStatus){
                Opp.Previous_Stage__c = Constants.Gate1Stage;   //When a gate is rejected the Previous stage is set to the previous stage. This is to support the email notification that goes out for approval.
            }
            //If Gate has not been started yet then run the determine first gate
            else if(opp.Gate_Status__c == Constants.NotStartedStatus){
                //determine whether gate 1 or 3
                determineGateOneOrThree(opp);
            }
            opp.TSF_Gate_Status__c = Constants.NotApplicableStatus;
            opp.CRA_Gate_Status__c = Constants.NotApplicableStatus;

            //If the Gate has been changed then reset the Gate Status
            if(oldopp.StageName != Opp.StageName){
                opp.Gate_Status__c = Constants.NotStartedStatus;
            }
        }
        //If gate 2 and approved then move to gate 3. If Declined then do nothing
        else if(Opp.StageName == Constants.Gate2Stage){
            if(opp.Gate_Status__c == Constants.ApprovedStatus || opp.Gate_Status__c == Constants.ConditionallyApprovedStatus){
                Opp.Previous_Stage__c = Constants.Gate2Stage;
                opp.StageName = Constants.Gate3Stage;
                opp.Gate_Status__c = Constants.NotStartedStatus;
            }
            else if(opp.Gate_Status__c == Constants.DeclinedStatus || opp.Gate_Status__c == Constants.ResubmittedStatus || opp.Gate_Status__c == Constants.RestartedStatus){
                Opp.Previous_Stage__c = Constants.Gate2Stage;
            }
            opp.TSF_Gate_Status__c = Constants.NotApplicableStatus;
            opp.CRA_Gate_Status__c = Constants.NotApplicableStatus;

            //If the Gate has been changed then reset the Gate Status
            if(oldopp.StageName != Opp.StageName){
                opp.Gate_Status__c = Constants.NotStartedStatus;
            }
        }
        //If gate 3 and approved then move to gate 4. If Declined then do nothing
        else if(Opp.StageName == Constants.Gate3Stage){
            if(opp.Gate_Status__c == Constants.ApprovedStatus || opp.Gate_Status__c == Constants.ConditionallyApprovedStatus){
                Opp.Previous_Stage__c = Constants.Gate3Stage;
                opp.StageName = Constants.Gate4Stage;
                opp.TSF_Gate_Status__c = Constants.NotStartedStatus;
                opp.CRA_Gate_Status__c = Constants.NotStartedStatus;
                opp.Gate_Status__c = Constants.NotApplicableStatus;
                opp.Prospect_status__c = Constants.TenderInPreperationStatus;
            }
            else if(opp.Gate_Status__c == Constants.DeclinedStatus || opp.Gate_Status__c == Constants.ResubmittedStatus || opp.Gate_Status__c == Constants.RestartedStatus){
                Opp.Previous_Stage__c = Constants.Gate3Stage;
            }

            //If the Gate has been changed then reset the Gate Status
            if(oldopp.StageName != Opp.StageName){
                opp.Gate_Status__c = Constants.NotStartedStatus;
            }
        }
        //If gate 4 then both TSF and CRA approval is required to move to gate 5. 
        else if(Opp.StageName == Constants.Gate4Stage){
            //if both TSF and CRA are approved then push to next gate
            if((opp.TSF_Gate_Status__c == Constants.ApprovedStatus || opp.TSF_Gate_Status__c == Constants.ConditionallyApprovedStatus) && (opp.CRA_Gate_Status__c == Constants.ApprovedStatus || opp.CRA_Gate_Status__c == Constants.ConditionallyApprovedStatus)){
                Opp.Previous_Stage__c = Constants.Gate4Stage;
                opp.StageName = Constants.Gate5Stage;
                opp.TSF_Gate_Status__c = Constants.NotStartedStatus;
                opp.CRA_Gate_Status__c = Constants.NotStartedStatus;
                opp.Prospect_status__c = Constants.TenderSubmittedStatus;
            }
            else if(opp.TSF_Gate_Status__c == Constants.DeclinedStatus || opp.TSF_Gate_Status__c == Constants.ResubmittedStatus || opp.TSF_Gate_Status__c == Constants.RestartedStatus || opp.CRA_Gate_Status__c == Constants.DeclinedStatus || opp.CRA_Gate_Status__c == Constants.ResubmittedStatus || opp.CRA_Gate_Status__c == Constants.RestartedStatus){
                Opp.Previous_Stage__c = Constants.Gate4Stage;
            }
            opp.Gate_Status__c = Constants.NotApplicableStatus;

            //If the Gate has been changed then reset the Gate Status
            if(oldopp.StageName != Opp.StageName){
                opp.TSF_Gate_Status__c = Constants.NotStartedStatus;
                opp.CRA_Gate_Status__c = Constants.NotStartedStatus;
            }
        }
        //If gate 5 then both TSF and CRA approval is required. 
        else if(Opp.StageName == Constants.Gate5Stage){
            if((opp.TSF_Gate_Status__c == Constants.ApprovedStatus || opp.TSF_Gate_Status__c == Constants.ConditionallyApprovedStatus) && (opp.CRA_Gate_Status__c == Constants.ApprovedStatus || opp.CRA_Gate_Status__c == Constants.ConditionallyApprovedStatus)){
                Opp.Previous_Stage__c = Constants.Gate5Stage;
                opp.StageName = Constants.ClosedWonStage;
                opp.Prospect_status__c = Constants.TenderWonStatus;
            }
            else if(opp.TSF_Gate_Status__c == Constants.DeclinedStatus || opp.TSF_Gate_Status__c == Constants.ResubmittedStatus || opp.TSF_Gate_Status__c == Constants.RestartedStatus || opp.CRA_Gate_Status__c == Constants.DeclinedStatus || opp.CRA_Gate_Status__c == Constants.ResubmittedStatus || opp.CRA_Gate_Status__c == Constants.RestartedStatus){
                Opp.Previous_Stage__c = Constants.Gate5Stage;
            }
            opp.Gate_Status__c = Constants.NotApplicableStatus;

            //If the Gate has been changed then reset the Gate Status
            if(oldopp.StageName != Opp.StageName){
                opp.TSF_Gate_Status__c = Constants.NotStartedStatus;
                opp.CRA_Gate_Status__c = Constants.NotStartedStatus;
            }
        }
    }

    /**
     * @description Resets the Old Gate values when the new gate is initiated
     * @return void
     **/
    public static void ResetPreviousGateValues(opportunity opp, opportunity oldOpp){
        
        //the gate for gates 1 - 3 has been initiated
        if(oldOpp.Gate_Status__c != Constants.InitiatedStatus && opp.Gate_Status__c == Constants.InitiatedStatus){
            opp.Previous_Gate_Status__c = Constants.NotApplicableStatus;
        }
        //the TSF gate has been initiated
        if(oldOpp.TSF_Gate_Status__c != Constants.InitiatedStatus && opp.TSF_Gate_Status__c == Constants.InitiatedStatus){
            opp.Previous_Gate_TSF_Status__c = Constants.NotApplicableStatus;
        }
        //the CRA gate has been initiated
        if(oldOpp.CRA_Gate_Status__c != Constants.InitiatedStatus && opp.CRA_Gate_Status__c == Constants.InitiatedStatus){
            opp.Previous_Gate_CRA_Status__c = Constants.NotApplicableStatus;
        }
    }
    
    
    /**
     * @description controls the gate process through gate status changes. A Lightning component will do the changing of the appropriate status
     * @return void
     **/
    public static void ApprovalProcessOrchestrator(List<Opportunity> newList, map<Id, Opportunity> oldMap){
        Debug_Log_Service Debug = new Debug_Log_Service('Approval Process Orchestrator');

        list<gate__c> gatesToUpsert = new list<gate__c>();
        set<id> OppsToStartApprovalProcess = new set<id>();

        for(Opportunity opp: newList){
            Opportunity oldOpp = oldMap.get(opp.ID);

            string gateNumber = OpportunityHelper.getGateNumber(opp.stageName);

            Debug.updateLog('*** TEST ApprovalProcessOrchestrator opp: ' + opp);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator opp Stage: ' + opp.stageName);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator old opp Stage: ' + oldopp.stageName);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator oppGate Status: ' + opp.Gate_Status__c);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator OLD oppGate Status: ' + oldOpp.Gate_Status__c);

            if(opp.stageName == Constants.Gate1Stage || opp.stageName == Constants.Gate2Stage || opp.stageName == Constants.Gate3Stage){
                //See if the gate Status has been initalised - meaning the user has initialised the approval process i.e. creating the Approvers. Users can initialise the approval process from from Not Started, Resubmitted or Restarted
                if((oldOpp.Gate_Status__c == Constants.NotStartedStatus || oldOpp.Gate_Status__c == Constants.ResubmittedStatus || oldOpp.Gate_Status__c == Constants.RestartedStatus || oldOpp.Gate_Status__c == Constants.DeclinedStatus) && opp.Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName, 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID, OwnerId = opp.OwnerId));
                }
                //see if the Gate Status has been In Progress - i.e. triggering the approval process
                else if(oldOpp.Gate_Status__c == Constants.InitiatedStatus && opp.Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }
            else if(opp.stageName == Constants.Gate4Stage || opp.stageName == Constants.Gate5Stage){    
                //See if the CRA Status has been initalised from Not Started, Resubmitted or Restarted
                if((oldOpp.CRA_Gate_Status__c == Constants.NotStartedStatus || oldOpp.CRA_Gate_Status__c == Constants.ResubmittedStatus || oldOpp.CRA_Gate_Status__c == Constants.RestartedStatus || oldOpp.CRA_Gate_Status__c == Constants.DeclinedStatus) && opp.CRA_Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName + ' - CRA', 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'CRA', OwnerId = opp.OwnerId));
                }
                //see if the CRA Status has been In Progress
                else if(oldOpp.CRA_Gate_Status__c == Constants.InitiatedStatus && opp.CRA_Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }

                //See if the TSF Status has been initalised from Not Started, Resubmitted or Restarted
                if((oldOpp.TSF_Gate_Status__c == Constants.NotStartedStatus || oldOpp.TSF_Gate_Status__c == Constants.ResubmittedStatus || oldOpp.TSF_Gate_Status__c == Constants.RestartedStatus || oldOpp.TSF_Gate_Status__c == Constants.DeclinedStatus) && opp.TSF_Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName + ' - TSF', 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'TSF', OwnerId = opp.OwnerId));
                }
                //see if the TSF Status has been In Progress
                else if(oldOpp.TSF_Gate_Status__c == Constants.InitiatedStatus && opp.TSF_Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }
        }

        for(Opportunity Opp: OpportunityHelper.getOpportunitiesAndInitiatedGates(OppsToStartApprovalProcess)){

            List<gate__c> gates = Opp.Gates__r;
            if(gates != null){
                //If Gate Status is set to In Progress then find the appropriate gate record and set the status to Constants.InProgressStatus to start the approval process
                if(Opp.Gate_Status__c == Constants.InProgressStatus){
                    for(gate__c gate : gates){
                        if(gate.Gate_Number__c == OpportunityHelper.getGateNumber(opp.stageName)){
                            gate.status__c = Constants.InProgressStatus;
                            gatesToUpsert.add(gate);
                            break;
                        }
                    }
                }
                else{
                    if(Opp.TSF_Gate_Status__c == Constants.InProgressStatus){
                        for(gate__c gate : gates){
                            if(gate.Gate_Number__c == OpportunityHelper.getGateNumber(opp.stageName) && gate.Gate_Type__c == 'TSF'){
                                gate.status__c = Constants.InProgressStatus;
                                gatesToUpsert.add(gate);
                                break;
                            }
                        }
                    }

                    if(Opp.CRA_Gate_Status__c == Constants.InProgressStatus){
                        for(gate__c gate : gates){
                            if(gate.Gate_Number__c == OpportunityHelper.getGateNumber(opp.stageName) && gate.Gate_Type__c == 'CRA'){
                                gate.status__c = Constants.InProgressStatus;
                                gatesToUpsert.add(gate);
                                break;
                            }
                        }
                    }
                }              
            }   
        }

        try{
            upsert gatesToUpsert;
        }
        catch(exception e){
            Debug.logError(e);
        }
        finally{
            Debug.finishLogging();
        }

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