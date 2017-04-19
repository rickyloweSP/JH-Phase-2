public without sharing class Assigned_Approver_Helper {
	/**
     * @description returns the query for selecting Approvers that need reminding. Note the name of the Date variable theDate needs to be the same as the date variable in the batch class
     * @return string of the query
     **/
    public static string getQueryForReminders(){
    	string query;
    	query = 'SELECT Approval_Level__c,Approval_Status__c,Current_Approver__c,Date_Time_Assigned_as_Current_Approver__c,Decision_Date__c,Number_of_Reminder_Emails_Sent__c,Last_Email_Sent__c';
		query += ' FROM Assigned_Approver__c';
		query += ' WHERE Number_of_Reminder_Emails_Sent__c < ' + Constants.Approvers.Number_of_Reminder_Emails_to_be_Sent__c;
		query += ' AND Last_Email_Sent__c <= :theDate';
		query += ' AND Current_Approver__c = true';
		query += ' AND Approval_Status__c = \'' + Constants.PendingApprovalStatus + '\'';
        return query;
    }

	/**
     * @description Get date for reminder
     * @return date of reminder
     **/
    public static date getDateForReminders(){
        date d = date.today().addDays(- integer.ValueOf(Constants.Approvers.Number_of_Days_Between_Reminder_Emails__c));
        return d;
    }

    /**
     * @description creates approver gate share record from the gate id and the user id
     * @return 
     **/
    public static Gate__Share createGateShare(ID gateID, ID UserID){
        Gate__Share share = new Gate__Share();
        share.ParentId = gateID;
        share.UserOrGroupId = UserID;
        share.AccessLevel = 'edit';
        share.RowCause = Schema.Gate__Share.RowCause.Approver__c;
        return share;
    }

}