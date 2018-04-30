/**
 *  Description :   Helper class for property trigger.
 *
 *  Created By  :   Bhavi
 *
 *  Created Date:   07/19/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  v1.1- Bhavi - 09/23/2012 - new method added - populateBKContestInternalDecisionDate
 *                  v1.2 - Vrajesh - 09/29/2012 - new method added - createataskSO , createTaskForTIPCoordinator
 *                  v1.3 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  v1.4 - (06/18/2013) - Rajesh - Added code to cover AM Reporting creation.
 *                  v1.5 - (10/09/2014) - Abhinav - D-00013320 - Fund 5 Changes to Salesforce (Code)
 *                  v1.6 - (11/03/2014) - Abhinav - D-00013423 - Modified owner entity population method
 *                  v1.7 - (27/03/2015) - Prashant - D-00013834 - Update Tip records, added method updateTipRecords
 *                  v1.8 - (08/07/2015) - Saurabh  - D-00014396 - Method to Validate Portfolio Accquisation state  as per disposition rehab status
 *                  v1.9 - (08/25/2015) - Abhinav - D-00014487 - Method to populate PM Email field on violation based on portfolio's owner email
 *                  v1.10 - (09/08/2015) -Saurabh - D-00014561 - Modified method validatePortfolioAccStatus .
 *                  v1.11 - (03-01-2016) -Abhinav -D-00014918 -  Added a new method populateDateCancelledBasedOnAcqStatus
 *                  V1.12 - (06/14/2016) -Poonam Bhargava - D-00015709  - Added a new method populateSubmarket to populate sunmarket field on Portfolio
 *                  v1.13 - (05-30-2016) -Saurabh -D-00015414 - Method to populate Property attributes on Disposition . this method to be called from Process builder
 *                  V1.14 - (6/01/2016)  -Saurabh -D-00015412 - Modified method validatePortfolioAcqStatus for Sold Property Validation
 *                  V1.15 - (06/14/2016) - Poonam Bhargava - D-00015709  - Added a new method populateSubmarket to populate sunmarket field on Portfolio
 *                  V1.16 - (5/30/2016)  - saurabh kumar - D-00015599- Added method updateRelatedRenewalToSold 
 *                  V1.17 - (2/15/2017)  - Saurabh Kumar - D-00016866 updateDateSoldOnPortfolio
 *                  V1.18 - (11/06/2017) - Poonam Bhargava - D-00017574 validatePropertyOnInsert
**/
public class PropertyTriggerHelper {

    //This flag is to control the execution of Property Trigger
    public static Boolean EXECUTE_PROPERTY_TRIGGER = true;

    //This method is to set the property fileds
    public static void setPropertyFields(List<Property__c> properties) {

        //loop through the properties
        for(Property__c property : properties) {

            //Set Properties data
            property.LeaseSign_Date_First_Tenant__c = Utility.populateLeasedSignDateFirstTenant(property);
        }
    }
    
    //(10/09/2014) - Added - Abhinav - D-00013320 - Fund 5 Changes to Salesforce (Code)
    //This method is to set the property "Owner Entity" field
    public static void setPropertyOwnerEntity(List<Property__c> properties) {
    
        //Map to hold the Fund Value-Property Stage as key and corresponding owner entity as value 
        Map<String, String> mapFundAndStateWithOwnerEntity = new Map<String, String>();
        Map<String, String> mapStateWithOwnerEntity = new Map<String, String>();
        Map<String, String> mapNameWithOwnerEntity = new Map<String, String>();
        
        //Loop through all the custom setting records
        for(Owner_Entity_Configuration__c config : Owner_Entity_Configuration__c.getAll().values()) {

            //Check if Key values are not null
            if(String.isBlank(config.Fund__c) && String.isBlank(config.State__c))
                mapNameWithOwnerEntity.put(config.Name, config.Owner_Entity__c);
            
            //Populating maps with appropriate combination of values
            if(String.isNotBlank(config.State__c)) {
                if(String.isNotBlank(config.Fund__c))
                    mapFundAndStateWithOwnerEntity.put(config.Fund__c + '-' + config.State__c,  config.Owner_Entity__c);
                else
                    mapStateWithOwnerEntity.put(config.State__c,  config.Owner_Entity__c);
            }
        }
        
        //Set to hold the residence records Id value
        Set<Id> setResidenceIds = new Set<Id>();
        
        //loop through property records
        for(Property__c pro : properties) {
            if(pro.Residence__c != null)
                setResidenceIds.add(pro.Residence__c);
        }
        
        //Checking for the size value
        if(setResidenceIds.size() > 0) {
            
            //Map to hold the residence record
          Map<Id, Residence__c> mapResidence = new Map<Id, Residence__c>([SELECT ID, Address_State__c FROM Residence__c 
                                                                        WHERE ID IN : setResidenceIds]);
    
            //Loop through new property records
            for(Property__c p : properties) {
            
                //Checking for field values and populating "Owner Entity" field accordingly
                if(p.Securitization_Date__c != null
                    && mapNameWithOwnerEntity.get(String.valueOf(p.Securitization_Date__c)) != null)
                    p.Owner_Entity1__c = mapNameWithOwnerEntity.get(String.valueOf(p.Securitization_Date__c));
                else {
                            
                    //Checking "State" field value for null/blank
                    if(p.Residence__c != null && mapResidence.get(p.Residence__c) != null 
                        && mapResidence.get(p.Residence__c).Address_State__c != null) {
                    
                        //Checking "Fund" field value for null/blank
                        if(String.isNotBlank(p.Fund__c)) {
                            
                            //Checking for the value in the map and populating it
                            if(mapFundAndStateWithOwnerEntity.get(p.Fund__c + '-' + mapResidence.get(p.Residence__c).Address_State__c) != null)
                                p.Owner_Entity1__c = mapFundAndStateWithOwnerEntity.get(p.Fund__c + '-' + mapResidence.get(p.Residence__c).Address_State__c);
                            else
                                p.Owner_Entity1__c = '';
                            
                        } else {
                            //Checking for values in map and then populating the map accordingly
                            if(mapStateWithOwnerEntity.get(mapResidence.get(p.Residence__c).Address_State__c) != null)
                                p.Owner_Entity1__c = mapStateWithOwnerEntity.get(mapResidence.get(p.Residence__c).Address_State__c);
                            else
                                p.Owner_Entity1__c = '';
                        }
                    } else
                        p.Owner_Entity1__c = '';
                }
          }
        }
    }

    //Validate date field
    public static void validateAllDateField(List<SObject> sObjects) {

        Set<String> fieldNotAllowedToHoldFutureDate = Constants.PROPERTY_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE;
        
        //Describe property object
        Schema.DescribeSObjectResult propertyObject = Property__c.sObjectType.getDescribe();

        //Describe Property object and get all the fields
        Map<String, Schema.SObjectField> propertyFieldsMap = propertyObject.fields.getMap();
       
        //loop through the records
        for(SObject sObj : sObjects) {
        
            //Loop through the fields name
            for(String fName : propertyFieldsMap.keySet()) {
            
                //Describe field
                Schema.DescribeFieldResult field = propertyFieldsMap.get(fName).getDescribe();

                //Check if the field is customa and type is Date
                if(field.isCustom() && (!field.isCalculated()) && (field.getType() == DisplayType.Date || field.getType() == DisplayType.DateTime)) {

                    //Check if field is not allowed to hold future date
                    if(fieldNotAllowedToHoldFutureDate.contains(fName.toLowerCase()) && sObj.get(fName) != null) {

                        //check for the value
                        if(field.getType() == DisplayType.Date) {

                            //Getting Local Time String
                            Date myDate = Date.valueOf(sObj.get(fName));
                            List<String> dateString = Date.valueOf(sObj.get(fName)).format().split('/');

                            //Chekc for the future date
                            if(date.newinstance(Integer.valueOf(dateString[2]), Integer.valueOf(dateString[0]), Integer.valueOf(dateString[1])) > Date.today()) {

                                //Error
                                sObj.addError(field.getLabel() + Constants.COLON + Constants.SPACE + Constants.ERROR_FUTUE_DATE);
                            }

                        } else if(field.getType() == DisplayType.DateTime) {

                            //Get the date time value
                            DateTime dtm = DateTime.valueOf(sObj.get(fName));

                            //Convert to Local time zone and dd/MM/yyyy format
                            List<String> datePair = dtm.format('dd/MM/yyyy').split('/');

                            //Check for the future date
                            if( Date.newInstance(Integer.valueOf(datePair[2]), Integer.valueOf(datePair[1]), Integer.valueOf(datePair[0]))  > Date.toDay()) {

                                //Error
                                sObj.addError(field.getLabel() + Constants.COLON + Constants.SPACE + Constants.ERROR_FUTUE_DATE);
                            }
                        }
                    }
                }
            }
        }
    }

    
    //Validate Portfolio Accquisation status
    
    //Added By - Saurabh kumar - 7/8/2015 - D-00014396
    /** Description :   Method to Validate Portfolio Accquisation state  as per disposition rehab status
    *
    *   Created By  :   Saurabh kumar
    *
    *   Arguments   :   List<Property__c> properties, Map<ID, Property__c> propertiesOldMap
    *
    *   Return      :   void
    *
    * 
    **/
    public static void validatePortfolioAccStatus(List<Property__c> properties, Map<ID, Property__c> propertiesOldMap) {
        
        if(Label.ByPassDisposition.equalsIgnoreCase('True'))
            return ; 
        
        Map<Id, property__c> propToValidate = new Map<Id, property__c>();
        
        Set<String> Disposition_YRR_VacancyStatus =  new Set<String>{'VACANT' ,'ADMIN','DOWN'};
        
        Set<String> setPortfolio_Acq_Status_For_Sale = new Set<String>{Constants.PORTFOLIO_ACQ_STATUS_FOR_SALE };
        //System Admin Profile ID 
        Id systemAdminId = [Select id from Profile where Name ='System Administrator'].ID;    
        //Validating  all new portfolio inserted and all old which Acquisition_Status__c field is updated 
    for(Property__c prop : Properties){
                
            if(PropertiesOldMap != null && PropertiesOldMap.containsKey(prop.id)) {
                
                if(prop.For_sale__c 
                    && PropertiesOldMap.get(prop.id).Acquisition_Status__c != null
                    && PropertiesOldMap.get(prop.id).Acquisition_Status__c.equalsIgnoreCase('Sold')
                    && Utility.hasFieldChanged(prop, propertiesOldMap, Schema.SObjectType.Property__c.fields.Acquisition_Status__c.getName())
                    && UserInfo.getProfileId() != systemAdminId){
                    
                    prop.addError(Constants.ERROR_ACQUISITION_FIELD_WHEN_PORTFOLIO_SOLD);
                }
                else if(prop.Acquisition_Status__c != PropertiesOldMap.get(prop.id).Acquisition_Status__c){
                    propToValidate.put(prop.id, prop);
                }
            }
            // When a new Property is created than it's Acquisition_Status__c field should not be 'For Sale' as Child Object (Disposition) only create afer Parent(Portfolio)
            else if(prop.Acquisition_Status__c != null
                      && prop.Acquisition_Status__c == 'For Sale'){       
                prop.addError('Acquisition Status -'+ Constants.ERROR_ACQUISITION_FIELD_WHEN_NO_DIPORB);
            }
        }  
        //Checking list for emptyness
        if(propToValidate.values().size() > 0){
           
            //Taking recordtype of Disposition Rehab record
            Id disposition_Rehab_RecordTypeId  = Schema.SObjectType.Rehab__c.getRecordTypeInfosByName().get('Disposition').getRecordTypeId();
            
            disposition_Rehab_RecordTypeId = disposition_Rehab_RecordTypeId != null ? disposition_Rehab_RecordTypeId : '';
               
            System.debug('Record Type Id for Disposition :-' + disposition_Rehab_RecordTypeId +' ******');
                                                
      for(Property__c  prop  : [select id ,Residence__r.Most_Recent_Yardi_Rent_Roll__r.Current_Tenant_Status__c,
                                        (select id, Stage__c from rehabs__r 
                                        where RecordTypeId =:disposition_Rehab_RecordTypeId) from  
                                        property__c where Id IN:propToValidate.keySet()]){
                                            
                //when  disposition rehab exist on property
        if(!prop.rehabs__r.isEmpty()){
                    
                    String YRR_Vacancy_Status =  prop.Residence__r.Most_Recent_Yardi_Rent_Roll__r.Current_Tenant_Status__c != NULL ? prop.Residence__r.Most_Recent_Yardi_Rent_Roll__r.Current_Tenant_Status__c : ' ' ;
                                  
                    //checking if YRR status is Vacant/Admin/Down than only a property can be For sale 
                    if(setPortfolio_Acq_Status_For_Sale.contains(propToValidate.get(prop.id).Acquisition_Status__c)
                        && !Disposition_YRR_VacancyStatus.Contains(YRR_Vacancy_Status.toUpperCase()) 
                        ) {
                                         
                        propToValidate.get(prop.id).addError('Acquisition Status:-'+Constants.ERROR_ACQUISITION_FIELD_WHEN_DISPORB_YRR_STATUS_NOT_VACANT);
                        break;
                    }
                                  
                    //variable to count active dispositon rehab on portfolio
                    Integer activeDispoRehabWithForSale = 0;
                                  
                    //variable to count canceled disposition rehab on portfolio
                    Integer cancelledDispoRehabWithForSale = 0; 
                                  
                    for(Rehab__c dispoRehab : prop.rehabs__r){
                                      
                        if(dispoRehab.Stage__c == Constants.REHAB_STAGE_CLOSED_CANCELLED
                            && setPortfolio_Acq_Status_For_Sale.contains(propToValidate.get(prop.id).Acquisition_Status__c) ){
                                         
                            cancelledDispoRehabWithForSale++;
                        }
                        
                        if(dispoRehab.Stage__c != Constants.REHAB_STAGE_CLOSED_CANCELLED 
                            && setPortfolio_Acq_Status_For_Sale.contains(propToValidate.get(prop.id).Acquisition_Status__c)  ){
                                          
                            activeDispoRehabWithForSale++;
                        }
                        
                        if((dispoRehab.Stage__c != Constants.REHAB_STAGE_CLOSED_CANCELLED 
                            && !setPortfolio_Acq_Status_For_Sale.contains(propToValidate.get(prop.id).Acquisition_Status__c) )
                            && Disposition_YRR_VacancyStatus.Contains(YRR_Vacancy_Status.toUpperCase())){
                                             
                            if(dispoRehab.Stage__c == Constants.REHAB_STAGE_CLOSED_COMPLETED && propToValidate.get(prop.id).Acquisition_Status__c == Constants.PORTFOLIO_ACQ_STATUS_SOLD)
                                continue;      
                                             
                            propToValidate.get(prop.id).addError( 'Accquisation status:-' + Constants.ERROR_ACQUISITION_FIELD_WHEN_DIPORB);
                        }
                    }
                                  
                    //when only closed cancelled dispositon rehab is present on property ,Accquisation status can not be For sale
                    if(activeDispoRehabWithForSale == 0 && cancelledDispoRehabWithForSale > 0){
                        propToValidate.get(prop.id).addError('Acquisition Status:-'+ Constants.ERROR_ACQUISITION_FIELD_WHEN_NO_DIPORB);
                    } 
                }
                          
                //when no disposition rehab exist on property
                else if(setPortfolio_Acq_Status_For_Sale.contains(propToValidate.get(prop.id).Acquisition_Status__c)){
                    propToValidate.get(prop.id).addError('Acquisition Status:-'+Constants.ERROR_ACQUISITION_FIELD_WHEN_NO_DIPORB);
                }
            }
        }
    }
    
    
    
    //Update Residence
    // Function updated by Rajesh and to only update residences with Parent Structure = False
    public static void updateResidence(List<Property__c> properties, Map<ID, Property__c> propertiesOldMap) {

        MAP<ID, ID> mapResidenceId_PortfolioID = new Map<ID, ID>();

        Set<Id> residenceIds = new Set<Id>();
        for(Property__c property : properties) {
            //if residence is changed
            if(Utility.hasFieldChanged(property, propertiesOldMap, 'Residence__c')) {
                //if residence is not null and acqusition status is not cancelled
                residenceIds.add(property.Residence__c);
            }
        }
    
        List<Residence__c> listResidenceToUpdate = new List<Residence__c>();
        
        //Checing set for size value
        if(residenceIds.size() > 0) { 

            Map<Id, Residence__c> residenceMap = new Map<Id, Residence__c>([Select Id from Residence__c where Id in : residenceIds 
                                                                                and Parent_Structure__c = false]);
  
            for(Property__c property : properties) {
            
                //if residence is changed
                if(Utility.hasFieldChanged(property, propertiesOldMap, 'Residence__c')) {
                    
                    //if residence is not null and acqusition status is not cancelled
                    if(property.Residence__c != null
                        && residenceMap.containsKey(property.Residence__c)
                        && property.Acquisition_Status__c != 'Cancelled') {
                        listResidenceToUpdate.add(new Residence__c(Id = property.Residence__c, Current_Portfolio__c = property.Id));
                    }
                }
            }
        }
        
        //Checking list for size value
        if(listResidenceToUpdate.size() > 0) {
            
            ResidenceTriggerHelper.runValidation = false;
            update listResidenceToUpdate;
            ResidenceTriggerHelper.runValidation = true;
        }
    }

    //Follow Property records by region
    public static void followPropertyByRegion(List<Property__c> properties) {

        //Create set of region
        Set<String> regions = new Set<String>();

        //Loop through the properties
        for(Property__c property : properties) {

            //Check if region is not null
            if(property.Region__c != null && property.Region__c != '')
                regions.add(property.Region__c);
        }

        //Create a map to hold teh User list with  respect to regin anme
        Map<String, List<User>> mapUsersWithRegion = new Map<String, List<User>>();

        //Get all the Users in regions
        for(User user : [Select Id, UserRole.Name from User where IsActive = true]) {

            //Check for teh user role and region
            if(user.UserRole.Name != null) {

                //Get region from role name
                List<String> rolePair = user.UserRole.Name.split('-');

                if(rolePair.size() > 1 && regions.contains(rolePair[1])) {

                    //Check for the existing region in map and associate it with map
                    if(mapUsersWithRegion.containsKey(rolePair[1])) {
                        mapUsersWithRegion.get(rolePair[1]).add(user);
                    } else {
                        mapUsersWithRegion.put(rolePair[1], new List<User>{user});
                    }
                }
            }
        }

        //variable to hold the records to be followed with user
        List<EntitySubscription> entities = new List<EntitySubscription>();

        //Loop through the properties
        for(Property__c property : properties) {

            //Check if region is not null
            if(property.Region__c != null && property.Region__c != '' && mapUsersWithRegion.containsKey(property.Region__c)) {

                //Check in the map
                for(User user : mapUsersWithRegion.get(property.Region__c)) {

                    //Add entities records
                    entities.add(new EntitySubscription(ParentId = property.Id, SubscriberId = user.Id));
                }
            }
        }

        //Check for the entities size
        if(entities.size() > 0)
            insert entities;
    }

    //This method is to give sharing access to 3rd Party users to property records
    public static void sharePropertyWith3rdPartyUsers(Map<Id, Property__c> oldProperties, Map<Id, Property__c> newProperties, Boolean isUpdate) {

        //Create a set of 3rd party agencies, where users need to be given access to the properties records
        Map<Id, Set<Id>> mapPropIdsWithAccIdsForAddSharing = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapPropIdsWithAccIdsForRemoveSharing = new Map<Id, Set<Id>>();

        //Loop through the property records
        //Sharing will be created only in case of new
        if(!isUpdate) {

            //loop through the properties and create a set of
            for(Property__c property : newProperties.values()) {

                //Check if accounts is there and access need to be granted
                if(property.X3rd_Party_Door_Knock_Agency__c != null) {

                    //add in map
                    if(mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id))
                        mapPropIdsWithAccIdsForAddSharing.get(property.Id).add(property.X3rd_Party_Door_Knock_Agency__c);
                    else
                        mapPropIdsWithAccIdsForAddSharing.put(property.Id, new Set<Id>{property.X3rd_Party_Door_Knock_Agency__c});
                }

                //Check if accounts are there and access need to be deleted
                if(property.X3rd_Party_Lease_Agency__c != null && property.X3rd_Party_Lease_Agency__c != property.X3rd_Party_Door_Knock_Agency__c) {

                    //add in map
                    if(mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id))
                        mapPropIdsWithAccIdsForAddSharing.get(property.Id).add(property.X3rd_Party_Lease_Agency__c);
                    else
                        mapPropIdsWithAccIdsForAddSharing.put(property.Id, new Set<Id>{property.X3rd_Party_Lease_Agency__c});
                }
            }
        } else {

            //loop through the properties and create a set of
            for(Property__c property : newProperties.values()) {

                //check for the 3rd party agencies
                //In case of Update if X3rd_Party_Door_Knock_Agency__c field's value gets change, then remove related users access
                //from property record and give access to new users
                //In case of new property, add access for new users
                if(oldProperties.get(property.Id).X3rd_Party_Door_Knock_Agency__c != property.X3rd_Party_Door_Knock_Agency__c) {

                    //Check if accounts is there and access need to be granted
                    if(property.X3rd_Party_Door_Knock_Agency__c != null) {

                        //add in map
                        if(mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id))
                            mapPropIdsWithAccIdsForAddSharing.get(property.Id).add(property.X3rd_Party_Door_Knock_Agency__c);
                        else
                            mapPropIdsWithAccIdsForAddSharing.put(property.Id, new Set<Id>{property.X3rd_Party_Door_Knock_Agency__c});
                    }
                }

                //check for the 3rd party lease agencies
                //In case of Update if X3rd_Party_Lease_Agency__c field's value gets change, then remove related users access
                //from property record and give access to new users
                //In case of new property, add access for new users
                if(oldProperties.get(property.Id).X3rd_Party_Lease_Agency__c != property.X3rd_Party_Lease_Agency__c) {

                    //Check if accounts are there and access need to be deleted
                    if(property.X3rd_Party_Lease_Agency__c != null && property.X3rd_Party_Lease_Agency__c != property.X3rd_Party_Door_Knock_Agency__c) {

                        //add in map
                        if(mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id))
                            mapPropIdsWithAccIdsForAddSharing.get(property.Id).add(property.X3rd_Party_Lease_Agency__c);
                        else
                            mapPropIdsWithAccIdsForAddSharing.put(property.Id, new Set<Id>{property.X3rd_Party_Lease_Agency__c});
                    }
                }

                //Populate map for remove sharing access
                if(oldProperties.get(property.Id).X3rd_Party_Door_Knock_Agency__c != property.X3rd_Party_Door_Knock_Agency__c) {

                    //Check if accounts is there and access need to be granted
                    if(oldProperties.get(property.Id).X3rd_Party_Door_Knock_Agency__c != null) {

                        //door knok agency Id
                        Property__c oldProperty = oldProperties.get(property.Id);
                        Id doorKnockAgency = oldProperty.X3rd_Party_Door_Knock_Agency__c;

                        //add in map if this is not added  for new Sharing
                        if(!mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id)
                            || !mapPropIdsWithAccIdsForAddSharing.get(property.Id).contains(doorKnockAgency)) {

                            //add in map
                            if(mapPropIdsWithAccIdsForRemoveSharing.containsKey(property.Id))
                                mapPropIdsWithAccIdsForRemoveSharing.get(property.Id).add(oldProperty.X3rd_Party_Door_Knock_Agency__c);
                            else
                                mapPropIdsWithAccIdsForRemoveSharing.put(property.Id, new Set<Id>{oldProperty.X3rd_Party_Door_Knock_Agency__c});
                        }
                    }
                }

                //Populate map for remove Sharing
                if(oldProperties.get(property.Id).X3rd_Party_Lease_Agency__c != property.X3rd_Party_Lease_Agency__c
                    && oldProperties.get(property.Id).X3rd_Party_Lease_Agency__c != oldProperties.get(property.Id).X3rd_Party_Door_Knock_Agency__c) {

                    //Check if accounts is there and access need to be granted
                    if(oldProperties.get(property.Id).X3rd_Party_Lease_Agency__c != null) {

                        //door knok agency Id
                        Property__c oldProperty = oldProperties.get(property.Id);
                        Id leaseAgency = oldProperty.X3rd_Party_Lease_Agency__c;

                        //add in map if this is not added  for new Sharing
                        if(!mapPropIdsWithAccIdsForAddSharing.containsKey(property.Id)
                            || !mapPropIdsWithAccIdsForAddSharing.get(property.Id).contains(leaseAgency)) {

                            //add in map
                            if(mapPropIdsWithAccIdsForRemoveSharing.containsKey(property.Id))
                                mapPropIdsWithAccIdsForRemoveSharing.get(property.Id).add(oldProperty.X3rd_Party_Lease_Agency__c);
                            else
                                mapPropIdsWithAccIdsForRemoveSharing.put(property.Id, new Set<Id>{oldProperty.X3rd_Party_Lease_Agency__c});
                        }
                    }
                }
            }
        }

        //Check if there are records to process
        if(mapPropIdsWithAccIdsForAddSharing.size() > 0 || mapPropIdsWithAccIdsForRemoveSharing.size() > 0) {

            //Create a set Of Users where Sharing needs to be removed
            Set<Id> accountsToQuery = new Set<Id>();

            //Prepare the Users set
            for(Set<Id> accIds : mapPropIdsWithAccIdsForAddSharing.values()) {

                //Add in set
                accountsToQuery.addAll(accIds);
            }

            //Prepare the Users set
            for(Set<Id> accIds : mapPropIdsWithAccIdsForRemoveSharing.values()) {

                //Add in set
                accountsToQuery.addAll(accIds);
            }

            //Create a map to hold the Users for 3rd party Agencies
            Map<Id, Set<Id>> mapAccountIdWithUsers = new Map<Id, Set<Id>>();

            //Check for size
            if(accountsToQuery.size() > 0){
            
                //Get all the 3rd party agencies uses related to account ids
                for(X3_Party_Users__c partyUser : [Select Id, User__c, X3_Party_Agency__c from X3_Party_Users__c where X3_Party_Agency__c IN: accountsToQuery]) {

                    //Check if account is already added, then id user in existing set
                    if(mapAccountIdWithUsers.containsKey(partyUser.X3_Party_Agency__c)) {

                        //Add user in set
                        mapAccountIdWithUsers.get(partyUser.X3_Party_Agency__c).add(partyUser.User__c);
                    } else {

                        //Add user in set
                        mapAccountIdWithUsers.put(partyUser.X3_Party_Agency__c, new Set<Id>{partyUser.User__c});
                    }
                }
            }

            //Create a set of Users to Query
            Set<Id> usersToQuery = new Set<Id>();

            if(mapAccountIdWithUsers.values().size() > 0){
            
                //Prepare users data
                for(Set<Id> userIds : mapAccountIdWithUsers.values()) {

                    //Add users in set
                    usersToQuery.addAll(userIds);
                }
            }

            //create alist of records to be deleted
            List<Property__Share> pSToBeDeleted = new List<Property__Share>();
            
            //Check for size
            if(usersToQuery.size() > 0){
            
                //Query data from Property__Share object
                for(Property__Share pShare : [Select Id, ParentId, UserOrGroupId from Property__Share where
                                                (ParentId IN: mapPropIdsWithAccIdsForAddSharing.keySet()
                                                OR ParentId IN: mapPropIdsWithAccIdsForRemoveSharing.keySet()) AND UserOrGroupId IN: usersToQuery
                                                AND RowCause =: Schema.Property__Share.RowCause.X3rd_Party_User__c]) {

                    //Check if record needs to be deleted
                    if(mapPropIdsWithAccIdsForRemoveSharing.containsKey(pShare.ParentId)) {

                        //loop through the 3rd party accounts
                        for(Id accId : mapPropIdsWithAccIdsForRemoveSharing.get(pShare.ParentId)) {

                            //Check for the user and add record in the list to be deleted
                            if(mapAccountIdWithUsers.containsKey(accId) && mapAccountIdWithUsers.get(accId).contains(pShare.UserOrGroupId)) {

                                //Add record in list to be deleted
                                pSToBeDeleted.add(pShare);
                            }
                        }
                    } else if(mapPropIdsWithAccIdsForAddSharing.containsKey(pShare.ParentId)) {

                        //loop through the 3rd party accounts
                        for(Id accId : mapPropIdsWithAccIdsForAddSharing.get(pShare.ParentId)) {

                            //Check for the user and add record in the list to be deleted
                            if(mapAccountIdWithUsers.containsKey(accId) && mapAccountIdWithUsers.get(accId).contains(pShare.UserOrGroupId)) {

                                //No need to add sharing record as this is already in database
                                mapAccountIdWithUsers.get(accId).remove(pShare.UserOrGroupId);
                            }
                        }
                    }
                }
            }

            //delete shring records
            if(pSToBeDeleted.size() > 0)
                delete pSToBeDeleted;

            //Create a list of Property share records to be inserted
            List<Property__Share> propertiesSharingToInsert = new List<Property__Share>();

            //Loop through the map and create the sharing records
            for(Id parentId : mapPropIdsWithAccIdsForAddSharing.keySet()) {

                //loop through the 3rd party accounts
                for(Id accId : mapPropIdsWithAccIdsForAddSharing.get(parentId)) {

                    //Check if account has users
                    if(mapAccountIdWithUsers.containsKey(accId)) {

                        //Get all teh users
                        for(Id userOrGroupId : mapAccountIdWithUsers.get(accId)) {

                             //Add user for Sharing access
                            propertiesSharingToInsert.add(new Property__Share(UserOrGroupId = userOrGroupId, ParentId = parentId,
                                                                                AccessLevel = Constants.ACCESS_LEVEL_EDIT,
                                                                                RowCause = Schema.Property__Share.RowCause.X3rd_Party_User__c));
                        }
                    }
                }
            }

            //insert sharing records
            if(propertiesSharingToInsert.size() > 0)
                insert propertiesSharingToInsert;
        }
    }

    //Method to set Yardi_Integration__c as true if insert
    public static void setYardiIntegrrationFlag(List<Property__c> properties){
        //loop over property record list
        for(Property__c p : properties){
            //if record id is null, this will be true on before insert
            if(p.id == null) {
                p.Yardi_Integration__c = true;
            }
        }
    }

    //Method to create Yardi Property record if insert
    public static void createYardiProperty(List<Property__c> properties){
        List<Yardi_Property__c> listYP = new List<Yardi_Property__c>();
        //loop over property record list
        for(Property__c p : properties){
            listYP.add(new Yardi_Property__c(Property__c = p.Id));
        }
        if(listYP.size() > 0)
            insert listYP;
    }

    //Method to create Actual Results record if insert
    public static void createAactualResults(List<Property__c> properties){
        List<Actual_Results__c> listAR = new List<Actual_Results__c>();
        //loop over property record list
        for(Property__c p : properties){
            listAR.add(new Actual_Results__c(Property__c = p.Id));
        }
        if(listAR.size() > 0)
            insert listAR;
    }

    // Method to set Yardi_Integration__c as true if attribute is updated
    public static void setYardiIntegrrationFlagOnAttributeUpdate(List<Property__c> properties, Map<Id, Property__c> oldProperties ){

        List<String> listAttributeFields = new List<String>{ 'Acquisition_Status__c' };
        //loop over property record list
        for(Property__c p : properties){
          for( String fieldAPIName : listAttributeFields ) {
              // if attribute field is updated
              if( trigger.isInsert || ( trigger.isUpdate && Utility.hasFieldChanged( p, oldProperties, fieldAPIName)) ) {
                  p.Yardi_Attributes_PropertyStatus__c = true;
              }
          }
        }
    }

    //Method to create Violation record if insert
    public static void createViolation(List<Property__c> properties){
        List<Violation__c> listViolation = new List<Violation__c>();
        //loop over property record list
        for(Property__c p : properties){
            listViolation.add(new Violation__c(Property__c = p.Id));
        }
        if(listViolation.size() > 0)
            insert listViolation;

    }

    public static void createBoxPropertyFolder(List<Property__c> properties, MAP<Id, Property__c> mapProperties){

        Set<Id> setCreateFolderIds = new Set<Id>();
        Set<Id> setPromoteFolderIds = new Set<Id>();

        for(Property__c p : properties) {
            if(p.Box_Folder_Id__c == null) {
                setCreateFolderIds.add(p.Id);
            }
            else {
                setPromoteFolderIds.add(p.Id);
            }
        }

        if(setCreateFolderIds.size() > 0) {
            //commented because of SIR - D-00003775
            //Uncommented because of error source folder not found making debugging difficult on S3
            // As  promote is commented this gets uncommented
            //commented because of SIR - D-00008515
            //BoxSearchAndCreateMissingFolders.createMassFolderHierarchyIHServiceFuture(setCreateFolderIds, IHBoxIntegrationService.OBJECT_TYPE_PORTFOLIO);
        }
        if(setPromoteFolderIds.size() > 0) {
          //commented because of error source folder not found making debugging difficult on S3
          //BoxSearchAndCreateMissingFolders.promoteMassFolderHierarchyIHServiceFuture(setPromoteFolderIds, IHBoxIntegrationService.OBJECT_TYPE_PORTFOLIO);
        }

    }

    //This method is to populate the BK Contest Internal Decision Date of BK object
    public static void populateBKContestInternalDecisionDate(Map<Id, Property__c> mapProperties) {

        //Create a list of BK properties to be updated
        List<BK__c> listBKs = new List<BK__c>();

        //Fetch BK data Related to teh property
        for(BK__c bk : [Select Id, Property__c, Contest_Internal_Decision_Date__c from BK__c where Property__c IN: mapProperties.keySet()]) {

            //Check BK_Contest_Internal_Decision_Date__c is not equals to child's BK_Contest_Internal_Decision_Date__c
            if(mapProperties.get(bk.Property__c).BK_Contest_Internal_Decision_Date__c != null
                && mapProperties.get(bk.Property__c).BK_Contest_Internal_Decision_Date__c != bk.Contest_Internal_Decision_Date__c) {

                //Set data
                bk.Contest_Internal_Decision_Date__c = mapProperties.get(bk.Property__c).BK_Contest_Internal_Decision_Date__c;

                //Add in the list to be updated
                listBKs.add(bk);
            }
        }

        //Update data
        if(listBKs.size() > 0)
            update listBKs;
    }

    //this method is to create a task for related user on property record
    public static task createataskSO(Property__c property , ID relatedUserId,Date Duedate){
        Task newTask = new Task();
        newTask.WhatId = property.id;
        newTask.OwnerId = relatedUserId;
        newTask.Subject = 'Determine TIP Resolution of Section 8 Property - '+property.Property_Code__c;
        newTask.priority= 'Normal';
        newTask.status = 'Not Started';
        newTask.description = 'Determine TIP Resolution of Section 8 Property - '+property.Property_Code__c;

        newTask.ActivityDate = Duedate;

        return newTask;
    }

    //Method to create a task for TIP coordinator
    public static void createTaskForTIPCoordinator(Map<Id, Property__c> oldMapProperties,list<Property__c> newListProperties){
        list<Task> tasktoInsert = new list<task>();
        for(Property__c propertyRecord : newListProperties){
            if(propertyRecord.Abandoned_Property__c && !(oldMapProperties.get(propertyRecord.id)).Abandoned_Property__c){
                Task newTask = new Task();
                newTask = createataskSO(propertyRecord,propertyRecord.TIP_Coordinator__c,date.today()+2);
                newTask.Subject = 'Abandoned Property Post Eviction - '+propertyRecord.Property_Code__c;
                newTask.description = 'The tenants of property '+propertyRecord.Property_Code__c+' at'+ propertyRecord.Property_Street__c+', '+propertyRecord.Property_City__c +' were evicted on '+ propertyRecord.Constable_Lock_Date__c+' , however abandoned property remains at the residence.Please take appropriate steps.';
                tasktoInsert.add(newTask);
            }
            if((propertyRecord.Section_8_Housing__c && !(oldMapProperties.get(propertyRecord.id)).Section_8_Housing__c)
                        && propertyRecord.Pre_Existing_Lease_Period_End__c < date.today() ){
                        tasktoInsert.add(createataskSO(propertyRecord,propertyRecord.TIP_Coordinator__c,propertyRecord.Pre_Existing_Lease_Period_End__c));
                    }
        }
        try{
            if(tasktoInsert.size() > 0)
                
                insert tasktoInsert;
        }catch(exception e){

        }
    }

    //Method to Create task for Rehab Manager – review Rehab Budget
    public static void createataskRehabManager(List<Property__c> listNewProperty, MAP<ID, Property__c> mapOldProperty){

        List<Task> listRehabReviewTask  = new List<Task>();

        for(Property__c p : listNewProperty) {
            if(p.PTL_COMPLETE_DATE__c != null && p.PTL_COMPLETE_DATE__c != mapOldProperty.get(p.Id).PTL_COMPLETE_DATE__c) {

                Task rehabReviewTask = new Task(WhatId = p.id, OwnerId = p.Rehab_PM__c,
                                Subject = 'Review Rehab Budget', Priority= 'Normal', Status = 'Not Started',
                                Description = 'Review Rehab Budget - '+ p.Property_Code__c, ActivityDate = p.PTL_COMPLETE_DATE__c);

                listRehabReviewTask.add(rehabReviewTask);
            }
        }
        if(listRehabReviewTask.size() > 0)
            insert listRehabReviewTask;
    }

    /*
    //Method to send email to Rehab Crew Intake contact
    public static void sendEmailToRehabCrewIntakeContact(List<Property__c> listNewProperty, MAP<ID, Property__c> mapOldProperty) {
         Id templateID = [Select Id from EmailTemplate where DeveloperName = 'Rehab_Crew_Intake_Email'].Id;
         MAP<Id, Id> mapPropertyAccounts = new MAP<Id, Id>();
         Set<Id> setRehabPMIds = new Set<Id>();
         List<Property__c> listPropertiesInContext = new List<Property__c>();
         for(Property__c p : listNewProperty) {
             if(p.Rehab_Crew_Notification__c && (!mapOldProperty.get(p.Id).Rehab_Crew_Notification__c)) {
                 if(p.Rehab_Crew__c != null) {
                    mapPropertyAccounts.put(p.Id, p.Rehab_Crew__c);
                 }
                 if(p.Rehab_PM__c != null) {
                    setRehabPMIds.add(p.Rehab_PM__c);
                 }
                 listPropertiesInContext.add(p);
             }
         }
         if(mapPropertyAccounts.size() > 0) {
             Map<Id, Account> mapAccounts = new MAP<ID, Account>([Select Id, (Select Id from Contacts where Role__c =: 'Rehab Crew Intake Contact' And No_Longer_with_Company__c =: False Limit 1) From Account Where Id in: mapPropertyAccounts.values()]);
             Map<Id, User> mapUsers = new MAP<ID, User>([Select Email From User Where Id in: setRehabPMIds]);
             List<Messaging.SingleEmailMessage> listSingleEmail = new List<Messaging.SingleEmailMessage>();
             for(Property__c p : listPropertiesInContext) {
                 if(p.Rehab_Crew_Notification__c && (!mapOldProperty.get(p.Id).Rehab_Crew_Notification__c)
                        && mapAccounts.get(p.Rehab_Crew__c) != null
                        && mapAccounts.get(p.Rehab_Crew__c).Contacts.size() > 0) {
                     //SingleEmailMessage instance
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     mail.setTemplateId(templateID);
                     mail.setTargetobjectid(mapAccounts.get(p.Rehab_Crew__c).Contacts.get(0).Id);
                     mail.setWhatId(p.Id);
                     if(mapUsers.get(p.Rehab_PM__c) != null && mapUsers.get(p.Rehab_PM__c).Email != null) {
                         mail.setCcAddresses(new List<String>{String.valueOf(mapUsers.get(p.Rehab_PM__c).Email)});
                     }
                     listSingleEmail.add(mail);
                 }
             }
             Messaging.sendEmail(listSingleEmail);
         }
    }
    */

    public static void setOrganizationLastAcquisitionDate(List<Property__c> listNewProperty, MAP<ID, Property__c> mapOldProperty) {
       /*
       Property_Rollup__c propertyRollUp = Property_Rollup__c.getOrgDefaults();
       Date lastAcquisitionDate = propertyRollUp.Last_Acquisition_Date__c;
       for(Property__c p : listNewProperty) {
           if( (
                   (trigger.isInsert && p.Acquisition_Date__c != null) ||
                   (trigger.isUpdate && p.Acquisition_Date__c != mapOldProperty.get(p.Id).Acquisition_Date__c )
               )
               &&
               (  propertyRollUp.Last_Acquisition_Date__c == null
                   ||
                  propertyRollUp.Last_Acquisition_Date__c < p.Acquisition_Date__c
               )
             ) {
               propertyRollUp.Last_Acquisition_Date__c = p.Acquisition_Date__c;
           }
       }
       update propertyRollUp;
       */
    }

    public static void validateRehabCrewEmailBeforeSendingEmail(List<Property__c> listNewProperty, MAP<ID, Property__c> mapOldProperty) {

        MAP<Id, Id> mapPropertyAccounts = new MAP<Id, Id>();

        for(Property__c p : listNewProperty) {
             if(p.Rehab_Crew_Notification__c && (!mapOldProperty.get(p.Id).Rehab_Crew_Notification__c)) {

                 if(p.Rehab_Crew__c != null) {
                    mapPropertyAccounts.put(p.Id, p.Rehab_Crew__c);
                 }
             }
         }

         if(mapPropertyAccounts.size() > 0) {

             Map<Id, Account> mapAccounts = new MAP<ID, Account>([Select Id, Rehab_Crew_Intake_Contact__c, Rehab_Crew_Intake_Contact__r.Role__c, Rehab_Crew_Intake_Contact__r.Email, Rehab_Crew_Intake_Contact__r.No_Longer_with_Company__c
                                          From Account
                                                            Where Id in: mapPropertyAccounts.values()]);
             String REHAB_CREW_INTAKE_CONTACT = 'Rehab Crew Intake Contact';

             for(Property__c p : listNewProperty) {

                 if(p.Rehab_Crew_Notification__c && (!mapOldProperty.get(p.Id).Rehab_Crew_Notification__c)
                        && mapAccounts.get(p.Rehab_Crew__c) != null
                    ) {
                       if(mapAccounts.get(p.Rehab_Crew__c).Rehab_Crew_Intake_Contact__c == null) {
                         p.addError(Label.Rehab_Crew_Message1);
                         return;
                       }
                       else if(mapAccounts.get(p.Rehab_Crew__c).Rehab_Crew_Intake_Contact__r.Role__c != REHAB_CREW_INTAKE_CONTACT) {
                         p.addError(Label.Rehab_Crew_Message2);
                         return;
                       }
                     else if(mapAccounts.get(p.Rehab_Crew__c).Rehab_Crew_Intake_Contact__r.Email == null) {
                       p.addError(Label.Rehab_Crew_Message3);
                       return;
                     }
                     else  if(mapAccounts.get(p.Rehab_Crew__c).Rehab_Crew_Intake_Contact__r.No_Longer_with_Company__c) {
                       p.addError(Label.Rehab_Crew_Message4);
                       return;
                     }
                     p.Rehab_Crew_Intake_Contact_Email__c = mapAccounts.get(p.Rehab_Crew__c).Rehab_Crew_Intake_Contact__r.Email;
                 }
             }

         }
    }

    public static void validateLawn_PoolMaintenanceEmailBeforeSendingEmail(List<Property__c> listNewProperty, MAP<ID, Property__c> mapOldProperty) {

         MAP<Id, Id> mapPropertyAccountsLawnM = new MAP<Id, Id>();
         MAP<Id, Id> mapPropertyAccountsPoolM = new MAP<Id, Id>();

         List<Property__c> listPropertiesInContext = new List<Property__c>();

         for(Property__c p : listNewProperty) {
             if(p.Actual_Move_in_Date__c != null
               && (trigger.isInsert || p.Actual_Move_in_Date__c != mapOldProperty.get(p.Id).Actual_Move_in_Date__c)) {

                 if(p.Lawn_Maintenance_Team__c != null) {
                    mapPropertyAccountsLawnM.put(p.Id, p.Lawn_Maintenance_Team__c);
                 }

                 if(p.Pool_Maintenance_Team__c != null) {
                    mapPropertyAccountsPoolM.put(p.Id, p.Pool_Maintenance_Team__c);
                 }

                 listPropertiesInContext.add(p);
             }


         }

         if(mapPropertyAccountsLawnM.size() > 0 || mapPropertyAccountsPoolM.size() > 0) {

             Map<Id, Account> mapAccounts = new MAP<ID, Account>([Select Id, Lawn_Maintenance_End_Service_Contact__c, Lawn_Maintenance_End_Service_Contact__r.Role__c, Lawn_Maintenance_End_Service_Contact__r.Email, Lawn_Maintenance_End_Service_Contact__r.No_Longer_with_Company__c,
                                          Pool_Maintenance_End_Service_Contact__c, Pool_Maintenance_End_Service_Contact__r.Role__c, Pool_Maintenance_End_Service_Contact__r.Email, Pool_Maintenance_End_Service_Contact__r.No_Longer_with_Company__c
                                                            From Account
                                                            Where Id in: mapPropertyAccountsLawnM.values() OR Id in : mapPropertyAccountsPoolM.values()]);



             String LAWN_MAINTENANCE_END_SERVICE_CONTACT = 'Lawn Maintenance End Service Contact';
             String POOL_MAINTENANCE_END_SERVICE_CONTACT = 'Pool Maintenance End Service Contact';

             for(Property__c p : listNewProperty) {

                 if(p.Actual_Move_in_Date__c != null
                        &&
                        (trigger.isInsert || p.Actual_Move_in_Date__c != mapOldProperty.get(p.Id).Actual_Move_in_Date__c)){


                     if(p.Lawn_Maintenance_Team__c != null) {

                       if(mapAccounts.get(p.Lawn_Maintenance_Team__c).Lawn_Maintenance_End_Service_Contact__c == null) {
                         p.addError(Label.Lawn_Maintenance_Message1);
                         return;
                       }
                       else if(mapAccounts.get(p.Lawn_Maintenance_Team__c).Lawn_Maintenance_End_Service_Contact__r.Role__c != LAWN_MAINTENANCE_END_SERVICE_CONTACT) {
                         p.addError(Label.Lawn_Maintenance_Message2);
                         return;
                       }
                     else if(mapAccounts.get(p.Lawn_Maintenance_Team__c).Lawn_Maintenance_End_Service_Contact__r.Email == null) {
                       p.addError(Label.Lawn_Maintenance_Message3);
                       return;
                     }
                     else  if(mapAccounts.get(p.Lawn_Maintenance_Team__c).Lawn_Maintenance_End_Service_Contact__r.No_Longer_with_Company__c) {
                       p.addError(Label.Lawn_Maintenance_Message4);
                       return;
                     }
                     p.Lawn_Maintenance_End_Service_Email__c = mapAccounts.get(p.Lawn_Maintenance_Team__c).Lawn_Maintenance_End_Service_Contact__r.Email;
                    }

                     if(p.Pool_Maintenance_Team__c != null) {

                       if(mapAccounts.get(p.Pool_Maintenance_Team__c).Pool_Maintenance_End_Service_Contact__c == null) {
                         p.addError(Label.Pool_Maintenance_Message1);
                         return;
                       }
                     else if(mapAccounts.get(p.Pool_Maintenance_Team__c).Pool_Maintenance_End_Service_Contact__r.Role__c != POOL_MAINTENANCE_END_SERVICE_CONTACT) {
                         p.addError(Label.Pool_Maintenance_Message2);
                         return;
                       }
                     else if(mapAccounts.get(p.Pool_Maintenance_Team__c).Pool_Maintenance_End_Service_Contact__r.Email == null) {
                       p.addError(Label.Pool_Maintenance_Message3);
                       return;
                     }
                     else  if(mapAccounts.get(p.Pool_Maintenance_Team__c).Pool_Maintenance_End_Service_Contact__r.No_Longer_with_Company__c) {
                       p.addError(Label.Pool_Maintenance_Message4);
                       return;
                     }
                     p.Pool_Maintenance_End_Service_Email__c = mapAccounts.get(p.Pool_Maintenance_Team__c).Pool_Maintenance_End_Service_Contact__r.Email;
                     }

                 }
             }
         }
    }

    public static void createRehabAndListingRecords(List<Property__c> newList) {
        PortfolioManagement.createRehabAndListingRecords(newList);
    }

    // Function to create AM Reporting records
    public static void createAMReportingRecords(List<Property__c> properties) {
        List<AM_Reporting__c> reportingRecordsToInsert = new List<AM_Reporting__c>();
        for(Property__c prop : properties) {
            reportingRecordsToInsert.add(new AM_Reporting__c(Portfolio__c = prop.Id));
        }
        if(reportingRecordsToInsert.size() > 0)
            insert reportingRecordsToInsert;
    }

    private static Map<String, String> mapRegion {
        get {
            if(mapRegion == null) {
                mapRegion = new Map<String, String>();

                //Loop through new records list
                for(Region__c region : [Select Id, Name, Property_Code_Base__c from Region__c where Property_Code_Base__c != null]) {

                    //Add region name in set
                    mapRegion.put(region.Name.toLowerCase(), region.Property_Code_Base__c);
                }
            }
            return mapRegion;
        }
        private set;
    }

    //Create a map to hold the Property Code with respect to state-region
    private static Map<String, Integer> mapPropertyCode {
        get {
            //Get the max property code
            if(mapPropertyCode == null) {
                mapPropertyCode = new Map<String, Integer>();

                for(AggregateResult aggr : [Select Region__c region, Max(Property_Code_Number_Part__c) code from Property__c where Region__c != null AND Property_Code_Number_Part__c != null group by Region__c]) {

                    //Create key and value for Map
                    String key = String.valueOf(aggr.get('region')).toLowerCase();
                    Integer val = Integer.valueOf(aggr.get('code'));

                    //Add in map
                    mapPropertyCode.put(key, val);
                }
            }
            return mapPropertyCode;
        }
        private set;
    }

    // Function to generate a Property Code for a new property
    public static String getPropertyCode(Property__c prop) {

        String propertyCode = '';

        //populate Property Code
        if(prop.Region__c != null) {

            //Create key for Property code map
            String key = prop.Region__c.toLowerCase();

            //Max code from code map
            Integer propNumber = 1;  // For first one if the region is new

            if(mapPropertyCode.containsKey(key)) {
                propNumber = mapPropertyCode.get(key) + 1;

            }

            // Now construct and set the property code
            String newNumberPart = '0000' + propNumber;

            if(mapRegion.containsKey(prop.Region__c.toLowerCase())) {
                String regionBase = mapRegion.get(prop.Region__c.toLowerCase());
                propertyCode = regionBase.toUpperCase() + newNumberPart.right(4);
            }
        }
        return propertyCode;
    }

    /*
      @description => Method to create Actual Results record if insert
      @args
          properties  => new properties inserted
    */
    public static void createPortfolioDocCompliance(List<Property__c> properties){

        // create instance of list for Portfolio_Doc_Compliance__c
        List<Portfolio_Doc_Compliance__c> listPDC = new List<Portfolio_Doc_Compliance__c>();

        // loop over property record list
        for(Property__c p : properties){
            // add to list
            listPDC.add( new Portfolio_Doc_Compliance__c( Portfolio__c = p.Id ) );
        }
        if(listPDC.size() > 0){
            // insert pdc
            insert listPDC;
        } 
    }
    
    
    /**
    * @description Method to update TIP record's record type based on 
    *              Occupied Status @ acquisition field value on portfolio
    * @date 27-March-2015
    * @params PropertyNewValues, PropertyOldValues
    */
    public static void updateTipRecords(List<Property__c> propertyNewValues, Map<Id, Property__c> propertyOldValues){
        
        //Get record types of TIP object
        Map<String, String> recordTypeMap = new Map<String, String>();
        List<RecordType> recordTypeTipsList = [select Id, Name from RecordType where SObjectType = 'TIP_Tracking__c'];
        if(recordTypeTipsList != null || (!recordTypeTipsList.isEmpty())){
            for(RecordType type: recordTypeTipsList)
                recordTypeMap.put(type.Name, type.Id);
        }
        System.debug('*** recordTypeMap *** '+recordTypeMap);
        //set to hold property related tip records id
        Map<Id, Property__c> propertyRecordsUpdatedMap = new Map<Id, Property__c>();
        
        //Check if property Occupied Status @ acquisition has been changed
        // If yes, add to id set
        for(Property__c property: propertyNewValues){
            if(Utility.hasFieldChanged(property, propertyOldValues, 'Occupied_Status_Acquisition__c'))
                propertyRecordsUpdatedMap.put(property.Id, property);
        }
        
        List<TIP_Tracking__c> tipRecordsToUpdateList = new List<TIP_Tracking__c>();
        
        if(propertyRecordsUpdatedMap.values().size() > 0){
            
            Map<Id, TIP_Tracking__c> tipRecordsToUpdateMap = new Map<Id, TIP_Tracking__c>([select Id, Portfolio__c, RecordTypeId from TIP_Tracking__c where Portfolio__c IN: propertyRecordsUpdatedMap.keySet()]);
        
            //Update Tip records according to Occupied Status @ acquisition fields value
            for(Tip_Tracking__c tip: tipRecordsToUpdateMap.values()){
                if(propertyRecordsUpdatedMap.get(tip.Portfolio__c).Occupied_Status_Acquisition__c.equals('Purchased Rented'))
                    tip.RecordTypeId = recordTypeMap.get('Purchased Rented');
                else
                    tip.RecordTypeId = recordTypeMap.get('Standard TIP');
                
                tipRecordsToUpdateList.add(tip);
            }
        }
        if(!tipRecordsToUpdateList.isEmpty())
            upsert tipRecordsToUpdateList;
    }
    
    //Added by Abhinav Sharma -  D-00014487 (08/25/2015) 
    /**
      * @Description    :   Method for maintain violation field  "PM Email" values.
      *
      * @arg            :   List of new properties, map of old properties.
      *
      * @return         :   Void
    **/
    public static void populatePMEmailOnViolations(List<Property__c> properties, Map<ID, Property__c> mapOldProperties){
    
        //Set to hold Portfolio Id
        Set<Id> setPortfolioIds = new Set<Id>();  
        
        //Loop through Trigger.new
        for(Property__c pro : properties){
        
            //Check for conditions and populate set with portfolio ids
            if(pro.OwnerId != null && mapOldProperties != null
               && mapOldProperties.get(pro.Id).ownerId != pro.OwnerId) {
                setPortfolioIds.add(pro.Id);      
            }
                    
        }
        
        //Check for set size
        if(setPortfolioIds.size() > 0) {
            
            //Map to hold the voilation records to be updated
            Map<Id, Violations__c> mapViolations = new Map<Id, Violations__c>();
        
            //Loop through violation
            for(Violations__c vio : [Select Id, Portfolio__c, PM_Email__c, Portfolio__r.OwnerId, Portfolio__r.Owner.Type,
                                        Portfolio__r.Owner.Email, Portfolio__r.Owner.IsActive FROM Violations__c 
                                        where Portfolio__c != null AND Portfolio__c IN : setPortfolioIds]){
                
                //Check map for key and populate voilation field
                if(vio.Portfolio__r.Owner.Email != null && vio.Portfolio__r.Owner.Type != 'Queue' 
                   && vio.Portfolio__r.Owner.IsActive != null && vio.Portfolio__r.Owner.IsActive) {
                    vio.PM_Email__c = vio.Portfolio__r.Owner.Email;       
                }
                else
                    vio.PM_Email__c = null; 
                                            
                //Populating map with appropriate values
                mapViolations.put(vio.Id, vio);                            
            }
            
            //Check for map size and update map
            if(mapViolations.values().size() > 0){
                update mapViolations.values();
            }
        }       
    }
    
    //Added by Abhinav Sharma  - D-00014918 (03-01-2016)
    /**
     *  @description  :  Method to populate 'Date Cancelled' field on Potfolio based on Acquisition Status
      *
      *  @arg      :  List of new properties, map of old properties.
      *
      *  @return      :  Void  
  **/
 
  public static void populateDateCancelledBasedOnAcqStatus(List<Property__c> properties, Map<Id, Property__c> mapOldProperties){
    
    //Initialize string constant
    String CANCELLED = 'Cancelled';
  
    //Loop over properties record
    for(Property__c pro : properties){
      
      //Check for condition insert/update 
      if(mapOldProperties == null || pro.Acquisition_Status__c != mapOldProperties.get(pro.Id).Acquisition_Status__c){
          
          //Check for Acquisition Status and populate Date Cancelled field
          if(pro.Acquisition_Status__c == CANCELLED)
            pro.Date_Cancelled__c = System.Today();
          else if(pro.Acquisition_Status__c != CANCELLED)
            pro.Date_Cancelled__c = null;  
      }      
    }
  }
    
    //Added by Saurabh Kumar - D-00015414(5/27/2016)
    /**
      * @description    :   Method to populate Property attributes on Disposition . this method to be called from Process builder 
      *
      * @arg            :   Set of properties ID
      *
      * @return         :   Void    
    **/
    @InvocableMethod  
  public static void updateDispositionPropertyAttributes(List<String> setPropertiesID){
        
        //fetch all dispositions which need to be blank  update
        List<Disposition__c> listDispositionToBeUpdated = [Select ID from Disposition__c where Portfolio__c IN :setPropertiesID];
        
        if(!listDispositionToBeUpdated.isEmpty() && !setPropertiesID.isEmpty()){
            update listDispositionToBeUpdated;
        }
    } 
    
   /**
//Added by Saurabh Kumar -D-00015599(5/30/2016)
    /**
      * @description    :   Method to Update realated Open Renewal to 'Property - Sold' if Property : Acquisition status chanes to Sold  
      *
      * @arg            :   List of new properties, map of old properties.
      *
      * @return         :   Void    
    **/
    
   public static void updateRelatedRenewalToSold(List<Property__c> properties, Map<Id, Property__c> mapOldProperties){
        
        Set<ID> setSoldPropertyId = new Set<ID>();
        List<Renewal__c> listRenewalTobeUpdated = new List<Renewal__c>();
        //check if portfolio acc. status changes to Sold and Non core disposition is True 
        for(Property__c prop : properties){            
            if(prop.Acquisition_Status__c != null 
               && Utility.hasFieldChanged(prop, mapOldProperties, 'Acquisition_Status__c')
               && prop.Acquisition_Status__c.equalsIgnoreCase('Sold')
               && prop.For_Sale__c){
                   
                setSoldPropertyId.add(prop.id);
            }
        }
        
        if(!setSoldPropertyId.isEmpty()){
            for(Disposition__c disp : [Select ID,Renewals__c 
                                      From Disposition__c 
                                      Where Portfolio__c IN :setSoldPropertyId 
                                      AND Current_Renewal_Status__c != :Constants.RENEWAL_SOLD
                                      AND Renewals__c != null ]){
                //updating Renewal Status to Property Sold for those Portfolio which got Sold
                listRenewalTobeUpdated.add(new Renewal__c(ID = disp.Renewals__c ,
                                           Renewal_Status__c = Constants.RENEWAL_SOLD));  
            }     
        }
        
        if(!listRenewalTobeUpdated.isEmpty()){
            update listRenewalTobeUpdated;
        }
    }
  /** * @description    :   Method to populate Submarket field on Portfolio  
      *
      * @arg            :   List of new properties
      *
      * @return         :   Void  
      *
      *  @revision Log  :  V1.0 - Created - 06/14/2016 - Poonam Bhargava - D-00015709   
    **/
   public static void populateSubmarket(List<Property__c> properties){
  
    //Map to hold values of Custom setting Submarket Assignment Defaults
    Map<String, String>  mapOfSubmarketDefaults = new Map<String, String>();
    
    //Get all values from custom setting
    List<Submarket_Assignment_Defaults__c> submarketDefaults = Submarket_Assignment_Defaults__c.getAll().values();
     
    //Loop over custom setting values
    for(Submarket_Assignment_Defaults__c submarketDefault : submarketDefaults){
      
      //Populate map mapOfSubmarketDefaults, key as region+ZipCode and value as Submarket
      mapOfSubmarketDefaults.put((submarketDefault.Region__c + '-' + submarketDefault.Zip__c).toLowerCase(), submarketDefault.Submarket__c);  
    }
    
    //Loop through the properties
    for(Property__c property : properties) {
      
      //Check for null condition
      if(property.Residence__c != null && property.Region__c != null && property.Property_Zip_Code__c != null){
        
        //String variable to hold portfolio zip code
        String zipcode = property.Property_Zip_Code__c.replaceAll(',', '');
        
        //String variable to hold key of map in lower case
        String regionZipKey = (property.Region__c + '-' + zipcode).toLowerCase();
        
        //Check the map for key and populate Submarket field on portfolio
        if(mapOfSubmarketDefaults.containsKey(regionZipKey))
          property.Submarket__c = mapOfSubmarketDefaults.get(regionZipKey);
      }
    }
  } 
    
    /** @description    :   Method to populate Date Sold from Disposition:Settlement Date
      *
      * @arg            :   List of new properties, Oldmap
      *
      * @return         :   Void  
      *
      * @revision Log   :   Saurabh Kumar - D-00016866  
    **/
    public static void updateDateSoldOnPortfolio(List<Property__c> properties, Map<Id, Property__c> mapOldProperties){
        //map to hold property which need to be updated 
        Map<Id ,Property__c> mapPropertyIdwithPropertyDateSold = new Map<Id ,Property__c>();
        
        for(Property__c prop : properties){
             if(Utility.hasFieldChanged(prop, mapOldProperties, 'Acquisition_Status__c')
                 && prop.Acquisition_Status__c == Constants.PORTFOLIO_ACQ_STATUS_SOLD)
                 mapPropertyIdwithPropertyDateSold.put(prop.Id, prop);
        }
        
        //Query to get Disposition ->Disposition Date related to Portfolio 
        for(Property__c Prop : [Select Id ,
                                (Select Id ,Settlement_Date__c  From Dispositions__r 
                                   Order By CreatedDate Desc limit 1)
                                  from Property__c 
                                where Id IN :mapPropertyIdwithPropertyDateSold.keySet()]){
                 
             Date tempDispositionDate =  (prop.Dispositions__r==null || prop.Dispositions__r.isEmpty()|| prop.Dispositions__r[0].Settlement_Date__c == null)?null : prop.Dispositions__r[0].Settlement_Date__c ;                       
             //Showing error if no Disposition record not present or Disposition Date is not Present 
            If(tempDispositionDate == null){
                   mapPropertyIdwithPropertyDateSold.get(prop.id).addError(Label.Disposition_Date_Need_to_Populate);
            }else {
               //updating Date Sold On Portfolio as per Disposition Date
               mapPropertyIdwithPropertyDateSold.get(prop.Id).Date_Sold__c = tempDispositionDate;               
            }                                  
         }          
     }
     
     //Added by Poonam Bhargava - (11/06/2017) - D-00017574
     /** @description    :   Method to validate portfolio for Yardi Batch
      *
      * @arg            :   List<Property__c> properties
      *
      * @return         :   Void  
      *
    **/
     public static void validatePropertyOnInsert(List<Property__c> properties){
        
        //Initialize DateTime instance
        DateTime reportingDate = null;
        
        //Initialize list variable of CronTrigger
        List<CronTrigger> schedulerNextRun = new List<CronTrigger>();
        
        //Populate the list instance of Configuration Manager custom setting
        List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey(Constants.YARDI_BATCH_SCHEDULER_NAME);
        
        //Check for size and retrieve the Cron Trigger records
        if(configs.size() > 0)
            schedulerNextRun = [Select Id, NextFireTime, CronJobDetailId from CronTrigger where CronJobDetail.Name =: configs[0].Parameter_Value__c];   
        
        //Validate eligible criteria for schedularNextRun   
        if(schedulerNextRun.size() > 0 && schedulerNextRun[0].NextFireTime != null){
        
            //Populate dateTime varibale with 2 days previous date
            reportingDate = (schedulerNextRun[0].NextFireTime.date()) - 2;
            
            //Loop over the trigger.new list
            for(Property__c prop : properties){
                
                //Check for reporting date on property record and throw exception accordingly
                if(prop.Reporting_Date__c != null && prop.Reporting_Date__c <= reportingDate)
                    prop.addError(Label.ERROR_PROPERTY_APPROVAL);      
            }
        }   
    }
    
    public static void populateYardiPropertyCodeOnPortfolio(List<Property__c> properties){
    
        for(Property__c prop : properties){
        
            if(String.isNotBlank(prop.Securitized_Yardi_Code__c)){
                prop.Yardi_Property_Code_Text__c = prop.Securitized_Yardi_Code__c;  
            }
            else if(String.isNotBlank(prop.Securitized_Yardi_Code__c) && prop.Securitization_Candidate__c){
                prop.Yardi_Property_Code_Text__c = prop.Securitized_Yardi_Code__c;      
            }
            else {
                
                if(prop.Fund__c != null && Integer.valueOf(prop.Fund__c) >= 5){
                    prop.Yardi_Property_Code_Text__c = prop.Yardi_Code_Prefix__c + prop.Yardi_Property_Code_Number_Part__c ;    
                }else{
                    if(String.isNotBlank(prop.Property_Code__c))
                        prop.Yardi_Property_Code_Text__c = prop.Yardi_Code_Prefix__c + prop.Property_Code__c.right(4);  
                }
            }   
        }   
    }
}