Email_Alert_Class EA = new Email_Alert_Class(null, false, true);

Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {EA.message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) {
    System.debug('The email was sent successfully.');
} else {
    System.debug('The email failed to send: '
          + results[0].errors[0].message);
}
