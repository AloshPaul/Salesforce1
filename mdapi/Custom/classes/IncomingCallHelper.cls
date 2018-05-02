/**
 *   Description     : Helper class for Trigger on Incoming_Calls__c object
 *
 *   Created By      :
 *
 *   Created Date    :
 *
 *   Revision Logs   :  v_1.0 - Created
 *                      v_1.1 - Modfied By Abhinav Sharma
 *                      v_1.2 - Rajesh Shah - Updated Logic for Incoming Call Sharing
 *                      v_1.3 - Saurabh Kumar - Updated Method updateShowingSharing and created a new method  createShowingSharingForIhLeadAgents
 *                      v_1.4 - Poonam Bhargava - Added a new method 'populateSameStoreFromPortfolio' - D-00016574
 *                      V_1.5 - Poonam Bhargava(12/16/2016) - Added a new method'populateAppTrackFieldFromIHLead' - D-00016575 
 *                      V_1.6 - Prasad Added new method 'PopulateListingData' (D-00016943)
 *                      V_1.7 - Poonam Bhargava - D-00017048
 *                      V_1.8 - Poonam Bhargava - Added a new method - "markCloseDuplicateIHLead" (07/31/2017) - D-00017394
 *                      V_1.9 - Poonam Bhargava - Modified method "updateListingTotalIncomingCallCount" - D-00017395
 **/
public without sharing class IncomingCallHelper {
     
     
   //Static Variable To stop recurssive calling of Some methods 
     Private Static Boolean Is_Recursive = False;     
   // Get all the Incoming Call records whose Listing Agent/Listing has changed and create a Showing Share for them
    public static void updateShowingSharing(Map<Id, Incoming_Calls__c> newIncomingMap, Map<Id, Incoming_Calls__c> oldIncomingMap){
       
      //Checking if it is recursion call of this method
       if(Is_Recursive)
        return ;
       
       Map<Id , Set<Id>> mapListingIdToNewLeadListingAgents =  new Map<ID , Set<ID>>();
       Map<Id  ,Set<Id>> mapListingIdToOldLeadListingAgents =  new Map<ID , Set<ID>>();
      //iterating over  Updated  IH Leads Record and adding New and Deleted Listing Agents in Map with Listing id 
       for(Incoming_Calls__c incoming : newIncomingMap.values()){
        
            if(incoming.Listing_Agent__c != oldIncomingMap.get(incoming.Id).Listing_Agent__c
                    ||  incoming.Listing__c != oldIncomingMap.get(incoming.Id).Listing__c) {
                
                   
                     if(incoming.Listing__c != null && incoming.Listing_Agent__c !=null){
                       
                        
                                if(!mapListingIdToNewLeadListingAgents.containsKey(incoming.Listing__c)){
                                    mapListingIdToNewLeadListingAgents.put(incoming.Listing__c , new Set<ID>{incoming.Listing_Agent__c});
                                    } else{
                                    mapListingIdToNewLeadListingAgents.get(incoming.Listing__c).add(incoming.Listing_Agent__c);
                                 }    
                        
                         
                        }
                      
                     if(oldIncomingMap.get(incoming.Id).Listing__c != null && oldIncomingMap.get(incoming.Id).Listing_Agent__c!=null ) {
                        
                                   if(mapListingIdToOldLeadListingAgents.containsKey(oldIncomingMap.get(incoming.Id).Listing__c)){
                                        mapListingIdToOldLeadListingAgents.get(oldIncomingMap.get(incoming.Id).Listing__c).add(oldIncomingMap.get(incoming.Id).Listing_Agent__c);
                                     }
                                     else{
                                        mapListingIdToOldLeadListingAgents.put(oldIncomingMap.get(incoming.Id).Listing__c , new Set<ID>{oldIncomingMap.get(incoming.Id).Listing_Agent__c});
                                     }
                              }
                    
                }
           }
           
         if(!mapListingIdToNewLeadListingAgents.isEmpty() || !mapListingIdToOldLeadListingAgents.isEmpty() ){
            
            // calling method to create/delete manual share for Showing_share records 
            createShowingSharingForIhLeadAgents(mapListingIdToNewLeadListingAgents , mapListingIdToOldLeadListingAgents);
           
        }
         //updating  Is Recursive Field to True to stop recursion of this method 
           if(!Test.isRunningTest())
            Is_Recursive = True;  
      
      //  Now It is not required to create showing share for all Ih lead on updation of single one
       /* Set<Id> incomingIdSet = new Set<Id>();
        Set<Id> listingIdSet  = new Set<Id>();
        for(Incoming_Calls__c incoming : newIncomingMap.values()){
            if(incoming.Listing_Agent__c != oldIncomingMap.get(incoming.Id).Listing_Agent__c
                    || (incoming.Listing__c != null && incoming.Listing__c != oldIncomingMap.get(incoming.Id).Listing__c)) {
                
                incomingIdSet.add(incoming.Id);
                if(incoming.Listing__c != null) {
                    listingIdSet.add(incoming.Listing__c);
                }
                else if((incoming.Listing_Agent__c != oldIncomingMap.get(incoming.id).Listing_Agent__c) 
                        || (incoming.Listing__c !=  oldIncomingMap.get(incoming.id).Listing__c) ) {
                        
                        if( oldIncomingMap.get(incoming.Id).Listing__c != null ) {
                            listingIdSet.add(oldIncomingMap.get(incoming.Id).Listing__c);
                        }
                    
                }
            }
        }

        if(!incomingIdSet.isEmpty()) {
            List<Showing__c> showingList = new List<Showing__c>();

            showingList = [Select Call_Record_if_applicable__c, Agent_Name__c, Listing__c, OwnerId
                                                                from Showing__c
                                                                where   Call_Record_if_applicable__c in :incomingIdSet
                                                                or      Listing__c in :listingIdSet];
            if(!showingList.isEmpty())
                Trigger_ShowingHandler.updateShowingSharingRules(showingList);
        }
        */

    }

    // Checking if Listing Agent on Incomming Calls is not null or changed and adding values to the List accordingly
    public static void incomingSharing(List<Incoming_Calls__c> incomingList, Map<Id, Incoming_Calls__c> oldIncomingMap){
        
        Map<Id, Incoming_Calls__c> incomingCallMap = new Map<ID, Incoming_Calls__c>();
        for(Incoming_Calls__c incomingCall : IncomingList){
            if (oldIncomingMap == null && incomingCall.Listing_Agent__c == null) {
                //Nothing to do since it's a new Incoming Call with no listing agent
                continue;
            } else if(oldIncomingMap == null && (incomingCall.Listing_Agent__c != null || incomingCall.Listing__c != null))
                incomingCallMap.put(incomingCall.id, incomingCall);
            else if((incomingCall.OwnerId != oldIncomingMap.get(incomingCall.Id).OwnerId)
                        || (incomingCall.Listing_Agent__c != oldIncomingMap.get(incomingCall.Id).Listing_Agent__c)
                        || (incomingCall.Listing__c != oldIncomingMap.get(incomingCall.Id).Listing__c))
                incomingCallMap.put(incomingCall.id, incomingCall);
        }
        updateSharingRuleForIncomingCalls(incomingCallMap);
    }

    public static void updateSharingRuleForIncomingCalls(Map<Id, Incoming_Calls__c> incomingMap) {

        List<Incoming_Calls__Share> incomingCallShareToBeInserted = new List<Incoming_Calls__Share>();
        set<id> listingIds = new set<id>();

        // Looping throgh the Incomming Calls Records and adding the Listing Ids to a set
        for(Incoming_Calls__c incoming : incomingMap.values()){
            if(incoming.Listing__c != null)
                listingIds.add(incoming.Listing__c);
        }
        // Delete old sharing Rules
        List<Incoming_Calls__Share> incomingSharingForDelete = [Select Id from Incoming_Calls__Share
                                                                        where ParentId IN: incomingMap.keyset()
                                                                        AND RowCause = 'Manual'];
        if(incomingSharingForDelete.size() > 0)
            delete incomingSharingForDelete;

        // Creating a Map for Listing Records under Tenant_App
        Map<Id, Listing__c> listingMap = new Map<Id, Listing__c>([Select Id, Listing_Agent__c, Secondary_Agent__c from Listing__c
                                                                                                    where   Id IN: listingIds
                                                                                                    AND     Listing_Agent__c != null
                                                                                                    AND     Listing_Agent__r.isActive = true ]);


        for(Incoming_Calls__c incomingCall : incomingMap.values()){
            if(incomingCall.Listing_Agent__c != null && incomingCall.Listing_Agent__c != incomingCall.OwnerId){

                // Creating a new Sharing rule for Listing_Agent
                incomingCallShareToBeInserted.add(
                    new Incoming_Calls__Share(
                        ParentId        = incomingCall.Id,
                        UserOrGroupId   = incomingCall.Listing_Agent__c,
                        AccessLevel     = 'Edit'
                    )
                );
            }     
            
            if(incomingCall.Secondary_Agent_Id__c != null 
                && incomingCall.Secondary_Agent_Id__c != '' 
                && incomingCall.Secondary_Agent_Id__c != incomingCall.OwnerId){

                // Creating a new Sharing rule for Secondary_Agent__c
                incomingCallShareToBeInserted.add(
                    new Incoming_Calls__Share(
                        ParentId        = incomingCall.Id,
                        UserOrGroupId   = incomingCall.Secondary_Agent_Id__c,
                        AccessLevel     = 'Edit'
                    )
                );
            }
            
            // Insert sharing rule for Incoming_Calls.Listing__r.Listing_Agent__c
            if(incomingCall.Listing__c != null && listingMap.containsKey(incomingCall.Listing__c)
                    && listingMap.get(incomingCall.Listing__c).Listing_Agent__c != incomingCall.OwnerId) {
                // Create New Sharing record on change change of Listing. Listing_Agent
                incomingCallShareToBeInserted.add(
                    new Incoming_Calls__Share(
                        ParentId        = incomingCall.Id,
                        UserOrGroupId   = listingMap.get(incomingCall.Listing__c).Listing_Agent__c,
                        AccessLevel     = 'Edit'
                    )
                );
            }
            
            // Insert sharing rule for Incoming_Calls.Listing__r.Listing_Agent__c
            if(incomingCall.Listing__c != null && listingMap.containsKey(incomingCall.Listing__c)
                    && listingMap.get(incomingCall.Listing__c).Secondary_Agent__c != null
                    && listingMap.get(incomingCall.Listing__c).Secondary_Agent__c != incomingCall.OwnerId) {
                // Create New Sharing record on change change of Listing. Listing_Agent
                incomingCallShareToBeInserted.add(
                    new Incoming_Calls__Share(
                        ParentId        = incomingCall.Id,
                        UserOrGroupId   = listingMap.get(incomingCall.Listing__c).Secondary_Agent__c,
                        AccessLevel     = 'Edit'
                    )
                );
            }
        }
        // Inserting the List values to Database
        if(!incomingCallShareToBeInserted.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(incomingCallShareToBeInserted, false);
        }
    }

    public static void updateListingTotalIncomingCallCount(List<Incoming_Calls__c> incomingCallList, Map<Id, Incoming_Calls__c> oldIncomingMap) {

        Set<Id> listingIdSet = new Set<Id>();
        for(Incoming_Calls__c incomingCall : incomingCallList) {
            if (incomingCall.Listing__c == null) {
                continue;
            } else if(oldIncomingMap == null && incomingCall.Listing__c != null)
                listingIdSet.add(incomingCall.Listing__c);
            else if(incomingCall.Listing__c != oldIncomingMap.get(incomingCall.Id).Listing__c || incomingCall.Lead_Status__c != oldIncomingMap.get(incomingCall.Id).Lead_Status__c) {
                if(incomingCall.Listing__c != null)
                    listingIdSet.add(incomingCall.Listing__c);
                if(oldIncomingMap.get(incomingCall.Id).Listing__c != null)
                    listingIdSet.add(oldIncomingMap.get(incomingCall.Id).Listing__c);
            }
        }

        if(!listingIdSet.isEmpty()) {
            List<Listing__c> listingsForUpdate = new List<Listing__c>();
            Set<Id> listingIdProcessed = new Set<Id>();
            for(AggregateResult aggr : [Select COUNT(Id) cnt, Listing__c listingId
                                                                    from Incoming_Calls__c
                                                                    where Listing__c in :listingIdSet AND Lead_Status__c !=: Constants.LEAD_STATUS_AS_CLOSED_DUPLICATE //Added By Poonam Bhargava - D-00017395
                                                                    group by Listing__c]) {
                listingsForUpdate.add(new Listing__c(
                        Id = String.valueOf(aggr.get('listingId')),
                        Total_Incoming_Calls__c = Integer.valueOf(aggr.get('cnt'))
                    )
                );
                listingIdProcessed.add(String.valueOf(aggr.get('listingId')));
            }

            for(Id listingId : listingIdSet) {
                if(!listingIdProcessed.contains(listingId)) {
                    listingsForUpdate.add(new Listing__c(
                            Id = String.valueOf(listingId),
                            Total_Incoming_Calls__c = 0
                        )
                    );
                }
            }

            update listingsForUpdate;
        }
    }

    // method to update Time_to_Assignment_Minutes__c on Date_Time_Agent_Notified__c field update on Incoming_Calls__c object
    public static void updateTimeToAssignmentMinutes( List<Incoming_Calls__c> incomingCallList,
                                                      Map<Id, Incoming_Calls__c> oldIncomingMap) {

        Set<String> setRegionName = new Set<String>();

        // loop over incoming calls
        for( Incoming_Calls__c ihLead : incomingCallList ) {
            if( ihLead.Region__c != null ) {
                setRegionName.add( ihLead.Region__c );
            }
        }

        // query region
        Map<ID, Region__c> mapRegions = new Map<Id, Region__c>( [ Select Name,
                                                                         Call_Center_Business_Hours__c
                                                                  From Region__c
                                                                  Where Name in: setRegionName ]);
        Set<String> setBusinesHours = new Set<String>();

        Map<String, Region__c> mapRegionNameToRegion = new Map<String, Region__c>();
        // loop over regions
        for( Region__c region : mapRegions.values() ) {
            if( region.Call_Center_Business_Hours__c != null ) {
                setBusinesHours.add( region.Call_Center_Business_Hours__c );
                mapRegionNameToRegion.put( region.Name.trim().toLowerCase(), region );
            }
        }

        String defaultCallCenter = 'Call Center CST';

        // Query Business Hours
        List<BusinessHours> listBusinessHoursObj = [ SELECT Name
                                                     FROM BusinessHours
                                                     WHERE ( Name in: setBusinesHours
                                                             OR
                                                             Name =: defaultCallCenter)
                                                            And IsActive =: True
                                                    ];

        Map<String, BusinessHours> mapCallCenterToBusinessHours = new Map<String, BusinessHours>();
        for( BusinessHours bu : listBusinessHoursObj ) {
            mapCallCenterToBusinessHours.put( bu.Name.trim().toLowerCase(), bu );
        }

        // loop over incoming calls
        for( Incoming_Calls__c ihLead : incomingCallList ) {
            String callCenterBusinessHours;
            if( ihLead.Region__c != null && mapRegionNameToRegion.containsKey( ihLead.Region__c.trim().toLowerCase() ) ) {
                callCenterBusinessHours = mapRegionNameToRegion.get( ihLead.Region__c.trim().toLowerCase() ).Call_Center_Business_Hours__c;
            }

            if( callCenterBusinessHours != null && callCenterBusinessHours.trim().length() > 0 ) {
                callCenterBusinessHours = callCenterBusinessHours.trim().toLowerCase();
            }

            BusinessHours businessHoursObj;
            if( mapCallCenterToBusinessHours.containsKey(callCenterBusinessHours) ) {
                businessHoursObj = mapCallCenterToBusinessHours.get( callCenterBusinessHours );
            }
            // when business hours null for region then use default
            if( businessHoursObj == null ) {
                callCenterBusinessHours = defaultCallCenter.trim().toLowerCase();
                if( mapCallCenterToBusinessHours.containsKey( callCenterBusinessHours )) {
                    businessHoursObj = mapCallCenterToBusinessHours.get( callCenterBusinessHours );
                }
            }

            if( Utility.hasFieldChanged( ihLead, oldIncomingMap, 'Date_Time_Agent_Notified__c')
                || Utility.hasFieldChanged( ihLead, oldIncomingMap, 'Date_Time__c') ) {
                ihLead.Time_to_Assignment_Minutes__c = getTimeToAssignmentMinutes( ihLead, businessHoursObj );
            }
        }
    }

    // method to get business hours difference for TimeToAssignmentMinutes for Incoming_Calls__c
    private static Integer getTimeToAssignmentMinutes( Incoming_Calls__c ihLead, BusinessHours businessHoursObj ) {
         Integer timeToAssignmentMinutes = getBusinessHoursDifferenceInMinutes( businessHoursObj, ihLead.Date_Time__c, ihLead.Date_Time_Agent_Notified__c );
         return timeToAssignmentMinutes;
    }

    // method to get business hours difference between two Datetime values
    private static Integer getBusinessHoursDifferenceInMinutes( BusinessHours businessHoursObj, DateTime startDatetime , Datetime endDatetime ) {
         Integer differenceInMinutes;
         // when businessHoursObj is not null and businessHoursObj.Id is not null and startDatetime ad endDatetime is not null
         if( businessHoursObj != null && businessHoursObj.Id != null
             && startDatetime != null && endDatetime != null ) {
            differenceInMinutes = Integer.valueOf( Decimal.valueOf(BusinessHours.diff( businessHoursObj.Id, startDatetime, endDatetime ) / ( 1000 * 60 )).round());
         }
         return differenceInMinutes;
    }
    
    
   
   
    //method to sharing Showing with IH Lead Listing Agent  on Update Or create 
    Private static void createShowingSharingForIhLeadAgents(Map<Id , Set<Id>> mapListingIdToNewLeadListingAgents ,  Map<Id  ,Set<Id>> mapListingIdToOldLeadListingAgents){
        
        list<Showing__Share> listShowingShareToBeCreated            =   new list<Showing__Share>();
        list<Showing__Share> listShowingShareToBeDeleted            =   new list<Showing__Share>();
        Map<ID ,Set<ID>>     MapShowingIdWithSetOfAgentToBeRemoved  =   new Map<ID , Set<ID>>();
        Map<Id , Set<ID>> MapListingIdwithallListingAgentsOnIHLead  =    new Map<Id ,Set<ID>>();
        
        For(Incoming_calls__c IHlead : [Select id ,Listing__c,Listing_Agent__c 
                                        from  Incoming_calls__c where  Listing__c
                                        IN :mapListingIdToOldLeadListingAgents.keySet()]){
            
                 if(!MapListingIdwithallListingAgentsOnIHLead.containsKey(IHlead.Listing__c)){
                      MapListingIdwithallListingAgentsOnIHLead.put(IHlead.Listing__c , new Set<ID>{IHlead.Listing_Agent__c});
                 }else{
                      MapListingIdwithallListingAgentsOnIHLead.get(IHlead.Listing__c).add(IHlead.Listing_Agent__c);
                     }  
            
       }
      //retrieving Showing record on Mentioned listing 
      For(Showing__c sh  : [ select id , 
                             Listing__c , Listing__r.Listing_Agent__c ,
                             Agent_Name__c ,Call_Record_if_applicable__r.Listing_Agent__c 
                             from showing__c  
                             where Listing__c IN :mapListingIdToNewLeadListingAgents.keySet() 
                             OR Listing__c IN :mapListingIdToOldLeadListingAgents.keySet() ]){
        
        
                   //Showing id with Agent which Showing Share   need to be revoked 
                    if(mapListingIdToOldLeadListingAgents != null 
                         && mapListingIdToOldLeadListingAgents.containsKey(sh.listing__c)){
                 
                            
                            Set<ID> setOfAllListingAgentOnListing =   MapListingIdwithallListingAgentsOnIHLead != Null && MapListingIdwithallListingAgentsOnIHLead.containsKey(sh.listing__c) ? MapListingIdwithallListingAgentsOnIHLead.get(sh.listing__c) : new set<Id>();
                           
                            for(Id AgentIdRemoved  :  new List<Id>(mapListingIdToOldLeadListingAgents.get(sh.listing__c)) ){
                                
                                
                              
                                    if(AgentIdRemoved != sh.Listing__r.Listing_Agent__c 
                                         &&  AgentIdRemoved != sh.Agent_Name__c 
                                           && AgentIdRemoved != sh.Call_Record_if_applicable__r.Listing_Agent__c 
                                              && !setOfAllListingAgentOnListing.Contains(AgentIdRemoved) ){
                                                
                                       
                                        if(!MapShowingIdWithSetOfAgentToBeRemoved.containsKey(sh.id)) {
                                          MapShowingIdWithSetOfAgentToBeRemoved.put(sh.id , new set<ID>{AgentIdRemoved});
                                         }else{
                                            MapShowingIdWithSetOfAgentToBeRemoved.get(sh.id).add(AgentIdRemoved);
                                         }      
                                        
                                    }
                                  }
                               }
                      
                  //Inserting New Showing Share 
                  if(mapListingIdToNewLeadListingAgents!=null && mapListingIdToNewLeadListingAgents.ContainsKey(sh.Listing__c)){
                    
                     For(ID AgentIdToShare  :  new List<Id>(mapListingIdToNewLeadListingAgents.get(sh.listing__c)) ){
                        
                       listShowingShareToBeCreated.add(new Showing__Share(
                        ParentId        = sh.Id,
                        UserOrGroupId   = AgentIdToShare,
                        AccessLevel     = 'Edit'
                        )
                        );
                      }
                  
                   }
    
       }
       
          //Fetching Those Sharing_share record which need to be deleted
          if(!MapShowingIdWithSetOfAgentToBeRemoved.isEmpty()){
             
                     for(Showing__Share showingShare : [Select ParentId ,UserOrGroupId from Showing__Share 
                                                                Where RowCause ='Manual' 
                                                                and ParentId IN :MapShowingIdWithSetOfAgentToBeRemoved.keySet() ]){
                     
                        if(MapShowingIdWithSetOfAgentToBeRemoved.containskey(showingShare.ParentId )
                             && MapShowingIdWithSetOfAgentToBeRemoved.get(showingShare.ParentId ).contains(showingShare.UserOrGroupId)){
                             
                             listShowingShareToBeDeleted.add(showingShare);
                                                        
                         }                          
                                                        
                      }                                 
                                                
          }
         if(!listShowingShareToBeDeleted.isEmpty()){
            Database.delete(listShowingShareToBeDeleted, false);
         }  
         
         if(!listShowingShareToBeCreated.isEmpty()){
            Database.SaveResult[] srList = Database.insert(listShowingShareToBeCreated, false);
            System.debug('**** SaveResult is ' +srList +'*******' );
         }    
    }
    
    //Added by Poonam Bhargava(12/10/2016) - D-00016574
    /**
      * @description    :   Method to populate IH Lead field 'Portfolio Same Store' from Portfolio
      *
      * @arg            :   List of new IH Lead, map of old IH Lead
      *
      * @return         :   Void
    **/
    public static void populateSameStoreFromPortfolio(List<Incoming_Calls__c> newIHLead, map<Id, Incoming_Calls__c> mapOfOldIHLead) {
    
        //Initialize set to hold Listing Ids
        Set<Id> setListingIds = new Set<Id>();
        
        //Loop over IH Lead records
        for(Incoming_Calls__c lead : newIHLead){
            
            //Check for insert/update case
            if(lead.Listing__c != null && (mapOfOldIHLead == null || mapOfOldIHLead.get(lead.Id).Listing__c != lead.Listing__c
                                            || lead.Portfolio_Same_Store__c != mapOfOldIHLead.get(lead.Id).Portfolio_Same_Store__c))
        
            //Populate set with listing ids
            setListingIds.add(lead.Listing__c);
        }
         
        //Check for set size
        if(setListingIds.size()> 0){
    
            //Initialize map to hold listing record with listing IDs
            Map<Id, Listing__c> mapListing = new Map<Id, Listing__c>([Select Id, Portfolio__c, Portfolio__r.SameStore__c
                                                                        From Listing__c Where Id IN : setListingIds]);
    
            //Loop over IH Lead records
            for(Incoming_Calls__c lead : newIHLead){
            
                //Check for map size and for eligibility criteria
                if(lead.Listing__c != null && mapListing.containsKey(lead.Listing__c) && mapListing.get(lead.Listing__c).Portfolio__c != null){
            
                    //Populate fields on IH Lead
                    if(lead.Portfolio_Same_Store__c != mapListing.get(lead.Listing__c).Portfolio__r.SameStore__c)  
                        lead.Portfolio_Same_Store__c = mapListing.get(lead.Listing__c).Portfolio__r.SameStore__c; 
                } 
            }
        }
    }
    
    //Added by Poonam Bhargava(12/16/2016) - D-00016575
    /**
      * @description    :   Method to populate App Track fields 'IH Lead Source' and 'Lead Channel' from IH Lead object
      *
      * @arg            :   List of new IH Lead, map of old IH Lead 
      *
      * @return         :   Void
    **/
    public static void populateAppTrackFieldFromIHLead(List<Incoming_Calls__c> newIHLead, map<Id, Incoming_Calls__c> mapOfOldIHLead) {
    
        //Initialize set to hold IH Lead Ids
        Set<Id> setLeadIds = new Set<Id>();
        
        //Initialize the list of App Track
        List<Tenant_App__c> tenantApps = new List<Tenant_App__c>();
        
        //Loop over IH Lead records
        for(Incoming_Calls__c lead : newIHLead){
        
            //Check for insert/update case    
            if(lead.Source_New__c != mapOfOldIHLead.get(lead.Id).Source_New__c
                || lead.Lead_Channel__c != mapOfOldIHLead.get(lead.Id).Lead_Channel__c)
        
                //Populate set with IH Lead ids
                setLeadIds.add(lead.Id);
        }
         
        //Check for set size
        if(setLeadIds.size()> 0){
    
            //Loop over app track records
            for(Tenant_App__c app : [Select Id, IH_Lead_Source__c,Lead_Channel__c, Lead__c, Lead__r.Source_New__c,Lead__r.Lead_Channel__c 
                                        From Tenant_App__c Where Lead__c IN : setLeadIds]){
    
                //Populate field 'IH Lead Source' on App Track 
                if(app.IH_Lead_Source__c != app.Lead__r.Source_New__c)       
                    app.IH_Lead_Source__c = app.Lead__r.Source_New__c; 
                
                //Populate field 'Lead Channel' on App Track 
                if(app.Lead_Channel__c != app.Lead__r.Lead_Channel__c)       
                    app.Lead_Channel__c = app.Lead__r.Lead_Channel__c;
                
                //Add into list 
                tenantApps.add(app);
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
        }
    }
    
  //Prasad's changes. D-00016943
    public static void PopulateListingData(List<Incoming_Calls__c> IHLeads, map<Id, Incoming_Calls__c> OldIHLeadsMap) {
    
        //String LISTING_STATUS_LEASED = 'Leased';
        
        map<string, Incoming_Calls__c> IHLeadsMap = new map<string, Incoming_Calls__c>();
        Set<Id> setListingIds = new Set<Id>();
        String ListingRegion = '';
        
        for(Incoming_Calls__c IC : IHLeads) {
            if(IC.Listing__c != null && (OldIHLeadsMap == null || IC.Listing__c != OldIHLeadsMap.get(IC.Id).Listing__c))
                setListingIds.add(IC.Listing__c);
        }
        
        if(setListingIds.size() > 0){
            
            map<Id, Listing__c> LinkedListingMap = new map<Id, Listing__c>([Select Id, Status__c, Portfolio__r.OwnerId, Secondary_Agent__c, Listing_Agent__c,
                                                                            Region__c from Listing__c where Id IN: setListingIds]);
            
            if(LinkedListingMap.size() > 0){
            
                for(Incoming_Calls__c IH : IHLeads) {
                
                    if(IH.Listing__c != null && (IH.First_Name__c != null || IH.Last_Name__c != null) && (IH.Email__c != null || IH.Phone__c != null)){
                        
                        if(LinkedListingMap.containsKey(IH.Listing__c) 
                            && (LinkedListingMap.get(IH.Listing__c).Status__c == Constants.LISTING_STATUS_DOWN_IN_REHAB 
                                || LinkedListingMap.get(IH.Listing__c).Status__c == Constants.LISTING_STATUS_HOLD_CURRENTLY_NOT_LEASABLE 
                                || LinkedListingMap.get(IH.Listing__c).Status__c == Constants.CANCELLED)){
                            
                            if(String.isNotBlank(LinkedListingMap.get(IH.Listing__c).Portfolio__r.OwnerId)  && 
                                String.valueOf(LinkedListingMap.get(IH.Listing__c).Portfolio__r.OwnerId).startsWith('005')){
                                
                                IH.Listing_Agent__c = LinkedListingMap.get(IH.Listing__c).Portfolio__r.OwnerId;
                                IH.Notification_Agent__c = LinkedListingMap.get(IH.Listing__c).Portfolio__r.OwnerId;
                            }
                        }
                        else {
                            
                            if(LinkedListingMap.containsKey(IH.Listing__c)){
                                //Update IH Lead 'Notification_Agent__c' field from Linked Listing record.
                                if(LinkedListingMap.get(IH.Listing__c).Secondary_Agent__c != null && IH.Notification_Agent__c != LinkedListingMap.get(IH.Listing__c).Secondary_Agent__c)
                                  IH.Notification_Agent__c = LinkedListingMap.get(IH.Listing__c).Secondary_Agent__c;
                                else if(LinkedListingMap.get(IH.Listing__c).Secondary_Agent__c == null && IH.Notification_Agent__c != LinkedListingMap.get(IH.Listing__c).Listing_Agent__c)
                                    IH.Notification_Agent__c = LinkedListingMap.get(IH.Listing__c).Listing_Agent__c;
                                else if(LinkedListingMap.get(IH.Listing__c).Secondary_Agent__c == null && LinkedListingMap.get(IH.Listing__c).Listing_Agent__c == null)
                                    IH.Notification_Agent__c = null;
                                
                                if(LinkedListingMap.get(IH.Listing__c).Region__c != null)
                                    ListingRegion = LinkedListingMap.get(IH.Listing__c).Region__c.trim();
                                
                                IH.Listing_Agent__c = LinkedListingMap.get(IH.Listing__c).Listing_Agent__c; 
                            }           
                        }   
                        
                         //Modified under SIR D-00017394
                        if(IH.Notification_Agent__c != null && IH.Lead_Status__c != Constants.LEAD_STATUS_AS_CLOSED_DUPLICATE){
                            
                            IH.Send_Lead_to_Agent__c = true;
                            IH.AutoClosed__c = true;
                        }
                    }  
                }
            }      
        }
    }
    
    //Depricated under SIR D-00017394
    //Added by Bhavi Sharma - D-00017048
    /**
      * @description    :   Method to send the lead to Agent
      *
      * @arg            :   List of new IH Lead, map of old IH Lead 
      *
      * @return         :   Void
    **/
   /** public static void sendLeadToAgent(List<Incoming_Calls__c> IHLeads) {
        
        Sched_SendLeadToAgent fRH = new Sched_SendLeadToAgent();
        
        DateTime dtm = Datetime.now().addMinutes(1);
        String hour = String.valueOf(dtm.hour());
        String min = String.valueOf(dtm.minute()); 
        String ss = String.valueOf(dtm.second());
        String year = String.valueOf(dtm.year());
        String month = String.valueOf(dtm.month());
        String day = String.valueOf(dtm.day());
        
        List<Incoming_Calls__c> lstIHLeads = new List<Incoming_Calls__c>();
        
        for(Incoming_Calls__c IH : IHLeads) {
            
            if(IH.Notification_Agent__c != null 
                && (IH.First_Name__c !=null || IH.Last_Name__c != null) 
                && (IH.Email__c != null || IH.Phone__c != null) 
                && IH.Notification_Agent__c != null){
                
                lstIHLeads.add(IH);
            }
        }
        fRH.ihLeads = lstIHLeads;
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ?  ' + year;
        System.schedule('FutureRequestHandler ' + String.valueOf(Datetime.now()) + Math.random(), nextFireTime, fRH);
    }**/
    
    
    //Added by Poonam Bhargava(03/30/2017) - D-00017048
    /**
      * @description    :   Method to format Phone Number on IH Lead object
      *
      * @arg            :   List of new IH Lead, map of old IH Lead 
      *
      * @return         :   Void
    **/
    public static void removePhoneformatingOnIHLead(List<Incoming_Calls__c> newIHLead, map<Id, Incoming_Calls__c> mapOfOldIHLead){
    
        //Loop over IH Lead records
        for(Incoming_Calls__c lead : newIHLead){
        
            //Check for null in Phone field    
            if(lead.Phone__c != null){
             
                //String varibale to hold phone number   
                String phone = '';

                //List varibale hold phone number
                List<String> phonenumbers = lead.Phone__c.split('');
                
                //Loop over phone string
                for(String phoneDigit : phonenumbers){
                
                    //Check if phone number is numeric value or not and add into string variable
                    if(phoneDigit.isNumeric())
                        phone += phoneDigit; 
                }
                
                if(phone.length() > 10)
                    phone = phone.right(10);
                    
                //Populate Phone field on IH Lead object
                lead.UnformattedNumber__c = phone;     
            }
        }   
    }
    
   //Added by Poonam Bhargava(07/31/2017) - D-00017394
    /**
      * @description    :   Method to mark the IH Lead record as duplicate based on the fileds FirstName/LastName/Email/Phone and the existing record created is in last 48 hours
      *
      * @arg            :   List of new IH Lead
      *
      * @return         :   Void
    **/
    public static void markCloseDuplicateIHLead(List<Incoming_Calls__c> newIHLead){
        
        //Set to hold Listing Ids
        Set<String> setListingIds = new Set<String>();
        
        //Map to hold ListingId as Key and FirstName/LastName/Email/Phone as value
        Map<Id, Set<String>> mapIHLeadWithFName = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapIHLeadWithLName = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapIHLeadWithEmail = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapIHLeadWithPhone = new Map<Id, Set<String>>();

        //Loop over IH Lead records
        for(Incoming_Calls__c lead : newIHLead){
            
            //Check fo null and populate set with listing id
            if(lead.Listing__c != null)
                setListingIds.add(lead.Listing__c);     
        }
        
        //Check for set size
        if(setListingIds.size() > 0){
            
            //Current time
            DateTime currentDTM = DateTime.Now();
            currentDTM = currentDTM.addHours(-(Integer.valueOf(Label.DUPLICATE_RULE_LAST_CREATED_HOURS)));
            
            //Loop over IH Lead records
            for(Incoming_Calls__c iC : [Select Id, First_Name__c, Last_Name__c, UnformattedNumber__c, Email__c, Listing__c, CreatedDate, Source_New__c from Incoming_Calls__c 
                                            where Listing__c IN : setListingIds AND Lead_Status__c !=: Constants.LEAD_STATUS_AS_CLOSED_DUPLICATE AND CreatedDate >=: currentDTM]){
                
                //Check for key in map and populate map accordingly with key
                if(!mapIHLeadWithFName.containsKey(iC.Listing__c))
                    mapIHLeadWithFName.put(iC.Listing__c, new Set<String>()); 
                    
                if(!mapIHLeadWithPhone.containsKey(iC.Listing__c))
                    mapIHLeadWithPhone.put(iC.Listing__c, new Set<String>()); 
                    
                if(!mapIHLeadWithEmail.containsKey(iC.Listing__c))
                    mapIHLeadWithEmail.put(iC.Listing__c, new Set<String>()); 
                    
                if(!mapIHLeadWithLName.containsKey(iC.Listing__c))
                    mapIHLeadWithLName.put(iC.Listing__c, new Set<String>());
                
                //Populate map with FirstName/LastName/Email/Phone      
                mapIHLeadWithFName.get(iC.Listing__c).add(iC.First_Name__c); 
                mapIHLeadWithPhone.get(iC.Listing__c).add(iC.UnformattedNumber__c); 
                mapIHLeadWithEmail.get(iC.Listing__c).add(iC.Email__c); 
                mapIHLeadWithLName.get(iC.Listing__c).add(iC.Last_Name__c); 
            }
            
            //Loop over IH Lead records
            for(Incoming_Calls__c lead : newIHLead){
            
                //Modified for the Rently - D-00017100
                //Check if the Existing lead
                if(lead.Listing__c != null && lead.Source_New__c != 'Rently'){
                
                    //Check for eligible criteria for duplicate ih lead record
                    if(((lead.First_Name__c != null && mapIHLeadWithFName.containsKey(lead.Listing__c) && mapIHLeadWithFName.get(lead.Listing__c).contains(lead.First_Name__c))
                            || (lead.Last_Name__c != null && mapIHLeadWithLName.containsKey(lead.Listing__c) && mapIHLeadWithLName.get(lead.Listing__c).contains(lead.Last_Name__c)))
                        && ((lead.Email__c != null && mapIHLeadWithEmail.containsKey(lead.Listing__c) && mapIHLeadWithEmail.get(lead.Listing__c).contains(lead.Email__c))
                            || (lead.UnformattedNumber__c != null && mapIHLeadWithPhone.containsKey(lead.Listing__c) && mapIHLeadWithPhone.get(lead.Listing__c).contains(lead.UnformattedNumber__c)))) {
                        
                        //Populate IH Lead fields value if Duplicate found 
                        lead.Lead_Status__c = Constants.LEAD_STATUS_AS_CLOSED_DUPLICATE;
                        lead.Agent_Lead_Status__c = Constants.AGENT_LEAD_STATUS_AS_CLOSED_DUPLICATE;
                        lead.AutoClosed__c = true;
                        lead.Automated_Duplicate__c = true;
                    }
                    
                    //Check for key in map and populate map accordingly with key
                    if(!mapIHLeadWithFName.containsKey(lead.Listing__c))
                        mapIHLeadWithFName.put(lead.Listing__c, new Set<String>()); 
                        
                    if(!mapIHLeadWithPhone.containsKey(lead.Listing__c))
                        mapIHLeadWithPhone.put(lead.Listing__c, new Set<String>()); 
                        
                    if(!mapIHLeadWithEmail.containsKey(lead.Listing__c))
                        mapIHLeadWithEmail.put(lead.Listing__c, new Set<String>()); 
                        
                    if(!mapIHLeadWithLName.containsKey(lead.Listing__c))
                        mapIHLeadWithLName.put(lead.Listing__c, new Set<String>());  
                    
                    //Populate map with FirstName/LastName/Email/Phone  
                    mapIHLeadWithFName.get(lead.Listing__c).add(lead.First_Name__c); 
                    mapIHLeadWithPhone.get(lead.Listing__c).add(lead.UnformattedNumber__c); 
                    mapIHLeadWithEmail.get(lead.Listing__c).add(lead.Email__c); 
                    mapIHLeadWithLName.get(lead.Listing__c).add(lead.Last_Name__c); 
                    
                }   
            }
        }
    }   
}