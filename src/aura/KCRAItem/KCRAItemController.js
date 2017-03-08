({
    editMode: function(component, event, helper) {                   
        /*helper.editMode(component);  // explicit edit component      
        console.log("KCRAtem Controller after editMode helper");   */   
    },
    navigateToKCRA: function(component, event, helper) {                 
        helper.navigateToKCRA(component);        
        console.log("KCRAItem Controller after navigateToKCRA helper");      
    } ,
    doChangeKCRA: function(component, event, helper) {
      var cmpEvt = component.getEvent("onClick");
      cmpEvt.setParams({
        "KCRA": component.get("v.KCRA")
      }).fire();
        console.log("Item " + component.get("v.KCRA"));
    },
})