/**
 *  Description :   This trigger is responsiable for all the pre and post processing for TIP record.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   06/03/2013
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - Modified by Abhinav Sharma(08/31/2015) - call the method validateTipRecordBasedOnTipType - D-00014488 
 *                  v1.2 - Modified by Saurabh Kumar (10/26/2015)-   call the method  validateTipType - bug-6566
 **/
trigger Trigger_TIP on TIP_Tracking__c (before insert, before update, after insert, after update) {
    
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;
    
    //Check for the request type
    if(Trigger.isBefore) {

        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Calling Helper class Method for validation the date fields for future date value
            TIPTriggerHelper.validateAllDateField(Trigger.New);
            //Calling Helper class Method to validate Tip type 
            TIPTriggerHelper.validateTipType(Trigger.New ,Trigger.oldMap);
        }
    }   
    
    else if(trigger.isAfter) {
        if(trigger.isInsert) {
            // Associate the Tip with the Residence as the Most Recent Tip
            TIPTriggerHelper.updateMostRecentTipOnResidence(trigger.new);
        }
        
        //Commented By - Abhinav Sharma - As per conversation with naveen - 09/15/2015
        //Check for the event type
        /*if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Call helper class method
            TIPTriggerHelper.validateTipRecordBasedOnTipType(Trigger.New, Trigger.oldMap);
        }*/
    }
}