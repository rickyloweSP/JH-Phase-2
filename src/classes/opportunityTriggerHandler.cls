public class opportunityTriggerHandler extends TriggerHandler{
    public static Boolean runOnce = true;
    public static final String KCRATemplateRecordTypeID   = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA Template').getRecordTypeId();
    public static final String KCRARecordTypeID           = Key_Commercial_Risks_Approvals__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('KCRA').getRecordTypeId();
    public static final String PRATemplateRecordTypeID    = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA Template').getRecordTypeId();
    public static final String PRARecordTypeID            = Project_Risk_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('PRA').getRecordTypeId();
    
    public OpportunityTriggerHandler() {
        //this.setMaxLoopCount(1);
    }
    
    public override void afterInsert() {
        insertKCRAitems();  //Create KCRA Related List Records from KCRA Template Records
        insertPRAitems();   //Create PRA Related List Records from PRA Template Records
    }


    public override void beforeUpdate() {
        determineGate();
    }   

    public override void AfterUpdate(){
        ApprovalProcessOrchestrator();
    }


    /**
     * @description Create KCRA Related List Records from KCRA Template Records
     * @return void
     **/
    private void insertKCRAitems(){
        List<Key_Commercial_Risks_Approvals__c> KCRAItemsToCreate = new List<Key_Commercial_Risks_Approvals__c>();
        List<Key_Commercial_Risks_Approvals__c> KCRATemplateItems = [SELECT name,ItemNo__c,Approved__c,KCRA_Item__c,Applicable__c
                                                                  FROM Key_Commercial_Risks_Approvals__c
                                                                  WHERE RecordTypeId =: KCRATemplateRecordTypeID];    
         for(Opportunity opp: (List<Opportunity>) Trigger.new){
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
         if(!KCRAItemsToCreate.isEmpty())
            insert KCRAItemsToCreate;
    }

    /**
     * @description Create PRA Related List Records from PRA Template Records
     * @return void
     **/
    private void insertPRAitems(){
        List<Project_Risk_Assessment__c> PRAItemsToCreate = new List<Project_Risk_Assessment__c>();
        List<Project_Risk_Assessment__c> PRATemplateItems = [SELECT name,category__c,Is_Critical_Risk__c,ItemNo__c,Mitigation_Strategy__c,Rating__c,Risk_Item__c,
                                                             		description__c,Help_Text_0A__c,Help_Text_0B__c,Help_Text_0C__c,Help_Text_1A__c,Help_Text_1B__c, 
                                                             		Help_Text_1C__c,Help_Text_2A__c,Help_Text_2B__c,Help_Text_2C__c,Help_Text_3A__c,Help_Text_3B__c,
                                                             		Help_Text_3C__c,Mitigation_Advice__c,Selected_Indicators__c,Selected_Indicators_With_Text__c
                                                             FROM Project_Risk_Assessment__c
                                                             WHERE RecordTypeId =: PRATemplateRecordTypeID];    
         for(Opportunity opp: (List<Opportunity>) Trigger.new){
             for(Project_Risk_Assessment__c PRATemplateItem : PRATemplateItems){
                 Project_Risk_Assessment__c newPRA = new Project_Risk_Assessment__c(ItemNo__c=PRATemplateItem.ItemNo__c,
                                                                                    Risk_Item__c=PRATemplateItem.Risk_Item__c ,
                                                                                    Category__c=PRATemplateItem.Category__c,
                                                                                    Is_Critical_Risk__c = PRATemplateItem.Is_Critical_Risk__c ,
                                                                                    Mitigation_Strategy__c = PRATemplateItem.Mitigation_Strategy__c,
                                                                                    Mitigation_Advice__c = PRATemplateItem.Mitigation_Advice__c,
                                                                                    Rating__c = PRATemplateItem.Rating__c,
                                                                                    RecordTypeId = PRARecordTypeID,
                                                                                    Opportunity__c=opp.id,
                                                                                    Help_Text_0A__c = PRATemplateItem.Help_Text_0A__c ,Help_Text_0B__c = PRATemplateItem.Help_Text_0B__c,
                                                                                    Help_Text_0C__c = PRATemplateItem.Help_Text_0C__c ,Help_Text_1A__c = PRATemplateItem.Help_Text_1A__c,
                                                                                    Help_Text_1B__c = PRATemplateItem.Help_Text_1B__c ,Help_Text_1C__c = PRATemplateItem.Help_Text_1C__c,
                                                                                    Help_Text_2A__c = PRATemplateItem.Help_Text_2A__c ,Help_Text_2B__c = PRATemplateItem.Help_Text_2B__c,
                                                                                    Help_Text_2C__c = PRATemplateItem.Help_Text_2C__c ,Help_Text_3A__c = PRATemplateItem.Help_Text_3A__c,
                                                                                    Help_Text_3B__c = PRATemplateItem.Help_Text_3B__c ,Help_Text_3C__c = PRATemplateItem.Help_Text_3C__c,
                                                                                    Selected_Indicators__c= PRATemplateItem.Selected_Indicators__c 
                                                                                   );
                 PRAItemsToCreate.add(newPRA);
             }   
         }
         if(!PRAItemsToCreate.isEmpty())
            insert PRAItemsToCreate;
    }




    /**
     * @description Determine the next gate
     * @return void
     * To Do:   1)  Confirm that if a gate is rejected then the opp stage is set to Closed Lost
     *          2)  Find EOI and PQ field(s)
     *          3)  X Set Gate Status properly for gates 4 + 5
     *          4)  Error handling
     **/
    private void determineGate(){
        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);
            
            //!!!!!!!!use old opportunity just in case the StageName changes and the trigger runs again!
            //If new then check if meets the criteria for Gate 1
            if(oldOpp.StageName == 'New'){
                if(opp.Overall_Prospect_Value__c > 10000000){
                    opp.StageName = 'Gate 1';
                    opp.Gate_Status__c = 'Not Started';
                }
                opp.TSF_Gate_Status__c = 'N/A';
                opp.CRA_Gate_Status__c = 'N/A';
            }
            //If gate 1 then if approved then either set to gate 2 or gate 3 depending on whether EOI/PQ/Non-Bonding required.
            else if(oldOpp.StageName == 'Gate 1'){
                if(opp.Gate_Status__c == 'Approved'){
                    if(opp.Non_Binding_Proposal_Required__c){// ||opp.EOI || opp.PQ){
                        opp.StageName = 'Gate 2';
                    }
                    else{
                        opp.StageName = 'Gate 3';
                    }
                    opp.Gate_Status__c = 'Not Started';
                }
                //Set stage to Closed lost if rejected?
                else if(opp.Gate_Status__c == 'Rejected'){
                    opp.StageName = 'Closed Lost';
                }
                opp.TSF_Gate_Status__c = 'N/A';
                opp.CRA_Gate_Status__c = 'N/A';
            }
            //If gate 2 and approved then move to gate 3. If rejected then set stage to closed lost
            else if(oldOpp.StageName == 'Gate 2'){
                if(opp.Gate_Status__c == 'Approved'){
                    opp.StageName = 'Gate 3';
                    opp.Gate_Status__c = 'Not Started';
                }
                else if(opp.Gate_Status__c == 'Rejected'){
                    opp.StageName = 'Closed Lost';
                }
                opp.TSF_Gate_Status__c = 'N/A';
                opp.CRA_Gate_Status__c = 'N/A';
            }
            //If gate 3 and approved then move to gate 4. If rejected then set stage to closed lost
            else if(oldOpp.StageName == 'Gate 3'){
                if(opp.Gate_Status__c == 'Approved'){
                    opp.StageName = 'Gate 4';
                    opp.TSF_Gate_Status__c = 'Not Started';
                    opp.CRA_Gate_Status__c = 'Not Started';
                    opp.Gate_Status__c = 'N/A';
                }
                else if(opp.Gate_Status__c == 'Rejected'){
                    opp.StageName = 'Closed Lost';
                }
            }
            //If gate 4 then both TSF and CRA approval is required to move to gate 5. If either one of them is rejected then set stage to closed lost
            else if(oldOpp.StageName == 'Gate 4'){
                if(opp.TSF_Gate_Status__c == 'Approved' && opp.CRA_Gate_Status__c == 'Approved'){
                    opp.StageName = 'Gate 5';
                    opp.TSF_Gate_Status__c = 'Not Started';
                    opp.CRA_Gate_Status__c = 'Not Started';
                }
                else if(opp.TSF_Gate_Status__c == 'Rejected' || opp.CRA_Gate_Status__c == 'Rejected'){
                    opp.StageName = 'Closed Lost';
                }
                opp.Gate_Status__c = 'N/A';
            }
            //If gate 5 then both TSF and CRA approval is required. If either one of them is rejected then set stage to closed lost
            else if(oldOpp.StageName == 'Gate 5'){
                if(opp.TSF_Gate_Status__c == 'Approved' && opp.CRA_Gate_Status__c == 'Approved'){
                    opp.StageName = 'Closed Won';
                }
                else if(opp.TSF_Gate_Status__c == 'Rejected' || opp.CRA_Gate_Status__c == 'Rejected'){
                    opp.StageName = 'Closed Lost';
                }
                opp.Gate_Status__c = 'N/A';
            }
        }
    }

    /**
     * @description Controls the approval process temporarily while we use field changes instead of the button component
     * @return void
     **/
    private void ApprovalProcessOrchestrator(){
        list<gate__c> gatesToUpsert = new list<gate__c>();
        set<id> OppsToStartApprovalProcess = new set<id>();

        for(Opportunity opp: (List<Opportunity>) Trigger.new){
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.ID);

            string gateNumber = getGateNumber(opp.stageName);

            if(gateNumber == '1' || gateNumber == '2' || gateNumber == '3'){
                //See if the gate Status has been initalised - meaning the user has initialised the approval process i.e. creating the Approvers
                if(oldOpp.Gate_Status__c == 'Not Started' && opp.Gate_Status__c == 'Reviewing Approvers'){
                    gatesToUpsert.add(new gate__c(name = opp.name + ' ' + opp.stageName, Gate_Number__c = gateNumber, opportunity__c = opp.ID));
                }
                //see if the Gate Status has been submitted for approval - i.e. triggering the approval process
                else if(oldOpp.Gate_Status__c == 'Reviewing Approvers' && opp.Gate_Status__c == 'Submitted For Approval'){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }
            else if(opp.stageName == 'Gate 4' || opp.stageName == 'Gate 5'){    
                //See if the CRA Status has been initalised
                if(oldOpp.CRA_Gate_Status__c == 'Not Started' && opp.CRA_Gate_Status__c == 'Reviewing Approvers'){
                    gatesToUpsert.add(new gate__c(name = opp.name + ' ' + opp.stageName + ' CRA', Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'CRA'));
                }
                //see if the CRA Status has been submitted for approval
                else if(oldOpp.CRA_Gate_Status__c == 'Reviewing Approvers' && opp.CRA_Gate_Status__c == 'Submitted For Approval'){
                    OppsToStartApprovalProcess.add(opp.ID);
                }

                //See if the TSF Status has been initalised
                if(oldOpp.TSF_Gate_Status__c == 'Not Started' && opp.TSF_Gate_Status__c == 'Reviewing Approvers'){
                    gatesToUpsert.add(new gate__c(name = opp.name + ' ' + opp.stageName + ' TSF', Gate_Number__c = gateNumber, opportunity__c = opp.ID, Gate_Type__c = 'TSF'));
                }
                //see if the TSF Status has been submitted for approval
                else if(oldOpp.TSF_Gate_Status__c == 'Reviewing Approvers' && opp.TSF_Gate_Status__c == 'Submitted For Approval'){
                    OppsToStartApprovalProcess.add(opp.ID);
                }
            }
            /*CRA_Gate_Status__c
            Gate_Status__c
            TSF_Gate_Status__c*/
        }

        for(Opportunity Opp: [SELECT ID,stageName, Gate_Status__c,CRA_Gate_Status__c,TSF_Gate_Status__c, (SELECT ID, Gate_Number__c, Gate_Type__c FROM Gates__r WHERE status__c = 'Not Started' ORDER BY CreatedDate desc) FROM Opportunity WHERE ID IN : OppsToStartApprovalProcess]){
            List<gate__c> gates = Opp.Gates__r;

            //If Gate Status is set to submitted For Approval then find the appropriate gate record and set the status to 'In Progress' to start the approval process
            if(Opp.Gate_Status__c == 'Submitted For Approval'){
                for(gate__c gate : gates){
                    if(gate.Gate_Number__c == getGateNumber(opp.stageName)){
                        gate.status__c = 'In Progress';
                        gatesToUpsert.add(gate);
                        break;
                    }
                }
            }
            else{
                if(Opp.TSF_Gate_Status__c == 'Submitted For Approval'){
                    for(gate__c gate : gates){
                        if(gate.Gate_Number__c == getGateNumber(opp.stageName) && gate.Gate_Type__c == 'TSF'){
                            gate.status__c = 'In Progress';
                            gatesToUpsert.add(gate);
                            break;
                        }
                    }
                }

                if(Opp.CRA_Gate_Status__c == 'Submitted For Approval'){
                    for(gate__c gate : gates){
                        if(gate.Gate_Number__c == getGateNumber(opp.stageName) && gate.Gate_Type__c == 'CRA'){
                            gate.status__c = 'In Progress';
                            gatesToUpsert.add(gate);
                            break;
                        }
                    }
                }
            }
        }

        try{
            upsert gatesToUpsert;
        }
        catch(exception e){

        }
    }


    private string getGateNumber(string stage){
        if(stage == 'Gate 1') return '1';
        else if(stage == 'Gate 2') return '2';
        else if(stage == 'Gate 3') return '3';
        else if(stage == 'Gate 4') return '4';
        else if(stage == 'Gate 5') return '5';
        else return '';
    }


}