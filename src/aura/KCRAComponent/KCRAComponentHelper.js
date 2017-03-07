({
   //Fetch the KCRA Items from the Apex controller
  getKCRAItems: function(component,recID) {
    var action = component.get("c.getAllKCRARecords");

    var OppId = recID;
    var params = {"opportunityId" : OppId};//
    action.setParams(params);//

    //Set up the callback
    var self = this;
  
    action.setCallback(this, function(actionResult) {
        component.set("v.KCRAItems", actionResult.getReturnValue());            
    });
    $A.enqueueAction(action);
  },
  enableSaveButton : function(cmp) {
        var saveButton = cmp.find('savebtn');
        saveButton.set("v.disabled", false);
    },
   
    disableSaveButton : function(cmp) {
        var saveButton = cmp.find('savebtn');
        saveButton.set("v.disabled", true);
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
    showErrorToast : function(message) {
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
    
})