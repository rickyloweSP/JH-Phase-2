public with sharing class Constants {

	public class ApproversNotDefinedException extends Exception {}

	//approver Custom Setting
	public static Approvers__c Approvers{
		get{
			if(Approvers == null){
				Approvers = Approvers__c.getInstance();
				if(Approvers.CEO_User_ID__c == null || Approvers.COO_User_ID__c == null){
					throw new ApproversNotDefinedException('COO or CEO Approvers not defined in the Approvers__c custom setting');
				}

				if(Approvers.Lower_Threshold__c == null || Approvers.Higher_Threshold__c == null || Approvers.Gate_1_Entry_Threshold__c == null){
					throw new ApproversNotDefinedException('OPV Thresholds not defined in the Approvers__c custom setting');
				}

				if(Approvers.Number_of_Days_Between_Reminder_Emails__c == null || Approvers.Number_of_Reminder_Emails_to_be_Sent__c == null){
					throw new ApproversNotDefinedException('Email Reminder settings are not defined in the Approvers__c custom setting');
				}
			}
			return Approvers;
		}
		set;
	}

	//get Opp Record Types
	public static map<String,ID> OppRecordTypeMap{
		get{
			if(OppRecordTypeMap == null){
				OppRecordTypeMap = new map<String,ID>();
				for(RecordType RT : [SELECT DeveloperName,Id 
									 FROM RecordType 
									 WHERE SobjectType = 'Opportunity' 
									 AND IsActive = true]){
					OppRecordTypeMap.put(RT.DeveloperName, RT.Id);
				}
			}
			return OppRecordTypeMap;
		}
		set;
	}	

	//get Opp new record type
	public static ID getNewRecordType(){
		return OppRecordTypeMap.get('New_D_C');
	}

	/**
     * @description map of profile name to profile ID
     **/
	public static map<string, ID> profileNameToID{
		get{
			if(profileNameToID == null){
				profileNameToID = new map<string, ID>();
				for(profile prof : [SELECT Id,Name FROM Profile]){
					profileNameToID.put(prof.name, prof.id);
				}
			}
			return profileNameToID;
		}
		set;
	}

	/**
     * @description get specific profile ID
     **/
	public static ID getProfileID(string profileName){
		return profileNameToID.get(profileName);
	}

	//Gate statuses
	public static final string NotStartedStatus 					= 'Not Started';
	public static final string InitiatedStatus 						= 'Initiated';
	public static final string InProgressStatus 					= 'In Progress';
	public static final string ApprovedStatus 						= 'Approved';
	public static final string ConditionallyApprovedStatus 			= 'Conditionally Approved';
	public static final string DeclinedStatus 						= 'Declined';
	public static final string ResubmittedStatus 					= 'Resubmitted';
	public static final string RestartedStatus 						= 'Restarted';
	public static final string NotApplicableStatus 					= 'Not Applicable';
	
	//Assigned Approver status
	public static final string PendingApprovalStatus 				= 'Pending Approval';

	//Prospect Status Values
	public static final string TenderWonStatus 						= 'Tender Won';
	public static final string TenderInPreperationStatus 			= 'Tender in Preparation';
	public static final string TenderSubmittedStatus 				= 'Tender Submitted';

	//Gate Stage Values
	public static final string NewDandCStage 						= 'New';
	public static final string Gate1Stage 							= 'Gate 1';
	public static final string Gate2Stage 							= 'Gate 2';
	public static final string Gate3Stage 							= 'Gate 3';
	public static final string Gate4Stage 							= 'Gate 4';
	public static final string Gate5Stage 							= 'Gate 5';
	public static final string ClosedWonStage 						= 'Closed Won';

	//Email Template Names
	public static final string ApprovalOutcomeNotificationEmail 	= 'Gate_Approval_Outcome_Notification';
	public static final string DecisionRequiredEmail 				= 'Approval_Decsion_Required_Notification';
	public static final string ApprovalSubmissionEmail 				= 'Approval_Submission_Notification';
	public static final string StalledReminderEmail 				= 'Alert_Reminder_Email_Stalled_Approvals';
	public static final string TSF_ApprovalOutcomeNotificationEmail = 'TSF_Approval_Outcome_Notification';
	public static final string TSF_DecisionRequiredEmail 			= 'TSF_Approval_Decsion_Required';
	public static final string TSF_ApprovalSubmissionEmail 			= 'TSF_Approval_Submission_Notification';
	public static final string TSF_StalledReminderEmail 			= 'TSF_Alert_Reminder_Email_Stalled_Appr';
	public static final string CRA_ApprovalOutcomeNotificationEmail = 'CRA_Approval_Outcome_Notification';
	public static final string CRA_DecisionRequiredEmail 			= 'CRA_Approval_Decsion_Required';
	public static final string CRA_ApprovalSubmissionEmail 			= 'CRA_Approval_Submission_Notification';
	public static final string CRA_StalledReminderEmail 			= 'CRA_Alert_Reminder_Email_Stalled_Appr';
	public static final string TenderWonEmail 						= 'Tender_Won_Notification';

	//RecordTypes
	public static final String KCRATemplateRecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA Template').getRecordTypeId();
    public static final String KCRARecordTypeID           = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA').getRecordTypeId();
    public static final String PRATemplateRecordTypeID    = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA Template').getRecordTypeId();
    public static final String PRARecordTypeID            = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA').getRecordTypeId();

}