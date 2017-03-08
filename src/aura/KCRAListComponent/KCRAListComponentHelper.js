({
      
    getKCRAList: function(component) {
        var parentId = component.get("v.recordId");
        var status = component.get("v.filterStatus");
        //var OppId = recID;
        console.log('KCRAList inside setCallback parentId = ' + parentId);
        
        if (parentId == null || parentId == '') return;
        
        var action = component.get("c.getAllKCRARecords");        
        
        action.setParams({
            "opportunityId" : parentId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  
            var listKCRA = [];
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
                    listKCRA.push(returnVal[i]);
                }
                component.set('v.KCRAList',listKCRA);
                component.set('v.maxNumRecordDisplay',returnValLen);               
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