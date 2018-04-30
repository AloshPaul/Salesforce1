/*
    Trigger helper for Listing Trigger
    Revision Logs   :   V_1.2  - Abhinav Sharma - 7/10/2013 - New Method added(mostRecentListingOnResidence) - D-00005982
                        V_1.3  - Abhinav Sharma - 7/13/2013 - New Method added(shareChildtenantAppRecordsOnChangeOfListingAgent) - D-00006205
                        V_1.4  - Added code to populate move out date(line 54-56) - Prashant Wayal
                        V_1.5  - Abhinav Sharma - 04/20/2015 - Removed existing method (updateMoveOutDate) - D-00013862
                        V_1.6  - Abhinav Sharma - 06/19/2015 - New Method added(updateMoveOutDateBasedOnRehab) - D-00014114
                        V_1.7  - Saurabh kumar  - 8/27/2015  - New Method added(updateResutingLeaseFieldsOnListing) to update Resulting Lease field based on Resulting Lease on listing
                        v_1.8  - Abhinav Sharma - 09/14/2015 - Added a new method (populatePreleasedOnListing) to populate preleased field on listing D-00014490 
                        v_1.9  - Saurabh kumar - 9/15/2015   - Updated Method updateResultingleasefieldsOnlisting -BUG-6510
                        v_1.10 - Poonam Bhargava - (03/18/2016) - new method - populateFieldsonAppTrackFromResultingLease - D-00015112
                        v_1.11 - Saurabh kumar  - 07/20/2016 - new method  updateRehabSupritendentOnListing  D-00015947
                        v_1.12 - Saurabh kumar  - 11/28/2016 - new method  updateActualAppTrackInfoOnRehab, updateMoveOutOfficeSignOffOnListing D-00016509
                        v_1.13 - Poonam Bhargava - (01/04/2017) - new method - updateHOAAmenityInformationOnListing - D-00016725
                        v_1.14 - Saurabh Kumar  -(1/30/2017)- Added Method  updateDaystoReResidentOnApplicationTracking -D-00016788
                        V_1.15 - Poonam Bhargava - 03/07/2017 - Added a new method updateDispositionInfoOnListing - D-00016958
                        V_1.16 - Poonam Bhargava (05-15-2017) - Modified method updateHOAAmenityInformationOnListing D-00017131
                        V_1.17 - Saurabh Kumar - (05/15/2017) -  Modified method updateChildObjectSharing  D-00017148
                        V_1.18 -  Poonam Bhargava - (06/19/2017) - Added a new method 'populateOwnerFromAppTrack' - D-00017170
                        V_1.19 -  Poonam Bhargava - (07/10/2017) - Added a new method 'listingSharingForListingAgent' - D-00017310
            
*/
public class ListingTriggerHelper { 
 
    public static Boolean runListingTrigger = true;
    public static Boolean EXECUTE_LISTING_TRIGGER = true;
 
    public static void updateListingIdOnRehabRecords(List<Listing__c> newList) {
        if(runListingTrigger) {
            List<Rehab__c> listRehabs = new List<Rehab__c>();
            for(Listing__c listing : newList) {
                                if(listing.Rehab__c != null) {
                       listRehabs.add(new Rehab__c(Id = listing.Rehab__c, Listing__c = listing.Id));
                                }
            }
            if(listRehabs.size() > 0) {
                update listRehabs;
            }
        }
    }
 
    // method to update Previous Lease Rent Fields
    public static void populatePreviousLeaseRentFields( List<Listing__c> newList ) {
    
        // set of residence Ids
        Set<Id> setResidenceIds = new Set<Id>();
        // loop over listings
        for( Listing__c listing : newList ) {
            // when Residecne is not equals to null
            if( listing.Residence__c != null ) {
               setResidenceIds.add( listing.Residence__c );
            }
        }
       
        // query residence
        Map<Id, Residence__c> mapResidences = new Map<Id, Residence__c>( [ Select Most_Recent_Lease__c,
                                                                                  Most_Recent_Lease__r.Lease_Rent__c,
                                                                                  Most_Recent_Lease__r.Housing_Rent__c
                                                                          From Residence__c
                                                                          Where Id in: setResidenceIds
                                                                         ]);
        
        // loop over listings
        for( Listing__c listing : newList ) {
            // when Residecne is not equals to null and mapResidences has item for Residence__c
            if( listing.Residence__c != null && mapResidences.containsKey( listing.Residence__c )) {
                Residence__c res = mapResidences.get( listing.Residence__c );
                listing.Previous_Lease__c = res.Most_Recent_Lease__c;
                listing.Previous_Lease_Rent__c = res.Most_Recent_Lease__r.Lease_Rent__c;
                listing.Previous_Housing_Rent__c = res.Most_Recent_Lease__r.Housing_Rent__c;
            }
            
        }
        
       
    }
 
    //This method is to stamp the most recent Listing record on Residence record
    public static void mostRecentListingOnResidence(List<Listing__c> newListing) {
 
        //Map to hold Portfolio Id as Key and Listing Id as Value
        Map<Id,Id> portfolioListingMap = new MAp<Id,Id>();
 
        //Loop through Listing Records
        for(Listing__c listing : newListing) {
 
            //Check for Portfolio associted with Listing
            if(listing.Portfolio__c != null) {
 
                //put values in map
                portfolioListingMap.put(listing.Portfolio__c,listing.Id);
            }
        }
 
        //List of Residence
        List<Residence__c> residences = new List<Residence__c>();
 
        //Loop through Portfolio records that is associted with Listing
        for(Property__c property : [Select Id,Residence__c From Property__c
                                                            Where Id IN :portfolioListingMap.keySet()
                                                            AND Residence__c != null
                                                            and Residence__r.Parent_Structure__c = false]) {
 
            //Check if map has property id
            if(portfolioListingMap.containsKey(property.Id)) {
 
                //Instance of residence that is associated with property
                Residence__c residence = new Residence__c(Id = property.Residence__c);
 
                //Add Listing in Most Recent Listing field
                residence.Most_Recent_Listing__c = portfolioListingMap.get(property.Id);
 
                //Add value in list
                residences.add(residence);
            }
        }
 
        //Check for size
        if(residences.size() > 0)
            update residences;
    }
 
    /*
    -- Commented and Logic moved to 'updateChildObjectSharing' as part of SIR - D-00010320
    //Method for adding sharing rule for each of the Child record applicants (Tenant_App__c) of the current Listing if
    //Listing agent changes
    public static void shareChildtenantAppRecordsOnChangeOfListingAgent(Map<Id, Listing__c> newMapListings, Map<Id, Listing__c> oldMapListings) {
 
        // Get all the Listing Agent and Query only the Active ones.
        Set<Id> listingAgentSet = new Set<Id>();
        for(Listing__c listing : newMapListings.values()) {
            if(listing.Listing_Agent__c != null)
                listingAgentSet.add(listing.Listing_Agent__c);
        }
 
        Map<Id, User> usrMap = new Map<Id, User>([Select Id from User where Id in :listingAgentSet and IsActive = true]);
 
        //List to hold the Tenant App manual sharing records
        List<Tenant_App__Share> tenantAppShareRecordsList = new List<Tenant_App__Share>();
 
        //List to hold the Tenant App manual sharing records  to delete
        List<Tenant_App__Share> tenantAppShareDeleteRecordsList = new List<Tenant_App__Share>();
 
        //Map to hold the Tenant Id - Listing Agent Id as key and Sharing record as value
        Map<String, Tenant_App__Share> mapLAIdWithTAS = new Map<String, Tenant_App__Share>();
 
        //Fetch exting sharing data and put in Map
        for(Tenant_App__Share tAS : [Select ParentId, UserOrGroupId from Tenant_App__Share
                                                                    where Parent.Listing__c IN: newMapListings.keySet()
                                                                    AND RowCause = 'Manual']) {
 
            //Create a unique key
            String key = tAS.ParentId + '-' + tAS.UserOrGroupId;
 
            //Populate map with values
            mapLAIdWithTAS.put(key, tAS);
        }
 
        //Loop through listing records
        for(Tenant_App__c tApp : [Select Id, OwnerId, Listing__c From Tenant_App__c Where Listing__c IN : newMapListings.keySet()]) {
 
            //Get list records
            Listing__c newListing = newMapListings.get(tApp.Listing__c);
            Listing__c oldListing = oldMapListings.get(tApp.Listing__c);
 
            //Check for same tenant owner and old Listing agent
            if(newListing.Listing_Agent__c != null
                    && tApp.OwnerId != newListing.Listing_Agent__c
                    && newListing.Listing_Agent__c != oldListing.Listing_Agent__c) {
 
                //Create a unique key
                String key = tApp.Id + '-' + newListing.Listing_Agent__c;
 
                //Add record in sharing list to delete
                if(!mapLAIdWithTAS.containsKey(key) && usrMap.containsKey(newListing.Listing_Agent__c)) {
 
                    //Populate list with the tanant App sharing record
                    tenantAppShareRecordsList.add(new Tenant_App__Share(ParentId = tApp.Id, UserOrGroupId = newListing.Listing_Agent__c, AccessLevel = 'Edit'));
                }
            }
 
            //Check for tenant owner and Listing agent
            if(oldListing.Listing_Agent__c != null && newListing.Listing_Agent__c != oldListing.Listing_Agent__c && tApp.OwnerId != oldListing.Listing_Agent__c) {
 
                //Create a unique key to insert a new sharing record
                String key = tApp.Id + '-' + oldListing.Listing_Agent__c;
 
                //Check for key
                if(mapLAIdWithTAS.containsKey(key)) {
 
                    //delete unused
                    tenantAppShareDeleteRecordsList.add(mapLAIdWithTAS.get(key));
                }
            }
        }
 
        //Check for list size
        if(tenantAppShareDeleteRecordsList.size() > 0)
            delete tenantAppShareDeleteRecordsList;
 
        //Check for size of list
        if(tenantAppShareRecordsList != null)
            Database.SaveResult[] srList = Database.insert(tenantAppShareRecordsList, false);
    }
    */
 
    // Function to update the Sharing rules of Listing when Listing Agent is upatated
    public static void updateChildObjectSharing(Map<Id,Listing__c> newListingMap, Map<Id, Listing__c> oldListingMap){
        Set<Id> listingIdSet = new Set<Id>();
        Set<Id> listingSecondaryAgentChangedId = new Set<Id>();
        for(Listing__c listing : newListingMap.values()){
            
            if(listing.Listing_Agent__c != oldListingMap.get(listing.Id).Listing_Agent__c) listingIdSet.add(listing.Id);
            
            else if(Utility.hasFieldChanged(listing ,oldListingMap ,'Secondary_Agent__c')) listingSecondaryAgentChangedId.add(listing.Id);
            
        }
        if(!listingIdSet.isEmpty() || !listingSecondaryAgentChangedId.isEmpty()) {
            
            if(!listingIdSet.isEmpty()){
                // Update Sharing for Related Showings
                List<Showing__c> showingList = [Select Listing__c, Agent_Name__c, Call_Record_if_applicable__c, OwnerId
                                                                    from    Showing__c
                                                                    where   Listing__c in :listingIdSet];
                if(showingList != null && !showingList.isEmpty())
                    Trigger_ShowingHandler.updateShowingSharingRules(showingList);
                
                // Update Sharing for Related Incoming Calls
                Map<Id, Incoming_Calls__c> incomingCallMap = new Map<Id, Incoming_Calls__c>([Select Listing__c, Listing_Agent__c , Secondary_Agent_Id__c, OwnerId
                                                                                                from    Incoming_Calls__c
                                                                                                where   Listing__c in :listingIdSet]);
                if(incomingCallMap != null && !incomingCallMap.isEmpty()){
                    incomingCallHelper.updateSharingRuleForIncomingCalls(incomingCallMap);
                }
            }
            // Update Sharing for Related Tenant Applications
            Map<Id, Tenant_App__c> tenantAppMap = new Map<Id, Tenant_App__c > ([Select Listing__c, Co_Broker_IH__c , OwnerId,Listing_Agent_Name_Text__c
                                                                                        from    Tenant_App__c
                                                                                        where   Listing__c in :listingIdSet 
                                                                                        OR      Listing__c in :listingSecondaryAgentChangedId]);
            if(tenantAppMap != null && !tenantAppMap.isEmpty()){
                Tenant_App_TriggerHelper.updateSharingRuleForTenantApp(TenantAppMap);
            }
     
        }
    }
    
    /**
      * @Discription    :    Method for update the field "YRR Move Out Date" based on rehab field.   
      *
      * @arg            :    List<Listing__c> newList
      *
      * @return         :    void
    **/
    public static void updateMoveOutDateBasedOnRehab(List<Listing__c> newList){
    
        //Set to hold rehab record ids
        Set<Id> setToHoldRehabIds = new Set<Id>();
        
        //Loop through Trigger.new
        for(Listing__c li : newList){
        
            //Check for null condition and populate set
            if(li.Rehab__c != null) {
                setToHoldRehabIds.add(li.Rehab__c); 
            }
            else if(li.Rehab__c == null){
                 li.YRR_Move_Out_Date__c  = null;
             }
        }
        
        //Check for setToHoldRehabIds size
        if(setToHoldRehabIds.size() > 0){
        
            //Initialize map of rehab and populate map
            map<Id, Rehab__c> mapRehabs = new map<Id, Rehab__c>([Select Id, Move_Out_Date__c From Rehab__c Where id IN : setToHoldRehabIds]);
            
            //Loop through trigger.new list and populating fields with the map of rehabs
            for(Listing__c li : newList){
            
                //Checking and validting for eligibility and then accordingly populating the field value on listing 
                if(li.Rehab__c != null && mapRehabs != null && mapRehabs.values().size() > 0 
                    && mapRehabs.containsKey(li.Rehab__c) && mapRehabs.get(li.Rehab__c) != null) {
                    
                    //If the rehab is selected then Move Out Date should be populated
                    if(mapRehabs.get(li.Rehab__c).Move_Out_Date__c != null)
                        li.YRR_Move_Out_Date__c = mapRehabs.get(li.Rehab__c).Move_Out_Date__c;  
                    else
                        li.YRR_Move_Out_Date__c = null;
                    
                }   
            }       
        }       
    } 
    
    
    /**
     *  @description  :  Method to populate Resulting lease fields value on listing records
     *                    since we reached the limit of 15 relation object (out of box) so we 
     *                    moved to use trigger  . it also handle Resulting lease  when a listing status change to 
     *                    leased .
     *  @args      :   New list of listing , oldmap
     * 
     *  @return      :  Void
     *  
     *  created by   : Saurabh kumar  (8/27/2015) : updated on 9/15/2015 : 
     * 
  **/
    public static void updateResutingLeaseFieldsOnListing(List<Listing__c> newListing , Map<Id, Listing__c> oldmap){
         Map<Id ,Listing__c> mapListingIdtoListing = new Map<Id,Listing__c>();
         for(Listing__c listing : newListing){
            //checking if listing is updated 
            if(oldmap != null && oldmap.containskey(listing.id)){
                //condition to check Resulting lease is changed on listing object but their fields value on listing is not changed 
                if(oldmap.get(listing.id).Resulting_Lease__c != listing.resulting_lease__c && oldmap.get(listing.id).Resulting_Lease_s_Lease_Rent__c == listing.Resulting_Lease_s_Lease_Rent__c && oldmap.get(listing.id).Resulting_Lease_Housing_Rent__c == listing.Resulting_Lease_Housing_Rent__c ){
                        
                     if(listing.Resulting_lease__c == null){
                            listing.Resulting_Lease_s_Lease_Rent__c = null;
                            listing.Resulting_Lease_Housing_Rent__c = null;
                     }  
                    mapListingIdtoListing.put(listing.Resulting_Lease__c , listing);
                 }
                    
                    
                 //Resulting lease only populated on listing if and only if listing status is Leased    
                 if(Utility.hasFieldChanged(Listing, oldmap, 'Status__c') ){
                    //if listing status changed to Leased
                    if(listing.Status__c!=null && listing.Status__c.equalsIgnoreCase('leased') && listing.LeaseAfterListing__c != null){
                        listing.Resulting_Lease__c =  listing.LeaseAfterListing__c;
                        mapListingIdtoListing.put(listing.Resulting_Lease__c , listing);
                        
                       }
                    
                    //if listing status changed to other than leased
                    if(listing.status__c!=null && !listing.Status__c.equalsIgnoreCase('leased')){
                        //
                        if(listing.LeaseAfterListing__c == null && !(listing.Previous_Lease__c == listing.Resulting_Lease__c)){
                            
                            listing.LeaseAfterListing__c = listing.Resulting_Lease__c;
                            
                        }
                        listing.Resulting_Lease__c = null;
                        listing.Resulting_Lease_s_Lease_Rent__c = null;
                        listing.Resulting_Lease_Housing_Rent__c = null;
                      }
                    
                   }    
                
            }
            //when listing is created
            else if (listing.Resulting_Lease__c != null &&( listing.Resulting_Lease_s_Lease_Rent__c == null || listing.Resulting_Lease_Housing_Rent__c == null)){
                mapListingIdtoListing.put(listing.Resulting_Lease__c , listing);
            }
            
        }
    if(mapListingIdtoListing.size()> 0){    
        for(Tenant_Card__c lease : [select id ,Lease_Rent__c,Housing_Rent__c from Tenant_Card__c where Id In :mapListingIdtoListing.keySet()])  {
            
            mapListingIdtoListing.get(lease.id).Resulting_Lease_s_Lease_Rent__c= lease.Lease_Rent__c;
            mapListingIdtoListing.get(lease.id).Resulting_Lease_Housing_Rent__c= lease.Housing_Rent__c;
          }
    }
        
    }
    
    
    //Added by Abhinav Sharma(09/14/2015) D-00014490
    /**
      * @description    :   Method to populate Preleased field on Listing records
      *
      * @arg            :   List of new Listing, map of old listing 
      *
      * @return         :   Void
    **/
    public static void populatePreleasedOnListing(List<Listing__c> newList) {
        //Set to hold the Rehab Ids
        Set<Id> setRehabIds = new Set<Id>();
        
        //Loop over Listing Records
        for(Listing__c li : newList)
            setRehabIds.add(li.Rehab__c);           
        
        //Check for set size
        if(setRehabIds.size() > 0){
        
            //Map to hold Rehab record with Id and populate map
            map<Id, Rehab__c> mapOfRehabWithIds = new map<Id, Rehab__c>([Select Id, Office_Signoff_Date__c FROM Rehab__c 
                                                                            WHERE Id IN : setRehabIds 
                                                                            AND Office_Signoff_Date__c != null]); 
            
            //Loop over Trigger.new list (listing records)
            for(Listing__c li : newList) {
            
                //Checking if map contains the key
                if(mapOfRehabWithIds != null 
                   && mapOfRehabWithIds.values().size() > 0  
                   && li.Rehab__c != null
                   && mapOfRehabWithIds.containsKey(li.Rehab__c) 
                   && mapOfRehabWithIds.get(li.Rehab__c) != null) {
                
                    //Marking listing as "Pre-Leased", if status = Leased and Office SignOff Date >= App Received Date    
                    if(li.Status__c == 'Leased' 
                        && li.App_Received_Date__c != null
                        && mapOfRehabWithIds.get(li.Rehab__c).Office_Signoff_Date__c >= li.App_Received_Date__c)  
                        li.Preleased__c = true;
                    else
                        li.Preleased__c = false;
                } else {
                    li.Preleased__c = false;                   
                }   
            }   
        }
     }  
     
    //Added by Poonam Bhargava(03/18/2016) - D-00015112 
    /**
      * @description    :   Method to populate Lease End Date nad Lease Start Date on App Track records
      *
      * @arg            :   List of new Listing , map of old Listing 
      *
      * @return         :   Void
    **/
    public static void populateFieldsonAppTrackFromResultingLease(List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing) {

        //List of App Track
        List<Tenant_App__c> tenantApps = new List<Tenant_App__c>();

        //Initialize set of Listing Ids
        Set<Id> setListingIds = new Set<Id>();
        
        //Check for null on old map
        if(mapOfOldListing != null){
        
            //Loop over Listing records
            for(Listing__c li : newListing){
        
                //Check for update case and populate set
                if(mapOfOldListing.get(li.Id).Resulting_Lease__c != li.Resulting_Lease__c)
                    setListingIds.add(li.Id);
            }
        }   
    
        //Check for set size
        if(setListingIds.size() > 0) {
        
            //Loop over app track records
            for(Tenant_App__c app : [Select Id,Lease_End_Date__c,Lease_Start_Date__c,Listing__c,Listing__r.Actual_AppTrack__c,Listing__r.Resulting_Lease__r.Lease_End_Date__c,
                                        Listing__r.Resulting_Lease__r.Lease_From_Date__c from Tenant_App__c 
                                        where Listing__c != null and Listing__c IN : setListingIds]){
            
                //Check for fields values 
                if(app.Listing__r.Resulting_Lease__c != null){
                            
                    if(app.Lease_End_Date__c != app.Listing__r.Resulting_Lease__r.Lease_End_Date__c
                        || app.Lease_Start_Date__c != app.Listing__r.Resulting_Lease__r.Lease_From_Date__c){
                    
                        //Populate fields values on app track
                        app.Lease_End_Date__c = app.Listing__r.Resulting_Lease__r.Lease_End_Date__c;
                        app.Lease_Start_Date__c = app.Listing__r.Resulting_Lease__r.Lease_From_Date__c; 
                    }
                }
                
                //Add into list
                tenantApps.add(app);
            }
        }
        
        //Check for list size and perform update operation
        if(tenantApps.size() > 0) {
            
            //Bypass the App Track Trigger
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = false;
            
            //Perform update operation on App Track
            update tenantApps;
            
            //App Track trigger on
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = true;
        }
    }
    
 
    /**
      * @Discription    :    Method for update the field "Rehab Supritendent " based on rehab field.   
      *
      * @arg            :    List<Listing__c> newList , Map<Id ,Listing__c> oldMap
      *
      * @return         :    void
    **/
     public static void updateRehabSupritendentOnListing(List<Listing__c> newList, Map<Id,Listing__c> oldmap){
    
        //Set to hold rehab record ids
        Set<Id> setToHoldRehabIds = new Set<Id>();
        
        //Loop through Trigger.new
        for(Listing__c li : newList){
        
            //Check for null condition and populate set
            if(li.Rehab__c != null 
               &&(oldmap == null || !oldmap.containsKey(li.id)|| (li.Rehab__c != oldmap.get(li.id).Rehab__c))
               ) {
                setToHoldRehabIds.add(li.Rehab__c); 
            }
            else if(li.Rehab__c == null){
                 li.Rehab_Superintendent__c  = null;
             }
        }
        
        //Check for setToHoldRehabIds size
        if(setToHoldRehabIds.size() > 0){
        
            //Initialize map of rehab and populate map
            map<Id, Rehab__c> mapRehabs = new map<Id, Rehab__c>([Select Id, Back_end_Supervisor__c From Rehab__c Where id IN : setToHoldRehabIds]);
            
            //Loop through trigger.new list and populating fields with the map of rehabs
            for(Listing__c li : newList){
            
                //Checking and validting for eligibility and then accordingly populating the field value on listing 
                if(li.Rehab__c != null && mapRehabs != null && mapRehabs.values().size() > 0 
                    && mapRehabs.containsKey(li.Rehab__c) && mapRehabs.get(li.Rehab__c) != null) {
                    
                    //If the rehab is selected then Rehab Supritendent  should be populated
                    if(mapRehabs.get(li.Rehab__c).Back_end_Supervisor__c != null)
                        li.Rehab_Superintendent__c = mapRehabs.get(li.Rehab__c).Back_end_Supervisor__c;  
                    else
                        li.Rehab_Superintendent__c = null;
                    
                }   
            }       
        }       
    } 
  
  //Added by Saurabh kumar(11/28/2016) :-D-00016509  
  /**
      * @Discription    :    Method for update the Application Tracking and Listing Status on Related Rehab.   
      *
      * @arg            :    List<Listing__c> newList , Map<Id ,Listing__c> oldMap
      *
      * @return         :    void
    **/  
    public static void updateActualAppTrackInfoOnRehab(List<Listing__c> newList , Map<Id ,Listing__c> oldMap){
        //set of Listing Id
        Set<Id> setListingId = new Set<Id>();
        //flag to update Apptrack on Rehab
        Boolean flagToRehabUpdate = false;
        //checking condition if any change happen in Listing Status Or Listing: Actual App Traker
        for(Listing__c listing : newList){
            
            if(     ((oldMap==null || !oldMap.containsKey(listing.id)) && listing.Rehab__c != null ) 
                     || ( oldMap!=null && oldMap.containsKey(listing.id) 
                          &&( Utility.hasFieldChanged(listing,oldMap, 'Status__c')
                              || Utility.hasFieldChanged(listing,oldMap, 'Actual_AppTrack__c')
                              || Utility.hasFieldChanged(listing,oldMap, 'Resulting_Lease__c') )
                         ) 
              ){
                
                setListingId.add(listing.id);
                if(Utility.hasFieldChanged(listing,oldMap, 'Resulting_Lease__c'))
                    flagToRehabUpdate = true;
              }
        }
          
        if(!setListingId.isEmpty()){
            updateRehabActualAppTrackInfo(setListingId,flagToRehabUpdate);    
        }                           
    }
   
    
    //Added by Saurabh kumar(11/28/2016) :-D-00016509  
  /**
      * @Discription    :    Method for Update Days from Move Out to Office Sign Off on Listing  
      *
      * @arg            :    List<Listing__c> newList , Map<Id ,Listing__c> oldMap
      *
      * @return         :    void
    **/          
    
    public static Void updateMoveOutOfficeSignOffOnListing(List<Listing__c> newList){
        
        //set of ListingId having Reahb associated
        Map<Id,Listing__c> mapListingIdToListing = new Map<Id,Listing__c>();
        for(Listing__c listing : newList){
            if(listing.Rehab__c == null){
                listing.Days_from_Move_Out_to_Office_Sign_Off__c = null;
            }else{
                mapListingIdToListing.put(listing.id,listing);
            }
        }
        
        //iterating over listing having rehab associated 
        if(mapListingIdToListing.isEmpty())
        return;
        
        for(Listing__c listing :[Select id ,Rehab__c,Rehab__r.Days_Move_Out_to_Office_Sign_Off__c,Rehab__r.Renewal__c ,Rehab__r.Renewal__r.Lease__c From Listing__c where Id IN:mapListingIdToListing.keySet()]){
            
            //checking for Renewal and lease presence on Rehab associated with current listing 
            if(listing.Rehab__c != null && listing.Rehab__r.Renewal__c != null
              && listing.Rehab__r.Renewal__r.Lease__c != null){
                
                mapListingIdToListing.get(listing.id).Days_from_Move_Out_to_Office_Sign_Off__c =  mapListingIdToListing.get(listing.id).Days_from_Move_Out_to_Office_Sign_Off__c != listing.Rehab__r.Days_Move_Out_to_Office_Sign_Off__c ? listing.Rehab__r.Days_Move_Out_to_Office_Sign_Off__c : mapListingIdToListing.get(listing.id).Days_from_Move_Out_to_Office_Sign_Off__c ;
              
              }else{
                
                mapListingIdToListing.get(listing.id).Days_from_Move_Out_to_Office_Sign_Off__c = null;
              }
        }
    
        
    }
    
     //Added by Saurabh kumar(11/28/2016) :-D-00016509  
   /**
      * @Discription    :    Method for update the Rehab based on Application Tracking and Listing update (reusable Method)  
      *
      * @arg            :    Set<Id>  set of listing Id
      *
      * @return         :    void
    **/  
    
    public static void updateRehabActualAppTrackInfo(Set<Id> setListingId ,Boolean externalCall){
        
        //list of Rehab to be updated 
        List<Rehab__c> listRehabToUpdate = new List<Rehab__c>();
        
        for(Rehab__c rhb : [Select Id ,App_Tracker__c,Back_End_Supervisor_if_Different__c,Lease_Start_Date_App_Tracker__c,Move_In_Specialist__c,
                                         Move_In_Time__c,Pre_Lease_Walk_Notes__c,Scheduled_Move_In_Date__c,Section_8_Applicant__c,
                                         Listing_Status__c,
                                         Listing__c,
                                         Listing__r.Status__c,Listing__r.Actual_AppTrack__c ,
                                         Listing__r.Actual_AppTrack__r.Back_End_Supervisor_if_different__c,
                                         Listing__r.Actual_AppTrack__r.Lease_Start_Date__c,
                                         Listing__r.Actual_AppTrack__r.Move_In_Specialist__c,
                                         Listing__r.Actual_AppTrack__r.Move_In_Time_Move_In_Process__c,
                                         Listing__r.Actual_AppTrack__r.Pre_Lease_Walk_Notes__c,
                                         Listing__r.Actual_AppTrack__r.Scheduled_Move_In__c,
                                         Listing__r.Actual_AppTrack__r.Section_8__c
                                         From Rehab__c where Listing__c IN :setListingId]){
                                    
                Rehab__c Rehab = new Rehab__c(Id = rhb.id) ;
                Rehab.Listing_Status__c = (rhb.Listing_Status__c != rhb.Listing__r.Status__c)  ?rhb.Listing__r.Status__c :rhb.Listing_Status__c;
                
                //checking if Actual App Tracking changed on Listing 
                if(rhb.App_Tracker__c != rhb.Listing__r.Actual_AppTrack__c || externalCall){
                    
                    Rehab.App_Tracker__c = rhb.Listing__r.Actual_AppTrack__c ;
                    Rehab.Back_End_Supervisor_if_Different__c =   rhb.Listing__r.Actual_AppTrack__r.Back_End_Supervisor_if_different__c;                
                    Rehab.Lease_Start_Date_App_Tracker__c = rhb.Listing__r.Actual_AppTrack__r.Lease_Start_Date__c;
                    Rehab.Move_In_Specialist__c =    rhb.Listing__r.Actual_AppTrack__r.Move_In_Specialist__c ;
                    Rehab.Move_In_Time__c = rhb.Listing__r.Actual_AppTrack__r.Move_In_Time_Move_In_Process__c;
                    Rehab.Pre_Lease_Walk_Notes__c = rhb.Listing__r.Actual_AppTrack__r.Pre_Lease_Walk_Notes__c;
                    Rehab.Scheduled_Move_In_Date__c = rhb.Listing__r.Actual_AppTrack__r.Scheduled_Move_In__c;
                    Rehab.Section_8_Applicant__c = rhb.Listing__r.Actual_AppTrack__r.Section_8__c;
                                    
                }
               //adding to list
               listRehabToUpdate.add(Rehab);
         }
        
        //updating List of Rehab
        if(!listRehabToUpdate.isEmpty()){
            
            Boolean TriggerReahb = Trigger_RehabHandler.isTrigger_RehabCalld;
            Trigger_RehabHandler.isTrigger_RehabCalld = true;
            update listRehabToUpdate;
            Trigger_RehabHandler.isTrigger_RehabCalld = TriggerReahb;
        
        }                                    
    }
    
    //Modified By Poonam Bhargava (05-15-2017) -  D-00017131
    //Added by Poonam Bhargava (01/04/2016) - D-00016725
    /**
      * @Discription    :    Method for update the fields HOA Amenity information based on Account field.   
      *
      * @arg            :    List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing
      *
      * @return         :    void
    **/
    public static void updateHOAAmenityInformationOnListing(List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing){
   
        //Set to hold Residence Id
        Set<Id> setOfResidence = new Set<Id>();
        
        //Loop over Listing record     
        for(Listing__c li : newListing){
        
            //Check for Insert/Update case
            if(li.Residence__c != null){
                
                //Populate set with Residence Id                                  
                setOfResidence.add(li.Residence__c);  
            }
            else{
            
                //Populate fields with blank values
                li.Amenities__c  = null;
                li.Amenities_Detail__c  = null;
                li.Amenities_Included__c   = null;
                li.Tenant_App_Required__c  = null;
                li.Tenant_Application_Notes__c  = null;
                li.HOA_Application_Fee__c  = null;
                li.Other_Restrictions__c  = null;
            }
               
        }
        
        //Check for set size
        if(setOfResidence.size() > 0){
        
            //Populate map to hold Residence Id with Residence record
            Map<Id, Residence__c> mapResidence = new Map<Id, Residence__c>([Select Id,HOA_Primary__c, HOA_Primary__r.Amenities__c, 
                                                                            HOA_Primary__r.Amenity_Details__c, HOA_Primary__r.Amenities_Included__c,
                                                                            HOA_Primary__r.Tenant_Aplication_Required__c,
                                                                            HOA_Primary__r.Tenant_Application_Notes__c,
                                                                            HOA_Primary__r.HOA_Application_Fee__c, 
                                                                            HOA_Primary__r.Other_Restrictions__c
                                                                            from Residence__c where HOA_Primary__c != null and Id IN : setOfResidence]); 
            
            //Loop over Listing record 
            for(Listing__c li : newListing){
            
                //Check for eligible criteria
                if(li.Residence__c != null && mapResidence.containsKey(li.Residence__c) && mapResidence.get(li.Residence__c).HOA_Primary__c != null){
                
                    //Ckeck field 'Amenities' on both Account and Listing object and populate accordingly
                    if(li.Amenities__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Amenities__c)  
                        li.Amenities__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Amenities__c ;
                    
                    //Ckeck field 'Amenities Detail' on both Account and Listing object and populate accordingly
                    if(li.Amenities_Detail__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Amenity_Details__c)
                        li.Amenities_Detail__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Amenity_Details__c;
                    
                    //Ckeck field 'Amenities Included' on both Account and Listing object and populate accordingly
                    if(li.Amenities_Included__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Amenities_Included__c)
                        li.Amenities_Included__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Amenities_Included__c;  
                    
                    //Ckeck field 'Amenities Included' on both Account and Listing object and populate accordingly
                    if(li.Tenant_App_Required__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Tenant_Aplication_Required__c)
                        li.Tenant_App_Required__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Tenant_Aplication_Required__c;
                        
                    //Ckeck field 'Amenities Included' on both Account and Listing object and populate accordingly
                    if(li.Tenant_Application_Notes__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Tenant_Application_Notes__c)
                        li.Tenant_Application_Notes__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Tenant_Application_Notes__c;
                        
                    //Ckeck field 'Amenities Included' on both Account and Listing object and populate accordingly
                    if(li.HOA_Application_Fee__c != mapResidence.get(li.Residence__c).HOA_Primary__r.HOA_Application_Fee__c)
                        li.HOA_Application_Fee__c = mapResidence.get(li.Residence__c).HOA_Primary__r.HOA_Application_Fee__c;
                        
                    //Ckeck field 'Amenities Included' on both Account and Listing object and populate accordingly
                    if(li.Other_Restrictions__c != mapResidence.get(li.Residence__c).HOA_Primary__r.Other_Restrictions__c)
                        li.Other_Restrictions__c = mapResidence.get(li.Residence__c).HOA_Primary__r.Other_Restrictions__c;      
                } 
                else{
                
                    //Populate fields with blank values
                    li.Amenities__c  = null;
                    li.Amenities_Detail__c  = null;
                    li.Amenities_Included__c   = null;
                    li.Tenant_App_Required__c  = null;
                    li.Tenant_Application_Notes__c  = null;
                    li.HOA_Application_Fee__c  = null;
                    li.Other_Restrictions__c  = null;
                }    
            }   
        }   
    }
    
    //Added by Saurabh kumar(01/23/2017) :  
    /**
      * @Discription    :    Method to update the Days to Re-Resident on Application Tracking
      *
      * @arg            :    List<Listing__c> newList , Map<Id ,Listing__c> oldMap
      *
      * @return         :    void
    **/ 
    public static void updateDaystoReResidentOnApplicationTracking(List<Listing__c> newList, Map<Id, Listing__c> oldMap){
        //Map of Listing
         Map<Id, Map<String,Object>> mapListingToListingData = new  Map<Id, Map<String,Object>>();
        
        //If any changes happen add that record to the map.
        for(Listing__c lst : newList){
            if(Utility.hasFieldChanged(lst, oldMap, 'Days_from_Move_Out_to_Office_Sign_Off__c') 
               || lst.DOM_Rehab_Complete_to_Lease_Start__c != null || Utility.hasFieldChanged(lst, oldMap, 'Rehab__c')){
                
                Map<String ,Object> mapListingData = new Map<String,Object>();
                mapListingData.put('Days_to_Re_Resident__c',lst.Days_to_Re_Resident__c);   
                mapListingData.put('Rehab__c',Utility.hasFieldChanged(lst, oldMap, 'Rehab__c') ? null : lst.Rehab__c);
                mapListingToListingData.put(lst.Id, mapListingData);
            }
        }
        
        if(!mapListingToListingData.isEmpty()){
           Tenant_App_TriggerHelper.updateDaysToReResidentGeneralContractorOnApplicationTrackingExternal(mapListingToListingData);
        } 
    }

    //Added by Poonam Bhargava (03/01/2017) - D-00016958
    /**
      * @Discription    :    Method for update the fields "Disposition No", "Disposition Listing Status" and "Disposition Strategy" from Most Recent Disposition on Portfolio.   
      *
      * @arg            :    List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing
      *
      * @return         :    void
    **/
    public static void updateDispositionInfoOnListing(List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing){

        //Set to hold Residence Id
        Set<Id> setOfResidenceIds = new Set<Id>();
        
        //Loop over Listing record     
        for(Listing__c li : newListing){
        
            //Check for null condition
            if(li.Residence__c != null){
                
                //Populate set with Residence Id                                  
                setOfResidenceIds.add(li.Residence__c);  
            }else{
                
                //Populate Listing fields with null value
                li.Disposition_No__c = null;
                li.Disposition_Listing_Status__c = null;
                li.Disposition_Strategy__c = null;
            }     
        }
        
        //Check for set size
        if(setOfResidenceIds.size() > 0){
        
            //Populate map to hold Residence Id with Residence record
            Map<Id, Residence__c> mapResidence = new Map<Id, Residence__c>([Select Id, Most_Recent_Disposition__c, 
                                                                            Most_Recent_Disposition__r.Listing_Status__c, 
                                                                            Most_Recent_Disposition__r.Disposition_Strategy__c
                                                                            from Residence__c where Id IN : setOfResidenceIds]); 
            
            //Loop over Listing record 
            for(Listing__c li : newListing){
            
                //Check for eligible criteria
                if(li.Residence__c != null && mapResidence.containsKey(li.Residence__c)){
                
                    //Ckeck Disposition fields on both Listing and Residence object and populate accordingly
                    if(li.Disposition_No__c != mapResidence.get(li.Residence__c).Most_Recent_Disposition__c
                            || li.Disposition_Listing_Status__c != mapResidence.get(li.Residence__c).Most_Recent_Disposition__r.Listing_Status__c
                            || li.Disposition_Strategy__c != mapResidence.get(li.Residence__c).Most_Recent_Disposition__r.Disposition_Strategy__c){
                    
                        //Populate Listing Fileds
                        li.Disposition_No__c = mapResidence.get(li.Residence__c).Most_Recent_Disposition__c;
                        li.Disposition_Listing_Status__c = mapResidence.get(li.Residence__c).Most_Recent_Disposition__r.Listing_Status__c;
                        li.Disposition_Strategy__c = mapResidence.get(li.Residence__c).Most_Recent_Disposition__r.Disposition_Strategy__c;          
                    }      
                }         
            }   
        }     
    }

    //Added by Poonam Bhargava(06/19/2017) - D-00017170
    /**
    * @description    :     Method to populate "AppTrack Owner" field on Resulting Lease from Application Tracking record
    *
    * @arg            :     List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing
    *
    * @return         :     Void
    **/
    public static void populateOwnerFromAppTrack(List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing){
    
        //Set to hold Listing Ids
        Set<Id> setOfListing = new Set<Id>();
        
        //List of Lease to be updated
        List<Tenant_Card__c> leaseToBeUpdated =  new List<Tenant_Card__c>();
    
        //Loop over listing
        for(Listing__c li : newListing){
        
            //Check for insert/update case and populate set with Listing Ids
            if(li.Resulting_Lease__c != null && (mapOfOldListing == null || li.Resulting_Lease__c != mapOfOldListing.get(li.Id).Resulting_Lease__c 
                                                    || li.Actual_AppTrack__c != mapOfOldListing.get(li.Id).Actual_AppTrack__c)){
            
                setOfListing.add(li.Id);                                            
            }           
        }
        
        //Check for set size
        if(setOfListing.size() > 0){
            
            //Get the key Prefix of Queue 
            String keyPrefix = Schema.getGlobalDescribe().get('Group').getDescribe().getKeyPrefix();
        
            //Set to hold already existing Lease id 
            Set<Id> alreadyAddedLease = new Set<Id>();
            
            //Loop over listing records
            for(Listing__c  li : [Select Id, Actual_AppTrack__c, Actual_AppTrack__r.OwnerId, Resulting_Lease__c, Resulting_Lease__r.AppTrack_Owner__c 
                                    from Listing__c where Id IN : setOfListing Order By LastModifiedDate DESC]){
                
                //Check for eligible criteria on listing and populate lease list accordingly
                if(li.Actual_AppTrack__c != null && li.Actual_AppTrack__r.OwnerId != null){
                    
                    //String variable to hold App track owner id as string  
                    String appOwner = String.valueOf(li.Actual_AppTrack__r.OwnerId);  
                
                    //Check for App Track owner update condition and add into list 
                    if((!appOwner.contains(keyPrefix)) && (!alreadyAddedLease.contains(li.Resulting_Lease__c))
                        && li.Resulting_Lease__c != null && li.Actual_AppTrack__r.OwnerId != li.Resulting_Lease__r.AppTrack_Owner__c){
                        
                        //Add into list to be updated
                        leaseToBeUpdated.add(new Tenant_Card__c(Id = li.Resulting_Lease__c, AppTrack_Owner__c = li.Actual_AppTrack__r.OwnerId));
                        
                        //Populate set with lease Id    
                        alreadyAddedLease.add(li.Resulting_Lease__c);    
                    }
                }else if(!alreadyAddedLease.contains(li.Resulting_Lease__c)) {
                    leaseToBeUpdated.add(new Tenant_Card__c(Id = li.Resulting_Lease__c, AppTrack_Owner__c = null)); 
                    
                    //Populate set with lease Id    
                    alreadyAddedLease.add(li.Resulting_Lease__c);
                }   
            }   
        }
        
        //Check for list size and perform update operation
        if(leaseToBeUpdated.size() > 0){
            
            LeaseTriggerHelper.EXECUTE_LEASE_TRIGGER = false;
            update leaseToBeUpdated;
            LeaseTriggerHelper.EXECUTE_LEASE_TRIGGER = true;
                
        }
    }
    
    //Added by Poonam Bhargava(07/10/2017) - D-00017310 
    /**
    * @description    :     Method to provide the sharing access of Listing record to "Listing Agent"
    *
    * @arg            :     List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing
    *
    * @return         :     Void
    **/
    public static void listingSharingForListingAgent(List<Listing__c> newListing, map<Id, Listing__c> mapOfOldListing){
       
        //List of property share object to be inserted 
        List<Property__Share> propertySharesTobeInserted = new List<Property__Share>();
        
        //Set to hold the Portfolio Ids
        Set<Id> setOfPortfolioIds = new Set<Id>();
        
        //Set to hold the Listing Agent Ids
        Set<Id> setListingAgentIds = new Set<Id>();

        //Set to hold the unique combination of Portfolio and Listing agent
        Set<String> setPortfolioAndListingAgentUK = new Set<String>();
        
        //Loop over listing records
        for(Listing__c listing : newListing){
        
            //Check for null condition and insert/update case and 
            if(listing.Portfolio__c != null && ((mapOfOldListing ==  null && listing.Listing_Agent__c != null) 
                                                    || (mapOfOldListing != null && listing.Listing_Agent__c != mapOfOldListing.get(listing.Id).Listing_Agent__c))){
                
                //populate set with Portfolio Ids accordingly   
                setOfPortfolioIds.add(listing.Portfolio__c);    
                    
                //Check for old Listing Agent
                if(mapOfOldListing != null && mapOfOldListing.get(listing.Id).Listing_Agent__c != null) {
   
                    //Populate set with old Listing Agent Ids
                    setListingAgentIds.add(mapOfOldListing.get(listing.Id).Listing_Agent__c);

                    //Add the unique key in the set
                    setPortfolioAndListingAgentUK.add(listing.Portfolio__c + '-' + mapOfOldListing.get(listing.Id).Listing_Agent__c);
                }   
            }   
        }
        
        //Check for set size
        if(setOfPortfolioIds.size() > 0){
            
            //List of to hold the Property Share record to be deleted
            List<Property__Share> propertySharesToBeDeleted = new List<Property__Share>();

            //Querying the old sharing rules under Portfolio
            for(Property__Share pS : [Select ParentId, UserOrGroupId from Property__Share where ParentId IN: setOfPortfolioIds AND RowCause = 'Manual' AND UserOrGroupId IN : setListingAgentIds]) {
  
                //Check unique key in set
                if(setPortfolioAndListingAgentUK.contains(pS.ParentId + '-' + pS.UserOrGroupId))
                    propertySharesToBeDeleted.add(pS); 
            }
            
            //Check for list size to be deleted and perform the delete operation
            if(propertySharesToBeDeleted.size() > 0)
                delete propertySharesToBeDeleted;
            
            //Retrieve the Listing records for the sharing   
            for(Listing__c listing : [Select Id, Listing_Agent__c, Portfolio__c from Listing__c where Portfolio__c IN : setOfPortfolioIds and Listing_Agent__r.IsActive = true]){
                
                //Check the Listing Agent for null
                if(listing.Listing_Agent__c != null){
                
                    //Creating a new Sharing rule for thr Listing Agent
                    propertySharesTobeInserted.add(new Property__Share(ParentId = listing.Portfolio__c, UserOrGroupId = listing.Listing_Agent__c, AccessLevel = 'Edit' ));  
                }   
            }   
        }   
            
        //Inserting the List values to database
        if(propertySharesTobeInserted.size() >0){
            Database.SaveResult[] srList = Database.insert(propertySharesTobeInserted, false);
        }
    }
}