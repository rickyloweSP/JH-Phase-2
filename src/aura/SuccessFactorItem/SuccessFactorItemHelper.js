({
    navigateToSuccessFactor : function(component, event, helper) {
     
        var SuccessFactorId = component.get("v.SuccessFactor.Id");

        if (SuccessFactorId == null || SuccessFactorId == '') return;
        
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            recordId : SuccessFactorId,
            "slideDevName": "related"
        });
        evt.fire();
    }     
})