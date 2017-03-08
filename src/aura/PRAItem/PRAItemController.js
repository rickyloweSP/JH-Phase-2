({
    editMode: function(component, event, helper) {                   
        helper.editMode(component);  // explicit edit component      
        console.log("PRAtem Controller after editMode helper");      
    },
    navigateToPRA: function(component, event, helper) {                 
        helper.navigateToPRA(component);        
        console.log("PRAItem Controller after navigateToPRA helper");      
    }   
})