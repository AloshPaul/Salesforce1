/**
 *   Description  :  Batch Class to create .csv for new records
 *
 *   Created By Shrinath
 *
 *   Created Date:  02/08/2012
 *
 *   Revision Logs:  V_1.0 - Created
                     V_1.1 - Bhavi Sharma - 11/01/2013 - D-00008819
                     V_1.2 - Bhavi Sharma - 02/20/2014 - Modified(Added Market2 and Fund pair) - D-00011530
                     V_1.3 - Bhavi Sharma - 03/29/2014 - Added new Method(generateRehabOneToManyCSV) - D-00012072
                     V_1.4 - Bhavi Sharma - 04/28/2014 - D-00012787
                     V_1.5 - Bhavi Sharma - 05/09/2014 - D-00012844
                     V_1.6 - Bhavi Sharma - 08/20/2014 - Added new method(generateIACommitmentsCSV) - D-00013161
                     V_1.7 - Abhinav Sharma - 10/08/2014 - D-00013320 - Modify for Fund 5 Changes
                     V_1.8 - Bhavi Sharma - 01/09/2014 - D-00013622 - CR for Ticket - 00035389: Modify Yardi Integration "CommUnits" File
                     V_1.9 - Abhinav Sharma - 03/24/2015 - D-00013835 - CR for Ticket - 00034961: Section 8 Attribute
                     V_1.10 - Abhinav Sharma - 10/04/2015 - D-00014700 - CR for Ticket - 00062041: Add "Bulk" Property Attribute
                     V_1.11 - Abhinav Sharma - 12/17/2015 - D-00014839 - CR for Ticket - 00066934: ResSpecials  
                     V)1.12 - Bhavi Sharma - 02/10/2016 - D-00014948 - CR for Ticket - 00070224: Modify "generateAttributesMarketCSV" method
                                adding two rows in "AttributesMarket" file.   
                     V_1.13 - Poonam Bhargava - (04-22-2016) - D-00015415 - adding three rows in "AttributesMarket" file.  
                     V_1.14 - Poonam Bhargava - (05-06-2016) - (D-00015528) - adding two rows in "AttributesMarket" file. 
                     V_1.15 - Poonam Bhargava - (06-03-2016) - D-00015694 
                     V_1.16 - Poonam Bhargava - (06-24-2016) - (D-00015809) - Adding a new row in "AttributesMarket" file. 
                     V_1.17 - Poonam Bhargava - (06-29-2016) - (D-00015885) - Modified the "National Lease Market" value for Atlanta 
                     V_1.18 - Poonam Bhargava (11-21-2016) - (D-00016473) -  Adding a new row in "AttributesMarket" file.  
                     V_1.19 - Poonam Bhargava (12-02-2016) - (D-00016564) - Modified the method generateIACommitmentsCSV  
                     V_1.20 - Poonam Bhargava (03/03/2017) - D-00016962 - Modified the method generateIACommitmentsCSV for California
                     V_1.21 - Poonam Bhargava - (04/04/2017)-(D-00017023) - Added a new method generateCommProperties1CSV 
                     V_1.22 - Poonam Bhargava (04-06-2017) - D-00017041 - Modified method - AttributesMarket
                     V_1.23 - Poonam Bhargava - (04/13/2017)- (D-00017047)- Added a new method generateLateFeeCofigurationCSV
                    // V_1.24 - Poonam Bhargava (06/26/2017) - (D-00017213) - Adding a new row in "AttributesMarket" file.
                    V1.25 - Bhvai Sharma - (D-00017506) - Added new methods to handle SWAY Properties 
 **/

 public with sharing class YardiIntegrationNewProperty {
    
     public static String FILE_NAME_COMM_PROPERTIES         = 'CommProperties';
     public static String FILE_NAME_COMMON_PROPERTY_LISTS   = 'CommonPropertyLists';
     public static String FILE_NAME_COMMON_PROP_OWNERS      = 'CommonPropOwners';
     public static String FILE_NAME_COMMON_BANKXREFS        = 'CommonBankXRefs';
     public static String FILE_NAME_COMM_UNITS              = 'CommUnits';
     public static String FILE_NAME_RES_UNIT_HISTORIES      = 'ResUnitHistories';
     public static String FILE_NAME_ONE_TO_MANYS            = 'Common_OneToMany';
     public static String HEADER_FILE_NAME_ONE_TO_MANYS     = 'OneToManys';
     
     //Added by Abhinav Sharma - 12/17/2015
     public static String FILE_NAME_RES_SPECIALS            = 'ResSpecials';
     
     //Added by Poonam Bhargava - 04/04/2017 (D-00017023)
     public static String FILE_NAME_COMMPROPERTIES1         = 'CommProperties1';
     
     //Added by Poonam Bhargava - 04/13/2017 -(D-00017047)
     public static String HEADER_FILE_NAME_LATE_FEE         = 'CommonPropOptions';
     public static String FILE_NAME_LATE_FEE                = 'LateFee';
     

     public static String FILE_NAME_ATTRIBUTES_MARKET        = 'AttributesMarket';
     public static String HEADER_FILE_NAME_ATTRIBUTES_MARKET = 'CommPropAttributes';

     public static String FILE_NAME_UNIT_STATUS         = 'UnitStatus';
     public static String HEADER_FILE_NAME_UNIT_STATUS  = 'CommUnits';

     // Added by Rajesh - 1/10/2013
     public static String FILE_NAME_ATTRIBUTES_PROPERY_STATUS        = 'Attributes_PropertyStatus';
     public static String HEADER_FILE_NAME_ATTRIBUTES_PROPERY_STATUS = 'CommPropAttributes';

     // Added by Rajesh - 6/25/2013
     public static String FILE_NAME_PORTFOLIO_MANAGERS          = 'PortfolioManagers';
     public static String HEADER_FILE_NAME_PORTFOLIO_MANAGERS   = 'CommPropAttributes';

     public static String FILE_NAME_UNIT_TYPES          = 'UnitTypes';
     public static String HEADER_FILE_NAME_UNIT_TYPES   = 'ResUnitTypes';

     public static String FILE_NAME_ATTRIBUTES_UNIT_TYPES        = 'Attributes_UnitTypes';
     public static String HEADER_FILE_NAME_ATTRIBUTES_UNIT_TYPES = 'CommPropAttributes';
     public static String HEADER_FILE_NAME_ATTRIBUTES_REHAB_ONE_TO_MANY = 'Rehab_OneToMany';

     //Added By - Bhavi Sharma - 08/20/2014 - D-00013161
     public static String HEADER_FILE_NAME_IA_COMMITMENTS = 'IACommitments';
     
     //Added by Bhavi Sharma for SWAY Market - D-00017506
     public static String FILE_NAME_ETL_COMMON_ONETOMANY_PROP_INFO = 'ETL_Common_OneToMany_PROP_INFO';
     public static String FILE_NAME_ETL_ONETOMANY_UNIT_INFO = 'ETL_OneToMany_UNIT_INFO';
     private final static String SUFFIX_SWAY = '_SWAY';
     private final static String FILE_NAME_UNIT_AVAILABILITY_DETAILS = 'UnitAvailabilityDetails';
     
     
     public static String DESCRIPTION_NEW_RECORD                    = 'New Property Record Inserted';
     public static String YARDI_INTEGRATION_NEW_RECORD_FOLDER_NAME  = 'YardiIntegrationDocuments';
     public static String seperator = ',';
     public static String newLine = '\n';

     private static String YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID_KEY   = 'Yardi Intgration Email Receiver Contact ID';
     private static String YARDI_INTGRATION_EMAIL_TEMPLATE_ID_KEY           = 'Yardi Intgration Email Template ID';
     private static String YARDI_INTEGRATION_CC_EMAIL_ADDRESS               = 'Yardi Integration CC Email Address';

     public static  String YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID = null;
     public static String YARDI_INTGRATION_EMAIL_TEMPLATE_ID = null;

     private static String SACRAMENTO = 'Sacramento';
     private static String NORCAL = 'NorCal';
     
     //Map to hold the Month name wityh their year value
     final static Map<Integer, String > mapMonthWithName = new Map<Integer, String> {
                                                                                        1 => 'January',
                                                                                        2 => 'February',
                                                                                        3 => 'March',
                                                                                        4 => 'April',
                                                                                        5 => 'May',
                                                                                        6 => 'June',
                                                                                        7 => 'July',
                                                                                        8 => 'August',
                                                                                        9 => 'September',
                                                                                        10 => 'October',
                                                                                        11 => 'November',
                                                                                        12 => 'December'
                                                                                    };
     
     public static List<String> listYardiIntegrationCCEmailAddresses = new List<String>();

     //map of account codes
     public static MAP<String, List<Region_Configuration__c>> mapRegionBankAccountCode = new Map<String, List<Region_Configuration__c>>();

     //Map of region short name with bank account code
     public static MAP<String, List<Region_Configuration__c>> mapRegionShortNameWithBankAccountCode = new Map<String, List<Region_Configuration__c>>();
        
    //Map to hold the fund, Region and region Config
    public static Map<String, List<Region_Configuration__c>> mapFundRegionWithRegionConfiguration = new Map<String, List<Region_Configuration__c>>();
    
     //method to get Yardi Intgration Email Receiver Contact ID
     public static void setYardiIntgrationEmailParams(){

        //Create a list of Configuration_Manager__c
        List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();
        configs.addAll(Constants.getConfigManagerByParameterKey(YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID_KEY));
        configs.addAll(Constants.getConfigManagerByParameterKey(YARDI_INTGRATION_EMAIL_TEMPLATE_ID_KEY));
        configs.addAll(Constants.getConfigManagerByParameterKey(YARDI_INTEGRATION_CC_EMAIL_ADDRESS));

        for(Configuration_Manager__c config : configs) {

            if(config.Parameter_Key__c == YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID_KEY) {
                YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID = config.Parameter_Value__c;
            }
            else if(config.Parameter_Key__c == YARDI_INTGRATION_EMAIL_TEMPLATE_ID_KEY){
                YARDI_INTGRATION_EMAIL_TEMPLATE_ID = config.Parameter_Value__c;
            }
            else {
                if(config.Parameter_Value__c != null && config.Parameter_Value__c.trim().length() > 0)
                    listYardiIntegrationCCEmailAddresses.add(config.Parameter_Value__c);
            }
        }
     }

     //map of bank account code fetched from custom setting
     public static void setMapRegionBankAccountCode(Set<String> setRegions){

        //Map to hold Region Name as kay and corresponding Region Configuration custom setting records list as value
        mapRegionBankAccountCode = new Map<String, List<Region_Configuration__c>>();
        mapRegionShortNameWithBankAccountCode = new Map<String, List<Region_Configuration__c>>();
        mapFundRegionWithRegionConfiguration = new Map<String, List<Region_Configuration__c>>();
        
        //Loop over the Configuration record list
        for(Region_Configuration__c rc : [Select Region__c, Region_Short_Name__c, Bank_Code_Suffix__c, Bank_Account_Number__c, Fund__c
                                               From Region_Configuration__c
                                               where Region__c in: setRegions]) {
            if(rc.Region__c != null && String.isBlank(rc.Fund__c)) {
                List<Region_Configuration__c> listRC = (mapRegionBankAccountCode.containsKey(rc.Region__c.trim().toLowerCase())) ? mapRegionBankAccountCode.get(rc.Region__c.trim().toLowerCase()) : new List<Region_Configuration__c>();
                listRC.add(rc);
                mapRegionBankAccountCode.put(rc.Region__c.trim().toLowerCase(), listRC);
            }
            
            //Added by Bhavi to Support Fund 5 and Region Cong changes
            if(String.isNotBlank(rc.Region__c) && String.isNotBlank(rc.Fund__c)) {
                
                //Create Key
                String key = rc.Fund__c + '-' + rc.Region__c.trim().toLowerCase();
                
                //Check if thsi is in map already 
                if(!mapFundRegionWithRegionConfiguration.containsKey(key))
                    
                    mapFundRegionWithRegionConfiguration.put(key, new List<Region_Configuration__c>());
                
                //Add region record
                mapFundRegionWithRegionConfiguration.get(key).add(rc);
            }
            
            //Bhavi Sharma - 11/01/2013 - D-00008819: Creating a Map to hold the Region Short Name with Region Configuration List
            //Check if Region Short name is not null, only then add this in map
            if(rc.Region_Short_Name__c != null && String.isBlank(rc.Fund__c)) {

                //format region short name
                String reginShortName = rc.Region_Short_Name__c.trim().toLowerCase();

                //Check in Map if Region  Short Name already exists,
                //If yes, then get the exisitng list from Map and Add the new Region Configuration record in it
                //Otherwise put this Region Short Name in map and add a new list of region Configuration as value with region configuration record
                if(!mapRegionShortNameWithBankAccountCode.containsKey(reginShortName))
                    mapRegionShortNameWithBankAccountCode.put(reginShortName, new List<Region_Configuration__c>());

                mapRegionShortNameWithBankAccountCode.get(reginShortName).add(rc);
            }
        }
     }

     //method to return blank string if value is null
     private static String getString(String val){
         return (val == null ? '' : String.valueOf(val).escapeCSV());
     }

     //generate csv methos which calls methods to generate csv content
     public static MAP<String, String> generateCSVFiles(List<Yardi_Property__c> listYardiProperty, List<Yardi_Property__c> listSWAYYardiProperty, MAP<String, String> mapCSVName_Content) {
         //call methos to generate csv content and fill the mapCSVName_Content
         mapCSVName_Content = generateCommPropertiesCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommPropertiesListCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommonBankXRefsCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommonPropOwnersCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommUnitsCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateResUnitHistoriesCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateOneToManysCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateAttributesMarketCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateResSpecialsCSV(listYardiProperty, mapCSVName_Content); //Added by Abhinav Sharma - 12/17/2015
         mapCSVName_Content = generateCommProperties1CSV(listYardiProperty, mapCSVName_Content); //Added by Poonam Bhargava - 04/04/2017 (D-00017023)
         mapCSVName_Content = generateLateFeeCofigurationCSV(listYardiProperty, mapCSVName_Content); //Added by Poonam Bhargava - 04/13/2017
         mapCSVName_Content = generateUnitTypesCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateAttributesUnitTypesCSV(listYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateIACommitmentsCSV(listYardiProperty, mapCSVName_Content);
         
         //Bhavi Sharma - 10/25/2017 - D-00017506
         mapCSVName_Content = generateCommPropertiesSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommonBankXRefsSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateCommUnitsSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateOneToManysPropInfoSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateAttributesMarketSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateUnitTypesSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateIACommitmentsSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateOneToManysUnitInfoSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
         mapCSVName_Content = generateUnitAvailabilityDetailsSWAYCSV(listSWAYYardiProperty, mapCSVName_Content);
                 
         return mapCSVName_Content;
     }

    // Added by Rajesh to generate Attributes_PropertyStatus for all properties - 01/29/2013
    public static Map<String, String> generateCSVFilesForAll(List<Yardi_Property__c> listYardiProperty, Map<String, String> mapCSVName_Content) {
        mapCSVName_Content = generateAttributesPropertyStatusCSV(listYardiProperty, mapCSVName_Content);
        return mapCSVName_Content;
    }

    //method to genrate AttributesMarket CSV content
    private static MAP<String, String> generateAttributesMarketCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {
        
        //Added by Poonam Bhargava - (04-22-2016)- D-00015415
        //Map to hold Region as key and combination of values Region-District-Area                      
        Map<String,String> mapMarket2WithRDA = new Map<String,String>();
        
        //Populate map mapMarket2WithRDA
        mapMarket2WithRDA.put('atlanta', 'EAST-Unassigned-Unassigned');
        mapMarket2WithRDA.put('charlotte', 'CAROLINAS-D01NCCH-Unassigned');
        mapMarket2WithRDA.put('jacksonville', 'NORTH FLORIDA-D01FLJA-Unassigned');
        mapMarket2WithRDA.put('orlando', 'NORTH FLORIDA-D01FLOR-Unassigned');
        mapMarket2WithRDA.put('tampa', 'CENTRAL FLORIDA-D01FLTA-Unassigned');
        mapMarket2WithRDA.put('miami', 'SOUTH FLORIDA-D01FLMI-Unassigned');
        mapMarket2WithRDA.put('inland empire', 'SOUTHERN CALIFORNIA-D01CAIE-Unassigned');
        mapMarket2WithRDA.put('los angeles', 'SOUTHERN CALIFORNIA-D01CALA-Unassigned');
        mapMarket2WithRDA.put('norcal', 'NCalVega-D01canc-Unassigned');
        mapMarket2WithRDA.put('las vegas', 'NCalVega-D01nvla-Unassigned');      
        mapMarket2WithRDA.put('seattle', 'PACIFIC N WEST-D01WASE-Unassigned');
        mapMarket2WithRDA.put('phoenix', 'SOUTHWEST-D01AZPH-Unassigned');
        mapMarket2WithRDA.put('minneapolis', 'MIDWEST-D01MNMI-Unassigned');
        mapMarket2WithRDA.put('chicago', 'MIDWEST-D01ILCH-Unassigned');
        mapMarket2WithRDA.put('sacramento', 'NCalVega-D01canc-Unassigned'); //Added by Poonam Bhargava - D-00015694(06-03-2016)
         
        //Added by Poonam Bhargava (05-06-2016) - (D-00015528)
        //Map to hold Region as key and values of National Lease Market Attribute value according to Region
        Map<String, String> mapNationalLeaseMarketAttributeValues = new Map<String,String>();
        
        //Populate map mapNationalLeaseMarketAttributeValues
        mapNationalLeaseMarketAttributeValues.put('chicago', 'chicago-evanston');
        mapNationalLeaseMarketAttributeValues.put('inland empire', 'inland empire');
        mapNationalLeaseMarketAttributeValues.put('jacksonville', 'jacksonville');
        mapNationalLeaseMarketAttributeValues.put('los angeles', 'los angeles');
        mapNationalLeaseMarketAttributeValues.put('miami', 'miami');
        mapNationalLeaseMarketAttributeValues.put('orlando', 'orlando');
        mapNationalLeaseMarketAttributeValues.put('sacramento', 'sacramento');
        mapNationalLeaseMarketAttributeValues.put('tampa', 'tampa');
        mapNationalLeaseMarketAttributeValues.put('atlanta', 'Georgia');
        mapNationalLeaseMarketAttributeValues.put('charlotte', 'nc-sc-north carolina-south carolina');
        mapNationalLeaseMarketAttributeValues.put('las vegas', 'nevada');
        mapNationalLeaseMarketAttributeValues.put('minneapolis', 'minnesota');
        mapNationalLeaseMarketAttributeValues.put('seattle', 'washington');
        mapNationalLeaseMarketAttributeValues.put('phoenix', 'arizona');
        
        //Added by Poonam Bhargava (06-24-2016) - (D-00015809)
        //Set to hold Portfolio ids
        Set<Id> setPortfolios = new Set<Id>();
      
        //Initialize map with Portfolio Id as key and Disposition as Value
        Map<Id, Disposition__c> mapPortfolioIdWithDispositions = new Map<Id, Disposition__c>();   
        
        //Map to hold mapping for Dispositon Strategy                   
        Map<String,String> mapDispositionStrategy = new Map<String,String>();
        
        //Populate map mapDispositionStrategy
        mapDispositionStrategy.put('rfl', 'RFL');
        mapDispositionStrategy.put('online platform', 'Online');
        
        //Loop over Yardi Properties
        for(Yardi_Property__c yp : listYardiProperty){
        
            //Check for null and populate set setPortfolios with Portfolio Ids
            if(String.isNotBlank(yp.Property__c))
                setPortfolios.add(yp.Property__c);  
        }
        
        //Check for set size
        if(setPortfolios.size() > 0){
            
            //Modified By Poonam Bhargava (Reteieve  Yardi_Dispo_Lease_Renewal_Strategy__c field drom Disposition) - 06/26/2017 - (D-00017213)
            //Modified By Poonam Bhargava (04-06-2017) - D-00017041
            //Loop over Disposition and populate map mapPortfolioIdWithDispositions with Portfolio as key and Dispositions as value
            for(Property__c prop : [Select Id,(Select Id, Yardi_Dispo_Lease_Renewal_Strategy__c, Disposition_Strategy__c from Dispositions__r order by CreatedDate DESC LIMIT 1) 
                                        from Property__c where Id IN : setPortfolios and Acquisition_Status__c !=: Constants.CANCELLED]){
                //Populate map
                if(prop.Dispositions__r.size() > 0)
                    mapPortfolioIdWithDispositions.put(prop.Id, prop.Dispositions__r);                              
            }
        }  
        
        //header row content
        String headerRow1 = HEADER_FILE_NAME_ATTRIBUTES_MARKET;
        String headerRow2 = newLine  + 'Property_Code,Attribute_Set_Code,Attribute_Name,Attribute_Value,Foreign_Db_Name,Ref_Property_Id';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_MARKET) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_MARKET));
        
        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {
            
            //String variable to hold the values form map mapMarket2WithRDA (Region-District-Area)
            String strRegionDistrictArea = 'Unassigned-Unassigned-Unassigned'; //Added by Poonam Bhargava - D-00015694(06-03-2016)
            
            //Added by Poonam Bhargava (05-06-2016) - (D-00015528)
            //String variable to hold Pool values 'Yes/No' 
            String strPool;
            
            //String variable to hold National Lease Market Attribute value according to region
            String strNationalLeaseMarket;
            
            //String variable to hold property region in lower case
            String strRegion;
            
            //String variable to hold property city in lower case
            String strCity;
            //String DispLeaseRenewalStrategy = 'None';
            
            //Added by Poonam Bhargava (05-06-2016) - (D-00015528)
            //Check for Pool value on properties and populate strPool string variable accordingly    
            if(String.isNotBlank(p.Property__r.Pool__c) && p.Property__r.Pool__c == 'Yes')
                strPool = 'Yes';
            else
                strPool = 'No'; 
            
            //Check for null
            if(String.isNotBlank(p.Property__r.Region__c)){
                
                //Populate string variable with region in lower case
                strRegion = (p.Property__r.Region__c).toLowerCase();
                
                //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                //Check for key in map and get the value from map and populate string strRegionDistrictArea
                if(mapMarket2WithRDA.containsKey(strRegion))
                    strRegionDistrictArea = mapMarket2WithRDA.get(strRegion);  

                //Added by Poonam Bhargava (05-06-2016) - (D-00015528)  
                //Check for key in map mapNationalLeaseMarketAttributeValues and value in property city on properties
                if(mapNationalLeaseMarketAttributeValues.containsKey(strRegion) && String.isNotBlank(p.Property__r.Property_City__c)){
                
                    //Populate city variable in lower case
                    strCity = (p.Property__r.Property_City__c).toLowerCase();   
                    
                    //Check for region
                    if(strRegion == 'chicago'){
                        
                        //Check for property city in map values and populate strNationalLeaseMarket variable
                        if((mapNationalLeaseMarketAttributeValues.get(strRegion)).contains(strCity))
                            strNationalLeaseMarket = p.Property__r.Property_City__c;
                        else
                            strNationalLeaseMarket = 'Illinois';
                    }
                    else if(strRegion == 'atlanta'){
                      strNationalLeaseMarket = mapNationalLeaseMarketAttributeValues.get(strRegion); //Added by Poonam Bhargava (06/29/2016) - D-00015885
                    }
                    else {
                        
                        //Check for property city in map values and populate strNationalLeaseMarket variable
                        if((mapNationalLeaseMarketAttributeValues.get(strRegion)).contains(strCity))
                            strNationalLeaseMarket = p.Property__r.Property_City__c;
                        else
                            strNationalLeaseMarket = p.Property__r.Region__c;
                    }
                }                                  
            }
            
            //Added by Poonam Bhargava (06-24-2016) - (D-00015809)
            //String Varible to hold Disposition Strategy value 
            String dispStrategy = 'None';
            
            //Check for map mapPortfolioIdWithDispositions size   
            if(mapPortfolioIdWithDispositions.size() > 0){
            
                //Check mapPortfolioIdWithDispositions for eligible criteria to pupulate the values in varibale dispStrategy
                if(mapPortfolioIdWithDispositions.containsKey(p.Property__c) && mapPortfolioIdWithDispositions.get(p.Property__c).Disposition_Strategy__c != null){
                
                    //String variable to hold Disposition Strategy in lower case
                    String dispStrategyInLowerCase = mapPortfolioIdWithDispositions.get(p.Property__c).Disposition_Strategy__c.toLowerCase();
                      
                    //Check map mapDispositionStrategy for key and populate dispStrategy accordingly 
                    if(mapDispositionStrategy.containsKey(dispStrategyInLowerCase))  
                        dispStrategy =  mapDispositionStrategy.get(dispStrategyInLowerCase);
                    else
                        dispStrategy = 'Standard';  
                }
            }
            
            // Get the first 4 digits of Yardi Code
            String yardiPropertyCodeSubStr = p.Property__r.Yardi_Property_Code__c.toLowerCase();
            
            if(yardiPropertyCodeSubStr != null && yardiPropertyCodeSubStr != '' && yardiPropertyCodeSubStr.length() > 4)
                yardiPropertyCodeSubStr = yardiPropertyCodeSubStr.subString(0, 4);
            
            if(yardiRegionConfigMap.containsKey(yardiPropertyCodeSubStr)) {
                
                //Check for portfolio Acquisition Status = For Sale
                if(p.Property__c != null && p.Property__r.Acquisition_Status__c != null && p.Property__r.Acquisition_Status__c.trim().equalsIgnoreCase('For Sale')) {
                
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                        + 'Portfolio Manager' + seperator + 'Unassigned');
                } else {
                    dataRows = dataRows +
                                        //Added by Abhinav Sharma - 10/04/2015 - D-00014700
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            +  'Bulk' + seperator + 'None' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Acquisition Year' + seperator + p.Property__r.Acquisition_Date__c.year() + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Acquisition Month' + seperator + mapMonthWithName.get(p.Property__r.Acquisition_Date__c.month()) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Credit Facility' + seperator + 'None' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Securitization' + seperator + 'NONE' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Market' + seperator + yardiRegionConfigMap.get(yardiPropertyCodeSubStr).Market_Name__c + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Market2' + seperator + processRegionString(p.Property__r.Region__c) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Portfolio Manager' + seperator + 'Unassigned')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Fund' + seperator + getString(mapFundNumberWithFundValue.get(p.Property__r.Fund__c)) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Fixed Asset' + seperator + 'No Rehab')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Stabilized' + seperator + 'Non-Stabilized')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Sec8' + seperator + 'No')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator    //Added by Bhavi Sharma D-00014948 SIR
                                            + 'DQ Date' + seperator + 'None')                                                                  
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator    
                                            + 'DQ Entity' + seperator + 'None')                                                              //Added by Bhavi Sharma D-00014948 SIR
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator   //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'Region' + seperator + strRegionDistrictArea.split('-')[0])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator    //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'District' + seperator + strRegionDistrictArea.split('-')[1])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator    //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'Area' + seperator + strRegionDistrictArea.split('-')[2])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (05-06-2016) - (D-00015528)   
                                            + 'Pool' + seperator + strPool)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (05-06-2016) - (D-00015528)   
                                            + 'National Lease Market' + seperator + strNationalLeaseMarket)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (06-24-2016) - (D-00015809)   
                                            + 'Disposition Strategy' + seperator + dispStrategy)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator   //Added by Poonam Bhargava (11-21-2016) - (D-00016473)  
                                            + 'Encumbered' + seperator + 'No');   
                }
            } else {
                    
                //Check for portfolio Acquisition Status = For Sale
                if(p.Property__c != null && p.Property__r.Acquisition_Status__c != null && p.Property__r.Acquisition_Status__c.trim().equalsIgnoreCase('For Sale')) {
                
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Portfolio Manager' + seperator + 'Unassigned');
                } else {
                    dataRows = dataRows +
                                        //Added by Abhinav Sharma - 10/04/2015 - D-00014700
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            +  'Bulk' + seperator + 'None' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Acquisition Year' + seperator + p.Property__r.Acquisition_Date__c.year() + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Acquisition Month' + seperator + mapMonthWithName.get(p.Property__r.Acquisition_Date__c.month()) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Credit Facility' + seperator + 'None' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Securitization' + seperator + 'NONE' + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Market' + seperator + p.Property__r.Region__c +  + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Market2' + seperator + processRegionString(p.Property__r.Region__c) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Portfolio Manager' + seperator + 'Unassigned')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Fund' + seperator + getString(mapFundNumberWithFundValue.get(p.Property__r.Fund__c)) + seperator + '' + seperator + '')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Fixed Asset' + seperator + 'No Rehab')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Stabilized' + seperator + 'Non-Stabilized')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Sec8' + seperator + 'No')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator //Added by Bhavi Sharma D-00014948 SIR
                                            + 'DQ Date' + seperator + 'None')                                                                
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator 
                                            + 'DQ Entity' + seperator + 'None')                                                             //Added by Bhavi Sharma D-00014948 SIR
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'Region' + seperator + strRegionDistrictArea.split('-')[0])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator   //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'District' + seperator + strRegionDistrictArea.split('-')[1])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator   //Added by Poonam Bhargava - (04-22-2016)- D-00015415
                                            + 'Area' + seperator + strRegionDistrictArea.split('-')[2])
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (05-06-2016) - (D-00015528)   
                                            + 'Pool' + seperator + strPool)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (05-06-2016) - (D-00015528)   
                                            + 'National Lease Market' + seperator + strNationalLeaseMarket)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator  //Added by Poonam Bhargava (06-24-2016) - (D-00015809)   
                                            + 'Disposition Strategy' + seperator + dispStrategy)
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator   //Added by Poonam Bhargava (11-21-2016) - (D-00016473)  
                                            + 'Encumbered' + seperator + 'No');
                                        
                }
            }
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_ATTRIBUTES_MARKET, dataRows);
        
        return mapCSVName_Content;
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    private static MAP<String, String> generateAttributesMarketSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {
       
        //header row content
        String headerRow1 = HEADER_FILE_NAME_ATTRIBUTES_MARKET;
        String headerRow2 = newLine  + 'Property_Code,Attribute_Set_Code,Attribute_Name,Attribute_Value,Ref_Property_Id';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_MARKET + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_MARKET + SUFFIX_SWAY));
        
        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {
           
            // Get the first 4 digits of Yardi Code
            String yardiPropertyCodeSubStr = p.Property__r.Yardi_Property_Code__c.toLowerCase();
            
            if(yardiPropertyCodeSubStr != null && yardiPropertyCodeSubStr != '' && yardiPropertyCodeSubStr.length() > 4)
                yardiPropertyCodeSubStr = yardiPropertyCodeSubStr.subString(0, 4);
            
            if(yardiRegionConfigMap.containsKey(yardiPropertyCodeSubStr)) {
                
                //Check for portfolio Acquisition Status = For Sale
                if(p.Property__c != null && p.Property__r.Acquisition_Status__c != null && p.Property__r.Acquisition_Status__c.trim().equalsIgnoreCase('For Sale')) {
                
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                        + 'Portfolio Manager' + seperator + 'Unassigned');
                } else {
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Common' + seperator
                                            +  'Level' + seperator + '0 - Property')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Property Status' + seperator + 'Active')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Affiliate Partner' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Portfolio' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'State' + seperator + 'CO')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'MSA' + seperator + 'Colorado Springs')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Acquisition Company' + seperator + 'CSH Property One LLC')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Property Type' + seperator + 'Single Family')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Source of Capital' + seperator + 'Founders')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'DebtObligation' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Company' + seperator + 'CSH')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'SWAY Fund' + seperator + ' ')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator    
                                            + 'Level Company' + seperator + 'CSH') ;                                                                 
                                        
                }
            } else {
                    
                //Check for portfolio Acquisition Status = For Sale
                if(p.Property__c != null && p.Property__r.Acquisition_Status__c != null && p.Property__r.Acquisition_Status__c.trim().equalsIgnoreCase('For Sale')) {
                
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                            + 'Portfolio Manager' + seperator + 'Unassigned');
                } else {
                    dataRows = dataRows +
                                        (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Common' + seperator
                                            +  'Level' + seperator + '0 - Property')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Property Status' + seperator + 'Active')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Affiliate Partner' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Portfolio' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'State' + seperator + 'CO')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'MSA' + seperator + 'Colorado Springs')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Acquisition Company' + seperator + 'CSH Property One LLC')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Property Type' + seperator + 'Single Family')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Source of Capital' + seperator + 'Founders')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'DebtObligation' + seperator + 'None')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'Company' + seperator + 'CSH')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator
                                            + 'SWAY Fund' + seperator + ' ')
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Property' + seperator    
                                            + 'Level Company' + seperator + 'CSH') ; 
                }
            }
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_ATTRIBUTES_MARKET + SUFFIX_SWAY, dataRows);
        
        return mapCSVName_Content;
    }

    //Check for the region
    private static String processRegionString(String regionValue) {

        //if the Region__c == "Sacramento", translate the output value to be "NorCal" otherwise go with base value
        if(regionValue == SACRAMENTO)
            regionValue = NORCAL;

        //Return region String value
        return getString(regionValue);
    }

    //Abhinav Sharma - 10/08/2014 - D-00013320 - Modify for Fund 5 Changes
    //Method to process property region value before placing it at csv file row in current context
    private static MAP<String, String> mapFundNumberWithFundValue = new Map<String, String> {
        '01'  => 'Fund1' ,
        '02'  => 'Fund2',
        '03'  => 'Fund3',
        '04'  => 'Fund4',
        '05' => 'Fund5',
        '06' => 'Fund6'
    };

     private static Map<String,Yardi_Short_Region_Config__c> yardiRegionConfigMap = Yardi_Short_Region_Config__c.getAll();

     //method to genrate CommProperties CSV content
     private static MAP<String, String> generateCommPropertiesCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = FILE_NAME_COMM_PROPERTIES;
         String headerRow2 = newLine  + 'Property_Code,Country,Ext_Ref_Property_Id,Ref_Owner_Id,Owner,Addr1,Addr2,Addr3,Addr4,City,State,ZipCode,Notes,Vat_Recovery_Type,Vat_Opted,International,Contract_Reserve,Commission_Percent,';
         headerRow2 = headerRow2  + 'Commission_Min,Contract_Exp_Date,Residential,Is_Estate,Tax_Status_Changed,Status,Tax_Recovery_Percentage,MLA';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_COMM_PROPERTIES) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMM_PROPERTIES));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){

             dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Country__c) + seperator + getString(p.Ext_Ref_Property_Id__c) + seperator +
                        getString(p.Ref_Owner_Id__c) + seperator + getString(p.Owner__c) + seperator +
                        getString(p.Addr1__c) + seperator + getString(p.Addr2__c) + seperator + getString(p.Addr3__c) + seperator +
                        getString(p.Addr4__c) + seperator + getString(p.City__c) + seperator + getString(p.State__c) + seperator +  getString(p.Zipcode__c) + seperator +
                        getString(p.Notes__c) + seperator + getString(p.Vat_Recovery_Type__c) + seperator + getString(p.Vat_Opted__c) + seperator + getString(p.International__c) + seperator +
                        getString(p.Contract_Reserve__c) + seperator + getString(p.Commission_Percent__c) + seperator + getString(p.Commission_Min__c) + seperator +
                        getString(p.Contract_Exp_Date__c) + seperator + getString(p.Residential__c) + seperator + getString(p.Is_Estate__c) + seperator +
                        getString(p.Tax_Status_Changed__c) + seperator + + getString(p.Status__c) + seperator + getString(p.Tax_Recovery_Percentage__c) + seperator +
                        + getString(p.MLA__c)
                        );
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_COMM_PROPERTIES, dataRows);
         return mapCSVName_Content;
     }
     
     //Bhavi Sharma - 10/25/2017 - D-00017506
     private static MAP<String, String> generateCommPropertiesSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = FILE_NAME_COMM_PROPERTIES;
         String headerRow2 = newLine  + 'Property_Code,Country,Ext_Ref_Property_Id,Ref_Owner_Id,Owner,Addr1,Addr2,Addr3,Addr4,City,State,ZipCode,Vat_Recovery_Type,Vat_Opted,International,';
         headerRow2 = headerRow2  + 'Residential,Is_Estate,Tax_Status_Changed,Status,Tax_Recovery_Percentage,Notes,End_Of_Year,MLA,Acquisition_Date,NCREIF_Manager_ID,Disposition_Asset_Date,';
         headerRow2 = headerRow2  + 'Purchase_Price,True_Acquisition_Asset_Date,Net_Sales_Price,Asset_Date_Not_NCREIF,Project_Type,Ideal_Lease,Months_To_Lease';
        
         //Set to hold Portfolio ids
        Set<Id> setPortfolios = new Set<Id>();
        
        //Initialize map with Portfolio Id as key and Disposition as Value
        Map<Id, Disposition__c> mapPortfolioIdWithDispositions = new Map<Id, Disposition__c>();   
            
        //loop over yardi property 
        for(Yardi_Property__c yp : listYardiProperty) {
            
            //Check for null and populate set with Portfolio Ids
            if(String.isNotBlank(yp.Property__c))
                setPortfolios.add(yp.Property__c);  
        }
            
        //Check for set size
        if(setPortfolios.size() > 0){
            
            //Loop over Disposition and populate map mapPortfolioIdWithDispositions with Portfolio as key and Dispositions as value
            for(Property__c prop : [Select Id,(Select Id, Settlement_Date__c from Dispositions__r order by CreatedDate DESC LIMIT 1) 
                                        from Property__c where Id IN : setPortfolios and Yardi_Attributes_PropertyStatus__c = true
                                        and Acquisition_Status__c = : Constants.PORTFOLIO_ACQ_STATUS_SOLD]){
                //Populate map
                if(prop.Dispositions__r.size() > 0)
                    mapPortfolioIdWithDispositions.put(prop.Id, prop.Dispositions__r);                              
            }
        }
        
         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_COMM_PROPERTIES + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMM_PROPERTIES + SUFFIX_SWAY));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){
            
            String acquisitionDate = '';
            String settlementDate = '';
            
            if(p.Property__r.Acquisition_Date__c != null)
                acquisitionDate = p.Property__r.Acquisition_Date__c.format();
            
            //Check map for null and populate the values in varibale propertyDispDate
            if(mapPortfolioIdWithDispositions.containsKey(p.Property__c) && mapPortfolioIdWithDispositions.get(p.Property__c).Settlement_Date__c != null)
                settlementDate = mapPortfolioIdWithDispositions.get(p.Property__c).Settlement_Date__c.format();
            
            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Country__c) + seperator + getString(p.Ext_Ref_Property_Id__c) + seperator +
                        getString(p.Ref_Owner_Id__c) + seperator + getString(p.Owner__c) + seperator +
                        getString(p.Addr1__c) + seperator + getString(p.Addr2__c) + seperator + getString(p.Addr3__c) + seperator +
                        getString(p.Addr4__c) + seperator + getString(p.City__c) + seperator + getString(p.State__c) + seperator +  getString(p.Zipcode__c) + seperator +
                        getString(p.Vat_Recovery_Type__c) + seperator + getString(p.Vat_Opted__c) + seperator + getString(p.International__c) + seperator +
                        getString(p.Residential__c) + seperator + getString(p.Is_Estate__c) + seperator +
                        getString(p.Tax_Status_Changed__c) + seperator + getString(p.Status__c) + seperator + getString(p.Tax_Recovery_Percentage__c) + seperator +
                        getString(p.Notes__c) + seperator + '' + seperator + getString(p.MLA__c) + seperator + acquisitionDate + seperator +
                        '' + seperator + settlementDate + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + ''
                        );
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_COMM_PROPERTIES + SUFFIX_SWAY, dataRows);
         return mapCSVName_Content;
     }

     //method to genrate CommPropertiesList CSV content
     private static MAP<String, String> generateCommPropertiesListCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = FILE_NAME_COMMON_PROPERTY_LISTS;
         String headerRow2 = newLine  + 'Property_Code,Ext_Ref_Property_Id,Property_List_Code,Description,Percent';

         //list of code
         String description = '';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_COMMON_PROPERTY_LISTS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMMON_PROPERTY_LISTS));

         //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
        
            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Ext_Ref_Property_Id__c) + seperator
                         + 'THRNEW' + seperator + description + seperator + getString(p.Percent__c));
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMMON_PROPERTY_LISTS, dataRows);
        return mapCSVName_Content;
    }

    //method to genrate CommonPropOwners CSV content
    private static MAP<String, String> generateCommonPropOwnersCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {
        //header row content
        String headerRow1 = FILE_NAME_COMMON_PROP_OWNERS;
        String headerRow2 = newLine  + 'Owner_Code,Property_Code,Percent,Investment,InvestDate,Remarks,Shares,Income,Depreciation,TaxCredit,StateCredit,Type,Ref_Property_Id,Ref_Owner_Id';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_COMMON_PROP_OWNERS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMMON_PROP_OWNERS));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {

            // Get the first 4 digits of Yardi Code
            String yardiPropertyCodeSubStr = p.Property__r.Yardi_Property_Code__c.toLowerCase();

            if(yardiPropertyCodeSubStr != null && yardiPropertyCodeSubStr != '' && yardiPropertyCodeSubStr.length() > 4)
                yardiPropertyCodeSubStr = yardiPropertyCodeSubStr.subString(0, 4);

            if(yardiRegionConfigMap.containsKey(yardiPropertyCodeSubStr))
                dataRows = dataRows + (newLine + yardiRegionConfigMap.get(yardiPropertyCodeSubStr).Owner_Entity__c + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    getString(p.Percent__c) + seperator + '' + seperator + getString(p.InvestDate__c) +  seperator + '' + seperator + ''
                                    + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '');
            else
                dataRows = dataRows + (newLine + getString(p.Owner_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    getString(p.Percent__c) + seperator + '' + seperator + getString(p.InvestDate__c) +
                                    seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' +
                                    seperator + '' + seperator + '' + seperator + '' + seperator + ''
                                    );

        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMMON_PROP_OWNERS, dataRows);
        return mapCSVName_Content;
    }

    //Abhinav Sharma - 10/08/2014 - D-00013320 - Modify for Fund 5 Changes
    //method to genrate CommonBankXRefs CSV content
    private static MAP<String, String> generateCommonBankXRefsCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = FILE_NAME_COMMON_BANKXREFS;
        String headerRow2 = newLine  + 'Bank_Code,Property_Code,Account_Code';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_COMMON_BANKXREFS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMMON_BANKXREFS));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {

            //Condition added By Bhavi
            //This logic will remain same for the FUND 1, 2 3, 4 properties
            if(p.Property__r.Fund__c != '05' && p.Property__r.Fund__c != '06') {
          
                if(mapRegionBankAccountCode.containsKey(p.Property__r.Region__c.trim().toLowerCase())
                    && mapRegionBankAccountCode.get(p.Property__r.Region__c.trim().toLowerCase()) != null) {
                     
                    // Get the first 4 digits of Yardi Code
                    String yardiPropertyCodeSubStr = p.Property__r.Yardi_Property_Code__c.toLowerCase();
                   
                    if(yardiPropertyCodeSubStr != null && yardiPropertyCodeSubStr != '' && yardiPropertyCodeSubStr.length() > 4)
                        yardiPropertyCodeSubStr = yardiPropertyCodeSubStr.subString(0, 4);
                     
                    // Substitute the property codes if they match any of these.
                    //Bhavi Sharma - 11/01/2013 - D-00008819: Removing "yardiPropertyCodeSubStr == '3mnc'" clause
                    if(yardiPropertyCodeSubStr == '2wic' || yardiPropertyCodeSubStr == '2mnc' || yardiPropertyCodeSubStr == '2mic'
                            || yardiPropertyCodeSubStr == '2inc' || yardiPropertyCodeSubStr == '2coc')
                        yardiPropertyCodeSubStr = '2ilc';
                    else if(yardiPropertyCodeSubStr == '3wic' || yardiPropertyCodeSubStr == '3mic'
                            || yardiPropertyCodeSubStr == '3inc' || yardiPropertyCodeSubStr == '3coc')
                        yardiPropertyCodeSubStr = '3ilc';
                    else if(yardiPropertyCodeSubStr == '4wic' || yardiPropertyCodeSubStr == '4mic'
                            || yardiPropertyCodeSubStr == '4inc' || yardiPropertyCodeSubStr == '4coc')
                        yardiPropertyCodeSubStr = '4ilc';
                    else if(yardiPropertyCodeSubStr == '5wic' || yardiPropertyCodeSubStr == '5mic'
                            || yardiPropertyCodeSubStr == '5inc' || yardiPropertyCodeSubStr == '5coc')
                        yardiPropertyCodeSubStr = '5ilc';
                    else if(yardiPropertyCodeSubStr == '6wic' || yardiPropertyCodeSubStr == '6mic'  //Added for fund6
                            || yardiPropertyCodeSubStr == '6inc' || yardiPropertyCodeSubStr == '6coc')
                        yardiPropertyCodeSubStr = '6ilc';
                    else if(yardiPropertyCodeSubStr == 'mnch' || yardiPropertyCodeSubStr == 'mich' || yardiPropertyCodeSubStr == 'inch'
                            || yardiPropertyCodeSubStr == 'coch' || yardiPropertyCodeSubStr == 'wich')
                        yardiPropertyCodeSubStr = 'ilch';
                    else if(yardiPropertyCodeSubStr == '2scc')
                        yardiPropertyCodeSubStr = '2ncc';
                    else if( yardiPropertyCodeSubStr == '3scc')
                        yardiPropertyCodeSubStr = '3ncc';
                    else if( yardiPropertyCodeSubStr == '4scc')
                        yardiPropertyCodeSubStr = '4ncc';
                    else if( yardiPropertyCodeSubStr == '5scc')
                        yardiPropertyCodeSubStr = '5ncc';
                    else if( yardiPropertyCodeSubStr == '6scc')//Added for Fund6(08/11/2015)
                        yardiPropertyCodeSubStr = '6ncc';
                    else if(yardiPropertyCodeSubStr == 'sc2c')
                        yardiPropertyCodeSubStr = 'nc2c';
                    else  if(yardiPropertyCodeSubStr == 'sc3c')
                        yardiPropertyCodeSubStr = 'nc3c';
                    else  if(yardiPropertyCodeSubStr == 'sc4c')
                        yardiPropertyCodeSubStr = 'nc4c';
                    else  if(yardiPropertyCodeSubStr == 'sc5c')
                        yardiPropertyCodeSubStr = 'nc5c';
                    else  if(yardiPropertyCodeSubStr == 'sc6c')//Added for Fund6(08/11/2015)
                        yardiPropertyCodeSubStr = 'nc6c';
                    
    
                    //Bhavi Sharma - 11/01/2013 - D-00008819: Instead of looping all the records, pull the appropriate records from
                    //mapRegionShortNameWithBankAccountCode map and use that
                 
                    if(mapRegionShortNameWithBankAccountCode.containsKey(yardiPropertyCodeSubStr)) {
                        for(Region_Configuration__c rc : mapRegionShortNameWithBankAccountCode.get(yardiPropertyCodeSubStr)) {
                            dataRows = dataRows + (newLine + getString(rc.Region_Short_Name__c + rc.Bank_Code_Suffix__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c)
                                                + seperator + getString(rc.Bank_Account_Number__c));
                        }
                    }
                }
            } else if(String.isNotBlank(p.Property__r.Fund__c)){
                    
                //Create a Unique Key for Fund and Region
                String key = p.Property__r.Fund__c + '-' + p.Property__r.Region__c.trim().toLowerCase();
                
                //Get the Region Configuration Values from Custom Setting
                if(mapFundRegionWithRegionConfiguration.containsKey(key)) {
                    
                    //Get the Region Configuration Records
                    for(Region_Configuration__c rc : mapFundRegionWithRegionConfiguration.get(key)) {
                        
                        //Append data in CSV
                        dataRows = dataRows + (newLine + getString(rc.Region_Short_Name__c + rc.Bank_Code_Suffix__c).toLowerCase() + seperator + getString(p.Property__r.Yardi_Property_Code__c)
                                            + seperator + getString(rc.Bank_Account_Number__c));
                    }
                }
            }
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMMON_BANKXREFS, dataRows);
        return mapCSVName_Content;
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    private static MAP<String, String> generateCommonBankXRefsSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = FILE_NAME_COMMON_BANKXREFS;
        String headerRow2 = newLine  + 'Property_Code,Bank_Code,Account_Code';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_COMMON_BANKXREFS + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMMON_BANKXREFS + SUFFIX_SWAY));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {

            if(String.isNotBlank(p.Property__r.Fund__c)){
                    
                //Create a Unique Key for Fund and Region
                String key = p.Property__r.Fund__c + '-' + p.Property__r.Region__c.trim().toLowerCase();
                System.debug('key::::: '+ key);
                System.debug('mapFundRegionWithRegionConfiguration:::::' + mapFundRegionWithRegionConfiguration);
                
                //Get the Region Configuration Values from Custom Setting
                if(mapFundRegionWithRegionConfiguration.containsKey(key)) {
                    
                    //Get the Region Configuration Records
                    for(Region_Configuration__c rc : mapFundRegionWithRegionConfiguration.get(key)) {
                        
                        //Append data in CSV
                        dataRows = dataRows + (newLine + 
                                    getString(p.Property__r.Yardi_Property_Code__c) + seperator + 
                                    getString(rc.Region_Short_Name__c + rc.Bank_Code_Suffix__c).toLowerCase() + seperator + 
                                    getString(rc.Bank_Account_Number__c));
                    }
                }
            }
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMMON_BANKXREFS + SUFFIX_SWAY, dataRows);
        return mapCSVName_Content;
    }
    
    //method to genrate CommUnits CSV content
    //Bhavi Sharma - 01/09/2014 - D-00013622: Updated this method to set the Rental Type = 'Admin' always
    private static MAP<String, String> generateCommUnitsCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = FILE_NAME_COMM_UNITS;
         String headerRow2 = newLine  + 'Property_Code,Unit_Code,Rental_Type,Country,Ext_Ref_Unit_Id,Ref_Property_Id,Ref_Building_Id,Ref_Floor_Id,Bldg_Code,Floor_Code,';
                headerRow2 = headerRow2 + 'Address_1,Address_2,Address_3,Address_4,City,State,Zip_Code,Rent,SQFT,Rent_Ready,BedRooms,Exclude,Available_Date,Date_Ready,Unit_Type,Location,';
                headerRow2 = headerRow2 + 'Notes,MLA,Lease_Type,Attributes_1,Attributes_2,Attributes_3,Attributes_4,Attributes_5,Attributes_6,Attributes_7,Attributes_8,Attributes_9,Attributes_10,';
                headerRow2 = headerRow2 + 'Userdefined_1,Userdefined_2,Userdefined_3,Userdefined_4,Userdefined_5,Userdefined_6,Userdefined_7,Userdefined_8,Userdefined_9,Userdefined_10';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_COMM_UNITS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMM_UNITS));

        //Set to hold Portfolio ids
        Set<Id> setPortfolios = new Set<Id>();
        
        //loop over yardi property 
        for(Yardi_Property__c yp : listYardiProperty) {
            
            //Check for null and populate set with Portfolio Ids
            if(String.isNotBlank(yp.Property__c))
                setPortfolios.add(yp.Property__c);  
        }
       
        //Check for size
        if(setPortfolios.size() > 0){
        
            Map<Id, Property__c> mapPortfolioIdWithPortfolio = new Map<Id, Property__c>([Select Id, Residence__c, Residence__r.Location__latitude__s, Residence__r.Location__longitude__s 
                                                                     from Property__c where Id IN : setPortfolios 
                                                                     and Acquisition_Status__c !=: Constants.CANCELLED 
                                                                     and Residence__c != null]);


            //loop over records to generate row content
            for(Yardi_Property__c p : listYardiProperty){
            
                String latitude = '';
                String longitude = '';
                
                //Check for map size
                if(mapPortfolioIdWithPortfolio.size() > 0 ){
                
                    //Checck for null
                    if(String.isNotBlank(p.Property__c) && mapPortfolioIdWithPortfolio.containsKey(p.Property__c) && mapPortfolioIdWithPortfolio.get(p.Property__c).Residence__c != null){
                
                        latitude = getString(String.valueOf(mapPortfolioIdWithPortfolio.get(p.Property__c).Residence__r.Location__latitude__s));
                        longitude = getString(String.valueOf(mapPortfolioIdWithPortfolio.get(p.Property__c).Residence__r.Location__longitude__s));         
                    }
                }
                
                dataRows = dataRows + (newLine + 
                getString(p.Property__r.Yardi_Property_Code__c) + seperator     //Property_Code
                + getString(p.Property__r.Yardi_Property_Code__c) + seperator  //Unit_Code
                + 'Admin' + seperator  //Rental_Type
                + '' + seperator   //Country
                + '' + seperator   //Ext_Ref_Unit_Id
                + '' + seperator   //Ref_Property_Id
                + '' + seperator   //Ref_Building_Id
                + '' + seperator   //Ref_Floor_Id
                + '' + seperator   //Bldg_Code
                + '' + seperator   //Floor_Code
                + getString(p.Addr1__c) + seperator    //Address_1
                + '' + seperator   //Address_2
                + '' + seperator   //Address_3
                + '' + seperator   //Address_4
                + getString(p.City__c) + seperator     //City
                + getString(p.State__c) + seperator    //State
                + getString(p.ZipCode__c) + seperator  //Zip_Code
                + getString(p.Rent__c) + seperator     //Rent
                + getString(p.Sqft__c) + seperator     //SQFT
                + getString(p.Rent_Ready__c) + seperator   //Rent_Ready
                + getString(p.BedRooms__c) + seperator     //BedRooms
                + getString(p.Exclude__c) + seperator  //Exclude
                + getString(p.Available_Date__c) + seperator   //Available_Date
                + getString(p.Available_Date__c) + seperator   //Date_Ready
                + getString(p.Property__r.Yardi_Property_Code__c) + seperator  //Unit_Type
                + '' + seperator   //Location
                + '' + seperator   //Notes
                + '' + seperator   //MLA
                + '' + seperator   //Lease_Type
                + '' + seperator   //Attributes_1
                + getString(p.Attributes_2__c) + seperator     //Attributes_2
                + getString(p.Parking__c) + seperator  //Attributes_3
                + '' + seperator   //Attributes_4
                + '' + seperator   //Attributes_5
                + '' + seperator   //Attributes_6
                + '' + seperator   //Attributes_7
                + '' + seperator   //Attributes_8
                + latitude + seperator   //Attributes_9
                + longitude + seperator   //Attributes_10
                + getString(p.Rent__c) + seperator     //Userdefined_1
                + '' + seperator   //Userdefined_2
                + '' + seperator   //Userdefined_3
                + '' + seperator   //Userdefined_4
                + '' + seperator   //Userdefined_5
                + '' + seperator   //Userdefined_6
                + '' + seperator   //Userdefined_7
                + '' + seperator   //Userdefined_8
                + '' + seperator   //Userdefined_9
                + ''   //Userdefined_10
                );
            }
        }
             
        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMM_UNITS, dataRows);
        return mapCSVName_Content;
     }
     
    //Bhavi Sharma - 10/25/2017 - D-00017506 
    private static Map<string, string> generateCommUnitsSWAYCSV(List<Yardi_Property__c> listYardiProperty, Map<string, string> mapCSVName_Content) {
    
        //header row content
        String headerRow1 = FILE_NAME_COMM_UNITS;
        String headerRow2 = newLine  + 'Property_Code,Unit_Code,Rental_Type,Country,';
                headerRow2 = headerRow2 + 'Available_Date,Date_Ready,Address_1,Address_2,Address_3,Address_4,City,State,Zip_Code,Rent,SQFT,Rent_Ready,Exclude,Unit_Type,';
                headerRow2 = headerRow2 + 'BedRooms,Attributes_1,Attributes_2,Attributes_3,Attributes_4,Attributes_5,Attributes_6,Attributes_7,Attributes_8,Attributes_9,Attributes_10,';
                headerRow2 = headerRow2 + 'Userdefined_1,Userdefined_2,Userdefined_3,Userdefined_4,Userdefined_5,Userdefined_6,Userdefined_7,Userdefined_8,Userdefined_9,Userdefined_10';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_COMM_UNITS + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMM_UNITS + SUFFIX_SWAY));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
             
            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                'Admin' + seperator + '' + seperator + getString(p.Available_Date__c) + seperator + getString(p.Available_Date__c) +
                                seperator + getString(p.Addr1__c) + seperator + '' + seperator + '' + seperator + '' + seperator +
                                getString(p.City__c) + seperator + getString(p.State__c) + seperator + getString(p.ZipCode__c) +
                                seperator + getString(p.Rent__c) + seperator + getString(p.Sqft__c) + seperator + getString(p.Rent_Ready__c)
                                + seperator + getString(p.Exclude__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.BedRooms__c) +
                                seperator + '' + seperator + getString(p.Attributes_2__c) + seperator + getString(p.Parking__c) +
                                seperator + '' + seperator + '' + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator + '' + seperator + '' + seperator
                                + '' + seperator + '' + seperator + getString(p.Rent__c) + seperator + '' + seperator + '' + seperator + ''
                                + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' );   
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_COMM_UNITS + SUFFIX_SWAY, dataRows);
         return mapCSVName_Content;
    } 
    
     //method to genrate ResUnitHistories CSV content
     private static MAP<String, String> generateResUnitHistoriesCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = FILE_NAME_RES_UNIT_HISTORIES;
         String headerRow2 = newLine  + 'Unit_Code,Property_Code,Ref_Unit_Id,Ref_Property_ID,Record_Type,Date,Rent,Deposit,Sqft,FSetAside,UtilityAllowance,ContractRent,RoomId,BedId,RDBasicRent,NewRentsId';

         //data rows content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_RES_UNIT_HISTORIES) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_RES_UNIT_HISTORIES));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){

             dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    '' + seperator + '' + seperator + getString(p.Record_Type__c) +
                                    + seperator + getString(p.InvestDate__c) + seperator + getString(p.Rent__c) + seperator + getString(p.Deposit__c) +
                                    seperator + getString(p.Sqft__c) + seperator + getString(p.FSetAside__c) + seperator + getString(p.UtilityAllowance__c)
                                    + seperator + '' + getString(p.ContractRent__c) + seperator + '' + seperator + '' + seperator + getString(p.RDBasicRent__c) +
                                    seperator + ''
                                    );
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_RES_UNIT_HISTORIES, dataRows);
         return mapCSVName_Content;
     }

     //method to genrate OneToManys CSV content
     private static MAP<String, String> generateOneToManysCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = HEADER_FILE_NAME_ONE_TO_MANYS;
         String headerRow2 = newLine  + 'Table_Name,Entity_Record_Code,Record_Code,Record_Name,Field_Name1,Field_Desc1,Field_Value1,Field_Name2,Field_Desc2,Field_Value2,Field_Name3,Field_Desc3,Field_Value3,Field_Name4,Field_Desc4,Field_Value4,Field_Name5,Field_Desc5,Field_Value5,Field_Name6,Field_Desc6,Field_Value6,Field_Name7,Field_Desc7,Field_Value7,Field_Name8,Field_Desc8,Field_Value8';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_ONE_TO_MANYS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ONE_TO_MANYS));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){

             dataRows = dataRows + (newLine + getString(p.Table_Name__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    '' + seperator + '' + seperator + getString(p.Field_Name1__c) + seperator + ''
                                    + seperator + getString(p.Field_Value1__c) + seperator + getString(p.Field_Name2__c) + seperator + '' +
                                    seperator + getString(p.Field_Value2__c) + seperator + getString(p.Field_Name3__c) + seperator + '' + seperator + getString(p.Field_Value3__c)
                                    + seperator + getString(p.Field_Name4__c) + seperator + '' + seperator + getString(p.Field_Value4__c) + seperator + '' + seperator + '' + seperator + '' + seperator + '' +
                                    seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' +
                                    seperator + '' + seperator + ''
                                    );
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_ONE_TO_MANYS, dataRows);
         return mapCSVName_Content;
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    private static MAP<String, String> generateOneToManysPropInfoSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = HEADER_FILE_NAME_ONE_TO_MANYS;
         String headerRow2 = newLine  + 'Table_Name,Entity_Record_Code,Record_Code,Record_Name,Field_Name1,Field_Desc1,Field_Value1,Field_Name2,Field_Desc2,Field_Value2,Field_Name3,Field_Desc3,Field_Value3,Field_Name4,Field_Desc4,Field_Value4,Field_Name5,Field_Desc5,Field_Value5,Field_Name6,Field_Desc6,Field_Value6';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_ETL_COMMON_ONETOMANY_PROP_INFO + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ETL_COMMON_ONETOMANY_PROP_INFO + SUFFIX_SWAY));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){

             dataRows = dataRows + (newLine + getString(p.Table_Name__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    '' + seperator + '' + seperator + getString(p.Field_Name1__c) + seperator + ''
                                    + seperator + getString(p.Field_Value1__c) + seperator + getString(p.Field_Name2__c) + seperator + '' +
                                    seperator + getString(p.Field_Value2__c) + seperator + getString(p.Field_Name3__c) + seperator + '' + seperator + getString(p.Field_Value3__c)
                                    + seperator + getString(p.Field_Name4__c) + seperator + '' + seperator + getString(p.Field_Value4__c) + seperator + '' + seperator + '' + seperator + '' + seperator + '' +
                                    seperator + '' + seperator + '');
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_ETL_COMMON_ONETOMANY_PROP_INFO + SUFFIX_SWAY, dataRows);
         return mapCSVName_Content;
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    private static MAP<String, String> generateOneToManysUnitInfoSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

         //header row content
         String headerRow1 = HEADER_FILE_NAME_ONE_TO_MANYS;
         String headerRow2 = newLine  + 'Table_Name,Entity_Record_Code,Parent_Code1,Record_Code,Record_Name,Field_Name1,Field_Desc1,Field_Value1,Field_Name2,Field_Desc2,Field_Value2,Field_Name3,Field_Desc3,Field_Value3,Field_Name6,Field_Desc6,Field_Value6,Field_Name12,Field_Desc12,Field_Value12,Field_Name50,Field_Desc50,Field_Value50,Field_Name51,Field_Desc51,Field_Value51';

         //data row content
         String dataRows = (mapCSVName_Content.get(FILE_NAME_ETL_ONETOMANY_UNIT_INFO + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ETL_ONETOMANY_UNIT_INFO + SUFFIX_SWAY));

         //loop over records to generate row content
         for(Yardi_Property__c p : listYardiProperty){

             dataRows = dataRows + (newLine + getString(p.Table_Name__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator + '' + seperator +
                                    '' + seperator + '' + seperator + getString(p.Field_Name1__c) + seperator + ''
                                    + seperator + getString(p.Field_Value1__c) + seperator + getString(p.Field_Name2__c) + seperator + '' +
                                    seperator + getString(p.Field_Value2__c) + seperator + getString(p.Field_Name3__c) + seperator + '' + seperator + getString(p.Field_Value3__c)
                                    + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '' +
                                    seperator + '' + seperator + '' + seperator + '' + seperator + '' + seperator + '');
         }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_ETL_ONETOMANY_UNIT_INFO + SUFFIX_SWAY, dataRows);
         return mapCSVName_Content;
    }

    private static MAP<String, String> mapPortfolioVal_YardiVal = new Map<String, String>{
        'Acquired'  => 'Active' ,
        'Limbo'     => 'Future - Bankruptcy Dispute',
        'Cancelled' => 'Inactive - Bankruptcy Takeback',
        'Sold'      => 'Inactive - Sold',
        'For Sale'  => 'For Sale'
    };

    // Added by Rajesh - 1/10/2013
    private static MAP<String, String> generateAttributesPropertyStatusCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_ATTRIBUTES_PROPERY_STATUS;
        String headerRow2 = newLine  + 'Property_Code,Attribute_Set_Code,Attribute_Name,Attribute_Value';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_PROPERY_STATUS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_PROPERY_STATUS));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                    + 'Property Status' + seperator + replaceAcquisitionStatusOption(getString(p.Property__r.Acquisition_Status__c))
                                    );
        }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_ATTRIBUTES_PROPERY_STATUS, dataRows);
         return mapCSVName_Content;
    }

    private static String replaceAcquisitionStatusOption(String portfolioValue){
        return ( portfolioValue != null && mapPortfolioVal_YardiVal.containsKey(portfolioValue) ) ? mapPortfolioVal_YardiVal.get(portfolioValue) : portfolioValue;
    }

    // Added by Rajesh - 25/6/2013
   private static Map<String, String> generatePortfolioManagersCSV(List<Yardi_Property__c> listYardiProperty, Map<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_PORTFOLIO_MANAGERS;
        String headerRow2 = newLine  + 'Property_Code,Attribute_Set_Code,Attribute_Name,Attribute_Value';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_PORTFOLIO_MANAGERS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_PORTFOLIO_MANAGERS));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                + 'Portfolio Manager' + seperator + getString(p.Property__r.Owner.Name)
                            );
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_PORTFOLIO_MANAGERS, dataRows);
        return mapCSVName_Content;
    }

    private static MAP<String, String> generateUnitTypesCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_UNIT_TYPES;
        String headerRow2 = newLine  + 'UnitType_Code,Property_Code,Description,Beds,Baths,SQFT,Rent,Deposit';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_UNIT_TYPES) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_UNIT_TYPES));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
            String description = '';
            if(getString(p.BedRooms__c) != '')
                description += getString(p.BedRooms__c) + ' Bedroom';
            if(getString(p.Baths__c) != '') {
                if(description != '')
                    description += '\\';
                description += getString(p.Baths__c) + ' Bath';
            }

            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator
                                    + description + seperator
                                    + getString(p.BedRooms__c) + seperator + getString(p.Baths__c) + seperator + getString(p.sqft__c) + seperator
                                    + getString(p.Rent__c) + seperator + getString(p.Deposit__c)
                                    );
        }

        //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_UNIT_TYPES, dataRows);
         return mapCSVName_Content;
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    private static MAP<String, String> generateUnitTypesSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_UNIT_TYPES;
        String headerRow2 = newLine  + 'UnitType_Code,Ref_Property_ID,Property_Code,Description,Beds,Baths,SQFT,Rent,Deposit,MinimumRent,Maximim_Rent,UserDefined_1,UserDefined_2,UserDefined_3,UserDefined_4';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_UNIT_TYPES + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_UNIT_TYPES + SUFFIX_SWAY));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty){
            String description = '';
            if(getString(p.BedRooms__c) != '')
                description += getString(p.BedRooms__c) + ' Bedroom';
            if(getString(p.Baths__c) != '') {
                if(description != '')
                    description += '\\';
                description += getString(p.Baths__c) + ' Bath';
            }

            dataRows = dataRows + (newLine + 
                                    getString(p.Property__r.Yardi_Property_Code__c) + seperator + //UnitType_Code
                                    '' + seperator + //Ref_Property_ID
                                    getString(p.Property__r.Yardi_Property_Code__c) + seperator + //Property_Code
                                    description + seperator + //Description
                                    getString(p.BedRooms__c) + seperator + //Beds
                                    getString(p.Baths__c) + seperator + //Baths
                                    getString(p.sqft__c) + seperator + //SQFT
                                    getString(p.Rent__c) + seperator + //Rent
                                    getString(p.Deposit__c) + seperator + //Deposit
                                    '' + seperator + //MinimumRent
                                    '' + seperator + //Maximim_Rent
                                    '' + seperator + //UserDefined_1
                                    '' + seperator + //UserDefined_2
                                    '' + seperator + //UserDefined_3
                                    '' //UserDefined_4
                                  );
        }

        //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_UNIT_TYPES + SUFFIX_SWAY, dataRows);
         return mapCSVName_Content;
    }

    // Added by Rajesh - 1/29/2013
    private static MAP<String, String> generateAttributesUnitTypesCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_ATTRIBUTES_UNIT_TYPES;
        String headerRow2 = newLine  + 'Property_Code,Attribute_Set_Code,Attribute_Name,Attribute_Value';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_UNIT_TYPES) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_UNIT_TYPES));

        Map<String, String> bedroomMap = new Map<String, String> {
            '0' => 'A', '1' => 'A', '2' => 'B', '3' => 'C', '4' => 'D', '5' => 'E', '6' => 'F', '7' => 'G', '8' => 'H', '9' => 'I'
        };

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {
            String attrVal = '';
            if(getString(p.BedRooms__c) != '')
                attrVal = bedroomMap.get(getString(p.BedRooms__c)) + getString(p.BedRooms__c);
            if(getString(p.Baths__c) != '') {
                if(attrVal != '')
                    attrVal += '.';
                attrVal += getString(p.Baths__c);
            }

            dataRows = dataRows + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'THR' + seperator
                                    + 'Unit Type' + seperator + attrVal
                                    );
        }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(FILE_NAME_ATTRIBUTES_UNIT_TYPES, dataRows);
         return mapCSVName_Content;
    }

    /**
     *  @description    :   This method is to generate the file with Rehab information where either Re Key Ready date or Sign-Off date is changed
     *
     *  @args           :   List of yardi records
     *
     *  @return         :   Content
     *
     **/
    public static MAP<String, String> generateRehabOneToManyCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //header row content
        String headerRow1 = HEADER_FILE_NAME_ONE_TO_MANYS;
        String headerRow2 = newLine  + 'Table_Name,Entity_Record_Code,Record_Code,Record_Name,Field_Name1,Field_Desc1,Field_Value1,Field_Name2,Field_Desc2,Field_Value2';

        //data row content
        String dataRows = (mapCSVName_Content.get(HEADER_FILE_NAME_ATTRIBUTES_REHAB_ONE_TO_MANY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_ATTRIBUTES_UNIT_TYPES));

        //loop over records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {

            //Rekey Date
            String reKeyDate = '';
            if(p.Rehab_Re_Key_Date__c != null)
                reKeyDate = p.Rehab_Re_Key_Date__c.format();

            //Signoff Date
            String officeSignOffDate = '';
            if(p.Rehab_Office_Signoff_Date__c != null)
                officeSignOffDate = p.Rehab_Office_Signoff_Date__c.format();


            dataRows = dataRows + (newLine + 'PROPBUT13' + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator +
                                    '' + seperator + '' + seperator +
                                    'REHABDATE' + seperator + '' + seperator + reKeyDate + seperator +
                                    'REHABDATE2' + seperator + '' + seperator + officeSignOffDate);
        }

         //fill map mapCSVName_Content
         mapCSVName_Content.put(HEADER_FILE_NAME_ATTRIBUTES_REHAB_ONE_TO_MANY, dataRows);
         return mapCSVName_Content;
    }
    
    /**
     *   @description:  This method is to create the IA_Commitments CSV fiel.
     *
     *   @args       :   List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content
     *
     *   @return     :   MAP<String, String>
     *
     **/
    public static MAP<String, String> generateIACommitmentsCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //Header row's content
        String headerRow1 = HEADER_FILE_NAME_IA_COMMITMENTS;
        String headerRow2 = newLine  + 'InvestorCode,InvestmentCode,DateStart,Percent,TransactionCurrencyCode,InvestorCurrencyCode,InvestmentCurrencyCode,Amount,Shares,TotalFlag,DateEnd,RuleSet,CascadeSet,FeeAllocationRuleSet,FeeCalculationRuleSet,InvestorRate,InvestmentRate,TransactionAmount,TotalTransactionAmount,TotalAmount,InvestmentAmount,TotalInvestmentAmount,AllocationSet,PerfRuleSet,Notes,SharePrice,Field1,Field2,Field3,Field4';

        //Data row's content
        String dataRows = (mapCSVName_Content.get(HEADER_FILE_NAME_IA_COMMITMENTS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(HEADER_FILE_NAME_IA_COMMITMENTS));
        
        //loop through the properties
        for(Yardi_Property__c p : listYardiProperty) {
            
            //String to hold the "Inverster Code" value for the row in current context
            String investorCode = '';
            
            //Modified by Poonam Bhargava(D-00016564)- 12/02/2016
            //Check Fund Value,State value and get the related Code
            if(String.isNotBlank(p.Property__r.Fund__c) && String.isNotBlank(p.Property__r.Property_State__c)){
            
                //String variable to hold state code in lower case
                String propState = (p.Property__r.Property_State__c).toLowerCase();
            
                //Added by Poonam Bhargava(03/03/2017)- D-00016962 for California
                if(propState == 'ca')
                    investorCode += 'ih' + p.Property__r.Fund__c + 'ws';
                else
                    investorCode += 'ih' + p.Property__r.Fund__c + propState;
            } 
            
            //Start date
            Date startDate = Date.today() - 1;
            if(p.Property__r.Reporting_Date__c != null)
                startDate = p.Property__r.Reporting_Date__c;
            
            startDate = startDate.addMonths(-1);
            String startDateText = startDate.month() + '/01/' + startDate.year();
            
            dataRows = dataRows + (newLine + 
                        investorCode + seperator +  //InvestorCode
                        getString(p.Property__r.Yardi_Property_Code__c) + seperator +   //InvestmentCode
                        startDateText + seperator +     //DateStart
                        '100' + seperator +     //Percent
                        '' + seperator +    //TransactionCurrencyCode
                        '' + seperator +    //InvestorCurrencyCode
                        '' + seperator +    //InvestmentCurrencyCode
                        '' + seperator +    //Amount
                        '' + seperator +    //Shares
                        '' + seperator +    //TotalFlag
                        '' + seperator +    //DateEnd
                        'ihpc' + seperator +    //RuleSet
                        '' + seperator +    //CascadeSet
                        '' + seperator +    //FeeAllocationRuleSet
                        '' + seperator +    //FeeCalculationRuleSet
                        '' + seperator +    //InvestorRate
                        '' + seperator +    //InvestmentRate
                        '' + seperator +    //TransactionAmount
                        '' + seperator +    //TotalTransactionAmount
                        '' + seperator +    //TotalAmount
                        '' + seperator +    //InvestmentAmount
                        '' + seperator +    //TotalInvestmentAmount
                        '' + seperator +    //AllocationSet
                        '' + seperator +    //PerfRuleSet
                        '' + seperator +    //Notes
                        '' + seperator +    //SharePrice
                        '' + seperator +    //Field1
                        '' + seperator +    //Field2
                        '' + seperator +    //Field3
                        ''  //Field4
                    );
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(HEADER_FILE_NAME_IA_COMMITMENTS, dataRows);
        return mapCSVName_Content;        
    }
    
    //Bhavi Sharma - 10/25/2017 - D-00017506
    public static MAP<String, String> generateIACommitmentsSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {

        //Header row's content
        String headerRow1 = HEADER_FILE_NAME_IA_COMMITMENTS;
        String headerRow2 = newLine  + 'InvestorCode,InvestmentCode,DateStart,Percent,Foreign_Db_Name,Amount,Shares,TotalFlag,DateEnd,RuleSet,CascadeSet,DealCode';

        //Data row's content
        String dataRows = (mapCSVName_Content.get(HEADER_FILE_NAME_IA_COMMITMENTS + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(HEADER_FILE_NAME_IA_COMMITMENTS + SUFFIX_SWAY));
        
        //loop through the properties
        for(Yardi_Property__c p : listYardiProperty) {
            
            //String to hold the "Inverster Code" value for the row in current context
            String investorCode = '';
            
            //Check Fund Value,State value and get the related Code
            if(String.isNotBlank(p.Property__r.Fund__c) && String.isNotBlank(p.Property__r.Property_State__c)){
            
                String propState = (p.Property__r.Property_State__c).toLowerCase();
                investorCode += 'ih' + p.Property__r.Fund__c + propState;
            } 
            
            //Start date
            Date startDate = Date.today() - 1;
            if(p.Property__r.Reporting_Date__c != null)
                startDate = p.Property__r.Reporting_Date__c;
            
            startDate = startDate.addMonths(-1);
            String startDateText = startDate.month() + '/01/' + startDate.year();
            
            dataRows = dataRows + (newLine + 
                        investorCode + seperator +  //InvestorCode
                        getString(p.Property__r.Yardi_Property_Code__c) + seperator +   //InvestmentCode
                        startDateText + seperator +     //DateStart
                        '100' + seperator +     //Percent
                        '' + seperator +    //Foreign_Db_Name
                        '' + seperator +    //Amount
                        '' + seperator +    //Shares
                        '' + seperator +    //TotalFlag
                        '' + seperator +    //DateEnd
                        '' + seperator +    //RuleSet
                        '' + seperator +    //CascadeSet
                        ''    //DealCode
                    );
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(HEADER_FILE_NAME_IA_COMMITMENTS + SUFFIX_SWAY, dataRows);
        return mapCSVName_Content;        
    }
    
    //Added By Abhinav Sharma - 12/17/2015 - (D-00014839)
    /**
     *  @description    :   Method to genrate ResSpecials CSV content.
     * 
     *  @args           :   List<Yardi_Property__c> listYardiProperty, map<string, string> mapCSVName_Content
     * 
     *  @return         :   map<string, string>
     * 
    **/
    private static map<string, string> generateResSpecialsCSV(List<Yardi_Property__c> listYardiProperty, map<string, string> mapCSVName_Content) {

        //header row content
        string headerRow1 = FILE_NAME_RES_SPECIALS;
        string headerRow2 = newLine  + 'Property_Code,Desc,Amount,Charge_Code,Is_Renewal,Is_NewMoveIn,MinLeaseTerm,LeasingSpecialType,Ref_Unit_Id,Ref_Property_ID,UnitType_Code,Unit_Code,MaxLeaseTerm,Start_Date,Expiration_Date,FrequencyType,StartMonth,Taxable,Modifiable,Proration,Recurrences,Notes,Is_ShowOnPortal,Portal_Description,iAmountType';

        //data row content
        string dataRows = (mapCSVName_Content.get(FILE_NAME_RES_SPECIALS) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_RES_SPECIALS));

        //loop over yardi property records to generate row content
        for(Yardi_Property__c p : listYardiProperty) {
            
            //Checking for property reference value for null/blank value
            if(p.Property__c != null) {
                
                //Initialize date variable
                Date startDate;
                
                //Check for reporting date of property
                if(p.Property__r.Reporting_Date__c != null)
                    startDate = p.Property__r.Reporting_Date__c;
                
                //Initialize string variable to hold reporting date as string
                string propertyStartDate = '';
                
                //Check for null
                if(startDate != null)
                    propertyStartDate = startDate.format();
                
                //Constructing data rows for this file
                dataRows = dataRows +
                                    (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Multi Year Rent Adjustment' + seperator +  '1' + seperator + 'conlbump' 
                                    + seperator + '0' + seperator + '1' + seperator + '13' + seperator + '0' + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator 
                                    + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator 
                                    + getString(p.Property__r.Yardi_Property_Code__c) + seperator + '24' + seperator + propertyStartDate + seperator + ' ' 
                                    + seperator + '1' + seperator + '1' + seperator + '0' + seperator + '-1' + seperator + '1' + seperator + '12' + seperator +  'Multi Year Rent Adjustment' 
                                    + seperator + '0' + seperator + ' ' + seperator + '0' )
                                    + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + 'Multi Year Rent Adjustment - Month 13 proration' + seperator +  '1' 
                                    + seperator + 'conlbump' + seperator + '0' + seperator + '1'  + seperator + '13' + seperator + '0' + seperator + getString(p.Property__r.Yardi_Property_Code__c)
                                    + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator + getString(p.Property__r.Yardi_Property_Code__c) + seperator 
                                    + getString(p.Property__r.Yardi_Property_Code__c) + seperator + '24' + seperator + propertyStartDate + seperator + ' ' 
                                    + seperator + '0' + seperator + '13' + seperator + '0' + seperator + '-1' + seperator + '1' + seperator + 'NULL' + seperator
                                    + 'Multi Year Rent Adjustment - Month 13 proration' + seperator +  '0' + seperator + ' ' + seperator + '0' );   
            }
        }
            
        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_RES_SPECIALS, dataRows);
        return mapCSVName_Content;
    }  
    
    //Added By Poonam Bhargava - 04/04/2017 - (D-00017023)
    /**
     *  @description    :   Method to genrate CommProperties1 CSV content.
     * 
     *  @args           :   List<Yardi_Property__c> listYardiProperty, map<string, string> mapCSVName_Content
     * 
     *  @return         :   map<string, string>
     * 
    **/
    private static Map<string, string> generateCommProperties1CSV(List<Yardi_Property__c> listYardiProperty, Map<string, string> mapCSVName_Content) {

        //Set to hold Portfolio ids
        Set<Id> setPortfolios = new Set<Id>();
        
        //Initialize map with Portfolio Id as key and Disposition as Value
        Map<Id, Disposition__c> mapPortfolioIdWithDispositions = new Map<Id, Disposition__c>();   
            
        //header row content
        String headerRow1 = FILE_NAME_COMM_PROPERTIES;
        String headerRow2 = newLine  + 'Property_Code,Disposition_Asset_Date';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_COMMPROPERTIES1) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_COMMPROPERTIES1));

        //loop over yardi property 
        for(Yardi_Property__c yp : listYardiProperty) {
            
            //Check for null and populate set with Portfolio Ids
            if(String.isNotBlank(yp.Property__c))
                setPortfolios.add(yp.Property__c);  
        }
            
        //Check for set size
        if(setPortfolios.size() > 0){
            
            //Loop over Disposition and populate map mapPortfolioIdWithDispositions with Portfolio as key and Dispositions as value
            for(Property__c prop : [Select Id,(Select Id, Settlement_Date__c from Dispositions__r order by CreatedDate DESC LIMIT 1) 
                                        from Property__c where Id IN : setPortfolios and Yardi_Attributes_PropertyStatus__c = true
                                        and Acquisition_Status__c = : Constants.PORTFOLIO_ACQ_STATUS_SOLD]){
                //Populate map
                if(prop.Dispositions__r.size() > 0)
                    mapPortfolioIdWithDispositions.put(prop.Id, prop.Dispositions__r);                              
            }
        }
        
        //Check for map mapPortfolioIdWithDispositions size   
        if(mapPortfolioIdWithDispositions.size() > 0){
            
            //loop over records to generate row content
            for(Yardi_Property__c p : listYardiProperty){
                
                //Initialize string variable to hold reporting date as string
                String propertyDispDate;
                    
                //Check for null
                if(p.Property__c != null){
                    
                    //Check mapPortfolioIdWithDispositions for eligible criteria 
                    if(mapPortfolioIdWithDispositions.containsKey(p.Property__c)) {
                        
                        //Check map for null and populate the values in varibale propertyDispDate
                        if(mapPortfolioIdWithDispositions.get(p.Property__c).Settlement_Date__c != null)
                            propertyDispDate = mapPortfolioIdWithDispositions.get(p.Property__c).Settlement_Date__c.format();
                        else
                            propertyDispDate = '';
                        
                        //Constructing data rows for this file
                        dataRows = dataRows +
                                (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + propertyDispDate);     
                    }
                }           
            }   
        }  
           
        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_COMMPROPERTIES1, dataRows);
        return mapCSVName_Content;
    } 
    
    //Added By Poonam Bhargava - 04/13/2017 - (D-00017047)
    /**
     *  @description    :   Method to genrate LateFeeCofiguration CSV content.
     * 
     *  @args           :   List<Yardi_Property__c> listYardiProperty, map<string, string> mapCSVName_Content
     * 
     *  @return         :   map<string, string>
     * 
    **/
    private static Map<string, string> generateLateFeeCofigurationCSV(List<Yardi_Property__c> listYardiProperty, Map<string, string> mapCSVName_Content) {
    
        //Set to hold Portfolio Region
        Set<String> setPortfolioRegion = new Set<String>();
        
        //Initialize map to hold Region as key and custom metadata LateFeeDefaultConfig__mdt as value
        Map<String, List<LateFeeDefaultConfig__mdt>> mapOfLateFeeDefault = new Map<String, List<LateFeeDefaultConfig__mdt>>(); 
    
        //header row content
        String headerRow1 = HEADER_FILE_NAME_LATE_FEE;
        String headerRow2 = newLine  + 'Property_Code,Ref_Property_Id,Type,StringValue,HandleValue,HandleValueInt,Date';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_LATE_FEE) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_LATE_FEE));
        
        //loop over yardi property 
        for(Yardi_Property__c yp : listYardiProperty) {
            
            //Check for null and populate set with Portfolio Region
            if(String.isNotBlank(yp.Property__c) && String.isNotBlank(yp.Property__r.Region__c))
                setPortfolioRegion.add(yp.Property__r.Region__c);  
        }
        
        //Check for set size
        if(setPortfolioRegion.size() > 0){
        
            //Loop over LateFeeDefaultConfig__mdt
            for(LateFeeDefaultConfig__mdt lateFeeDefault :[Select Id, Region__c, City__c, Type__c, StringValue__c, HandleValue__c, HandleValueInt__c 
                                                                    from LateFeeDefaultConfig__mdt where Region__c IN : setPortfolioRegion]){
            
                //String value to hold Region in lower case
                String region = lateFeeDefault.Region__c.toLowerCase();
                if(String.IsNotBlank(lateFeeDefault.City__c))
                    region = region + '-' + lateFeeDefault.City__c.toLowerCase();
                    
                //Check map mapOfLateFeeDefault for key and populate accordingly
                if(!mapOfLateFeeDefault.containsKey(region))
                    mapOfLateFeeDefault.put(region, new List<LateFeeDefaultConfig__mdt>());
                
                mapOfLateFeeDefault.get(region).add(lateFeeDefault);
            }   
        }
        
        //Check for map size
        if(mapOfLateFeeDefault.size() > 0 ){
        
            //loop over yardi property 
            for(Yardi_Property__c p : listYardiProperty) {
                
                //Checking for property reference value for null/blank value
                if(p.Property__c != null && String.isNotBlank(p.Property__r.Region__c)) {
                    
                    //String value to hold Region in lower case
                    String strRegion = p.Property__r.Region__c.toLowerCase();
                    
                    if(strRegion.equalsIgnoreCase('Chicago') 
                        && String.isNotBlank(p.Property__r.Property_City__c) 
                        && p.Property__r.Property_City__c.equalsIgnoreCase('Chicago'))
                        strRegion = strRegion + '-' + p.Property__r.Property_City__c.toLowerCase();
                    
                    //Check for kregion key in map
                    if(String.isNotBlank(strRegion) && mapOfLateFeeDefault.containsKey(strRegion)){
                        
                        //Loop over map values
                        for(LateFeeDefaultConfig__mdt mtd : mapOfLateFeeDefault.get(strRegion)){
                            
                            //Constructing data rows for this file
                            dataRows = dataRows +
                                        + (newLine + getString(p.Property__r.Yardi_Property_Code__c) + seperator + '' + seperator +
                                            +  mtd.Type__c + seperator 
                                            + (mtd.StringValue__c == null ? '': mtd.StringValue__c) + seperator
                                            + (mtd.HandleValue__c == null ? '': mtd.HandleValue__c) + seperator
                                            + (mtd.HandleValueInt__c == null ? '': mtd.HandleValueInt__c) + seperator+ '');
                        }   
                    }       
                }   
            }   
        }

        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_LATE_FEE, dataRows);
        return mapCSVName_Content;      
    }  
    
    //Added by Poonam Bhargava - D-00017506
    private static MAP<String, String> generateUnitAvailabilityDetailsSWAYCSV(List<Yardi_Property__c> listYardiProperty, MAP<String, String> mapCSVName_Content) {
    
        //Set to hold Portfolio ids
        Set<Id> setPortfolios = new Set<Id>();
          
        //header row content
        String headerRow1 = FILE_NAME_UNIT_AVAILABILITY_DETAILS;
        String headerRow2 = newLine  + 'Unit,Resident,Name,Resident Rent,Unit Status,Make Ready,Move In,Move Out, Lease From, Lease To';

        //data row content
        String dataRows = (mapCSVName_Content.get(FILE_NAME_UNIT_AVAILABILITY_DETAILS + SUFFIX_SWAY) == null ? (headerRow1 + headerRow2) : mapCSVName_Content.get(FILE_NAME_UNIT_AVAILABILITY_DETAILS + SUFFIX_SWAY));
        
        //loop over yardi property 
        for(Yardi_Property__c yp : listYardiProperty) {
            
            //Check for null and populate set with Portfolio Ids
            if(String.isNotBlank(yp.Property__c))
                setPortfolios.add(yp.Property__c);  
        }
        
        //Check for size
        if(setPortfolios.size() > 0){
       
            //Retrieve record from Property
            Map<Id, Property__c> mapPortfolioIdWithPortfolio = new Map<Id, Property__c>(
                                                                    [Select Id, Residence__c, Residence__r.Most_Recent_Lease__c, Residence__r.Most_Recent_Lease__r.tCode_LastName__c,
                                                                        Residence__r.Most_Recent_Yardi_Rent_Roll__c,Residence__r.Most_Recent_Yardi_Rent_Roll__r.Unit_Status__c, 
                                                                        Residence__r.Most_Recent_Yardi_Rent_Roll__r.Resident_Rent__c, Residence__r.Most_Recent_Yardi_Rent_Roll__r.Current_Unit_status__c, 
                                                                        Residence__r.Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c, Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_In_Date__c, 
                                                                        Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c, Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_Start_Current_Tenant__c, 
                                                                        Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_End_Current_Tenant__c 
                                                                        from Property__c where Id IN : setPortfolios and Acquisition_Status__c !=: Constants.CANCELLED
                                                                        and Residence__c != null]); 
        
            //Check for map size
            if(mapPortfolioIdWithPortfolio.size() > 0 ){
            
                //Loop over Yardi Property
                for(Yardi_Property__c yp : listYardiProperty){
            
                    //Checck for null
                    if(String.isNotBlank(yp.Property__c) && mapPortfolioIdWithPortfolio.containsKey(yp.Property__c)){
                        
                        //String variables  
                        String tCode = '';
                        
                        //Check for eligible criteria and populate string varibales acordingly
                        if(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Lease__c != null )
                            tCode = getString(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Lease__r.tCode_LastName__c);
                    
                        //Checl for null and populate staring avriable accordingly
                        if(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__c != null){
                            
                            //Constructing data rows for this file
                            dataRows = dataRows +
                                            + (newLine + getString(yp.Property__r.Yardi_Property_Code__c) 
                                            + seperator + tCode
                                            + seperator + getString(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Unit_Status__c)
                                            + seperator + getString(String.ValueOf(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Resident_Rent__c))
                                            + seperator + getString(mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Current_Unit_status__c)
                                            + seperator + (mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c != null ? mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Yardi_Make_Ready_Date__c.format() : '')
                                            + seperator + (mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_In_Date__c != null ? mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_In_Date__c.format() : '')
                                            + seperator + (mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c != null ? mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Move_Out_Date__c.format() : '')
                                            + seperator + (mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_Start_Current_Tenant__c != null ? mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_Start_Current_Tenant__c.format() : '')
                                            + seperator + (mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_End_Current_Tenant__c != null ? mapPortfolioIdWithPortfolio.get(yp.Property__c).Residence__r.Most_Recent_Yardi_Rent_Roll__r.Lease_Period_End_Current_Tenant__c.format() : '')); 
                            
                        } 
                        else {
                            //Constructing data rows for this file
                            dataRows = dataRows +
                                            + (newLine + getString(yp.Property__r.Yardi_Property_Code__c) 
                                            + seperator + tCode
                                            + seperator + ''
                                            + seperator + ''
                                            + seperator + 'Vacant Unrented Ready'
                                            + seperator + ''
                                            + seperator + ''
                                            + seperator + ''
                                            + seperator + ''
                                            + seperator + ''); 
                        }                       
                    }   
                }       
            }               
        }
        
        //fill map mapCSVName_Content
        mapCSVName_Content.put(FILE_NAME_UNIT_AVAILABILITY_DETAILS + SUFFIX_SWAY, dataRows);
        return mapCSVName_Content;      
    }
}