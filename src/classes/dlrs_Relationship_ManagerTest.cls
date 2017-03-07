/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Relationship_ManagerTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Relationship_ManagerTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Relationship_Manager__c());
    }
}