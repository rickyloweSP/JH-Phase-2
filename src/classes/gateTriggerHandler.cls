public with sharing class gateTriggerHandler extends TriggerHandler {
	public gateTriggerHandler() {
		
	}

	public override void afterInsert() {
		getApprovers();
    }

    public override void afterUpdate() {
		findNextApprover(trigger.newMap.KeySet());
    }

    /**
     * @description finds the first or next approver from the list of approvers
     * @return void
     * To Do:   1)  
     **/
    public static void findNextApprover(set<id> gateIds){
    	//[SELECT ID, (SELECT )]
    }



    /**
     * @description Create the Assigned Approvers from the appropriate Business Unit Approvers
     * @return void
     * To Do:   1)  Possibly only get the appropriate approvers instead of getting both the bussiness group and the regional for each opp
     *			2)	Add logic for international Prospects
     *			3) 	Add in logic for gates 4 + 5
     *			4) 	Clean up logic for assigning approvers
     **/
    private void getApprovers(){

    	set<ID> Business_Unit_Ids = new set<ID>();
    	Map<ID, Gate__c> gateToOppfields = new Map<ID, Gate__c>(getOppFields(Trigger.newMap.keySet()));

    	for(Gate__c gate: gateToOppfields.values()){
    		//Add Business Group to the list
    		if(gate.Opportunity__c != null && gate.Opportunity__r.Business_Group__c != null){
    			Business_Unit_Ids.add(gate.Opportunity__r.Business_Group__c);
    		}

    		if(gate.Opportunity__c != null && gate.Opportunity__r.Regional_Business__c != null){
    			Business_Unit_Ids.add(gate.Opportunity__r.Regional_Business__c);
    		}
    	}

    	Map<ID, List<Assigned_Approver__c>> BusinessUnitToApproverMap = getBusinessUnitToApproverMap(Business_Unit_Ids);
    	List<Assigned_Approver__c> Assigned_Approvers_ToInsert = new List<Assigned_Approver__c>();


    	for(Gate__c gate: (List<Gate__c>) Trigger.new){

    		Gate__c gateWithOppFields = gateToOppfields.get(gate.ID);
    		ID theBusinessUnit = null;

            //if gates 1 or 2 - Blueworks Diagram '4a. Determine Approvers - Gates 1 & 2'
            if(gate.gate_number__c == '1' || gate.gate_number__c == '2' || gate.gate_number__c == '3'){
            	integer maxLevelApprover = 2;

            	if(gate.gate_number__c == '1' || gate.gate_number__c == '2'){
            		theBusinessUnit = gateWithOppFields.Opportunity__r.Business_Group__c;
            	}
            	//If gate 3 then use the Regional Business Unit. The rest is the same. BW Diagram '4b. Determine Approvers - Gate 3'
            	else if(gate.gate_number__c == '3'){
	            	theBusinessUnit = gateWithOppFields.Opportunity__r.Regional_Business__c;
	            }
            	
            	if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > 200000000 || gateWithOppFields.Opportunity__r.Number_of_PRA_Critical_Items_Rated_3__c > 0){
            		maxLevelApprover = 3;
            	}
            	if(gateWithOppFields.Opportunity__r.Overall_Prospect_Value__c > 500000000 || gateWithOppFields.Opportunity__r.D_I_Involvement__c){
            		maxLevelApprover = 4;
            	}

            	for(Assigned_Approver__c AA : BusinessUnitToApproverMap.get(theBusinessUnit)){
            		if(integer.valueOf(AA.Approval_Level__c) <= maxLevelApprover){
            			AA.gate__c = gate.ID;
            			Assigned_Approvers_ToInsert.add(AA);
            		}
            	}


            }
            else if(gate.gate_number__c == '4' || gate.gate_number__c == '5'){

            }

            try{
            	insert Assigned_Approvers_ToInsert;
            }
            catch(exception e){

            }
            
        }
    }

    /**
     * @description Gets a List of gate records with the Opportunity fields
     * @return List<Gate__c>
     * To Do:   1)  
     **/
    private static List<Gate__c> getOppFields(set<id> gateIds){
    	return [SELECT ID, Opportunity__r.Business_Group__c, Opportunity__r.Regional_Business__c, Opportunity__r.Overall_Prospect_Value__c, Opportunity__r.Number_of_PRA_Critical_Items_Rated_3__c, Opportunity__r.D_I_Involvement__c FROM gate__c WHERE ID IN : gateIds];
    }


    /**
     * @description builds a map of buisiness unit IDs to a list of Assigned Approvers which is found from the Business Unit Approvers
     * @return Map<ID, List<Assigned_Approver__c>>
     * To Do:   1)  
     **/
    private static Map<ID, List<Assigned_Approver__c>> getBusinessUnitToApproverMap(set<id> BusinessUnitIDs){
    	Map<ID, List<Assigned_Approver__c>> BusinessUnitToApproverMap = new Map<ID, List<Assigned_Approver__c>>();

    	for(Business_Unit_Approvers__c BUA : [SELECT Approval_Level__c,Approver_Role__c,Approver__c,Business_Unit__c,Id,Name FROM Business_Unit_Approvers__c WHERE Business_Unit__c = :BusinessUnitIDs]){
    		
    		//Map the Business Unit Approver fields to the Assigned Approver Fields
    		Assigned_Approver__c AA = new Assigned_Approver__c(	Approval_Level__c = string.ValueOf(BUA.Approval_Level__c),
																Approval_Status__c = 'Assigned Pending Approval',
																Approver__c = BUA.Approver__c,
																Gate__c = null,
																Approver_Role__c = BUA.Approver_Role__c);

    		if(BusinessUnitToApproverMap.containsKey(BUA.Business_Unit__c)){
    			List<Assigned_Approver__c> AAlist = BusinessUnitToApproverMap.get(BUA.Business_Unit__c);
    			AAlist.add(AA);
    		}
    		else{
    			List<Assigned_Approver__c> AAlistNew = new List<Assigned_Approver__c>();
    			AAlistNew.add(AA);
    			BusinessUnitToApproverMap.put(BUA.Business_Unit__c, AAlistNew);
    		}
    	}

    	return BusinessUnitToApproverMap;
    }
    
}