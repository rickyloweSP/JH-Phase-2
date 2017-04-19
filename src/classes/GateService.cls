public without sharing class GateService {

    /**
     * @description delete the old Approver OppTeamMembers - the new ones are added in by the Assigned Approvers
     * @return 
     **/
    public static void reevaluateOppTeamMembers(list<Gate__c> newList){
        //create a set of Opportunity IDs
        set<ID> OppIDs = new set<ID>();
        for(Gate__c gate : newList){
            if(gate.Opportunity__c != null){
                OppIDs.add(gate.Opportunity__c);
            }
        }

        //query the curent Opportunity Team Members that have a role of 'Approver' and delete them
        delete OpportunityHelper.getOppTeamMemberApprovers(OppIDs);
    }


	/**
     * @description Create the Assigned Approvers from the appropriate Business Unit Approvers. This is where the 'Determine Approvers' logic is kept
     * @return void 
     **/
    public static void DetermineApprovers(list<Gate__c> newList, map<Id,Gate__c> newMap){
        list<Assigned_Approver__c> Assigned_Approvers_ToInsert = new list<Assigned_Approver__c>();
        list<Gate__Share> GateShareList = new list<Gate__Share>();
        Debug_Log_Service Debug = new Debug_Log_Service('Determine Approvers');

        set<ID> Business_Unit_Ids = new set<ID>();
        Map<ID, Gate__c> gateToOppfields = new Map<ID, Gate__c>(GateHelper.getOppFields(newMap.keySet()));

        //Add Business Groups to a list so we can query the Approvers
        for(Gate__c gate: gateToOppfields.values()){
            if(gate.Opportunity__c != null && gate.Opportunity__r.Business_Group__c != null){
                Business_Unit_Ids.add(gate.Opportunity__r.Business_Group__c);
            }

            if(gate.Opportunity__c != null && gate.Opportunity__r.Regional_Business__c != null){
                Business_Unit_Ids.add(gate.Opportunity__r.Regional_Business__c);
            }
        }

        //get the approvers using the Business Unit IDs collected above
        Map<ID, List<Assigned_Approver__c>> BusinessUnitToApproverMap = BusinessUnitService.getBusinessUnitToApproverMap(Business_Unit_Ids);

        //loop round the gate records and add the appropriate approvers
        for(Gate__c gate: newList){
            Gate__c gateWithOppFields = gateToOppfields.get(gate.ID);
            ID theBusinessUnit = null;

            //if gates 1 - 3
            if(gate.gate_number__c == '1' || gate.gate_number__c == '2' || gate.gate_number__c == '3'){
                //If gates 1 or 2 then use business group - Blueworks Diagram '4a. Determine Approvers - Gates 1 & 2'
                if(gate.gate_number__c == '1' || gate.gate_number__c == '2'){
                    theBusinessUnit = gateWithOppFields.Opportunity__r.Business_Group__c;
                }
                //If gate 3 then use the Regional Business Unit. The rest is the same as Gates 1 + 2. BW Diagram '4b. Determine Approvers - Gate 3'
                else if(gate.gate_number__c == '3'){
                    theBusinessUnit = gateWithOppFields.Opportunity__r.Regional_Business__c;
                }
                
                //if meets the threshold to add the COO
                if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Lower_Threshold__c || gateWithOppFields.Opportunity__r.Number_of_PRA_Critical_Items_Rated_3__c > 0 || gateWithOppFields.Opportunity__r.D_I_Involvement__c){
                    GateHelper.addApprovers('COO', gate, Assigned_Approvers_ToInsert);
                }

                //If meets the threshold for CEO
                if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Higher_Threshold__c || gateWithOppFields.Opportunity__r.D_I_Involvement__c){
                    GateHelper.addApprovers('CEO', gate, Assigned_Approvers_ToInsert);
                }

                //Add all the level 1 and 2 approvers
                if(BusinessUnitToApproverMap.containsKey(theBusinessUnit)){
                    for(Assigned_Approver__c AA : BusinessUnitToApproverMap.get(theBusinessUnit)){
                        if(AA.Approval_Level__c == '1' || AA.Approval_Level__c == '2'){
                            GateHelper.cloneAndAddApprovers(gate, AA, Assigned_Approvers_ToInsert);
                        }
                    }
                }
            }
            //if Gates 4 or 5
            else if(gate.gate_number__c == '4' || gate.gate_number__c == '5'){
                //gates 4 + 5 use the Regional Business Group
                theBusinessUnit = gateWithOppFields.Opportunity__r.Regional_Business__c;

                //Add all level 2 approvers for both TSF and CRA
                if(BusinessUnitToApproverMap.containsKey(theBusinessUnit)){
                    for(Assigned_Approver__c AA : BusinessUnitToApproverMap.get(theBusinessUnit)){
                        if(AA.Approval_Level__c == '2'){
                            GateHelper.cloneAndAddApprovers(gate,AA, Assigned_Approvers_ToInsert);
                        }
                    }
                }

                if(gate.Gate_Type__c == 'TSF'){
                    if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Lower_Threshold__c){
                        GateHelper.addApprovers('COO', gate, Assigned_Approvers_ToInsert);
                    }

                    if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Higher_Threshold__c){
                        GateHelper.addApprovers('CEO', gate, Assigned_Approvers_ToInsert);
                    }

                }
                else if(gate.Gate_Type__c == 'CRA'){
                    //if the opp has a critical risk item
                    if(gateWithOppFields.Opportunity__r.Number_of_PRA_Critical_Items_Rated_3__c > 0){
                        //if there is a critical risk item then add COO and use the lower threshold to decide whether the CEO needs to be added
                        GateHelper.addApprovers('COO', gate, Assigned_Approvers_ToInsert);

                        if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Lower_Threshold__c){
                            GateHelper.addApprovers('CEO', gate, Assigned_Approvers_ToInsert);
                        }
                    }
                    //if the opp doesn't have a critical risk item
                    else{
                        if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Lower_Threshold__c){
                            GateHelper.addApprovers('COO', gate, Assigned_Approvers_ToInsert);
                        }

                        if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > Constants.Approvers.Higher_Threshold__c){
                            GateHelper.addApprovers('CEO', gate, Assigned_Approvers_ToInsert);
                        }
                    }
                }
            }
            //add the BDM and/or PDM to the Gate share list
            GateHelper.ManageBDMandPDMGateShare(gateWithOppFields, GateShareList);
        
        }//end Gate For Loop
            

        //try to insert the Approvers, Reevaluate the Opp Team members + Insert Gate Share records
        try{
            if(Assigned_Approvers_ToInsert.size() > 0){
                insert Assigned_Approvers_ToInsert;
            }
            
            if(GateShareList.size() > 0){
                insert GateShareList;
            }
        }
        catch(exception e){
            Debug.logError(e);
        }
        finally{
            Debug.finishLogging();
        }
        
    }

    /**
     * @description find the gate records that were just set to Constants.InProgressStatus i.e. the approval process has been kicked off. Or set to Constants.RestartedStatus - in which case we want to update the opportunity
     * @return void 
     **/
    public static void findGatesSetToInProgressOrRestarted(list<Gate__c> newList, map<Id,Gate__c> oldMap){
        set<ID> gatesInProgress = new set<ID>();
        for(gate__c G : newList){
            gate__c oldGate = oldMap.get(G.ID);

            if((G.status__c == Constants.InProgressStatus && oldGate.status__c != Constants.InProgressStatus) || (G.status__c == Constants.RestartedStatus && oldGate.status__c != Constants.RestartedStatus)){
                gatesInProgress.add(G.ID);
            }
        }

        //find next approver for the gates that have been changed to In Progress
        if(gatesInProgress.size() > 0){
            findNextApprover(gatesInProgress);
        }
    }

    /**
     * @description finds the first or next approver from the list of approvers
     * @return void
     **/
    public static void findNextApprover(set<id> gateIds){
        if(gateIds != null && gateIds.size() > 0){
            list<Assigned_Approver__c> approversToUpdate = new list<Assigned_Approver__c>();
            list<Gate__c> gatesToUpdate = new list<Gate__c>();
            map<ID, Opportunity> OppMapToBeUpdated = new map<ID, Opportunity>();
            
            Debug_Log_Service debug = new Debug_Log_Service('Find Next Approver');

            //get Approvers for the gates
            for(Gate__c G :GateHelper.getGateAndApprovers(gateIds)){

                list<Assigned_Approver__c> AAs = G.Assigned_Approvers__r;
                debug.updateLog('*** AAs: ' + AAs);
                
                //Gate status and Opp Status fields along with the indicator for whether they need to be updated
                boolean updateGate = false;
                boolean updateOpp = false;
                string gateStatus = '';
                string oppStatus = '';

                //if the gate has manually been restarted then set the opp status to Restarted
                if(G.Status__c == Constants.RestartedStatus){
                    updateOpp = true;
                    oppStatus = Constants.RestartedStatus;
                }

                if(AAs != null && updateOpp == false){  //if update Opp is true now then skip the find next approver process
                    //loop round Assigned Approvers and check their approval
                    for(Assigned_Approver__c AA : AAs){
                        debug.updateLog('*** Debug 1 - AA: ' + AA);
                        //Assign gate status in the following order - Constants.DeclinedStatus, Constants.ResubmittedStatus, Constants.PendingApprovalStatus, Constants.ConditionallyApprovedStatus then Constants.ApprovedStatus. 
                        //Constants.DeclinedStatus trumps everything 
                        if(AA.Approval_Status__c == Constants.DeclinedStatus){
                            gateStatus = Constants.DeclinedStatus;
                            updateGate = true;
                            oppStatus = Constants.DeclinedStatus;
                            updateOpp = true;
                            debug.updateLog('*** Debug 2.a - Declined gateStatus: ' + gateStatus);
                            break;
                        }
                        //if Resubmitted but not already been Declined then set status. Note that the check for gateStatus being Declined is redundant due to break 
                        else if(AA.Approval_Status__c == Constants.ResubmittedStatus && gateStatus != Constants.DeclinedStatus){
                            gateStatus = Constants.ResubmittedStatus;
                            updateGate = true;
                            oppStatus = Constants.ResubmittedStatus;
                            updateOpp = true;
                            debug.updateLog('*** Debug 2.b - resubmitted gateStatus: ' + gateStatus);
                        }
                        //if Constants.PendingApprovalStatus and not already been Declined or resubmitted then set gate status to In Progress
                        else if(AA.Approval_Status__c == Constants.PendingApprovalStatus && gateStatus != Constants.DeclinedStatus && gateStatus != Constants.ResubmittedStatus){
                            gateStatus = Constants.InProgressStatus;
                            updateGate = false;     //don't need to update the gate status because it will already be In Progress
                            oppStatus = Constants.InProgressStatus;
                            updateOpp = false;
                            debug.updateLog('*** Debug 2.c - In Progress gateStatus: ' + gateStatus);
                        }
                        //if Conditionally Approved and not already been Declined, resubmitted or In Progress then set the status
                        else if(AA.Approval_Status__c == Constants.ConditionallyApprovedStatus && gateStatus != Constants.DeclinedStatus && gateStatus != Constants.ResubmittedStatus && gateStatus != Constants.InProgressStatus){
                            gateStatus = Constants.ConditionallyApprovedStatus;
                            updateGate = true;
                            oppStatus = Constants.ConditionallyApprovedStatus;
                            updateOpp = true;
                            debug.updateLog('*** Debug 2.d - App w/ cond gateStatus: ' + gateStatus);
                        }
                        //if Approved and not already been Declined, resubmitted, In Progress or Constants.ConditionallyApprovedStatus then set the status
                        else if(AA.Approval_Status__c == Constants.ApprovedStatus && gateStatus != Constants.DeclinedStatus && gateStatus != Constants.ResubmittedStatus && gateStatus != Constants.InProgressStatus && gateStatus != Constants.ConditionallyApprovedStatus){
                            gateStatus = Constants.ApprovedStatus;
                            updateGate = true;
                            oppStatus = Constants.ApprovedStatus;
                            updateOpp = true;
                            debug.updateLog('*** Debug 2.e - approved gateStatus: ' + gateStatus);
                        }
                    } 

                    debug.updateLog('*** Debug 3 - gateStatus: ' + gateStatus);

                    //find the next approver and mark as Current Approver unless the gate has already been determind as Declined or Resubmitted
                    if(gateStatus != Constants.DeclinedStatus && gateStatus != Constants.ResubmittedStatus){
                        for(Assigned_Approver__c AA : AAs){
                            if(AA.Approval_Status__c == Constants.PendingApprovalStatus){
                                AA.Current_Approver__c = TRUE;
                                approversToUpdate.add(AA);
                                break;
                            }
                        }
                    }
                }      

                //if the gate needs to be updated the set the status and add to the list to be updated
                if(updateGate == true){
                    G.status__c = gateStatus;
                    gatesToUpdate.add(G);
                }   

                //if the opp needs to be updated then find out which status should be updated depending on the type of gate record
                if(updateOpp == true){
                    debug.updateLog('*** opp to Update');
                    addToOppMap(OppMapToBeUpdated, oppStatus, G);
                }    

                debug.updateLog('*** OppMapToBeUpdated after method: ' + OppMapToBeUpdated);        
            }

            //try to update the Approvers + The gates
            try{
                if(approversToUpdate.size() > 0){
                    update approversToUpdate;
                }
                if(gatesToUpdate.size() > 0){
                    update gatesToUpdate;
                }
                if(OppMapToBeUpdated.values().size() > 0){
                    update OppMapToBeUpdated.values();
                }
            }
            catch(exception e){
                debug.logError(e);
            }
            finally{
                debug.finishLogging();
            }
        }
    }

    /**
     * @description Controlls the adding of the Opportunity to the to be updated map. Includes handling the possiblity of a TSF and CRA gate being updated in the same transaction
     * @param map<ID, Opportunity> OppMapToBeUpdated - the map of opportunities to be updated
     * @param string oppStatus - the new Status value of the Opportunity
     * @param gate__c G - the gate record
     * @return void
     **/
    public static void addToOppMap(map<ID, Opportunity> OppMapToBeUpdated, string oppStatus, Gate__c G){
        //set up the Opportunity to be Updated
        opportunity oppToBeUpdated = new Opportunity();
        oppToBeUpdated.ID = G.opportunity__c;

        //decide on which status we are updating
        string statusField = '';
        if(G.Gate_Type__c == 'TSF'){
            oppToBeUpdated.TSF_Gate_Status__c = oppStatus;
            oppToBeUpdated.Previous_Gate_TSF_Status__c = oppStatus;
            statusField = 'TSF';
        }
        else if(G.Gate_Type__c == 'CRA'){
            oppToBeUpdated.CRA_Gate_Status__c = oppStatus;
            oppToBeUpdated.Previous_Gate_CRA_Status__c = oppStatus;
            statusField = 'CRA';
        }
        else{
            oppToBeUpdated.Gate_Status__c = oppStatus;
            oppToBeUpdated.Previous_Gate_Status__c = oppStatus;     //Update the previous gate status fields to support the email notification fields. This is due to the Opp automatically being set to the naxt gate and the statuses reset to Not Started.
        }

        System.debug(loggingLevel.Error, '*** oppToBeUpdated: ' + oppToBeUpdated);

        //add to map. If the opp already exists (two gate records for the same opportunity TSF and CRA updated in same transaction) then update the appropriate status field
        if(OppMapToBeUpdated.containsKey(oppToBeUpdated.ID)){
            Opportunity Opp = OppMapToBeUpdated.get(oppToBeUpdated.ID);
            
            if(statusField == 'TSF'){
                Opp.TSF_Gate_Status__c = oppToBeUpdated.TSF_Gate_Status__c;
            }
            else if(statusField == 'CRA'){
                Opp.CRA_Gate_Status__c = oppToBeUpdated.CRA_Gate_Status__c;
            }
            else{
                Opp.Gate_Status__c = oppToBeUpdated.Gate_Status__c;
            }
        }
        else{
            OppMapToBeUpdated.put(oppToBeUpdated.ID, oppToBeUpdated);
        }

        System.debug(loggingLevel.Error, '*** OppMapToBeUpdated: ' + OppMapToBeUpdated);
    }


}