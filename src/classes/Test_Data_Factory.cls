public with sharing class Test_Data_Factory {
	public static string oppName = 'RL Test Opp ' + string.valueOf(dateTime.now());
	public static user BDM;
	public static user PDM;
	public static user RegonalApproverL1;
	public static user RegonalApproverL2;
	public static user GroupApproverL1;
	public static user GroupApproverL2;
	public static user CEO;
	public static user COO;

	/**
     * @description sets up the users
     * @return List of Users
     **/	
	public static list<User> createUsers(integer noOfUsers){
		list<user> users = new list<user>();
		for(integer i = 0; i<noOfUsers; i++){
			String randomString = Util.returnRandomString(5);

			user U = new user(isactive = true, 
									firstname='First' + randomString, 
									lastName = 'last'+randomString, 
									username = 'Testuser' + randomString + '@JHTest.com', 
									email = 'Testuser' + randomString + '@JHTest.com', 
									profileID = Constants.getProfileID('John Holland Standard User'), 
									alias = 'U'+randomString, 
									communityNickname = 'U'+randomString, 
									EmailEncodingKey = 'ISO-8859-1', 
									LanguageLocaleKey = 'en_US', 
									LocaleSidKey = 'en_AU', 
									TimeZoneSidKey = 'Australia/Sydney');
			users.add(U);
		}
		return users;
	}

	/**
     * @description creates test Business Units
     * @return List of Business Units
     **/
	public static list<Business_Unit__c> createBusinessUnits(integer noOfBU, String BusinessStream){
		list<Business_Unit__c> BUs = new list<Business_Unit__c>();
		for(Integer i = 0; i < noOfBU; i++) {
			Business_Unit__c BU = new Business_Unit__c(name = string.valueOf(i), Business_stream__c = BusinessStream);
			BUs.add(BU);
		}
		return BUs;
	}

	/**
     * @description creates a regional and a business group BU
     * @return List of Business Units - regional at index 0, Business Group at index 1
     **/	
	public static list<Business_Unit__c> createRegionalAndGroupBU(){
		list<Business_Unit__c> BUs = new list<Business_Unit__c>();
		BUs.addAll(createBusinessUnits(1, 'Regional Business'));
		BUs.addAll(createBusinessUnits(1, 'Business Group'));
		insert BUs;
		return BUs;
	}

	/**
     * @description creates the Business Unit Approvers
     * @return List of Business Unit Approvers
     **/	
	public static Business_Unit_Approvers__c createBusinessUnitApprovers(ID BUID, ID UserId, string approverLevel){
		return new Business_Unit_Approvers__c  (Approval_Level__c = approverLevel, 
												Approver__c = UserId, 
												Proxy_Approver__c = null, 
												Business_Unit__c = BUID);
	}

	/**
     * @description inserts Accounts
     * @return list of accounts
     **/	
	public static list<Account> createAccount(integer noOfAccounts){
		list<Account> Acc = new list<Account>();
		for(integer i = 0; i<noOfAccounts; i++){
			Account A = new Account(name = 'Test');
			Acc.add(A);
		}
		insert Acc;
		return Acc;
	}

	/**
     * @description inserts Contacts
     * @return list of Contacts
     **/	
	public static list<Contact> createContact(integer noOfContactsPerAccount, list<Account> accounts){
		list<Contact> Con = new list<Contact>();
		for(Account Acc : accounts){
			for(integer i = 0; i<noOfContactsPerAccount; i++){
				Contact A = new Contact(lastName = 'Test', firstName = 'Test');
				Con.add(A);
			}
		}
			
		insert Con;
		return Con;
	}



	/**
     * @description creates test prospects
     * @return List of inserted Opportunities
     **/
	public static list<opportunity> createProspect(integer noOfProspects, boolean meetCriteriaForGate1, String startGate){
		decimal OPV;
		if(meetCriteriaForGate1){
			OPV = Constants.Approvers.Gate_1_Entry_Threshold__c + 1;
		}
		else{
			OPV = Constants.Approvers.Gate_1_Entry_Threshold__c - 1;
		}
		return createProspectForTestMethods(noOfProspects, OPV, startGate, oppName, 'a0BO000000F4DiNMAV', 'a0BO000000F4Di8MAF','00528000006B07F','005O0000003uaVK');
	}


	/**
     * @description creates test prospects
     * @return List of inserted Opportunities
     **/
	public static list<opportunity> createProspectForTestMethods(integer noOfProspects, decimal OPV, String startGate, String OppNameIn, ID RegionalBU, ID GroupBU, ID PDMId, ID BDMId){
		list<opportunity> prospects = new list<opportunity>();

		for(Integer i = 0; i < noOfProspects; i++) {
			opportunity opp = new opportunity();
			opp.AccountId = '001O0000017RQomIAG';		
			opp.Amount = OPV;
			opp.Anticipated_Revenue_Start_Date__c = date.today();
			opp.Apply_Default_Bonding__c = FALSE;
			opp.Budget_Confirmed__c = FALSE;
			opp.Business_Development_Manager__c = BDMId;
			opp.Business_Group__c = GroupBU;
			opp.Client_Drivers__c = 'test';
			opp.Client_Probity__c = FALSE;
			opp.Client_Relationship_Management__c = 'test';
			opp.CloseDate = date.today();
			opp.Contract_Responsibility__c = 'Construction Management/EPCM';
			opp.Conversion_Budget_Comments__c = '';
			opp.Country__c = 'Australia';
			//opp.CRA_Gate_Status__c = '';
			opp.Defect_Liability_Duration_Months__c = 12;
			opp.Detailed_Description__c = 'test';
			opp.Discovery_Completed__c = FALSE;
			opp.District__c = 'Northern Melbourne';
			opp.D_I_Involvement__c = FALSE;
			opp.Executive_Summary__c = 'Test';
			opp.Gate_Status__c = Constants.NotStartedStatus;
			opp.Independent_Credit_Check_Required__c = FALSE;
			opp.Managing_Contractor_Time_Risk__c = FALSE;
			opp.Name = OppNameIn;
			opp.Non_Binding_Proposal_Required__c = FALSE;
			opp.Probability = 60;
			opp.Project_Development_Manager__c = PDMId;
			opp.Project_Duration_Months__c = 24;
			opp.Project_Probability__c = 10;
			opp.Proposed_Margin_on_Revenue__c = 10;
			opp.Prospect_Priority__c = '1';
			opp.Prospect_Status__c = 'Prospect';
			opp.Reason_For_Performing_Work__c = 'test';
			opp.RecordTypeId = Constants.getNewRecordType();
			opp.Regional_Business__c = RegionalBU;
			opp.StageName = startGate;
			opp.State__c = 'Victoria';
			opp.Tender_Close_Date__c = date.today();
			opp.Tender_Start_Date__c = date.today();
			//opp.TSF_Gate_Status__c = '';
			opp.Value_of_Managed_Works__c = 1000000;
			opp.Type = '';
			opp.Win_Probability__c = 10;
			prospects.add(opp);			
		}
		insert prospects;
		return prospects;
	}

	/**
     * @description Create a test prospect with all the required records for the approval process
     * @return void
     **/
	public static list<Opportunity> CreateProspectAndOtherRecords(){
		//create users
		list<user> users = createUsers(8);	
		insert users;

		//assign created users to the various user "roles"
		BDM = users[0];
		PDM = users[1];
		RegonalApproverL1 = users[2];
		RegonalApproverL2 = users[3];
		GroupApproverL1 = users[4];
		GroupApproverL2 = users[5];
		CEO = users[6];
		COO = users[7];

		//Create custom setting for Approval process
		createApprovalCS(CEO.Id, COO.Id);

		//Insert Business Units
		list<Business_Unit__c> BUs = createRegionalAndGroupBU();

		//Insert Business Unit Approvers
		list<Business_Unit_Approvers__c> BUA = new list<Business_Unit_Approvers__c>();
		BUA.add(createBusinessUnitApprovers(BUs[0].Id, RegonalApproverL1.Id, '1'));	//Insert Level 1 BU Approver for regional BU
		BUA.add(createBusinessUnitApprovers(BUs[0].Id, RegonalApproverL2.Id, '2'));	//Insert Level 2 BU Approver for regional BU
		BUA.add(createBusinessUnitApprovers(BUs[1].Id, GroupApproverL1.Id, '1'));	//Insert Level 1 BU Approver for group BU
		BUA.add(createBusinessUnitApprovers(BUs[1].Id, GroupApproverL2.Id, '2'));	//Insert Level 2 BU Approver for group BU
		insert BUA;

		//create the Prospect
		list<Opportunity> Opp = createProspectForTestMethods(1,Constants.Approvers.Higher_Threshold__c + 1, 'New', oppName, BUs[0].ID, BUs[1].ID, PDM.ID, BDM.ID);
		return Opp;
	}     


	/**
     * @description inserts Approval Custom Setting
     * @return void
     **/
	public static void createApprovalCS(ID CEOin, ID COOin){
		insert new Approvers__c(SetupOwnerId=UserInfo.getOrganizationId(), CEO_User_ID__c = CEOin, COO_User_ID__c = COOin, Lower_Threshold__c = 200000000, Higher_Threshold__c = 500000000, Gate_1_Entry_Threshold__c = 10000000);
	}

	/**
     * @description inserts Approval Custom Setting
     * @return void
     **/
	public static void createApprovalCS(){
		createApprovalCS(UserInfo.getUserId(), UserInfo.getUserId());
	}

}