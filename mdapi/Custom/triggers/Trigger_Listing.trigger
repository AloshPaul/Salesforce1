/*
    Trigger on Listing Object
    Revision Logs   :   V_1.2 - Abhinav Sharma - 7/10/2013 - Helper class Call added(mostRecentListingOnResidence) - D-00005982
                        V_1.3 - Abhinav Sharma - 7/13/2013v- Helper Class Call added(shareChildtenantAppRecordsOnChangeOfListingAgent) - D-00006205
                        V_1.4 - Rajesh Shah - 12/16/2013 - Helper class and trigger updated - D-00010320
                        V_1.5 - Abhinav Sharma - 04/20/2015 - Removed existing method (updateMoveOutDate) - D-00013862
                        V_1.6 - Abhinav Sharma - 06/19/2015 - Helper class Call added(updateMoveOutDateBasedOnRehab) - D-00014114
                        V_1.7 - Saurabh Kumar  - 08/27/2015 - before insert and update call method  updateResutingLeaseFieldsOnListing
                        V_1.8 - Abhinav Sharma - 09/14/2015 - Call the helper class method populatePreleasedOnListing - D-00014490
                        v_1.9 - Poonam Bhargava - (03/18/2016) - call helper class method 'populateFieldsonAppTrackFromResultingLease'' - D-00015112
                        v_1.10 -Saurabh kumar  - 07/20/2016 - call helper class method  updateRehabSupritendentOnListing  D-00015947
                        v_1.11 - Saurabh kumar  - 11/28/2016 -call helper class method updateActualAppTrackInfoOnRehab, updateMoveOutOfficeSignOffOnListing D-00016509 
                        v_1.12 - Poonam Bhargava - 01/04/2017 - call helper class method 'updateHOAAmenityInformationOnListing'
                        v_1.13 - Saurabh Kumar - (1/30/2017) -D-00016788 (updateDaystoReResidentOnApplicationTracking)
                        V_1.14 - Poonam Bhargava - 03/07/2017 - call helper class method updateDispositionInfoOnListing - D-00016958
                        v_1.15 - Saurabh kumar -  (05/29/2017) - call helper method in Tenant_App_TriggerHelper
                        v_1.16 - Poonam Bhargava (06/19/2017) - Call the helper class method 'populateOwnerFromAppTrack' - D-00017170
                        V_1.17 -  Poonam Bhargava - (07/10/2017) - call the helper class method 'listingSharingForListingAgent' - D-00017310
*/
trigger Trigger_Listing on Listing__c (before insert, after insert, after update, before update) {

    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false
         || ListingTriggerHelper.EXECUTE_LISTING_TRIGGER == false ){
        return;
     }
    
    if(trigger.isBefore) {
        
        if(trigger.isInsert || trigger.isUpdate){
            
            //call method to update Resulting Lease fields value on Listing record as per resulting lease record
            ListingTriggerHelper.updateResutingLeaseFieldsOnListing(trigger.new , trigger.oldmap);
            
            //Added by Abhinav sharma - 09/14/2015 - D-00014490
            //Call the helper class method 
            ListingTriggerHelper.populatePreleasedOnListing(trigger.new);
            
            //Added by Saurabh kumar  - 07/20/2016 - D-00015947
            ListingTriggerHelper.updateRehabSupritendentOnListing(trigger.new, trigger.oldmap);
            
            //Added by Saurab kumar - 11/28/2016 -D-00016509 
             ListingTriggerHelper.updateMoveOutOfficeSignOffOnListing(trigger.new);
             
            //Added by Poonam Bhargava (01/04/2016) - D-00016725
            //Call the helper class method 
            ListingTriggerHelper.updateHOAAmenityInformationOnListing(trigger.new , trigger.oldmap);

            //Added by Poonam Bhargava (03/07/2017) - D-00016958
            //Call the helper class method 
            ListingTriggerHelper.updateDispositionInfoOnListing(trigger.new , trigger.oldmap); 
            
            
            if(trigger.isInsert) {
            
                // call method to update Previous Lease Rent Fields
                ListingTriggerHelper.populatePreviousLeaseRentFields( trigger.new );
            }
            
            //Added by Abhinav sharma
            //Check for trigger event
            if(trigger.isUpdate) {
  
                //Call the helper class method to update the move out date field
                ListingTriggerHelper.updateMoveOutDateBasedOnRehab(Trigger.new);    
            }
        }
    }
        
    if(trigger.isAfter) {
        
        if(trigger.isInsert || trigger.isUpdate){
          
        
          if(trigger.isInsert) {
          
              //update lsiting id on rehab record
              ListingTriggerHelper.updateListingIdOnRehabRecords(trigger.new);
  
              //Call helper class method to stamp the most recent listing on residence
              ListingTriggerHelper.mostRecentListingOnResidence(Trigger.New);
          }
  
          //Check for trigger event
          if(trigger.isUpdate) {
              
              // Update Showing Share records.
              ListingTriggerHelper.updateChildObjectSharing(trigger.newMap, trigger.oldMap);
              
              //Added by Poonam Bhargava (03/18/2016) - D-00015112
              //Call helper class method
              ListingTriggerHelper.populateFieldsonAppTrackFromResultingLease(Trigger.New, trigger.oldMap);
              
              //call helper class method to update the Days to Re-Resident on Application Tracking (1/30/2017) -D-00016788 
              ListingTriggerHelper.updateDaystoReResidentOnApplicationTracking(trigger.new, trigger.oldMap);
          }
          
          //Added by Saurab kumar - 11/28/2016 -D-00016509 
          ListingTriggerHelper.updateActualAppTrackInfoOnRehab(trigger.new, trigger.oldMap);
          //Calling App Track Helper method to update AppTrack:Listing Agent
          //Added by Saurabh Kumar  -(05/29/2017)
            Tenant_App_TriggerHelper.updateListingAgentOnAppTrack(trigger.new, trigger.oldMap);

          //Added by Poonam Bhargava(06/19/2017) - D-00017170
          ListingTriggerHelper.populateOwnerFromAppTrack(trigger.new, trigger.oldMap);
          
          //Added by Poonam Bhargava - D-00017310
          //Call the helper class method
          ListingTriggerHelper.listingSharingForListingAgent(trigger.new, trigger.oldMap);
        }
    }
}