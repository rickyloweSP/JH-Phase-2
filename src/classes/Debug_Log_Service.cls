public class Debug_Log_Service
{
	private Debug_Log__c log;

	public Debug_Log_Service(String logName){
		log = new Debug_Log__c();
		log.results__c = '';
		log.name = logName;
		updateLog('start');
		log.Status__c = 'Pending';
	}


	public void finishLogging(){
		
		updateLog('finish');

		if(doesLogIncludeErrors() == false){
			log.Status__c = 'Success';
		}

		if (!test.IsRunningTest()){
			insert log;
		}
	}

	public void updateLog(string message){

		log.results__c 		+= Datetime.now() + ' : ' + message + '\n';
		System.debug(loggingLevel.Error, '*** updateLog: ' + log.results__c);

	}

	public void logError(exception e){
		updateLog('EXCEPTION:' + e.getTypeName());
		updateLog(e.getMessage());
		updateLog(e.getStackTraceString());
		log.Status__c 	= 'Failure';
	}

	public boolean doesLogIncludeErrors(){
		if(log.Status__c == 'Failure'){
			return true;
		}
		else{
			return false;
		}
	}

	public static void deleteLogsOlderThanXDays(integer X){
		Debug_Log_Service Debug = new Debug_Log_Service('Deleting Logs');
		try{
			list<Debug_Log__c> DebugToDelete = [SELECT ID FROM Debug_Log__c WHERE createdDate <= :date.today().addDays(-X)];
			Debug.updateLog('Attempting to update ' + DebugToDelete.size() + ' Log records');
			delete DebugToDelete;
			Debug.updateLog('Successfully Deleted ' + DebugToDelete.size() + ' Log records');
		}
		catch(exception e){
			Debug.logError(e);
		}
		finally{
			Debug.finishLogging();
		}
	}
}