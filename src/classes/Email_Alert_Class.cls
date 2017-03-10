public with sharing class Email_Alert_Class {

	private Set<String> toAddresses;
	private string CentralEmailAddress = 'ricky.lowe@yopmail.com';
	public Messaging.SingleEmailMessage[] messages;
	public list<EmailMessage> EmailMessages;

	
	public Email_Alert_Class() {
		messages = new List<Messaging.SingleEmailMessage>();
		EmailMessages = new list<EmailMessage>();
	}

	public void registerNewEmail(string templateDevName, boolean sendToPreContractGroup, boolean sendToCentralEmailAddress, ID OppID, boolean sendToPDM, boolean sendToBDM, boolean sendToAllApprovers, ID currentApprover){
		EmailMessage EM = new EmailMessage();
		EM.templateDevName = templateDevName;
		EM.sendToPreContractGroup = sendToPreContractGroup;
		EM.sendToCentralEmailAddress = sendToCentralEmailAddress;
		EM.OppID = OppID;
		EM.sendToPDM = sendToPDM;
		EM.sendToBDM = sendToBDM;
		EM.sendToAllApprovers = sendToAllApprovers;
		EM.currentApprover = currentApprover;
		EmailMessages.add(EM);
	}

	public class EmailMessage{
		public string templateDevName;
		public boolean sendToPreContractGroup;
		public boolean sendToCentralEmailAddress;
		public ID OppID;
		public boolean sendToPDM;
		public boolean sendToBDM;
		public boolean sendToAllApprovers;
		public ID currentApprover;
	}

	public void sendEmails(){
		Set<ID> OppIds = new Set<ID>();
		Set<String> EmailTemplateDevNames = new Set<String>();

		for(EmailMessage EM: EmailMessages){
			OppIds.add(EM.OppID);
			EmailTemplateDevNames.add(EM.templateDevName);
		}

		Map<String, ID> EmailTemplatesDevNameToID = getTemplateIDs(EmailTemplateDevNames);
		Set<String> PreContract = getPreContractGroupMembers();
		map<ID, map<String, Set<string>>> MapOppToOppTeamMemberGroupedByRole = getOppTeamMembers(OppIds);
		System.debug(loggingLevel.Error, '*** MapOppToOppTeamMemberGroupedByRole: ' + MapOppToOppTeamMemberGroupedByRole);

		for(EmailMessage EM: EmailMessages){
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			Set<String> toAddresses = new Set<String>();

			//If Send To Pre Contract Group is set to true then find all the member of that public group
			if(EM.sendToPreContractGroup){
				toAddresses.addAll(PreContract);
			} 

			//If send to central email address is true then add to the recipient list
			if(EM.sendToCentralEmailAddress){
				toAddresses.add(CentralEmailAddress);
			}

			//Get the users grouped by role for the Opportunity
			map<String, Set<string>> groupedByRole = MapOppToOppTeamMemberGroupedByRole.get(EM.OppID);
			System.debug(loggingLevel.Error, '*** groupedByRole: ' + groupedByRole);
			
			//If send to PDM then add the PDM user
			if(EM.sendToPDM){
				if(groupedByRole.containsKey('Channel Manager')){
					toAddresses.addAll(groupedByRole.get('Channel Manager'));
				}
			}

			if(EM.sendToBDM){
				if(groupedByRole.containsKey('BDM')){
					toAddresses.addAll(groupedByRole.get('BDM'));
				}
				
			}

			if(EM.sendToAllApprovers){
				if(groupedByRole.containsKey('Approver')){
					toAddresses.addAll(groupedByRole.get('Approver'));
				}
			}

			if(EM.currentApprover != null){
				toAddresses.add(EM.currentApprover);
			}

			//toAddresses.add('005O0000003t7an');	//add my user for testing purposes
			
			//Set Fields
			System.debug(loggingLevel.Error, '*** toAddresses: ' + toAddresses);
			
			message.toAddresses = new List<String>(toAddresses);
			if(EM.templateDevName != null){
				message.setTemplateId(EmailTemplatesDevNameToID.get(EM.templateDevName));
			}
			
			message.setSaveAsActivity(true);
			message.setWhatId(EM.OppID);
			message.subject = 'Test 2';
			message.plainTextBody = 'This is the message body.';
			
			//add email message to list to send
			messages.add(message);
		}

		//send emails and debug
		for(Messaging.SendEmailResult SendResult : Messaging.sendEmail(messages)){

		}

	}

	private map<ID, map<String, Set<string>>> getOppTeamMembers(set<id> OppIds){
		map<ID, map<String, Set<string>>> MapOppToOppTeamMemberGroupedByRole = new map<ID, map<String, Set<string>>>();

		for(OpportunityTeamMember OTM : [SELECT Id,OpportunityAccessLevel,OpportunityId,TeamMemberRole,UserId FROM OpportunityTeamMember WHERE OpportunityId = :OppIds]){
			Set<String> UserIds = new Set<String>();
			map<String, Set<string>> groupedByRole = new map<String, Set<string>>();

			//Have we processed a team member for this Opportunity ID? If yes then do this
			if(MapOppToOppTeamMemberGroupedByRole.ContainsKey(OTM.OpportunityId)){
				groupedByRole = MapOppToOppTeamMemberGroupedByRole.get(OTM.OpportunityId);
				
				//Have we processed a team member in this Role for this opportunity. If yes then add the user to the list
				if(groupedByRole.containsKey(OTM.TeamMemberRole)){
					UserIds = groupedByRole.get(OTM.TeamMemberRole);
					UserIds.add(OTM.UserId);
				}
				//If no then create a new Role entry for the map
				else{
					Set<String> UserIdsNew = new Set<String>();
					UserIdsNew.add(OTM.UserId);
					groupedByRole.put(OTM.TeamMemberRole, UserIdsNew);
				}
			}
			//Have we processed a team member for this Opportunity ID? If no then do this
			else{
				map<String, Set<string>> groupedByRoleNew = new map<String, Set<string>>();
				Set<String> UserIdsNew2 = new Set<String>();
				UserIdsNew2.add(OTM.UserId);
				groupedByRoleNew.put(OTM.TeamMemberRole, UserIdsNew2);

				MapOppToOppTeamMemberGroupedByRole.put(OTM.OpportunityId, groupedByRoleNew);
			}
		}
		return MapOppToOppTeamMemberGroupedByRole;
	}


	private Map<String, ID> getTemplateIDs(Set<String> EmailTemplateDevNames){
		Map<String, ID> EmailTemplatesDevNameToID = new Map<String, ID>();

		for(EmailTemplate ET: [SELECT DeveloperName,Id,Name FROM EmailTemplate WHERE DeveloperName IN : EmailTemplateDevNames]){
			EmailTemplatesDevNameToID.put(ET.DeveloperName, ET.ID);
		}
		return EmailTemplatesDevNameToID;
	}


	public Set<String> getPreContractGroupMembers(){
		List<Group> PreContract = [SELECT DeveloperName,Id FROM Group WHERE DeveloperName = 'Pre_Contracts_Group' LIMIT 1];
		Set<String> PreContractUserIDs = new Set<String>();
		if(PreContract != null && PreContract.size() == 0){
			for(GroupMember gm : [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId = :PreContract[0].ID]){
				if(gm.UserOrGroupId != null && ((string) gm.UserOrGroupId).startsWith('005')){
					PreContractUserIDs.add(gm.UserOrGroupId);
				}
			}	
		}
		return PreContractUserIDs;
	}
}