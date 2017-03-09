/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Lessons_Learnt_ReportTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Lessons_Learnt_ReportTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Lessons_Learnt_Report__c());
    }
}