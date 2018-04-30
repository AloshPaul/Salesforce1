/*
    Trigger helper for Lease Trigger
    Revision Logs   :   V1.0 Created - Rajesh Shah
                        V1.1 Updated as per the SIR - D-00008171 - 26th Sep, 2013
                        V1.2 Worked on SIR - D-00011371 and Made class without sharing - Shrinath
                        V1.3 Worked on SIR - D-00013665 and updated method updateRenewals to add date fields to update - Prashant Wayal, 12-Feb-2015
                        V1.4 Bhavi Sharma - 03/11/2015 - D-00013701: Autocreate the post acquisition rehab record upon move-out
                        V1.5 Abhinav Sharma - 07/04/2015 - D-00014372: Added new method "updateMoveOutDateBasedOnRehab" to fetch the listing record's 
                                                related to rehab and update the YRR Move-out Date field with the Rehab's Move-out date 
                                                on the basis of rehab.
                        v1.6 saurabh kumar -07/10/2015 D-00014396 updated method doActionsOnLeaseNoticeUpdate while creating dispositon rehab check for fund 2 property
                        v1.7 saurabh kumar - 07/28/2015D-00014444 created method  createLeaseDataIntegrityRecord which call on after insert 
                        v1.8 saurabh kumar  - 8/19/2015D-00014444 created method populateLDIRecordsBasedOnLease which trigger after update to populate some dependent field on child Lease data integrity records
                        v1.9 saurabh kumar  - 8/24/2015D-00014484 modified method populateResultingLeaseOnListing which trigger both(after insert and update) 
                        v1.10 Poonam Bhargava -(03/18/2016)- D-00015112 - new method - populateFieldsonAppTrackFromLease 
                        v1.11 Saurabh kumar  -(5/4/2016) :-D-00015385 - Modify method -doActionsOnLeaseNoticeUpdateToNonNul's  
                                                Condition below comments 'Check if this property is undergoing Disposition' 
                        v1.12 Poonam Bhargava - (05/12/2016) - (D-00015384) - Modified the method updateNewRenewedLeaseOnRenewal
                        v1.13 Saurabh Kumar - (8/11/2016) -D-00016046 updated method doActionsOnLeaseNoticeUpdateToNonNull
                        v1.14 Saurabh kumar - (09/06/2016) - D-00016125 = Updated method updateNewRenewedLeaseOnRenewal
                        v1.15 Poonam Bhargava - (10/13/2016)- D-00016239 - Added a new method createRenewalOnLeaseInsertion
                        v1.16 Saurabh kumar - (12/12/2016) - D-00016572 = Updated method updateNewRenewedLeaseOnRenewal(matches First & Last Name)
                        v1.17 Saurabh Kumar - (2/6/2017) - D-00016788 - Modified populateFieldsonAppTrackFromLease
                        v1.18 Poonam Bhargava - (06/19/2-17)- D-00017170 - Added a new method 'populateAppTrackOwnerfieldFromAppTrack'
                        v1.19 Saurabh Kumar - (5/24/2017) - D-00017164 - Created New Methods checkForLeaseRenewal & cancelRehabAndListing
                        v1.20 Poonam Bhargava - (09/16/2017)- Created a new method - populateResidenceFromProperty
                        V1.21 - Poonam Bhargava - (01/19/2018) - Created a new method - updateBedDataResultingLeaseOnListing
                        V1.22 - Poonam Bhargava - (04/02/2018) - Created a new method - populateLeaseRentFieldsOnListing - D-00017863
*/
public without sharing class LeaseTriggerHelper {

  //This flag is to control the execution of Lease Trigger
  public static Boolean EXECUTE_LEASE_TRIGGER = true;
     
    //This method is to stamp the most recent Lease record on Lease record
    public static void updateMostRecentLeaseOnResidence(List<Tenant_Card__c> newLease, Map<Id, Tenant_Card__c> oldLeaseMap) {

        // Map of Residence Id along with their Related Recoeds in Lease
        Map<Id, Tenant_Card__c> LeaseResidenceMap = new Map<Id,Tenant_Card__c >();

        // Looping Through the Lease Records
        for(Tenant_Card__c leaserec : newLease) {
            if(leaserec.Residence__c != null && leaserec.Yardi_Active_Lease__c
                    && (oldLeaseMap == null || !oldLeaseMap.get(leaserec.Id).Yardi_Active_Lease__c)){

                // Adding the Values to the map fulfilling the not null condition
                LeaseResidenceMap.put(leaserec.Residence__c ,leaserec);
            }
        }

        if(!LeaseResidenceMap.isEmpty()) {

            List<Residence__c> residenceList = new List<Residence__c>();
            // Creating a List of Residence Records
            for(Residence__c res : [Select Id From Residence__c
                                                            Where Id IN :LeaseResidenceMap.keySet()
                                                            and Parent_Structure__c = false]) {

                // Adding Values to the List
                residenceList.add(new Residence__c(Id = res.Id, Most_Recent_Lease__c = LeaseResidenceMap.get(res.Id).Id));
            }

            // Updating the residence List
            update residenceList;
        }
    }

    private static Map<Id, Listing__c> mapListingsToUpdate = new Map<Id, Listing__c>();
    private static List<Rehab__c> rehabsToUpsert = new List<Rehab__c>();
    private static List<Listing__c> listingsToUpsert = new List<Listing__c>();
    private static Map<Id, Rehab__c> mapRehabsToUpdate = new Map<Id, Rehab__c>();

    // method to update Rehab and Listings on Lease Notice Date Update
    public static void doActionsOnLeaseNoticeUpdate( List<Tenant_Card__c> newLease, Map<Id, Tenant_Card__c> oldLeaseMap ) {
        
        // initialize collections
        rehabsToUpsert = new List<Rehab__c>();
        mapListingsToUpdate = new Map<Id, Listing__c>();
        mapRehabsToUpdate = new Map<Id, Rehab__c>();
        
        Set<Id> setLeaseIdsWithNoticeDateUpdate = new Set<Id>();

        List<Tenant_Card__c> leasesNoticeDateUpdateToNonNull = new List<Tenant_Card__c>();
        List<Tenant_Card__c> leasesNoticeDateUpdateToNull = new List<Tenant_Card__c>();

        // Map of leases that are allowed to be processed on Lease Notice Update
        Map<Id, Tenant_Card__c> mapLeasesAllowed = new Map<Id, Tenant_Card__c>( [ Select Id,
                                                                                  Portfolio__r.Residence__c
                                                                                  , Portfolio__r.Closed_Completed_Post_Acq_Rehabs__c
                                                                                  , Portfolio__r.Non_Cancelled_Post_Acq_Rehabs__c
                                                                                  , Portfolio__r.Open_Rehab__c
                                                                                  , Portfolio__r.Total_Rehabs__c
                                                                                  , Portfolio__r.Number_Leases__c
                                                                                  , Portfolio__r.Open_TIP__c
                                                                                  , Portfolio__r.fund__c
                                                                                  , Portfolio__r.Rehab_on_TIP_HOLD__c
                                                                                  , Portfolio__r.Non_Cancelled_Post_Acq_Pur_Rented_Rehabs__c
                                                                                  , Portfolio__r.Closed_Comp_Post_Acq_Purch_Rented_Rehabs__c 
                                                                                  , YRR_Current_Tenant_Status__c
                                                                                  //, Portfolio__r.Closed_Cancelled_Post_Acq_Rehabs__c
                                                                                  From Tenant_Card__c
                                                                                  Where id in : newLease ] );

        // loop over lease the Lease Records
        for( Tenant_Card__c leaseObj : newLease ){
            
            // when notice date is changed from null to non null vaue or from non null to null value
            if(leaseObj.Yardi_Active_Lease__c && Utility.hasFieldChanged( leaseObj, oldLeaseMap, 'Notice_Date__c' )
                && ( leaseObj.Notice_Date__c == null || oldLeaseMap.get(leaseObj.Id).Notice_Date__c == null ) ){
                setLeaseIdsWithNoticeDateUpdate.add( leaseObj.Id );
                    
                // when notice date not equal to null
                 if( leaseObj.Notice_Date__c != null &&  leaseObj.Bad_Data__c == false 
                  && (leaseObj.Data_Validation_Notes__c == null || (leaseObj.Data_Validation_Notes__c != null && !leaseObj.Data_Validation_Notes__c.containsIgnoreCase(Label.Validation_Notes_Promote_Roommate)))
                  && leaseObj.Move_Out_Date__c != null) {

                    leasesNoticeDateUpdateToNonNull.add( leaseObj );
                }
                else {
                    leasesNoticeDateUpdateToNull.add( leaseObj );
                }
            }
        }
        
        Map<Id, Renewal__c> mapLeaseIdToRenewal = new Map<Id, Renewal__c>();
        // query renewals
        Map<Id, Renewal__c> mapRenewals = new Map<Id, Renewal__c>( [ Select Id,
                                                                            Lease__c,
                                                                            Scheduled_Move_Out_Date__c,
                                                                            Renewal_Status__c
                                                                       From Renewal__c
                                                                       Where Lease__c in: setLeaseIdsWithNoticeDateUpdate] );

        // loop over renewals
        for( Renewal__c renewalObj : mapRenewals.values() ) {
            mapLeaseIdToRenewal.put( renewalObj.Lease__c, renewalObj );
        }
        // query rehabs
        Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c> ( [ Select Renewal__r.Lease__c,
                                                                       Listing__r.Status__c,
                                                                       Listing__c,
                                                                       Renewal__c,
                                                                       Stage__c,
                                                                       Renewal_Status__c,
                                                                       Portfolio__c
                                                                From Rehab__c
                                                                Where Renewal__r.Lease__c in: setLeaseIdsWithNoticeDateUpdate ] );

        Map<Id, Rehab__c> mapLeaseIdToRehab = new Map<Id, Rehab__c>();
        // loop over rehabs
        for( Rehab__c rehabObj : mapRehabs.values() ) {
            mapLeaseIdToRehab.put( rehabObj.Renewal__r.Lease__c, rehabObj );
        }

        doActionsOnLeaseNoticeUpdateToNull( leasesNoticeDateUpdateToNull, mapLeaseIdToRehab, mapLeaseIdToRenewal );
        doActionsOnLeaseNoticeUpdateToNonNull( leasesNoticeDateUpdateToNonNull, mapLeaseIdToRehab, mapLeaseIdToRenewal, mapLeasesAllowed);
        
        //Error Log
        String debuglog = '';
        
        // upsert rehabs
        if(rehabsToUpsert.size() > 0 ) {
        
            //upsert rehabsToUpsert;
            //Upsert results
            Database.UpsertResult[] srs =  Database.upsert(rehabsToUpsert, false);
            
            Integer index = 0;
            //loop through the results
            for(Database.UpsertResult sr : srs) {
                Rehab__c rehabUpserted = rehabsToUpsert.get(index);
                if(!sr.isSuccess()) {
                   
                    debuglog += '<br/>' + sr.getId() + ' failed to update which is assocaied with portfolio ' + rehabUpserted.Portfolio__c;
                    for(Database.Error err : sr.getErrors()) {
                    
                        debuglog += '<br/>' + err.getMessage();
                    }
                }
                index++;
            }
        }

        //system.assert( false, debuglog );
        listingsToUpsert = new List<Listing__c>();

        // add all listings to update
        if( mapListingsToUpdate.size() > 0 ) {
            listingsToUpsert.addAll( mapListingsToUpdate.values() );
        }
        
        // query Turn record type
        List<RecordType> rtList = [ Select Id, Name, SObjectType
                                    From RecordType where (DeveloperName = 'Disposition')
                                    And SObjectType = 'Rehab__c' AND IsActive = true ORDER BY DeveloperName Limit 1
                                   ];
        
        //Don't do anything if record type not found
        if( rtList.size() != 1 )
            return;
        
        Id dispositionRecordTypeId = rtList.get(0).Id;
        //System.assert(false, rehabsToUpsert + ':::::' + mapRehabsToUpdate + ':::::' + mapRenewals);
        for( Rehab__c rehabObj : rehabsToUpsert ) {
            
            if( !mapRehabsToUpdate.containsKey( rehabObj.Id )) {
                
                //Get teh Related Lease iD
                Id leaseId = mapRenewals.containsKey(rehabObj.renewal__c) ? mapRenewals.get(rehabObj.renewal__c).Lease__c : null;
                if(rehabObj.RecordTypeId != dispositionRecordTypeId) {
                    if(rehabObj.Id != null) {
                      listingsToUpsert.add( new Listing__c( Id = rehabObj.Listing__c, Rehab__c = rehabObj.Id, Portfolio__c = rehabObj.Portfolio__c, Residence__c = rehabObj.Home__c, Status__c = Constants.LISTING_STATUS_DOWN_IN_REHAB, Previous_Lease__c  = leaseId));
                  }
                }
            }
        }

        // upsert listings
        if( listingsToUpsert.size() > 0 ) {
            
            //Upsert results
            Database.UpsertResult[] srs =  Database.upsert(listingsToUpsert, false);
            
            //loop through the results
            for(Database.UpsertResult sr : srs) {
                if(!sr.isSuccess()) {
                   
                    debuglog += '<br/>' + sr.getId() + ' failed to update.';
                    for(Database.Error err : sr.getErrors()) {
                        debuglog += '<br/>' + err.getMessage();
                    }
                }
            }
        }
        
        //Email User
        if(debuglog != null && debuglog != ''){
            Utility.sendEmail(UserInfo.getUserEmail(), 'TURN Creation Error', debuglog, debuglog);
            Utility.sendEmail('bhavi@cf-re.com', 'TURN Creation Error', debuglog, debuglog);
        }
    }
    
    // actions when lease notice date updated to non null value
    //Bhavi Sharma - 03/14/2015 - Modified: If the rehab we are creating on portfolio is first rehab, this should be of Post Acquisition TIP type
    //Once Post Acq is created, after that only TURN will be get created automatically.
    private static void doActionsOnLeaseNoticeUpdateToNonNull( List<Tenant_Card__c> leasesNoticeDateUpdateToNonNull,
                                                               Map<Id, Rehab__c> mapLeaseIdToRehab,
                                                               Map<Id, Renewal__c> mapLeaseIdToRenewal,
                                                               Map<Id, Tenant_Card__c> mapLeasesAllowed) {
          
        // query Turn record type
        List<RecordType> rtList = [Select Id, Name, SObjectType
                                    From RecordType where (DeveloperName = 'TURN' OR DeveloperName = 'Post_Acquisition_TIP' OR DeveloperName = 'Disposition')
                                    And SObjectType = 'Rehab__c' AND IsActive = true ORDER BY DeveloperName Limit 3
                                   ];
        
        //Don't do anything if record type not found
        if(rtList.size() != 3 )
            return;
        
        Id dispositionRecordTypeId = rtList.get(0).Id;
        Id postAcqTIPRecordTypeId = rtList.get(1).Id;
        Id turnRecordTypeId = rtList.get(2).Id;
        
        Set<Id> portfolioIds = new Set<Id>();
        
        //Loop over leases having notice date updated not equal to null
        for(Tenant_Card__c leaseObj : leasesNoticeDateUpdateToNonNull) {
            if( leaseObj.Portfolio__c != null ) {
                portfolioIds.add( leaseObj.Portfolio__c );
            }
        }
        
         
        Map<Id, Disposition__c> mapDispostion = new Map<Id, Disposition__c>( [ Select Portfolio__c ,TRS_Transferred__c
                                                                              ,Dispo_Lease_Renewal_Strategy__c,Disposition_Strategy__c
                                                                        From Disposition__c
                                                                        Where Portfolio__c in: portfolioIds 
                                                                        And BX_Approval_of_Sale__c = 'Yes'
                                                                        And IH_Approval_of_Sale__c = 'Yes'
                                    AND  Disposition_Strategy__c = :Constants.DISPOSITION_STRATEGY_MLS
                                                                        ] );
                                                                        
                                                                   
        Map<Id, Disposition__c> mapPortfolioIdToDispostion = new Map<Id, Disposition__c>();
        for( Disposition__c dis : mapDispostion.values() ) {
            mapPortfolioIdToDispostion.put( dis.Portfolio__c, dis );
        }
        
        //Loop over leases having notice date updated not equal to null
        for(Tenant_Card__c leaseObj : leasesNoticeDateUpdateToNonNull) {
            
            // when rehab record exists for the lease
            if(mapLeaseIdToRehab.containsKey(leaseObj.Id) ) {
                
                Rehab__c rehabObj = mapLeaseIdToRehab.get( leaseObj.Id );
                Renewal__c renewalObj = mapLeaseIdToRenewal.get( leaseObj.Id );
                String rehabStage = Constants.REHAB_STAGE_NOTIFICATION_RECEIVED;
                if( renewalObj != null && renewalObj.Scheduled_Move_Out_Date__c != null ) {
                    rehabStage = Constants.REHAB_STAGE_READY_TO_SCHEDULE_MOI_UTILITY_TRANSFER;
                }
                rehabObj.Stage__c = rehabStage;
                mapRehabsToUpdate.put( rehabObj.Id, rehabObj );
                if( rehabObj.Listing__c != null ) {
                    mapListingsToUpdate.put( rehabObj.Listing__c, new Listing__c( Id = rehabObj.Listing__c,
                                                                                  Status__c = Constants.LISTING_STATUS_DOWN_IN_REHAB
                                                                                 ) );
                }
            }
            else {
            
                // when lease is allowed to create a new rehab of Turn recordtype
                if( mapLeasesAllowed.containsKey( leaseObj.Id )) {
                    // when renewal record exists for the lease
                    if(mapLeaseIdToRenewal.containsKey( leaseObj.Id )) {
                                
                        Renewal__c renewalObj = mapLeaseIdToRenewal.get( leaseObj.Id );
                        
                        String rehabStage = Constants.REHAB_STAGE_NOTIFICATION_RECEIVED;
                        if( renewalObj != null && renewalObj.Scheduled_Move_Out_Date__c != null ) {
                            rehabStage = Constants.REHAB_STAGE_READY_TO_SCHEDULE_MOI_UTILITY_TRANSFER;
                        }
                                
                        Rehab__c rehabObj = new Rehab__c(Stage__c = rehabStage,
                                                         Portfolio__c = leaseObj.Portfolio__c,
                                                         Home__c = mapLeasesAllowed.get(leaseObj.Id).Portfolio__r.Residence__c
                                                        );
                                
                        //Create an instance of the lease record
                        Tenant_Card__c relatedLease = mapLeasesAllowed.get(leaseObj.Id);
                        
                        //Check if the relatedLease's current Tenant Status = Notice, create disposition rehab
                        if( leaseObj.Portfolio__c != null 
                             && mapPortfolioIdToDispostion.containsKey(leaseObj.Portfolio__c)
                             && (mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).Dispo_Lease_Renewal_Strategy__c == null 
                             || !mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).Dispo_Lease_Renewal_Strategy__c.equalsIgnoreCase('Okay to Renew')) 
                             && String.IsNotBlank(relatedLease.YRR_Current_Tenant_Status__c)
                             && relatedLease.YRR_Current_Tenant_Status__c.containsIgnoreCase('Notice')
                             &&( (mapLeasesAllowed.get(leaseObj.Id).Portfolio__r.Fund__c !='02')
                             || (mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).TRS_Transferred__c !=null
                             &&  mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).TRS_Transferred__c.equalsIgnoreCase('Yes')))){ 
                             
                                
                             System.debug('inside lease : disposition');
                            //Disposition record type
                             rehabObj.RecordTypeId = dispositionRecordTypeId;
                            
                           //now only when YRR current tenant status is vacant/admin than only acquisition status will be FOR SALE
                            //dispoPortfolios.add(new Property__c(Id = leaseObj.Portfolio__c, Acquisition_Status__c = 'For Sale'));
                        }
                        else if(relatedLease.Portfolio__r.Total_Rehabs__c > 0 
                                && (    relatedLease.Portfolio__r.Non_Cancelled_Post_Acq_Rehabs__c > 0 
                                     || relatedLease.Portfolio__r.Non_Cancelled_Post_Acq_Pur_Rented_Rehabs__c > 0 )
                                && relatedLease.Portfolio__r.Open_Rehab__c == 0 
                                && ( relatedLease.Portfolio__r.Closed_Completed_Post_Acq_Rehabs__c > 0 
                                    || relatedLease.Portfolio__r.Closed_Comp_Post_Acq_Purch_Rented_Rehabs__c > 0 ) &&(!mapPortfolioIdToDispostion.containsKey(leaseObj.Portfolio__c) || mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).Dispo_Lease_Renewal_Strategy__c=='Okay to Renew' )
                                ) {
                                      
                                    rehabObj.RecordTypeId = turnRecordTypeId;
                                  
                                  }
                        else if(
                               // SIR - D-00016019 number of non cancelled post acquistion should be 0 and non cancelled post acquistion purchase rented should be 0       
                               (!(    relatedLease.Portfolio__r.Total_Rehabs__c > 0 
                                   && (  relatedLease.Portfolio__r.Non_Cancelled_Post_Acq_Rehabs__c > 0 
                                         || relatedLease.Portfolio__r.Non_Cancelled_Post_Acq_Pur_Rented_Rehabs__c > 0 
                                      )
                                 ))                                    
                                &&   
                                relatedLease.Portfolio__r.Number_Leases__c > 0 
                                && relatedLease.Portfolio__r.Open_TIP__c == 0 
                                && relatedLease.Portfolio__r.Rehab_on_TIP_HOLD__c == 0  && (
                                   (!mapPortfolioIdToDispostion.containsKey(leaseObj.Portfolio__c) || 
                                    mapPortfolioIdToDispostion.get(leaseObj.Portfolio__c).Dispo_Lease_Renewal_Strategy__c =='Okay to Renew')))
                                    rehabObj.RecordTypeId = postAcqTIPRecordTypeId;
                            
                            rehabObj.Renewal__c = renewalObj.Id;
                        if( rehabObj.RecordTypeId != NULL)
                         rehabsToUpsert.add( rehabObj );
                        
                        //System.assert(false,  rehabsToUpsert);    
                    
                    }
                }
            }
        }
                                                                   
        // add rehasb to update in list rehabsToUpsert
        rehabsToUpsert.addAll(mapRehabsToUpdate.values());
      //no need to update acquisition status to for sale when YRR status is notice  
      /*  if(dispoPortfolios.size() > 0) {
            
            //No need to execute trigger
            PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = false;
            update dispoPortfolios;
            PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = true;
        }   */ 
    }

    // actions when lease notice date updated to null value
    private static void doActionsOnLeaseNoticeUpdateToNull( List<Tenant_Card__c> leasesNoticeDateUpdateToNull,
                                                            Map<Id, Rehab__c> mapLeaseIdToRehab,
                                                            Map<Id, Renewal__c> mapLeaseIdToRenewal ) {

        // loop over leases having notice date updated to null
        for( Tenant_Card__c leaseObj : leasesNoticeDateUpdateToNull ) {
            if( mapLeaseIdToRehab.containsKey( leaseObj.Id ) ) {
                
                Boolean leaseRenewed = false;
                if( mapLeaseIdToRenewal.containsKey(leaseObj.Id )) {
                    Renewal__c renewalObj = mapLeaseIdToRenewal.get(leaseObj.Id );
                    if( renewalObj.Renewal_Status__c != null 
                        // SIR - D-00016018 when Renewal Status is Month To Month
                        && ( renewalObj.Renewal_Status__c.EqualsIgnoreCase( Constants.RENEWAL_STATUS_LEASE_RENEWED )
      )) {
                        leaseRenewed = true;
                    }
                }
                    
                Rehab__c rehabObj = mapLeaseIdToRehab.get( leaseObj.Id );
                rehabObj.Stage__c = leaseRenewed ? Constants.REHAB_STAGE_CLOSED_CANCELLED : Constants.REHAB_STAGE_HOLD_NOTIFICATION_CANCEL_UTILITY_TRANSFER;
                mapRehabsToUpdate.put( rehabObj.Id, rehabObj );
                
                if( rehabObj.Listing__c != null ) {
                    
                    mapListingsToUpdate.put( rehabObj.Listing__c, 
                                    new Listing__c( Id = rehabObj.Listing__c,
                                                    Status__c = leaseRenewed ? 'Cancelled' : Constants.LISTING_STATUS_HOLD_CURRENTLY_NOT_LEASABLE
                                                   ));
                }
            }
        }
    }

    // method to update Rehab Stage On Move Out Within 14 Days Update
    public static void doActionsOnMoveOutWithin14DaysUpdate( List<Tenant_Card__c> newLease, Map<Id, Tenant_Card__c> oldLeaseMap ) {

        Map<Id, Rehab__c> mapRehabsToUpdateOnMoveOutWithin14Days = new Map<Id, Rehab__c>();

        Set<Id> setLeaseIds = new Set<Id>();
        // loop over lease the Lease Records
        for( Tenant_Card__c leaseObj : newLease ){
            // when Move_Out_within_14_Days__c is changed
            if(leaseObj.Yardi_Active_Lease__c && Utility.hasFieldChanged( leaseObj, oldLeaseMap, 'Move_Out_within_14_Days__c' )) {
                setLeaseIds.add( leaseObj.Id );
            }
        }

        // query rehabs
        Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c> ( [ Select Renewal__r.Lease__c,
                                                                       Listing__r.Status__c,
                                                                       Listing__c,
                                                                       Renewal__c,
                                                                       Stage__c
                                                                From Rehab__c
                                                                Where Renewal__r.Lease__c in: setLeaseIds ] );

        Map<Id, Rehab__c> mapLeaseIdToRehab = new Map<Id, Rehab__c>();
        // loop over rehabs
        for( Rehab__c rehabObj : mapRehabs.values() ) {
            mapLeaseIdToRehab.put( rehabObj.Renewal__r.Lease__c, rehabObj );
        }

        // loop over lease the Lease Records
        for( Tenant_Card__c leaseObj : newLease ){

            // when Move_Out_within_14_Days__c is changed
            if( leaseObj.Yardi_Active_Lease__c && Utility.hasFieldChanged( leaseObj, oldLeaseMap, 'Move_Out_within_14_Days__c' )) {

                if( mapLeaseIdToRehab.containsKey( leaseObj.Id ) ) {
                    Rehab__c rehabObj = mapLeaseIdToRehab.get( leaseObj.Id );
                    // when Move_Out_within_14_Days__c  is true
                    if( leaseObj.Move_Out_within_14_Days__c ) { //Flag is set
                        // If the stage happens to be in a HOLD or some other status we want to leave the stage as it was,
                        // regardless of the moveout flag
                        if (rehabObj.Stage__c == Constants.REHAB_STAGE_NOTIFICATION_RECEIVED) {
                            rehabObj.Stage__c = Constants.REHAB_STAGE_READY_TO_SCHEDULE_MOI_UTILITY_TRANSFER;
                            mapRehabsToUpdateOnMoveOutWithin14Days.put( rehabObj.Id, rehabObj );
                        }
                    }
                    else {  // Flag is cleared
                        // Since the flag can be cleared 2 ways we have to make sure to
                        // only backtrack the Stage if the Stage was in the READY_TO_SCHEDULE stage
                        // The flag can be cleared by either clearing the move out date/notice date
                        // and a workflow will clear the flag
                        // OR if the notice date is CHANGED to a date which is now > 14 days out
                        // another workflow will clear the flag.
                        // However, when the notice date is cleared, this moves the status back to a "HOLD" status
                        // and we don't want the "HOLD" status change to be undone
                        if (rehabObj.Stage__c == Constants.REHAB_STAGE_READY_TO_SCHEDULE_MOI_UTILITY_TRANSFER) {
                            rehabObj.Stage__c = Constants.REHAB_STAGE_NOTIFICATION_RECEIVED;
                            mapRehabsToUpdateOnMoveOutWithin14Days.put( rehabObj.Id, rehabObj );
                        }
                    }

                }
            }
        }

        // update rehabs
        if( mapRehabsToUpdateOnMoveOutWithin14Days.size() > 0 ) {
            update mapRehabsToUpdateOnMoveOutWithin14Days.values();
        }
    }

    //Method modified by Saurabh kumar (09/06/2016) lease linking issue : D-00016125
    //Method modified by Poonam Bhargava (05/12/2016)- D-00015384
    //Method to update New_Renewed_Lease__c on old Renewal record
    public static void updateNewRenewedLeaseOnRenewal(List<Tenant_Card__c> newLease){
    
        //Set to hold Residence ids
        Set<Id> setOfResidenceIds = new Set<Id>();

        //Map to hold Renewal Id with Renewal record
        Map<Id, Renewal__c> mapRenewalsToUpdate = new Map<Id, Renewal__c>();

        //Loop over Lease Records
        for(Tenant_Card__c leaseObj : newLease){
            
            //Check for fileds values on Lease record and Populate set with residence ids
            if(leaseObj.Yardi_Active_Lease__c && leaseObj.Lease_Term__c != null && leaseObj.Lease_Term__c >= 6 && leaseObj.Residence__c != null)
                setOfResidenceIds.add(leaseObj.Residence__c);
        }
        
        //Check for set size
        if(setOfResidenceIds.size() > 0){
        
            //Query renewal records and populate renewal map
            Map<Id, Renewal__c> mapRenewals = new Map<Id, Renewal__c>([Select Id, Lease__r.Residence__c, Lease_End_Date__c,
                                                                        Lease_Start_Date__c,Lease__r.First_Last_Name__c ,
                                                                        Lease__r.tCode_LastName__c From Renewal__c
                                                                        Where Lease__c != null
                                                                        And Lease__r.Residence__c !=: null
                                                                        And Lease__r.Residence__c IN : setOfResidenceIds
                                                                        And Bad_Data__c =: false
                                                                        And New_Renewed_Lease__c =: null
                                                                        And Lease_End_Date__c !=: null
                                                                        And Lease_Start_Date__c !=: null order by Lease_End_Date__c DESC 
                                                                    ]);

            //Initialize map to hold Residence Id with list of Renewal records
            Map<Id, List<Renewal__c>> mapResidenceIdToListOfRenewals = new Map<Id, List<Renewal__c>>();

            //Check for map mapRenewals size
            if(mapRenewals.size() > 0 ){
            
                //Loop over renewals records
                for(Renewal__c renewal : mapRenewals.values()){

                    //Check map mapResidenceIdToListOfRenewal contains key or not and populate map with the renewal records 
                    if(!(mapResidenceIdToListOfRenewals.containsKey(renewal.Lease__r.Residence__c)))
                        mapResidenceIdToListOfRenewals.put(renewal.Lease__r.Residence__c, new List<Renewal__c>{renewal});
                    else
                        mapResidenceIdToListOfRenewals.get(renewal.Lease__r.Residence__c).add(renewal);  
                }       
            }
            
            //Check for map mapResidenceIdToListOfRenewal size
            if(mapResidenceIdToListOfRenewals.size() > 0){
            
                //Loop over Lease Records
                for( Tenant_Card__c leaseObj : newLease){
                
                    //When Lease_Term__c is greater than equals to 6
                    if(leaseObj.Lease_Term__c != null && leaseObj.Lease_Term__c >= 6 && leaseObj.Residence__c != null){
    
                        //Check map for key      
                        if(mapResidenceIdToListOfRenewals.containsKey(leaseObj.Residence__c)){
                     
                            //Loop over renewal records
                            for(Renewal__c renewal : mapResidenceIdToListOfRenewals.get(leaseObj.Residence__c)) {
                                System.debug('lease Start date on renewal ' + renewal.Lease_Start_Date__c + ' lease End date on Lease' + leaseObj.Lease_End_Date__c);
                                
                                //Check for fields values on renewal records and populate map mapRenewalToUpdate
                                if(renewal.Lease_End_Date__c < leaseObj.Lease_From_Date__c 
                                   && renewal.Lease__r.First_Last_Name__c == leaseObj.First_Last_Name__c && (leaseObj.tCode_LastName__c == null || renewal.Lease__r.tCode_LastName__c == leaseObj.tCode_LastName__c)){
                                  // System.assertEquals('status', 'lease end date on renewal ' + renewal.Lease_End_Date__c + ' lease Start date on Lease' + leaseObj.Lease_From_Date__c);
                                    mapRenewalsToUpdate.put(renewal.Id, new Renewal__c(Id = renewal.Id, New_Renewed_Lease__c = leaseObj.Id));
                                    break;
                                }
                            }
                        }
                    }
                }   
            }   
        }
            
        //Check for map mapRenewalToUpdate size and perform update operation on renewal records
        if(mapRenewalsToUpdate.size() > 0 ) 
            update mapRenewalsToUpdate.values();
     }   
    
    /**
    * @author Ashish Verma
    * @date 9-Feb-2015
    * @description Method used to update the date fields based on Lease end date
    */
     public static void updateRenewals(List<Tenant_Card__c> updatedLease, Map<Id, Tenant_Card__c> mapOldTenantCards){
            
        // declare set to hold all Lease Ids
         Set<Id> LeaseIds = new Set<Id>();
         
        // fetch only those Lease records whose Lease_End_Date__c is modified or changed
        for(Tenant_Card__c ren : updatedLease ) {
            if(ren.Yardi_Active_Lease__c && ren.Lease_End_Date__c != null && ren.Lease_End_Date__c != mapOldTenantCards.get(ren.Id).Lease_End_Date__c) {
                LeaseIds.add(ren.Id);
            }
        }
         
         List<Renewal__c> renewalList = new List<Renewal__c>();
        
         if(LeaseIds.size()> 0 ){
         
           renewalList= [SELECT Id, First_Contact_Notice_Due_Date__c, Second_Contact_Due__c, Third_Notice_Due_Date__c, Fourth_Contact_Due_Date__c,
                       Lease_End_Date__c, Lease__r.Lease_End_Date__c, Notice_to_Vacate_Due_Date__c FROM Renewal__c where Lease__c IN :LeaseIds ];  
            
            // update Renewal records based on Lease Expiration Date
       for(Renewal__c newRen : renewalList) {
          System.debug('The New Renewal is' + newRen);
          Date dt = newRen.Lease__r.Lease_End_Date__c;
          //Check if lease end date is not null
          if(dt != null){
              newRen.First_Contact_Notice_Due_Date__c = dt.addDays(-120);
              newRen.Second_Contact_Due__c = dt.addDays(-90);
              newRen.Third_Notice_Due_Date__c = dt.addDays(-60);
              newRen.Fourth_Contact_Due_Date__c = dt.addDays(-30);
              newRen.Notice_to_Vacate_Due_Date__c = dt.addDays(-30);
          }
       }
         }

         if(renewalList.size()> 0) {
           update renewalList;
         }
         system.debug('after renewal' + renewalList);   
    }
    
    /**
     *  @description    :   This method is to check whenever a new Lease is being inserted than , 
                            Update the Resulting Lease field on the the Latest Listing record if exists OR  if resulting lease is being updated 
                            populate resulting lease rent and resulting housing rent of  connected  listing both on insert and update.
     * 
     *  @args           :   List of lease , map of lease
     * 
     *  @return         :   void
     * 
     **/
    public static void populateResultingLeaseOnListing(List<Tenant_Card__c> leaseRecords , Map<Id, Tenant_Card__c> oldmap) {
        
        //Map to Hold the Residense Id with new Latest lease 
         Map<Id, Tenant_Card__c> mapResidenseWithRecentLease = new Map<Id, Tenant_Card__c>();
        //Map to Hold the Lease Id and Lease with Resulting lease being updated
         Map<Id ,Tenant_Card__c> mapLeaseIdwithResultingLeaseupdated = new Map<Id,Tenant_Card__c>();
        //List of Liatings to be updated
         List<Listing__c> listings = new List<Listing__c>();
        
        
        //Loop through the Lease records, get the related Related Residense first
        for(Tenant_Card__c lease : leaseRecords) {
          
          if(lease.Yardi_Active_Lease__c){
          
            //check if lease being updated
              if(oldmap !=null && oldmap.containsKey(lease.id)){
                  
                  if(utility.hasFieldChanged(lease, oldmap,'Lease_Rent__c') || utility.hasFieldChanged(lease, oldmap,'Housing_Rent__c')){
                      mapLeaseIdwithResultingLeaseupdated.put(lease.id ,new Tenant_Card__c(id = lease.id, Lease_Rent__c = lease.Lease_Rent__c ,Housing_Rent__c= lease.Housing_Rent__c));
                  }
                  
              }
              //when lease being inserted
              //Check for the Residense and add in map 
             else if(lease.Residence__c != null)
                  mapResidenseWithRecentLease.put(lease.Residence__c, new Tenant_Card__c(id = lease.id, Lease_Rent__c = lease.Lease_Rent__c ,Housing_Rent__c= lease.Housing_Rent__c));  
          }   
        }
        
        //Action when new lease is being insertd 
        if(!mapResidenseWithRecentLease.isEmpty()){
            //Get the Most recent lease records from the related Lease records
            Set<Id> leaseIds = new Set<Id>();
            
            //Get all the Lease where these Lease Records are marked as Previsous Lease Records
            for(Residence__c residense : [Select Id, Most_Recent_Lease__c from Residence__c where Id IN: mapResidenseWithRecentLease.keySet()]) {
                
                //Loop through the records and populate the Populate the Set of Lease Records
                leaseIds.add(residense.Most_Recent_Lease__c);
            }
            
            
            //Get all the Listing records where Lease is stamped as Previous Lease
            for(Listing__c listing : [Select Id,Status__c, Residence__c ,Resulting_Lease__c,Resulting_Lease_s_Lease_Rent__c,Resulting_Lease_Housing_Rent__c from Listing__c where Residence__c IN: mapResidenseWithRecentLease.keySet() AND (Previous_Lease__c IN: leaseIds OR Previous_Lease__c = null) ]) {
                
                //Get the Residense Related to this Lease
                if(mapResidenseWithRecentLease.containsKey(listing.Residence__c) && listing.Resulting_Lease__c == null) {
                     
                    //Set Resulting lease
                    if(listing.Status__c!=null && listing.status__c.equalsIgnoreCase('Leased')){
                    listing.LeaseAfterListing__c =  mapResidenseWithRecentLease.get(listing.Residence__c).id;
                    listing.Resulting_Lease__c = mapResidenseWithRecentLease.get(listing.Residence__c).id;
                    listing.Resulting_Lease_s_Lease_Rent__c = mapResidenseWithRecentLease.get(listing.Residence__c).Lease_Rent__c;
                    listing.Resulting_Lease_Housing_Rent__c = mapResidenseWithRecentLease.get(listing.Residence__c).Housing_Rent__c;
                    System.debug('mapResidenseWithRecentLease.get(listing.Residence__c).id----'+mapResidenseWithRecentLease.get(listing.Residence__c).id);
                    }
                    //if listing status is not leased and a new lease created then storing that lease to leaseAfterlisting variable , 
                   
                    else   
                    { 
                        listing.LeaseAfterListing__c =  mapResidenseWithRecentLease.get(listing.Residence__c).id;
                    }
                    
                    listings.add(listing);
                }
            }
        
        }
        
        //Action when a Resulting lease is being updated 
        if(!mapLeaseIdwithResultingLeaseupdated.isEmpty()){
            
           for(Listing__c listing : [Select Id ,Resulting_lease__c,Resulting_Lease_s_Lease_Rent__c,Resulting_Lease_Housing_Rent__c from Listing__c where Resulting_lease__c IN :mapLeaseIdwithResultingLeaseupdated.keySet()]){
            
                  listing.Resulting_Lease_s_Lease_Rent__c =  mapLeaseIdwithResultingLeaseupdated.get(listing.Resulting_lease__c).Lease_Rent__c;
                  listing.Resulting_Lease_Housing_Rent__c =  mapLeaseIdwithResultingLeaseupdated.get(listing.Resulting_lease__c).Housing_Rent__c;
                  listings.add(listing);
            
           }
            
            
        }
        if(listings.size() > 0)
            update listings;
    }
    
    /**
     *  @description  :  Method to sink the "YRR Move Out date" whenever the rehab's "Move-out Date" field is updated.
     * 
     *  @args      :  New list of lease, map of old lease
     * 
     *  @return      :  Void
     * 
  **/
  public static void  updateMoveOutDateBasedOnRehab(List<Tenant_Card__c> newLeaseList , Map<Id,Tenant_Card__c> mapOldLease) {
      
    //Set to hold the Lease Ids
    Set<Id> setLeaseIds = new Set<Id>();
    
    //Loop through Trigger.new list 
    for(Tenant_Card__c lease : newLeaseList) {
        
      //Check for update condition and populate set 
      if(lease.Yardi_Active_Lease__c && lease.Move_Out_Date__c != mapOldLease.get(lease.Id).Move_Out_Date__c)
          setLeaseIds.add(lease.Id);
    }
        
    //List to hold the Listing records to be updated
    List<Listing__c > listToUpdateListings = new List<Listing__c >();
        
        //Check for set size
        if(setLeaseIds.size() > 0) {
        
            //Query through Listing records
            for(Listing__c li : [SELECT Id, YRR_Move_Out_Date__c, Rehab__c, Rehab__r.Move_Out_Date__c 
                                  FROM Listing__c WHERE Rehab__r.Renewal__r.Lease__c != null AND Rehab__r.Renewal__r.Lease__c IN : setLeaseIds ]) {
                
                //Check YRR Move Out Date field values on listing and rehab
                If(li.YRR_Move_Out_Date__c != li.Rehab__r.Move_Out_Date__c ) {
                    
                    //Populate the listing's YRR_Move_Out_Date__c field with rehab's Move_Out_Date__c field
                    li.YRR_Move_Out_Date__c = li.Rehab__r.Move_Out_Date__c;
                    
                    //Popoulate the list listToUpdateListings
                    listToUpdateListings.add(li);
                }
            }
        }
        
        //Check for the size
        //Update the  Listings records
        if(listToUpdateListings.size() > 0)
            update listToUpdateListings;    
    }
    
    
   /**
     *  @description  :  Method to create a Lease Data Integrity record when a new lease is created.
     * 
     *  @args      :   New list of lease
     * 
     *  @return      :  Void
     *  
     *  created by   : Saurabh kumar  (7/28/2015) 
     * 
  **/
  /** public static void  createLeaseDataIntegrityRecord (List<Tenant_Card__c> newLeaseList) {
      
    List<Lease_Data_Integrity__c> listLDIToCreate = new List<Lease_Data_Integrity__c>();
    //Loop through Trigger.new list 
    for(Tenant_Card__c lease : newLeaseList) {
        
      //Adding new Lease data integrity record
     Lease_Data_Integrity__c LDI = new Lease_Data_Integrity__c();
                             LDI.Lease__c  = lease.id;
                             LDI.Portfolio__c = lease.Portfolio__c;
                             LDI.All_Page_s_present__c ='Yes';
                             LDI.Documents_available_in_S3__c ='Yes';
                             LDI.Rent_in_Yardi_match_Lease_Doc__c ='Yes';
                             LDI.Terms_in_Yardi_match_Lease_Doc__c ='Yes';                      
                             LDI.Documents_available_in_S3__c ='Yes';
                             LDI.File_Naming_Convention_Correct__c ='Yes';
                             LDI.Signature_s_present__c ='Yes';
                             LDI.Not_a_negative_Lease_Term__c ='Yes';
                             LDI.Document_Legible__c ='Yes';
                             LDI.Document_Opens_properly__c ='Yes';
                            if( lease.Lease_From_Date__c == null || lease.Lease_End_Date__c == null || (((lease.Lease_End_Date__c.Year() - lease.Lease_From_Date__c.Year())*12 + lease.Lease_End_Date__c.month()- lease.Lease_From_Date__c.month()) < 19))  {
                                            LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c ='N/A';   
                            }else{
                                            LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c ='Yes';
                            }                    
                            
      listLDIToCreate.add(LDI);
      
    }       
    if(!listLDIToCreate.isEmpty())
    {
      insert listLDIToCreate; 
    }
        
    }**/
    
  
    
   
      
    /**
     *  @description  :  Method to update lease data integrity records based on lease changes
     * 
     *  @args      :    New list of lease, old map 
     * 
     *  @return      :  Void
     *  
     *  created by   : Saurabh kumar  (8/19/2015) : this trigger method will fire only on update of lease record
     * 
  **/
  
 /**  public static void populateLDIRecordsBasedOnLease(List<Tenant_Card__c> newLease , Map<Id, Tenant_Card__c> oldMap){
    
    Map<Id , Tenant_Card__c> mapIdtoLeaseValueChanged = new Map<Id , Tenant_Card__c>();
    List<Lease_Data_Integrity__c >  listLDItoUpdate = new List<Lease_Data_Integrity__c>();
    //checking if lease terms has changed 
    for(Tenant_Card__c lease : newLease){
        
        if(oldmap != null && oldmap.containskey(lease.id) && ( oldmap.get(lease.id).Lease_End_Date__c != lease.Lease_End_Date__c || oldmap.get(lease.id).Lease_From_Date__c != lease.Lease_From_Date__c ) ){
            
         mapIdtoLeaseValueChanged.put(lease.id , lease);
            
            
        }
        
     }
     
     for(Lease_Data_Integrity__c LDI : [select id , lease__c ,Rent_Bump_in_Yardi_match_Lease_Doc__c from Lease_Data_Integrity__c where lease__c In :mapIdtoLeaseValueChanged.keyset()]){
        Integer monthDifference = null;
        if(mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_End_Date__c!=null && mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_From_Date__c !=null)
         monthDifference = (mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_End_Date__c.year() - mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_From_Date__c.year())*12 + mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_End_Date__c.month()- mapIdtoLeaseValueChanged.get(LDI.lease__c).Lease_From_Date__c.month();
        
        if( (monthDifference ==null )|| ( monthDifference < 19 && LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c !=null && !LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c.equalsIgnoreCase('N/A')))
        {
            LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c = 'N/A';
            listLDItoUpdate.add(LDI);
        }
        
        if( monthDifference !=null &&monthDifference >= 19  && LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c !=null && LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c.equalsIgnoreCase('N/A') ){
            LDI.Rent_Bump_in_Yardi_match_Lease_Doc__c = 'Yes';
            listLDItoUpdate.add(LDI);
        }
        
     }
     
     if(!listLDItoUpdate.isEmpty()){ 
         update listLDItoUpdate;
     }
    
  }**/
  
  
    //Added by Poonam Bhargava(03/18/2016)- D-00015112 
    /**
    * @description    :   Method to populate Lease End Date nad Lease Start Date on App Track records
    *
    * @arg            :   List of new Listing , map of old Listing 
    *
    * @return         :   Void
    **/
    public static void populateFieldsonAppTrackFromLease(List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease){
    
        //Initialize the list of App Track
        List<Tenant_App__c> tenantApps = new List<Tenant_App__c>();
        
        //Listing to be Blank Updated to Calculate Day Days to Re-Resident on App Track :D-00016788 
        Map<Id ,Listing__c> listingHavingResultingLease = new Map<Id ,Listing__c>();
        //Set to hold Lease Id
        Set<Id> setLeaseId = new Set<Id>();
        
        //loop overe lease records
        for(Tenant_Card__c lease : newLease){
        
            //Check for null value and populate set with lease ids  
            if( lease.Yardi_Active_Lease__c && (mapOfOldLease.get(lease.Id).Lease_End_Date__c != lease.Lease_End_Date__c 
                              || mapOfOldLease.get(lease.Id).Lease_From_Date__c != lease.Lease_From_Date__c)){
               setLeaseId.add(lease.Id);                    
      }           
        }
    
        //Check for set size
        if(setLeaseId.size() > 0){
        
           //Loop over app track records
            for(Tenant_App__c app : [Select Id, Lease_End_Date__c, Lease_Start_Date__c, Listing__c, Listing__r.Resulting_Lease__c,
                                        Listing__r.Resulting_Lease__r.Lease_End_Date__c, Listing__r.Resulting_Lease__r.Lease_From_Date__c
                                        From Tenant_App__c Where Listing__c != null AND Listing__r.Resulting_Lease__c != null
                                        AND Listing__r.Resulting_Lease__c IN : setLeaseId]) {
            
                //Check for fields values 
                if(app.Lease_End_Date__c != app.Listing__r.Resulting_Lease__r.Lease_End_Date__c || app.Lease_Start_Date__c != app.Listing__r.Resulting_Lease__r.Lease_From_Date__c){
                    
                    //Populate fields values on app track
                    app.Lease_End_Date__c = app.Listing__r.Resulting_Lease__r.Lease_End_Date__c;
                    app.Lease_Start_Date__c = app.Listing__r.Resulting_Lease__r.Lease_From_Date__c;
                       
                    //Add into list
                    tenantApps.add(app);  
                }
                //adding listing for blank update 
                listingHavingResultingLease.put(app.Listing__c ,new Listing__c(id = app.Listing__c));
            }
        }
        
        //Check for list size and perform update operation
        if(tenantApps.size() > 0) {
        
            //Bypass the App Track Trigger
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = false;
            
            //Perform Update operation on App Track Record
            update tenantApps;
            
            //App Track trigger on
            Tenant_App_TriggerHelper.EXECUTE_APPTRACK_TRIGGER = true;
        } 
           
        if(!listingHavingResultingLease.isEmpty()){
          update  listingHavingResultingLease.values();
        }         
    }

    //Added by Poonam Bhargava(10/13/2016)- D-00016239
    /**
    * @description    :   Method to create Renewal record when Lease record is inserted
    *
    * @arg            :   List of new Listing
    *
    * @return         :   Void
    **/
    public static void createRenewalOnLeaseInsertion(List<Tenant_Card__c> newLease){
    
        //Initialize the list of Renewals
        List<Renewal__c> renewals = new List<Renewal__c>();
        
        //Loop overe lease records
        for(Tenant_Card__c lease : newLease){
        
            //Prasad: D-00017507
            if(!lease.Portfolio__r.SWAY__c && lease.Yardi_Active_Lease__c){
                //Creating the instance of Renewal and populate renewal fields value
                Renewal__c renewal = new Renewal__c();
                renewal.Lease__c = lease.Id;
                renewal.Portfolio__c = lease.Portfolio__c;
                    
                //Check the field value on lease and then populate the renewal fields
                if(lease.Month_to_Month__c){
                    renewal.Renewal_Status__c = Constants.RENEWAL_STATUS_MONTH_TO_MONTH;    
                    renewal.MTM_Extension_Reason__c = Constants.MTM_EXTENSION_REASON;
                } else {
                    
                    //Check to calculate the days and populate fields accordingly
                    if(lease.Lease_End_Date__c != null && Date.today().daysBetween(lease.Lease_End_Date__c) > 120)
                        renewal.Renewal_Status__c = Constants.RENEWAL_STATUS_DAYS;  
                    else
                        renewal.Renewal_Status__c = Constants.RENEWAL_STATUS_OPEN;      
                }
        
                //Add instance into list
                renewals.add(renewal);
            }
        }
        
        //Check for renewal list size and perform the insert operation on Renewals
        if(renewals.size() > 0)
            insert renewals;    
    }
    
    //Saurabh Kumar - D-00017164
    public static void checkForLeaseRenewal(List<Tenant_Card__c> newLease ,Map<Id,Tenant_Card__c> oldMap){
        // 5/24/2017 : check condition if lease updated with Month to Month and Notice date = null then call cancelRehabAndListing if Rehab/listing is associated with it 
        set<Id> setRehabIds = new Set<Id>();
        set<Id> leaseIds = new Set<Id>();
        Map<Id,Id> mapRehabwithListingIds = new Map<Id,Id>();
        
        for(Tenant_Card__c leaserec : newLease){
            if(leaserec.Yardi_Active_Lease__c && Utility.hasFieldChanged(leaserec, oldMap, 'Month_to_Month__c') && leaserec.Notice_Date__c == null){
                leaseIds.add(leaserec.Id);
            }
        }
        
        System.debug('** Lease to Cancel Rehab/Listing ** '+leaseIds);
        
        if(leaseIds.isEmpty())
          return;
          
        for(Rehab__c rehab : [Select Id, listing__c from rehab__c where Renewal__r.lease__c in : leaseIds and (rehab__c.stage__c !=: Constants.REHAB_STAGE_CLOSED_CANCELLED or listing__r.status__c !=: Constants.CANCELLED)]){
                mapRehabwithListingIds.put(rehab.id, rehab.listing__c);
        }
        
        System.debug('** Map Rehab/Listing ** '+leaseIds);
        
         if(!mapRehabwithListingIds.isEmpty()){
            cancelRehabAndListing(mapRehabwithListingIds);
         }
    }
    
    //Saurabh Kumar - D-00017164
    public static void cancelRehabAndListing(Map<Id,Id> mapRehabwithListing){
        // 5/24/2017 : fetch Rehab and Listing records with status and update to Closed-Cancelled and Cancelled respectively if not already
        List<Listing__c> updateListing = new List<Listing__c>();
        List<Rehab__c> updateRehab = new List<Rehab__c>();
        
        for(Id rehab : mapRehabwithListing.keySet()){
                updateRehab.add(new Rehab__c(Id = rehab, Stage__c = Constants.REHAB_STAGE_CLOSED_CANCELLED));
                updateListing.add(new Listing__c(Id = mapRehabwithListing.get(rehab), status__c = Constants.CANCELLED));
            }
            
        System.debug('** Update Rehab ** '+updateRehab);
        System.debug('** Update Listing ** '+updateListing);
        
        if(!updateListing.isEmpty()){
            update updateListing;
        }
        if(!updateRehab.isEmpty()){
            update updateRehab;
        }
    }

    //Added by Poonam Bhargava(06/19/2017) - D-00017170
    /**
    * @description    :   Method to populate "AppTrack Owner" field from Application Tracking record
    *
    * @arg            :   List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease
    *
    * @return         :   Void
    **/
    public static void populateAppTrackOwnerfieldFromAppTrack(List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease){
    
        //Set to hold the Lease Ids
        Set<Id> setOfLeasIds = new Set<Id>();
  
        //List of Lease to be updated
        List<Tenant_Card__c> leaseToBeUpdated =  new List<Tenant_Card__c>();
        
        //Loop over Lease records
        for(Tenant_Card__c tC : newLease){
      
            //Check for insert/update case and populate set with Lease Ids
            if(tC.Yardi_Active_Lease__c && tC.AppTrack_Owner__c != mapOfOldLease.get(tC.Id).AppTrack_Owner__c)
                setOfLeasIds.add(tC.Id);        
        }
      
        //Check for set size
        if(setOfLeasIds.size() > 0){
      
            //Map to hold Lease Id as key and Listing record as value  
            Map<Id, Listing__c>  mapOfListings = new Map<Id, Listing__c>();
        
            //Loop over listing records
            for(Listing__c  li : [Select Id, Actual_AppTrack__c, Actual_AppTrack__r.OwnerId, Resulting_Lease__c, 
                                        Resulting_Lease__r.AppTrack_Owner__c from Listing__c
                                        where Actual_AppTrack__c != null 
                                        and Resulting_Lease__c != null
                                        and Resulting_Lease__c IN : setOfLeasIds Order By LastModifiedDate DESC]){
        
                //Check map ffor key and populate according with Lease Id and Listing record
                if(!mapOfListings.containsKey(li.Resulting_Lease__c))  
                    mapOfListings.put(li.Resulting_Lease__c, li);
            }
        
            //Check for map size
            if(mapOfListings.size() > 0){
            
                //Get the key Prefix of Queue 
                String keyPrefix = Schema.getGlobalDescribe().get('Group').getDescribe().getKeyPrefix();
            
                //Loop over Lease records
                for(Tenant_Card__c tC : newLease){
                  
                    //Check map for key
                    if(mapOfListings.containsKey(tC.Id) && mapOfListings.get(tC.Id).Actual_AppTrack__r.OwnerId !=null){
                        
                        //String variable to hold App track owner id as string  
                        String appOwner = String.valueOf(mapOfListings.get(tC.Id).Actual_AppTrack__r.OwnerId);
                            
                        //Check for eligible criteria of AppTrack Owner on Lease record
                        if((!appOwner.contains(keyPrefix))
                                && mapOfListings.get(tC.Id).Resulting_Lease__r.AppTrack_Owner__c != mapOfListings.get(tC.Id).Actual_AppTrack__r.OwnerId){
                                
                            //Populate AppTrack Owner on Lease record from Application Tracking and add into list
                            leaseToBeUpdated.add(new Tenant_Card__c(Id = tC.Id, AppTrack_Owner__c = mapOfListings.get(tC.Id).Actual_AppTrack__r.OwnerId));              
                        }  
                    }
                }  
            }
        }
      
        //Check for list size and perform update operation
        if(leaseToBeUpdated.size() > 0)
            update leaseToBeUpdated;
    } 

    //Added by Poonam Bhargava(09/16/2017)
    /**
    * @description    :   Method to populate "Residence" field On Lease from Portfolio record
    *
    * @arg            :   List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease
    *
    * @return         :   Void
    **/
    public static void populateResidenceFromProperty(List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease){

        //Set to hold Portfolio Ids
        Set<Id> setOfPortfolio = new Set<Id>();

        //Loop over trigger.new list
        for(Tenant_Card__c tC : newLease){
        
            //Check for null condition and populate set with portfolio ids
            if(tC.Yardi_Active_Lease__c &&  tC.Portfolio__c != null)
                setOfPortfolio.add(tC.Portfolio__c);
        }
        
        //Check for set size
        if(setOfPortfolio.size() > 0){
        
            //Populate map to hold portfolio id as key and portfolio as value
            Map<Id, Property__c> mapOfPortfolio = new Map<Id, Property__c>([Select Id, Residence__c from Property__c where Residence__c != null and Id IN : setOfPortfolio]);
            
            //Loop over Lease records
            for(Tenant_Card__c lease : newLease){
                
                //Check for null condition
                if(lease.Portfolio__c != null && mapOfPortfolio.containsKey(lease.Portfolio__c)){
                    
                    //Check for eligible criteria and populate lease field accordingly
                    if(lease.Residence__c != mapOfPortfolio.get(lease.Portfolio__c).Residence__c)
                        lease.Residence__c = mapOfPortfolio.get(lease.Portfolio__c).Residence__c;
                }           
            }
        }
    }   
    
    //Added by Poonam Bhargava(01/19/2018) - D-00017712
    /**
    * @description    :   Method to update Resulting_Lease__c field on Listing records In case of Bad Data marked Rewsulting Lease found on Listing
    *
    * @arg            :   List<Tenant_Card__c> newLease
    *
    * @return         :   Void
    **/
    public static void updateBedDataResultingLeaseOnListing( List<Tenant_Card__c> newLease) {
        
        //Set to hold the Portfolio Ids
        Set<Id> setOfPortfolioIds = new Set<Id>();
        
        //Map to hold the Last Lease Id and New Lease Id
        Map<Id, Id> mapOfLastLeaseAndNewLease = new Map<Id, Id>();
    
    List<Listing__c> listingsToUpdate = new List<Listing__c>();
                
        //Loop to hold the Portfolios Id
        for(Tenant_Card__c lease : newLease) {
            
            if(lease.Yardi_Active_Lease__c && lease.Portfolio__c != null )
                setOfPortfolioIds.add(lease.Portfolio__c);
        }
        
        if(setOfPortfolioIds.size() > 0) {
          
          //Loop over the Portfolios to update last lease on it
          for(Property__c property : [Select Id, (Select Id, Portfolio__c, Bad_Data__c, Lease_From_Date__c, Lease_End_Date__c  
                                      From Leases__r Where Id NOT IN : newLease AND Bad_Data__c =: true ORDER BY CreatedDate DESC Limit 1) 
                                      From Property__c Where Id IN :  setOfPortfolioIds]) {
              
              if(property.Leases__r.size() > 0) {
                
                //Loop over the newLease
                for(Tenant_Card__c lease : newLease) {
                
                    //Loop over the last most recent lease on Portfolio
                    for(Tenant_Card__c Lastlease : property.Leases__r) {
                        
                        //Check for Lease Start Date And Lease End Date
                        if(Lastlease.Portfolio__c == lease.Portfolio__c && Lastlease.Lease_From_Date__c == lease.Lease_From_Date__c && Lastlease.Lease_End_Date__c == lease.Lease_End_Date__c) {
              
                            mapOfLastLeaseAndNewLease.put(Lastlease.Id, lease.Id);
                        }
                    }
                }
              } 
          }
        }
        
        if(mapOfLastLeaseAndNewLease.size() > 0) {
          
          //Loop over the Listing records
          for(Listing__c listing : [Select Id, Resulting_Lease__c From Listing__c Where Resulting_Lease__c IN : mapOfLastLeaseAndNewLease.keySet()]) {
          
            listingsToUpdate.add(new Listing__c(Id = listing.Id, Promoted_Lease__c = listing.Resulting_Lease__c, Resulting_Lease__c = mapOfLastLeaseAndNewLease.get(listing.Resulting_Lease__c)));
          }
        }
                     
        //Null check on listing list to be update
        if(listingsToUpdate.size() > 0)
            update listingsToUpdate;
    }
    
    //Added by Poonam Bhargava(04/02/2018) - D-00017863
    /**
    * @description    :   Method to update Previous Lease Rent and Previous Housing Rent field on Listing from Previous Lease
    *
    * @arg            :   List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease
    *
    * @return         :   Void
    **/
    public static void populateLeaseRentFieldsOnListing(List<Tenant_Card__c> newLease, map<Id, Tenant_Card__c> mapOfOldLease){
        
        //Set to hold Lease Ids
        Set<Id> setOfLeaseIds = new Set<Id>();
        
        //List to hold Listing to be updated
        List<Listing__c> ListingToBeUpdated = new List<Listing__c>(); 
        
        for(Tenant_Card__c tC : newLease){
            
            //Check for update case and populate set wwith Lease Ids
            if(tC.Yardi_Active_Lease__c && mapOfOldLease != null && (tC.Lease_Rent__c != mapOfOldLease.get(tC.Id).Lease_Rent__c 
                                            || tC.Housing_Rent__c != mapOfOldLease.get(tC.Id).Housing_Rent__c)){
                setOfLeaseIds.add(tC.Id);   
            }
        }
        
        //Check for set size
        if(setOfLeaseIds.size() > 0 ){
        
            //Retrieve Listing records 
            for(Listing__c listing : [Select Id, Previous_Lease__c, Previous_Lease_Rent__c, Previous_Housing_Rent__c, Previous_Lease__r.Lease_Rent__c, 
                                        Previous_Lease__r.Housing_Rent__c from Listing__c where Previous_Lease__c IN : setOfLeaseIds]){
            
                //Check for eligible criteria and populate Listing Fields
                if(listing.Previous_Lease_Rent__c != listing.Previous_Lease__r.Lease_Rent__c)
                    listing.Previous_Lease_Rent__c = listing.Previous_Lease__r.Lease_Rent__c;
                
                if(listing.Previous_Housing_Rent__c != listing.Previous_Lease__r.Housing_Rent__c)
                    listing.Previous_Housing_Rent__c = listing.Previous_Lease__r.Housing_Rent__c;   
                
                //Add Listing records in the list
                ListingToBeUpdated.add(listing);    
            }           
        }
        
        //Check for Listi size and perform update operation
        if(ListingToBeUpdated.size() > 0)
            update ListingToBeUpdated;      
     }     
}