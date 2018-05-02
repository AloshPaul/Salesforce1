/** Description         :  Trigger helper class to populate disposition fields based on residence.
  * 
  * Created Date        :   05/27/2015
  *
  * Created By          :   Abhinav Sharma 
  *  
  * Version             :   V_1.0 
  * 
  * Revision Logs       :   V_1.0 - Created 
  * 
  * Version             :   V_1.1 - Saurabh -method to set For sale value on portfolio unchecked when disposition is deleted and no other disposition with valid criteria is present on portfolio
                        :   v_1.2 - Saurabh - Added a new method :-updateRenewalBasedonDispo  D-00016020 
                        :   V_1.3 - Saurabh  -updated method populateDataOnRenewalBasedOnDisposition/updatePortfolioafterDispositionDeleted -D-00016046(8/11/2016)
                        :   V_1.4 - Saurabh - Added a new Method validateDisposition D-00016940
                        :   V_1.5 - Poonam Bhargava - 03/07/2017 - Added a new method populateListingRehabFieldsBasedOnDisposition - D-00016958
                        :   //V_1.6 - Poonam Bhargava - 06/29/2017 - Added a new method updateYardiFlagTrueOnAttributeChange - (D-00017213) - Blocked
                        :   V_1.7 - Poonam Bhargava - 10/03/2017 - Modified the method 'populateDataOnRenewalBasedOnDisposition' (D-00017496)      
                        :   //V_1.8 - Shashikant - 08/11/2017 - D-00017007 - Added method populateDispositionValues to RFL/Standard based on Disposition Strategy - Blocked
**/

public class DispositionTriggerHelper {
 
    /**
      * @Description    :   Method for maintain disposition fields "Rehab" and "Renewal" values.
      *
      * @arg            :   List of new disposition, map of old disposition.
      *
      * @return         :   Void
    **/
    public static boolean isTrigger_DispositionHandler = false;
    public static void populateDataFromResidence(List<Disposition__c> newDisposition, map<Id, Disposition__c> mapOldDisposition) {
    
        //Set to hold portfolio records
        Set<Id> setPortfolioIds = new Set<Id>(); 
        
        //Loop through trigger.new list
        for(Disposition__c di : newDisposition) {
            
            //Checking if portfolio was stamped there as owner or not
            if(di.Portfolio__c != null)
              setPortfolioIds.add(di.Portfolio__c);
        }
        
        //Checking set for size value
        if(setPortfolioIds.size() > 0) {
        
            //Map of portfolios
            Map<Id, Property__c> mapPortfolios = new Map<Id, Property__c>([SELECT ID, Residence__c, Residence__r.Most_Recent_Rehab__r.id,
                                                                           Residence__r.Most_Recent_Rehab__r.RecordTypeId,
                                                                           (SELECT ID FROM Renewals__r WHERE Portfolio__c != null
                                                                              AND Portfolio__c IN  : setPortfolioIds
                                                                              ORDER BY CreatedDate DESC LIMIT 1)
                                                                           From Property__c Where Id IN : setPortfolioIds]);
           
            //Loop through trigger.new list and populating fields with the map of portfolios
            for(Disposition__c disp : newDisposition) {
        
                //Checking and validting for eligibility and then accordingly populating the field value on disposition                
                if(disp.Portfolio__c != null 
                     && mapPortfolios != null && mapPortfolios.values().size() > 0
                    && mapPortfolios.containsKey(disp.Portfolio__c)
                    && mapPortfolios.get(disp.Portfolio__c) != null) {
                        
                    //If the property (Portfolio) is selected, then most recent Renewals data should be populated.
                    if(mapPortfolios.get(disp.Portfolio__c).Renewals__r != null
                      && mapPortfolios.get(disp.Portfolio__c).Renewals__r.size() > 0) {
                      disp.Renewals__c = mapPortfolios.get(disp.Portfolio__c).Renewals__r[0].ID;
                    } else {
                       disp.Renewals__c = null;     
                    }
                        
                    /*    //  Removed because Now Rehab__c on disposition is populate when a dispositon rehab is created :-- 
                     //Populating Rehab from residence record as most recent rehab
         
                       List<RecordType> listRecordType = [Select Id from RecordType Where SObjectType = 'Rehab__c' And DeveloperName = 'Disposition' And isActive = True];
                      if(mapPortfolios.get(disp.Portfolio__c).Residence__c != null && !listRecordType.isEmpty()) {
                        
                        //If the property (Portfolio) is selected, then most recent Rehab data should be populated.
                         if(mapPortfolios.get(disp.Portfolio__c).Residence__r.Most_Recent_Rehab__r.RecordTypeId= null )
                            disp.Rehab__c = mapPortfolios.get(disp.Portfolio__c).Residence__r.Most_Recent_Rehab__c;
                        else
                            disp.Rehab__c = null;
                    } else {
                        disp.Rehab__c = null;
                    }  */    
                }
                
                //Check for disposition field value
                if(disp.IH_Approval_of_Sale__c == 'No' && disp.BX_Approval_of_Sale__c == 'No' && 
                    (mapOldDisposition == null
                     || (mapOldDisposition.get(disp.Id).IH_Approval_of_Sale__c  != disp.IH_Approval_of_Sale__c
                         || mapOldDisposition.get(disp.Id).BX_Approval_of_Sale__c != disp.BX_Approval_of_Sale__c )) ){
                
                    //Set disposition field Listing Status value
                    disp.Listing_Status__c = 'Cancelled';
                }
            }
        }
    } 
    
    /**
      * @Description    :   Method for populate renewal "PM Strategy" field and creating disposition rehab record based on criteria:-
      *                 :   for fund 02 property if TRS Transferd is True than only create disposition rehab -
      *
      * @arg            :   List of new disposition, map of old disposition.
      *
      * @return         :   Void
    **/
    public static void populateDataOnRenewalBasedOnDisposition(List<Disposition__c> newDisposition, map<Id, Disposition__c> mapOldDisposition) {
    
        //Map to hold Disposition Id with Renewal
        //map<Id, Renewal__c> mapToHoldDispositionIdWithRenewal = new map<Id, Renewal__c>(); 
        
        //Map to hold Portfolio Id with Portfolio
        map<Id, Property__c> mapToHoldPortfolioIdWithPortfolio = new map<Id, Property__c>();
        
        //Map to hold Portfolio Id with Portfolio
        map<Id, Property__c> mapToHoldPortfolioWithPortfolioId = new map<Id, Property__c>();
        
        //Map to hold Dispositions records with Portfolio Id
        map<Id, List<Disposition__c>> mapPortfolioWithDispositions = new map<Id, List<Disposition__c>>(); 
        
        //Initialize list of rehab to be inserted
        List<Rehab__c> listOfRehabToBeInserted = new List<Rehab__c>();
        //Initialize list of Listing to be inserted
        List<Listing__c> listOfListingToBeInserted = new List<Listing__c>();
        //map to hold dispositon id and it related lease noticd date 
        Map<id, Disposition__c> mapDispIdwithfullleasevalue = new Map<id,Disposition__c>();
        //set to hold all disposition id which approval date is not null 
        set<id> setofdispidforlease = new set<id>();
        //List of Rehab to be updated on disposition 
        list<Rehab__c> listTurnRehabupdated = new list<rehab__c>();
        
        //Retrieve Turn record Type from Rehab
        ID turnRehabRecordTypeId = Schema.sObjectType.Rehab__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId(); 
        
        for(Disposition__c disp : newDisposition)
        {
             if(disp.Date_of_IH_Approval_of_Sale__c != null && disp.Date_of_BX_Approval_of_Sale__c != null && disp.Rehab__c ==NULL)
             {
                 setofdispidforlease.add(disp.Id);
             }
            
         }
        
        if(!setofdispidforlease.isEmpty())
        {
             //retrieving disposition ->renewal-lease-notice date 
            mapDispIdwithfullleasevalue = new Map<id,Disposition__c>([Select id,Renewals__r.lease__r.Notice_Date__c ,Renewals__r.lease__c from disposition__c where id in :setofdispidforlease]);
        }
        
        //Loop through Trigger.new
        for(Disposition__c disp : newDisposition){
        
        
            //when dispositon  :-Dispo Lease Renewal Strategy value is  Okay to Renew then no process will work for that disposition
            if(disp.Dispo_Lease_Renewal_Strategy__c!=null && disp.Dispo_Lease_Renewal_Strategy__c.equalsIgnoreCase('Okay to Renew'))
              continue;
            //Check for null
            if(disp.Id != null && disp.Portfolio__c != null ){

                //Ckeck map for Portfolio Id and populate map 
                if(!mapToHoldPortfolioIdWithPortfolio.containsKey(disp.Portfolio__c)) 
                    mapToHoldPortfolioIdWithPortfolio.put(disp.Portfolio__c, new Property__c(Id = disp.Portfolio__c));            
            }
            
            //Checking and validting for eligibility and then accordingly populating map
            if(disp.IH_Approval_of_Sale__c != null && disp.BX_Approval_of_Sale__c != null && disp.IH_Approval_of_Sale__c.equalsIgnoreCase('Yes')
                 && disp.BX_Approval_of_Sale__c.equalsIgnoreCase('Yes')&& disp.Date_of_BX_Approval_of_Sale__c !=null && disp.Date_of_IH_Approval_of_Sale__c !=null
                 && (mapOldDisposition == null 
                        || (mapOldDisposition.get(disp.Id).IH_Approval_of_Sale__c != disp.IH_Approval_of_Sale__c
                              || mapOldDisposition.get(disp.Id).BX_Approval_of_Sale__c != disp.BX_Approval_of_Sale__c || disp.Rehab__c ==NULL) ))
                {
                
                //Check for disposition field to creating disposition rehab
                if((String.isNotBlank(disp.Vacancy_Status__c) && disp.Vacancy_Status__c.equalsIgnoreCase('Vacant')) ||
                (mapDispIdwithfullleasevalue.containsKey(disp.Id) 
                && mapDispIdwithfullleasevalue.get(disp.Id).Renewals__r.lease__r.Notice_Date__c !=Null 
                && String.isNotBlank(disp.Vacancy_Status__c) && disp.Vacancy_Status__c.equalsIgnoreCase('Notice') ) ){
                          
                    //Check map for key and populate accordingly
                    if(mapPortfolioWithDispositions.containsKey(disp.Id))
                        mapPortfolioWithDispositions.get(disp.Portfolio__c).add(disp);
                    else
                        mapPortfolioWithDispositions.put(disp.Portfolio__c, new List<Disposition__c>{disp});    
                }
                
                
                     //Check for renewal Id
                     //Commented out  as per SIR  D-00016020 , Now PM Strategty will depends on field Dispo Lease Renewal strategy in Dispo record
                   /* if(disp.Renewals__c != null){
                    
                        //Ckeck map for renewal Id and populate map 
                        if(!mapToHoldDispositionIdWithRenewal.containsKey(disp.Renewals__c )) 
                            mapToHoldDispositionIdWithRenewal.put(disp.Renewals__c, new Renewal__c(Id = disp.Renewals__c));   
                     
                }  */
            } 
             //checking if disposition is disapproved  or having listing status canceled 
             if((disp.IH_Approval_of_Sale__c == 'No' && disp.BX_Approval_of_Sale__c == 'No' && mapOldDisposition != Null )|| (disp.Listing_Status__c != null && disp.Listing_Status__c.equalsIgnoreCase('Cancelled'))){
                
                //Check for portfolio Id  
                if(disp.Portfolio__c != null){
                    
                    //Ckeck map for Portfolio Id and populate map 
                    if(!mapToHoldPortfolioWithPortfolioId.containsKey(disp.Portfolio__c)) {
                        mapToHoldPortfolioWithPortfolioId.put(disp.Portfolio__c, new Property__c(Id = disp.Portfolio__c));    
                        mapToHoldPortfolioIdWithPortfolio.remove(disp.portfolio__c);
                    } 
                }
            } 
        }
        
        //Check for portfolio-disposition map
        if(mapPortfolioWithDispositions.size() > 0) {
            
            //Modified by Poonam Bhargava - 10/03/2017 - (D-00017496)     
            //Map to hold Renwal id with Renewal record
            Map<Id, Renewal__c> mapOfRenewal = new Map<Id, Renewal__c>([Select Id, Lease__c, Lease__r.Portfolio__c,Lease__r.Yardi_Active_Lease__c from Renewal__c where Lease__r.Portfolio__c IN : mapPortfolioWithDispositions.keyset()
                                                                                order BY CreatedDate DESC]);
            
            //Initialize Map of portfolios and populate 
            Map<Id, Property__c> mapPortfolios = new Map<Id, Property__c>([SELECT ID, Residence__c,Fund__c,
                                                                            (Select Id ,portfolio__c, RecordTypeId from Rehabs__r where RecordTypeId = :turnRehabRecordTypeId And Stage__c !='Closed - Cancelled' 
                                                                             And Stage__c !='Closed - Completed' Order BY CreatedDate DESC limit 1) From Property__c 
                                                                             Where Id IN : mapPortfolioWithDispositions.keyset()]);
            
            //Retrieve record from record type
            List<RecordType> listRecordType = [Select Id from RecordType Where SObjectType = 'Rehab__c' And DeveloperName = 'Disposition' And isActive = True];
            
            //Check for list size
            if(!listRecordType.isEmpty()){
            
                 //Loop through keyset
                 for(Id propId : mapPortfolioWithDispositions.keySet()) {
                     
                       
                    //Loop through disposition
                    for(Disposition__c di : mapPortfolioWithDispositions.get(propId)){
                          
                        //Populate Rehab record and add to list
                        //Checking if property fund is  02 and  TRS Transfered  is Yes than create a disposition Rehab
                        Rehab__c rehab ;
                        if(mapPortfolios.get(propId).fund__c =='02'){
                            if(di.TRS_Transferred__c=='Yes') {
                                rehab = new Rehab__c(RecordTypeId = di.Disposition_Strategy__c == Constants.DISPOSITION_STRATEGY_MLS ?listRecordType[0].Id : ((mapPortfolios.get(propId).Rehabs__r.isEmpty())? turnRehabRecordTypeId : null), 
                                                                            Stage__c= 'Notification Received', 
                                                                            Home__c = mapPortfolios.get(propId).Residence__c,
                                                                            Portfolio__c = propId);
                                      
                            }
                        }
                        else {
                            rehab = new Rehab__c(RecordTypeId = di.Disposition_Strategy__c == Constants.DISPOSITION_STRATEGY_MLS ?listRecordType[0].Id : ((mapPortfolios.get(propId).Rehabs__r.isEmpty())? turnRehabRecordTypeId : null),
                                                                        Stage__c= 'Notification Received', 
                                                                        Home__c = mapPortfolios.get(propId).Residence__c,
                                                                        Portfolio__c = propId);
                              
                        }
                        
                        //Modified by Poonam Bhargava - 10/03/2017 - (D-00017496)           
                        //Check for null condition
                        if(mapOfRenewal.size() > 0){
                                
                            //Loop over Renewal records
                            for(Renewal__c re : mapOfRenewal.values()){
                            	        						
        						if(rehab != null){
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
                        }
                        
                        if(rehab != null && rehab.RecordTypeId != null){
                            listOfRehabToBeInserted.add(rehab);
                        }
                        else if(rehab!=null) {
                            listTurnRehabupdated.add(mapPortfolios.get(propId).Rehabs__r[0]);
                        }       
                    }
                }
            }
            //calling method to update portfolio acq status
            if(!listTurnRehabupdated.isEmpty()){ 
                //Only MLS Disposition Strategy will be changing Acquisition status to For Sale
                //Trigger_RehabHandler.updatePortfolioAcqStatus(listTurnRehabupdated);
                Trigger_RehabHandler.populateDataOnDispositionBasedOnRehab(listTurnRehabupdated);
            }    
        }
        
        //Check for rehab list size and insert 
        if(listOfRehabToBeInserted.size() > 0)
        {
        try{
            system.debug('@@@@@@@@' + listOfRehabToBeInserted.size());
            insert listOfRehabToBeInserted; 
        }
        Catch(DMlException de)
        {
            system.debug('######' + listOfRehabToBeInserted.size());
            System.debug(de.getmessage());
        }
        }   
        
        
        //creating Listing on Turn rehab 
        for(Rehab__c RehabObj : listOfRehabToBeInserted){
            
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
        
        //Check for portfolio map size 
        if(mapToHoldPortfolioIdWithPortfolio.size() > 0){
        
            //Loop through Ids
            for(Id portfolioId : mapToHoldPortfolioIdWithPortfolio.keySet()) {
            
                //Populating portfolio field value
                mapToHoldPortfolioIdWithPortfolio.get(portfolioId).For_Sale__c = True; 
            } 
            
            //Check for map size to perform update
            if(mapToHoldPortfolioIdWithPortfolio.size() > 0)
                update mapToHoldPortfolioIdWithPortfolio.values(); 
                
        }
        
        //Check for portfolio map size 
        if(mapToHoldPortfolioWithPortfolioId.size() > 0){
        
            //Loop through Ids
            for(Id portfolioId : mapToHoldPortfolioWithPortfolioId.keySet()) {
            
                //Populating portfolio field value
                mapToHoldPortfolioWithPortfolioId.get(portfolioId).For_Sale__c = False; 
            } 
            
            //Check for map size to perform update
            if(mapToHoldPortfolioWithPortfolioId.size() > 0)
                update mapToHoldPortfolioWithPortfolioId.values();    
        }
       
        //Check for map size
        //Commented out  as per SIR  D-00016020 , Now PM Strategty will depends on field Dispo Lease Renewal strategy in Dispo record
        /**if(mapToHoldDispositionIdWithRenewal.size() > 0) {
        
            //Loop through Ids
            for(Id renewalId : mapToHoldDispositionIdWithRenewal.keySet()) {
            
                //Populating renewal field value
                mapToHoldDispositionIdWithRenewal.get(renewalId).Notes__c = 'Not Renew'; 
            }
            
            //Check for map size to perform update
            if(mapToHoldDispositionIdWithRenewal.size() > 0)
                update mapToHoldDispositionIdWithRenewal.values();  
        }**/
    }  
    
    
    /**  D-00014396
      * @Description    :   method to set For sale value on portfolio unchecked when disposition is deleted and no other disposition with valid criteria is present on portfolio
      *       
      * @CreatedBy      :   saurabh kumar
      * 
      * @arg            :   map of old disposition.
      *
      * @return         :   Void
    **/
    public static void updatePortfolioafterDispositionDeleted(Map<Id, Disposition__c> oldDispositionMap)
    {
         Set<Id> propIdONDisposition = new Set<Id>();
         List<property__c> listPropertyToBeUpdatedOnDispoDelete = new list<Property__C>();
        for(Disposition__c disp : oldDispositionMap.values())
        {
            if(disp.Portfolio__c !=null)
            {
                propIdONDisposition.add(disp.Portfolio__c);
            }
        }
        for(Property__c prop : [select id, For_Sale__c ,Approved_for_Sale__c,Approved_for_Sale_timestamp__c,(select Id  from Dispositions__r 
                                    Where IH_Approval_of_Sale__c = :Constants.YES And BX_Approval_of_Sale__c =:Constants.YES And Submitted_for_IH_Dispo_Approval__c = :Constants.YES
                                    And Dispo_Lease_Renewal_Strategy__c != :Constants.DISPOSITION_OK_TO_RENEW And Listing_Status__c != :Constants.CANCELLED)
                                    from Property__c where Id IN :propIdONDisposition])
        {
            //checking if any other disposition exist on portfolio except this deleted one
          /*  if(!prop.Dispositions__r.isEmpty())
            {
                for(Disposition__c dispo : prop.Dispositions__r)
                {
                    if(dispo.IH_Approval_of_Sale__c == 'No' && dispo.BX_Approval_of_Sale__c == 'No' )
                    {
                        prop.For_Sale__c = False;
                        listPropertyToBeUpdatedOnDispoDelete.add(prop);
                        
                    }
                }
                
            }*/
                if(prop.Dispositions__r.isEmpty() && (prop.For_Sale__c != False || prop.Approved_for_Sale__c != False || prop.Approved_for_Sale_timestamp__c != null))
                {
                    prop.For_Sale__c = false;
                    prop.Approved_for_Sale__c = false;
                    prop.Approved_for_Sale_timestamp__c = null;
                    listPropertyToBeUpdatedOnDispoDelete.add(prop);
                }
            
            
        }
        if(!listPropertyToBeUpdatedOnDispoDelete.isEmpty())
        {
            try
            {
                update listPropertyToBeUpdatedOnDispoDelete;
            }
            catch(DmlException de)
            {
                system.debug(de.getMessage()); 
            }
        }
    }
    
     
      /**  D-00014489  
      * @Description    :   method to populate most recent disposition on residence
      *       
      * @CreatedBy      :   Abhinav Sharma
      * 
      * @arg            :   list of new disposition
      *
      * @return         :   Void
    **/
    public static void mostRecentDispositionOnResidence(List<Disposition__c> newDisposition) {
        
        //Map of disposition Ids on Portfolio
        Map<Id,Id> mapOfDispositionOnPortfolio = new Map<Id,Id>();
        
        //loop over disposition
        for(Disposition__c newDispo : newDisposition) {
            
            //check for property on disposition and populate map with portfolioId and disposition Id
            if(newDispo.Portfolio__c != null)
                mapOfDispositionOnPortfolio.put(newDispo.Portfolio__c , newDispo.Id);
        }
        
        //list of residence     
        List<Residence__c> listOfResidences = new List<Residence__c>();
        
        for(Property__c properties : [Select Residence__c from Property__c 
                                        WHERE Id IN : mapOfDispositionOnPortfolio.keySet()
                                        AND Residence__c != null AND Residence__r.Parent_Structure__c = false]) {
                                                                                    
            Residence__c residence = new Residence__c(Id = properties.Residence__c);
            residence.Most_Recent_Disposition__c = mapOfDispositionOnPortfolio.get(properties.Id);
            listOfResidences.add(residence); 
        }
        
        //update residence
        if(listOfResidences.size() > 0)
            Update listOfResidences;
    }

/**  
      * @Description    :   method to update PM Strategy on Renewal depending on Dispo lease renewal strategy field on disposition record 
      *       
      * @CreatedBy      :   Saurabh kumar
      * 
      * @arg            :   list of new disposition , Map<Id ,Disposition__>
      *
      * @return         :   Void
    **/ 
    public static void updateRenewalBasedonDispo(List<Disposition__c> newDispo , Map<Id ,Disposition__c> oldMap){
        
        
        List<Renewal__c> listRenewaltobeUpdated = new List<Renewal__c>();
        for(Disposition__c dispo : newDispo){
            //condition to check Dispo Lease Renewal Strategy changes to  Non-Renew    
            if(dispo.Dispo_Lease_Renewal_Strategy__c != null 
               && (dispo.Dispo_Lease_Renewal_Strategy__c.equalsIgnoreCase(Constants.DISPOSITION_PM_STRATEGY_NON_RENEW) || dispo.Dispo_Lease_Renewal_Strategy__c.equalsIgnoreCase(Constants.DISPOSITION_PM_STRATEGY_NOT_RENEW))
               && dispo.Renewals__c != null
               && (oldMap == null || !oldMap.containsKey(dispo.id) || Utility.hasFieldChanged(dispo, oldMap, 'Dispo_Lease_Renewal_Strategy__c'))){
               
                listRenewaltobeUpdated.add(new Renewal__c(Id = dispo.Renewals__c , Notes__c = Constants.DISPOSITION_PM_STRATEGY_NOT_RENEW));
            }
            
        }
       
        if(!listRenewaltobeUpdated.isEmpty()){
            update listRenewaltobeUpdated;     
        }
     }
     
 
  /**  
      * @Description    :   Method to Validate Disposition When Created or Modified based on Some Logic 
      *       
      * @CreatedBy      :   Saurabh kumar
      * 
      * @arg            :   list of new disposition , Map<Id ,Disposition__>
      *
      * @return         :   Void
    **/ 
    public static void validateDisposition(List<Disposition__c> newDispo , Map<Id ,Disposition__c> oldMap){
        
        //iterate over Disposition 
        for(Disposition__c dispo : newDispo){
            if(dispo.Listing_Status__c ==Constants.DISPOSITION_UNDER_CONTRACT
              &&( dispo.Approval_Status__c ==NULL || !dispo.Approval_Status__c.equalsIgnoreCase(Constants.DISPOSITION_APPROVED_FORSALE)
                  ||  dispo.Accepted_Contract_Price__c == null || dispo.Contract_Date__c == null || dispo.Projected_Closing_Date__c ==null 
                  ||  dispo.Buyer_s_Name__c == null || dispo.Targeted_Buyer__c == null || dispo.Disposition_Manager__c == null 
                  ||  dispo.Contract_Date__c > System.today() || dispo.Projected_Closing_Date__c < System.today() )
              ){
                    String errorMsg =' Disposition Fields :';
                    If(dispo.Accepted_Contract_Price__c == null)
                    errorMsg = errorMsg +'Accepted Contract Price ,';
                    If(dispo.Buyer_s_Name__c == null)
                    errorMsg = errorMsg +'Buyer\'s Name ,';
                    If(dispo.Targeted_Buyer__c == null)
                    errorMsg = errorMsg +'Targeted Buyer ,';
                    If(dispo.Disposition_Manager__c == null)
                    errorMsg = errorMsg +'Disposition Manager,';
                    IF(dispo.Approval_Status__c ==NULL)
                    errorMsg = errorMsg +'Approval Status ,';
                    IF(dispo.Contract_Date__c ==NULL)
                    errorMsg = errorMsg +'Contract Date ,';
                    IF(dispo.Projected_Closing_Date__c ==NULL)
                    errorMsg = errorMsg +'Projected Closing Date ,';
                    
                    If(errorMsg !=' Disposition Fields :' )
                    errorMsg = errorMsg.removeEnd(',') + ' are Required ,';
                    
                    If(dispo.Approval_Status__c!= NULL && !dispo.Approval_Status__c.equalsIgnoreCase(Constants.DISPOSITION_APPROVED_FORSALE))
                    errorMsg = errorMsg + 'Approval Status Should be \'Approved For Sale\' ,';
                    
                    If( (Utility.hasFieldChanged(dispo,oldMap,'Listing_Status__c') || Utility.hasFieldChanged(dispo,oldMap,'Contract_Date__c') ) && dispo.Contract_Date__c > System.today())
                     errorMsg = errorMsg + 'Contract Date Should not Greater Than TODAY ,';
                     
                    If((Utility.hasFieldChanged(dispo,oldMap,'Listing_Status__c') || Utility.hasFieldChanged(dispo,oldMap,'Projected_Closing_Date__c') ) && dispo.Projected_Closing_Date__c < System.today())
                    errorMsg = errorMsg + 'Projected Closing Date Should not less than TODAY,';
           
                    
                    errorMsg = errorMsg.removeEnd(',') + '  When Listing Status is Under Contract ';
                    
                    dispo.addError(errorMsg);
                
              }
           }
            
        }

  /**  
    * @Description    :   Method for update the fields "Disposition Listing Status" and "Disposition Strategy" on Listing/Rehab object. 
    *       
    * @CreatedBy      :   Poonam Bhargava
    * 
    * @arg            :   List<Disposition__c> newDispo , Map<Id, Disposition__c> mapOfOldDispo
    *
    * @return         :   void
  **/ 
  public static void populateListingRehabFieldsBasedOnDisposition(List<Disposition__c> newDispo , Map<Id, Disposition__c> mapOfOldDispo){
        
    //Set to hold Disposition Ids
    Set<Id> setDispositionIds = new Set<Id>();
    
    //Creating list variable of Listing
    List<Listing__c> listings = new List<Listing__c>();
    
    //Creating list variable of Rehab
    List<Rehab__c> rehabs = new List<Rehab__c>();
    
    //Loop over Disposition Record
    for(Disposition__c disp : newDispo){
          
      //condition to check Disposition fileds got changed    
      if(disp.Listing_Status__c != mapOfOldDispo.get(disp.Id).Listing_Status__c 
        || disp.Disposition_Strategy__c != mapOfOldDispo.get(disp.Id).Disposition_Strategy__c){
        
        //Populate set with Disposition Id
        setDispositionIds.add(disp.Id);
      }  
    }
    
    //Check for set size
    if(setDispositionIds.size() > 0){
        
      //Loop over Listing  
      for(Listing__c listing : [SELECT Id, Disposition_Listing_Status__c, Disposition_Strategy__c,Residence__c,
                     Residence__r.Most_Recent_Disposition__c, Residence__r.Most_Recent_Disposition__r.Listing_Status__c, 
                     Residence__r.Most_Recent_Disposition__r.Disposition_Strategy__c 
                     FROM Listing__c WHERE Residence__c != null 
                     AND Residence__r.Most_Recent_Disposition__c != null 
                     AND Residence__r.Most_Recent_Disposition__c IN: setDispositionIds]){
        
        //Check for eligible criteria and populate Listing field accordingly               
        if(listing.Disposition_Listing_Status__c != listing.Residence__r.Most_Recent_Disposition__r.Listing_Status__c)
          listing.Disposition_Listing_Status__c = listing.Residence__r.Most_Recent_Disposition__r.Listing_Status__c;  
        
        if(listing.Disposition_Strategy__c != listing.Residence__r.Most_Recent_Disposition__r.Disposition_Strategy__c)  
          listing.Disposition_Strategy__c = listing.Residence__r.Most_Recent_Disposition__r.Disposition_Strategy__c;
        
        //Add into list
        listings.add(listing);               
      }
      
      //Loop over Rehab  
      for(Rehab__c rehab : [SELECT Id, Disposition_Listing_Status__c, Disposition_Strategy__c,Home__c,
                     Home__r.Most_Recent_Disposition__c, Home__r.Most_Recent_Disposition__r.Listing_Status__c, 
                     Home__r.Most_Recent_Disposition__r.Disposition_Strategy__c 
                     FROM Rehab__c WHERE Home__c != null 
                     AND Home__r.Most_Recent_Disposition__c != null 
                     AND Home__r.Most_Recent_Disposition__c IN: setDispositionIds]){
        
        //Check for eligible criteria and populate Rehab field accordingly               
        if(rehab.Disposition_Listing_Status__c != rehab.Home__r.Most_Recent_Disposition__r.Listing_Status__c)
          rehab.Disposition_Listing_Status__c = rehab.Home__r.Most_Recent_Disposition__r.Listing_Status__c;  
        
        if(rehab.Disposition_Strategy__c != rehab.Home__r.Most_Recent_Disposition__r.Disposition_Strategy__c)  
          rehab.Disposition_Strategy__c = rehab.Home__r.Most_Recent_Disposition__r.Disposition_Strategy__c;
        
        //Add into list
        rehabs.add(rehab);               
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
}