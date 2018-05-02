/**
 *  Description    :    This class is for all the utility methods.
 *
 *  Created By     :    Bhavi Sharma
 *
 *  Created Date   :    7/19/2012
 *
 * Revision Logs   :    V1.0 - Created
                        V1.1 - Modified for D-00000317 by Abhinav Sharma on 08/22/2012
                        V1.2 - Modified for D-00000574 by Abhinav Sharma on 08/28/2012
                        V1.3 - Modified for D-00001858 - Bhavi Sharma - 01/15/2013- Added a new method(getPipelineIdByProspectId)
                        V1.4 - Modified for D-00002737 - Bhavi Sharma - 02/26/2013- Added a new methods(addConfigurationManagerData, addConversionMappingData)
                        V1.5 - Modified for D-00005879 - Rajesh Shah  - 07/02/2013 - Added a new method - userBelongsToAssetManagerGroup
                        V1.6 - Modified for D-00007041 - Bhavi Sharma - 08/07/2013 - Added a new method - migrateAttachmentFromSourceToTarget
                        V1.7 - Modified for D-00007173 - Bhavi Sharma - 08/21/2013 - Added a new method - createLog
                        V1.8 - Modified for D-00008763 - Bhavi Sharma - 10/26/2013 - Modified migrateAttachmentFromSourceToTarget method
                                                                                        Commented out the portion which is migrating feed attachments from source to target
 *                      V1.9 - Modified for D-00008765 - Bhavi Sharma - 11/05/2013 - Modified migrateAttachmentFromSourceToTarget method
                                                                                        Eradicated the V_1.8 code
						V1.10 - Modified By Poonam Bharagav - (D-00017166)
 **/
global class Utility {

  //This method is to check wheather record is locked or not
  webservice static Boolean getLockingStatus(Id recordId) {

    //check for the record type null
    if(recordId != null) {
      //Get obejct record type
      Schema.SObjectType objectName = recordId.getSObjectType();
      Map<String, Schema.SObjectField> mapFields = objectName.getDescribe().fields.getMap(); //get a map of fields for the passed sobject

      //Chekc for the record type
      if(mapFields.containsKey('ispadlocked__c')) {

        //check for the status
        List<SObject> records = database.query('Select ispadlocked__c from ' + objectName + ' where Id =: recordId limit 1');

        //Chekc if the results
        if(records.size() > 0)
          return Boolean.valueOf(records[0].get('ispadlocked__c'));
      }
    }

    //else return false
    return false;
  }

    //This method is to get the view modspeaciale
    webservice static Boolean getListViewMode() {

        //Get configuration
        View_Configuration__c config = View_Configuration__c.getOrgDefaults();

        return config.View_My_Records__c;
    }

    //This method is to swith the view mode
    webservice static void switchListViewMode() {

        //Get configuration
        View_Configuration__c config = View_Configuration__c.getOrgDefaults();

        if(config.View_My_Records__c)
            config.View_My_Records__c = false;
        else
            config.View_My_Records__c = true;

        //Update database
        update config;
    }

    //This method is to run the Yardi Integration batch
    webservice static String runYardiIntigrationBatch() {
        try {
            //run batch for yardi intigration
            BatchGenerateYardiIntegrationCSV.runJob();
            return 'Batch is running.';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }

    //Populate Leased Signed Date @ First TEnant
    public static Date populateLeasedSignDateFirstTenant(Property__c property) {

        //Check for the fields
        if(property.TIP_Prior_Lease_Accepted_Date__c != null )
            return property.TIP_Prior_Lease_Accepted_Date__c;
        else if(property.TIP_New_Lease_Signed_Date__c != null)
            return property.TIP_New_Lease_Signed_Date__c;
        else
            return null;
    }

    //Method to find out the max value from a list
    public static Date getMax(List<Date> values) {

        //Check if list is not null
        if(values != null && values.size() > 0) {

            //Sort the list and
            values.sort();
            return values[values.size() - 1];
        }

        //return null
        return null;
    }

    //Method to returning HTMLEncoded String
    public static String replaceSpecialCharacters(String inputString) {

        if(inputString != null) {
            String replacingString = '-';

            inputString = inputString.replace('/', replacingString);
            inputString = inputString.replace('\\', replacingString);
            inputString = inputString.replace('"', replacingString);
            inputString = inputString.replace(':', replacingString);
            inputString = inputString.replace('<', replacingString);
            inputString = inputString.replace('>', replacingString);
            inputString = inputString.replace('|', replacingString);
            inputString = inputString.replace('*', replacingString);
            inputString = inputString.replace('?', replacingString);
            //inputString = inputString.replace('.', replacingString);

            inputString = inputString.replace('$', replacingString);
            inputString = inputString.replace('%', replacingString);
            inputString = inputString.replace('#', replacingString);

            //inputString = inputString.replace('&', replacingString);
            //return null
        }
        else {
            inputString = '';
        }
        return inputString;
    }

    //Method to grant automatic approvals
    public static void autoApprovalSubmission(List<Id> prospectIds) {

        //Auto Locking of Prospect through Auto Approval once converted to Pipeline
        List<Approval.ProcessSubmitRequest> listProcessSubmitResult = new List<Approval.ProcessSubmitRequest>();

        //Loop through list of Ids
        for(Id prospectId : prospectIds) {

            //Create an approval requests
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Automatic record lock.');
            req1.setObjectId(prospectId);

            //Populate List with Values
            listProcessSubmitResult.add(req1);

        }

        //Submit the approval requests
         approval.ProcessResult[] result = Approval.process(listProcessSubmitResult);
    }

    //Populate All_In_Cost_Est_UW__c
    public static Decimal populateAllInCostEst(Prospect__c prospect) {

        //return null if all other fields are already null
        if(prospect.Acquisition_Basis_Est_UW__c == null && prospect.Acquisition_Overhead__c == null
            && prospect.Rehab_Overhead__c == null && prospect.Title_Policy_Cost_Est_UW__c == null
            && prospect.Other_Closing_Costs_Est_UW__c == null && prospect.Platform_Buildup_Allocation__c == null
            && prospect.Initial_Lease_up_Cost_Est_UW__c == null && prospect.Bridge_Cost_during_Rehab_and_Lease_up__c == null
            && prospect.CFK_Est_UW__c == null) {

            return null;

        } else {

            //Set the deafult value
            return ((prospect.Acquisition_Basis_Est_UW__c == null)?0:prospect.Acquisition_Basis_Est_UW__c)
                                                + ((prospect.Acquisition_Overhead__c == null)?0:prospect.Acquisition_Overhead__c)
                                                + ((prospect.Rehab_Overhead__c == null)?0:prospect.Rehab_Overhead__c)
                                                + ((prospect.Title_Policy_Cost_Est_UW__c == null)?0:prospect.Title_Policy_Cost_Est_UW__c)
                                                + ((prospect.Other_Closing_Costs_Est_UW__c == null)?0:prospect.Other_Closing_Costs_Est_UW__c)
                                                + ((prospect.Platform_Buildup_Allocation__c == null)?0:prospect.Platform_Buildup_Allocation__c)
                                                + ((prospect.Initial_Lease_up_Cost_Est_UW__c == null)?0:prospect.Initial_Lease_up_Cost_Est_UW__c)
                                                + ((prospect.Bridge_Cost_during_Rehab_and_Lease_up__c == null)?0:prospect.Bridge_Cost_during_Rehab_and_Lease_up__c)
                                                + ((prospect.CFK_Est_UW__c == null)?0:prospect.CFK_Est_UW__c);
        }
    }

    //Populate All_In_Cost_Est_UW__c
    public static Decimal populateAllInCostEstForPipeline(Property_Opportunity__c pipeline) {

        //return null if all other fields are already null
        if(pipeline.Acquisition_Basis_Est_UW__c == null && pipeline.Acquisition_Overhead__c == null
            && pipeline.Rehab_Overhead__c == null && pipeline.Title_Policy_Cost_Est_UW__c == null
            && pipeline.Other_Closing_Costs_Est_UW__c == null && pipeline.Platform_Buildup_Allocation__c == null
            && pipeline.Initial_Lease_up_Cost_Est_UW__c == null && pipeline.Bridge_Cost_during_Rehab_and_Lease_up__c == null
            && pipeline.CFK_Est_UW__c == null) {

            return null;

        } else {

            //Set the deafult value
            return ((pipeline.Acquisition_Basis_Est_UW__c == null)?0:pipeline.Acquisition_Basis_Est_UW__c)
                                                + ((pipeline.Acquisition_Overhead__c == null)?0:pipeline.Acquisition_Overhead__c)
                                                + ((pipeline.Rehab_Overhead__c == null)?0:pipeline.Rehab_Overhead__c)
                                                + ((pipeline.Title_Policy_Cost_Est_UW__c == null)?0:pipeline.Title_Policy_Cost_Est_UW__c)
                                                + ((pipeline.Other_Closing_Costs_Est_UW__c == null)?0:pipeline.Other_Closing_Costs_Est_UW__c)
                                                + ((pipeline.Platform_Buildup_Allocation__c == null)?0:pipeline.Platform_Buildup_Allocation__c)
                                                + ((pipeline.Initial_Lease_up_Cost_Est_UW__c == null)?0:pipeline.Initial_Lease_up_Cost_Est_UW__c)
                                                + ((pipeline.Bridge_Cost_during_Rehab_and_Lease_up__c == null)?0:pipeline.Bridge_Cost_during_Rehab_and_Lease_up__c)
                                                + ((pipeline.CFK_Est_UW__c == null)?0:pipeline.CFK_Est_UW__c);
        }
    }

    //This method is to create Bidding Statistics records for Missing days
    public static List<Bidding_Statistics__c> createBiddingStatisticsForMissingDays(Date startDate, Date endDate, String region) {

        //List of Acquisition Reporting records
        List<Bidding_Statistics__c> listBiddStatRecords = new List<Bidding_Statistics__c>();

        System.debug(':::::' + startDate.daysBetween(endDate));
        Integer daysBetween = startDate.daysBetween(endDate);
        //Loop through the missing days
        for(Integer i = 1; i < daysBetween; i++) {

            //Start Date
            startDate = startDate.addDays(1);

            System.debug('startDate:::::' + startDate);

            //check for the weekend
            String day = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('EEEE');
            System.debug('day:::::' + day);

            //Check if day is saturday or sunday
            if(!day.equalsIgnoreCase('saturday') && !day.equalsIgnoreCase('sunday')) {

                //Add record in list and mark it as completed
                listBiddStatRecords.add(new Bidding_Statistics__c(Date__c = startDate, Region__c = region,
                                                                    Daily_Acq_Report_Complete_By__c = UserInfo.getUserId(),
                                                                    Daily_Acq_Report_Complete_Date__c = Date.today(),
                                                                    Daily_Asset_Report_Completed_By__c = UserInfo.getUserId(),
                                                                    Daily_Asset_Report_Completed_Date__c = Date.today()));
            }
        }

        //return all bidding statistics records to be inserted
        return listBiddStatRecords;
    }

    //This method is to attach the pipeline records with appropriate bidding stat record
    public static void populateTotalNoHomes(Set<Date> setAcquisitionDates, Set<String> setRegions) {

        //Map to hold string and Bidding Statistics
        Map<String, Bidding_Statistics__c> mapKeyWithBiddingStats = new Map<String, Bidding_Statistics__c>();

        //Loop through Bidding Stats
        for(Bidding_Statistics__c bidding : [SELECT ID, Name, Date__c, Region__c FROM Bidding_Statistics__c WHERE Date__c IN : setAcquisitionDates
                                                                                                                    AND Date__c != null
                                                                                                                    AND Region__c IN : setRegions
                                                                                                                    AND Region__c != null]) {

            //Formation of Key
            String key = String.valueOf(bidding.Date__c) + '-' + String.valueOf(bidding.Region__c);

            //Populate Map with values
            mapKeyWithBiddingStats.put(key, bidding);
        }

        System.debug('##### Value in Map Before'+ mapKeyWithBiddingStats);

        //Create a list of Bidding Stats to be updated
        List<Bidding_Statistics__c> biddingStatsToBeUpdated = new List<Bidding_Statistics__c>();


        //Count of Pipeline associated with Bidding Statistics
        for(AggregateResult agg : [Select Acquisition_Date__c acqDate, Region__c reg, count(Id) cnt
                                       FROM Property_Opportunity__c
                                       Where Acquisition_Date__c IN : setAcquisitionDates
                                       AND Acquisition_Date__c != null
                                       AND Region__c IN : setRegions
                                       AND Region__c != null
                                       AND Bid_Type__c = 'Trustee'
                                       AND Stage__c Not IN ('Cancelled' , 'Dead - Cancelled', 'Dead  - Duplicate', 'Dead - Bid Lost')
                                       GROUP BY Acquisition_Date__c, Region__c]) {


            //Formation of String
            String key = String.valueOf(agg.get('acqDate')) + '-' + String.valueOf(agg.get('reg'));
            key = key.replace(' 00:00:00', '');

            System.debug('Value of Key After' + key);

            //Get the value of count
            Integer count = Integer.valueOf(agg.get('cnt'));

            //Getting Value from the Map on the basis of key
            if(mapKeyWithBiddingStats.containsKey(key)) {

                System.debug('Please Enter in the loop');

                //Getting the Bidding Stats
                Bidding_Statistics__c bid = mapKeyWithBiddingStats.get(key);

                //Populate field with Value
                bid.Total_of_Homes_Won__c = count;

                //Populate List with Bidding Stats
                biddingStatsToBeUpdated.add(bid);

                //Remove Key from the Map
                mapKeyWithBiddingStats.remove(key);
            }
        }
        System.debug('##### Value in Map After'+ mapKeyWithBiddingStats);

        //Loop through remaining Bidding Stats having no pipelines
        for(Bidding_Statistics__c bS : mapKeyWithBiddingStats.values()) {

            //Add record in list to be updated
            biddingStatsToBeUpdated.add(new Bidding_Statistics__c(Id = bs.Id, Total_of_Homes_Won__c = 0));
        }

        //Check if there are records to process
        if(biddingStatsToBeUpdated.size() > 0) {

            Bidding_StatisticsTriggerHelper.ISEXECUTED = true;

            //Update bCRs
            update biddingStatsToBeUpdated;
        }
    }

    //This method id to return the Pipeline Id for a Prospect record
    webservice static String getPipelineIdByProspectId(String prospectId) {

        //Check if prospectId is not null
        if(prospectId != null) {

            //Get all the Pipeline records associated with the Prospect Id
            List<Property_Opportunity__c> pipeline = [Select Id from Property_Opportunity__c where Prospect__c =: prospectId limit 1];

            //Check for the size
            if(pipeline.size() > 0)
                return pipeline[0].Id;
        }

        //return null
        return null;
    }

    //This method is to return the Pipeline keycode
    webservice static String getObjectKeyCode(String objectName) {

        //Check if objectName is not null
        if(objectName != null) {

            //Get the Schema sObjetc Type
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);

            //Check for the Schema type
            if(targetType != null)
                return targetType.getDescribe().getKeyPrefix();
        }

        //return null
        return null;
    }

    //Method to Populate Apn Unique field corresponding to the values for Bid Type and APN fields
    public static String getApnUnique(String bidType, String apn){

        //Check for Bid Type field value for 'Trustee'
        if(bidType == 'Trustee') {
            return (bidType == null || apn == null) ? null : (bidType + '-' + removeExceptAlphaNumeric(apn.deleteWhitespace()));
        }

        //For Bid Type other than 'Trustee'
        else {
            return (bidType == null || apn == null) ? null : (removeExceptAlphaNumeric(apn.deleteWhitespace()));
        }
    }

    /**
      * Description :   This method is to remove non alpha numeric from a string
      * @args       :   inputString to be converted into alphanumeric - String
      * @return     :   alphanumeric String
     **/
    //Method to process APN field values
    public static String removeExceptAlphaNumeric(String inputString){
        String alphaNumericString = '';
        if(inputString != null) {
            inputString = inputString.deleteWhitespace();
            for(Integer i = 0 ; i < inputString.length() ; i++){
                alphaNumericString = alphaNumericString +
                                  (inputString.subString(i, i + 1).isAlphanumeric() ? inputString.subString(i, i + 1) : '');
            }
        }
        return alphaNumericString;
    }

    /**
      * Description :   This method is to add data in Configuation Manager custom setting
      * @args       :   Set of Data. Data will be in form of Parameter Key-Parameter Value
      * @return     :   void
     **/
    public static void addConfigurationManagerData(Set<String> dataSet) {

        //Check if dataset is not null and have records
        if(dataSet != null && dataSet.size() > 0) {

            //Create a list a custom setting to be created
            List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();

            //Get Max key Number
            Integer lastKeyNumber = getMaxKeyNameByCustomSettingName('Configuration_Manager__c');

            System.debug('lastKeyNumber:::::' + lastKeyNumber);

            //Loop through the data set
            for(String recordData : dataSet) {

                //Split data based in hyphen
                //First value is Parameter Key and Second is Parameter Value
                List<String> dataPair = recordData.split('-');

                //Check for tga data pair size and create teh Custom setting data
                if(dataPair.size() == 2) {

                    //Increase the key counter
                    lastKeyNumber += 1;

                    System.debug('lastKeyNumber:::::' + lastKeyNumber);

                    configs.add(new Configuration_Manager__c(Name = String.valueOf(lastKeyNumber), Parameter_Key__c = dataPair[0], Parameter_Value__c = dataPair[1]));
                }
            }

            //Check if there are records to insert in custom setting
            if(configs.size() > 0)
                insert configs;
        }
    }

    /**
      * Description :   This method is to add data in Configuation Manager custom setting
      * @args       :   Set of Data. Data will be in form of Parameter Key-Parameter Value
      * @return     :   void
     **/
    public static void addConversionMappingData(Set<String> dataSet) {

        //Check if dataset is not null and have records
        if(dataSet != null && dataSet.size() > 0) {

            //Create a list a custom setting to be created
            List<Property_Conversion_Maching_For_Approval__c> mappings = new List<Property_Conversion_Maching_For_Approval__c>();

            //Get Max key Number
            Integer lastKeyNumber = getMaxKeyNameByCustomSettingName('Property_Conversion_Maching_For_Approval__c');

            System.debug('lastKeyNumber:::::' + lastKeyNumber);

            //Loop through the data set
            for(String recordData : dataSet) {

                //Split data based in hyphen
                //First value is Mapping Name and Second is Source API Name and last will be target API Name
                List<String> dataPair = recordData.split('-');

                //Check for tga data pair size and create teh Custom setting data
                if(dataPair.size() == 3) {

                    //Increase the key counter
                    lastKeyNumber += 1;

                    //Add mapping data in list
                    mappings.add(new Property_Conversion_Maching_For_Approval__c(Name = String.valueOf(lastKeyNumber), Mapping_Name__c = dataPair[0],
                                                                                    Source_API_Name__c = dataPair[1], Target_API_Name__c = dataPair[2]));
                }
            }

            //Check if there are records to insert in custom setting
            if(mappings.size() > 0)
                insert mappings;
        }
    }

    /**
      * Description :   This method is to add data in Configuation Manager custom setting
      * @args       :   Set of Data. Data will be in form of Parameter Key-Parameter Value
      * @return     :   void
     **/
    public static Integer getMaxKeyNameByCustomSettingName(String customSettingAPIName) {

        //Check if customSettingAPIName is not null
        if(customSettingAPIName != null && customSettingAPIName != '') {

            List<SObject> records = database.query('Select name from ' + customSettingAPIName + ' where name like \'1%\' order by name desc limit 1');

            //Check for the records size
            if(records.size() > 0) {

                //get the Name and convert it into string
                String lastKey = String.valueOf(records[0].get('name'));

                //Check if lastkey is a number
                if(lastKey.isNumeric()) {

                    //return the number
                    return Integer.valueOf(lastKey);
                } else {

                    //Return zero as default
                    return 0;
                }
            }  else {

                //Return zero as default
                return 0;
            }
        }  else {

            //Return zero as default
            return 0;
        }
    }

    // Select * implementation for Force.com
    // Usage: List<Account myAcct = CloneHelper.selectStar( '001C000000mxREz');
    public static List<SObject> selectStar( List<Id> objIds ) {

        //List to hold the sObjects
        List<SObject> results = new List<SObject>();

        // Make sure some wise guy didn't pass in an empty set
        if ( objIds == null || objIds.size() == 0 ) {
            return results;
        }

        // Figure out what the first Id's prefix is
        String firstId = (String)objIds[0];
        String idPrefix = firstId.substring( 0, 3);
        System.debug( 'The idPrefix is ' + idPrefix);

        Boolean isPortfolioRec = isPortfolio(firstId);

        //Variable to hold the sObject information's
        String sObjName;
        Schema.SObjectType sObjType;

        // Search through all SObjects
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();

        //Loop through Map sObject API Name keySet
        for (String s : gdMap.keySet()) {

            //Getting sObject Key Prefix on the basis of Name
            String objPrefix = gdMap.get(s).getDescribe().getKeyPrefix();

            //Check for null
            if (objPrefix != null && objPrefix.equals(idPrefix)) {

                //Getting sObject Type
                sObjType = gdMap.get(s);

                //Getting sObject Name
                sObjName = sObjType.getDescribe().getName();
                break;
            }
        }
        // Get all the fields and build the SOQL
        String soql = 'select ';

        //Getting Map<String,Schema.SObjectField> for sObject
        Map<String, Schema.SObjectField> sObjectFieldsMap = sObjType.getDescribe().fields.getMap();

        Boolean ignoreFormulaFields = false;
        Integer fieldSize = 400;
        if(fieldSize < sObjectFieldsMap.size())
            ignoreFormulaFields = true;

        System.debug('Ingore Formula Fields : ' + ignoreFormulaFields);
        //Loop through sObject field names
        for (String fieldName : sObjectFieldsMap.keySet()) {

            //Getting field describe results
            if( sObjectFieldsMap.get(fieldName).getDescribe().getType() != Schema.DisplayType.LOCATION) {
                if(!ignoreFormulaFields || !sObjectFieldsMap.get(fieldName).getDescribe().isCalculated())
                    soql += fieldName + ',';
            }
            /*if(sObjectFieldsMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.LOCATION) {
                soql += 'location__latitude__s,';
            }
            else
                soql += fieldName + ',';*/
        }
        soql = soql.substring( 0, soql.length()-1);  //Remove the last comma
        soql += ' from ' + sObjName;
        soql += ' where id in :objIds';
        System.debug( 'Soql query is ' + soql);
        System.debug( 'Size soql ' + soql.length());
        return Database.query( soql);
    }

    // Just one id and just one object
    // Usage: Account myAcct = CloneHelper.selectStar( '001C000000mxREz');
    public static SObject selectStar( ID theId) {
        return selectStar( new List<Id> { theId})[0];
    }
    //Method converts the GMT date in user's local TimeZone from GMT
    public Static Date getLocalDate(Date inputDate){

            Date myDate;
            if(inputDate != null) {
                Integer day = inputDate.day();
                Integer month = inputDate.month();
                Integer year = inputDate.year();

                String timeZone = [Select timeZoneSidKey from User where id =: userinfo.getUserId()].timeZoneSidKey;
                //create datetime instance in GMT
                Datetime dateGMT = Datetime.newInstanceGmt(year, month, day, 0, 0, 0 );

                //Format the GMT date time to the local according to user's TimeZone
                String formatteddate = dateGMT.format('yyyy-MM-dd HH:mm:ss', timeZone);
                Datetime dateLocal = Datetime.valueOfGmt(formatteddate);
                //convert datetime in date
                myDate = date.newinstance(dateLocal.year(), dateLocal.month(), dateLocal.day());
            }

            return myDate;
    }

    //method to check if values has changed in insert/update trigger
    public static Boolean hasFieldChanged(SObject sObjNew, MAP<Id, SObject> sObjMapOld, String fieldAPIName) {

        if(trigger.isInsert) {
            return true;
        }
        else if(trigger.isUpdate){
            return (sObjNew.get(fieldAPIName) != sObjMapOld.get(sObjNew.id).get(fieldAPIName));
        }

        return false;
    }

    /*
       Method to insert a salesforce record id in appropriate reference field
       if more than one same type of reference then first field in field map will be populated
       @parameters
          sObjectId - Is the salesforce record id which will be populated in reference field
          sObj      - Is the record which will be populated with the value
    */
    public static SObject insertSObjectId(String sObjectId, SOBject sObj){
         //get global describe
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         //get SObject describe
         Schema.SObjectType targetObjectType = gd.get(String.valueOf(sObj.getSObjectType()));
         //get field map for the SOBject passed in parameter
         Map<String, Schema.SObjectField> fieldMap = targetObjectType.getDescribe().fields.getMap();

         for(String fieldName : fieldMap.keySet()){

             Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
             //if reference type field
             if(fieldDescribe.getType() == Schema.DisplayType.Reference) {
                 //find the related Sobject
                 List<Schema.sObjectType> referObject = fieldDescribe.getReferenceTo();
                 for(Schema.sObjectType s : referObject ){
                     //if it matches then put id in that field
                     if(String.valueOf(s.getDescribe().getKeyPrefix()) == sObjectId.substring(0,3)){
                         sObj.put(fieldName, sObjectId);
                         //return sObject
                         return sObj;
                     }
                 }
             }
         }
         return sObj;
    }

    //method to return blank string if value is null
    public static Object getBlankStringIfValueNull(Object objVal) {
      //if value is null
      if(objVal == null) {
        return '';
      }
        else {
          return objVal;
        }
    }

    //Method to get the map of RecordTypeId with respect to RecordType Name on the basis of profiles for sObjects
    public static Map<Id,String> GetAvailableRecordTypesForSObject(Schema.SObjectType objType) {

        //Map to hold the record types
        Map<Id, String> mapRecordTypeIdWithName = new Map<Id,String>();

        //List to hold the record type information
        List<RecordTypeInfo> listRecordTypeInfo = objType.getDescribe().getRecordTypeInfos();

        //If there are 2 or more RecordTypes...
        if(listRecordTypeInfo.size() > 1) {

            //Loop through list of record Types info
            for (RecordTypeInfo i : listRecordTypeInfo) {

               //Check for avalability
               if (i.isAvailable()

               // Ignore the Master Record Type, whose Id always ends with 'AAA'. We check the Id because Name can be changes.
               && !String.valueOf(i.getRecordTypeId()).endsWith('AAA')) {

                    //Populating map with values
                    mapRecordTypeIdWithName.put(i.getRecordTypeId(), i.getName());

                    //Debugging for values
                    System.debug('####### Record Type Map:' + mapRecordTypeIdWithName );
                }
            }
        }

        // Otherwise there's just the Master record type, so add it in, since it MUST always be available.
        else {

             //Populate map ith values
             mapRecordTypeIdWithName .put(listRecordTypeInfo[0].getRecordTypeId(), listRecordTypeInfo[0].getName());
        }

        //Return Map of RecordTypeIdWithName
        return mapRecordTypeIdWithName;
    }

    // Returns the Page parameter if present.
    public static String getPageParameter(String param) {
      if (ApexPages.currentPage().getParameters().containsKey(param)) {
        return escapeSingleQuotes(ApexPages.CurrentPage().getParameters().get(param));  //.replace('%2F', '')
      }
      return null;
    }

    public static String escapeSingleQuotes(String param) {
    String stringToReturn;
      if (param != null) stringToReturn = String.escapeSingleQuotes(param);
      return stringToReturn;
    }

    //Method to get the current user region value
    public Static String currentLoggedInUserRegionValue(Id userID) {

        List<User> myUser = new List<User>();
        String userRegion = '';

        myUser = [Select Id, Region__c from User where IsActive = true AND ID =:userID LIMIT 1];

        if(myUser.size() > 0) {
            userRegion = myUser[0].Region__c;
        }

        //Return value
        return userRegion;
    }

    //Method to return the State ID value corresponding to the State Name
    public Static ID retrieveIdOnTheBasisOfStateName(String stateName) {

        //Variable to hold the state Id
        Id stateIdValue;

        //List of state
        List<State__c> states = new List<State__c>();

        //Removal of special charector
        stateName = Utility.removeExceptAlphaNumeric(stateName);

        try {

            //Check for null
            if(stateName != null || stateName != '') {

                //Populating list with values
                states = [SELECT ID, Name FROM State__c WHERE Name =: stateName LIMIT 1];
            }

            //Check for state list for size
            if(states.size() > 0)
                stateIdValue = states[0].ID;

            //return value
            return stateIdValue;

        } catch(exception ex) {

            //Throw Error and add message on page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.STATE_NOT_FOUND));

            //Return value
            return null;
        }
    }

    //Method to get the State Name on the basis of State ID
    public Static String retrieveStateNameOnTheBasisOfID(ID stateIdValue) {

        //String to hold the state Name
        String stateNameValue;

        try {

            //Check for null value
            if(stateIdValue != null || stateIdValue != '') {

                //Populating String with values
                stateNameValue = [SELECT ID, Name FROM State__c WHERE ID =: stateIdValue LIMIT 1].Name;
            }

            //Return State Name Value
            return stateNameValue;

        } catch(exception ex) {

            //Throw Error and add message on page
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.STATE_NOT_FOUND));

            //Return Null
            return null;
        }
    }

    //This method is to create a list view for Bulk Deal
    public static String packageDotXMLForListView(String objectName, String bulkDealNumber) {


        //Package.xml file
        return '<?xml version="1.0" encoding="UTF-8"?>'
                                + '<Package xmlns="http://soap.sforce.com/2006/04/metadata">'
                                    + '<types>'
                                        + '<members>Prospect__c.' + bulkDealNumber + '</members>'
                                        + '<members>Property_Opportunity__c.' + bulkDealNumber + '</members>'
                                        + '<members>Property__c.' + bulkDealNumber + '</members>'
                                        + '<name>ListView</name>'
                                    + '</types>'
                                    + '<version>25.0</version>'
                                + '</Package>';
    }

    //This method is to create a list view for Bulk Deal
    public static String metaDataXMLForProspectListView(String bulkDealName, String bulkDealNumber, String bulkDealNameString) {

        //Metadata file
        return '<?xml version="1.0" encoding="UTF-8"?>'
                                + '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">'
                                    + '<listViews>'
                                        + '<fullName>' + bulkDealNumber + '</fullName>'
                                        + '<columns>Property_Street__c</columns>'
                                        + '<columns>Property_City__c</columns>'
                                        + '<columns>Property_Zip_Code__c</columns>'
                                        + '<columns>APN__c</columns>'
                                        + '<columns>Bulk_Deal__c</columns>'
                                        + '<columns>Bid_Type__c</columns>'
                                        + '<columns>Prospect_Status__c</columns>'
                                        + '<columns>Region__c</columns>'
                                        + '<columns>Property_Type__c</columns>'
                                        + '<columns>Bedrooms__c</columns>'
                                        + '<columns>Baths__c</columns>'
                                        + '<columns>Contract_Price__c</columns>'
                                        + '<columns>HOA_Options__c</columns>'
                                        + '<columns>Escrow_Opened_Date__c</columns>'
                                        + '<columns>Escrow_Expected_Close_Date__c</columns>'
                                        + '<filterScope>Everything</filterScope>'
                                        + '<filters>'
                                            + '<field>Bulk_Deal__c</field>'
                                            + '<operation>equals</operation>'
                                            + '<value>' + bulkDealNameString + '</value>'
                                        + '</filters>'
                                        + '<filters>'
                                            + ' <field>RECORDTYPE</field>'
                                            + '<operation>equals</operation>'
                                            + '<value>Prospect__c.Bulk</value>'
                                        + '</filters>'
                                        + '<label>' + bulkDealName + '</label>'
                                        + '<sharedTo>'
                                            + '<allInternalUsers></allInternalUsers>'
                                        + '</sharedTo>'
                                    + '</listViews>'
                                + '</CustomObject>';
    }

    //This method is to create a list view for Bulk Deal
    public static String metaDataXMLForPipelineListView(String bulkDealName, String bulkDealNumber, String bulkDealNameString) {

        //Metadata file
        return '<?xml version="1.0" encoding="UTF-8"?>'
                                + '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">'
                                    + '<listViews>'
                                        + '<fullName>' + bulkDealNumber + '</fullName>'
                                        + '<columns>NAME</columns>'
                                        + '<columns>Region__c</columns>'
                                        + '<columns>Stage__c</columns>'
                                        + '<columns>Market_Value_UW__c</columns>'
                                        + '<columns>Exp_Gross_Monthly_Rent_UW__c</columns>'
                                        + '<columns>Previous_High_Value__c</columns>'
                                        + '<columns>Acquisition_Date__c</columns>'
                                        + '<filterScope>Everything</filterScope>'
                                        + '<filters>'
                                            + '<field>Bulk_Deal__c</field>'
                                            + '<operation>equals</operation>'
                                            + '<value>' + bulkDealNameString + '</value>'
                                        + '</filters>'
                                        + '<filters>'
                                            + ' <field>RECORDTYPE</field>'
                                            + '<operation>equals</operation>'
                                            + '<value>Property_Opportunity__c.Bulk</value>'
                                        + '</filters>'
                                        + '<label>' + bulkDealName + '</label>'
                                        + '<sharedTo>'
                                            + '<allInternalUsers></allInternalUsers>'
                                        + '</sharedTo>'
                                    + '</listViews>'
                                + '</CustomObject>';
    }

    //This method is to create a list view for Bulk Deal
    public static String metaDataXMLForPortfolioListView(String bulkDealName, String bulkDealNumber, String bulkDealNameString) {

        //Metadata file
        return '<?xml version="1.0" encoding="UTF-8"?>'
                                + '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">'
                                    + '<listViews>'
                                        + '<fullName>' + bulkDealNumber + '</fullName>'
                                        + '<columns>NAME</columns>'
                                        + '<columns>Region__c</columns>'
                                        + '<columns>Property_Code__c</columns>'
                                        + '<columns>Acquisition_Status__c</columns>'
                                        + '<columns>Acquisition_Date__c</columns>'
                                        + '<columns>Property_Status__c</columns>'
                                        + '<columns>Occupied_Status_Acquisition__c</columns>'
                                        + '<filterScope>Everything</filterScope>'
                                        + '<filters>'
                                            + '<field>Bulk_Deal__c</field>'
                                            + '<operation>equals</operation>'
                                            + '<value>' + bulkDealNameString + '</value>'
                                        + '</filters>'
                                        + '<label>' + bulkDealName + '</label>'
                                        + '<sharedTo>'
                                            + '<allInternalUsers></allInternalUsers>'
                                        + '</sharedTo>'
                                    + '</listViews>'
                                + '</CustomObject>';
    }

    // Check if the user belongs to the Asset Manager group or not.
    // Asset Manager Group : IT Support, System Administrator, and Invitation Asset Management
    public static Boolean userBelongsToAssetManagerGroup() {

        Set<String> setAllowedProfiles = new Set<String>();

        //configuration Manager
        List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey('Portfolio Residence Lock Disabled Profile');

        //fill set from custom settings
        for(Configuration_Manager__c config : configs) {

            if(config.Parameter_Value__c != null) {
                setAllowedProfiles.add(config.Parameter_Value__c.trim().toLowerCase());
            }
        }
        //get profile name for urrent user
        String profileName = [Select Name From Profile Where id =: Userinfo.getProfileId()].Name;

        if(setAllowedProfiles.Contains(profileName.toLowerCase()))
            return true;
        return false;
    }

    public static String PORTFOLIO_KEYPREFIX = Schema.SObjectType.Property__c.getKeyPrefix();

    // Function to determine if the given Id belongs to a Portfolio record or not.
    public static Boolean isPortfolio(String id) {
        return (id != null && id.startsWith(PORTFOLIO_KEYPREFIX)) ? true : false;
    }

    /**
     *  description :   This method is to clone the attachments from source object and attach them to target object.
     *
     *  arguments   :   Map<Id, Id> Key => Source record Id and Value => Target record Id
     *
     *  return      :   void
    **/
    public static void migrateAttachmentFromSourceToTarget(Map<Id, Id> mapSourceWithTarget) {

        //Null Check
        if(mapSourceWithTarget != null && mapSourceWithTarget.size() > 0) {

            //Create a list of Attachments to be created
            List<Attachment> attachments = new List<Attachment>();

            //Query Source object to get all the related attachments
            for(Attachment attach : [Select Id, Body, ContentType, Description, Division, IsPrivate, ParentId, Name, OwnerId from Attachment where ParentId IN: mapSourceWithTarget.keySet()]) {

                //Check if related target record id from mapSourceWithTarget
                Id targetRecordId = mapSourceWithTarget.get(attach.ParentId);

                //Create a new Clone for attachment and attach it on Target record
                Attachment cloneAttachment = attach.clone(false);
                cloneAttachment.ParentId = targetRecordId;

                //Add this in list of attachments to be created
                attachments.add(cloneAttachment);
            }

            //insert attachments
            if(attachments.size() > 0)
                database.insert(attachments, false);
        }
    }

    /**
     *  Description :   Method for create log of DML upsert opertion. This method called with 1 argument which is given from any class that is :
     *
     *      1.  Database.SaveResult[] results   :   Its a Database DML Update or Insert result operation
     *
     *  Example:
     *              if(listTobeUpsert.size() > 0) {
     *
     *                  Database.SaveResult[] results = Database.insert(listTobeDeleted); OR Database.SaveResult[] results = Database.update(listToBeUpdated);
     *                  String errorLog = '';
     *                  errorLog = Utility.createLog(results);
     *              }
     *
     **/
    public Static String createLog(Database.SaveResult[] results) {

        //String to hold Log message
        String errorLog = '';

        //Iterate through each returned result
        for(Database.SaveResult result : results) {

            //Check for success
            if (!result.isSuccess()) {

                //call errorHTMLLog for getting Errors in HTML format
                errorLog = errorHTMLLog(result.getErrors());
            }
        }

        //return logmessage
        return errorLog;
    }

    /**
     *  Description :   Method for create log of DML opertion errors in HTML format. This method called with 1 argument
     *                  which is given from Utility class that is :
     *
     *      1.  Database.Error [] errors    :   Its a Database DML result's getErrors
     *
     *  Example: Utility.errorHTMLLog(result.getErrors());
     *
     **/
    public Static String errorHTMLLog(Database.Error [] errors) {

        //String to hold Log message
        String errorHTMLLogs = '';

        //Operation failed, so get all errors
        for(Database.Error err : errors) {

            //create log message
            errorHTMLLogs += '<tr><td>' + err.getStatusCode() + '</td><td>' + err.getMessage() + '</td></tr>';
        }

        //Check if error log is not null
        if(errorHTMLLogs != '')
            errorHTMLLogs = '<table border="1"><tr><th>StatusCode</th><th>Message</th></tr>' + errorHTMLLogs + '</table>';

        //return logmessage
        return errorHTMLLogs;
    }

    //get Batch processed logs in finish method of Batch and send status email
    /**
     *  This method called with 3 arguments which are given from Batch class these are :
     *
     *      1.  Id batchJobId       :   finish method have Database.BatchableContext(bCtx) as argument this instance give batch Id by
     *                                  bCtx.getJobId().
     *
     *      2.  String batchName    :   It is Batch class name.
     *
     *      3.  String errors       :   Its error log message on faliure of DML operations.
     *
     *  Example:    global class Batch_Example implements Database.Batchable<sObject>, Database.Stateful {
     *                  .
     *                  .
     *                  //finish method
     *                  global void finish(Database.BatchableContext ctx) {
     *
     *                      Utility.sendBatchStatus(ctx.getJobId(), 'Batch_Example', errors);
     *                  }
     *              }
     *
     **/
    public Static void sendBatchStatus(Id batchJobId, String batchName, String errors) {

        //Query the asynchronous jobs results
        AsyncApexJob aSyncJob = [SELECT Id, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedBy.Email FROM AsyncApexJob
                            WHERE id = :batchJobId];

        // Send email indicating the completion of this batch
        String emailMessage = 'Your batch job \"' + batchName + '\" has finished.  It processed job items'
                    + aSyncJob.totalJobItems +
                    ' batches.  Of which, '
                    + aSyncJob.JobItemsProcessed
                    + ' processed without any exceptions thrown and '
                    + aSyncJob.numberOfErrors
                    + ' batches threw unhandled exceptions.' + '<br>' + errors;

            //Send batch status to the person who executed this batch
        Utility.sendEmail(aSyncJob.CreatedBy.Email, batchName + ' has been completed', emailMessage, errors);
    }

    /**
     *  Description :   Method is used for sending single mail message with these 4 arguments.
     *
     *      1.  String toAddress    :   This is mail id of recipients.
     *
     *      2.  String subject      :   This is subject of mail.
     *
     *      3.  String body         :   This is mail body.
     *
     *      4.  String htmlBody     :   This is html body part of mail.
     *
     *  Example:    String toAddress = 'test@test.com';
     *              String subject = 'Example mail';
     *              String body = 'This is your creation have great time forever';
     *              String htmlBody += '<tr><td>Data1</td><td>Data2</td></tr>';
     *              EmailHandler.sendEmail(toAddress, subject, body, htmlBody);
     *
     **/
     public static void sendEmail(String toAddress, String subject, String body, String htmlBody) {

       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       // email address of the salesforce email service
       String[] toAddresses = new String[] {toAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject(subject);
       mail.setPlainTextBody(body);
       mail.setHtmlBody(htmlBody);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

	//Added by Poonam Bhargava  - D-00017166
	//Method to Populate Market field from Market2(Region__c) on various objects.
	public static void populateMarketFromRegion(List<Sobject> objects, String sourceField, String targetField){

		//String varibales
		String source = sourceField;
		String target = targetField;
		 
		//Loop over objects list   
		for(Sobject obj : objects){
		   
			//String variables to hold the source(Market2) and target(Market) field values 
			String strSourceField = String.valueOf(obj.get(sourceField));
			String strTargetField = String.valueOf(obj.get(targetField));
			 
			//Check for eligible criteria populate market field and populate accordingly       
			if(strSourceField  != null && strTargetField == null){
				obj.put(target, obj.get(source)); 
			}   
		}      
	}   
}