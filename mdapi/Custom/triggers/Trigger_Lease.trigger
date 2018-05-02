trigger Trigger_Lease on Tenant_Card__c (after insert,after update, before insert, before update) {
     
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false
       ||LeaseTriggerHelper.EXECUTE_LEASE_TRIGGER == false){
        return;
    }

     //Added by Poonam Bhargava(09/16/2017)
    //Check for Trigger Event
    if(trigger.isBefore){
    
      //Check for request type
      if(trigger.isInsert || trigger.isUpdate){
      
        //Call the helper class method
        LeaseTriggerHelper.populateResidenceFromProperty(Trigger.new,Trigger.oldMap);  
      }  
    }
       
    if(trigger.isAfter) {
        
        if(trigger.isInsert || trigger.isUpdate){
            
            // call method to update New Resulting Lease  and it's dependent field on Listing
            LeaseTriggerHelper.populateResultingLeaseOnListing( Trigger.new,Trigger.oldMap);
            
            if(trigger.isInsert) {
                // Call the Helper Class Method to stamp the most recent Lease on the Residence
                LeaseTriggerHelper.updateMostRecentLeaseOnResidence(Trigger.new, null);
  
                //call method to update New Renewed Lease on Renewal
                LeaseTriggerHelper.updateNewRenewedLeaseOnRenewal( Trigger.new );
              
                //call method to update New Renewed Lease on Renewal
                //LeaseTriggerHelper.populateResultingLeaseOnListing( Trigger.new );
              
                //Added by saurabh kumar  - 7/28/2015 D-00014444
                //call method to create New Lease Data Integrity Record 
                //LeaseTriggerHelper.createLeaseDataIntegrityRecord(Trigger.new );

                //Added by Poonam Bhargava - (10/13/2016)- D-00016239
                //Call the Helper Class Method 
                LeaseTriggerHelper.createRenewalOnLeaseInsertion(Trigger.new );
                
                // Saurabh Kumar - (25-4-2017) - D-00017164
                LeaseTriggerHelper.checkForLeaseRenewal(Trigger.new, trigger.oldMap);
                
                LeaseTriggerHelper.updateBedDataResultingLeaseOnListing(Trigger.new);
            }

            if (trigger.isUpdate){
                  
                //Added by Abhinav Sharma - D-00014372
                //Call the Helper Class Method to update the Listing's YRR_Move_Out_Date__c field with rehab's Move_Out_Date__c field
                LeaseTriggerHelper.updateMoveOutDateBasedOnRehab(Trigger.new, Trigger.oldMap);
                  
                //Call the Helper Class Method to stamp the most recent Lease on the Residence
                LeaseTriggerHelper.updateMostRecentLeaseOnResidence(Trigger.new, trigger.oldMap);
      
                //call helper class method to update rehab and listings
                LeaseTriggerHelper.doActionsOnLeaseNoticeUpdate( trigger.new, trigger.oldMap );
      
                //call helper class method to update rehab stage
                LeaseTriggerHelper.doActionsOnMoveOutWithin14DaysUpdate( trigger.new, trigger.oldMap );
                  
                //call helper class method to update Renewal date
                LeaseTriggerHelper.updateRenewals(trigger.New, Trigger.oldMap);
                  
                //Added by saurabh kumar Date: 8/19/2015
                // call helper class method to update Lease data intigrity fields
                //LeaseTriggerHelper.populateLDIRecordsBasedOnLease(trigger.New, Trigger.oldMap);
                  
                //Added by Poonam Bhargava(03/18/2016) - D-00015112
                //Call the helper class method
                LeaseTriggerHelper.populateFieldsonAppTrackFromLease(trigger.New, Trigger.oldMap);
                
                // Saurabh Kumar - (25-4-2017) - D-00017164
                LeaseTriggerHelper.checkForLeaseRenewal(Trigger.new, trigger.oldMap);

                //Added by Poonam Bhargava(06/19/2017) - D-00017170
                LeaseTriggerHelper.populateAppTrackOwnerfieldFromAppTrack(Trigger.new,Trigger.oldMap);
                
                //Added by Poonam Bhargava(04/02/2018) - D-00017863
                LeaseTriggerHelper.populateLeaseRentFieldsOnListing(Trigger.new,Trigger.oldMap);
            
            }
        }
    }
}