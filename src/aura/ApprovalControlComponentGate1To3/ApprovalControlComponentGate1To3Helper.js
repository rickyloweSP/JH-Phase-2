({
getOppRecord: function(component) {
        var OppId = component.get("v.recordId");
        //var status = component.get("v.filterStatus");
        //console.log('KCRAList inside setCallback parentId = ' + parentId);
        
        if (OppId == null || OppId == '') return;
        
        var action = component.get("c.getOpportunityRecord");        
        
        action.setParams({
            "opportunityId" : OppId
        });
        
        //Set up the callback
        action.setCallback(this, function(response) {  

            var state = response.getState();

            if (state == "SUCCESS") {
                var returnVal =response.getReturnValue();

                component.set('v.Opp',returnVal[0]);
                var gateStatus = component.get("v.Opp.Gate_Status__c");

                if(gateStatus=='Not Started'||gateStatus=='Restarted'||gateStatus=='Resubmitted'||gateStatus=='Declined'){
                    component.set("v.buttonStyleSubmitApproval","uiButton");
                    component.set("v.buttonStyleInitiateApproval","uiButtonActive");
                    component.set("v.buttonStyleViewApprovers","uiButton");
                    component.set("v.DisableInitiateApproval",false); 
                    component.set("v.DisableSubmitForApproval",true); 
                    component.set("v.DisableViewApprovers",true); 

                    //console.log(gateStatus);
                    //var btnInitiateApproval = cmp.find('InitiateApproval');
                    //btnInitiateApproval.set("v.disabled", true);
                    
                }
                else if(gateStatus=='Initiated'){
                    
                    /*var nextButton = component.find('SubmitApproval');
                    nextButton.set("v.disabled", false);
                    nextButton.set("v.class", "uiButtonActive");
                    var previousButton = component.find('InitiateApproval');
                    previousButton.set("v.disabled", true);
                    previousButton.set("v.class", "uiButton");*/
                    component.set("v.buttonStyleSubmitApproval","uiButtonActive");
                    component.set("v.buttonStyleInitiateApproval","uiButton");
                    component.set("v.buttonStyleViewApprovers","uiButtonActive");
                    component.set("v.DisableSubmitForApproval",false); 
                    component.set("v.DisableInitiateApproval",true); 
                    
                }
                else if(gateStatus=='Not Started'){
                    component.set("v.buttonStyleViewApprovers","uiButton");
                    component.set("v.DisableViewApprovers",true); 
                }
                else{
                    component.set("v.buttonStyleSubmitApproval","uiButton");
                    component.set("v.buttonStyleInitiateApproval","uiButton");
                    component.set("v.buttonStyleViewApprovers","uiButtonActive"); 
                }

                var gateStatusCRA = component.get("v.Opp.CRA_Gate_Status__c");

                if(gateStatusCRA=='Not Started'||gateStatusCRA=='Restarted'||gateStatusCRA=='Resubmitted'||gateStatusCRA=='Declined'){
                    component.set("v.buttonStyleSubmitApprovalCRA","uiButton");
                    component.set("v.buttonStyleInitiateApprovalCRA","uiButtonActive");
                    component.set("v.buttonStyleViewApproversCRA","uiButton");
                    component.set("v.DisableInitiateApprovalCRA",false); 
                    component.set("v.DisableSubmitForApprovalCRA",true); 
                    component.set("v.DisableViewApproversCRA",true); 
                    //console.log(gateStatus);
                    //var btnInitiateApproval = cmp.find('InitiateApproval');
                    //btnInitiateApproval.set("v.disabled", true);
                    
                }
                else if(gateStatusCRA=='Initiated'){
                    component.set("v.buttonStyleSubmitApprovalCRA","uiButtonActive");
                    component.set("v.buttonStyleInitiateApprovalCRA","uiButton");
                    component.set("v.buttonStyleViewApproversCRA","uiButtonActive");
                    component.set("v.DisableSubmitForApprovalCRA",false); 
                    component.set("v.DisableInitiateApprovalCRA",true); 
                }
                else if(gateStatusCRA=='Not Started'){
                    component.set("v.buttonStyleViewApproversCRA","uiButton");
                    component.set("v.DisableViewApproversCRA",true); 
                }
                else{
                    component.set("v.buttonStyleSubmitApprovalCRA","uiButton");
                    component.set("v.buttonStyleInitiateApprovalCRA","uiButton");
                    component.set("v.buttonStyleViewApproversCRA","uiButtonActive"); 
                }

                var gateStatusTSF = component.get("v.Opp.TSF_Gate_Status__c");

                if(gateStatusTSF=='Not Started'||gateStatusTSF=='Restarted'||gateStatusTSF=='Resubmitted'||gateStatusTSF=='Declined'){
                    component.set("v.buttonStyleSubmitApprovalTSF","uiButton");
                    component.set("v.buttonStyleInitiateApprovalTSF","uiButtonActive");
                    component.set("v.buttonStyleViewApproversTSF","uiButton");
                    component.set("v.DisableInitiateApprovalTSF",false); 
                    component.set("v.DisableSubmitForApprovalTSF",true); 
                    component.set("v.DisableViewApproversTSF",true); 
                    //console.log(gateStatus);
                    //var btnInitiateApproval = cmp.find('InitiateApproval');
                    //btnInitiateApproval.set("v.disabled", true);
                    
                }
                else if(gateStatusTSF=='Initiated'){
                    component.set("v.buttonStyleSubmitApprovalTSF","uiButtonActive");
                    component.set("v.buttonStyleInitiateApprovalTSF","uiButton");
                    component.set("v.buttonStyleViewApproversTSF","uiButtonActive");
                    component.set("v.DisableSubmitForApprovalTSF",false); 
                    component.set("v.DisableInitiateApprovalTSF",true); 
                }
                else if(gateStatusTSF=='Not Started'){
                    component.set("v.buttonStyleViewApproversTSF","uiButton");
                    component.set("v.DisableViewApproversTSF",true); 
                }
                else{
                    component.set("v.buttonStyleSubmitApprovalTSF","uiButton");
                    component.set("v.buttonStyleInitiateApprovalTSF","uiButton");
                    component.set("v.buttonStyleViewApproversTSF","uiButtonActive"); 
                }


                $A.get('e.force:refreshView').fire();    

          
            }
            else if (state == "ERROR") {
                var errors = response.getError();                
                alert('Error : ' + JSON.stringify(errors));
            }
        });
        $A.enqueueAction(action); 
    },
    openAssignApprovals : function(component) {
        console.log("Inside OpenAssignApprovals");        
        var thisOpp=component.get("v.Opp");
        console.log(thisOpp);
        /*
        $A.createComponent("c:ViewApproversListComponent",{
        
            "Opp": Opp
        }, function(newComp) {
            var content = component.find("body");
            content.set("v.body", newComp);
            //document.getElementsByClassName('viewport')[0].style.overflow="hidden";
        });*/
    },
    /*doSave : function(cmp) {      
        var thisOpp = cmp.get("v.Opp");
		console.log(thisOpp); 
        var OpportunityId = cmp.get("v.recordId");
		console.log("Save 1"); 


        var action = cmp.get("c.updateOpportunity");

        action.setParams({"opp" : thisOpp});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultStr = response.getReturnValue();
                if (resultStr != ''){
                    console.log("Error 1"); 
                    helper.showErrorToast(resultStr);
                }
                else {
                    console.log("Success 1"); 
                    showSuccessToast();
                    //helper.showSuccess('Changes have been successfully saved.');
                    //$A.get('e.force:refreshView').fire();
                }    
            } else if (state === "ERROR") {
                console.log("Error 2"); 
                //helper.displayActionError(response);
            }
            //cmp.set('v.updatedKCRAItems', null);
            //cmp.set('v.isDirty', false);
            //helper.enableSaveButton(cmp);
        });

        $A.enqueueAction(action);		
	}*/
    showErrorToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message
        });
        toastEvent.fire();
	},
    
    showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
	},   
    displayActionError : function (response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showError(response.state + ' - ' + errors[0].message);
            }
        } else {
            this.showError('An unknown error has occurred.');
        }    
    },
    enableInitiateApprovalButton : function(cmp) {
        var thisButton = cmp.find('InitiateApproval');
        thisButton.set("v.disabled", false);
    },
    enableInitiateApprovalButtonCRA : function(cmp) {
        var thisButton = cmp.find('InitiateApprovalCRA');
        thisButton.set("v.disabled", false);
    },
    enableInitiateApprovalButtonTSF : function(cmp) {
        var thisButton = cmp.find('InitiateApprovalTSF');
        thisButton.set("v.disabled", false);
    },
    enableViewApproversButton : function(cmp) {
        var thisButton = cmp.find('ViewApprovers');
        thisButton.set("v.disabled", false);
    },
    enableViewApproversButtonCRA : function(cmp) {
        var thisButton = cmp.find('ViewApproversCRA');
        thisButton.set("v.disabled", false);
    },
    enableViewApproversButtonTSF : function(cmp) {
        var thisButton = cmp.find('ViewApproversTSF');
        thisButton.set("v.disabled", false);
    },
    enableSubmitApprovalButton : function(cmp) {
        var nextButton = cmp.find('SubmitApproval');
        nextButton.set("v.disabled", false);
        nextButton.set("v.class", "uiButtonActive");
        var previousButton = cmp.find('InitiateApproval');
        previousButton.set("v.disabled", true);
        previousButton.set("v.class", "uiButton");
    },
    enableSubmitApprovalButtonCRA : function(cmp) {
        var nextButton = cmp.find('SubmitApprovalCRA');
        nextButton.set("v.disabled", false);

        var previousButton = cmp.find('InitiateApprovalCRA');
        previousButton.set("v.disabled", true);
    },
    enableSubmitApprovalButtonTSF : function(cmp) {
        var nextButton = cmp.find('SubmitApprovalTSF');
        nextButton.set("v.disabled", false);
        var previousButton = cmp.find('InitiateApprovalTSF');
        previousButton.set("v.disabled", true);
    },
    disableInitiateApprovalButton : function(cmp) {
        var thisButton = cmp.find('InitiateApproval');
        thisButton.set("v.disabled", true);
    },
    disableInitiateApprovalButtonCRA : function(cmp) {
        var thisButton = cmp.find('InitiateApprovalCRA');
        thisButton.set("v.disabled", true);
    },
    disableInitiateApprovalButtonTSF : function(cmp) {
        var thisButton = cmp.find('InitiateApprovalTSF');
        thisButton.set("v.disabled", true);
    },
    disableSubmitApprovalButton: function(cmp) {
        var nextButton = cmp.find('SubmitApproval');
        nextButton.set("v.disabled", true);
    },
    disableSubmitApprovalButtonCRA: function(cmp) {
        var nextButton = cmp.find('SubmitApprovalCRA');
        nextButton.set("v.disabled", true);
    },
    disableSubmitApprovalButtonTSF: function(cmp) {
        var nextButton = cmp.find('SubmitApprovalTSF');
        nextButton.set("v.disabled", true);
    },
    
})