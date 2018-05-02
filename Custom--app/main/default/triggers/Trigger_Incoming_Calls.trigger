/**
 *   Description     : Trigger on Incoming_Calls__c object
 *
 *   Created By      :
 *
 *   Created Date    :  07/03/2013
 *
 *   Revision Logs   :  v_1.0 - Created
 *                      v_1.1 - Modfied By Abhinav Sharma
 *                      V_1.2 - Bhavi Sharma - 07/15/2013 - D-00006244
 *                      V_1.3 - Rajesh Shah - 12/16/2013 - D-00010319
 *                      V_1.4 - Shrinath Sharma - 02-25-2014 - D-00011741
 *                      V_1.5 - Poonam Bhargava - (12/10/2016) - D-00016574
 *                      V_1.6 - Poonam Bhargava - (12/16/2016) - D-00016575
 *                      V_1.7 - Prasad (3/8/2017) D-00016943
 *                      V_1.8 - Poonam Bhargava (D-00017048)
 *                      V_1.9 - Poonam Bhargava (D-00017394)
 **/
trigger Trigger_Incoming_Calls on Incoming_Calls__c (before insert, before update, after insert, after update, after delete) {
    
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;
    
    // When before trigger
    if(trigger.isBefore) {

        // when update trigger event
        if(trigger.isUpdate) {
            IncomingCallHelper.updateTimeToAssignmentMinutes( trigger.new, trigger.oldMap );            
        }
        
        
        //Check for event Type
        if(Trigger.isInsert || Trigger.isUpdate){
        
            //Added by Poonam Bhargava(12/10/2016) - D-00016574
            //Call the helper class method
            IncomingCallHelper.populateSameStoreFromPortfolio(trigger.new, trigger.oldMap);   
            
            //Check for request
            if(trigger.isInsert) {
                
                //Added by Poonam Bhargava(03/30/2017)- D-00017048
                IncomingCallHelper.removePhoneformatingOnIHLead(trigger.new, trigger.oldMap); 
            
                //Added by Poonam Bhargav (07/31/2017) - D-00017394
                //Call the helper class method
                IncomingCallHelper.markCloseDuplicateIHLead(trigger.new);           
            }  
            
            //Prasad - Added Method  PopulateListingData - D-00016943, D-00017172
            IncomingCallHelper.PopulateListingData(Trigger.New, trigger.oldMap);
        }  
    }

    //Check for request type
    if(trigger.isAfter) {

        //Check for event type
        if(trigger.isInsert) {

            // Calling Helper Class on Insert of Listing_Agent
            IncomingCallHelper.incomingSharing(trigger.new, null);

            // Call helper function to count total Incoming Calls for Listing
            IncomingCallHelper.updateListingTotalIncomingCallCount(trigger.new, null); 
             
            //Depricated under SIR D-00017394           
            //D-00017048
            //IncomingCallHelper.sendLeadToAgent(Trigger.New);
        }

        //Check for event type
        if(trigger.isDelete) {
            // Call helper function to count total Incoming Calls for Listing
            IncomingCallHelper.updateListingTotalIncomingCallCount(trigger.old, null);
        }

        //Check for event type
        if(trigger.isUpdate) {

            // Calling Helper Class on Update  of Listing_Agent
            IncomingCallHelper.incomingSharing(trigger.new, trigger.oldMap);

            // Calling helper class to update sharing on change of Listing Agent
            IncomingCallHelper.updateShowingSharing(trigger.newMap, trigger.oldMap);

            // Call helper function to count total Incoming Calls for Listing
            IncomingCallHelper.updateListingTotalIncomingCallCount(trigger.new, trigger.oldMap);
            
            //Added by Poonam Bhargava(12/16/2016) - D-00016575
            //Call the helper class method
            IncomingCallHelper.populateAppTrackFieldFromIHLead(trigger.new, trigger.oldMap);
        }
    }
}