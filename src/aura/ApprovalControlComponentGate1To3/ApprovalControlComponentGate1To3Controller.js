({
    
    doInit: function(component, event, helper) { 

       // var OpportunityId = component.get("v.recordId");
        //helper.getPRAList(component,OpportunityId);
        helper.getOppRecord(component);
        
        var gateStatus = component.get("v.Opp.Gate_Status__c");
                    
   },   


    initiateOrSubmitApproval: function(component, event, helper) {  
        var StageName = component.get("v.Opp.StageName");
        var gateStatus = component.get("v.Opp.Gate_Status__c");
        console.log(gateStatus);

        if(StageName=='Gate 1'||StageName=='Gate 2'||StageName=='Gate 3'){
            if(gateStatus=='Not Started'||gateStatus=='Restarted'||gateStatus=='Resubmitted'||gateStatus=='Declined'){
                component.set("v.Opp.Gate_Status__c","Initiated"); 
                helper.disableInitiateApprovalButton(component);
                helper.enableSubmitApprovalButton(component);
                helper.enableViewApproversButton(component);
                component.set("v.buttonStyleSubmitApproval","uiButtonActive");
                component.set("v.buttonStyleInitiateApproval","uiButton");
                component.set("v.buttonStyleViewApprovers","uiButtonActive");

                
            }     
            else if(gateStatus=='Initiated')
            {
                component.set("v.Opp.Gate_Status__c","In Progress"); 
                helper.disableInitiateApprovalButton(component);
                helper.disableSubmitApprovalButton(component);
                helper.enableViewApproversButton(component);
                component.set("v.buttonStyleSubmitApproval","uiButton");
                component.set("v.buttonStyleInitiateApproval","uiButton");
                component.set("v.buttonStyleViewApprovers","uiButtonActive");
                
            }
            else{
                return;   
            }
        }
            
        var thisOpp = component.get("v.Opp");
        var OpportunityId = component.get("v.recordId");
        

        var action = component.get("c.updateOpportunity");

        action.setParams({"opp" : thisOpp});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
                }
                else {
                    helper.showSuccessToast();
                    $A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
        });

        $A.enqueueAction(action);		
	},
    
        initiateOrSubmitApprovalCRA: function(component, event, helper) {  
        var StageName = component.get("v.Opp.StageName");
		var CRACriticalRisks = component.find("CRACriticalRisks").get("v.value");
        var CRAChanged = component.find("CRAChanged").get("v.value");
        var CRAGateStatus = component.get("v.Opp.CRA_Gate_Status__c");

        if(StageName=='Gate 4'||StageName=='Gate 5'){
            if(CRAGateStatus=='Not Started'||CRAGateStatus=='Restarted'||CRAGateStatus=='Resubmitted'||CRAGateStatus=='Declined'){
                component.set("v.Opp.CRA_Gate_Status__c","Initiated"); 
                component.set("v.Opp.Are_there_any_critical_risks__c",CRACriticalRisks); 
                component.set("v.Opp.Has_CRA_changed_since_last_approval__c",CRAChanged); 
                helper.disableInitiateApprovalButtonCRA(component);
                helper.enableSubmitApprovalButtonCRA(component);
                helper.enableViewApproversButtonCRA(component);
                component.set("v.buttonStyleSubmitApprovalCRA","uiButtonActive");
                component.set("v.buttonStyleInitiateApprovalCRA","uiButton");
                component.set("v.buttonStyleViewApproversCRA","uiButtonActive");

                
            }     
            else if(CRAGateStatus=='Initiated')
            {
                component.set("v.Opp.CRA_Gate_Status__c","In Progress"); 
                component.set("v.Opp.Are_there_any_critical_risks__c",CRACriticalRisks); 
                component.set("v.Opp.Has_CRA_changed_since_last_approval__c",CRAChanged); 
                helper.disableInitiateApprovalButtonCRA(component);
                helper.disableSubmitApprovalButtonCRA(component);
                helper.enableViewApproversButtonCRA(component);
                component.set("v.buttonStyleSubmitApprovalCRA","uiButton");
                component.set("v.buttonStyleInitiateApprovalCRA","uiButton");
                component.set("v.buttonStyleViewApproversCRA","uiButtonActive");
                
            }
            else{
                return;   
            }
        }
            
        var thisOpp = component.get("v.Opp");
        var OpportunityId = component.get("v.recordId");

        var action = component.get("c.updateOpportunity");

        action.setParams({"opp" : thisOpp});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
                }
                else {
                    helper.showSuccessToast();
                    $A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
        });

        $A.enqueueAction(action);		
	},
     initiateOrSubmitApprovalTSF: function(component, event, helper) {  
        var StageName = component.get("v.Opp.StageName");

		var TSFChanged = component.find("TSFChanged").get("v.value");
        var TSFGateStatus = component.get("v.Opp.TSF_Gate_Status__c");
        if(StageName=='Gate 4'||StageName=='Gate 5'){
            if(TSFGateStatus=='Not Started'||TSFGateStatus=='Restarted'||TSFGateStatus=='Resubmitted'||TSFGateStatus=='Declined'){
                component.set("v.Opp.TSF_Gate_Status__c","Initiated"); 
                component.set("v.Opp.Has_TSF_changed_since_last_approval__c",TSFChanged); 
                helper.disableInitiateApprovalButtonTSF(component);
                helper.enableSubmitApprovalButtonTSF(component);
                helper.enableViewApproversButtonTSF(component);
                component.set("v.buttonStyleSubmitApprovalTSF","uiButtonActive");
                component.set("v.buttonStyleInitiateApprovalTSF","uiButton");
                component.set("v.buttonStyleViewApproversTSF","uiButtonActive");

                
            }     
            else if(TSFGateStatus=='Initiated')
            {
                component.set("v.Opp.TSF_Gate_Status__c","In Progress"); 
                component.set("v.Opp.Has_TSF_changed_since_last_approval__c",TSFChanged); 
                helper.disableInitiateApprovalButtonTSF(component);
                helper.disableSubmitApprovalButtonTSF(component);
                helper.enableViewApproversButtonTSF(component);
                component.set("v.buttonStyleSubmitApprovalTSF","uiButton");
                component.set("v.buttonStyleInitiateApprovalTSF","uiButton");
                component.set("v.buttonStyleViewApproversTSF","uiButtonActive");
                
            }
            else{
                return;   
            }
        }
            
        var thisOpp = component.get("v.Opp");
        var OpportunityId = component.get("v.recordId");

        var action = component.get("c.updateOpportunity");

        action.setParams({"opp" : thisOpp});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    helper.showErrorToast(resultStr);
                }
                else {
                    helper.showSuccessToast();
                    $A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                helper.displayActionError(response);
            }
        });

        $A.enqueueAction(action);		
	},


    viewApprovers: function(component, event, helper) {  
        console.log("viewApprovers 1 ");                   
        //helper.openAssignApprovals(component);     
        var thisOpp = component.get("v.Opp");
        console.log(thisOpp);   

        $A.createComponent("c:ViewApproversListComponent",{
        
            "Opp": thisOpp
        }, function(newComp) {
            var content = component.find("body");
            content.set("v.body", newComp);
            //document.getElementsByClassName('viewport')[0].style.overflow="hidden";
        });


        console.log("viewApprovers 2 ");      
    },
    submitForApproval: function(component, event, helper) {                 
        //helper.navigateToPRA(component);        
        console.log("submitForApproval}");      
    } 
})