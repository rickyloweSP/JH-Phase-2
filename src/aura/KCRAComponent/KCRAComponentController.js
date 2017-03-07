({
   doInit: function(component, event, helper) {      
      var OpportunityId = component.get("v.recordId");
      helper.getKCRAItems(component, OpportunityId);

   },
    doSave : function(cmp, event, helper) {      
        var updatedItems = cmp.get('v.updatedKCRAItems');
        //var updatedItems = cmp.get('v.KCRAItems'); //<---- RL: would update all of the KCRA items not just the ones that had changed
        var OpportunityId = cmp.get("v.recordId");
        
        console.log('Updated Items SAVE 1==========' + 'OppId ' + OpportunityId + '----' + updatedItems);

        if (!updatedItems) updatedItems = [];
        
        //helper.disableSaveButton(cmp);

         var action = cmp.get("c.updateKCRA");

        action.setParams({'updatedKCRA' : updatedItems});
        
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
            cmp.set('v.updatedKCRAItems', null);
            //cmp.set('v.isDirty', false);
            //helper.enableSaveButton(cmp);
        });

        $A.enqueueAction(action);		
	},
    doChangeKCRA : function(cmp, event, helper) {
        
        
        
        var a = event.getSource();
        var items = cmp.get('v.KCRAItems');
        var updatedItems = cmp.get('v.updatedKCRAItems');

        
        console.log('Updated Items 1==========' + updatedItems);
        
        if (!updatedItems) updatedItems = [];
        var xid = a.get("v.text");
        var selectedYesNo = a.get("v.labelClass");
        console.log("YID =  " + selectedYesNo);
        console.log("XID =  " + xid);
        if ($A.util.isEmpty(xid) && $A.util.isEmpty(selectedYesNo)) return;
        
        var updatedItem = items.find(function (o) { 
                if($A.util.isEmpty(xid) && !$A.util.isEmpty(selectedYesNo))
                	return o.Id == selectedYesNo; 
                else if($A.util.isEmpty(selectedYesNo) && !$A.util.isEmpty(xid))
                    return o.Id == xid;
            	else
                    return o.Id == xid;
        })
        console.log('Updated Item Before==========' + updatedItem);
        
        
        
        
        
        
        //if (a.get("v.value")) {
        //// Checkbox is checked - add id to checkedContacts
            //if (cmp.get("v.updatedKCRAItems").indexOf(xid) < 0) {
              //cmp.get("v.updatedKCRAItems").push(updatedItem);
            //}
        //} 
        /*else {
        // Checkbox is unchecked - remove id from checkedContacts
        var index = component.get("v.checkedContacts").indexOf(id);
            if (index > -1) {
              component.get("v.checkedContacts").splice(index, 1);
            }
        }*/

       
        if (updatedItem != null && updatedItem != undefined) {
        	updatedItems.push(updatedItem);
        }
        
        console.log('Updated Items 2==========' + updatedItems);
        
        cmp.set('v.isDirty', true);
        cmp.set('v.updatedKCRAItems', updatedItems);
        
    },
    
   
})