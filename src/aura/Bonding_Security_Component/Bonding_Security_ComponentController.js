({
	doInit : function(component, event, helper) {
        //console.log("Competitor Analysis Controller doInit");
        helper.getOppRecord(component);		
	},
    updateOpp : function(component, event, helper) {
        var bondSecurity = component.find("checkBox").get("v.value");
        var OpportunityId = component.get("v.recordId");
        var OppToUpdate = component.get("v.OppToUpdate");
        OppToUpdate.Id = OpportunityId;
        OppToUpdate.Apply_Default_Bonding__c = bondSecurity;
        
        console.log("********" + OppToUpdate.Apply_Default_Bonding__c);
        console.log("********" + OppToUpdate.Id);

        var action = component.get("c.updateOpportunity");
        action.setParams({"opp" : OppToUpdate});        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
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
    },
    display : function(component, event, helper) {
        helper.toggleHelper(component, event);
    },

    displayOut : function(component, event, helper) {
        helper.toggleHelper(component, event);
    }
})