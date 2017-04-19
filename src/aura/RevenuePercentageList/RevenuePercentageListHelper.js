({
	getRevList: function(component) {
        var parentId = component.get("v.recordId");
        var status = component.get("v.filterStatus");
        //console.log('KCRAList inside setCallback parentId = ' + parentId);
        
        if (parentId == null || parentId == '') return;
        
        var action = component.get("c.getAllPercentageRevenueRecords");        
        
        action.setParams({
            "opportunityId" : parentId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  
            var listRev = [];
            var state = response.getState();

            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();
                console.log('revlist = ');
                console.log(returnVal);
                var total = 0;
                for(var i=0; i<returnVal.length; i++){
                    if(returnVal[i].Allocated__c!=='' && 
                       returnVal[i].Allocated__c!==null && 
                       returnVal[i].Allocated__c!==undefined){
                        total += returnVal[i].Allocated__c;
                    }
                }
                component.set('v.RevList',returnVal); 
                component.set('v.total',total);
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action); 
    },
    
     getOpportunity: function(component) {
        var oppId = component.get("v.recordId");
        
        if (oppId == null || oppId == '') return;
        var action = component.get("c.getOpportunity");        
        action.setParams({
            "opportunityId" : oppId
        });
        //Set up the callback
        action.setCallback(this, function(response) {  
            var state = response.getState();
            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();
                component.set('v.opp',returnVal); 
                console.log('opp..');
                console.log(returnVal);              
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action); 
    },
    
    updateOpportunity : function(component){
        console.log('2..');
        var opp = component.get("v.opp");
    	var action = component.get("c.updateOpportunity");
        action.setParams({ 
            "opp": opp
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();
            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue(); 
                console.log('update opp successfully');
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
        this.getRevList(component);
	},
    
    updateRevList: function(component){
    	var revList = component.get("v.RevList");
    	var action = component.get("c.updateRevList");
        action.setParams({ 
            "revList": revList
        });
        action.setCallback(this, function(response) {  
            var state = response.getState();
            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue(); 
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action);
        this.getRevList(component);
	}
})