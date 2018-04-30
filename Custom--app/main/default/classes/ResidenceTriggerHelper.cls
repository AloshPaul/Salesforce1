/**
 *  Description :   Helper class for Trigger_Residence trigger.
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   03/05/2013
 *
 *  Revision Logs:  V1.0 - Created
 *                  V_1.1 - Bhavi Sharma - 07/20/2013 - Added new method(validateAddressChanges) - D-00006528
                    V_1.2 - Bhavi Sharma - 10/10/2013 - Modified validateAddressChanges method - D-00007174
                            (Nullify Google geo code fields id address data has been changed)
 *                  V_1.3 - Abhinav Sharma - 04/03/2015 - Added new method (populateMoveOutDateOnListings) - D-00013862
 *                  V_1.4 - Abhinav Sharma - 05/04/2015 - Modified method(populateMoveOutDateOnListings) - D-00014017
 *                  V_1.5 - Abhinav Sharma - 10/16/2015 - Modified method(populateMakeReadyDateOnListings)
 *                  v_1.6 - Saurabh Kumar  - 05/13/2016 - Modified method (validateUpdates) - D-00015533
 *                  V_1.7 - Poonam Bhargava - 03/07/2017 - Added a new method updateDispositionInfoOnListingAndRehab - D-00016958 
 *                  V_1.8 - Poonam Bhargava - 05/15/2017 - Added a new method populateHOAAmenityInformationOnListing - D-00017131
 *                  V_1.9 - Poonam Bhargava - 10/27/2017 - Modified the method generateUniqueAPN - D-00017506
 *
 **/
public without sharing class ResidenceTriggerHelper {

    private static String PORTFOLIO_RESIDENCE_LOCK_DISABLED_PROFILE = 'Portfolio Residence Lock Disabled Profile';
    private static String PORTFOLIO_RESIDENCE_LOCK_DISABLED_USER = 'Portfolio Residence Lock Disabled User';
    private static String RESIDENCE_FIELDS_NOT_ALLOWED_FOR_UPDATE   = 'ResidenceFieldsNotAllowedForUpdate';

    private static final String CUSTOM_FIELD_APN = 'APN__c';
    private static final String CUSTOM_FIELD_MULTI_UNIT = 'Child_Unit__c';
    private static final String CUSTOM_FIELD_ADDRESS_UNIT = 'Address_Unit__c';

    private static final String UPDATE_ERROR_MESSAGE = Label.Residence_Update_Not_Allowed_Error_Message;
    //Get APN Unique
    private static String getApnUnique(Residence__c res){
        return Utility.removeExceptAlphaNumeric(res.APN__c);
    }

    public static Boolean runValidation = true;

    public static void validateUpdates(List<Residence__c> residenceNew, Map<Id, Residence__c> resOldMap) {
        if(runValidation) {

            Set<String> setExcludedProfiles = new Set<String>();
            Set<String> setExecludedUsers = new Set<String>();

            //Configuration Manager
            List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>(Constants.getConfigManagerByParameterKey(PORTFOLIO_RESIDENCE_LOCK_DISABLED_PROFILE));
            configs.addAll(Constants.getConfigManagerByParameterKey(PORTFOLIO_RESIDENCE_LOCK_DISABLED_USER));
            
            //fill set from custom settings
            for(Configuration_Manager__c config : configs) {

                if(config.Parameter_Value__c != null 
                   && config.Parameter_Key__c == PORTFOLIO_RESIDENCE_LOCK_DISABLED_PROFILE){
                    
                    setExcludedProfiles.add(config.Parameter_Value__c.trim().toLowerCase());
                }
                else if(config.Parameter_Value__c != null 
                   && config.Parameter_Key__c == PORTFOLIO_RESIDENCE_LOCK_DISABLED_USER){
                    
                    setExecludedUsers.add(config.Parameter_Value__c.trim().toLowerCase());      
                 }          
            }
            //get profile name for current user
            String profileName = [Select Name From Profile Where id =: Userinfo.getProfileId()].Name;
            System.debug('profileName:::::'+ profileName );
            System.debug('setExcludedProfiles:::::'+ setExcludedProfiles );
            System.debug('UserName:::::'+ UserInfo.getUserName());
            System.debug('setExecludedUsers:::::'+ setExecludedUsers );
            
            if(!setExcludedProfiles.Contains(profileName.toLowerCase())
               && !setExecludedUsers.Contains(UserInfo.getUserName().toLowerCase())){

                List<Property__c> listPortfolio = [Select Residence__c From Property__c
                                                    Where Residence__c in: residenceNew];
                Set<Id> setResidenceIdsNotUpdatable = new Set<Id>();
                for(Property__c p : listPortfolio) {
                    setResidenceIdsNotUpdatable.add(p.Residence__c);
                }

                if(setResidenceIdsNotUpdatable.size() > 0) {

                    Set<String> fieldsNotAllowedForUpdate = new Set<String>();

                    //Configuration Manager
                    List<Configuration_Manager__c> residenceConfigs = Constants.getConfigManagerByParameterKey(RESIDENCE_FIELDS_NOT_ALLOWED_FOR_UPDATE);

                    for(Configuration_Manager__c config : residenceConfigs) {

                        if(config.Parameter_Value__c != null) {
                            fieldsNotAllowedForUpdate.add(config.Parameter_Value__c.trim().toLowerCase());
                        }
                    }

                    for(Residence__c res : residenceNew) {
                        if(setResidenceIdsNotUpdatable.size() > 0 && setResidenceIdsNotUpdatable.contains(res.Id)) {

                            Boolean allowUpdate = true;
                            for(String f : fieldsNotAllowedForUpdate) {
                                Residence__c oldRes = resOldMap.get(res.Id);
                                if(res.get(f) != oldRes.get(f))
                                    allowUpdate = false;
                            }
                            if(!allowUpdate)
                                res.addError(UPDATE_ERROR_MESSAGE);
                        }
                    }
                }
            }
        }
    }


    //method to get apn unique for residence
    public static void generateUniqueAPN(List<Residence__c> residenceNew, Map<Id, Residence__c> residenceOldMap) {
        for(Residence__c res : residenceNew) {
        
            //Added by Poonam Bhargava - (D-00017506)
            if(String.isNotBlank(res.Region__c) && Label.SWAY_REGION.containsIgnoreCase(res.Region__c)){
                res.SWAY__c = true;
            }
            
            if( (   Utility.hasFieldChanged(res, residenceOldMap, CUSTOM_FIELD_APN)
                    ||
                    Utility.hasFieldChanged(res, residenceOldMap, CUSTOM_FIELD_MULTI_UNIT)
                    ||
                    Utility.hasFieldChanged(res, residenceOldMap, CUSTOM_FIELD_ADDRESS_UNIT)
                )
                ||
                (  res.APN_Unique__c == null || res.APN_Search__c == null)
              ) {
                res.APN_Unique__c = getApnUnique(res) + (res.Child_Unit__c && res.Address_Unit__c != null ? (' - ' + Utility.removeExceptAlphaNumeric(res.Address_Unit__c)) : '');
                res.APN_Search__c = getApnUnique(res);
            }
        }
    }

    //This method is to check if address data has been changed.
    //If any of the address field has been changed to residence record, nullify all the validated address data
    //and Mark this as Validated_Successfully = false and set Last Attempt Date as Null
    public static void validateAddressChanges(List<Residence__c> residences, Map<Id, Residence__c> mapOldResidences) {

        //Loop through all the new residences and check if address data have been changed in any of the field
        for(Residence__c residence : residences) {

            //Get the residence old instance
            Residence__c oldResidence = mapOldResidences.get(residence.Id);

            //Compare new residence with old record and check if address data has been changed
            if(residence.Address_Street__c != oldResidence.Address_Street__c
                || residence.Address_City__c != oldresidence.Address_City__c
                || residence.Address_State__c != oldResidence.Address_State__c
                || residence.Address_Zip_Code__c != oldResidence.Address_Zip_Code__c) {

                //Nullify all the validated address fields
                residence.Address_Validated_Street__c = null;
                residence.Address_Validated_City__c = null;
                residence.Address_Validated_State__c = null;
                residence.Address_Validated_Zip__c = null;
                residence.ZipPlus4__c = null;
                residence.Location__Latitude__s =  null;
                residence.Location__Longitude__s =  null;
                residence.Address_Validated_County__c = null;
                residence.Address_Validation_Message__c = null;
                residence.Address_Validated_Last_Attempt__c = null;
                residence.Address_Validated_Successfully__c = false;

                //Nullify Google Geo Code fields
                //residence.Google_geocode_last_attempt__c = null;
                //residence.Google_geocode_assigned__c = false;
            }
        }
    }
    
    //Added By - Abhinav Sharma - 04/03/2015 - D-00013862  
    /**  Description    :   Method to populate Move out date on most recent listing record with Most recent YRR move out date value. 
    *                       if any update happens for the "Most recent listing"/"Most recent YRR" field value on residence.
    *
    *    Created By     :   Abhinav Sharma
    *
    *    Arguments      :   List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences
    *
    *    Return         :   void
    *
    **/
    /*public static void populateMoveOutDateOnListings(List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences) {

        //Set to hold the residence IDs
        Set<Id> setResidenceIDs = new Set<Id>();

        //Map to hold the listing ID as key and listing record as value
        Map<Id, Listing__c> mapListings = new Map<Id, Listing__c>();

        //Loop through new records list
        for(Residence__c res : newResidences) {

            //Checking if most recent lookup fields were populated on the residence record 
            //and with this, any of them got changed
            //If satisfies, then only needs to execute the trigger logic
            if(res.Most_Recent_Listing__c != null 
                && res.Most_Recent_Yardi_Rent_Roll__c != null
                && mapOldResidences != null 
                && (res.Most_Recent_Listing__c != mapOldResidences.get(res.Id).Most_Recent_Listing__c
                    || res.Most_Recent_Yardi_Rent_Roll__c != mapOldResidences.get(res.Id).Most_Recent_Yardi_Rent_Roll__c)  
            ) {
            
                //Populating collections
                setResidenceIDs.add(res.Id);
            }
        }

        //Loop through eligible residence records
        for(Residence__c r : [SELECT Id, Most_Recent_Listing__c, Most_Recent_Yardi_Rent_Roll__c, 
                                Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c FROM Residence__c
                                WHERE Id IN : setResidenceIDs]) {
        
            if(r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c != null)
                mapListings.put(r.Most_Recent_Listing__c, new Listing__c(Id = r.Most_Recent_Listing__c, YRR_Move_Out_Date__c = r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c));
        }

        //Checking for the size
        if(mapListings.values().size() > 0)
            update mapListings.values(); 
    }*/
    
    //Added By - Abhinav Sharma - 10/16/2015 - D-00014655  
    /**  Description    :   Method to populate Yardi Make Ready Date on most recent listing record with Most recent YRR's Yardi Make Ready Date value. 
    *                       if any update happens for the "Most recent listing"/"Most recent YRR" field value on residence.
    *
    *    Created By     :   Abhinav Sharma
    *
    *    Arguments      :   List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences
    *
    *    Return         :   void
    *
    **/
    public static void populateMakeReadyDateOnListings(List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences) {

        //Set to hold the residence IDs
        Set<Id> setResidenceIDs = new Set<Id>();

        //Map to hold the listing ID as key and listing record as value
        Map<Id, Listing__c> mapListings = new Map<Id, Listing__c>();

        //Loop through new records list
        for(Residence__c res : newResidences) {

            //Checking if most recent lookup fields were populated and any of them got changed
            if(res.Most_Recent_Listing__c != null 
                && res.Most_Recent_Yardi_Rent_Roll__c != null
                && mapOldResidences != null 
                && (res.Most_Recent_Listing__c != mapOldResidences.get(res.Id).Most_Recent_Listing__c
                    || res.Most_Recent_Yardi_Rent_Roll__c != mapOldResidences.get(res.Id).Most_Recent_Yardi_Rent_Roll__c)) {
            
                //Populating set with residence ids
                setResidenceIDs.add(res.Id);
            }
        }
        
        if(setResidenceIDs.size() > 0){
        
            //Loop through residence records
            for(Residence__c r : [SELECT Id, Most_Recent_Listing__c, Most_Recent_Yardi_Rent_Roll__c, 
                                    Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c,
                                    Most_Recent_Listing__r.Make_Ready_Date__c 
                                    FROM Residence__c
                                    WHERE Id IN : setResidenceIDs]) {
                                      
              //Check for null and populate listing map
                if(r.Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c != r.Most_Recent_Listing__r.Make_Ready_Date__c)                        
                    mapListings.put(r.Most_Recent_Listing__c, new Listing__c(Id = r.Most_Recent_Listing__c, Make_Ready_Date__c = r.Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c));
            
            }
            
            //Checking for size value and update listing record
            if(mapListings.values().size()  > 0) {
              Constants.EXECUTE_TRIGGER = false;
              update mapListings.values();
              Constants.EXECUTE_TRIGGER = true;
            }   
        }   
    }
    
    //Added By - Poonam Bhargava - 03/07/2017 - D-00016958
    /**  Description    :   Method to populate Disposition Information on the listing/Rehab record with Most recent Disposition value. 
    *
    *    Created By     :   Poonam Bhargava
    *
    *    Arguments      :   List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences
    *
    *    Return         :   void
    *
    **/
    public static void updateDispositionInfoOnListingAndRehab(List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences){

        //Set to hold the residence IDs
        Set<Id> setResidenceIDs = new Set<Id>();
        
        //Creating list variable of Listing
        List<Listing__c> listings = new List<Listing__c>();
        
        //Creating list variable of Rehab
        List<Rehab__c> rehabs = new List<Rehab__c>();
    
        //Loop through new records list
        for(Residence__c res : newResidences) {
    
            //Checking if most recent disposition field value got changed
            if(mapOldResidences != null  && res.Most_Recent_Disposition__c != mapOldResidences.get(res.Id).Most_Recent_Disposition__c) {
            
                //Populating set with residence ids
                setResidenceIDs.add(res.Id);
            }
        }

        //Check for set size
        if(setResidenceIDs.size() > 0){
        
            //Loop over Listing 
            for(Listing__c listing : [SELECT Id, Disposition_No__c,Disposition_Listing_Status__c, Disposition_Strategy__c,Residence__c,
                                         Residence__r.Most_Recent_Disposition__c, Residence__r.Most_Recent_Disposition__r.Listing_Status__c, 
                                         Residence__r.Most_Recent_Disposition__r.Disposition_Strategy__c 
                                         FROM Listing__c WHERE Residence__c != null AND Residence__c IN: setResidenceIDs]){
                                
                //Check for null and populate listings
                if(listing.Residence__r.Most_Recent_Disposition__c != null && listing.Disposition_No__c != listing.Residence__r.Most_Recent_Disposition__c){                    
                    listings.add(new Listing__c(Id = listing.Id,  Disposition_No__c = listing.Residence__r.Most_Recent_Disposition__c, 
                                                    Disposition_Listing_Status__c = listing.Residence__r.Most_Recent_Disposition__r.Listing_Status__c,
                                                    Disposition_Strategy__c = listing.Residence__r.Most_Recent_Disposition__r.Disposition_Strategy__c ));
                
                }else if(listing.Residence__r.Most_Recent_Disposition__c == null){
                    listings.add(new Listing__c(Id = listing.Id,  Disposition_No__c = null,Disposition_Listing_Status__c = null,
                                                    Disposition_Strategy__c = null ));      
                }
            }
            
            //Loop over Rehab   
            for(Rehab__c rehab : [SELECT Id, Disposition_No__c,Disposition_Listing_Status__c, Disposition_Strategy__c,Home__c,
                                         Home__r.Most_Recent_Disposition__c, Home__r.Most_Recent_Disposition__r.Listing_Status__c, 
                                         Home__r.Most_Recent_Disposition__r.Disposition_Strategy__c 
                                         FROM Rehab__c WHERE Home__c != null AND Home__c IN: setResidenceIDs]){
                                
                //Check for null and populate rehab
                if(rehab.Home__r.Most_Recent_Disposition__c != null && rehab.Disposition_No__c != rehab.Home__r.Most_Recent_Disposition__c){                    
                    rehabs.add(new Rehab__c(Id = rehab.Id,  Disposition_No__c = rehab.Home__r.Most_Recent_Disposition__c, 
                                                    Disposition_Listing_Status__c = rehab.Home__r.Most_Recent_Disposition__r.Listing_Status__c,
                                                    Disposition_Strategy__c = rehab.Home__r.Most_Recent_Disposition__r.Disposition_Strategy__c ));
                
                }else if(rehab.Home__r.Most_Recent_Disposition__c == null){
                    rehabs.add(new Rehab__c(Id = rehab.Id,  Disposition_No__c = null,Disposition_Listing_Status__c = null,
                                                    Disposition_Strategy__c = null ));      
                }
            }   
        }
        
        //Check for list size
        if(listings.size() > 0){
            
            //Skip trigger
            Constants.EXECUTE_TRIGGER = false;
            
            //Update listing
            update listings;
            Constants.EXECUTE_TRIGGER = true;
        }
        
        //Check for list size
        if(rehabs.size() > 0){
            
            //Skip trigger
            Constants.EXECUTE_TRIGGER = false;
            
            //Update rehab
            update rehabs;
            Constants.EXECUTE_TRIGGER = true;
        }
    }   
    

    //Added By - Poonam Bhargava - 05/15/2017 -  D-00017131
    /**  Description    :   Method to populate HOA Amenity Information on the listing record from Account. 
    *
    *    Created By     :   Poonam Bhargava
    *
    *    Arguments      :   List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences
    *
    *    Return         :   void
    *
    **/
     public static void populateHOAAmenityInformationOnListing(List<Residence__c> newResidences, Map<Id, Residence__c> mapOldResidences){
     
        //Set to hold the residence IDs
        Set<Id> setResidenceIDs = new Set<Id>();
       
        //Loop through new records list
        for(Residence__c res : newResidences) {
    
            //Checking if most recent disposition field value got changed
            if(mapOldResidences != null  && res.HOA_Primary__c != mapOldResidences.get(res.Id).HOA_Primary__c ) {
            
                //Populating set with residence ids
                setResidenceIDs.add(res.Id);
            }
        }
        
        //Check for set size
        if(setResidenceIDs.size() > 0){
        
            //Loop over Listing 
            List<Listing__c> listing = [SELECT Id, Amenities__c,Amenities_Detail__c,Amenities_Included__c,Tenant_App_Required__c,
                                        Tenant_Application_Notes__c,HOA_Application_Fee__c,Other_Restrictions__c,Residence__c, Residence__r.HOA_Primary__c, Residence__r.HOA_Primary__r.Amenities__c, 
                                        Residence__r.HOA_Primary__r.Amenity_Details__c, Residence__r.HOA_Primary__r.Amenities_Included__c,
                                        Residence__r.HOA_Primary__r.Tenant_Aplication_Required__c,
                                        Residence__r.HOA_Primary__r.Tenant_Application_Notes__c,
                                        Residence__r.HOA_Primary__r.HOA_Application_Fee__c, 
                                        Residence__r.HOA_Primary__r.Other_Restrictions__c 
                                        FROM Listing__c WHERE Residence__c != null AND Residence__c IN: setResidenceIDs];
                                        
                                        
            //Call the method of class Tenant_App_TriggerHelper
            ListingTriggerHelper.updateHOAAmenityInformationOnListing(listing, null);
            
            //Bypass Trigger
            ListingTriggerHelper.EXECUTE_LISTING_TRIGGER = false;
            
            //Update App Track records
            update listing;
            ListingTriggerHelper.EXECUTE_LISTING_TRIGGER = true; 
        }                             
        
     }
}