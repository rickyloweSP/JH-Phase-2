global class Email_Reminder_Batch implements Database.Batchable<sObject>, Database.Stateful{
	global String Query; 
	global date theDate;
	global Debug_Log_Service Debug;
	global integer recordCount = 0;

	global Email_Reminder_Batch() {
		Debug = new Debug_Log_Service('Email Reminder Batch');
		theDate = Assigned_Approver_Helper.getDateForReminders();
		query = Assigned_Approver_Helper.getQueryForReminders();
		Debug.updateLog('query: ' + query);
		Debug.updateLog('theDate: ' + theDate);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Debug.updateLog('*** Reminding ' + scope.size() + ' Approvers');
   		recordCount += scope.size();
		Assigned_Approver_Service.sendReminderEmails((list<Assigned_Approver__c>) scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		Debug.updateLog('*** Total of ' + recordCount + ' Reminders Sent');
		Debug.finishLogging();
		Debug_Log_Service.deleteLogsOlderThanXDays(integer.valueOf(Constants.Approvers.Keep_Debug_Logs_For_X_Days__c));
	}
	
}