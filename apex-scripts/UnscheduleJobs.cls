for(CronTrigger sObj: [SELECT Id FROM CronTrigger]) {
	System.abortJob(sObj.ID);
}