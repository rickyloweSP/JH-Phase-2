({
    doInit: function(component, event, helper) { 
        console.log("KCRAListController in doInit");
       // var OpportunityId = component.get("v.recordId");
        //helper.getPRAList(component,OpportunityId);
        helper.getKCRAList(component);
        component.set("v.currentNumRecordDisplay", component.get("v.defaultNumRecordDisplay"));    // set the currentNumDisplay to the default on init                
   },   
   doChangeKCRA: function(component, event, helper) {
      var KCRA = event.getParam("KCRA");
      console.log(KCRA);
    },
    newRecord: function(component, event, helper) {
        helper.newRecord(component);
 
        console.log("KCRAListController end new record controller");        
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
       
       for (i = 0; i < viewToggle.length; i++) {  // toggle for each element contain "viewToggle"
          $A.util.toggleClass(viewToggle[i], "toggle");  
       }       
   }
})