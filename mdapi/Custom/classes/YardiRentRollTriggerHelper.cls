/**
 *  Description     :   This class is helper class for Yardi Rent Roll object trigger
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   05/09/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 -  Abhinav Sharma - 7/10/2013 - New Method added(mostRecentYardiRentRollOnResidence) - D-00005982
 *                      V1_1.2 - Abhinav Sharma - 7/23/2013 - New Method Added(populateRegionBasedOnPortfolioRegionValue) - BUG-1944
 *                      V_1.3 - Abhinav Sharma - 04/03/2015 - New method added (populateYRRMoveDateOnMostRecentListing) - D-00013862
                        V_1.4 - Abhinav Sharma - 05/04/2015 - Modified method(populateYRRMoveDateOnMostRecentListing) - D-00014017
                        v_1.5 - Saurabh kumar  - 07/17/2015-  New Method added (createDispositionRehabOnPortfolio)   - D- 00014396
                        v_1.5  -saurabh kumar -09/4/2015  -  Modified method (createDispositionRehabOnPortfolio) :- added functionality which update
                                                              related portfolio acquisition status to for sale as per conditions
                       v_1.6 - Abhinav Sharma - 10/16/2015 - New method added(populateYRRMakeReadyDateOnMostRecentListing) - D-00014655
                       v_1.7 - Poonam Bhargava - 03/28/2016  - New method added(updatePortfolioOwnerFromYRR) - D-00015227
                       V_1.8 - Saurabh Kumar   - 4/27/2016   - Modify Soql Query in Method  createDispositionRehabOnPortfolio :- D-00015412
                       v_1.9 - Saurabh kumar  - 5/4/2016     - Modified method  createDispositionRehabOnPortfolio :- added RFL Disposition strategy D-00015385  
                       v1_1.10- Saurabh Kumar - 6/20/2016    - Modified method  createDispositionRehabOnPortfolio :- Modify functionality for Acquisition Status changes
                       v_1.11 - Poonam Bhargava - 08/04/2016 - Modified the method updatePortfolioOwnerFromYRR - D-00016017
                       v_1.12 - Saurabh Kumar - 8/11/2016    - Modified  method  createDispositionRehabOnPortfolio -
                       V_1.13 - Poonam Bhargava - Added a new method updateMarketfieldfromMarket2 - (D-00017166)
                       V_1.14 - Poonam Bhargava - 10/03/2017 - Modified the method 'createDispositionRehabOnPortfolio' - (D-00017496)
                 
 **/                                     
 
public class YardiRentRollTriggerHelper {

    //This method is to attach the Portfolio record with the appropriate Yardi Rent Roll
    public static void attachPortfolioWithYardiRentRoll(List<Yardi_Rent_Roll__c> yardiRentRoll , Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll) {

        //Create a set of Yardi Property code
        Set<String> setYardiPropertyCodes = new Set<String>();

        //Loop throught the records and populate the set
        for(Yardi_Rent_Roll__c yRR : yardiRentRoll) {

            //Check if code is not null
            if(yRR.Yardi_Property_Code__c != null && yRR.Yardi_Property_Code__c != '') {

                //Populate the set
                setYardiPropertyCodes.add(yRR.Yardi_Property_Code__c);
            }
        }

        //Create a map to hold the  property information against Yardi_Property_Code__c
        Map<String, Property__c> mapYPCwithProperty = new Map<String, Property__c>();

        //Query to fetch Property records
        for(Property__c property : [Select Id, Yardi_Property_Code__c from Property__c where Yardi_Property_Code__c  != null
                                    AND Yardi_Property_Code__c IN: setYardiPropertyCodes]) {

            //Add data in Map
            mapYPCwithProperty.put(property.Yardi_Property_Code__c.toLowerCase(), property);
        }

        //Loop throught the Yardi Rent Roll and populate the field
        for(Yardi_Rent_Roll__c yRR : yardiRentRoll) {

            //Check if yardi property code is not null and map contains the yardi property code
            if(yRR.Yardi_Property_Code__c != null && yRR.Yardi_Property_Code__c != '' && mapYPCwithProperty.containsKey(yRR.Yardi_Property_Code__c.toLowerCase())) {

                //Populate the property field
                yRR.Portfolio__c = mapYPCwithProperty.get(yRR.Yardi_Property_Code__c.toLowerCase()).Id;
            }
        }
    }

    // Function to associate Yardi Rent Roll to AM Reporting based on the Portfolio
    public static void associateYardiRentRollToAMReporting(List<Yardi_Rent_Roll__c> yardiRentRolls) {
        // Create a Map of Portfolio Id with the Yardi Rent Roll ID
        Map<Id, Id> portYRRMap = new Map<Id, Id>();
        for(Yardi_Rent_Roll__c yrr : yardiRentRolls) {
            if(yrr.Portfolio__c != null)
                portYRRMap.put(yrr.Portfolio__c, yrr.Id);
        }

        AM_Reporting__c[] reportingListForUpdate = new List<AM_Reporting__c>();
        for(AM_Reporting__c reporting : [Select Portfolio__c, Yardi_Rent_Roll__c from AM_Reporting__c where Portfolio__c in :portYRRMap.keySet()]) {
            reporting.Yardi_Rent_Roll__c = portYRRMap.get(reporting.Portfolio__c);
            reportingListForUpdate.add(reporting);
        }
        // Update the Residences
        update reportingListForUpdate;
    }

    //This method is to stamp the most recent YRR record on Residence record
    public static void mostRecentYardiRentRollOnResidence(List<Yardi_Rent_Roll__c> newYardiRentRoll) {

        //Map to hold Portfolio Id as Key and Yardi Rent Roll Id as Value
        Map<Id,Id> portfolioYardiRentRollMap = new MAp<Id,Id>();

        //Loop through Yardi Rent Roll Records
        for(Yardi_Rent_Roll__c yardiRentRoll : newYardiRentRoll) {

            //Check for Portfolio associted with Yardi Rent Roll
            if(yardiRentRoll.Portfolio__c != null) {

                //put values in map
                portfolioYardiRentRollMap.put(yardiRentRoll.Portfolio__c, yardiRentRoll.Id);
            }
        }

        //List of Residence
        List<Residence__c> residences = new List<Residence__c>();

        //Loop through Portfolio records that is associted with Yardi Rent Roll
        for(Property__c property : [Select Id, Residence__c From Property__c 
                                                            Where Id IN :portfolioYardiRentRollMap.keySet() 
                                                            and Residence__c != null
                                                            and Residence__r.Parent_Structure__c = false
                                                            and Acquisition_Status__c not in ('Cancelled', 'Sold')]) {

            //Chekc if map has value
            if(portfolioYardiRentRollMap.containsKey(property.Id)) {

                //Instance of residence that is associated with property
                Residence__c residence = new Residence__c(Id = property.Residence__c);

                //Add Yardi Rent Roll in Most Recent Yardi Rent Roll field
                residence.Most_Recent_Yardi_Rent_Roll__c = portfolioYardiRentRollMap.get(property.Id);

                //Add value in list
                residences.add(residence);
            }
        }

        //Check for size
        if(residences.size() > 0)
            update residences;
    }
    
    //This method is there to populate region field on Yardi Rent Roll object based on the region field value of Parent Portfolio record
    public static void populateRegionBasedOnPortfolioRegionValue(List<Yardi_Rent_Roll__c> newYardiRentRoll, Map<Id, Yardi_Rent_Roll__c> oldMapYardiRentRoll) {
      
        //Set to hold the Parent Portfolio Ids assoicated with Yardi Rent Roll Records
        Set<Id> setPortfolioIds = new Set<Id>();
      
        //Loop through Yardi Rent roll records
        for(Yardi_Rent_Roll__c yRR : newYardiRentRoll) {
        
            //Populate set with the Portfolio Ids
            setPortfolioIds.add(yRR.Portfolio__c);
        }
      
        //Check for size
        if(setPortfolioIds.size()>0){
      
            //Map to hold the Portfolio record Id as key and Property record as a value
            Map<Id, Property__c> mapPortfolioIdWithPortfolio = new Map<Id, Property__c>([Select Id, Region__c, Yardi_Property_Code__c FROM Property__c WHERE ID IN : setPortfolioIds]);
      
            //Loop through Yardi Rent Roll records
            for(Yardi_Rent_Roll__c yRRForUpdate : newYardiRentRoll) {
            
                //Check for Property accocited with yardi rent roll
                if(yRRForUpdate.Portfolio__c != null && mapPortfolioIdWithPortfolio.get(yRRForUpdate.Portfolio__c) != null) {
            
                    //Check if yardi property code is not null and change in value is there or not
                    if((oldMapYardiRentRoll == null 
                        || mapPortfolioIdWithPortfolio.get(yRRForUpdate.Portfolio__c).Region__c != yRRForUpdate.Region__c)) {
      
                        //Populate the Region field
                        yRRForUpdate.Region__c = mapPortfolioIdWithPortfolio.get(yRRForUpdate.Portfolio__c).Region__c;
                    }
                }
            }
        }     
    }
    
    //Added By - Abhinav Sharma - 04/02/2015 - D-00013862
    /** Description :   Method to populate Move out date on most recent listing record 
    *                   if any update happens for the "Move out date" field on YRR record.
    *
    *   Created By  :   Abhinav Sharma
    *
    *   Arguments   :   List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll
    *
    *   Return      :   void
    *
    * 
    **/
    /*public static void populateYRRMoveDateOnMostRecentListing(List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll) {

        //Map of Yardi Rent Rolls
        Map<Id, Yardi_Rent_Roll__c> mapYardiRentRolls = new Map<Id, Yardi_Rent_Roll__c>();
    
        //Loop through new Yardi Rent Roll Records
        for(Yardi_Rent_Roll__c yRR : newYRRs) {

            //Checking if "Move Out Date" field value for change
            if(oldMapYardiRentRoll != null && yRR.Move_Out_Date__c != oldMapYardiRentRoll.get(yRR.ID).Move_Out_Date__c) {
                mapYardiRentRolls.put(yRR.Id, yRR);
            }
        }

        //Checking map for size value
        if(mapYardiRentRolls.values().size() > 0) {

            //Map of listing going to update with YRR Move out date value from the most recent YRR record
            Map<Id, Listing__c> mapListings = new Map<Id, Listing__c>();

            //Loop through eligible residence records
            for(Residence__c r : [SELECT Id, Most_Recent_Listing__c, Most_Recent_Yardi_Rent_Roll__c, 
                                    Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c FROM Residence__c
                                    WHERE Most_Recent_Yardi_Rent_Roll__c != null AND Most_Recent_Listing__c != null
                                    AND Most_Recent_Yardi_Rent_Roll__c IN : mapYardiRentRolls.keySet()]) {
                if(r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c != null)                        
                    mapListings.put(r.Most_Recent_Listing__c, new Listing__c(Id = r.Most_Recent_Listing__c, YRR_Move_Out_Date__c = r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c));
            }
        
            //Checking for size value
            if(mapListings.values().size()  > 0)
                update mapListings.values();
        }     
    }*/
    

/*    
    //Added By - Saurabh kumar - 7/17/2015 - d - 00014396
    /** Description :   Method to create disposition rehab when a current tenant status is changed to Notice
    *
    *   Created By  :   Saurabh kumar
    *
    *   Arguments   :   List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll
    *
    *   Return      :   void
    *
    * 
    *
    
   */    
    
    Public Static void createDispositionRehabOnPortfolio(List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll)
    {  
        //map to hold portfolioId and YRR sobject whose current tenat status been changed or newly inserted
        Map<Id, Yardi_Rent_Roll__c> mapPortfolioIdAndYRRStatusChanged = new Map<Id, Yardi_Rent_Roll__c>();
        
        //list to property which need to be updated
        List<Property__c> listPropertyToUPdate = new list<property__c>();
        
        //list of Disposition rehab to be created
        List<Rehab__c> newDispostionRehabToBeInserted = new list<Rehab__c>();
        
        //list of Disposition rehab to be created
        List<Listing__c> listOfListingToBeInserted = new List<Listing__c>();
        
        //List of Rehab to be updated on disposition 
        list<Rehab__c> listTurnRehabupdated = new list<rehab__c>();
        //list of recordType of Rehab
        //List<RecordType> listRecordType = [Select Id from RecordType Where SObjectType = :Schema.SObjectType.Rehab__c.getName() And DeveloperName = 'Disposition' And isActive = True];
        Id dispositionRehabRecordTypeId  = Schema.SObjectType.Rehab__c.getRecordTypeInfosByName().get('Disposition').getRecordTypeId() ;
        Id turnRehabRecordTypeId = Schema.sObjectType.Rehab__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId(); 
        //Set to hold porfolioId  whose Accquisation status need to be changed
        Set<Id>  setOfPortfolios = new Set<id>();
        List<Property__c> PortfolioToBeUpdated = new List<Property__c>();
        Set<String> Disposition_YRR_VacancyStatus =  new Set<String>{'VACANT' ,'ADMIN','DOWN'};
         
        for(Yardi_Rent_Roll__c  Yrr : newYRRs)
        {   //check if it is updated and Yrr current teanat status change as well if yes than add to ListYrr Changed
          if(oldMapYardiRentRoll != null 
                && oldMapYardiRentRoll.containsKey(yRR.id) 
                && yRR.Current_Tenant_Status__c != oldMapYardiRentRoll.get(yRR.Id).Current_Tenant_Status__c 
                && yRR.Current_Tenant_Status__c != null 
                && yRR.Portfolio__c != null
                && (yRR.Current_Tenant_Status__c.equalsIgnoreCase(Constants.DISPOSITION_NOTICE) 
                    || Disposition_YRR_VacancyStatus.contains(yRR.Current_Tenant_Status__c.toUpperCase()))
        ) {
                 
                //adding YRR as it's status changes to Notice/vacant/admin which make it eligible for creating a disposition record 
               mapPortfolioIdAndYRRStatusChanged.put(Yrr.Portfolio__c, Yrr);
                 
                //checking YRR Current Tenant status changed to Vacant/Admin from Notice
                     if( oldMapYardiRentRoll.get(Yrr.Id).Current_Tenant_Status__c!= null 
                       && oldMapYardiRentRoll.get(yRR.Id).Current_Tenant_Status__c.equalsIgnoreCase(Constants.DISPOSITION_NOTICE)
                       && Disposition_YRR_VacancyStatus.contains(yRR.Current_Tenant_Status__c.toUpperCase())){
                       
                       setofportfolios.add(Yrr.portfolio__c);
                  } 
                
             }
            //if it is newly inserted
              else if((oldMapYardiRentRoll == null || !oldMapYardiRentRoll.containsKey(yRR.id)) 
                        && yRR.Portfolio__c != null 
                        && yRR.Current_Tenant_Status__c != null 
                        && (yRR.Current_Tenant_Status__c.equalsIgnoreCase(Constants.DISPOSITION_NOTICE)
                          || Disposition_YRR_VacancyStatus.contains(yRR.Current_Tenant_Status__c.toUpperCase()))
             ){
                   mapPortfolioIdAndYRRStatusChanged.put(Yrr.Portfolio__c, Yrr);
            }
        }
        
        
        //fetching all portfolio on which new Disposition Rehab is to be created 
        if(!mapPortfolioIdAndYRRStatusChanged.isEmpty()){
        	
        	//Modified by Poonam Bhargava - 10/03/2017 - (D-00017496)
        	//Map to hold Renwal id with Renewal record
        	Map<Id, Renewal__c> mapOfRenewal = new Map<Id, Renewal__c>([Select Id, Lease__c, Lease__r.Portfolio__c,Lease__r.Yardi_Active_Lease__c from Renewal__c 
        																where Lease__r.Portfolio__c IN : mapPortfolioIdAndYRRStatusChanged.keySet()
        																order BY CreatedDate DESC]);
        	
            //Prasad: D-00017507
            for(Property__c prop : [Select Id, (Select Id ,portfolio__c, RecordTypeId from Rehabs__r 
                                        where RecordTypeId = :turnRehabRecordTypeId And Stage__c != :Constants.REHAB_STAGE_CLOSED_CANCELLED 
                                        And Stage__c != :Constants.REHAB_STAGE_CLOSED_COMPLETED Order BY CreatedDate DESC limit 1),
                                     (Select Id, Rehab__c , TRS_Transferred__c,Disposition_Strategy__c,
                                     Renewals__r.Lease__r.Notice_Date__c , Dispo_Lease_Renewal_Strategy__c
                                     from Dispositions__r where BX_Approval_of_Sale__c = 'Yes' 
                                     AND IH_Approval_of_Sale__c = 'Yes' 
                                     AND Dispo_Lease_Renewal_Strategy__c != :Constants.DISPOSITION_OK_TO_RENEW),
                                     fund__c ,Residence__c 
                                     from property__c where 
                                     Id IN :mapPortfolioIdAndYRRStatusChanged.keySet()]){
              
              //checking for fund 2 property if approved disposition is present and other rehab is in closed stage and no Disposition rehab is present in active and lease notice date is populated than create a new disposition rehab
              //Prasad: D-00017507
              if(!prop.dispositions__r.IsEmpty())
              {
                 for( Disposition__c disp : prop.dispositions__r){
                   if( disp.Rehab__c == null 
                           && (disp.Renewals__r.Lease__r.Notice_Date__c != Null || Disposition_YRR_VacancyStatus.contains(mapPortfolioIdAndYRRStatusChanged.get(prop.Id).Current_Tenant_Status__c.toUpperCase()))
                           && prop.Residence__c != null 
                           &&(prop.fund__c != Constants.DISPOSITION_FUND_TWO 
                               || (disp.TRS_Transferred__c!=null && disp.TRS_Transferred__c.equalsIgnoreCase(Constants.YES))) 
                        ){
                              
                          Rehab__c rehab = new Rehab__c(RecordTypeId = disp.Disposition_Strategy__c == Constants.DISPOSITION_STRATEGY_MLS ?dispositionRehabRecordTypeId : (prop.Rehabs__r.isEmpty())?turnRehabRecordTypeId : null , 
                                                                              Stage__c= Constants.REHAB_STAGE_NOTIFICATION_RECEIVED, 
                                                                              Home__c = prop.Residence__c,
                                                                              Portfolio__c = prop.Id);
                          
                         //Modified by Poonam Bhargava - 10/03/2017 - (D-00017496)                                                   
                         //Check for null condition
						 if(mapOfRenewal.size() > 0){
                              	
							//Loop over Renewal records
							for(Renewal__c re : mapOfRenewal.values()){
  		
								//Check for eligible criteria and populate Renewal field on Rehab accordingly
								if(String.isBlank(rehab.Renewal__c)){
									rehab.Renewal__c = re.Id;
								}
								if(re.Lease__r.Yardi_Active_Lease__c == true){
									rehab.Renewal__c = re.Id;
									Break;	
								}
							}
						 } 
                          
                         if(rehab.recordtypeId != null){                                                     
                          newDispostionRehabToBeInserted.add(rehab);
                         }
                         else{
                          listTurnRehabupdated.add(prop.Rehabs__r[0]);	
                          //setOfPortfolios.add(prop.id);
                         }
                    }
                 }
              } 
           }
        }
        
        //checking Active Disposition rehab on portfolio whose Accquisation status need to be changed to FOR SALE
        //If Portfolio :Acquisition Status = SOLD, it will never go back to For Sale.  :-D-00015412(4/26/2016)
        if(setOfPortfolios.size() > 0){ 
            portfolioToBeUpdated = Trigger_RehabHandler.portfolioAcqStatusForSale(setOfPortfolios,dispositionRehabRecordTypeId,turnRehabRecordTypeId);
        }
        
        //inserting Disposition rehab on portfolio
        if(!newDispostionRehabToBeInserted.isEmpty())
        {
        	try
            { 
             insert newDispostionRehabToBeInserted; 
            }
            catch(DMLException de)
            {
              system.debug(de.getmessage());
            }
           //creating Listing on Turn rehab 
         	for(Rehab__c RehabObj : newDispostionRehabToBeInserted){
        		if(rehabObj.RecordTypeId == turnRehabRecordTypeId && rehabObj.Id != null) {
                	listOfListingToBeInserted.add( new Listing__c( Rehab__c = rehabObj.Id,
                                        Portfolio__c = rehabObj.Portfolio__c,
                                        Residence__c = rehabObj.Home__c,
                                        Status__c = Constants.LISTING_STATUS_DOWN_IN_REHAB
                                        ));           
                 }
             }
        
        	//inserting new listing 
        	if(!listOfListingToBeInserted.isEmpty()){
        	
        		Database.SaveResult[] srs =  Database.insert(listOfListingToBeInserted, false);
        	}
        }
        
        //updating disposition record with related turn rehab
        if(!listTurnRehabupdated.isEmpty()){
        	
        	//populate Turn Rehab on realted dispositino 	
        	Trigger_RehabHandler.populateDataOnDispositionBasedOnRehab(listTurnRehabupdated);  
        }
        
        //updating portfolio Acquisition status to For sale 
        if(!PortfolioToBeUpdated.isEmpty()){
          
          update portfolioToBeUpdated ;  
          
        }
    } 
    
    
    
  //Added By - Abhinav Sharma - 10/16/2015 - D-00014655
  /**  @description  :  Method to populate Yardi Make Ready Date on most recent listing record 
    *            if any update happens for the "Yardi Make Ready Date" field on YRR record.
    *
    *  @created By    :  Abhinav Sharma
    *
    *  @arg      :  List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll
    *
    *  @return      :  void
  **/
    public static void populateYRRMakeReadyDateOnMostRecentListing(List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll) {

        //Map of Yardi Rent Rolls
        Map<Id, Yardi_Rent_Roll__c> mapYardiRentRolls = new Map<Id, Yardi_Rent_Roll__c>();
    
        //Loop through new Yardi Rent Roll Records
        for(Yardi_Rent_Roll__c yRR : newYRRs) {

            //Checking if Yardi Make Ready Date field value for change
            if(oldMapYardiRentRoll != null && yRR.Yardi_Make_Ready_Date__c != oldMapYardiRentRoll.get(yRR.ID).Yardi_Make_Ready_Date__c) {
                mapYardiRentRolls.put(yRR.Id, yRR);
            }
        }

        //Checking map for size value
        if(mapYardiRentRolls.values().size() > 0) {

            //Map of listing to be updated
            Map<Id, Listing__c> mapListings = new Map<Id, Listing__c>();

            //Loop through residence records 
            for(Residence__c r : [SELECT Id, Most_Recent_Listing__c, Most_Recent_Yardi_Rent_Roll__c, 
                                    Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c,
                                    Most_Recent_Listing__r.Make_Ready_Date__c
                                    FROM Residence__c
                                    WHERE Most_Recent_Yardi_Rent_Roll__c != null AND Most_Recent_Listing__c != null
                                    AND Most_Recent_Yardi_Rent_Roll__c IN : mapYardiRentRolls.keySet()]) {
                                      
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

  //Added By - Poonam Bhargava - 03/28/2016 - (D-00015227)
	/** @description    :   Method to populate Portfolio's Owner from YRR's Portfolio Manager(PM Owner Update Automation Process)
	  *
	  * @created By     :   Poonam Bhargava
	  *
	  * @arg            :   List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll
	  *
	  * @return         :   void
	**/   
	public static void updatePortfolioOwnerFromYRR(List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll){
      
		//Set to hold Portfolio Ids on Yardi Rent Roll
		Set<Id> setOfPortfolioIds = new Set<Id>();
	
		//Set to hold Portfolio Manager of Yardi Rent Roll records
		Set<String> setOfPortfolioManagerOnYRR = new Set<String>();

		//List to hold Portfolio records to be updated
		List<Property__c> portfoliosToBeUpdated = new List<Property__c>(); 
    
		//Initialize string variable to hold YRR's manager name
		String managerNameOnYRR;

		//Loop over Yardi Rent Roll
		for(Yardi_Rent_Roll__c yrr : newYRRs){
    
			//Check for null condition and insert/update case
			if(yrr.Portfolio__c != null &&(oldMapYardiRentRoll == null 
											|| oldMapYardiRentRoll.get(yrr.Id).Portfolio_Manager__c != yrr.Portfolio_Manager__c)){

				//Populate set with Portfolio Ids On Yardi Rent Roll
				setOfPortfolioIds.add(yrr.Portfolio__c);  
        
				//Populate set with Portfolio Manager On Yardi Rent Roll
				setOfPortfolioManagerOnYRR.add(yrr.Portfolio_Manager__c);  
			}   
		}

		//Check for set setOfPortfolioIds size
		if(setOfPortfolioIds.size() > 0){
            
			//Map to hold Yardi Queue (Custom Setting) records
			Map<String, Yardi_Defaults__c> mapOfYardiQueues = Yardi_Defaults__c.getAll();
            
			//Map to hold Portfolio Ids with Portfolio records
			Map<Id, Property__c> mapOfPortfolios = new Map<Id, Property__c>();
            
			//Initialize list to hold profiles not to included in PM update
			List<String> profilesNotToIncludeInPMUpdate = Label.PROFILE_ID_NOT_TO_INCLUDE_IN_PM_UPDATE.split(','); 
            
			//Loop over portfolio records related to YRR
			for(Property__c p : [Select Id, Owner.Name, OwnerId, Owner.IsActive From Property__c Where Id IN : setOfPortfolioIds 
									AND Acquisition_Status__c !=: Constants.CANCELLED]){
                                        
				//Populate map mapOfPortfolios with Portfolio 
				mapOfPortfolios.put(p.Id, p);
			}
            
			//Map to hold User Records related to Yardi Rent Roll (as Portfolio Manager)
			Map<String, User> mapOfUserRecordWithYRR = new Map<String, User>();
            
			//Check for setOfPortfolioManagerOnYRR size (YRR'S PM)
			if(setOfPortfolioManagerOnYRR.size() > 0){
            
				//Loop over User records related to Yardi Rent Roll as PM(Portfolio Manager)
				for(User u : [Select Id, Name, IsActive From User Where Name IN : setOfPortfolioManagerOnYRR AND IsActive = true
								AND ProfileId NOT IN : profilesNotToIncludeInPMUpdate ORDER BY LastModifiedDate ASC]){
					
					//Convert user name into lower case                
					managerNameOnYRR = (u.Name).toLowerCase();
                
					//Populate User map related to YRR
					mapOfUserRecordWithYRR.put(managerNameOnYRR, u);        
				}   
			}
            
			//Loop over Yardi Rent Roll records
			for(Yardi_Rent_Roll__c yrr : newYRRs) {
                
				//Check for map mapOfPortfolios Size                                                                    
				if(yrr.Portfolio__c != null && mapOfPortfolios.containsKey(yrr.Portfolio__c)){
                    
					//Check for null value and convert Portfolio manager into lower case
					if(yrr.Portfolio_Manager__c != null)
						managerNameOnYRR = (yrr.Portfolio_Manager__c).toLowerCase();
                    
					//Check for eligible criteria to populate Portfolio Owner
					if(managerNameOnYRR != null && mapOfUserRecordWithYRR.containsKey(managerNameOnYRR)
						&& mapOfPortfolios.get(yrr.Portfolio__c).OwnerId != null
						&& mapOfUserRecordWithYRR.get(managerNameOnYRR).Id != mapOfPortfolios.get(yrr.Portfolio__c).OwnerId){

						//Populate list of Portfolio's to be updated
						portfoliosToBeUpdated.add(new Property__c(Id = mapOfPortfolios.get(yrr.Portfolio__c).Id , OwnerId = mapOfUserRecordWithYRR.get(managerNameOnYRR).Id));    
					}   
					else if((String.isBlank(yrr.Portfolio_Manager__c) || yrr.Portfolio_Manager__c.equalsIgnoreCase(Label.UNASSIGNED)
							|| (!mapOfUserRecordWithYRR.containsKey(managerNameOnYRR)))
							&& yrr.Region__c != null && mapOfYardiQueues.containsKey(yrr.Region__c)
							&& mapOfYardiQueues.get(yrr.Region__c).Queue_Id__c != null
							&& mapOfPortfolios.get(yrr.Portfolio__c).OwnerId != null
							&& mapOfPortfolios.get(yrr.Portfolio__c).OwnerId != mapOfYardiQueues.get(yrr.Region__c).Queue_Id__c){ // Modified by Poonam Bhargava -(08-04-2016) D-00016017
					
						//Populate Queue as Portfolio Owner and add into list
						portfoliosToBeUpdated.add(new Property__c(Id = mapOfPortfolios.get(yrr.Portfolio__c).Id , OwnerId = mapOfYardiQueues.get(yrr.Region__c).Queue_Id__c));         
					}
				}
			}           
		}
        
		//Check for Portfolio list size and perform update operation
		if(portfoliosToBeUpdated.size() > 0) {
		    
			//Keep the Property trigger off
			PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = false;
			
			//Perform update operation on Property records
			update portfoliosToBeUpdated;
			
			//Keep the property trigger on
			PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = true;
		}
	}
	
	//Added By - Poonam Bhargava - 06/26/2017 - (D-00017166)
	/** @description    :   Method to truncate Market field and populate only region value on YRR when the market is populated by 3rd party users(DBA)
	  *
	  * @created By     :   Poonam Bhargava
	  *
	  * @arg            :   List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll
	  *
	  * @return         :   void
	**/   
	public static void updateMarketfieldfromMarket2(List<Yardi_Rent_Roll__c> newYRRs, Map<Id,Yardi_Rent_Roll__c> oldMapYardiRentRoll){
	
		//Set to hold the region string	
		Set<String> setOfRegion = new Set<String>();
		
		//Loop over the Region records and populate the set with the region value
		for(Region__c re : [Select Id, Name from Region__c]){
			setOfRegion.add(re.Name);	
		}
		
		//Loop overe the trigger.new list
		for(Yardi_Rent_Roll__c yRR : newYRRs){
			
			//Check for Market value for null on YRR record
			if(String.isNotBlank(yRR.Market__c)) {
				
				//Loop over the region string values
				for(String strRegion : setOfRegion){
				
					//Check is the Market value is exist in the region string
					if(yRR.Market__c.containsIgnoreCase(strRegion)){
						
						//Populate the Market field on YRR 
						yRR.Market__c = strRegion;
						break;	
					}
				}		
			}	
		}	
	}	
}