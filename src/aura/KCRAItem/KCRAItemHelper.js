({
    navigateToKCRA : function(component, event, helper) {
        console.log("KCRAItemHelper navigateToKCRA");        
        var KCRAId = component.get("v.KCRA.Id");

        if (KCRAId == null || KCRAId == '') return;
        
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            recordId : KCRAId,
            "slideDevName": "related"
        });
        evt.fire();
    }     
})