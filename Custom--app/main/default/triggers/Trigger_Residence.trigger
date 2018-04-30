/**
 *  Description :   This trigger on Response object
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   03/05/2013
 *
 *  Revision Logs:  V1.0 - Created
 *                  V_1.1 - Bhavi Sharma - 07/20/2013 - Added new method(validateAddressChanges) - D-00006528
 *                  V_1.2 - Abhinav Sharma - 04/03/2015 - Added new method (populateMoveOutDateOnListings) - D-00013862
 *                  V_1.3 - Abhinav Sharma - 10/16/2015 - Added new method (populateMakeReadyDateOnListings) - D-00014655
 *                  V_1.4 - Poonam Bhargava - 03/07/2017 - call helper class method updateDispositionInfoOnListingAndRehab - D-00016958
 *                  V_1.5 - Poonam Bhargava - 05/15/2017 - call helper class method populateHOAAmenityInformationOnListing - D-00017131
 *
 **/
trigger Trigger_Residence on Residence__c (before insert, before update, after update) {
    
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;
        
    if(Trigger.isBefore) {
        
        if(trigger.isUpdate) {

            //Validate Address changes
            ResidenceTriggerHelper.validateAddressChanges(Trigger.New, Trigger.oldMap);

            //validate residence update
            ResidenceTriggerHelper.validateUpdates(trigger.New, trigger.oldMap);
        }
        
        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //generate unique APN
            ResidenceTriggerHelper.generateUniqueAPN(trigger.New, trigger.oldMap);
        
            //Added By Poonam Bhargava - D-00017166
            //Call the utility class method to populate Market field
            Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
        }  
    }

    if(Trigger.isAfter) {
        
        if(Trigger.isUpdate) {
            
            //Added By - Abhinav Sharma - 10/16/2015 - D-00014655
            ResidenceTriggerHelper.populateMakeReadyDateOnListings(Trigger.new, Trigger.oldMap);
            
            //Added by Poonam Bhargava (03/07/2017) - D-00016958
            //Call the helper class method 
            ResidenceTriggerHelper.updateDispositionInfoOnListingAndRehab(Trigger.new, Trigger.oldMap);
            
            //Added by Poonam Bhargava (05/15/2017) - D-00017131
            //Call the helper class method
            ResidenceTriggerHelper.populateHOAAmenityInformationOnListing(Trigger.new, Trigger.oldMap); 
        }
    }
}