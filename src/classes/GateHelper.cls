public without sharing class GateHelper {
	/**
     * @description returns a list of gate records for a single opportunity Id
     * @return list of Gate records
     **/
    public static list<Gate__c> getGatesForOpps(ID OppID){
        return getGatesForOpps(new set<ID>{OppID});
    }

    /**
     * @description returns a list of gate records for a set of opportunity Ids
     * @return list of Gate records
     **/
    public static list<Gate__c> getGatesForOpps(set<ID> OppIDs){
        return [SELECT Id,Status__c 
                    FROM Gate__c
                    WHERE ID IN :oppIDs];
    }


    /**
     * @description Gets a List of gate records with the Opportunity fields
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getOppFields(set<id> gateIds){
        return [SELECT ID, gate_Number__c, Opportunity__r.Business_Development_Manager__c,Opportunity__r.Project_Development_Manager__c,Opportunity__r.Business_Group__c, Opportunity__r.Regional_Business__c, Opportunity__r.Overall_Prospect_Value__c, Opportunity__r.Number_of_PRA_Critical_Items_Rated_3__c, Opportunity__r.D_I_Involvement__c, Opportunity__c FROM gate__c WHERE ID IN : gateIds];
    }


    /**
     * @description Gets a List of gate records along with a list of approvers. In Progress and Restarted Gates only
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getInprogressGateAndApprovers(set<id> gateIds){
        return [SELECT ID,Status__c,Gate_Type__c,opportunity__c,opportunity__r.CRA_Gate_Status__c, opportunity__r.TSF_Gate_Status__c, opportunity__r.Gate_Status__c,opportunity__r.Prospect_Status__c,   
                   (SELECT Approval_Level__c,Approval_Status__c,Approver__c,Current_Approver__c,Gate__c,Id,Wet_Signature_Received__c
                    FROM Assigned_Approvers__r 
                    ORDER BY Approval_Level__c ASC) 
                FROM Gate__c 
                WHERE ID IN: gateIds AND (status__c = :Constants.InProgressStatus OR status__c = :Constants.RestartedStatus)];
    }

    /**
     * @description Gets a List of gate records along with a list of approvers. 
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getGateAndApprovers(id gateId){
        return getGateAndApprovers(new set<id>{gateId});
    }

    /**
     * @description Gets a List of gate records along with a list of approvers. 
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getGateAndApprovers(set<id> gateIds){
        return [SELECT ID,Status__c,Gate_Type__c,opportunity__c,opportunity__r.CRA_Gate_Status__c, opportunity__r.TSF_Gate_Status__c, opportunity__r.Gate_Status__c,opportunity__r.Prospect_Status__c,   
                   (SELECT Approval_Level__c,Approval_Status__c,Approver__c,Current_Approver__c,Gate__c,Id,Wet_Signature_Received__c,Approver__r.Name,Approver_Role__c,Decision_Date__c,Approval_Comments__c,Approval_Conditions__c
                    FROM Assigned_Approvers__r 
                    ORDER BY Approval_Level__c ASC) 
                FROM Gate__c 
                WHERE ID IN: gateIds];
    }

    /**
     * @description Gets the approvers for a given gate. Not bulkified so only to be used by Visualforce Controller
     * @return 
     **/
    public static list<Assigned_Approver__c> getApproversForGate(ID gateID){
        for(Gate__c G : GateHelper.getGateAndApprovers(gateID)){
            return G.Assigned_Approvers__r;
        }
        return new list<Assigned_Approver__c>();
    }


    /**
     * @description Gets a List of gate records along with a list of approvers from an opporuniy ID
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getGateAndApproversFromOpp(id OppID){
        return getGateAndApproversFromOpp(new set<ID>{OppID});
    }

    /**
     * @description Gets a List of gate records along with a list of approvers from the opporunity IDs
     * @return List<Gate__c>
     **/
    public static List<Gate__c> getGateAndApproversFromOpp(set<id> OppIDs){
        return [SELECT ID,Status__c,Gate_Type__c,opportunity__c,opportunity__r.CRA_Gate_Status__c, opportunity__r.TSF_Gate_Status__c, opportunity__r.Gate_Status__c,opportunity__r.Prospect_Status__c,   
                   (SELECT Approval_Level__c,Approval_Status__c,Approver__c,Current_Approver__c,Gate__c,Id,Wet_Signature_Received__c
                    FROM Assigned_Approvers__r 
                    ORDER BY Approval_Level__c ASC) 
                FROM Gate__c 
                WHERE Opportunity__c IN: OppIDs];
    }

    /**
     * @description creates approver gate share record from the gate id and the user id
     * @return 
     **/
    public static Gate__Share createGateShare(ID gateID, ID UserID, String shareType){
        Gate__Share share = new Gate__Share();
        share.ParentId = gateID;
        share.UserOrGroupId = UserID;
        share.AccessLevel = 'edit';
        share.RowCause = shareType;
        return share;
    }

    /**
     * @description Create GateShare records for PDM and BDM
     * @return list of Gate Share records for the gate input
     **/
    public static list<Gate__Share> ManageBDMandPDMGateShare(Gate__c gate){
        list<Gate__Share> GateShareList = new list<Gate__Share>();
        
        //Add PDM to Gate Share list no matter what gate we are in
        if(gate.Opportunity__r.Project_Development_Manager__c != null){
            GateShareList.add(createGateShare(gate.ID, gate.Opportunity__r.Project_Development_Manager__c, Schema.Gate__Share.RowCause.PDM__c));
        }
    
        //Add BDM to Gate share if gates 1 - 3
        if(gate.Gate_Number__c == '1' || gate.Gate_Number__c == '2' || gate.Gate_Number__c == '3'){
            if(gate.Opportunity__r.Business_Development_Manager__c != null){
                GateShareList.add(createGateShare(gate.ID, gate.Opportunity__r.Business_Development_Manager__c, Schema.Gate__Share.RowCause.BDM__c));
            }
        }
        return GateShareList;
    }

    /**
     * @description Create GateShare records for PDM and BDM
     * @return list of Gate Share records for the gate input
     **/
    public static void ManageBDMandPDMGateShare(Gate__c gate, list<Gate__Share> gateShareToInsert){
    	//Add to assigned Approver list
        list<Gate__Share> gateShare = ManageBDMandPDMGateShare(gate);
        if(gateShare != null){
        	gateShareToInsert.addAll(gateShare);
        }
    }

    /**
     * @description adds the CEO or COO as an Approver.
     * @param string CEO_or_COO - either 'CEO' or 'COO'
     * @param gate__c gate - the gate record
     * @return Assigned_Approver__c
     **/
    public static Assigned_Approver__c addApprovers(string CEO_or_COO, gate__c gate){
        Assigned_Approver__c AA;
        
        if(CEO_or_COO == 'COO'){
            AA = new Assigned_Approver__c(Approver__c = Constants.Approvers.COO_User_ID__c, Approver_Role__c = 'COO', gate__c = gate.ID, Approval_Level__c = '3', Prospect__c = gate.opportunity__c, ownerId = Constants.Approvers.COO_User_ID__c);
        }
        else if(CEO_or_COO == 'CEO'){
            AA = new Assigned_Approver__c(Approver__c = Constants.Approvers.CEO_User_ID__c, Approver_Role__c = 'CEO', gate__c = gate.ID, Approval_Level__c = '4', Prospect__c = gate.opportunity__c, ownerId = Constants.Approvers.CEO_User_ID__c);
        }
        return AA;
    }

    /**
     * @description adds the CEO or COO as an Approver.
     * @param string CEO_or_COO - either 'CEO' or 'COO'
     * @param gate__c gate - the gate record
     * @param list<Assigned_Approver__c> AAtoInsert - the List of Assigned Approvers to add to
     * @return void
     **/
    public static void addApprovers(string CEO_or_COO, gate__c gate, list<Assigned_Approver__c> AAtoInsert){
        Assigned_Approver__c AA = addApprovers(CEO_or_COO, gate);
        if(AA != null){
        	AAtoInsert.add(AA);
        }
    }

    /**
     * @description clones the approver and returns the result. Note the clone to ensure a reference is not added to the list
     * @param gate__c gate - the gate record   
     * @return void
     * To Do:   
     **/
    public static Assigned_Approver__c cloneAndAddApprovers(gate__c gate, Assigned_Approver__c AA){
        //Add to assigned Approver list
        Assigned_Approver__c AAClone = AA.clone(false, true, false, false);
        AAClone.gate__c = gate.ID;
        AAClone.Prospect__c = gate.opportunity__c;
        AAClone.OwnerID = AA.Approver__c;
        return AAClone;
    }

   	/**
     * @description add the Approver to the list to be inserted. Note the clone to ensure a reference is not added to the list
     * @param list<Assigned_Approver__c> AAtoInsert - the list of assigned approvers
     * @param gate__c gate - the gate record   
     * @return void
     * To Do:   
     **/
    public static void cloneAndAddApprovers(gate__c gate, Assigned_Approver__c AA, list<Assigned_Approver__c> AAtoInsert){
        //Add to assigned Approver list
        Assigned_Approver__c AsignedApprover = cloneAndAddApprovers(gate, AA);
        if(AsignedApprover != null){
        	AAtoInsert.add(AsignedApprover);
        }
    }





}