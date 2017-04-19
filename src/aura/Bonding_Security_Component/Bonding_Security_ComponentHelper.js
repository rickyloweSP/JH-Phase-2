({
    getOppRecord: function(component) {
        var OppId = component.get("v.recordId");
        
        if (OppId == null || OppId == '') return;
        
        var action = component.get("c.getOpportunityRecord");        
        
        action.setParams({
            "opportunityId" : OppId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  

            var state = response.getState();

            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();               
                console.log(returnVal);
                component.set('v.Opp',returnVal[0]);
          
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action); 
    },
    showError : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message
        });
        toastEvent.fire();
	},
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
	},   
    displayActionError : function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showError(response.state + ' - ' + errors[0].message);
            }
        } else {
            this.showError('An unknown error has occurred.');
        }    
    },
    toggleHelper : function(component,event) {
        var toggleText = component.find("tooltip");
        $A.util.toggleClass(toggleText, "toggle");
    }
})