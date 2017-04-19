Email_Alert_Class EA = new Email_Alert_Class();
//EA.registerNewEmail('Approval_Decsion_Required_Notification', false, true, '006O0000008lOvM', false, true, false, '005O0000003t7an','006O0000008lOvM');

EA.registerNewEmail('CRA_Approval_Decsion_Required', false, true, '006O0000008lOvM', false, true, false, '005O0000003t7an','006O0000008lOvM');
EA.registerNewEmail('Approval_Decsion_Required_Notification', false, true, '006O0000008lKg4', false, true, false, '005O0000003t7an','006O0000008lKg4');



//registerNewEmail(string templateDevName, boolean sendToPreContractGroup, boolean sendToCentralEmailAddress, ID OppID, boolean sendToPDM, boolean sendToBDM, boolean sendToAllApprovers, ID specificUserRecipient, ID objectForTemplateID)
EA.sendEmails();

