public with sharing class GateService {
	
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
        for(Gate__c G : gateService.getGateAndApprovers(gateID)){
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
}