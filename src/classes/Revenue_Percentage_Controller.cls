public with sharing class Revenue_Percentage_Controller {
	@AuraEnabled
   	public static List<Percentage_Revenue__c> getAllPercentageRevenueRecords(String opportunityId) {

	    List<Percentage_Revenue__c> allRevenue = [SELECT Allocated__c,Id,Inactive__c,Opportunity__c,Period_Date__c,Period__c 
	    											FROM Percentage_Revenue__c 
	    											WHERE Inactive__c = FALSE 
	    											AND Opportunity__c = :opportunityId]; 

       	return allRevenue;
    } 
    
    @AuraEnabled
   	public static Opportunity getOpportunity(String opportunityId) {
	    return [SELECT Id, Name, Anticipated_Revenue_Start_Date__c, Project_Duration_Months__c 
	    											FROM Opportunity 
	    											where id=:opportunityId limit 1]; 
    } 
    
}