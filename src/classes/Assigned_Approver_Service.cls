public without sharing class Assigned_Approver_Service {
	
	/**
     * @description Find the current Approver and send the Decision Required Email
     * @return void 
     **/
    public static void sendEmailToCurrentApprover(list<Assigned_Approver__c> newList, map<Id,Assigned_Approver__c> oldMap){
        Email_Alert_Class EA = new Email_Alert_Class();

        for(Assigned_Approver__c AA : newList){
            Assigned_Approver__c oldApprover = oldMap.get(AA.ID);
            boolean reminderEmail;
            boolean sendEmail;

            //if the Current Approver checkbox has just been set to true then send the decision required email
            if(AA.Current_Approver__c == TRUE && oldApprover.Current_Approver__c == FALSE){
            	//AA.Date_Time_Assigned_as_Current_Approver__c = dateTime.now();
            	//AA.Number_of_Reminder_Emails_Sent__c = 0;
            	reminderEmail = false;
            	sendEmail = true;
            }
            //If the Reminder number has been incremented then send the reminder email
			else if(AA.Number_of_Reminder_Emails_Sent__c != 0 && AA.Number_of_Reminder_Emails_Sent__c != oldApprover.Number_of_Reminder_Emails_Sent__c){
				reminderEmail = true;
				sendEmail = true;
			}

			//if sending email
			if(sendEmail == true){
				//AA.Last_Email_Sent__c = dateTime.now();

				if(AA.Gate_Type__c == 'CRA'){
					if(reminderEmail == true){
						EA.registerNewEmail(Constants.CRA_StalledReminderEmail, AA.Opportunity_ID__c);
					}
					else{
						EA.registerNewEmail(Constants.CRA_DecisionRequiredEmail, AA.Opportunity_ID__c);
					}
                }
                else if(AA.Gate_Type__c == 'TSF'){
                	if(reminderEmail == true){
                		EA.registerNewEmail(Constants.TSF_StalledReminderEmail, AA.Opportunity_ID__c);
					}
					else{
						EA.registerNewEmail(Constants.TSF_DecisionRequiredEmail, AA.Opportunity_ID__c);
					}
                }
                //else it is Gate 1 - 3
                else{ 
                	if(reminderEmail == true){
                		EA.registerNewEmail(Constants.StalledReminderEmail, AA.Opportunity_ID__c);
					}
					else{
						EA.registerNewEmail(Constants.DecisionRequiredEmail, AA.Opportunity_ID__c);
					}  
                    EA.setCurrentEmailField_sendToBDM(TRUE);
                }
                EA.setCurrentEmailField_SpecificUserRecipient(AA.Approver__c);
                EA.setCurrentEmailField_sendToPDM(TRUE);
                
                //if there is a proxy defined then add the proxy to the recipient list
                if(AA.Proxy_Approver__c != null){
                    EA.setCurrentEmailField_AddAdditionalRecipients(AA.Proxy_Approver__c);
                }
			}

        }

        //Send emails
        EA.sendEmails();
    }


    /**
     * @description Find the current approvers that have approved or Declined the Gate
     * @return void 
     **/
    public static void findCurrentApproversThatHaveApproved(list<Assigned_Approver__c> newList, map<Id,Assigned_Approver__c> oldMap, Boolean isBefore, Boolean isAfter){
    	System.debug(loggingLevel.Error, '*** Find approvers: ' + newList);

    	set<ID> gatesToFindNextApprover = new set<ID>();
        for(Assigned_Approver__c AA : newList){
            Assigned_Approver__c oldApprover = oldMap.get(AA.ID);
            System.debug(loggingLevel.Error, '*** Approvers before Wet Signature: ' + AA);

            //if wet signature received then set the approver status to Approved
            if(AA.Wet_Signature_Received__c == TRUE && Trigger.IsBefore){
                AA.Approval_Status__c = Constants.ApprovedStatus;
            }
            System.debug(loggingLevel.Error, '*** Approvers after Wet Signature: ' + AA);
            
            //if the status has been changed from Assigned Pending Approval to anything else then find next approver
            if(AA.Approval_Status__c != Constants.PendingApprovalStatus && oldApprover.Approval_Status__c == Constants.PendingApprovalStatus){
                System.debug(loggingLevel.Error, '*** Approver meets the requirements: ' + AA);
                
                if(IsAfter){
                	gatesToFindNextApprover.add(AA.gate__c);
                	System.debug(loggingLevel.Error, '*** Adding gate to the list: ' + AA.gate__c);
                }
                else if(IsBefore && AA.Current_Approver__c == TRUE){
                	AA.Current_Approver__c = FALSE;
                	System.debug(loggingLevel.Error, '*** Setting current approver as false: ' + AA.gate__c);
                }
            }
        }

        //If after trigger then find the next approver
        if(gatesToFindNextApprover.size() > 0 && IsAfter){
        	System.debug(loggingLevel.Error, '*** Triggering find next approver');
        	gateTriggerHandler.findNextApprover(gatesToFindNextApprover);
        }
    }

    /**
     * @description Increment the Email Reminder count to trigger the email.
     * @return void
     **/
    public static void sendReminderEmails(list<Assigned_Approver__c> newList){
        Debug_Log_Service Debug = new Debug_Log_Service('Email Reminder');
        try{
        	for(Assigned_Approver__c AA : newList){	
                Debug.updateLog('Processing ' + AA.Id);
                AA.Number_of_Reminder_Emails_Sent__c ++;
                AA.Last_Email_Sent__c = dateTime.now();
                Debug.updateLog('Setting Number_of_Reminder_Emails_Sent__c = '+ AA.Number_of_Reminder_Emails_Sent__c);
		    }
		    update newList;
        }
        catch(exception e){
        	Debug.logError(e);
        } 
        finally{
            Debug.finishLogging();
        }
    }

    /**
     * @description Increment the Email Reminder count to trigger the email.
     * @return void
     **/
    public static void setEmailDates(list<Assigned_Approver__c> newList, map<Id,Assigned_Approver__c> oldMap){
        for(Assigned_Approver__c AA : newList){
            Assigned_Approver__c oldApprover = oldMap.get(AA.ID);
            
            //if the Current Approver checkbox has just been set to true then send the decision required email
            if(AA.Current_Approver__c == TRUE && oldApprover.Current_Approver__c == FALSE){
                AA.Date_Time_Assigned_as_Current_Approver__c = dateTime.now();
                AA.Number_of_Reminder_Emails_Sent__c = 0;
                AA.Last_Email_Sent__c = dateTime.now();
            }
        }
    }

    /**
     * @description adds the Proxy approver as a share record
     * @return void
     **/
    public static void setProxyAsShareRecord(list<Assigned_Approver__c> newList){
        list<Assigned_Approver__Share> AssignedApproverShareList = new list<Assigned_Approver__Share>();

        for(Assigned_Approver__c AA : newList){
            if(AA.Proxy_Approver__c != null){
                Assigned_Approver__Share share = new Assigned_Approver__Share();
                share.ParentId = AA.Id;
                share.UserOrGroupId = AA.Proxy_Approver__c;
                share.AccessLevel = 'edit';
                share.RowCause = Schema.Assigned_Approver__Share.RowCause.Proxy_Approver__c;
                AssignedApproverShareList.add(share);
            }
        }
        insert AssignedApproverShareList;
    }

    /**
     * @description Adds the Proxy and the Approver to the Gate Sharing rules and the Opportunity Team Members
     * @return void
     **/
    public static void ControlApproversSharing(list<Assigned_Approver__c> newList){
        list<Assigned_Approver__Share> AssignedApproverShareList = new list<Assigned_Approver__Share>();

        
        insert AssignedApproverShareList;
    }


}