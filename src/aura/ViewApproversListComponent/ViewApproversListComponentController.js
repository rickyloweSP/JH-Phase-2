({
    doInit: function(component, event, helper) { 
        console.log("PRAListController in doInit");
        var OpportunityId = component.get("v.Opp.Id");
        console.log("OppId in Approvers List " + OpportunityId);
        //helper.getPRAList(component,OpportunityId);
        //helper.getOppRecord(component);      
        helper.getAssignedApproversList(component);
        //component.set("v.currentNumRecordDisplay", component.get("v.defaultNumRecordDisplay"));    // set the currentNumDisplay to the default on init                
   },   
    editRecord: function(component, event, helper) {
        helper.newRecord(component);
 
        //console.log("PRAListController end new record controller");        
   }, 
   close : function(component, event, helper) {
        //var newRecordSaved = component.get("v.newRecordSaved");

        //document.getElementsByClassName('viewport')[0].style.overflow="visible";
        //document.getElementById('oneHeader').parentNode.style.overflow='visible';
        component.destroy();
        $A.get('e.force:refreshView').fire();
    },  
    createNewRecord : function (component, event, helper) {

        var createMyCustomObjRecEvent = $A.get("e.force:createRecord");
        var OpportunityId = component.get("v.Opp.Id");
        createMyCustomObjRecEvent.setParams({

            "entityApiName": "Assigned_Approver__c",
            "Prospect__c": OpportunityId

        });

        createMyCustomObjRecEvent.fire();

    },
    doSave : function(cmp, event, helper) {      
        var updatedItems = cmp.get('v.AssignedApprovalList');
        //var updatedItems = cmp.get('v.KCRAItems'); //<---- RL: would update all of the KCRA items not just the ones that had changed
        //var OpportunityId = cmp.get("v.recordId");
        
        //console.log('Updated Items SAVE 1==========' + 'OppId ' + OpportunityId + '----' + updatedItems);

        if (!updatedItems) updatedItems = [];
        
        //helper.disableSaveButton(cmp);

         var action = cmp.get("c.updateAssignedApprovers");

        action.setParams({'updatedAA' : updatedItems});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
                }
                else {
                    helper.showSuccessToast();
                    //helper.showSuccess('Changes have been successfully saved.');
                    //$A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
            //cmp.set('v.updatedKCRAItems', null);
            //cmp.set('v.isDirty', false);
            //helper.enableSaveButton(cmp);
        });

        $A.enqueueAction(action);       
    },
})