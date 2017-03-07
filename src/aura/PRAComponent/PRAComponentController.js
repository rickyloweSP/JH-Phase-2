({
   doInit: function(component, event, helper) {      
      var OpportunityId = component.get("v.recordId");
      helper.getPRAItems(component, OpportunityId);

   },
    doSave : function(cmp, event, helper) {      
        var updatedItems = cmp.get('v.updatedPRAItems');
        //var updatedItems = cmp.get('v.KCRAItems'); <---- RL: would update all of the KCRA items not just the ones that had changed
        var OpportunityId = cmp.get("v.recordId");
        
        console.log('Updated Items SAVE 1==========' + 'OppId ' + OpportunityId + '----' + updatedItems);

        if (!updatedItems) updatedItems = [];
        
        //helper.disableSaveButton(cmp);

         var action = cmp.get("c.updatePRA");

        action.setParams({'updatedPRA' : updatedItems});
        
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
            cmp.set('v.updatedPRAItems', null);
            //cmp.set('v.isDirty', false);
            //helper.enableSaveButton(cmp);
        });

        $A.enqueueAction(action);		
	},
    editMode: function(component, event, helper) {                   
		helper.editMode(component);  // explicit edit component      
        //console.log("SOItem Controller after editMode helper");      
	},
   
})