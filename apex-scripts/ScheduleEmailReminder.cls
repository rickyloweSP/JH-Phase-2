
Email_Reminder_Schedulable batch2 = new Email_Reminder_Schedulable();
String sch2 = '0 0 10 * * ?';
system.schedule('Email Reminder Daily', sch2, batch2);