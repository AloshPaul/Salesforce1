/**
 *   Description   : Helper class for TenantAppTrigger
 *
 *   Created By    : Abhinav Sharma
 *
 *   Created Date  : 07/11/2013
 *
 *   Revision Logs : V_1.0 - Created
 *   Revision Logs : V_2 - Added function updateListings
 *   Revision Logs : V_3 - Added new method - (populatePreleasedOnListing) - Abhinav Sharma - (09/14/2015) - D-00014490
 *                   V_4 - Poonam Bhargava - (03/18/2016) - new method - populateLeaseEndDateandLeaseStartDateonAppTrack - D-00015112
 *                   v_5 - saurabh kumar  - (7/29/2016) - added a new variable AppTrack_2_0
 *                   v_6 - Poonam Bhargava - (08/25/2016) - Added changes for App Track 2.0
 *                   V_7 - Poonam Bharagav -(09/01/2016) - D-00016139 - Modified the sharing of App Track record from Read to Edit for the Listing Agent
 *                   V_8 - Poonam Bhargava(09/22/2016) - Added a new method populateHOAFromPortfolio - D-00016178 
 *                   V_9 - Poonam Bhargava(11/05/2016) - Modified method populateHOAFromPortfolio - D-00016428
 *                   V_10 - Saurabh kumar(11/28/2016) --D-00016509   Added method updateActualAppTrackInfoOnRehab
 *                   V_11 -Poonam Bhargava(12/10/2016) - Added a new method 'populateSameStoreFromPortfolio' - D-00016574
 *                   V_12 - Saurabh Kumar(12/26/2016) - D-00016689 - Added new Method populateLAUserbasedOnPerformance
 *                   V_13 - Poonam Bhargava(12/14/2016) - Added a new method 'populatefieldFromIHLead' - D-00016575
 *                   V_14 -Saurabh Kumar - (1/30/2017) -D-00016788 (updateDaysToReResidentGeneralContractorOnApplicationTracking and updateDaysToReResidentGeneralContractorOnApplicationTrackingExternal
 *                   V_15 - Saurabh Kumar - (2/23/2017) - D-00016689 (Updated Method populateLAUserbasedOnPerformance )
 *                   V_16 - Poonam Bhargava -(05/04/2017) - Added a new method 'populateLeasingAgentCoBrokerIHVendorId'
 *                   V_17 - Saurabh Kumar - (05/30/2017)  - D-00017148 Added a new method  updateListingAgentOnAppTrack
 *                   V_18 -  Poonam Bhargava -(06/19/2017) - Added a new method 'populateAppTrackOwnerOnLease' - D-00017170
 **/
public without sharing class Tenant_App_TriggerHelper {
    
    //This flag is to control the execution of Appliation Tracking Trigger
    public static Boolean EXECUTE_APPTRACK_TRIGGER = true;

    public static final string LISTING_PRIMARY_APPLICANT_RT = 'Listing - Primary Applicant';
    public static final string AppTrack_2_0 = 'AppTrack 2.0';

    // Get Recordtype Map
    public static Map<Id, Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Tenant_App__c.getRecordTypeInfosById();

    // Function to check if Tenant App is of type Listing - Primary Applicant
    public static Boolean isListingPrimaryApplication(Id recTypeId) {
        if(rtMapById != null && rtMapById.containsKey(recTypeId)) {
            return (rtMapById.get(recTypeId).getName() == LISTING_PRIMARY_APPLICANT_RT) ? true : false;
        }
        return false;
    }
    
    //Added by Poonam Bhargava - as per App Track 2.0 changes (08/25/2016)
    // Function to check if Tenant App is of type AppTrack 2.0
    public static Boolean isAppTrack2(Id recTypeId) {
        if(rtMapById != null && rtMapById.containsKey(recTypeId)) {
            return (rtMapById.get(recTypeId).getName() == AppTrack_2_0 ) ? true : false;
        }
        return false;
    }

    /*
    Commented and replaced with the function 'updateSharingRule' as per SIR -
    //Method for Share the current Tenant_App__c record (Applicant tracking)  with  the Listing Agent on the parent
    //Listing record:.Tenant_App__r.Listing__r.Listing_Agent__c
    public static void shareTenantAppWithListingAgent(Map<Id,Tenant_App__c> newTenantAppMap, Map<Id,Tenant_App__c> oldTenantAppMap) {

        //List to hold the Tenant App manual sharing records
        List<Tenant_App__Share> tenantAppShareRecordsList = new List<Tenant_App__Share>();

        //List to hold the Tenant App manual sharing records  to delete
        List<Tenant_App__Share> tenantAppShareDeleteRecordsList = new List<Tenant_App__Share>();

        //Map to hold the Tenant Id - Listing Agent Id as key and Sharing record as value
        Map<String, Tenant_App__Share> mapLAIdWithTAS = new Map<String, Tenant_App__Share>();

        //Fetch exting sharing data and put in Map
        for(Tenant_App__Share tAS : [Select ParentId, UserOrGroupId from Tenant_App__Share where ParentId IN: newTenantAppMap.keySet()
                                        AND RowCause = 'Manual']) {

            //Create a unique key
            String key = tAS.ParentId + '-' + tAS.UserOrGroupId;

            //Put this in Map
            mapLAIdWithTAS.put(key, tAS);
        }

        //Create a set od Listing Ids
        Set<Id> listingIds = new Set<Id>();

        //Loop through the Trigger.New and Trigger.Old and populate set
        for(Tenant_App__c tApp : newTenantAppMap.values()) {

            //Check if list agent is not null
            if(tApp.Listing__c != null)
                listingIds.add(tApp.Listing__c);
        }

        //Check if Trigger is running on update
        if(oldTenantAppMap != null) {

            //Loop through the Trigger.New and Trigger.Old and populate set
            for(Tenant_App__c tApp : oldTenantAppMap.values()) {

                //Check if list agent is not null
                if(tApp.Listing__c != null)
                    listingIds.add(tApp.Listing__c);
            }
        }

        //Checkif listing records are to process
        if(listingIds.size() > 0) {

            //Define a Map to hold the listing data
            Map<Id, Listing__c> mapListing = new Map<Id, Listing__c>([Select Id, Listing_Agent__c from Listing__c
                                                                                                    where   Id IN: listingIds
                                                                                                    AND     Listing_Agent__c != null
                                                                                                    AND     Listing_Agent__r.isActive = true ]);

            //Loop throgh the records to check if sharing need to be updated
            for(Tenant_App__c tApp : newTenantAppMap.values()) {

                //Check for Same Owner and Listing Agent value
                if(tApp.Listing__c != null && mapListing.containsKey(tApp.Listing__c) &&
                    mapListing.get(tApp.Listing__c).Listing_Agent__c != tApp.OwnerId &&
                    (oldTenantAppMap == null || oldTenantAppMap.get(tApp.Id).OwnerId != tApp.OwnerId
                        || tApp.Listing__c != oldTenantAppMap.get(tApp.Id).Listing__c)) {

                    //Create the unique Key to insert the record
                    String key = tApp.Id + '-' +  mapListing.get(tApp.Listing__c).Listing_Agent__c;

                    //Add new record in sharing table
                    if(!mapLAIdWithTAS.containsKey(key)) {
                        tenantAppShareRecordsList.add(new Tenant_App__Share(ParentId = tApp.Id, UserOrGroupId =  mapListing.get(tApp.Listing__c).Listing_Agent__c, AccessLevel = 'Edit'));
                    }

                }

                if(oldTenantAppMap != null
                    && oldTenantAppMap.get(tApp.Id).Listing__c != null
                    && oldTenantAppMap.get(tApp.Id).Listing__c != tApp.Listing__c
                    && mapListing.containsKey(oldTenantAppMap.get(tApp.Id).Listing__c)
                    && oldTenantAppMap.get(tApp.Id).OwnerId == tApp.ownerId) {

                    //Create Key
                    String key = tApp.Id + '-' +  mapListing.get(oldTenantAppMap.get(tApp.Id).Listing__c).Listing_Agent__c;

                    //Check if map doesn't have a sharing record already
                    //Add new record in sharing table
                    if(mapLAIdWithTAS.containsKey(key))
                        tenantAppShareDeleteRecordsList.add(mapLAIdWithTAS.get(key));
                }
            }
        }

        //Check for list size
        if(tenantAppShareDeleteRecordsList.size() > 0)
            delete tenantAppShareDeleteRecordsList;

        //Check for size of list
        if(!tenantAppShareRecordsList.isEmpty()){
            Database.SaveResult[] srList = Database.insert(tenantAppShareRecordsList, false);
        }

    }
    */

    // Function to update Listing based on the changes to Tenant App of type Listing - Primary Applicant.
    public static void updateListings(List<Tenant_App__c> tenantApps, Map<Id, Tenant_App__c> oldTenantAppMap) {

        List<Tenant_App__c> tenantAppList = new List<Tenant_App__c>();
        Set<Id> listingIds = new Set<Id>();

        // Get all the listing ids where the Application Status has changed or its a new Tenant app and of the type Listing - Primary Applicant
        for(Tenant_App__c tenantApp : tenantApps) {
            if(tenantApp.Listing__c != null && tenantApp.Application_Status__c != null && (isListingPrimaryApplication(tenantApp.RecordTypeId) || isAppTrack2(tenantApp.RecordTypeId) )) {
                if(oldTenantAppMap == null || tenantApp.Application_Status__c != oldTenantAppMap.get(tenantApp.Id).Application_Status__c) {
                    tenantAppList.add(tenantApp);
                    listingIds.add(tenantApp.Listing__c);
                }
            }
        }

        // Get all the Listing details
        Map<Id, Listing__c> listingMap = new Map<Id, Listing__c>([Select Status__c, 
                                                                         Down_Pre_Marketing_Status_Date__c, Rehab__r.Rehab_Status__c from Listing__c 
                                                                         where Id in :listingIds and Rehab__c != null]);
        List<Listing__c> listingsToUpdate = new List<Listing__c>();

        // Get the Status Map from the custom setting.
        Map<String, Listing_Status_Map__c> listingStatusMap = Listing_Status_Map__c.getAll();

        for(Tenant_App__c tenantApp : tenantAppList) {
            if(listingMap.containsKey(tenantApp.Listing__c)) {
                Listing__c listing = listingMap.get(tenantApp.Listing__c);
                // If Application Status = Declined or Cancelled, nullify Acutal App Track field.
                if(tenantApp.Application_Status__c == 'Cancelled' || tenantApp.Application_Status__c == 'Declined')
                    listing.Actual_AppTrack__c = null;
                else
                    listing.Actual_AppTrack__c = tenantApp.Id;

                // Update Listing status based on Application Status and Rehab Status
                if(listingStatusMap.containsKey(tenantApp.Application_Status__c)) {
                    
                    if( isListingClosed(listing.Rehab__r.Rehab_Status__c) ) {
                        if(listingStatusMap.get(tenantApp.Application_Status__c).Closed_Rehab_Listing_Status__c != 'No Change'){
                              listing.Status__c = listingStatusMap.get(tenantApp.Application_Status__c).Closed_Rehab_Listing_Status__c ;
                         }
                    }
                    else {
                    
                            listing.Status__c = listingStatusMap.get(tenantApp.Application_Status__c).Open_Rehab_Listing_Status__c;
                            if( listing.Status__c == 'Down (In Rehab)' && listing.Down_Pre_Marketing_Status_Date__c != null ) {
                                listing.Status__c = 'Down - Pre-Marketing';
                            }
                    }

                }
                listingsToUpdate.add(listing);
            }
        }
        update listingsToUpdate;
    }

    private static Boolean isListingClosed(String rehabStatus) {
        return (rehabStatus != null && rehabStatus != '' && rehabStatus == 'Completed') ? true : false;
    }

    // Method to all Tenant App records to the Map and pass to the next method
    public static void TenantAppSharing(List<Tenant_App__c> tenantApp, Map<Id, Tenant_App__c> oldTenantMap){
        Map<Id, Tenant_App__c> tenantMap = new Map<ID, Tenant_App__c>();
        for(Tenant_App__c tenant :tenantApp){
            if (tenant.TIP_Record__c != null) {
                // Ignore all sharing rules for TIP tenant_apps
                // Note that I could have used the record types, but I didn't want to hard-code Record Type names here
                // so I use the Tip__c field
                continue;
            }
            if(oldTenantMap == null && (tenant.Co_Broker_IH__c != null || tenant.Listing__c != null)){
                tenantMap.put(tenant.id,tenant);
            }
            else if(oldTenantMap != null &&
                    (tenant.OwnerId !=  oldTenantMap.get(tenant.id).OwnerId
                    || (tenant.Co_Broker_IH__c != oldTenantMap.get(tenant.id).Co_Broker_IH__c)
                    || (tenant.Listing__c !=  oldTenantMap.get(tenant.id).Listing__c) )) {
                tenantMap.put(tenant.id,tenant);
            }
        }
        updateSharingRuleForTenantApp(tenantMap);
    }

    
    // Update the sharing Rules based on Changing on Listing Agent and C0_Broker
    // Update By Saurabh Kumar 5/30/2017 (Providing access to Secondary Agent as well )
    public static void updateSharingRuleForTenantApp(Map<Id, Tenant_App__c> tenantAppMap) {
        List<Tenant_App__Share> TenanatAppSharesTobeInserted = new List<Tenant_App__Share>();
        set<id> listingIds = new set<id>();
        // Looping throgh the Tenant_App Records and adding the Listing Ids to a set
        for(Tenant_App__c tenant : tenantAppMap.values()){
            if(tenant.Listing__c != null)
                listingIds.add(tenant.Listing__c);
        }
        // Querying the old sharing rules under Tenant_App and deleting them
        List<Tenant_App__Share> tenantApplication = [Select ParentId, UserOrGroupId from Tenant_App__Share where ParentId IN: tenantAppMap.keyset()
                                        AND RowCause = 'Manual'];
        if(tenantApplication.size() > 0)
            delete tenantApplication;

        // Creating a Map for Listing Records under Tenant_App
        Map<Id, Listing__c> listingMap = new Map<Id, Listing__c>([Select Id, Listing_Agent__c, Secondary_Agent__c from Listing__c
                                                                                                    where   Id IN: listingIds 
                                                                                                    AND((   Listing_Agent__c != null
                                                                                                    AND     Listing_Agent__r.isActive = true) 
                                                                                                    OR(     Secondary_Agent__c != null
                                                                                                    AND     Listing_Agent__r.isActive = true)
                                                                                                    )]);
                                                                                                    

        // Looping through Tenant App Records and checking if its Co_Broker is not null
        for(Tenant_App__c tenant : tenantAppMap.values()){
            //Set to hold User who will provide sharing access on App Track
            Set<Id> setUserId = new Set<Id>();
            
            if(tenant.Co_Broker_IH__c != null && tenant.Co_Broker_IH__c != tenant.OwnerId){

                // Creating a new Sharing rule for CO_ Broker
                setUserId.add(tenant.Co_Broker_IH__c);
            }
            if(tenant.Listing_Agent_Name_Text__c != null && tenant.Listing_Agent_Name_Text__c.contains('-') && tenant.Listing_Agent_Name_Text__c.subStringBefore('-') != tenant.OwnerId){

                // Creating a new Sharing rule for CO_ Broker
                setUserId.add(tenant.Listing_Agent_Name_Text__c.subStringBefore('-'));
            }
            // Insert sharing rule for Tenant_App__c.Listing__r.Listing_Agent__c
            if(tenant.Listing__c != null && listingMap.containsKey(tenant.Listing__c)){
              
                if(listingMap.get(tenant.Listing__c).Listing_Agent__c != tenant.OwnerId)
                setUserId.add(listingMap.get(tenant.Listing__c).Listing_Agent__c);
                
                if(listingMap.get(tenant.Listing__c).Secondary_Agent__c != null)
                setUserId.add(listingMap.get(tenant.Listing__c).Secondary_Agent__c );
            }
            
            //Populating  TenanatAppSharesTobeInserted using setUserId
            for(Id userId : setUserId){
                // Creating a new Sharing rule 
                TenanatAppSharesTobeInserted.add(
                    new Tenant_App__Share(
                        ParentId        = tenant.Id,
                        UserOrGroupId   = userId,
                        AccessLevel     = 'Edit' // Modified By Poonam Bharagav -(09/01/2016) - D-00016139
                    )
                );
            }
        }
        
        
        // Inserting the List values to Database
        if(!TenanatAppSharesTobeInserted.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(TenanatAppSharesTobeInserted, false);
        }
    }
    
    //Added by Abhinav Sharma - (09/14/2015) - D-00014490
    /**
      * @description    :   Method to populate Preleased field on associated Listing records
      *
      * @arg            :   List of new Rehab, map of old Rehab 
      *
      * @return         :   Void
    **/
    public static void populatePreleasedOnListing(List<Tenant_App__c> newTenantApps, Map<Id, Tenant_App__c> mapOldTenantApps) {

        //List of listing recods to be updated
        List<Listing__c> listings = new List<listing__c>();
        
        //Set to hold the tenant app Ids
        Set<Id> setTenantApps = new Set<Id>();
                
        //Update use case
        if(mapOldTenantApps != null) {
            
            //Loop through tenant app records and populating the set with Ids accordingly
            for(Tenant_App__c ta : newTenantApps) {
                
                //Checking for "App_Received__c" field change
                if(ta.App_Received__c != mapOldTenantApps.get(ta.Id).App_Received__c)
                    setTenantApps.add(ta.Id);
            }
            
            //Chekcing set for its size
            if(setTenantApps.size() > 0) {
            
                //Loop through listing records
                for(Listing__c lis : [SELECT Id, Preleased__c, App_Received_Date__c, Status__c, Actual_AppTrack__c,
                                      Rehab__r.Office_Signoff_Date__c
                                      FROM Listing__c WHERE Actual_AppTrack__c != null 
                                      AND Actual_AppTrack__c IN : setTenantApps]) {
                    
                    //Marking listing as "Pre-Leased", if status = Leased and Office SignOff Date >= App Received Date    
                    if(lis.Status__c == 'Leased' 
                        && lis.App_Received_Date__c != null
                        && lis.Rehab__r.Office_Signoff_Date__c != null
                        && lis.Rehab__r.Office_Signoff_Date__c >= lis.App_Received_Date__c)  
                        lis.Preleased__c = true;
                    else
                        lis.Preleased__c = false;
    
                    //Adding records into the lsit for update
                    listings.add(lis);                      
                }
            }  
        }
        
        //Checking for size value and update list
        if(listings.size() > 0)
            update listings;
    } 
    
    //Added by Poonam Bhargava(03/18/2016) - D-00015112 
    /**
      * @description    :   Method to populate Lease End Date nad Lease Start Date  on App Track records
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populateLeaseEndDateandLeaseStartDateonAppTrack(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setListingIds = new Set<Id>();
    
        //Loop over AppTrack records
        for(Tenant_App__c tA : newTenantApp){
    
            //Check for null and insert/update case and populate set
            if(tA.Listing__c != null && (mapOfOldTenantApp == null || mapOfOldTenantApp.get(tA.Id).Listing__c != tA.Listing__c
                                            || mapOfOldTenantApp.get(tA.Id).Lease_End_Date__c != tA.Lease_End_Date__c 
                                            || mapOfOldTenantApp.get(tA.Id).Lease_Start_Date__c != tA.Lease_Start_Date__c))
                setListingIds.add(tA.Listing__c);
        }
    
        //Check fro set size
        if(setListingIds.size()> 0){
    
            //Initialize map to hold listing record with listing IDs
            map<Id, Listing__c> mapListing = new map<Id, Listing__c>([Select Id, Resulting_Lease__c, Resulting_Lease__r.Lease_End_Date__c, 
                                                Resulting_Lease__r.Lease_From_Date__c From Listing__c
                                                Where Id IN : setListingIds]);
    
            //Loop over App Track records
            for(Tenant_App__c tA : newTenantApp){
            
                //Check for map size and for eligibility criteria
                if(tA.Listing__c != null && mapListing.containsKey(tA.Listing__c) && mapListing.get(tA.Listing__c).Resulting_Lease__c != null){
                        
                    //Populate fields on App Track 
                    tA.Lease_End_Date__c = mapListing.get(tA.Listing__c).Resulting_Lease__r.Lease_End_Date__c;
                    tA.Lease_Start_Date__c = mapListing.get(tA.Listing__c).Resulting_Lease__r.Lease_From_Date__c;
                } 
            }
        }
    }
    
    //Modified by Poonam Bhargava(11/05/2016) - D-00016428 (Populate the field 'Tenant Application Required' on App Track)
    //Added by Poonam Bhargava(09/22/2016) - D-00016178
    /**
      * @description    :   Method to populate App Track field HOA with Company name from Portfolio
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populateHOAFromPortfolio(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setListingIds = new Set<Id>();
        
        //Loop over App Track records
        for(Tenant_App__c tA : newTenantApp){
        
            //Populate set with listing ids
            setListingIds.add(tA.Listing__c);
        }
         
        //Check for set size
        if(setListingIds.size()> 0){
    
            //Initialize map to hold listing record with listing IDs
            map<Id, Listing__c> mapListing = new map<Id, Listing__c>([Select Id, Portfolio__c, Portfolio__r.HOA_Primary__c, Portfolio__r.Residence__r.HOA_Primary__r.Tenant_Aplication_Required__c
                                                                        From Listing__c Where Id IN : setListingIds]);
    
            //Loop over App Track records
            for(Tenant_App__c tA : newTenantApp){
            
                //Check for map size and for eligibility criteria
                if(tA.Listing__c != null && mapListing.containsKey(tA.Listing__c) && mapListing.get(tA.Listing__c).Portfolio__c != null){
            
                    //Populate fields on App Track 
                    if(tA.HOA__c != mapListing.get(tA.Listing__c).Portfolio__r.HOA_Primary__c)       
                        tA.HOA__c = mapListing.get(tA.Listing__c).Portfolio__r.HOA_Primary__c;
                        
                    if(mapListing.get(tA.Listing__c).Portfolio__r.Residence__c != null 
                       && mapListing.get(tA.Listing__c).Portfolio__r.Residence__r.HOA_Primary__c != null 
                       && tA.Tenant_Application_Required__c != mapListing.get(tA.Listing__c).Portfolio__r.Residence__r.HOA_Primary__r.Tenant_Aplication_Required__c){
                        tA.Tenant_Application_Required__c = mapListing.get(tA.Listing__c).Portfolio__r.Residence__r.HOA_Primary__r.Tenant_Aplication_Required__c; 
                    }
                } 
            }
        }
    }  
    
    //Added by Saurabh kumar(11/28/2016) :-D-00016509  
    /**
      * @Discription    :    Method for update the Application Tracking and Listing Status on Related Rehab.   
      *
      * @arg            :    List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp
      *
      * @return         :    void
    **/  
    public static void updateActualAppTrackInfoOnRehab(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp){
        //set of Listing Id
        Set<Id> setListingId = new Set<Id>();
        //map of app track and listing id 
        Map<Id,Id> mapTenantAppIdWithListingId = new Map<Id,Id>();
        //checking condition if any change happen in Application Tracking which is  Actual App Traker on listing 
        for(Tenant_App__c apptrack : newTenantApp){
            
            if(  (mapOfOldTenantApp!=null && mapOfOldTenantApp.containsKey(apptrack.id) && apptrack.Listing__c != null)
                   &&( Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Back_End_Supervisor_if_different__c')
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Lease_Start_Date__c') 
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Move_In_Specialist__c') 
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Move_In_Time_Move_In_Process__c') 
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Pre_Lease_Walk_Notes__c') 
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Scheduled_Move_In__c') 
                        || Utility.hasFieldChanged(apptrack,mapOfOldTenantApp, 'Section_8__c') 
                      )
                   
              ){
                
                mapTenantAppIdWithListingId.put(apptrack.id ,apptrack.listing__c);
                
              }
        }
        
        //if actual app track found with correct changes then return from this method   
        if(mapTenantAppIdWithListingId.isEmpty())
            return;
        for(Tenant_App__c apptrack :[Select id ,listing__c ,listing__r.Actual_AppTrack__c from Tenant_App__c where Id In :mapTenantAppIdWithListingId.keySet()]){
            
            if(apptrack.id == apptrack.listing__r.Actual_AppTrack__c)
            setListingId.add(apptrack.listing__c);
        }
        
        if(setListingId.isEmpty())
            return;
        //calling reusable method of ListingTriggerHelper for updateRehabActualAppTrackInfo 
        ListingTriggerHelper.updateRehabActualAppTrackInfo(setListingId,true);
                                
    } 
    
    //Added by Poonam Bhargava(12/10/2016) - D-00016574
    /**
      * @description    :   Method to populate App Track field 'Portfolio Same Store' from Portfolio
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populateSameStoreFromPortfolio(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setListingIds = new Set<Id>();
        
        //Loop over App Track records
        for(Tenant_App__c tA : newTenantApp){
          
          if(tA.Listing__c != null && (mapOfOldTenantApp == null || mapOfOldTenantApp.get(tA.Id).Listing__c != tA.Listing__c
                          || tA.Portfolio_Same_Store__c != mapOfOldTenantApp.get(tA.Id).Portfolio_Same_Store__c))
        
            //Populate set with listing ids
            setListingIds.add(tA.Listing__c);
        }
         
        //Check for set size
        if(setListingIds.size()> 0){
    
            //Initialize map to hold listing record with listing IDs
            map<Id, Listing__c> mapListing = new map<Id, Listing__c>([Select Id, Portfolio__c, Portfolio__r.SameStore__c
                                                                        From Listing__c Where Id IN : setListingIds]);
    
            //Loop over App Track records
            for(Tenant_App__c tA : newTenantApp){
            
                //Check for map size and for eligibility criteria
                if(tA.Listing__c != null && mapListing.containsKey(tA.Listing__c) && mapListing.get(tA.Listing__c).Portfolio__c != null){
            
                    //Populate fields on App Track 
                    if(tA.Portfolio_Same_Store__c != mapListing.get(tA.Listing__c).Portfolio__r.SameStore__c)       
                        tA.Portfolio_Same_Store__c = mapListing.get(tA.Listing__c).Portfolio__r.SameStore__c; 
                } 
            }
        }
    }        
    //Added by Saurabh kumar(12/26/2016) :-D-00016689
    /**
      * @Discription    :    Method to Populate LA User based on Their Performance on Application Tracking record in SF
      *
      * @arg            :    List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> oldMap
      *
      * @return         :    void
    **/  
    public static void populateLAUserbasedOnPerformance(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> oldMap){
        
        //iterating Over the new list
       /* for(Tenant_App__c appTrack : newTenantApp){
            //Checking if new Created App Track or updated as per criteria 
            if(oldMap== null || !oldMap.containsKey(appTrack.Id) 
                ||Utility.hasFieldChanged(apptrack,oldMap, 'App_Received__c')
                ||Utility.hasFieldChanged(apptrack,oldMap, 'Screening_Recommendation_Received__c')
                ||Utility.hasFieldChanged(apptrack,oldMap, 'VOI_Completed_CheckBox__c')
                ||Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Prepared_Sent__c')
                ||Utility.hasFieldChanged(apptrack,oldMap, 'Revised_Lease_Prepared_Sent__c')
                ||Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Executed__c')){
                    
                    //when application Tracking Received Date is Entered 
                    appTrack.LA_Entered_App_Received__c = Utility.hasFieldChanged(apptrack,oldMap, 'App_Received__c') ?(appTrack.App_Received__c != null?UserInfo.getUserId() :null):appTrack.LA_Entered_App_Received__c;
                    
                    //when Screening Recommendation Received Entered , Update Current User 
                    appTrack.LA_Entered_Screening_Recommendation_Rec__c = Utility.hasFieldChanged(apptrack,oldMap, 'Screening_Recommendation_Received__c')?(appTrack.Screening_Recommendation_Received__c == true?UserInfo.getUserId() :null):appTrack.LA_Entered_Screening_Recommendation_Rec__c;
                    appTrack.Credit_Check_Complete__c = Utility.hasFieldChanged(apptrack,oldMap, 'Screening_Recommendation_Received__c')?(appTrack.Screening_Recommendation_Received__c == true ? appTrack.Credit_Check_Complete__c != null ? appTrack.Credit_Check_Complete__c : System.now() : null):appTrack.Credit_Check_Complete__c;
                    
                    //When VOI Completed  Entered ,Update Current User
                    appTrack.LA_Entered_VOI_Completed__c = Utility.hasFieldChanged(apptrack,oldMap, 'VOI_Completed_CheckBox__c')?(appTrack.VOI_Completed_CheckBox__c == true?UserInfo.getUserId() :null):appTrack.LA_Entered_VOI_Completed__c;
                    appTrack.VOI_Completed__c = Utility.hasFieldChanged(apptrack,oldMap, 'VOI_Completed_CheckBox__c')?(appTrack.VOI_Completed_CheckBox__c == true ? appTrack.VOI_Completed__c != null ? appTrack.VOI_Completed__c : System.now() : null):appTrack.VOI_Completed__c;
                    
                    //When  Lease_Prepared_Sent__c Entered 
                    appTrack.LA_Sent_Lease_Agreement__c = Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Prepared_Sent__c')?(appTrack.Lease_Prepared_Sent__c == true?UserInfo.getUserId() :null):appTrack.LA_Sent_Lease_Agreement__c;
                    
                    //When Revised_Lease_Prepared_Sent__c Entered or Changed 
                    appTrack.LA_Sent_Revised_Lease__c = Utility.hasFieldChanged(apptrack,oldMap, 'Revised_Lease_Prepared_Sent__c')?(appTrack.Revised_Lease_Prepared_Sent__c == true?UserInfo.getUserId() :null):appTrack.LA_Sent_Revised_Lease__c;
                    
                    //When Signed Lease Recieved Entered ,LA Entered Signed Lease Rec'vd populate with Current User
                    appTrack.LA_Entered_Signed_Lease_Rec_vd__c = Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Executed__c')?(appTrack.Lease_Executed__c == true?UserInfo.getUserId() :null):appTrack.LA_Entered_Signed_Lease_Rec_vd__c;
                    appTrack.Signed_Lease_Rec_vd_Date__c = Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Executed__c')?(appTrack.Lease_Executed__c == true ? appTrack.Signed_Lease_Rec_vd_Date__c != null ? appTrack.Signed_Lease_Rec_vd_Date__c : System.now() : null):appTrack.Signed_Lease_Rec_vd_Date__c;
                    
            }
        }*/
         //fetching all CheckBox Which trigger to Update DateTime and User 
        List<App_Track_CheckBox_And_DateTime_By_Map__mdt> LAUserWithCheckBoxMDTs = [Select CheckBox_Field_Name__c, 
                                                                                     DateTime_Checked__c,LA_Updated__c 
                                                                          From App_Track_CheckBox_And_DateTime_By_Map__mdt ];
        //Map of All Field of Application tracking 
        Map<String ,Schema.SObjectField> appTrackSchemaMap = Schema.SObjectType.Tenant_App__c.fields.getMap();
        Set<String> appTrackSchema = appTrackSchemaMap.keySet();
        System.debug('***'+appTrackSchema+'***');   
        
         
        //iterating Over the new list
        for(Tenant_App__c appTrack : newTenantApp){
            //Checking if new Created App Track or updated as per criteria 
            
            //Iterate over all CheckBox Which Triggered to Update LA user and DateTime
            for(App_Track_CheckBox_And_DateTime_By_Map__mdt appTrackMdt :LAUserWithCheckBoxMDTs ){
                System.Debug('**FieldName'+appTrackMdt);
                If(appTrackMdt.CheckBox_Field_Name__c != null && appTrackSchema.contains(appTrackMdt.CheckBox_Field_Name__c.toLowerCase()) && Utility.hasFieldChanged(apptrack,oldMap, appTrackMdt.CheckBox_Field_Name__c)){
                     Schema.DescribeFieldResult appFieldDes = appTrackSchemaMap.get(appTrackMdt.CheckBox_Field_Name__c).getDescribe();
                     Boolean changeRequired =  appFieldDes.type == Schema.DisplayType.BOOLEAN ?(Boolean)appTrack.get(appTrackMdt.CheckBox_Field_Name__c):appTrack.get(appTrackMdt.CheckBox_Field_Name__c)!=null ?True :False;
                     //updating Fields 
                     System.Debug('**FieldName'+appTrackMdt);
                     System.debug('changeRequired '+changeRequired +' for '+appTrackMdt );
                     If(appTrackMdt.LA_Updated__c != null && appTrackSchema.contains(appTrackMdt.LA_Updated__c.toLowerCase()))
                     appTrack.put(appTrackMdt.LA_Updated__c ,changeRequired?UserInfo.getUserId():null );
                     
                     If(appTrackMdt.DateTime_Checked__c != null && appTrackSchema.contains(appTrackMdt.DateTime_Checked__c.toLowerCase()))
                     appTrack.put(appTrackMdt.DateTime_Checked__c ,changeRequired?System.now() : null );     
                     
                }       
            }  
          //Updating Application Status As per CheckBox  Hold Fee Rec'd , Security Deposit Rec'd
           If((Utility.hasFieldChanged(apptrack,oldMap, 'Hold_Fee_Rec_d__c') || Utility.hasFieldChanged(apptrack,oldMap, 'Hold_Agreement_Rec_d__c') ) && appTrack.Hold_Fee_Rec_d__c)  
           appTrack.Application_Status__c = appTrack.Hold_Agreement_Rec_d__c?'Approved/Hold Fee Rec/Pre-leased':'Approved/Hold Fee Rec\'d';
           else If((Utility.hasFieldChanged(apptrack,oldMap, 'Security_Deposit_Rec_d__c') || Utility.hasFieldChanged(apptrack,oldMap, 'Lease_Executed__c')) && appTrack.Security_Deposit_Rec_d__c) 
           appTrack.Application_Status__c = appTrack.Lease_Executed__c?'Approved - Deposit Received/Leased':'Approved/Deposit Rec\'d';                                                           
        } 
    } 
    
    //Added by Poonam Bhargava(12/14/2016) - D-00016575
    /**
      * @description    :   Method to populate App Track fields 'IH Lead Source' and 'Lead Channel' from IH Lead object
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populatefieldFromIHLead(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setLeadIds = new Set<Id>();
        
        //Loop over App Track records
        for(Tenant_App__c tA : newTenantApp){
        
            //Check for insert/update case  
            if(tA.Lead__c != null && (mapOfOldTenantApp == null || mapOfOldTenantApp.get(tA.Id).Lead__c != tA.Lead__c
                                        || tA.IH_Lead_Source__c != mapOfOldTenantApp.get(tA.Id).IH_Lead_Source__c
                                        || tA.Lead_Channel__c != mapOfOldTenantApp.get(tA.Id).Lead_Channel__c))
        
            //Populate set with listing ids
            setLeadIds.add(tA.Lead__c);
        }
         
        //Check for set size
        if(setLeadIds.size()> 0){
    
            //Initialize map to hold listing record with listing IDs
            Map<Id, Incoming_Calls__c> mapLeads = new Map<Id, Incoming_Calls__c>([Select Id, Source_New__c,Lead_Channel__c
                                                                From Incoming_Calls__c Where Id IN : setLeadIds]);
    
            //Loop over App Track records
            for(Tenant_App__c tA : newTenantApp){
            
                //Check for map size and for eligibility criteria
                if(tA.Lead__c != null && mapLeads.containsKey(tA.Lead__c)){
            
                    //Populate field 'IH Lead Source' on App Track 
                    if(tA.IH_Lead_Source__c != mapLeads.get(tA.Lead__c).Source_New__c)       
                        tA.IH_Lead_Source__c = mapLeads.get(tA.Lead__c).Source_New__c; 
                    
                    //Populate field 'Lead Channel' on App Track 
                    if(tA.Lead_Channel__c != mapLeads.get(tA.Lead__c).Lead_Channel__c)       
                        tA.Lead_Channel__c = mapLeads.get(tA.Lead__c).Lead_Channel__c;
                } 
            }
        }
    }    

    //Prasad: D-00017575.
    /**
      * @description    :   Method to populate Company__c in App Track record from IH Lead object
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populateCompanyFromIHLead(List<Tenant_App__c> newAppTrack, map<Id, Tenant_App__c> mapOfOldAppTrack) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setLeadIds = new Set<Id>();
        
        //Loop over App Track records
        for(Tenant_App__c tA : newAppTrack){
            if(tA.Lead__c != null)
                setLeadIds.add(tA.Lead__c); //Populate set with listing ids
        }
         
        //Check for set size
        if(setLeadIds.size()> 0){
            //Initialize map to hold listing record with listing IDs
            Map<Id, Incoming_Calls__c> mapLeads = new Map<Id, Incoming_Calls__c>([Select Id,Company__c From Incoming_Calls__c Where Id IN : setLeadIds]);
    
            //Loop over App Track records
            for(Tenant_App__c tA : newAppTrack){
                //Check for map size and for eligibility criteria
                if(tA.Lead__c != null && mapLeads.containsKey(tA.Lead__c)){
                    if(tA.Company__c != mapLeads.get(tA.Lead__c).Company__c)       
                        tA.Company__c = mapLeads.get(tA.Lead__c).Company__c;
                } 
            }
        }
    }    


    //Added by Saurabh kumar(01/24/2017)
    /**
    * @Discription    :    Method to populate the Days to Re-Resident & General Contractor in Application Tracking.
    *
    * @arg            :    List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> oldMap
    *
    * @return         :    void
    **/
    public static void updateDaysToReResidentGeneralContractorOnApplicationTracking(List<Tenant_App__c> newTenantApp ,Map<Id,Tenant_App__c> oldMap){
        Map<Id, List<Tenant_App__c> > mapApplicationTrack = new Map<Id, List<Tenant_App__c>>();
        for(Tenant_App__c tenant : newTenantApp){
            if( ( oldMap == null 
                 || (oldMap.containsKey(tenant.Id)  && Utility.hasFieldChanged(tenant, oldMap, 'Listing__c')) )
               && tenant.Listing__c != null){ 
                   mapApplicationTrack.put(tenant.Listing__c, mapApplicationTrack.containsKey(tenant.Listing__c)? ((List<Tenant_App__c>)mapApplicationTrack.get(tenant.Listing__c).add(tenant)) : new List<Tenant_App__c>{tenant}); 
               }else If(tenant.Listing__c == null){
                   tenant.Days_to_Re_Resident__c = null;
                   tenant.General_Contractor__c  = null; 
               }
        }
        
        if(!mapApplicationTrack.isEmpty()){
            for(Listing__c listing : [select id, Days_to_Re_Resident__c, rehab__r.General_Contractor__c from Listing__c where Id IN : mapApplicationTrack.keyset()]){
                for(Tenant_App__c tapp : mapApplicationTrack.get(listing.id)){
                    tapp.Days_to_Re_Resident__c = listing.Days_to_Re_Resident__c;
                    tapp.General_Contractor__c  = listing.rehab__r.General_Contractor__c;
                }
            }
        }
    }
    //Added by Saurabh kumar(01/24/2017)
    /**
    * @Discription    :    Method to be used by Listing Trigger Helper and Rehab Trigger Helper to update on App track
    *
    * @arg            :     Map<Id, Map<String,Object>> 
    *
    * @return         :    void
    **/
    public static void updateDaysToReResidentGeneralContractorOnApplicationTrackingExternal( Map<Id, Map<String,Object>> mapListIdWithsobject){
        //Initialising the list to update.
        List<Tenant_App__c> updateTenantApp = new List<Tenant_App__c>();
        
        for(Tenant_App__c tapp : [Select id, General_Contractor__c, Days_to_Re_Resident__c,Listing__c ,Listing__r.Rehab__c , Listing__r.Rehab__r.General_Contractor__c from Tenant_App__c where Listing__c IN : mapListIdWithsobject.keySet()]){
            
            if(mapListIdWithsobject.containsKey(tapp.Listing__c) &&
               ((mapListIdWithsobject.get(tapp.Listing__c).containsKey('Days_to_Re_Resident__c') && (Decimal)mapListIdWithsobject.get(tapp.Listing__c).get('Days_to_Re_Resident__c') != tapp.Days_to_Re_Resident__c)
                ||(mapListIdWithsobject.get(tapp.Listing__c).containsKey('General_Contractor__c') && (Id)mapListIdWithsobject.get(tapp.Listing__c).get('General_Contractor__c') != tapp.General_Contractor__c )
                || mapListIdWithsobject.get(tapp.Listing__c).containsKey('Rehab__c') && mapListIdWithsobject.get(tapp.Listing__c).get('General_Contractor__c') == null)){
                    
                    Tenant_App__c tappTemp = new Tenant_App__c(Id = tapp.Id);
                    tappTemp.Days_to_Re_Resident__c = mapListIdWithsobject.get(tapp.Listing__c).containsKey('Days_to_Re_Resident__c') ? (Decimal)mapListIdWithsobject.get(tapp.Listing__c).get('Days_to_Re_Resident__c') : tapp.Days_to_Re_Resident__c;       
                    tappTemp.General_Contractor__c =  mapListIdWithsobject.get(tapp.Listing__c).containsKey('General_Contractor__c') ? (Id)mapListIdWithsobject.get(tapp.Listing__c).get('General_Contractor__c'): tapp.General_Contractor__c;
                    tappTemp.General_Contractor__c =  mapListIdWithsobject.get(tapp.Listing__c).containsKey('Rehab__c')? tapp.Listing__r.Rehab__r.General_Contractor__c : tappTemp.General_Contractor__c;
                    updateTenantApp.add(tappTemp);
                    //System.assertEquals(null, mapListIdWithsobject);
                    
                }
        }
        //Checking for empty list & updating it.
        if(!updateTenantApp.isEmpty() && Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER){
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = false;
            update updateTenantApp;
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = true;
        }
    }
    
    //Added By Poonam Bhargava -(05/04/2017)
    /**
      * @description    :   Method to populate App Track field Leasing Agent(Co-Broker) IH- Vendor ID from User's VendorId
      *
      * @arg            :   List of new App Track , map of old App Track 
      *
      * @return         :   Void
    **/
    public static void populateLeasingAgentCoBrokerIHVendorId(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp) {

        //Set to hold App Track Id
          Set<Id> setofUserIds = new Set<Id>();
    
        //Loop over Trigger new list of Application Tracking
        for(Tenant_App__c tA : newTenantApp){
        
            //Check for eligible criteria (insert/update case)  
            if(tA.Co_Broker_IH__c != null){
                
                //Populate set with App Track ids
                setofUserIds.add(tA.Co_Broker_IH__c );
            } 
            else{
                
                //Popualte App Track field with null value
                tA.Leasing_Agent_Co_Broker_IH_VendorId__c = null;
            } 
        }
        
        //Check for set size
        if(setofUserIds.size() > 0){
        
            //Populate map with User record
            Map<Id, User> mapOfUsers = new Map<Id, User>([Select Id, VendorID__c from User where Id IN : setofUserIds]);
            
            //Loop over App Track record
            for(Tenant_App__c tA : newTenantApp){
        
                //Check for field value Leasing Agent (Co-broker ) - IH on App Track
                if(tA.Co_Broker_IH__c != null && mapOfUsers.containsKey(tA.Co_Broker_IH__c)){
                
                    //Check for eligible criteria and populate field Leasing Agent(Co-Broker) IH- Vendor ID accordingly
                    if(tA.Leasing_Agent_Co_Broker_IH_VendorId__c != mapOfUsers.get(tA.Co_Broker_IH__c).VendorID__c)
                        tA.Leasing_Agent_Co_Broker_IH_VendorId__c = mapOfUsers.get(tA.Co_Broker_IH__c).VendorID__c;     
                }           
            }     
        } 
    } 
    
    
    
    //Added by Saurabh Kumar(5/29/2016) - 
     /**
     * @Description     :       This method to update App Track Listing Agent based on
     *                          IH Lead:Notification Or Listing :Secondary Agent 
     * 
     * @args            :       void
     *
     * @return          :       void
     **/
     
     Public static void updateListingAgentOnAppTrack(List<sObject> newListAppTrackRelatedObjects, Map<Id ,sObject> oldMap){
        
        If(newListAppTrackRelatedObjects.isEmpty())
        return ;
        
        //set collection to keep listing Id
        Set<Id> setListingId = new Set<Id>();
        //set of Incoming Call
        Set<ID> setLeadId = new Set<Id>();
        //Map LeadId with Lead 
        Map<Id , Incoming_Calls__c> mapIDToLead = new Map<Id, Incoming_Calls__c>();
        //Map of Lisiting Id to related AppTrack 
        Map<Id, List<Tenant_App__c>> mapListingIdToAppTrack = new Map<Id, List<Tenant_App__c>>();
        List<Tenant_App__c> listAppTrack = new List<Tenant_App__c>();
        //List Of App Track which need to be updated 
        List<Tenant_App__c> listAppTrackToRetrun  = new List<Tenant_App__c>();
        
        //Knowing Type of Sobject from which trigger it has been called 
        String Type = newListAppTrackRelatedObjects[0].getSObjectType().getDescribe().getName();
        
        //if called from   App Track Trigger 
        If(Type == Schema.sObjectType.Tenant_App__c.getSObjectType().getDescribe().getName()){
             listAppTrack = (List<Tenant_App__c>) newListAppTrackRelatedObjects;         
        }   
        
        //If called  from  Listing  trigger 
        else If(Type == Schema.sObjectType.Listing__c.getSObjectType().getDescribe().getName()){
                 List<Listing__c> newListing  = (List<Listing__c>)newListAppTrackRelatedObjects;
                 Map<Id ,Listing__c> oldLeadMap = (Map<Id ,Listing__c>)oldMap;
                 
                 for(Listing__c listing :newListing){
                        If(listing.Actual_AppTrack__c != null && (Utility.hasFieldChanged(listing, oldLeadMap, 'Secondary_Agent__c') || Utility.hasFieldChanged(listing, oldLeadMap, 'Actual_AppTrack__c'))){
                            setListingId.add(listing.id);
                         }
                 }
                 
                If(setListingId.isEmpty())
                return ;
                //App Track Status which is Closed or Cancelled 
                List<String> listAppStatusWhichClosed = Label.AppTrackClosedStatus.split(',');        
                listAppTrack = [Select Id , Name ,Listing_Agent_Name_Text__c, Listing__c , Lead__c ,Showing_Record__c from Tenant_App__c where Listing__c In :setListingId and  Application_Status__c NOT IN :listAppStatusWhichClosed ];
         }
        
        //creating map of LisitingId with AppTrack which need to be updated 
        for(Tenant_App__c appTrack : listAppTrack){
                 If(appTrack.Listing__c != null ){
                 
                     setListingId.add(appTrack.Listing__c);
                     
                     If(appTrack.Lead__c != null)
                     setLeadId.add(appTrack.Lead__c);
                     
                     If(mapListingIdToAppTrack.containsKey(appTrack.Listing__c)){
                      mapListingIdToAppTrack.get(appTrack.Listing__c).add(appTrack);
                     }else{
                        mapListingIdToAppTrack.put(appTrack.Listing__c ,new List<Tenant_App__c>{appTrack} ); 
                     }
                     system.debug('mapListingIdToAppTrack '+mapListingIdToAppTrack);
                 
                 }
        }
        
        
        //creating map of AppTrack and related Lead
        If(!setLeadId.isEmpty())
        mapIDToLead = new Map<Id, Incoming_Calls__c>([Select Id ,Listing__c ,Notification_Agent__c ,Notification_Agent__r.Name from Incoming_Calls__c where Id IN :setLeadId]); 
            
            
            
        
        System.debug(mapListingIdToAppTrack);
        //returning if mapListingIdToAppTrack is null
        If(mapListingIdToAppTrack.isEmpty())
        return ;
        
        for(Listing__c listing : [Select id , Secondary_Agent__c ,Secondary_Agent__r.name ,Listing_Agent__r.Email , Secondary_Agent__r.Email  from Listing__c where Id IN :mapListingIdToAppTrack.keySet()]){
             
                If(!mapListingIdToAppTrack.containsKey(listing.id))
                continue;
                //Iterating over apptrack related to Listing 
                for(Tenant_App__c appTrack : mapListingIdToAppTrack.get(listing.id)){
                    
                    //checking if Listing has secondary Agent and App Track is Active and having Listing_Agent_Name_Text__c = null
                    If(appTrack.Listing_Agent_Name_Text__c == null 
                       && (appTrack.Lead__c != null || appTrack.showing_Record__c != null )
                       &&  listing.Secondary_Agent__c != null){
                        String leadNotificationAgent = mapIDToLead.containsKey(appTrack.Lead__c)?mapIDToLead.get(appTrack.Lead__c).Notification_Agent__r.Name : listing.Secondary_Agent__r.name;
                        appTrack.Listing_Agent_Name_Text__c = (leadNotificationAgent != null && leadNotificationAgent == listing.Secondary_Agent__r.name) ?listing.Secondary_Agent__c+'-'+leadNotificationAgent :null;
                        
                    }
                    appTrack.AppTrack_Listing_Agent_Email__c = appTrack.Listing_Agent_Name_Text__c!=null? listing.Secondary_Agent__r.Email : listing.Listing_Agent__r.Email ;
                    listAppTrackToRetrun.add(appTrack);
                }
         }
         
        //Updating AppTrack only when it is called from other than AppTrack Trigger     
        if(Type != Schema.sObjectType.Tenant_App__c.getSObjectType().getDescribe().getName() && !listAppTrackToRetrun.isEmpty() ){
           Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = false;
           update listAppTrackToRetrun;
           Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = true;
        
        }
     }

     //Added by Poonam Bhargava(06/19/2017) - D-00017170
    /**
    * @description    :     Method to populate "AppTrack Owner" field on Lease from Application Tracking record
    *
    * @arg            :     List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp
    *
    * @return         :     Void
    **/
    public static void populateAppTrackOwnerOnLease(List<Tenant_App__c> newTenantApp, map<Id, Tenant_App__c> mapOfOldTenantApp){

        //Set of Application Tracking Ids
        Set<Id> setOfAppTrack = new Set<Id>();
        
        //List of Lease to be updated
        List<Tenant_Card__c> leaseToBeUpdated =  new List<Tenant_Card__c>();
    
        //Loop Over Application Tracking record
        for(Tenant_App__c tA : newTenantApp){
        
            //Check for insert/update case and populate set with App Track Ids
            if(tA.OwnerId != mapOfOldTenantApp.get(tA.Id).OwnerId)
                setOfAppTrack.add(tA.Id);
        }
    
        //Check for set size
        if(setOfAppTrack.size() > 0){
        
          //Get the key Prefix of Queue 
          String keyPrefix = Schema.getGlobalDescribe().get('Group').getDescribe().getKeyPrefix();

          //Set to hold already existing Lease id 
          Set<Id> alreadyAddedLease = new Set<Id>();

          //Loop over listing records
          for(Listing__c  li : [Select Id, Actual_AppTrack__c, Actual_AppTrack__r.OwnerId, Resulting_Lease__c, 
                        Resulting_Lease__r.AppTrack_Owner__c from Listing__c where Actual_AppTrack__c != null 
                        and Actual_AppTrack__c IN : setOfAppTrack Order By LastModifiedDate DESC]){

                //Check for eligible criteria on listing and populate lease list accordingly
                if(li.Actual_AppTrack__r.OwnerId != null){

                    //String variable to hold App track owner id as string
                    String appOwner = String.valueOf(li.Actual_AppTrack__r.OwnerId);
  
                    //Check for App Track owner update condition and add into list 
                    if((!appOwner.contains(keyPrefix)) && (!alreadyAddedLease.contains(li.Resulting_Lease__c))
                        && li.Resulting_Lease__c != null && li.Resulting_Lease__r.AppTrack_Owner__c != li.Actual_AppTrack__r.OwnerId){

                        //Add into list to be updated
                        leaseToBeUpdated.add(new Tenant_Card__c(Id = li.Resulting_Lease__c, AppTrack_Owner__c = li.Actual_AppTrack__r.OwnerId)); 

                        //Populate set with lease Id    
                        alreadyAddedLease.add(li.Resulting_Lease__c);
                    }        
                }else{
                    leaseToBeUpdated.add(new Tenant_Card__c(Id = li.Resulting_Lease__c, AppTrack_Owner__c = null));
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
}