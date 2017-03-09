({
    editMode : function(component, event, helper) {
        console.log("PRAItemHelper editMode");        
        var PRA=component.getReference("v.PRA");
        var PRAList=component.getReference("v.PRAList");
        $A.createComponent("c:PRAItemEdit",{
            "PRA": PRA,
            "PRAList": PRAList
        }, function(newComp) {
            var content = component.find("body");
            content.set("v.body", newComp);
        });
    },
    navigateToPRA : function(component, event, helper) {
        console.log("PRAItemHelper navigateToPRA");        
        var PRAId = component.get("v.PRA.Id");

        if (PRAId == null || PRAId == '') return;
        
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            recordId : PRAId,
            "slideDevName": "related"
        });
        evt.fire();
    }     
})