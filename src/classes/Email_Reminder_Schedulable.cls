global class Email_Reminder_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		Email_Reminder_Batch batch = new Email_Reminder_Batch();
		database.executeBatch(batch, integer.valueOf(Constants.Approvers.Email_Reminder_Batch_Size__c));
	}
}