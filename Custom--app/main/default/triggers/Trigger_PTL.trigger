/*********************************************************************************
 * Name             : Trigger_Showing
 * Created By       : Jennifer Dauernheim(Appirio Consulting)
 * Created Date     : Feb 27, 2013
 * Purpose          : To process changes to processs Showing recoreds
 
***********************************************************************************/
trigger Trigger_PTL on PTL__c (before insert) {

    if(Trigger_PTLHandler.isTrigger_PTLCalld) 
      return;
  
  if(Trigger.isbefore)
  {
    if(Trigger.isInsert)
    {
        Trigger_PTLHandler.isTrigger_PTLCalld = true;
        Trigger_PTLHandler.onBeforeInsert(Trigger.new); 
    }
    
    
  }
  

}