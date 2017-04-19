/*------------------------------------------------------------------------
 * Authors:       Alex Odago, Ricky Lowe
 * Company:       System Partners
 * Description:   Apex Trigger Handler for Opportunity object
 *
 * Test Class:    
 * 
 * History:
 * 2017-MAR-03    Alex Odago     Created
 * 2017-MAR-10    Ricky Lowe     Added logic for Prospect Lifecycle and Approval
 * 2017-MAR-13    Ricky Lowe     Commented out logic for Prospect Lifecycle and Approval so no issues arise while I am away
 * 2017-APR-18    Ricky Lowe     Moved logic to OpportunityService and added Logic to manage Revenue
 --------------------------------------------------------------------------*/
public class OpportunityTriggerHandler extends TriggerHandler{
    public static boolean recursionBefore = false;
    public static boolean recursionAfter = false;
    public list<opportunityTeamMember> OppTeamMembers = new list<opportunityTeamMember>();

    public OpportunityTriggerHandler() {

    }

    public override void beforeInsert() {
        System.debug(loggingLevel.Error, '*** BEFORE INSERT **');
        onBeforeInsertMethods();
    }  

    public override void afterInsert() {
        System.debug(loggingLevel.Error, '*** AFTER INSERT **');
        OpportunityService.insertKCRAitems((list<Opportunity>) Trigger.New);    //Create KCRA Related List Records from KCRA Template Records
        OpportunityService.insertPRAitems((list<Opportunity>) Trigger.New);     //Create PRA Related List Records from PRA Template Records
        onAfterInsertMethods();
        manageSharingForOppTeamMembers();
        OpportunityService.manageRevenueRecords((list<Opportunity>) Trigger.New, (map<Id,Opportunity>) Trigger.OldMap, Trigger.IsInsert, Trigger.IsUpdate);
    }

    public override void beforeUpdate() {
        System.debug(loggingLevel.Error, '*** BEFORE UPDATE **');
        if(recursionBefore == false){
            onBeforeUpdateMethods();
            recursionBefore = true;
        }
    }   

    public override void AfterUpdate(){
        System.debug(loggingLevel.Error, '*** AFTER UPDATE **');
        if(recursionAfter == false){
            ApprovalProcessOrchestrator();
            manageSharingForOppTeamMembers();
            OpportunityService.sendEmails((list<Opportunity>) Trigger.New, (map<Id,Opportunity>) Trigger.OldMap);
            OpportunityService.manageRevenueRecords((list<Opportunity>) Trigger.New, (map<Id,Opportunity>) Trigger.OldMap, Trigger.IsInsert, Trigger.IsUpdate);
            recursionAfter = true;
        }
    } 


    /**
     * @description Before Insert Methods - Determine Gates on insert + Determine the owner of the Opp
     * @return void
     **/
    private void onBeforeInsertMethods(){
        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            determineFirstGateFromNew(opp);       //determine whether the Prospect goes into gate 1 or 3
            BDM_PDM_Owner_Manager(opp);         //Determine the owner based on the gate
        }
    }


    /**
     * @description After Insert methods - manage Opp Team Members
     * @return void
     **/
    private void onAfterInsertMethods(){
        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            BDM_PDM_Opp_Team_Manager(opp);      //Manage the opportunity team members for the PDM and the BDM
        }
    }


    /**
     * @description controls the creation of the PDM and the BDM as Opportunity Team Members
     * @return void
     **/
    private void BDM_PDM_Opp_Team_Manager(opportunity opp){
        boolean BDMChange = false;
        boolean PDMChange = false;

        if(trigger.IsInsert){
            BDMChange = true;
            PDMChange = true;
        }
        else if(trigger.IsUpdate){
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);
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

    /**
     * @description controls the owner of the opportunity 
     * @return void
     **/
    private void BDM_PDM_Owner_Manager(opportunity opp){
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
     * @description manages the insert and deletion of the Opportunity Team Members as well as their sharing
     * @return void
     **/
    private void manageSharingForOppTeamMembers(){
        if(OppTeamMembers.size() > 0){
            insert OppTeamMembers;

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
    }

    /**
     * @description Determine the gate from new
     * @return void
     **/
    private static void determineFirstGateFromNew(opportunity opp){
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
    private static void determineGateOneOrThree(opportunity opp){
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



    private void onBeforeUpdateMethods(){
        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            validationRuleOnStageChange(opp);   //Validation rule to prevent users changing the stage  
            determineGate(opp);                 //determines the gate
            BDM_PDM_Owner_Manager(opp);         //set the owner - PDM or BDM
            ResetPreviousGateValues(opp);       //Reset the old gate values once the new gate has been initiated
        }
    }


     /**
     * @description validation rule to prevent users changing the stage
     * @return void
     **/
    private void validationRuleOnStageChange(opportunity opp){   
        Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);

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
     *          
     *          
     *          
     **/
    private void determineGate(opportunity opp){
        Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);

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
    private void ResetPreviousGateValues(opportunity opp){
        Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);
        
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
    private void ApprovalProcessOrchestrator(){
        Debug_Log_Service Debug = new Debug_Log_Service('Approval Process Orchestrator');

        list<gate__c> gatesToUpsert = new list<gate__c>();
        set<id> OppsToStartApprovalProcess = new set<id>();

        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);

            string gateNumber = OpportunityHelper.getGateNumber(opp.stageName);

            Debug.updateLog('*** TEST ApprovalProcessOrchestrator opp: ' + opp);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator opp Stage: ' + opp.stageName);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator old opp Stage: ' + oldopp.stageName);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator oppGate Status: ' + opp.Gate_Status__c);
            Debug.updateLog('*** TEST ApprovalProcessOrchestrator OLD oppGate Status: ' + oldOpp.Gate_Status__c);

            if(opp.stageName == Constants.Gate1Stage || opp.stageName == Constants.Gate2Stage || opp.stageName == Constants.Gate3Stage){
                //See if the gate Status has been initalised - meaning the user has initialised the approval process i.e. creating the Approvers. Users can initialise the approval process from from Not Started, Resubmitted or Restarted
                if((oldOpp.Gate_Status__c == Constants.NotStartedStatus || oldOpp.Gate_Status__c == Constants.ResubmittedStatus || oldOpp.Gate_Status__c == Constants.RestartedStatus || oldOpp.Gate_Status__c == Constants.DeclinedStatus) && opp.Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName, 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID));
                }
                //see if the Gate Status has been In Progress - i.e. triggering the approval process
                else if(oldOpp.Gate_Status__c == Constants.InitiatedStatus && opp.Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }
            else if(opp.stageName == Constants.Gate4Stage || opp.stageName == Constants.Gate5Stage){    
                //See if the CRA Status has been initalised from Not Started, Resubmitted or Restarted
                if((oldOpp.CRA_Gate_Status__c == Constants.NotStartedStatus || oldOpp.CRA_Gate_Status__c == Constants.ResubmittedStatus || oldOpp.CRA_Gate_Status__c == Constants.RestartedStatus || oldOpp.CRA_Gate_Status__c == Constants.DeclinedStatus) && opp.CRA_Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName + ' - CRA', 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'CRA'));
                }
                //see if the CRA Status has been In Progress
                else if(oldOpp.CRA_Gate_Status__c == Constants.InitiatedStatus && opp.CRA_Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }

                //See if the TSF Status has been initalised from Not Started, Resubmitted or Restarted
                if((oldOpp.TSF_Gate_Status__c == Constants.NotStartedStatus || oldOpp.TSF_Gate_Status__c == Constants.ResubmittedStatus || oldOpp.TSF_Gate_Status__c == Constants.RestartedStatus || oldOpp.TSF_Gate_Status__c == Constants.DeclinedStatus) && opp.TSF_Gate_Status__c == Constants.InitiatedStatus){
                    gatesToUpsert.add(new gate__c(name = Util.ConcatanateStringLength(opp.name + ' - ' + opp.stageName + ' - TSF', 80), Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'TSF'));
                }
                //see if the TSF Status has been In Progress
                else if(oldOpp.TSF_Gate_Status__c == Constants.InitiatedStatus && opp.TSF_Gate_Status__c == Constants.InProgressStatus){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }

            BDM_PDM_Opp_Team_Manager(opp);      //Control the opp team members
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


}