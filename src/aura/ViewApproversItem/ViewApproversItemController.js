({
    
    editMode: function(component, event, helper) {                   
        helper.editMode(component);  // explicit edit component      
        console.log("View Approvers Item Controller after editMode helper");      
    },
    navigateToAssignedApprover: function(component, event, helper) {                 
        helper.navigateToAssignedApprover(component);        
        console.log("Assigned Approver Controller after navigateToAssignedApprover helper");      
    }   
    

})