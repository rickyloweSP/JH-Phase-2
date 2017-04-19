/*------------------------------------------------------------------------
 * Authors:       Alex Odago, Ricky Lowe
 * Company:       System Partners
 * Description:   Apex Trigger Handler for Opportunity object
 *
 * Test Class:    
 * 
 * History:
 * 2017-MAR-03    Alex Odago     Created
 * 2017-MAR-10    Ricky Lowe     Added logic for Prospect Lifecycle and Approval
 * 2017-MAR-13    Ricky Lowe     Commented out logic for Prospect Lifecycle and Approval so no issues arise while I am away
 * 2017-APR-18    Ricky Lowe     Moved logic to OpportunityService and added Logic to manage Revenue
 --------------------------------------------------------------------------*/
public class OpportunityTriggerHandler extends TriggerHandler{
    public static boolean recursionBefore = false;
    public static boolean recursionAfter = false;
    public list<Opportunity> newList;
    public list<Opportunity> oldList;
    public map<Id,Opportunity> newMap;
    public map<Id,Opportunity> oldMap;
    public boolean isInsert;
    public boolean isUpdate;

    /**
     * @description Constructor - set all the Trigger variables
     * @return void
     **/
    public OpportunityTriggerHandler() {
        newList = (list<Opportunity>) Trigger.new;
        oldList = (list<Opportunity>) Trigger.old;
        newMap = (map<Id,Opportunity>) Trigger.newMap;
        oldMap = (map<Id,Opportunity>) Trigger.oldMap;
        isInsert = Trigger.IsInsert;
        isUpdate = Trigger.IsUpdate;
    }

    /**
     * @description Before Insert Methods
     * @return void
     **/
    public override void beforeInsert() {
        System.debug(loggingLevel.Error, '*** BEFORE INSERT **');
        for(Opportunity opp: newList){
            //determine whether the Prospect goes into gate 1 or 3
            OpportunityService.determineFirstGateFromNew(opp);  

            //Determine the owner based on the gate      
            OpportunityService.BDM_PDM_Owner_Manager(opp);                  
        }
    }  

    /**
     * @description After Insert Methods
     * @return void
     **/
    public override void afterInsert() {
        System.debug(loggingLevel.Error, '*** AFTER INSERT **');

        //Create KCRA Related List Records from KCRA Template Records
        OpportunityService.insertKCRAitems(newList); 

        //Create PRA Related List Records from PRA Template Records
        OpportunityService.insertPRAitems(newList); 

        //Add the BDM and the PDM as opportunity Team Members    
        OpportunityService.BDM_PDM_Opp_Team_Manager(newList, oldMap, isInsert, isUpdate);
        
        //Manage the Revenue records
        OpportunityService.manageRevenueRecords(newList, oldMap, isInsert, isUpdate);
    }

    /**
     * @description Before Update Methods
     * @return void
     **/
    public override void beforeUpdate() {
        System.debug(loggingLevel.Error, '*** BEFORE UPDATE **');
        if(recursionBefore == false){

            //Call method for calling before update methods
            for(Opportunity opp: newList){
                Opportunity oldOpp = oldMap.get(opp.Id);

                //Validation rule to prevent users changing the stage  
                OpportunityService.validationRuleOnStageChange(opp, oldOpp); 

                //determines the gate
                OpportunityService.determineGate(opp, oldOpp);  

                //set the owner - PDM or BDM
                OpportunityService.BDM_PDM_Owner_Manager(opp);

                //Reset the old gate values once the new gate has been initiated          
                OpportunityService.ResetPreviousGateValues(opp, oldOpp);        
            }
            recursionBefore = true;
        }
    }   

    /**
     * @description After Update Methods
     * @return void
     **/
    public override void AfterUpdate(){
        System.debug(loggingLevel.Error, '*** AFTER UPDATE **');
        if(recursionAfter == false){
            //controls the gate process through gate status changes
            OpportunityService.ApprovalProcessOrchestrator(newList, oldMap);
            
            //sends emails based on the approval outcome
            OpportunityService.sendEmails(newList, oldMap);
            
            //Manage the Revenue records
            OpportunityService.manageRevenueRecords(newList, oldMap, isInsert, isUpdate);
            recursionAfter = true;
        }
    } 

}