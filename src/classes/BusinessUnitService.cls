public without sharing class BusinessUnitService {

	/**
     * @description builds a map of buisiness unit IDs to a list of Assigned Approvers which is found from the Business Unit Approvers
     * @return Map<ID, List<Assigned_Approver__c>>
     **/
    public static Map<ID, List<Assigned_Approver__c>> getBusinessUnitToApproverMap(set<id> BusinessUnitIDs){
        Map<ID, List<Assigned_Approver__c>> BusinessUnitToApproverMap = new Map<ID, List<Assigned_Approver__c>>();

        for(Business_Unit_Approvers__c BUA :   [SELECT Approval_Level__c,Approver_Role__c,Approver__c,Business_Unit__c,Id,Name,Proxy_Approver__c 
                                                FROM Business_Unit_Approvers__c 
                                                WHERE Business_Unit__c = :BusinessUnitIDs]){
            
            //Map the Business Unit Approver fields to the Assigned Approver Fields
            Assigned_Approver__c AA = new Assigned_Approver__c( Approval_Level__c = BUA.Approval_Level__c,
                                                                Approval_Status__c = Constants.PendingApprovalStatus,
                                                                Approver__c = BUA.Approver__c,
                                                                Gate__c = null,
                                                                Approver_Role__c = BUA.Approver_Role__c,
                                                                Proxy_Approver__c = BUA.Proxy_Approver__c);

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