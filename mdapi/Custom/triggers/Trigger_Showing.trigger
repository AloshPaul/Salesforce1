/*********************************************************************************
 * Name             : Trigger_Showing
 * Created By       : Jennifer Dauernheim(Appirio Consulting)
 * Created Date     : Feb 27, 2013
 * Purpose          : To process changes to processs Showing recoreds
 
***********************************************************************************/
trigger Trigger_Showing on Showing__c (before insert, before update, after insert, after update) {
	
	//Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
    	return;
    
    if(Trigger_ShowingHandler.isTrigger_ShowingCalld) 
      	return;
  
  	if(Trigger.isBefore) {
    	if(Trigger.isInsert) {
        	//Trigger_ShowingHandler.isTrigger_ShowingCalld = true;
        	Trigger_ShowingHandler.onBeforeInsert(Trigger.new); 
       	}
    	if(Trigger.isUpdate) {
    		Trigger_ShowingHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap); 
    	}
  	}
   
  	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			Trigger_ShowingHandler.onAfterInsert(trigger.newMap);
		}
    	if(Trigger.isUpdate)
    	{
        	//Trigger_ShowingHandler.isTrigger_ShowingCalld = true;
        	Trigger_ShowingHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
       	}
    }
}