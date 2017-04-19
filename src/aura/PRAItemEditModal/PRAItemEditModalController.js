({
    doInit: function(component, event, helper) { // retrieve the attachments 

 		 helper.getIndicators(component);
         //component.set("v.cssStyle", ".forceStyle .viewport.oneHeader.desktop {z-index:0} .forceStyle.desktop .viewport{overflow:hidden}");
    }, 
    close : function(component, event, helper) {
        helper.closeModal(component);   

    },    
    save : function(cmp, event, helper) {
        helper.savePRAItem(cmp);
        helper.closeModal(cmp);  
		/*var PRA = cmp.get("v.PRA");
        var oppId = cmp.get("v.PRA.Opportunity__c");
        var action = cmp.get("c.updatePRA");
        action.setParams({'updatedPRA' : PRA});        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
                }
                else {
                    helper.showSuccessToast();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
        });
        $A.enqueueAction(action);	*/
        //$A.get('e.force:refreshView').fire();	
        //var parentEvent =  component.getEvent("updatePRAEvent");
        //parentEvent.fire();
    },
    moveNext : function(component, event, helper) {
        helper.savePRAItem(component);
        var currentPRAItem = component.get("v.PRA");
        var allPRAItems = component.get("v.PRAList");
        console.log(allPRAItems);
        var currentIndex = allPRAItems.indexOf(currentPRAItem);
        console.log('Current Index '  + currentIndex);
        var nextIndex = currentIndex + 1;
        console.log('Next Index '  + nextIndex);
        if(nextIndex===allPRAItems.length){
			helper.showEndOfListToast;
        }
        else
        	component.set("v.PRA",allPRAItems[nextIndex]);
    },
    movePrevious : function(component, event, helper) {
        helper.savePRAItem(component);
        var currentPRAItem = component.get("v.PRA");
        var allPRAItems = component.get("v.PRAList");
        console.log(allPRAItems);
        var currentIndex = allPRAItems.indexOf(currentPRAItem);
         console.log('Current Index '  + currentIndex);
        var previousIndex = currentIndex-1;
         console.log('Previous Index '  + previousIndex);
        if(currentIndex===0){
			helper.showStartOfListToast;
        }
        else
        	component.set("v.PRA",allPRAItems[previousIndex]);
    },
})