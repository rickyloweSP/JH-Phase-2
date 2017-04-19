({
	doInit: function(component, event, helper) { 
        helper.getRevList(component);
        helper.getOpportunity(component);
   	},
   	doSave : function(cmp, event, helper) {
        console.log('1...');
		helper.updateOpportunity(cmp);
   	},
    doSaveRev : function(cmp, event, helper){
    	helper.updateRevList(cmp);
	}
})