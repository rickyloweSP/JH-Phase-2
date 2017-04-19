({
    doInit: function(component, event, helper) { // retrieve the attachments 

 		 //component.set("v.cssStyle", ".forceStyle.viewport.oneHeader.desktop {z-index:0} .forceStyle.desktop.viewport{overflow:hidden}");
 		  //var styl = "height:600px;width:400px;margin-top:5cm;margin-left:6cm;";
          //component.set("v.cssStyle", styl);
          overrideHeaderStyle();
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
        helper.showSuccessToast();
    },
    moveNext : function(component, event, helper) {
        var currentPRAItem = component.get("v.PRA");
        var allPRAItems = component.get("v.PRAList");
        console.log(allPRAItems);
        var currentIndex = allPRAItems.indexOf(currentPRAItem);
        console.log('Current Index '  + currentIndex);
        var nextIndex = currentIndex + 1;
        console.log('Next Index '  + nextIndex);
        if(nextIndex===allPRAItems.length){
            //component.destroy();
			helper.showEndOfListToast();
			//alert('This is the last record');
        }
        else
        	component.set("v.PRA",allPRAItems[nextIndex]);
    },
    movePrevious : function(component, event, helper) {
        var currentPRAItem = component.get("v.PRA");
        var allPRAItems = component.get("v.PRAList");
        console.log(allPRAItems);
        var currentIndex = allPRAItems.indexOf(currentPRAItem);
         console.log('Current Index '  + currentIndex);
        var previousIndex = currentIndex-1;
         console.log('Previous Index '  + previousIndex);
        if(currentIndex===0){
            //component.destroy();
			helper.showStartOfListToast();
			//alert('This is the first record');
        }
        else
        	component.set("v.PRA",allPRAItems[previousIndex]);
    },
    overrideHeaderStyle : function(component, event, helper){
    	component.set("v.cssStyle", ".forceStyle .viewport.oneHeader.desktop {z-index:0} .forceStyle.desktop .viewport{overflow:hidden}");
	}
})