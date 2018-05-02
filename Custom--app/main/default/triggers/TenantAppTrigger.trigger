/**
    * Apex Trigger: TenantAppTrigger
    * Description:
    * Created By: Sudhir Kr. Jagetiya
    * Created Date: 20 March 2013
    * Revision Logs :   V_1.2 - Abhinav Sharma - 7/12/2013 - Helper class Call added(shareTenantAppWithListingAgent) - D-00005982
    * Revision Logs : V_1.3 - Rajesh Shah - 7/25/2013 - Updated logic for Total App Calculation
    * Revision Logs : V_1.4 - Rajesh Shah - 12/16/2013 - Updated logic for Tenant App Sharing 
    * Revision Logs : V_1.5 - Abhinav Sharma - (09/14/2015) - D-00014490
    *                 V_1.6 - Poonam Bhargava - (03/18/2016) - D-00015112
    *                 V_1.7 - Saurabh Kumar - (07/29/2016) - D-00015947- update aggregate query for Total App 
    *                 V_1.8 - Poonam Bhargava - (09/22/2016)
    *                 V_1.9 - Saurabh Kumar  - (11/28/2016) --D-00016509  
    *                 V_1.10- Poonam Bhargava(12/10/2016) - D-00016574  
    *                 V_1.11 -Saurabh Kumar -  (12/26/2016) -D-00016689
    *                 V_1.12 -Poonam Bhargava(12/27/2016) - D-00016575
    *                 V_1.13 -Saurabh Kumar - (1/30/2017) -D-00016788 (updateDaysToReResidentGeneralContractorOnApplicationTracking)
    *                 V_1.14 - Poonam Bhargava -(05/04/2017)
    *                 V_1.15 - Poonam Bhargava(06/19/2017) - D-00017170
    */
trigger TenantAppTrigger on Tenant_App__c (after delete, after insert, after undelete, after update, before insert, before update) {
    
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false
        ||Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER == false) {
        return;
    }
    
    //Added by Poonam Bhargava (03/18/2016) - D-00015112 
    //Check for request type   
    if(Trigger.isBefore){
    
        //Check for event Type
        if(Trigger.isInsert || Trigger.isUpdate){
            
            //Call the helper class method
            Tenant_App_TriggerHelper.populateLeaseEndDateandLeaseStartDateonAppTrack(trigger.new, trigger.oldMap); 
      
            //Added by Poonam Bhargava(09/22/2016)
            //Call the helper class method
            Tenant_App_TriggerHelper.populateHOAFromPortfolio(trigger.new, trigger.oldMap); 
             
            //Added by Poonam Bhargava(12/10/2016) - D-00016574
            //Call the helper class method
            Tenant_App_TriggerHelper.populateSameStoreFromPortfolio(trigger.new, trigger.oldMap);  
   
            //Added by Saurabh Kumar(12/26/2016)
            Tenant_App_TriggerHelper.populateLAUserbasedOnPerformance(trigger.new, trigger.oldMap); 
            
            //Added by Poonam Bhargava(12/14/2016) - D-00016575
            //Call the helper class method
            Tenant_App_TriggerHelper.populatefieldFromIHLead(trigger.new, trigger.oldMap); 
            
            //Prasad: D-00017575.
            Tenant_App_TriggerHelper.populateCompanyFromIHLead(trigger.new, trigger.oldMap);
            
            //Added by Saurabh Kumar(01/30/2017) D-00016788
            Tenant_App_TriggerHelper.updateDaysToReResidentGeneralContractorOnApplicationTracking(trigger.new, trigger.oldMap);
            
            //Added by Poonam Bhargava -(05/04/2017)
            //Call the helper class method
            Tenant_App_TriggerHelper.populateLeasingAgentCoBrokerIHVendorId(trigger.new, trigger.oldMap);
            
            
            if(Trigger.isInsert){
              //Added by Saurabh Kumar  -(05/29/2017)
                //Call the helper class method
              Tenant_App_TriggerHelper.updateListingAgentOnAppTrack(trigger.new, trigger.oldMap);
            }
            
 
        }
    }
    
    
    //Check for request type
    if(Trigger.isAfter) {

        //Check for event Type 
        if(Trigger.isInsert || Trigger.isUpdate) {
            try {
                    // Update Listing
                    Tenant_App_TriggerHelper.updateListings(trigger.new, trigger.oldMap);
            }
            catch(DMLException e ) {
                
                trigger.new.get(0).addError(e.getDmlMessage(0));
            }
            
            // Calling helper function for Insert
            if(trigger.isInsert)
                Tenant_App_TriggerHelper.TenantAppSharing(trigger.new, null);
            
            // Calling helper function for Update
            if(trigger.isUpdate) {
              
                Tenant_App_TriggerHelper.TenantAppSharing(trigger.new, trigger.oldMap);        
                //Calling helper function for updates on Rehab 
                Tenant_App_TriggerHelper.updateActualAppTrackInfoOnRehab(trigger.new, trigger.oldMap);

                //Added by Poonam Bhargava(06/19/2017) - D-00017170
                Tenant_App_TriggerHelper.populateAppTrackOwnerOnLease(trigger.new, trigger.oldMap);

                try {
                        //Added By- Abhinav Sharma - (09/14/2015) - D-00014490
                        //Calling helper class method (Only in update event)
                        Tenant_App_TriggerHelper.populatePreleasedOnListing(trigger.new, trigger.oldMap);
                }
                catch(DMLException e ) {
                    
                    trigger.new.get(0).addError(e.getDmlMessage(0));
                }
            }                
        }
    }

    Set<Id> listingIdSet = new Set<Id>();

    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for(Tenant_App__c tenantApp : trigger.new){
            if(Trigger.isUpdate && tenantApp.Listing__c == Trigger.oldMap.get(tenantApp.Id).Listing__c)
                continue;
            if (tenantApp.Listing__c != null)
                listingIdSet.add(tenantApp.Listing__c);
        }
    }

    if(Trigger.isUpdate || Trigger.isDelete){
        for(Tenant_App__c tenantApp : trigger.old){
            if(Trigger.isUpdate && tenantApp.Listing__c == Trigger.newMap.get(tenantApp.Id).Listing__c)
                continue;
            if (tenantApp.Listing__c != null)
                listingIdSet.add(tenantApp.Listing__c);
        }
    }

    // Updated by Rajesh to only consider Listing_Primary_Applicant record type for Tenant App
    // Get all Overdue tasks for the users
    List<Listing__c> listingsToUpdate = new List<Listing__c>();
    Set<Id> listingIdsProcessed = new Set<Id>();
    // Get the count for each Listing Id using aggregate query
    for(AggregateResult groupedResult : [Select Count(Id) cnt, Listing__c from Tenant_App__c
                                                where   Listing__c in :listingIdSet
                                                and    ( RecordType.Name = :Tenant_App_TriggerHelper.LISTING_PRIMARY_APPLICANT_RT
                                                     or RecordType.Name = :Tenant_App_TriggerHelper.AppTrack_2_0)  
                                                group by Listing__c]) {
        if(groupedResult.get('cnt') != null) {
            // Add Listing record for update
            listingsToUpdate.add(
                new Listing__c(
                    Id = String.valueOf(groupedResult.get('Listing__c')),
                    Total_Apps__c = Integer.valueOf(groupedResult.get('cnt'))
                )
            );
            listingIdsProcessed.add(String.valueOf(groupedResult.get('Listing__c')));
        }
    }
    // For the listing ids not processed, add Total Apps as 0
    for(Id listingId : listingIdSet) {
        if(!listingIdsProcessed.contains(listingId)) {
            listingsToUpdate.add(
                new Listing__c(
                    Id = listingId,
                    Total_Apps__c = 0
                )
            );
        }
    }
    try {
        // Update Listings D-00015497 - Changes
        update listingsToUpdate;
    }
    catch(DMLException e ) {
        
        trigger.new.get(0).addError(e.getDmlMessage(0));
    }
}