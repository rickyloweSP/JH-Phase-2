({
    editMode : function(component, event, helper) {
        /*console.log("PRAItemHelper editMode");        
        var AA=component.getReference("v.AssignedApprover");
        var AAList=component.getReference("v.AssignedApproverList");
        
        //$A.createComponent("c:PRAItemEdit",{
        $A.createComponent("c:PRAItemEditModal",{
        
            "PRA": PRA,
            "PRAList": PRAList
        }, function(newComp) {
            var content = component.find("body");
            content.set("v.body", newComp);
            document.getElementsByClassName('viewport')[0].style.overflow="hidden";
        });*/

            var AAId = component.get("v.AssignedApprover.Id");

            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                 "recordId": AAId
           });
            editRecordEvent.fire();
        

    },
    navigateToAssignedApprover : function(component, event, helper) {
        console.log("AssignedApproverHelper navigateToAssignedApprover");        
        var AAId = component.get("v.AssignedApprover.Id");

        if (AAId == null || AAId == '') return;
        
        var evt = $A.get("e.force:navigateToSObject");
        evt.setParams({
            recordId : AAId,
            "slideDevName": "related"
        });
        evt.fire();
    }     
})