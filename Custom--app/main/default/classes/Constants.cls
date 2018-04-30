/**
 *  Description :   Class to hold constant properties.
 *
 *  Created By  :   Bhavi
 *
 *  Created Date:   07/22/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - New variables added
 *                  V1.2 - (01/03/2013) - Bhavi - New Variable added - EXECUTE_TRIGGER
 *                  V1.3 - (02/01/2013) - Bhavi - New Variables added
 *                  V1.4 - (02/02/2013) - Bhavi - New Variables added, Test
 *                  v1.5 - (12/09/2013) - Abhinav Sharma - New Variables added as per SIR - D-00006519
                                    Test Comment  
 *                  v1.6 - (7/08/2015)  - Saurabh kumar - New Variables added as per SIR - D-00014396 ,
 *                                 ERROR_Accquisation_field

 *                  v1.7 - (4/27/2016) -  Saurabh Kumar - New variable added as per SIR - D-00015412 ,PORTFOLIO_ACQ_STATUS_SOLD
 *                  v1.8 - (5/2/2016)  -  Saurabh kumar - New variable added as per SIR - D-00015385 under comments //Variable To be used in For Acquisition Staus Change Functionality
 *                  v1.9 - (5/30/2016) -  Saurabh -D-00015599/D-00015412 - New Variables for Renewal Status/Sold Property Error Message  
 *                  v1.10 -(6/20/2016) -  Saurabh Kumar - New vaiable added for Online Platform Variable -D-00015770
 *                  v1.11 -(8/11/2016) -  Saurabh Kumar - New vaiable added for Online Platform Variable -D-00016046
 *                  V1.12 - (08/01/2017) - Poonam Bhargava - new Varibale for SIR D-00017394
 *                  V1.13 - Poonam Bhargava - Added new varibale for Sway Prospect 
 *                  V1.14 - Poonam Bhargava - new variable for D-00017574

 **/
public class Constants {

    //Variable
    public static final String NEW_LEASE_SIGNED = 'New Lease Signed';
    public static final String PRIOR_LEASE_APPROVED = 'Prior Lease Approved';
    public static final String MOVED_OUT = 'Moved Out';
    public static final String YES = 'YES';
    public static final String NO  = 'NO';
    public static final String REGION_NATIONAL = 'National';
    public static final String REGION_ATLANTA = 'Atlanta';
    public static final String COMPLETED = 'Completed';
    public static final String EVICTION_COMPLETE = 'Eviction Complete';
    public static final String POSTACQ_BK_UNRESOLVED = 'PostAcq BK Unresolved';
    public static final String NEW_LEASE_UNDERWRITING_APPROVED = 'New Lease - Underwriting Approved';
    public static final String NEW_LEASE_SUBMITTED_FOR_UNDERWRITING = 'New Lease Submitted for Underwriting';
    public static final String NEW_LEASE_NEGOTIATIONS_UNDERWAY = 'New Lease Negotiations Underway';
    public static final String CFK_NEGOTIATION_IN_PROCESS = 'CFK Negotiation in Process';
    public static final String CFK_AGREED_WITH_OCCUPANT = 'CFK Agreed with Occupant';
    public static final String CFK_CHECK_REQUESTED_FROM_FINANCE = 'CFK Check Requested from Finance';
    public static final String CFK_CHECK_RECEIVED_FROM_FINANCE = 'CFK Check Received from Finance';
    public static final String CFK_CHECK_GIVEN_TO_DRIVER = 'CFK Check given to Driver';
    public static final String AWAITING_CONSTABLE_LOCK = 'Awaiting Constable Lock';
    public static final String AWAITING_EVICTION_WRIT = 'Awaiting Eviction Writ';
    public static final String AWAITING_EVICTION_COURT_DATE = 'Awaiting Eviction Court Date';
    public static final String EVICTION_LETTER_SENT = 'Eviction Letter Sent';
    public static final String REFERRED_TO_EVICTION_ATTORNEY = 'Referred to Eviction Attorney';
    public static final String INITIAL_EVICTION_NOTICE_SENT = 'Initial Eviction Notice Sent';
    public static final String INITIAL_CONTACT_NEGOTIATION_IN_PROCESS = 'Initial Contact - Negotiation in Process';
    public static final String X_3RD_NOTICE_LEFT = '3rd Notice Left';
    public static final String X_2ND_NOTICE_LEFT = '2nd Notice Left';
    public static final String X_1ST_NOTICE_LEFT = '1st Notice Left';
    public static final String DRIVER_ASSIGNED = 'Driver Assigned';
    public static final String REFERRED_FOR_3RD_PARTY_DOOR_KNOCK = 'Referred for 3rd Party Door Knock';
    public static final String PRIOR_LEASE_SUBMITTED_FOR_UNDERWRITING = 'Prior Lease Submitted for Underwriting';
    public static final String PURCHASED_RENTED = 'Purchased Rented';
    public static final String PREACQ_BK = 'PreAcq BK';
    public static final String REHAB_IN_PROCESS = 'Rehab in Process';
    public static final String WAITING_FOR_DEED = 'Waiting for Deed';
    public static final String REFER_TO_REHAB = 'Refer to Rehab';
    public static final String EVICTION_IN_PROCESS = 'Eviction in Process';
    public static final String LEASE_UNDER_REVIEW = 'Lease Under Review';
    public static final String CFK_IN_PROCESS = 'CFK in Process';
    public static final String CONTACTED_IN_PROCESS = 'Contacted - In Process';
    public static final String ATTEMPTING_CONTACT = 'Attempting Contact';
    public static final String NO_CONTACT = 'No Contact';
    public static final String REHAB_COMPLETE = 'Rehab Complete';
    public static final String ACCESS_LEVEL_EDIT = 'Edit';
    public static final String ACCESS_LEVEL_READ = 'Read';
    public static final String TIP = 'TIP';
    public static final String BID_TYPE_TRUSTEE = 'Trustee';
    public static final String BID_TYPE_BULK_SALE = 'Bulk Sale';
    public static final String NO_CONTACT_INTERNAL_ASSIGNMENT_IN_PROCESS = 'No Contact - Internal Assignment in Process';
    public static final String FURTHER_CONTACT_ABORTED_REFERRED_TO_EVICTION = 'Contact Aborted – Referred to Eviction';
    public static final String APPROVAL_REQUIRED_FIELD_FOR_PIPELINE = 'RequiredForApprovalSubmission';
    public static final String REQUIRED_FIELD_FOR_PROSPECT_CONVERSION = 'RequiredForProspectConversion';
    public static final String REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_TRUSTEE = 'RequiredForProspectConversionForTrustee';
    public static final String REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE = 'RequiredForProspectConversionForNonTrustee';
    public static final String REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE_AND_NON_BULKY = 'RequiredForProspectConversionForNonTrusteeAndNonBulky';
    public static final String APPROVAL_REQUIRED_FIELD_FOR_TRUSTEE_PIPELINE = 'RequiredForTrusteeApprovalSubmission';
    public static final String APPROVAL_REQUIRED_FIELD_FOR_NON_TRUSTEE_PIPELINE = 'RequiredForNonTrusteeApprovalSubmission';
    public static final String GROUP_DEVELOPER_NAME_ASSET_MANAGEMENT_TEAM = 'Asset_Management_Team';
    public static final String GROUP_DEVELOPER_NAME_REGIONAL_MANAGERS = 'Regional_Managers';
    public static final String ROLLOUT_UNALLOCATED = 'Unallocated';
    public static final String STATUS_ON = 'on';
    public static final String STATUS_OFF = 'off';
    public static final String SANDBOX = 'sandbox';
    public static final String PREFIX_LISTVIEW_BULK_DEAL = 'Bulk Deal - ';

    public static final String COLON = ':';
    public static final String SPACE = ' ';
    public static final String ERROR_FUTUE_DATE = 'You can not use future date. Please correct your data.';
    public static final String ERROR_Accquisation_field_When_DipoRb = 'There is an active Disposition Rehab exist with the property; FOR SALE is only valid selection';
    public static final String ERROR_ACQUISITION_FIELD_WHEN_DIPORB = 'There is an active Disposition Rehab exist with the property; FOR SALE is only valid selection';
    public static final String ERROR_Accquisation_field_When_No_DipoRb = 'There is no disposition rehab associated with disposition of this Portfolio record. Please check you data.';
    public static final String ERROR_ACQUISITION_FIELD_WHEN_NO_DIPORB = 'There is no disposition rehab associated with disposition of this Portfolio record. Please check you data.';
    public static final String ERROR_Accquisation_field_When_DispoRb_YRRStatus_notVacant ='This Property is not Vacant OR  RFL is not approved Yet;FOR SALE is Invalid Selection';
    public static final String ERROR_ACQUISITION_FIELD_WHEN_DISPORB_YRR_STATUS_NOT_VACANT ='This Property is not Vacant OR  RFL is not approved Yet;FOR SALE is Invalid Selection';
    public static final String ERROR_ACQUISITION_FIELD_WHEN_PORTFOLIO_SOLD = 'Acquisition Status can\'t be updated for \"Sold\" properties';
    public static final String OBJECT_APINAME_PROPERTY = 'Property__c';
    public static final String OBJECT_APINAME_PROSPECT = 'Prospect__c';
    public static final String OBJECT_APINAME_PROPERTY_OPPORTUNITY = 'Property_Opportunity__c';
    public static final String OBJECT_APINAME_AZB_UPDATE = 'AZB_Update__c';
    public static final String OBJECT_APINAME_RESIDENCE = 'Residence__c';

    public static final String OBJECT_APINAME_ISSUES_NEW_FEATURE_REQUEST = 'Issues_New_Feature_Request__c';

    public static final String STAGE_ACQUIRED = 'Acquired';
    public static final String RETURN_URL = 'retURL';

    public static final String CANCELLED = 'Cancelled';
    public static final String DEAD_CANCELLED = 'Dead - Cancelled';

    public static final String PIPELINE_STAGE_CANCELLED = 'Cancelled';
    public static final String REGION_N_CALIFORNIA = 'N. California';
    public static final String REGION_SACRAMENTO = 'Sacramento';

    public static final String REHAB_STAGE_HOLD_NOTIFICATION_CANCEL_UTILITY_TRANSFER = 'HOLD - Notification Revoked/Cancel Utility Transfer';
    public static final String REHAB_STAGE_MOVE_OUT_SCHEDULED = 'Move Out Scheduled';
    public static final String REHAB_STAGE_MOVE_OUT_ASSIGNED = 'Move Out Assigned';
    public static final String REHAB_STAGE_READY_TO_SCHEDULE_MOI_UTILITY_TRANSFER = 'Ready to Schedule MOI/Utility Transfer';
    public static final String REHAB_STAGE_NOTIFICATION_RECEIVED = 'Notification Received';
    public static final String REHAB_STAGE_CLOSED_COMPLETED = 'Closed - Completed';
    public static final String REHAB_STAGE_CLOSED_CANCELLED = 'Closed - Cancelled';

    public static final String LISTING_STATUS_DOWN_IN_REHAB = 'Down (In Rehab)';
    public static final String LISTING_STATUS_OTM_READY_TO_LIST = 'OTM - Ready To List';
    public static final String LISTING_STATUS_HOLD_CURRENTLY_NOT_LEASABLE = 'Hold - Currently Not Leasable';
    public static final String LISTING_STATUS_LEASED = 'Leased';

    public static final String RENEWAL_STATUS_LEASE_RENEWED = 'Lease Renewed';
    public static final String RENEWAL_STATUS_MONTH_TO_MONTH = 'Month-to-Month';
    
    //Added by Poonam Bhargava(10/14/2016)- D-00016239  
    //Variable for LeaseTriggerHelper   
    public static final String MTM_EXTENSION_REASON = 'Unknown';
    public static final String RENEWAL_STATUS_DAYS = '>120 Days Out';
    public static final String RENEWAL_STATUS_OPEN = 'Open';


    //Variables useful in Strike Iron Web Service Call
    public static final String NULLVALUE = '';
    public static final String CASING = 'UPPER';
    public static final String LICENSEKEY = '3EDBB8D4AFC82D3996EC';
    public static final String PASSWORD = 'sf#12345';

    //String to hold the Value for Mapping Name field of Custom Setting (Pipeline To Property Mapping)
    public static final String PIPELINE_TO_PROPERTY_CONVERSION = 'PipelineToPropertyConversion';
    public static final String PROSPECT_TO_PIPELINE_CONVERSION = 'ProspectToPipelineConversion';
    public static final String CONVERTED_TO_PIPELINE = 'Converted to Pipeline';

    //Variable to hold the custom setting name for SkipTriggersForUser
    public static final String SKIP_TRIGGERS_FOR_USER = 'SkipTriggersForUser';

    //Record Types Developer Name
    public static final String RECORD_TYPE_TASK_SYSTEM_ISSUE_REPORT = 'Task_System_Issue_Report';
    public static final String ZWS_ID = 'ZWS ID';

    //Variables for people finder
    public static Integer MAX_CHILDREN_PER_ROW = 10;
    public static Integer MAX_SIBLINGS_PER_ROW = MAX_CHILDREN_PER_ROW - 1;
    
    //Added by Poonam Bhargava - D-00017705
    public static final String APP_TRACK_FIELD = 'AppTrackReport2015Field';
    public static final String IHLEAD_SHOWING_FIELD = 'IHLeadswithShowingswithoutAppTrack';

    //Property Status Tag config
    public static Status_Tags__c STATUS_TAGS {
        get {

            //Get Status Tag configuration
            Status_Tags__c config = Status_Tags__c.getOrgDefaults();

            //Check if config is already defined or not
            if(config == null)
                config = new Status_Tags__c();

            //Return config
            return config;
        }
    }

    //View configuration
    public static View_Configuration__c VIEW_CONFIGURATION {
        get {

            //Get Status Tag configuration
            View_Configuration__c config = View_Configuration__c.getOrgDefaults();

            //Check if config is already defined or not
            if(config == null)
                config = new View_Configuration__c();

            //Return config
            return config;
        }
    }

    //View configuration
    public static SmartyStreets_Configuration__c SMARTY_STREETS_CONFIGURATION {
        get {

            //Get Status Tag configuration
            SmartyStreets_Configuration__c config = SmartyStreets_Configuration__c.getInstance();

            //Check if config is already defined or not
            if(config == null)
                config = new SmartyStreets_Configuration__c();

            //Return config
            return config;
        }
    }

    //This varibale is to create a static Map of custom Setting, so it is not being queried all the time
    //Key = Parameter Key, Value = List<Parameter Values>
    public static Map<String, List<Configuration_Manager__c>> MAP_CONFIGURATION_MANAGER {

        get {
            if(MAP_CONFIGURATION_MANAGER == null) {

                MAP_CONFIGURATION_MANAGER = new Map<String, List<Configuration_Manager__c>>();

                //Get all values from custom setting
                List<Configuration_Manager__c> configs = Configuration_Manager__c.getAll().values();
        
                //Loop through all the custom setting records
                for(Configuration_Manager__c config : configs) {
          
                    //check if Parameter Key is not null
                    if(config.Parameter_Key__c == null || config.Parameter_Key__c == ''
                        || config.Parameter_Value__c == null || config.Parameter_Value__c == '')
                        continue;

                    //Check if map already has Parameter Key
                    if(MAP_CONFIGURATION_MANAGER.containsKey(config.Parameter_Key__c))
                        MAP_CONFIGURATION_MANAGER.get(config.Parameter_Key__c).add(config);
                    else
                        MAP_CONFIGURATION_MANAGER.put(config.Parameter_Key__c, new List<Configuration_Manager__c>{config});
                }
            }
            return MAP_CONFIGURATION_MANAGER;
        }
    }

    /**
     *  @description    :   This method is to get the Custom Setting data based on Parameter Key.
     *
     *  @args           :   Parameter Key
     *
     *  @return         :   List<Configuration_Manager__c>
     *
     **/
    public static List<Configuration_Manager__c> getConfigManagerByParameterKey(String parameterKey) {

        //Create a list of Configuaration Manager
        List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();

        //Check if Map has this key
        if(Constants.MAP_CONFIGURATION_MANAGER.containsKey(parameterKey)) {

            //return all the related values
            configs = Constants.MAP_CONFIGURATION_MANAGER.get(parameterKey);
        }

        return configs;
    }

    /**
     *  @description    :   This method is to get the Custom Setting data based on Parameter Key and Value.
     *
     *  @args           :   Parameter Key, Parameter Value
     *
     *  @return         :   boolean
     *
     **/
    public static Boolean getConfigManagerByParameterKeyAndValue(String parameterKey, String parameterValue) {

        //Create a list of Configuaration Manager
        List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();

        //Check if Map has this key
        if(Constants.MAP_CONFIGURATION_MANAGER.containsKey(parameterKey)) {

            //return all the related values
            configs = Constants.MAP_CONFIGURATION_MANAGER.get(parameterKey);
        }

        //Loop through the configs and check if parameter value exists
        for(Configuration_Manager__c config : configs) {

            if(config.Parameter_Value__c != null && config.Parameter_Value__c.equalsIgnoreCase(parameterValue))
                return true;
        }
        return false;
    }

    //Variable to hold the Collabaration Group Id. This groups will be notified when the property is acquired
    public Static Id CHATTER_COLLABARATION_GROUP_FOR_ACQUIRED_PROPERTIES {
        get {

            //Loop through the Config recoeds
            List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey('ChatterGroupToBeNotified');

            //Check for the parameter value
        if(configs.size() != 0) {

              //get the chatter group Name
              String groupName = configs[0].Parameter_Value__c;

              //get the chatter group Name
              List<CollaborationGroup> groups = [Select Id from CollaborationGroup where Name =: groupName];

              //Check if group exists
              if(groups.size() > 0) {

                //Return Group Id
                return groups[0].Id;
              }
        }

        //return null value
        return null;
        }
    }

    //This variable to check if the triiger needs to be executed for the current context user
    public static Boolean EXECUTE_TRIGGER {
        get {

            //Check if the triggers need to be executed for current context user
            if(Constants.getConfigManagerByParameterKeyAndValue(Constants.SKIP_TRIGGERS_FOR_USER, UserInfo.getUserName())) {

                //Skip triggers as user is added in the list to skip the tiggers
                return false;
            }

            //Execute all the triggers
            return true;
        }
    }

    //This variable to get ZWS ID for current context user
    public static String ZILLOW_ZWS_ID {
        get {

            //Get ZWS id for current user
            User user = [Select ZWS_Id__c from User where Id =: UserInfo.getUserId()];

            //check for the counter
            if(user.ZWS_Id__c != null)
                return user.ZWS_Id__c;

            //Get ZWS_Id__c from configuration
            List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey(Constants.ZWS_ID);

            //Check for the size
            if(configs.size() > 0)
              return configs[0].Parameter_Value__c;

            //Execute all the triggers
            return null;
        }
    }

    //This varibale is to create a static Map of custom Setting, so it is not being queried all the time
    //Key = Parameter Key, Value = List<Parameter Values>
    public static Map<String, List<FutureDateProhibited__c>> MAP_FutureDateProhibited {

        get {
            if(MAP_FutureDateProhibited == null) {

                MAP_FutureDateProhibited = new Map<String, List<FutureDateProhibited__c>>();

                //Get all values from custom setting
                List<FutureDateProhibited__c> configs = FutureDateProhibited__c.getAll().values();

                //Loop through all the custom setting records
                for(FutureDateProhibited__c config : configs) {

                    //check if Parameter Key is not null
                    if(config.Parameter_Key__c == null || config.Parameter_Key__c == ''
                        || config.Field_API_Name__c == null || config.Field_API_Name__c == '')
                        continue;

                    //Check if map already has Parameter Key
                    if(MAP_FutureDateProhibited.containsKey(config.Parameter_Key__c))
                        MAP_FutureDateProhibited.get(config.Parameter_Key__c).add(config);
                    else
                        MAP_FutureDateProhibited.put(config.Parameter_Key__c, new List<FutureDateProhibited__c>{config});
                }
            }
            return MAP_FutureDateProhibited;
        }
    }

    /**
     *  @description    :   This method is to get the Custom Setting data based on Parameter Key.
     *
     *  @args           :   Parameter Key
     *
     *  @return         :   List<FutureDateProhibited__c>
     *
     **/
    public static List<FutureDateProhibited__c> getFutureDateProhibitedByParameterKey(String parameterKey) {

        //Create a list of FutureDateProhibited
        List<FutureDateProhibited__c> configs = new List<FutureDateProhibited__c>();

        //Check if Map has this key
        if(Constants.MAP_FutureDateProhibited.containsKey(parameterKey)) {

            //return all the related values
            configs = Constants.MAP_FutureDateProhibited.get(parameterKey);
        }

        return configs;
    }

    /**
     *  @description    :   This method is to get the Custom Setting data based on Parameter Key and Value.
     *
     *  @args           :   Parameter Key, Parameter Value
     *
     *  @return         :   boolean
     *
     **/
    public static Boolean getgetFutureDateProhibitedByParameterKeyAndValue(String parameterKey, String parameterValue) {

        //Create a list of Configuaration Manager
        List<FutureDateProhibited__c> configs = new List<FutureDateProhibited__c>();

        //Check if Map has this key
        if(Constants.MAP_FutureDateProhibited.containsKey(parameterKey)) {

            //return all the related values
            configs = Constants.MAP_FutureDateProhibited.get(parameterKey);
        }

        //Loop through the configs and check if parameter value exists
        for(FutureDateProhibited__c config : configs) {

            if(config.Field_API_Name__c != null && config.Field_API_Name__c.equalsIgnoreCase(parameterValue))
                return true;
        }
        return false;
    }


    //Variable to return Prospect fields not allowed to have future date with them
    public Static Set<String> PROPERTY_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE {

       get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //List of FutureDateProhibited
            List<FutureDateProhibited__c> configs = Constants.getFutureDateProhibitedByParameterKey('PropertyFieldNotAllowedForFutureDate');

            //Loop through the Custom setting record
            for(FutureDateProhibited__c prohibitedFieldRecord : configs) {

            //Check for the parameter value
            if(prohibitedFieldRecord.Field_API_Name__c != null)
                setFields.add(prohibitedFieldRecord.Field_API_Name__c.toLowerCase());
      }

         //Return the field set not allowed to have future date with them
         return setFields;
       }
    }

    //Variable to return Pipeline fields not allowed to have future date with them
    public Static Set<String> PIPELINE_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE {

       get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //List of FutureDateProhibited
            List<FutureDateProhibited__c> configs = Constants.getFutureDateProhibitedByParameterKey('PipelineFieldNotAllowedForFutureDate');

            //Loop through the Custom setting record
            for(FutureDateProhibited__c prohibitedFieldRecord : configs) {

            //Check for the parameter value
            if(prohibitedFieldRecord.Field_API_Name__c != null)
                setFields.add(prohibitedFieldRecord.Field_API_Name__c.toLowerCase());
      }

         //Return the field set not allowed to have future date with them
         return setFields;
       }
    }

    //Variable to return property fields not allowed to have future date with them
    public Static Set<String> PROSPECT_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE {

       get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //List of FutureDateProhibited
            List<FutureDateProhibited__c> configs = Constants.getFutureDateProhibitedByParameterKey('ProspectFieldNotAllowedForFutureDate');

            //Loop through the Custom setting record
            for(FutureDateProhibited__c prohibitedFieldRecord : configs) {

            //Check for the parameter value
            if(prohibitedFieldRecord.Field_API_Name__c != null)
                setFields.add(prohibitedFieldRecord.Field_API_Name__c.toLowerCase());
      }

         //Return the field set not allowed to have future date with them
         return setFields;
       }
    }

    //Variable to return Rehab fields not allowed to have future date with them
    public Static Set<String> REHAB_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE {

        get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //List of FutureDateProhibited
            List<FutureDateProhibited__c> configs = Constants.getFutureDateProhibitedByParameterKey('RehabFieldNotAllowedForFutureDate');

            //Loop through the Custom setting record
            for(FutureDateProhibited__c prohibitedFieldRecord : configs) {

                //Check for the parameter value
                if(prohibitedFieldRecord.Field_API_Name__c != null)
                    setFields.add(prohibitedFieldRecord.Field_API_Name__c.toLowerCase());
            }

            //Return the field set not allowed to have future date with them
            return setFields;
        }
    }

    //Variable to return TIP fields not allowed to have future date with them
    public Static Set<String> TIP_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE {

        get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //List of FutureDateProhibited
            List<FutureDateProhibited__c> configs = Constants.getFutureDateProhibitedByParameterKey('TIPFieldNotAllowedForFutureDate');

            //Loop through the Custom setting record
            for(FutureDateProhibited__c prohibitedFieldRecord : configs) {

                //Check for the parameter value
                if(prohibitedFieldRecord.Field_API_Name__c != null)
                    setFields.add(prohibitedFieldRecord.Field_API_Name__c.toLowerCase());
            }

            //Return the field set not allowed to have future date with them
            return setFields;
        }
    }

    //Migration Configuration (List Custom Setting)
    public static Map<String, Migration_Configuration__c> MIGRATION_CONFIGURATION_MAP {

        get {

            // Find all the Migration Configuration in the custom setting
            Map<String, Migration_Configuration__c> migrationConfigMap = Migration_Configuration__c.getAll();

            //return map
            return migrationConfigMap;
        }
    }

    //Set to hold the components strings for whom ObjectName. Prefix is required for migration using Package.xml file
    public static Set<String> SET_COMPONENTS_NAME_HAVING_OBJECT_NAME_PREFIX_AS_MEMBER {

        get {

            //Create a Set of fields
            Set<String> setFields = new Set<String>();

            //Populating set with the value
            setFields.add('CustomField');
            setFields.add('CustomObjectOwnerSharingRule');
            setFields.add('CustomObjectCriteriaBasedSharingRule');
            setFields.add('RecordType');
            setFields.add('WorkflowRule');
            setFields.add('WorkflowFieldUpdate');
            setFields.add('WorkflowTask');
            setFields.add('WorkflowAlert');
            setFields.add('WebLink');
            setFields.add('ValidationRule');
            setFields.add('AssignmentRule');
            setFields.add('AutoResponseRule');
            setFields.add('BusinessProcess');
            setFields.add('EscalationRule');
            setFields.add('ListView');
            setFields.add('FieldSet');
            setFields.add('WorkflowOutboundMessage');
            setFields.add('ApprovalProcess');

            //Return Set
            return setFields;
        }
    }

    //User deactivation objects
    public static List<String> USER_DEACTIVATION_OBJECTS {
        get {
            return Label.USER_DEACTIVATION_OBJECT.toLowerCase().trim().replaceAll(' ', '').split(',');
        }
    }

    public final static String LAYOUT = 'Layout';
    public final static String PACKAGEFILENAMESPACE = 'http://soap.sforce.com/2006/04/metadata';
    public final static String PACKAGE_STRING = 'Package';
    public final static String PACKAGE_PREFIX = 'ih';
    public final static String FULLNAME = 'fullName';
    public final static String INITIAL_TEXT = 'Migration test';
    public final static String TYPES = 'types';
    public final static String MEMBERS = 'members';
    public final static String NAME = 'name';
    public final static String VERSION = 'version';
    public final static String VERSION_NO = '27.0';
    public final static String ENTIRE_WORKFLOW = 'Workflow: Entire Workflow';
    public final static String INFO_MESSAGE = 'Please include actions related to workflow manually. Since user added Entire workflow as modification on SIR.';

    //Variables are going to be helpful in New Rehab Auto Complete Search Functionality
    public final static String REHAB_TURN = 'Rehab Turn';
    public final static String TURN = 'Turn';
    public final static String REMEDIATION_TURN = 'Remediation Turn';
    public final static String REMEDIATION = 'Remediation';
    public final static String POST_ACQUISITION = 'Post-Acquisition';
    public final static String POST_ACQUISITION_TIP = 'Post Acquisition – Purchased Rented';
    public final static String DISPOSITION = 'Disposition';
    public final static String NEW_REHAB_HAVE_BEEN_CREATED = 'Rehab has been created for Yardi Code: ';
    public final static String ADDRESS_STRING = ' Address: ';
    
    //Variable To be used in For Acquisition Staus Change Functionality 
    
    public final static String PORTFOLIO_ACQ_STATUS_SOLD = 'Sold';
    public final static String PORTFOLIO_ACQ_STATUS_FOR_SALE = 'For Sale';
    public final static String PORTFOLIO_ACQ_STATUS_FOR_SALE_OCCUPIED = 'For Sale Occupied';
    public final static String DISPOSITION_STRATEGY_RFL = 'RFL';
    public final static String DISPOSITION_STRATEGY_OTHER = 'Other';
    public final static String DISPOSITION_STRATEGY_ONLINE_PLATFORM = 'Online Platform';
    public final static String DISPOSITION_ON_HOLD =  'HOLD - Other';
    public final static String DISPOSITION_OK_TO_RENEW = 'Okay to Renew';
    public final static String DISPOSITION_VACANT = 'Vacant';
    public final static String DISPOSITION_NOTICE = 'Notice';
    public final static String DISPOSITION_TARGETED_BUYER_RESIDENT = 'Resident';
    public final static String DISPOSITION_PM_STRATEGY_NOT_RENEW = 'Not Renew';
    public final static String DISPOSITION_FUND_TWO = '02';
    public final static String RENEWAL_OPEN = 'Open'; 
    public final static String RENEWAL_SOLD = 'Property - Sold';
    public final static String DISPOSITION_STRATEGY_MLS = 'Broker/MLS';
    public final static String DISPOSITION_PM_STRATEGY_NON_RENEW = 'Non-Renew';
    public final static String DISPOSITION_UNDER_CONTRACT ='Under Contract';
    public final static String DISPOSITION_APPROVED_FORSALE = 'Approved For Sale';
    
    //Added by Poonam Bhargava(07/31/2017) - D-00017394
    //Varibale for IncomingCallHelper Class
    public final static String LEAD_STATUS_AS_CLOSED_DUPLICATE = 'Closed - Duplicate Lead';
    public final static String AGENT_LEAD_STATUS_AS_CLOSED_DUPLICATE = 'Closed Duplicate';
    public final static String LEAD_STATUS_AS_CLOSED_SENT_TO_AGENT = 'Closed - Sent to Agent';
    
    //Added by Poonam Bhargava
    //Sway Record Type of Prospect
    public final static String NEW_BUILD_RT = 'New_Build';
    
    //Added by Poonam Bhargava - (11/14/2017) - D-00017574
    public final static String YARDI_BATCH_SCHEDULER_NAME = 'Yardi Batch Scheduler Name';
    
    //Added by Poonam Bhargava - (11/16/2017) - D-00017577
    public final static String TO_ADDRESS_PI_EXCEPTION = 'To_Address_PI_Exception';
}