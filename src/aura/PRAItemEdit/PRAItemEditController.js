({
    doInit: function(component, event, helper) { // retrieve the attachments 
/*        var mode = component.get("v.mode");
        
*/        

   }, 
    close : function(component, event, helper) {
        var newRecordSaved = component.get("v.newRecordSaved");
        var mode = component.get("v.mode");
        //console.log("SOEdit newRecordSaved " + newRecordSaved); 
        //console.log("SOEdit mode " + mode); 
  
        if (mode == "editNew") {	// if edit new mode, delete the newly created record
   		    //console.log("SOEdit insideIf mode = editNew");           
            //helper.deleteSO(component);
        }
        
		component.destroy();
    },    
    save : function(component, event, helper) {
        helper.save(component);
    }
})