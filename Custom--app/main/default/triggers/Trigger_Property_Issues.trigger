/**
 *  Description :   This trigger is responsiable for all the pre and post processing for property issue record
 *
 *  Created By  :   Shirnath 
 *
 *  Created Date:   01/12/2016
 *
 *  Revision Logs:  V1.0 - Created
 *					V1.1 - Modified By Poonam Bharagav - (D-00017166)
 *  Code Coverage - 100%
 **/

trigger Trigger_Property_Issues on Property_Issues__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    
        //Execute the trigger only if required
        if(Constants.EXECUTE_TRIGGER == false || Property_IssuesTriggerHelper.EXECUTE_PROPERTY_TRIGGER == false) { return; }
            
        //Check for the request type
        if(Trigger.isBefore) {

            //Check for the event type
            if(Trigger.isInsert) {
                
                Property_IssuesTriggerHelper.setPropertyIssueWhatRegion( Trigger.new );  
            }
            
             //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Added By Poonam Bhargava - D-00017166
                //Call the helper class method to populate Market field
                Property_IssuesTriggerHelper.populateMarketfromPortfolio(trigger.New, trigger.OldMap);
            }
            
        }   
    
}