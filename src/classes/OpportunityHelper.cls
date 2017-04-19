public with sharing class OpportunityHelper {
    static final String KCRATemplateRecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA Template').getRecordTypeId();
    static final String KCRARecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA').getRecordTypeId();

    public static void createKCRARelatedList(List<Opportunity> newOpportunities) {
        List<Key_Commercial_Risks_Approvals__c> KCRAItemsToCreate = new List<Key_Commercial_Risks_Approvals__c>();
        List<Key_Commercial_Risks_Approvals__c> KCRATemplateItems = [SELECT name,ItemNo__c,Approved__c,KCRA_Item__c,Applicable__c
                                                                    FROM Key_Commercial_Risks_Approvals__c
                                                                    WHERE RecordTypeId =: KCRATemplateRecordTypeID];
        for(Opportunity opp: newOpportunities){
            for(Key_Commercial_Risks_Approvals__c KCRATemplateItem : KCRATemplateItems){
                Key_Commercial_Risks_Approvals__c newKCRA = new Key_Commercial_Risks_Approvals__c(ItemNo__c=KCRATemplateItem.ItemNo__c,
                                                                    KCRA_Item__c=KCRATemplateItem.KCRA_Item__c ,
                                                                    Applicable__c=KCRATemplateItem.Applicable__c,
                                                                    Approved__c = KCRATemplateItem.Approved__c,
                                                                    RecordTypeId = KCRARecordTypeID,
                                                                    Opportunity__c=opp.id);
                KCRAItemsToCreate.add(newKCRA);
            }
        }
        if(!KCRAItemsToCreate.isEmpty()){
            insert KCRAItemsToCreate;
        }
    }

    /**
     * @description Queries a list of Opportunities with the Opportunity team members that are Approvers
     * @return list of Opportunities
     **/
    public static list<Opportunity> getOppAndTeamMemberApprovers(set<ID> OppIDs){

        return [SELECT Business_Development_Manager__c,Id,OwnerId,Project_Development_Manager__c,
                   (SELECT Id,OpportunityAccessLevel,OpportunityId,TeamMemberRole,UserId 
                    FROM OpportunityTeamMembers 
                    WHERE TeamMemberRole = 'Approver') 
                FROM Opportunity 
                WHERE Id IN :oppIDs];
    }

    /**
     * @description Queries a list of Opportunity team members that are Approvers for a given list of opportunities
     * @return list of OpportunityTeamMember
     **/
    public static list<OpportunityTeamMember> getOppTeamMemberApprovers(set<ID> OppIDs){

        return [SELECT Id,OpportunityAccessLevel,OpportunityId,TeamMemberRole,UserId 
                    FROM OpportunityTeamMember
                    WHERE OpportunityId IN :oppIDs
                    AND TeamMemberRole = 'Approver'];
    }

    
    /**
     * @description returns a list of Opportunities for a given set of opportunity Ids
     * @return list of Opportunity records
     **/
    public static list<Opportunity> getOpportunityFields(ID OppID){
        return getOpportunityFields(new set<ID>{OppID});
    }

    /**
     * @description returns a list of Opportunities for a given set of opportunity Ids
     * @return list of Opportunity records
     **/
    public static list<Opportunity> getOpportunityFields(set<ID> OppIDs){

        return [SELECT Id,StageName,gate_Status__c,Business_Group__c,Regional_Business__c,Business_Development_Manager__c,OwnerId,Project_Development_Manager__c 
                FROM Opportunity
                WHERE ID IN :oppIDs];
    }

    /**
     * @description returns a list of Opportunities and their Initiated Gates
     * @return list of Opportunity records
     **/
    public static list<Opportunity> getOpportunitiesAndInitiatedGates(set<ID> OppsToStartApprovalProcess){

        return [SELECT ID,stageName, Gate_Status__c,CRA_Gate_Status__c,TSF_Gate_Status__c, 
                    (SELECT ID, Gate_Number__c, Gate_Type__c 
                    FROM Gates__r 
                    WHERE status__c = :Constants.InitiatedStatus 
                    ORDER BY CreatedDate desc) 
                FROM Opportunity 
                WHERE ID IN : OppsToStartApprovalProcess];
    }

    /**
     * @description gets the previous gate for the opportunity that has been Approved or rejected. Limit to 2 gate records.
     * @return 
     **/
    public static list<Opportunity> getOpportunitiesAndDecidedGates(ID OppToFindDecidedGates){

        return getOpportunitiesAndDecidedGates(new set<ID>{OppToFindDecidedGates});
    } 

    /**
     * @description gets the previous gate for the opportunity that has been Approved or rejected. Limit to 2 gate records.
     * @return 
     **/
    public static list<Opportunity> getOpportunitiesAndDecidedGates(set<ID> OppsToFindDecidedGates){

        return [SELECT ID,stageName, 
                    (SELECT ID, Gate_Number__c, Gate_Type__c, Status__c
                    FROM Gates__r 
                    WHERE (status__c = :Constants.ApprovedStatus 
                        OR status__c = :Constants.ConditionallyApprovedStatus 
                        OR status__c = :Constants.DeclinedStatus 
                        OR status__c = :Constants.RestartedStatus)
                    ORDER BY CreatedDate desc
                    LIMIT 2) 
                FROM Opportunity 
                WHERE ID IN : OppsToFindDecidedGates];
    } 


    /**
     * @description gets a list of the opportunity and its revenue items
     * @return 
     **/
    public static list<Opportunity> getOpportunitiesAndRevenue(set<ID> Opps){

        return [SELECT ID,stageName,Project_Duration_Months__c,Anticipated_Revenue_Start_Date__c,
                   (SELECT Allocated__c,Id,Inactive__c,Name,Opportunity__c,Period_Date__c,Period__c 
                    FROM Percentage_Revenues__r
                    ORDER BY Period_Date__c ASC Nulls Last) 
                FROM Opportunity 
                WHERE ID IN : Opps];
    } 


    /**
     * @description returns the current approver for the Opportunities. This will include the Gate ID 
     * @return list<Assigned_Approver__c> - a list of the current assigned Approvers for the Opportunities
     **/
    public static list<Assigned_Approver__c> getTheCurrentApprover(ID OppToFindCurrentApproverFor){
        return getTheCurrentApprover(new Set<ID>{OppToFindCurrentApproverFor});
    }

    /**
     * @description returns the current approver for the Opportunities. This will include the Gate ID 
     * @return list<Assigned_Approver__c> - a list of the current assigned Approvers for the Opportunities
     **/
    public static list<Assigned_Approver__c> getTheCurrentApprover(set<ID> OppsToFindCurrentApproverFor){

        return [SELECT Approval_Status__c,Approver__c,Current_Approver__c,Gate__c,Id,Gate__r.Gate_Type__c,Gate__r.Opportunity__c,Gate__r.Status__c
                FROM Assigned_Approver__c 
                WHERE Current_Approver__c = true
                AND Gate__r.Opportunity__c IN : OppsToFindCurrentApproverFor
                ORDER BY CreatedDate DESC];
    }

    /**
     * @description 
     * @return 
     **/
    public static list<OpportunityShare> getTheOppTeamShareRules(set<ID> oppIDs, set<ID> UserIds){

        return [SELECT Id, OpportunityAccessLevel,RowCause,UserOrGroupId 
                FROM OpportunityShare 
                WHERE OpportunityId IN :oppIDs 
                AND RowCause = 'Team' 
                AND UserOrGroupId IN :UserIds];
    }


    /**
     * @description Sorts the Opp Team members into a map categorised by Role
     * @return map<ID, map<String, Set<string>>> - A map of Opp ID to map of Role to Set of IDS
     **/
    public static map<ID, map<String, Set<string>>> getOppTeamMembers(set<id> OppIds){
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


    /**
     * @description Gets the gate number for a given Stage
     * @return sting - the gate number. String because picklist used for gate number on the Gate object
     **/
    public static string getGateNumber(string stage){
        if(stage == Constants.Gate1Stage) return '1';
        else if(stage == Constants.Gate2Stage) return '2';
        else if(stage == Constants.Gate3Stage) return '3';
        else if(stage == Constants.Gate4Stage) return '4';
        else if(stage == Constants.Gate5Stage) return '5';
        else return '';
    }

    /**
     * @description gets the first revenue start date
     * @return 
     **/
    public static date getFirstRevenueStartDate(opportunity opp){
        date startDate;

        //get all the components of the date
        date RevStartDate = opp.Anticipated_Revenue_Start_Date__c;
        integer dayComponent = RevStartDate.Day();
        integer monthComponent = RevStartDate.Month();
        integer yearComponent = RevStartDate.Year();
        
        //Add one month on and get components of the date
        date nextMonth = RevStartDate.addMonths(1);
        integer nextMonthComponent = nextMonth.Month();
        integer nextYearComponent = nextMonth.Year();
        
        //If day component is greater than 20 then return the first day of the next month
        if(dayComponent > 20){
            startDate = Date.newInstance(nextYearComponent,nextMonthComponent,1);
        }
        //else the start date is the first day of the current month
        else{
            startDate = Date.newInstance(yearComponent,monthComponent,1);
        }

        return startDate;
    }



}