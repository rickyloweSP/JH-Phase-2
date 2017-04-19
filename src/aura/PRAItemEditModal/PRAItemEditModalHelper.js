({  

    closeModal :  function(component, event, helper) {
        var newRecordSaved = component.get("v.newRecordSaved");

        //document.getElementsByClassName('viewport')[0].style.overflow="visible";
        var parentEvent =  component.getEvent("updatePRAEvent");
        parentEvent.fire();
        component.destroy();
    },
    savePRAItem : function(cmp, event, helper){
        var PRA = cmp.get("v.PRA");
        var oppId = cmp.get("v.PRA.Opportunity__c");
        var action = cmp.get("c.updatePRA");
        action.setParams({'updatedPRA' : PRA});        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    this.showErrorToast(resultStr);
                }
                else {
                    this.showSuccessToast();
                }    
            } else if (state === "ERROR") {
                this.displayActionError(response);
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
            "title": "Start of PRA Records List!",
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
    getIndicators : function(component) {
        var action = component.get('c.getIndicators');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var items = response.getReturnValue();
                console.log(items);
                if (items.length > 0)
                    component.set('v.Indicators', items);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       this.displayToast('Error', errors[0].message);
                    }
                }
                else {
                    this.displayToast('Error', 'Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
})