/**
* @author Prashant Wayal
* @date 18-Feb-2015
* @description Helper class for Trigger_Renewal trigger
* @modified by : Saurabh kumar (5/27/2016) D-00015600
* Modified by : Poonam Bhargava (06/19/2017) - D-00017170
* Modified by : Saurabh Kumar (06/19/2017) - D-00017164
*/
public with sharing class Trigger_RenewalHelper{
    
    /**
    * @description Method to update renewal related rehab records 
    * @params List of Renewal Records
    */
    public static void updateRehabs(List<Renewal__c> renewalList){
        Set<String> renewalIdSet = new Set<String>();
        for(Renewal__c renewal: renewalList)
            renewalIdSet.add(renewal.Id);
            
        //Get all rehab records related to renewals and update
        List<Rehab__c> rehabList = [select Id from Rehab__c where Renewal__c IN: renewalIdSet];
        if(!rehabList.isEmpty())
            update rehabList;
    }
    
    //This method is to close cancel all open turn rehab when a new lease renewed
    public static void closeCancelRehabsOnLeaseRenewal(List<Renewal__c> newRenewalList, Map<Id, Renewal__c> oldRenewalMap) {
    
        List<Renewal__c> allowedRenewals = new List<Renewal__c>();
        
        //loop overe renewal records
        for( Renewal__c renewalObj : newRenewalList )   {
        
            if( Trigger.isUpdate 
                && renewalObj.Renewal_Status__c != null 
                && renewalObj.Renewal_Status__c.equalsIgnoreCase( Constants.RENEWAL_STATUS_LEASE_RENEWED )
                &&  renewalObj.Renewal_Status__c != oldRenewalMap.get(renewalObj.Id).Renewal_Status__c ) {
                if( renewalObj.Lease__c != null ) { 
                    allowedRenewals.add( renewalObj );
                }
            }
        }
    
        if( allowedRenewals.size() > 0 ) {
            
             // query Turn record type
            List<RecordType> rtList = [Select Id, Name, SObjectType, DeveloperName
                                        From RecordType where (DeveloperName = 'TURN' OR DeveloperName = 'Post_Acquisition_TIP' OR DeveloperName = 'Disposition')
                                        And SObjectType = 'Rehab__c' AND IsActive = true 
                                        ORDER BY DeveloperName Limit 3
                                       ];
            
            Id postAcqTIPRecordTypeId;
            Id turnRecordTypeId;
        
            for( RecordType rt : rtList ) {
                
                if( rt.DeveloperName.equalsIgnoreCase( 'TURN' )) {
                    turnRecordTypeId = rt.Id;
                }
                else if( rt.DeveloperName.equalsIgnoreCase( 'Post_Acquisition_TIP' )) {
                    postAcqTIPRecordTypeId = rt.id;
                }
            }
            
            Map<Id, Rehab__c> mapRehabToUpdate = new Map<Id, Rehab__c>();
            Map<Id, Listing__c> mapListingToUpdate = new Map<Id, Listing__c>();
            
            if( turnRecordTypeId != null ) { 
                
               // query rehabs
               Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c> ( [ Select Renewal__r.Lease__c,
                                                                               Listing__r.Status__c,
                                                                               Listing__c,
                                                                               Renewal__c,
                                                                               Stage__c
                                                                        From Rehab__c
                                                                        Where Renewal__c in: allowedRenewals
                                                                        And Renewal__r.Lease__r.Notice_Date__c =: NULL
                                                                        AND RecordTypeId !=: NULL
                                                                        And ( RecordTypeId =: turnRecordTypeId
                                                                              OR RecordTypeId =: postAcqTIPRecordTypeId )
                                                                        AND (   Rehab_Status__c like 'Active%' 
                                                                                OR Rehab_Status__c like 'HOLD%' )
                                                                        ] );
                                                                        
                for( Rehab__c rehabObj : mapRehabs.values() ) {
                    
                    Rehab__c rehabObjToUpdate = new Rehab__c( Id = rehabObj.Id,
                                                              Stage__c = Constants.REHAB_STAGE_CLOSED_CANCELLED  );
                                                              
                    mapRehabToUpdate.put( rehabObjToUpdate.Id, rehabObjToUpdate );
                    if( rehabObj.Listing__c != null ) {
                        mapListingToUpdate.put( rehabObj.Listing__c, 
                                                 new Listing__c( Id = rehabObj.Listing__c,
                                                                Status__c = 'Cancelled'
                                                               ));
                    }
                }
            }
                
            if( mapRehabToUpdate.size() > 0 ) {
                
                update mapRehabToUpdate.values();
                Trigger_RehabHandler.isTrigger_RehabCalld = false;
            }
            
            if( mapListingToUpdate.size() > 0 ) {
                 
                update mapListingToUpdate.values();
            }
        }
     }
    
     /**
      * @Description    :   Method for create rehab records based on renewal status.
      *
      * @arg            :   List of new renewal, map of old renewal.
      *
      * @return         :   Void
    **/
    //commented based on D-00015600 :- This method has been depricated 
 /*   public static void createRehabBasedOnRenewalStatus(List<Renewal__c> newRenewals, map<Id, Renewal__c> mapOldRenewals) {
    
        //Initialize list of rehab to be inserted
        List<Rehab__c> listOfRehabToBeInserted = new List<Rehab__c>();
        
        //Map to hold renewal records with Portfolio Id
        Map<Id, List<Renewal__c>> mapPortfolioWithRenewals= new Map<Id, List<Renewal__c>>();
        
        //Check for null
        if(newRenewals != null) {
        
            //Loop through Trigger.new
            for(Renewal__c renew : newRenewals) {
            
                //Checking and validting for eligibility and then accordingly populating the renewal map
                if(String.isNotBlank(renew.Renewal_Status__c ) && renew.Renewal_Status__c == 'Not Renewed - Notice' && 
                (mapOldRenewals == null || mapOldRenewals.get(renew.Id).Renewal_Status__c != renew.Renewal_Status__c )) {
                    
                    //Check map for key and populate accordingly
                    if(mapPortfolioWithRenewals.containsKey(renew.Id))
                        mapPortfolioWithRenewals.get(renew.Portfolio__c).add(renew);
                    else
                        mapPortfolioWithRenewals.put(renew.Portfolio__c, new List<Renewal__c>{renew});
                }
            }
            
            //Fecth the dispostion relared to Portfolio
            Map<Id, Disposition__c> mapDispostion = new Map<Id, Disposition__c>( [ Select Portfolio__c 
                                                            From Disposition__c
                                                            Where Portfolio__c IN: mapPortfolioWithRenewals.keySet()
                                                            And BX_Approval_of_Sale__c = 'Yes'
                                                            And IH_Approval_of_Sale__c = 'Yes'
                                                            ] );
                                                                        
                                                                   
            Map<Id, Disposition__c> mapPortfolioIdToDispostion = new Map<Id, Disposition__c>();
            for( Disposition__c dis : mapDispostion.values() ) {
                mapPortfolioIdToDispostion.put( dis.Portfolio__c, dis );
            }
            
            //Checking for map size
            if(mapPortfolioWithRenewals.size() > 0 ) {
                
                //Initialize Map of portfolios and populate 
                Map<Id, Property__c> mapPortfolios = new Map<Id, Property__c>([SELECT ID, Residence__c From Property__c 
                                                                               Where Id IN : mapPortfolioWithRenewals.keyset()]);
                
                //Retrieve record from record type
                List<RecordType> listRecordType = [Select Id from RecordType Where SObjectType = 'Rehab__c' And DeveloperName = 'Disposition' And isActive = True];
                
                //Check for  Record Type list size
                if(listRecordType.size() > 0) {
                    
                    //Loop through keyset
                    for(Id propId : mapPortfolioWithRenewals.keySet()) {
                    
                        //Check for id in map
                        if(mapPortfolioWithRenewals.containsKey(propId) && mapPortfolioIdToDispostion.containsKey(propId)) {
                            
                            //Loop through Renewal
                            for(Renewal__c renewal : mapPortfolioWithRenewals.get(propId)) {
                            
                                //Populate Rehab record and add to list
                                listOfRehabToBeInserted.add(new Rehab__c(RecordTypeId = listRecordType[0].Id, 
                                                                            Stage__c= 'Notification Received', 
                                                                            Home__c = mapPortfolios.get(propId).Residence__c,
                                                                            Portfolio__c = propId));
                            }
                        }
                    }
                }
            }
            
            //Check for rehab list size and insert 
            if(listOfRehabToBeInserted.size() > 0)
                insert listOfRehabToBeInserted; 
        }   
    }*/
    
    // Saurabh Kumar - (5/24/2017) - D-00017164
    public static void updateListingWhenLeaseRenewed(List<Renewal__c> listRenewal ,Map<Id, Renewal__c> oldMap){
        // 5/24/2017 : new renewed lease updated , renewal status change to Lease Renewed or Month to Month
        // Check if it is related to any listing or rehab then pass rehab Id to method cancelRehabAndListing
        
        Set<Id> renewalIds = new Set<Id>();
        Map<Id,Id> mapRehabwithListingIds = new Map<Id,Id>();
        
        for(Renewal__c renewal : listRenewal){
            if((Utility.hasFieldChanged(renewal, oldMap, 'New_Renewed_Lease__c') && renewal.New_Renewed_Lease__c != null) 
                || (Utility.hasFieldChanged(renewal, oldMap, 'Renewal_Status__c') 
                    && (renewal.Renewal_Status__c == constants.RENEWAL_STATUS_LEASE_RENEWED 
                         || renewal.Renewal_Status__c == constants.RENEWAL_STATUS_MONTH_TO_MONTH)))
            {
                renewalIds.add(renewal.Id);
            }
        }
        
        System.debug('** Renewal Ids ** '+renewalIds);
        
        if(renewalIds.isEmpty())
            return;
            
        for(Rehab__c rehab : [Select Id, listing__c from rehab__c where Renewal__c in : renewalIds and 
                                (stage__c !=: Constants.REHAB_STAGE_CLOSED_CANCELLED or 
                                 listing__r.status__c !=: Constants.CANCELLED)])
        {
            mapRehabwithListingIds.put(rehab.id, rehab.listing__c);
            System.debug('** Map Rehab/Listing Ids ** '+mapRehabwithListingIds);
        }
        
        
        
        if(!mapRehabwithListingIds.isEmpty()){
            LeaseTriggerHelper.cancelRehabAndListing(mapRehabwithListingIds);
        }
    }

    //Added by Poonam Bhargava (06/19/2017)- D-00017170
    /**
      * @Description    :   Method to populate Renewal Coordinator on related 'New (Renewed) Lease'.
      *
      * @arg            :   List<Renewal__c> newRenewals, map<Id, Renewal__c> mapOldRenewals.
      *
      * @return         :   Void
    **/
    public static void populateRenewalCoordinatorOnLease(List<Renewal__c> newRenewals, map<Id, Renewal__c> mapOldRenewals) {
    
        //Map to hold Lease Id with Lease record
        Map<Id, Tenant_Card__c> mapOfLease = new Map<Id, Tenant_Card__c>();
        
        //Loop Over Renewal records (check for insert/update/delete case)
        for(Renewal__c re : newRenewals != null ? newRenewals :  mapOldRenewals.values()) {
            
            //Check the criteria for insert condition and populate Lease map accordingly
            if(mapOldRenewals == null && re.New_Renewed_Lease__c != null)
                mapOfLease.put(re.New_Renewed_Lease__c, new Tenant_Card__c(Id = re.New_Renewed_Lease__c, Renewal_Coordinator__c = null));
            
            //Check the eligible criteria for update when 'New (Renewed) Lease' or 'Renewal Coordinator / APM' field is updated
            if(newRenewals != null && mapOldRenewals != null && (re.New_Renewed_Lease__c != mapOldRenewals.get(re.Id).New_Renewed_Lease__c 
                                                                    || re.Renewal_Coordinator__c != mapOldRenewals.get(re.Id).Renewal_Coordinator__c)) {
                
                //Check whether New (Renewed) Lease is not null and populate lease map accordingly
                if(re.New_Renewed_Lease__c != null)
                    mapOfLease.put(re.New_Renewed_Lease__c, new Tenant_Card__c(Id = re.New_Renewed_Lease__c, Renewal_Coordinator__c = null));
                
                //Check field New (Renewed) Lease is updated from not null to null value and populate map
                if(mapOldRenewals.get(re.Id).New_Renewed_Lease__c != null)
                    mapOfLease.put(mapOldRenewals.get(re.Id).New_Renewed_Lease__c, new Tenant_Card__c(Id = mapOldRenewals.get(re.Id).New_Renewed_Lease__c, Renewal_Coordinator__c = null));
            }
            
            //Delete case when field 'New (Renewed) Lease' is removed and populate map accordingly
            if(newRenewals == null && re.New_Renewed_Lease__c != null)
                mapOfLease.put(re.New_Renewed_Lease__c, new Tenant_Card__c(Id = re.New_Renewed_Lease__c, Renewal_Coordinator__c = null));   
        }   
        
        //Check for map mapOfLease size
        if(mapOfLease.size() > 0){
            
            //Retrieve Lease records with the child Renewal records
            for(Tenant_Card__c tC : [Select Id, Renewal_Coordinator__c, 
                                        (Select Id, Renewal_Coordinator__c from Renewals__r order by LastModifiedDate DESC LIMIT 1) 
                                        from Tenant_Card__c where Id IN : mapOfLease.keySet()]){

                //Check for child (Renewal) record size, lease as key in the map and populate Lease map with values accordingly
                if(tC.Renewals__r.size() > 0 && mapOfLease.containsKey(tC.Id))
                    mapOfLease.get(tC.Id).Renewal_Coordinator__c = tC.Renewals__r[0].Renewal_Coordinator__c;    
            }
        }
        
        //Check for map size and perform update operation on map
        if(mapOfLease.size() > 0 ){
            
            //Bypass Lease trigger
            LeaseTriggerHelper.EXECUTE_LEASE_TRIGGER = false;
            
            //Update Lease records
            update mapOfLease.values(); 
            
            //Set flag as true to keep on the lease trigger
            LeaseTriggerHelper.EXECUTE_LEASE_TRIGGER =  true;
        }
                  
    } 
}