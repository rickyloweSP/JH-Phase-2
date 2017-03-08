({
    editMode : function(component, event, helper) {/*
        console.log("KCRAItemHelper editMode");        
        var PRA=component.getReference("v.PRA");
        
        $A.createComponent("c:PRAItemEdit",{
            "PRA": PRA
        }, function(newComp) {
            var content = component.find("body");
            content.set("v.body", newComp);
        });*/
    },
    navigateToKCRA : function(component, event, helper) {
        console.log("KCRAItemHelper navigateToKCRA");        
        var KCRAId = component.get("v.KCRA.Id");

        if (KCRAId == null || KCRAId == '') return;
        
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            recordId : PRAId,
            "slideDevName": "related"
        });
        evt.fire();
    }     
})