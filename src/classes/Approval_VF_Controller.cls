public with sharing class Approval_VF_Controller {
	public Opportunity oppRecord {get;set;}
	public User userRecord {get;set;}
	public String emailTypeStr {get;set;}
	public Assigned_Approver__c AssignedApprover;
	public list<Assigned_Approver__c> ApproversForGateDecided;
	public list<Assigned_Approver__c> ApproversForCurrentGate;
	
	public Approval_VF_Controller() {
		
	}

	/**
     * @description Gets the Assigned Approver. Only appropriate to use for Decision required as it queries Assigned Approvers where Current Approver flag = true
     * @return 
     **/
	public Assigned_Approver__c getAssignedApprover(){
		for(Assigned_Approver__c AA : OpportunityHelper.getTheCurrentApprover(oppRecord.ID)){
			if(emailTypeStr == 'CRA' || emailTypeStr == 'TSF'){
				if(AA.Gate__r.Gate_Type__c == emailTypeStr){
					return AA;
				}
			}
			else if(AA.Gate__r.Gate_Type__c == null || AA.Gate__r.Gate_Type__c == ''){
				return AA;
			}
		}
		return new Assigned_Approver__c();
	}


	/**
     * @description Gets the rest of the approvers from the Current Assigned Approver. For use when showing table in Decision Required email.
     * @return 
     **/
	public list<Assigned_Approver__c> getApproversForCurrentGate(){
		Assigned_Approver__c AA = getAssignedApprover();
		return gateService.getApproversForGate(AA.gate__c);
	}


	/**
     * @description Gets the list of approvers. For use in Approval Outcome Email
     * @return 
     **/
	public list<Assigned_Approver__c> getApproversForGateDecided(){
		
		//get the correct gate
		gate__c theGate;

		for(Opportunity Opp : OpportunityHelper.getOpportunitiesAndDecidedGates(oppRecord.ID)){
			List<Gate__c> Gates = Opp.Gates__r;
			if(Gates != null && Gates.size() > 0){
				for(Gate__c G : Gates){
					if(emailTypeStr == 'CRA' || emailTypeStr == 'TSF'){
						if(G.Gate_Type__c == emailTypeStr){
							theGate = G;
							break;
						}
					}
					else if(G.Gate_Type__c == null || G.Gate_Type__c == ''){
						theGate = G;
						break;
					}
				}
			}
		}

		//if the gate exists then return the approvers
		if(theGate != null){
			return gateService.getApproversForGate(theGate.ID);
		}
		else{
			return new list<Assigned_Approver__c>();
		}


	}

}