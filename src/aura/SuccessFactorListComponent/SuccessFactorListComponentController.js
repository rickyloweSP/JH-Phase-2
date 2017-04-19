({
    doInit: function(component, event, helper) { 
        console.log("SuccessFactor in doInit");
        helper.getSuccessFactorList(component);
        component.set("v.currentNumRecordDisplay", component.get("v.defaultNumRecordDisplay"));    // set the currentNumDisplay to the default on init                
   },   
   doChangeSuccessFactor: function(component, event, helper) {
      var SuccessFactor = event.getParam("KCRA");
      console.log(SuccessFactor);
    },
    addUpdatedSuccessFactor: function(component, event, helper)
    {
        var updatedItem= event.getParam("SuccessFactorItem");
        console.log("Updated Item");
        var updatedItems = cmp.get('v.updatedSuccessFactorItems');
        if (!updatedItems) updatedItems = [];
        if (updatedItem != null && updatedItem != undefined) {
            updatedItems.push(updatedItem);
        }
        component.set("v.updatedItems", updatedItems);
    },
    doSave : function(cmp, event, helper) {      
        var updatedItems = cmp.get('v.SuccessFactorList');
        //var updatedItems = cmp.get('v.KCRAItems'); //<---- RL: would update all of the KCRA items not just the ones that had changed
        var OpportunityId = cmp.get("v.recordId");
        
        //console.log('Updated Items SAVE 1==========' + 'OppId ' + OpportunityId + '----' + updatedItems);

        if (!updatedItems) updatedItems = [];
        
        //helper.disableSaveButton(cmp);

         var action = cmp.get("c.updateSuccessFactor");

        action.setParams({'updatedSuccessFactor' : updatedItems});
        
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
            cmp.set('v.updatedSuccessFactorItems', null);
            //cmp.set('v.isDirty', false);
            //helper.enableSaveButton(cmp);
        });

        $A.enqueueAction(action);		
	},
    
    viewToggle: function(component, event, helper) { // toggle view/ hide
       var buttonClicked = event.target.getAttribute('id');
       //console.log(buttonClicked);
       
       if(buttonClicked == "viewAllButton") {
            component.set("v.currentNumRecordDisplay", component.get("v.maxNumRecordDisplay"));    // set the currentNumDisplay to the Max on View All        
       }
       else {
            component.set("v.currentNumRecordDisplay", component.get("v.defaultNumRecordDisplay"));    // set the currentNumDisplay to the default on View Less              
       }
        
       var viewToggle = component.find('viewToggle');
       //console.log(viewToggle);
       //console.log(viewToggle.length);        
       var i=0;
       for (i = 0; i < viewToggle.length; i++) {  // toggle for each element contain "viewToggle"
          $A.util.toggleClass(viewToggle[i], "toggle");  
       }       
   },
})