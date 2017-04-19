({
      
    getSuccessFactorList: function(component) {
        var parentId = component.get("v.recordId");
        var status = component.get("v.filterStatus");
        //console.log('KCRAList inside setCallback parentId = ' + parentId);
        
        if (parentId == null || parentId == '') return;
        
        var action = component.get("c.getAllSuccessFactorRecords");        
        
        action.setParams({
            "LessonsLearntId" : parentId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  
            var listSF = [];
            var state = response.getState();
 
            //console.log('KCRAList inside setCallback');
            //console.log('KCRAList state = ' + state);

            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();
                var returnValLen = returnVal.length;
                //console.log('KCRAList returnVal Length = ' + returnValLen);                
                console.log(returnVal);
                for(var i=0; i < returnValLen; i++) {
                    console.log(returnVal[i]);           
                    listSF.push(returnVal[i]);
                }
                component.set('v.SuccessFactorList',listSF);
                component.set('v.maxNumRecordDisplay',returnValLen);               
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
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