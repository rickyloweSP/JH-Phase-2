public with sharing class Email_Alert_Class {
	public class CustomEmailException extends Exception {}

	private Set<String> toAddresses;
	private string CentralEmailAddress = 'ricky.lowe@yopmail.com';
	private Messaging.SingleEmailMessage[] messages;
	private list<EmailMessage> EmailMessages;
	private Set<ID> OppIds = new Set<ID>();
	private Set<String> EmailTemplateDevNames = new Set<String>();
	private Contact randomContact;
	private Set<String> PreContractUsers;
	private Map<String, ID> EmailTemplatesDevNameToID;
	private map<ID, map<String, Set<string>>> MapOppToOppTeamMemberGroupedByRole;
	private EmailMessage EM;	//Current Email Message
	
	public Email_Alert_Class() {
		messages = new List<Messaging.SingleEmailMessage>();
		EmailMessages = new list<EmailMessage>();
	}

	public void registerNewEmail(string templateDevName, ID OppID){
		EM = new EmailMessage();
		EM.templateDevName = templateDevName;
		EM.OppID = OppID;
		EM.objectForTemplateID = OppID;			//Default to Opportunity ID
		EM.specificUserRecipient = null;		//Default to null
		EM.sendToPreContractGroup = FALSE;		//default to TRUE
		EM.sendToCentralEmailAddress = TRUE;	//default to TRUE
		EM.sendToPDM = FALSE;					//Default to FALSE
		EM.sendToBDM = FALSE;					//Default to FALSE
		EM.sendToAllApprovers = FALSE;			//Default to FALSE
		EmailMessages.add(EM);
		
		//add to the OppID Set + Email Template dev Set for querying the Opp Team members and Email Template IDs
		if(EM.OppID != null){
			OppIds.add(EM.OppID);
		}

		if(EM.templateDevName != null){
			EmailTemplateDevNames.add(EM.templateDevName);
		}
	}


	public void setCurrentEmailField_SpecificUserRecipient(ID specificUserRecipient){
		EM.specificUserRecipient = specificUserRecipient;
	}
	
	public void setCurrentEmailField_AddAdditionalRecipients(ID additionalRecipients){
		EM.additionalRecipients.add(additionalRecipients);
	}

	public void setCurrentEmailField_sendToPDM(boolean sendToPDM){
		//EM.sendToPDM = sendToPDM;
	}

	public void setCurrentEmailField_sendToBDM(boolean sendToBDM){
		//EM.sendToBDM = sendToBDM;
	}

	public void setCurrentEmailField_sendToAllApprovers(boolean sendToAllApprovers){
		//EM.sendToAllApprovers = sendToAllApprovers;
	}
	


	/*public void registerNewEmail(string templateDevName, boolean sendToPreContractGroup, boolean sendToCentralEmailAddress, ID OppID, boolean sendToPDM, boolean sendToBDM, boolean sendToAllApprovers, ID specificUserRecipient, ID objectForTemplateID){
		EM = new EmailMessage();
		EM.templateDevName = templateDevName;
		EM.sendToPreContractGroup = sendToPreContractGroup;
		EM.sendToCentralEmailAddress = sendToCentralEmailAddress;
		EM.OppID = OppID;
		EM.sendToPDM = sendToPDM;
		EM.sendToBDM = sendToBDM;
		EM.sendToAllApprovers = sendToAllApprovers;
		EM.specificUserRecipient = specificUserRecipient;
		EM.objectForTemplateID = objectForTemplateID;
		EmailMessages.add(EM);
		
		//add to the OppID Set + Email Template dev Set for querying the Opp Team members and Email Template IDs
		if(EM.OppID != null){
			OppIds.add(EM.OppID);
		}

		if(EM.templateDevName != null){
			EmailTemplateDevNames.add(EM.templateDevName);
		}
	}*/

	public class EmailMessage{
		public string templateDevName;
		public boolean sendToPreContractGroup;
		public boolean sendToCentralEmailAddress;
		public ID OppID;
		public boolean sendToPDM;
		public boolean sendToBDM;
		public boolean sendToAllApprovers;
		public ID specificUserRecipient;
		public set<string> additionalRecipients = new set<string>();
		public ID objectForTemplateID;
	}

	public void sendEmails(){
		//if there are any messages to send
		if(EmailMessages != null && EmailMessages.size() > 0){
			Debug_Log_Service debug = new Debug_Log_Service('Send Email');
			try{
				getTemplateIDs(EmailTemplateDevNames);												//Get Template IDs
				getPreContractGroupMembers();														//Get Precontract group Users
				MapOppToOppTeamMemberGroupedByRole = OpportunityHelper.getOppTeamMembers(OppIds);	//Get Opp Team Members
				setRandomContact();																	//Get a random Contact in the system - the email won't actually get sent to the contact
				debug.updateLog('*** Map of Opportunity to Team Member - grouped by Role: ' + MapOppToOppTeamMemberGroupedByRole);
			
				for(EmailMessage EM: EmailMessages){
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					Set<String> toAddresses = new Set<String>();

					//If Send To Pre Contract Group is set to true then find all the member of that public group
					if(EM.sendToPreContractGroup){
						toAddresses.addAll(PreContractUsers);
					} 

					//If send to central email address is true then add to the recipient list
					if(EM.sendToCentralEmailAddress){
						toAddresses.add(CentralEmailAddress);
					}

					//Get the users grouped by role for the Opportunity
					map<String, Set<string>> groupedByRole = MapOppToOppTeamMemberGroupedByRole.get(EM.OppID);

					//If send to PDM then add the PDM user
					if(EM.sendToPDM){
						if(groupedByRole.containsKey('PDM')){
							toAddresses.addAll(groupedByRole.get('PDM'));
						}
					}
					//If send to BDM then add the BDM user
					if(EM.sendToBDM){
						if(groupedByRole.containsKey('BDM')){
							toAddresses.addAll(groupedByRole.get('BDM'));
						}
						
					}

					//If send to All approvers then get all approvers
					if(EM.sendToAllApprovers){
						if(groupedByRole.containsKey('Approver')){
							toAddresses.addAll(groupedByRole.get('Approver'));
						}
					}

					//If send to a specific user then add the user
					if(EM.specificUserRecipient != null){
						toAddresses.add(EM.specificUserRecipient);
					}

					//If addtional recipients then add to the toAddresses
					if(EM.additionalRecipients != null && EM.additionalRecipients.size() >0){
						toAddresses.addAll(EM.additionalRecipients);
					}

					debug.updateLog('*** toAddresses: ' + toAddresses);

					//Set Email Fields
					if(EM.templateDevName != null && toAddresses.size() > 0 && EM.OppID != null){
						message.setTemplateId(EmailTemplatesDevNameToID.get(EM.templateDevName));
						message.toAddresses = new List<String>(toAddresses);
						message.setSaveAsActivity(false);
						message.setWhatId(EM.OppID);
						if(EM.specificUserRecipient != null){
							message.setTargetObjectId(EM.specificUserRecipient);
						}
						else{
							message.setTargetObjectId(randomContact.ID);
						}
						
						
						//add email message to list to send
						messages.add(message);
					}
					else{
						throw new CustomEmailException('Template, Recipients or Opportunity not defined');
					}
				}

				//send email and roll back. This is to get the contents of the emails with the random contact set. Work around for not being able send an email template to a user and save as an email record
				Savepoint sp = Database.setSavepoint();
				Messaging.sendEmail(messages);
				Database.rollback(sp);

				// For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
				// contents to a new SingleEmailMessage. Then send those new messages.
				List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
				for (Messaging.SingleEmailMessage email : messages) {
					Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
					emailToSend.setToAddresses(email.getToAddresses());
					emailToSend.setPlainTextBody(email.getPlainTextBody());
					emailToSend.setHTMLBody(email.getHTMLBody());
					emailToSend.setSubject(email.getSubject());
					emailToSend.setWhatId(email.getWhatID());
					emailToSend.setSaveAsActivity(true);
					lstMsgsToSend.add(emailToSend);
				}
				Messaging.sendEmail(lstMsgsToSend);
			}
			catch (Exception E){
				debug.logError(E);
				
			}
			finally{
				if(Constants.Approvers.Enable_Detailed_Logging__c || debug.doesLogIncludeErrors()){
					debug.finishLogging();
				}
			}
		}
	}


	private Map<String, ID> getTemplateIDs(Set<String> EmailTemplateDevNames){
		EmailTemplatesDevNameToID = new Map<String, ID>();

		for(EmailTemplate ET: [SELECT DeveloperName,Id,Name FROM EmailTemplate WHERE DeveloperName IN : EmailTemplateDevNames AND IsActive = true]){
			EmailTemplatesDevNameToID.put(ET.DeveloperName, ET.ID);
		}
		return EmailTemplatesDevNameToID;
	}


	public Set<String> getPreContractGroupMembers(){
		List<Group> PreContract = [SELECT DeveloperName,Id FROM Group WHERE DeveloperName = 'Pre_Contracts_Group' LIMIT 1];
		PreContractUsers = new Set<String>();
		if(PreContract != null && PreContract.size() == 0){
			for(GroupMember gm : [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId = :PreContract[0].ID]){
				if(gm.UserOrGroupId != null && ((string) gm.UserOrGroupId).startsWith('005')){
					PreContractUsers.add(gm.UserOrGroupId);
				}
			}	
		}
		return PreContractUsers;
	}

	public Contact setRandomContact(){
		list<contact> cons = [Select ID, Email FROM Contact WHERE Email <> null LIMIT 1];
		if(cons != null && cons.size() > 0){
			randomContact = cons[0];
		}
		else{
			throw new CustomEmailException('There needs to be at least 1 Contact with an email address in the system. This is a workaround to populate the email contents - the email isnt sent to this contact');
		}
		
		return randomContact;
	}
}