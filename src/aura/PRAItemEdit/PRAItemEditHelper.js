({  
    save : function(component) { 
        //console.log("SOEdit inside edit component - Save");
        var PRA = component.get("v.PRA");
        var oppId = component.get("v.PRA.Opportunity__c");
                            
        component.find("edit").get("e.recordSave").fire();

		// requery the PRA to retrieve all the fields and update so object.
		// This will trigger the change event on PRA        
        var action = component.get("c.getPRA");
        action.setParams({	// requery to update PRA
            "PRAId" : PRA.Id
        }); 

        //Set up the callback
        action.setCallback(this, function(response) { 
            //var newRecordSaved = component.get("v.newRecordSaved");
            var mode = component.get("v.mode");
            var state = response.getState();
            
            if (state == "SUCCESS") {
           		var returnVal =response.getReturnValue();     
                component.set('v.PRA',returnVal);                              
                    var evt = $A.get("e.c:KCRAEvent");
                    evt.setParams({ "recordId": oppId});
                    evt.fire();                 	  
		        component.destroy();                
            }
            else if (state == "ERROR") {
				displayActionError(response); 
            }
        });
        $A.enqueueAction(action);      
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
    
    showInfo : function (message) {
        this.displayToast('Info', 'info', 'dismissible', message);
    },

    showEndOfListToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "End of PRA Records List!",
            "message": "This is the last record in the list of PRA Items."
        });
        toastEvent.fire();
	},  
    showStartOfListToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Start of PRA Records List!",
            "message": "This is the first record in the list of PRA Items."
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

    showWarning : function (message) {
        this.displayToast('Warning', 'warning', 'sticky', message);
    },

    showError : function (message) {
        this.displayToast('Error', 'error', 'sticky', message);
    },

    displayToast : function (title, type, mode, message) {
        var toast = $A.get('e.force:showToast');
        if (toast) {
            toast.setParams({
                'title': title,
                'type': type,
                'mode': mode,
                'message': message
            });
            toast.fire();
        }
        else {
            alert(title + ': ' + message);
        }
    },    
    
})