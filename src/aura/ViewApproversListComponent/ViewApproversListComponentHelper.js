({
      
    getOppRecord: function(component) {
        console.log("Inside getOppRecord");
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
    

    getAssignedApproversList: function(component) {
        var parentId = component.get("v.Opp");
        var status = component.get("v.filterStatus");
        //var OppId = recID;
        console.log(parentId);
        
        if (parentId == null || parentId == '') return;
        
        var action = component.get("c.getAssignedApprovers");        
        
        action.setParams({
            "opp" : parentId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  
            var listAA = [];
            var state = response.getState();
 
            //console.log('SOList inside setCallback');
            //console.log('SOList state = ' + state);

            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();
                var returnValLen = returnVal.length;
                //console.log('PRAList returnVal Length = ' + returnValLen);                
                console.log(returnVal);
                for(var i=0; i < returnValLen; i++) {
                    console.log(returnVal[i]);           
                    listAA.push(returnVal[i]);
                }
                //console.log(listAA);
                component.set('v.AssignedApprovalList',listAA);
                //console.log('Test');
                //component.set('v.maxNumRecordDisplay',returnValLen);               
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action); 
    },
    newRecord : function(component) {
       /* var parentId = component.get("v.recordId");
        
        if (parentId == null || parentId == '') return;  
        
        //console.log('SOListHelper inside newRecord');

        // create a new shell record. When the user click cancel, the record will be deleted
        // As of Summer 16, in standard force:createRecord, it does not support passing a default field (parentId)       
        var action = component.get("c.createNewRecord");
        action.setParams({
            "clientPlanId" : parentId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  
            var so;
            var state = response.getState();
            //console.log('SOListHelper newRecord inside setCallback');
            //console.log('state = ' + state);
            
            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();
                //console.log("SOListHelper query for so is successful");         
                //console.log(returnVal);
                component.set("v.newSO",returnVal);
                
                var so=component.getReference("v.newSO");
                var newRecordSaved = component.getReference("v.newRecordSaved");
                $A.createComponent("c:StrategicOpportunityEdit",{
                      "so": so,
                      "mode": "editNew",
                      "newRecordSaved" : newRecordSaved,
                      "defaultHeader" : "New Strategic Opportunity"
                }, function(newComp) {
                  var content = component.find("body");
                  content.set("v.body", newComp);
                });      
            }
            else if (state == "ERROR") {
                displayActionError(response);
            }
        });
        $A.enqueueAction(action);   */            
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