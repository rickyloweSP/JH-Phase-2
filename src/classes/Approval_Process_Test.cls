@isTest (SeeAllData = false)
private class Approval_Process_Test {
	
	/*Tests to do:
	1) test that the levels off approvers are added for different OPV values


	*/

	@isTest static void test() {
		list<opportunity> opp = Test_Data_Factory.CreateProspectAndOtherRecords();
		System.debug(loggingLevel.Error, '*** PDM: ' + Test_Data_Factory.PDM);
	}


	@isTest static void test_Perfect_Use_Case() {

		//1) Create the Prospect with no Business Units set
		list<opportunity> opp = Test_Data_Factory.CreateProspectAndOtherRecords();
		test.startTest();
		list<opportunity> oppInsert = OpportunityHelper.getOpportunityFields(opp[0].id);
		System.debug(loggingLevel.Error, '*** oppInsert: ' + oppInsert);
		System.debug(loggingLevel.Error, '*** AFTER INSERTING THE RECORD');

		//2) Check the stage has changed to gate 1
		list<opportunity> oppQ = OpportunityHelper.getOpportunityFields(opp[0].id);
		System.debug(loggingLevel.Error, '*** opp after update: ' + oppQ);
		system.assert(oppQ[0].stageName == Constants.Gate1Stage);
		system.assert(oppQ[0].Business_Group__c != null);
		system.assert(oppQ[0].Regional_Business__c != null);
		
		//3) Update the Gate status to Initiated
		initiateGate(opp[0].ID, null);

		//4) Check that a gate record has been created
		list<gate__c> gate = GateHelper.getGateAndApproversFromOpp(opp[0].id);
		system.assert(gate.size() == 1);

		//5) Check Approvers have been created 
		list<Assigned_Approver__c> AA = GateHelper.getApproversForGate(gate[0].Id);
		System.debug(loggingLevel.Error, '*** AAs in test method: ' + AA);
		system.assert(AA.size() > 0);
		system.assert(AA.size() == 4);	//Gate 1 approval for a prospect over the highest threshold requires approval from all 4 levels - See blueworks process '4a. Determine Approvers - Gates 1 & 2' - https://us001.blueworkslive.com/scr/processes/20000199d5253d5#bpmn

		//6) Set the Opportunity Gate status to In Progress to submit the gate for approval
		submitGate(opp[0].ID, null);
		
		//7) Approve the gate by applying an approval decision to all the approvers
		test.stopTest();
	}

	/**
     * @description Initiate Gate without Business units being set
     **/
	@isTest static void test_Initiating_Gate_Process_Without_Business_Units_Set() {
		
		System.debug(loggingLevel.Error, '*** BUs in SF: ' + [SELECT Id FROM Business_Unit__c]);

		//set up test data
		Test_Data_Factory.createApprovalCS();

		//1) Create the Prospect with no Business Units set
		list<opportunity> opp = Test_Data_Factory.createProspectForTestMethods(1, Constants.Approvers.Gate_1_Entry_Threshold__c - 1, Constants.NewDandCStage,Test_Data_Factory.oppName, null, null,null,null);

		list<opportunity> oppInsert = OpportunityHelper.getOpportunityFields(opp[0].id);
		System.debug(loggingLevel.Error, '*** oppInsert: ' + oppInsert);

		System.debug(loggingLevel.Error, '*** AFTER INSERTING THE RECORD');


		//2) Check the stage has changed to gate 3
		list<opportunity> oppQ = OpportunityHelper.getOpportunityFields(opp[0].id);
		System.debug(loggingLevel.Error, '*** opp after update: ' + oppQ);
		system.assert(oppQ[0].stageName == Constants.Gate3Stage);
		
		//3) Update the Gate status to Initiated
		initiateGate(opp[0].ID, null);

		//4) Check that a gate record has been created
		list<gate__c> gate = GateHelper.getGateAndApproversFromOpp(opp[0].id);
		system.assert(gate.size() == 1);
	}


	/**
     * @description Initiate Gate - mimics the Lightning component
     **/
	public static void initiateGate(ID oppID, string GateType){
		changeGateStatus(oppID, GateType, Constants.InitiatedStatus);
	}

	/**
	 * @description Submit Gate Approval- mimics the Lightning component
     **/
	public static void submitGate(ID oppID, string GateType){
		changeGateStatus(oppID, GateType, Constants.InProgressStatus);
	}

	/**
	 * @description Change gate status - used by methods above to mimic lightning component behaviour
     **/
	public static void changeGateStatus(ID oppID, string GateType, string status){
		System.debug(loggingLevel.Error, '*** BEFORE Setting The Gate status to ' + status);
		opportunityTriggerHandler.recursionAfter = false;
		
		Opportunity oppUpdate = new Opportunity();
		oppUpdate.ID = oppID;

		if(GateType == 'CRA'){
			oppUpdate.CRA_gate_status__c = status;
		}
		else if(GateType == 'TSF'){
			oppUpdate.TSF_gate_status__c = status;
		}
		else{
			oppUpdate.gate_status__c = status;
		}
		
		update oppUpdate;
		System.debug(loggingLevel.Error, '*** AFTER Setting The Gate status to ' + status);
	}

	/**
	 * @description apply approval decision
     **/
	public static void applyApprovalDecision(ID AAID, string decision){
		
	}

	
}