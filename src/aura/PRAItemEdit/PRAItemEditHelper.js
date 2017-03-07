({  
    save : function(component) { 
        //console.log("SOEdit inside edit component - Save");
        var PRA = component.get("v.PRA");
        //var soStatusBefore = component.get("v.opp.Status__c");	// retrieve status before
        //var soStatusAfter = soStatusBefore;	// default the status after to be the same as status before
        var oppId = component.get("v.PRA.Opportunity__c");
        
        //console.log("SOEdit so before " + so.Name);                              
        component.find("edit").get("e.recordSave").fire();

		// requery the so to retrieve all the fields and update so object.
		// This will trigger the change event on so        
        var action = component.get("c.getPRA");
        action.setParams({	// requery to update so
            "PRAId" : PRA.Id
        });
 
        //console.log("SOEdit inside edit component - Save - before callback");

        //Set up the callback
        action.setCallback(this, function(response) { 
            var newRecordSaved = component.get("v.newRecordSaved");
            var mode = component.get("v.mode");
            var state = response.getState();
            //console.log('SOEdit inside setCallback');
            //console.log('SOEdit state = ' + state);
            
            if (state == "SUCCESS") {
           		var returnVal =response.getReturnValue();     
            	//console.log('SOEdit returnVal Length = ' + returnVal.length);            
                //console.log("SOEdit query for so is successful");                
                //console.log(returnVal);
                component.set('v.opp',returnVal);
        		//soStatusAfter = component.get("v.so.Status__c"); // retrieve the status after           
                
                if (mode == "editNew") {
                	component.set("v.newRecordSaved","true");   
                }

                //console.log("SOEdit soStatusBefore = " + soStatusBefore + " soStatusAfter = " + soStatusAfter);                
                //if (soStatusBefore != soStatusAfter) {
	                //console.log("SOEdit soStatusBefore != soStatusAfter");                                    
                    var evt = $A.get("e.c:KCRAEvent");
                    evt.setParams({ "recordId": oppId});
                    evt.fire();                 	   
                //}
  
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

    showSuccess : function (message) {
        this.displayToast('Success', 'success', 'dismissible', message);
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