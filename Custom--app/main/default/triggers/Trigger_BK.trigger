/**
 *  Description :   This trigger is responsiable for calling and population of "BKTriggerHelper" helper 
                    class with values.
 *   
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   09/25/2012
 * 
 *  Revision Logs:  V1.0 - Created
 *               
 **/ 
trigger Trigger_BK on BK__c (after insert, after update) {  
     
    //Check for the request type
    if(Trigger.isAfter) {
        
        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate) {
        
            //Call Helper class method
            BKTriggerHelper.newTaskForTransactionCoordinator(Trigger.New);   
        
            //Call Helper Class Method
            BKTriggerHelper.updateDataOnProperty(Trigger.newMap, Trigger.oldMap);
        }
    } 
}