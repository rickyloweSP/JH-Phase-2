({
	doInit : function(component, event, helper) {
		//console.log("Conversion Budget Controller doInit");
        helper.getOppRecord(component);
	},
    updateOpp : function(component, event, helper) {
        var budgetComments = component.find("inputRT").get("v.value");
        var OpportunityId = component.get("v.recordId");
        var OppToUpdate = component.get("v.OppToUpdate");
        OppToUpdate.Id = OpportunityId;
        OppToUpdate.Conversion_Budget_Comments__c = budgetComments;
        
        console.log("********" + OppToUpdate.Conversion_Budget_Comments__c);
        console.log("********" + OppToUpdate.Id);

        var action = component.get("c.updateOpportunity");
        action.setParams({"opp" : OppToUpdate});        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showError(resultStr);
                }
                else {
                    helper.showSuccessToast();
                    $A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
        });
		
        $A.enqueueAction(action);
		
	}
})