/**
 *  Description :   Helper class for Trigger_Property_Opportunity trigger.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   10/27/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - Bhavi - 11/19/2012 - New method added(attachPipelinesWithBiddingStat)
 *                  V1.2 - Vrajesh Sheth - 12/09/2012 - New method added (validateAllDateField)
 *                  V1.3 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  V1.4 - (02/02/2013) - Bhavi - New methid added(createFeedItemForChatterGroup)
 *                  V1.5 - (05/07/2013) - Rajesh - New Method added (updatePipelineExpenseMarginFromRegion) - SIR - 4300
 *                  V1.6 - (06/21/2013) - Rajesh - Added Sharing rule method to share Pipeline with Prosect Owner - SIR - 5643
 *                  V1.7 - (07/19/2013) - Bhavi - Added a new method(shareProspectWithCoworkers) - D-00006512
 *                  V1.8 - (08/07/2013) - Bhavi - Modified propertyOpportunityToPropertyConversion method - D-00007041
 **/

public class Property_OpportunityTriggerHelper{

    //This flag is to control the execution of Prospect Trigger
    public static Boolean EXECUTE_PIPELINE_TRIGGER = true;
    public static Boolean EXECUTE_PIPELINE_AFTER_UPDATE_TRIGGER = true;
    public static Boolean EXECUTE_PROPERTY_OPPORTUNITY_TO_PROPERTY_CONVERSION = true;
    public static Boolean EXECUTE_TOTAL_NO_OF_HOMES_WON = true;

    //set to contain ids of pipelines converted to portfolios
    private static Set<Id> convertedPipelineIds = new Set<Id>();

    //This method is to set defults fileds on AZB Pipelines
    public static void setAZBPipelineDefultsFields(List<Property_Opportunity__c> pipelines) {

        //loop through the pipelines
        for(Property_Opportunity__c pipeline : pipelines) {
            if(pipeline.AZB_Update__c != null) {
                pipeline.Back_Taxes_Est_UW__c = 0;
                pipeline.Bid_Service_Expense__c = 1000;
                pipeline.CFK_Est_UW__c = 0;
                //pipeline.HOA_Options__c = 'Unknown';
                pipeline.Liens_Fines_Est_UW__c = 0;
                pipeline.Other_Closing_Costs_Est_UW__c = 0;
                pipeline.Title_Policy_Cost_Est_UW__c = 0;
            }
        }
    }

    //This method is to refresh residence on pipeline insert
    public static void refreshResidence(List<Property_Opportunity__c> pipelines) {
        Set<Id> residenceIds = new Set<Id>();

        Set<Id> prospectIds = new Set<Id>();
        //loop through the pipelines
        for(Property_Opportunity__c pipeline : pipelines) {
            if(pipeline.Residence__c != null) {
                residenceIds.add(pipeline.Residence__c);
                if(pipeline.Prospect__c != null) {
                    prospectIds.add(pipeline.Prospect__c);
                }
            }
        }

        //list of residence to be refresed from prospect on pipeline conversion
        List<Residence__c> listResidenceToUpdate = new List<Residence__c>();

        for(Residence__c res : [Select  Id , (Select Property_State__r.Name,
                                        Baths__c,
                                        Subdivision__c,
                                        Bedrooms__c, Property_Street__c, Address_Unit__c,
                                        Property_Zip_Code__c, Property_City__c,
                                        APN__c, Property_County__c,
                                        HOA_Options__c, HOA__c, HOA_Phone__c,
                                        Parking__c, Pool__c, Property_Type__c,
                                        Roof_Type__c, Square_Feet__c,
                                        Year_Built__c, AC_or_Evap__c, Lot_Sq_Ft__c,
                                        Region__c, Market__c,Property_Cross_Streets__c,
                                        Residence__c,
                                        Address_Validated_City__c,
                                        Address_Validated_County__c,
                                        Address_Validated_Last_Attempt__c,
                                        Address_Validated_State__c,
                                        Address_Validated_Street__c,
                                        Address_Validated_Successfully__c,
                                        Address_Validated_Zip__c,
                                        Address_Validation_Message__c,
                                        Zip_Plus_4__c,
                                        Geolocation__Latitude__s,
                                        Geolocation__Longitude__s
                                        From Prospect__r
                                        Where Id in: prospectIds and IsConverted__c = TRUE
                                        Order By LastModifiedDate DESC Limit 1)
                                        From Residence__c Where id in : residenceIds]) {

            if(res.Prospect__r.size() > 0) {
                listResidenceToUpdate.add(ResidenceService.populateResidence(res, res.Prospect__r.get(0)));
            }
        }

        if(listResidenceToUpdate.size() > 0 ) {
            update listResidenceToUpdate;
        }

    }


    //This method is to set the prospect fileds
    public static void setPipelineFields(List<Property_Opportunity__c> pipelines) {

        //loop through the pipelines
        for(Property_Opportunity__c pipeline : pipelines) {

            //Set Pipelines data
            pipeline.All_In_Cost_Est_UW__c = Utility.populateAllInCostEstForPipeline(pipeline);
        }
    }

    //This method is to set IsConverted Field value for Property Opportunity Object
    public static void setIsCovertedFlag(List<Property_Opportunity__c> newPropertyOpportunity, List<Property_Opportunity__c> oldPropertyOpportunity) {

        //Loop through new records list
        for(Property_Opportunity__c PropertyOppNew : newPropertyOpportunity) {

            //Loop through old records list
            for(Property_Opportunity__c PropertyOppOld : oldPropertyOpportunity) {

                //Check for Value
                if(PropertyOppOld.Approved_from_Asset_Management_Team__c == Null && PropertyOppNew.Approved_from_Asset_Management_Team__c != Null) {

                    //Set Flag Value
                    PropertyOppNew.IsConverted__c = true;
                }
            }
        }
    }

    //This method is to for Property Opportunity to Property Conversion
    public static void propertyOpportunityToPropertyConversion(List<Property_Opportunity__c> newPropertyOpportunity, List<Property_Opportunity__c> oldPropertyOpportunity) {

        //Add data in set to check wheather trigger need to be executed
        Boolean recordsToProcess = false;

        //Loop through new records list
        for(Integer i = 0; i < newPropertyOpportunity.size(); i++) {

            //condition to stop duplicate conversion due to field update causing trigger  to fire again
            if( !convertedPipelineIds.contains( newPropertyOpportunity[i].Id ) ) {

                //Check for Value
                if(newPropertyOpportunity[i].IsConverted__c == true && newPropertyOpportunity[i].IsConverted__c != oldPropertyOpportunity[i].IsConverted__c) {

                    //Set flag
                    recordsToProcess = true;
                    //add pipeline id to the set
                    convertedPipelineIds.add( newPropertyOpportunity[i].Id );
                }
            }
        }

        //Check it there are records to process
        if(recordsToProcess == false)
            return;

        //Get all Values for custom setting
        List<Property_Conversion_Maching_For_Approval__c> listPropertyConversionSetting = Property_Conversion_Maching_For_Approval__c.getall().values();

        //Set to hold custom setting records Ids
        Set<Id> setCustomSettingIds = new Set<Id>();

        //Loop through Custom Setting
        for(Property_Conversion_Maching_For_Approval__c setting : listPropertyConversionSetting) {

            //Check for Mapping Name field value for Custom Setting
            if(setting.Mapping_Name__c == Constants.PIPELINE_TO_PROPERTY_CONVERSION) {

                //Populate Set with Values
                setCustomSettingIds.add(setting.Id);
            }
        }

        //Create a map to hold the Property Code with respect to state-region
        Map<String, Integer> mapPropertyCode = new Map<String, Integer>();

        //Get the max property code
        for(AggregateResult aggr : [Select Region__c region, Max(Property_Code_Number_Part__c) code from Property__c where Region__c != null AND Property_Code_Number_Part__c != null group by Region__c]) {

            //Create key and value for Map
            String key = String.valueOf(aggr.get('region')).toLowerCase();
            Integer val = Integer.valueOf(aggr.get('code'));

            //Add in map
            mapPropertyCode.put(key, val);
        }

        Map<String, Integer> mapYardiPropertyCode = new Map<String, Integer>();
        // funds included for new yardi property code format
        Set<String> includedFunds = new Set<String> { '05', '06' };

        //Get the max property code
        for(AggregateResult aggr : [Select Fund__c fund, Region__c region, Max(Yardi_Property_Code_Number_Part__c) yardiSuffix from Property__c where Fund__c in: includedFunds And Region__c != null AND Yardi_Property_Code_Number_Part__c != null group by Region__c, Fund__c ]) {

            //Create key and value for Map
            String regionKey = String.valueOf(aggr.get('region')).toLowerCase();
            Integer yardiSuffix = Integer.valueOf(aggr.get('yardiSuffix'));
            String fundKey = String.valueOf(aggr.get('fund')).toLowerCase();

            mapYardiPropertyCode.put( fundKey + regionKey, yardiSuffix );
        }

        //Create a Map for Region code
        Map<String, String> mapRegion = new Map<String, String>();

        //Loop through new records list
        for(Region__c region : [Select Id, Name, Property_Code_Base__c from Region__c where Property_Code_Base__c != null]) {

            //Add region name in set
            mapRegion.put(region.Name.toLowerCase(), region.Property_Code_Base__c);
        }


        //List having custom setting records related to Pipeline to Property Connersion
        List<Property_Conversion_Maching_For_Approval__c> listPropertyCustomSetting = [SELECT ID, Name, Source_API_Name__c,
                                        Target_API_Name__c, Mapping_Name__c FROM Property_Conversion_Maching_For_Approval__c
                                        WHERE ID IN : setCustomSettingIds];

        //Create a list of properties
        List<Property__c> properties = new List<Property__c>();

        //Create maps tp hold prospect and pipeline Schema
        Map<String, Schema.SObjectField> pipelineSchema = Schema.SObjectType.Property_Opportunity__c.fields.getMap();
        Map<String, Schema.SObjectField> propertySchema = Schema.SObjectType.Property__c.fields.getMap();

        //Loop through new records list
        for(Integer i = 0; i < newPropertyOpportunity.size(); i++) {

            //Add a new record
            Property__c property = new Property__c();

            //populate Property Code
            if(newPropertyOpportunity[i].Region__c != null) {

                //Create key for Property code map
                String key = newPropertyOpportunity[i].Region__c.toLowerCase();

                System.debug(LoggingLevel.INFO, 'Selected region on property: ' + key);
                System.debug(LoggingLevel.INFO, 'Region records: ' + mapRegion);
                System.debug(LoggingLevel.INFO, 'Property Codes: ' + mapPropertyCode);

                //Max code from code map
                Integer propNumber = 1;  // For first one if the region is new
                if(mapPropertyCode.containsKey(key)) {
                    propNumber = mapPropertyCode.get(key) + 1;
                }
                // Now construct and set the property code
                String newNumberPart = '0000' + propNumber;
                String regionBase = mapRegion.get(newPropertyOpportunity[i].Region__c.toLowerCase());
                property.Property_Code__c = regionBase.toUpperCase() + newNumberPart.right(4);

                System.debug(LoggingLevel.INFO, 'Generated Property Code for this property is: ' + property.Property_Code__c);

                if( newPropertyOpportunity[i].Fund__c != null && includedFunds.contains(newPropertyOpportunity[i].Fund__c)) {
                    String fundKey = newPropertyOpportunity[i].Fund__c;

                    //Max code from code map
                    Integer yardiPropNumber = 1;  // For first one if the region is new

                    if(mapYardiPropertyCode.containsKey(fundKey+key)) {
                        yardiPropNumber = mapYardiPropertyCode.get(fundKey+key) + 1;
                    }
                    // Now construct new yardi property code suffix number
                    String newYardiPropNumberPart = '0000' + yardiPropNumber;
                    property.Yardi_Property_Code_Number_Part__c = newYardiPropNumberPart.right(4);
                    mapYardiPropertyCode.put(fundKey+key, yardiPropNumber);
                }

                //Add in map
                mapPropertyCode.put(key, propNumber);

            }

            //Check for Value
            if(newPropertyOpportunity[i].IsConverted__c == true && newPropertyOpportunity[i].IsConverted__c != oldPropertyOpportunity[i].IsConverted__c) {

                //Loop through Custom Setting
                for(Property_Conversion_Maching_For_Approval__c settingConversion : listPropertyCustomSetting) {

                    //Getting Source API Name
                    String sourceAPINameString = settingConversion.Source_API_Name__c;

                    //Get Target API Name
                    String targetAPINameString = settingConversion.Target_API_Name__c;

                    //Validate the mapping
                    if(pipelineSchema.containsKey(settingConversion.Source_API_Name__c.toLowerCase())
                        && propertySchema.containsKey(settingConversion.Target_API_Name__c.toLowerCase())) {

                        //Check if fied is custom and not a calculation
                        Schema.DescribeFieldResult source = pipelineSchema.get(settingConversion.Source_API_Name__c.toLowerCase()).getDescribe();
                        Schema.DescribeFieldResult target = propertySchema.get(settingConversion.Target_API_Name__c.toLowerCase()).getDescribe();

                        //Check if target is not a formula field and Data type matches for source and target
                        if(!target.isCalculated() && (settingConversion.Source_API_Name__c.toLowerCase() == 'id'
                                                        || source.getType() == target.getType()
                                                        || (source.getType() == Schema.DisplayType.TextArea
                                                                || source.getType() == Schema.DisplayType.STRING
                                                                || source.getType() == Schema.DisplayType.PICKLIST
                                                                || source.getType() == Schema.DisplayType.EMAIL
                                                                || source.getType() == Schema.DisplayType.PHONE)
                                                            &&
                                                            (target.getType() == Schema.DisplayType.TextArea
                                                                || target.getType() == Schema.DisplayType.STRING
                                                                || target.getType() == Schema.DisplayType.PICKLIST
                                                                || target.getType() == Schema.DisplayType.EMAIL
                                                                || target.getType() == Schema.DisplayType.PHONE))
                                                            ) {

                            //Get Value
                            Object pro = newPropertyOpportunity[i].get(settingConversion.Source_API_Name__c.toLowerCase());

                            //Put Value
                            property.put(settingConversion.Target_API_Name__c.toLowerCase(), pro);
                        }
                    }
                }

                //Add record in list to be updated
                properties.add(property);
            }
        }

        //Check for Name
        if(properties.size() > 0) {

            //Insert Propeerty
            upsert properties;

            //Bhavi Sharma - 08/07/2013
            //Create a Map, Key => Pipeline Id and Value => Property Id
            Map<Id, Id> mapPipelineIdWithPropertyId = new Map<Id, Id>();

            //Loop through the newly created Pipeline and populate the Map
            for(Property__c property : properties)
                mapPipelineIdWithPropertyId.put(property.Pipeline__c , property.Id);

            //Migrate Attachments from Pipeline to Property
            Utility.migrateAttachmentFromSourceToTarget(mapPipelineIdWithPropertyId);
        }
    }

    //This method is to attach the pipeline records with appropriate bidding stat record
    public static void attachPipelinesWithBiddingStat(List<Property_Opportunity__c> pipeline) {

        //create a set to hold the Bidding Stat date and region
        Set<Date> reportingDates = new Set<Date>();
        Set<String> regions = new Set<String>();
        Map<String, Id> mapBiddingStat = new Map<String, Id>();
        Map<String, Property_Opportunity__c> mapPropertyOpportunities = new Map<String, Property_Opportunity__c>();

        //Loop through the records and prepare data set
        for(Property_Opportunity__c pLine : pipeline) {

            //Populate data set
            if(pLine.Reporting_Date__c != null && pLine.Region__c != null && pLine.Region__c != '') {

                reportingDates.add(pLine.Reporting_Date__c);
                regions.add(pLine.Region__c);

                //Create key for map
                String key = pLine.Reporting_Date__c + '-' + pLine.Region__c;

                //Add in Map
                mapPropertyOpportunities.put(key, pLine);
            }
        }

        //Loop through the records and prepare data set
        for(Bidding_Statistics__c biddingStat : [Select Date__c, Region__c from Bidding_Statistics__c where Date__c != null AND Region__c != null
                                                                                                            AND Date__c IN: reportingDates
                                                                                                            AND Region__c IN: regions]) {

            //Populate data set
            if(biddingStat.Date__c != null && biddingStat.Region__c != null && biddingStat.Region__c != '') {

                //Create key for map
                String key = biddingStat.Date__c + '-' + biddingStat.Region__c;

                //Check for the key
                if(!mapBiddingStat.containsKey(key)) {

                    //put data in map
                    mapBiddingStat.put(key, biddingStat.Id);

                    //Remove from map as Acquisition record already exists
                    mapPropertyOpportunities.remove(key);
                }
            }
        }

        //Add more Acquisition Rep[orting records]
        List<Bidding_Statistics__c> biddingStatisticsToInsert = new List<Bidding_Statistics__c>();

        //Loop through the new reporting dates
        for(Property_Opportunity__c pLine : mapPropertyOpportunities.values()) {

            //Add in list to insert
            biddingStatisticsToInsert.add(new Bidding_Statistics__c(Date__c = pLine.Reporting_Date__c, Region__c = pLine.Region__c));
        }

        //Insert in data base
        if(biddingStatisticsToInsert.size() > 0)
            insert biddingStatisticsToInsert;

        //loop through the newly created records and add in existing map
        for(Bidding_Statistics__c biddingStat : biddingStatisticsToInsert) {

            //Create key for map
            String key = biddingStat.Date__c + '-' + biddingStat.Region__c;

            //Check for the key
            if(!mapBiddingStat.containsKey(key)) {

                //put data in map
                mapBiddingStat.put(key, biddingStat.Id);
            }
        }

        //Fetch all the property records with the same reporting date
        for(Property_Opportunity__c pLine : pipeline) {

            //Set default value
            pLine.Acquisition_Reporting__c = null;

            //Populate data set
            if(pLine.Reporting_Date__c != null && pLine.Region__c != null && pLine.Region__c != '') {

                //Create key for map
                String key = pLine.Reporting_Date__c + '-' + pLine.Region__c;

                //Check if pipeline is already assciated with correct Bidding Statistics
                //if not then update the relationship
                if(mapBiddingStat.containsKey(key) && mapBiddingStat.get(key) != pLine.Acquisition_Reporting__c) {

                    //Populate pLine's bidding stat data
                    pLine.Acquisition_Reporting__c = mapBiddingStat.get(key);
                }
            }
        }
    }

    //Validate date field for Pipeline object
    public static void validateAllDateField(List<SObject> sObjects) {

        Set<String> fieldNotAllowedToHoldFutureDate = Constants.PIPELINE_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE ;

        //Describe pipeline object
        Schema.DescribeSObjectResult pipelineObject = Property_Opportunity__c.sObjectType.getDescribe();

        //Describe pipeline object and get all the fields
        Map<String, Schema.SObjectField> pipelineFieldsMap = pipelineObject.fields.getMap();

        //loop through the records
        for(SObject sObj : sObjects) {

            //Loop through the fields name
            for(String fName : pipelineFieldsMap.keySet()) {

                //Describe field
                Schema.DescribeFieldResult field = pipelineFieldsMap.get(fName).getDescribe();

                //Check if the field is customa and type is Date
                if(field.isCustom() && (!field.isCalculated()) && (field.getType() == DisplayType.Date || field.getType() == DisplayType.DateTime)) {

                    //Check if field is not allowed to hold future date
                    if(fieldNotAllowedToHoldFutureDate.contains(fName .toLowerCase()) && sObj.get(fName) != null) {

                        //check for the value
                        if(field.getType() == DisplayType.Date) {

                            //Getting Local Time String
                            Date myDate = Date.valueOf(sObj.get(fName));
                            List<String> dateString = Date.valueOf(sObj.get(fName)).format().split('/');

                            //Chekc for the future date
                            if(date.newinstance(Integer.valueOf(dateString[2]), Integer.valueOf(dateString[0]), Integer.valueOf(dateString[1])) > Date.toDay()) {

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

    public static void createBoxProspectFolder(List<Property_Opportunity__c> newPipelines, MAP<Id, Property_Opportunity__c> mapPipelines){

        //call batch
        //BatchCreateBoxFolder.runJob(mapPipelines.keySet(), String.valueOf(newPipelines.get(0).getSObjectType()));

        //Commented the code as per SIR D-00003149

        Set<Id> setCreateFolderIds = new Set<Id>();
        Set<Id> setPromoteFolderIds = new Set<Id>();

        for(Property_Opportunity__c p : newPipelines) {
            if(p.Box_Folder_Id__c == null) {
                setCreateFolderIds.add(p.Id);
            }
            else {
                setPromoteFolderIds.add(p.Id);
            }
        }

        if(setCreateFolderIds.size() > 0) {
            //BoxSearchAndCreateMissingFolders.createMassFolderHierarchyIHServiceFuture(setCreateFolderIds, IHBoxIntegrationService.OBJECT_TYPE_PIPELINE);
        }
        if(setPromoteFolderIds.size() > 0) {
            //commented because of error source folder not found making debugging difficult on S3
            //BoxSearchAndCreateMissingFolders.promoteMassFolderHierarchyIHServiceFuture(setPromoteFolderIds, IHBoxIntegrationService.OBJECT_TYPE_PIPELINE);
        }

    }


    public static void totalNoOfHomesWon(List<Property_Opportunity__c> pipelineNew, List<Property_Opportunity__c> pipelineOld) {

        //Set to hold the Acquistions Dates
        Set<Date> setAcquisitionDates = new Set<Date>();

        //Set to hold the Regions
        Set<String> setRegions = new Set<String>();

        //Do not execute this in case of delete
        if(pipelineNew != null) {

            //Loop through Pipeline Records
            for(Property_opportunity__c pipeline : pipelineNew) {

                //Check for Null
                if(pipeline.Acquisition_Date__c != Null) {

                    //Populate set with values
                    setAcquisitionDates.add(pipeline.Acquisition_Date__c);
                }

                //Check for Null
                if(pipeline.Region__c != Null) {

                    //Populate Set with values
                    setRegions.add(pipeline.Region__c);
                }
            }
        }

        //Check for Event Type
        if(pipelineOld != null) {

            //Loop through Pipeline Records
            for(Property_opportunity__c pipeOld : pipelineOld) {

                //Check for Null
                if(pipeOld.Acquisition_Date__c != Null) {

                    //Populate set with values
                    setAcquisitionDates.add(pipeOld.Acquisition_Date__c);
                }

                //Check for Null
                if(pipeOld.Region__c != Null) {

                    //Populate Set with values
                    setRegions.add(pipeOld.Region__c);
                }
            }
        }

        //Calling Helper Class Method
        Utility.populateTotalNoHomes(setAcquisitionDates, setRegions);
    }

    //This method is to adda feed item on group when pipeline is acquired
    public static void createFeedItemForChatterGroup(Map<Id, Property_Opportunity__c> mapNewPipeline, Map<Id, Property_Opportunity__c> mapOldPipeline) {

        //Variable to hold the chatter text for all properties
        List<FeedItem> feedItems = new List<FeedItem>();

        //Get the Group Id
        Id chatterGroupId = Constants.CHATTER_COLLABARATION_GROUP_FOR_ACQUIRED_PROPERTIES;

        //Chekc if group is defined
        if(chatterGroupId != null) {

            //Loop through the Pipeline
            //If new pipeline added with Acquired status or Pipeline status has been updated to acquired
            //Make a chatter post
            for(Property_Opportunity__c pipeline : mapNewPipeline.values()) {

                //Chekc if status is acquired
                if(pipeline.Stage__c == Constants.STAGE_ACQUIRED && (mapOldPipeline == null || pipeline.Stage__c != mapOldPipeline.get(pipeline.Id).Stage__c)) {

                    //add body in list
                    feedItems.add(new FeedItem(Type = 'LinkPost', LinkURL = '/' + pipeLine.Id, Title =  pipeLine.Name,
                                                Body = pipeLine.Name + ' has been ' + Constants.STAGE_ACQUIRED, ParentId = chatterGroupId));
                }
            }

            //Check if there are records to process
            if(feedItems.size() > 0)
                insert feedItems;
        }
    }

    // Added by Rajesh
    // Update Pipeline address from Residence when Pipeline is created.
    public static void updatePipelineAddressFromResidence(List<Property_Opportunity__c> pipelineList) {
        Map<Id, List<Property_Opportunity__c>> residencePipelineMap = new Map<Id, List<Property_Opportunity__c>>();
        for(Property_Opportunity__c pipeline : pipelineList) {
            if(pipeline.Residence__c != null) {
                if(residencePipelineMap.containsKey(pipeline.Residence__c))
                    residencePipelineMap.get(pipeline.Residence__c).add(pipeline);
                else
                    residencePipelineMap.put(pipeline.Residence__c, new List<Property_Opportunity__c>{pipeline});
            }
        }
        for(Residence__c res : [Select Address_Street__c from Residence__c
                                                where   Id in :residencePipelineMap.keySet()
                                                and     Address_Street__c != null]) {
            for(Property_Opportunity__c pipeline : residencePipelineMap.get(res.Id))
                pipeline.Street_Address__c = res.Address_Street__c;
        }
    }

    // Added by Rajesh - SIR 4300
    // Update M1 Expense Margin EST UW from Region
    /**public static void updatePipelineExpenseMarginFromRegion(List<Property_Opportunity__c> pipelineList, Map<Id, Property_Opportunity__c> pipelineOldMap, Boolean isUpdate) {

        // Create a map of Region Name and the list of Pipelines
        Map<String, List<Property_Opportunity__c>> regionPipelineMap = new Map<String, List<Property_Opportunity__c>>();
        for(Property_Opportunity__c pipeline : pipelineList) {
            // If region is null, make margin null
            if(pipeline.Region__c == null)
                pipeline.M1_Expense_Margin_Est_UW__c = null;
            // Ignore Chicago region
            else if(pipeline.Region__c.toUpperCase() != 'CHICAGO') {
                // Calculate only if Region is not null and it has been updated for update case.
                if(!isUpdate || pipelineOldMap.get(pipeline.Id).Region__c == null
                    || pipelineOldMap.get(pipeline.Id).Region__c != pipeline.Region__c) {
                    if(regionPipelineMap.containsKey(pipeline.Region__c))
                        regionPipelineMap.get(pipeline.Region__c).add(pipeline);
                    else
                        regionPipelineMap.put(pipeline.Region__c, new List<Property_Opportunity__c>{pipeline});
                }
            }
        }

        // Get the regions
        for(Region__c region : [Select Name, M1_Expense_Margin_Fund1__c, M1_Expense_Margin_Fund2__c
                                        From    Region__c
                                        where   Name in :regionPipelineMap.keySet()]) {
            // Get the Pipelines for the Pipelines
            for(Property_Opportunity__c pipeline : regionPipelineMap.get(region.Name)) {
                if(pipeline.Fund__c != null) {
                    // If Fund is 01 assign Fund1 field else Fund2 field.
                    if(pipeline.Fund__c == '01')
                        pipeline.M1_Expense_Margin_Est_UW__c = region.M1_Expense_Margin_Fund1__c;
                    else if(pipeline.Fund__c == '02')
                        pipeline.M1_Expense_Margin_Est_UW__c = region.M1_Expense_Margin_Fund2__c;
                }
            }
        }
    }**/

    //Method to update EMD/COE Request pipeline field after insertion of pipeline record
    public static void updateEMDCOERequestPipelineFieldOnPipelineInsert(List<Property_Opportunity__c> newPipelines) {

        //Set to store prospect
        Set<Id> setProspectIds = new Set<Id>();

        //Get prospect through pipeline records
        for(Property_Opportunity__c pipeline : newPipelines) {

            //Add prospects in the set
            setProspectIds.add(pipeline.Prospect__c);
        }

        //Create a map of the prospect id and pipeline
        Map<Id,Property_Opportunity__c> mapProspectIdWithPipeline = new Map<Id,Property_Opportunity__c>();

        //Get pipeline records
        for(Property_Opportunity__c pipe :[Select Id, Prospect__c from Property_Opportunity__c Where Prospect__c IN : setProspectIds]) {

            //Putting values in map
            mapProspectIdWithPipeline.put(pipe.Prospect__c,pipe);
        }
        System.debug('@@@@@@@ value in mapProspectIdWithPipeline ' + mapProspectIdWithPipeline);
        //List to hold the EMD/COE Request
        List<EMD_COE_Request__c> listEMDCOERequests = [Select Id, Pipeline__c,Prospect__c from EMD_COE_Request__c WHERE Prospect__c In : setProspectIds];

        //List of EMD_COE_Request__c records will update with pipeline lookup value
        List<EMD_COE_Request__c> listEMDCOERequestGoingToBeUpdate = new List<EMD_COE_Request__c>();

        //Check for size of list
        if(listEMDCOERequests.size() > 0) {

            //Create map of the prospect id and EMD/COE Request
            Map<Id, List<EMD_COE_Request__c>> mapProspectIdWithEMDCOERequests = new Map<Id,List<EMD_COE_Request__c>>();

            //Get EMD/COE Request records
            for(EMD_COE_Request__c emdCoe : listEMDCOERequests) {

                //List of EMD/COE Request
                List<EMD_COE_Request__c> emdRequestList;

                //Checking value in the map
                if(!mapProspectIdWithEMDCOERequests.containsKey(emdCoe.Prospect__c)) {

                    //Populate list wioth the value
                    emdRequestList = new List<EMD_COE_Request__c>{emdCoe};

                } else {

                    emdRequestList = mapProspectIdWithEMDCOERequests.get(emdCoe.Prospect__c);
                    emdRequestList.add(emdCoe);
                }

                //Putting values in map
                mapProspectIdWithEMDCOERequests.put(emdCoe.Prospect__c, emdRequestList);

            }
            System.debug('@@@@@@@ value in mapProspectIdWithEMDCOERequests ' + mapProspectIdWithEMDCOERequests);
            //loop through map keys
            for(String prospectId : mapProspectIdWithPipeline.keyset()) {

                //check for EMD/COE Records
                if(mapProspectIdWithEMDCOERequests.get(prospectId) != null) {

                    //Loop through list of EMD/COE Requests
                    for(EMD_COE_Request__c emdCOERequest : mapProspectIdWithEMDCOERequests.get(prospectId)) {

                        //Populate pipeline lookup fields value with appropraite Pipeline ID
                        emdCOERequest.Pipeline__c = mapProspectIdWithPipeline.get(prospectId).ID;

                        //Add record in the list
                        listEMDCOERequestGoingToBeUpdate.add(emdCOERequest);
                    }
                }
            }
        }
        System.debug('@@@@@@@ value in listEMDCOERequestGoingToBeUpdate ' + listEMDCOERequestGoingToBeUpdate);
        //Check for size
        if(listEMDCOERequestGoingToBeUpdate.size() > 0) {
            update listEMDCOERequestGoingToBeUpdate;
        }
    }

    // Function to add Sharing rule to share Pipeline with Prospect owner if it is Customer Portal User
    public static void sharePipelineWithProspectOwner(List<Property_Opportunity__c> pipelines) {

        // Set of Prospect Ids
        Set<Id> prospectIds = new Set<Id>();
        for(Property_Opportunity__c pipeline : pipelines) {
            if(pipeline.Prospect__c != null)
                prospectIds.add(pipeline.Prospect__c);
        }

        // Query all the Prospects with the Owner details where Owner is Portal Enabled
        Map<Id, Prospect__c> prospectMap = new Map<Id, Prospect__c>([Select OwnerId from Prospect__c]);

        // Create set of User Ids
        Set<Id> userIds = new set<Id>();
        for(Prospect__c pros : prospectMap.values()) {
            userIds.add(pros.OwnerId);
        }
        Map<Id, User> userMap = new Map<Id, User>([Select IsPortalEnabled from User where Id in :userIds and IsPortalEnabled = true]);

        // Check if the User for the Prospect Owner for the Pipeline is Customer Portal user.
        // If so, add sharing rule
        List<Property_Opportunity__Share> pipelineShare = new List<Property_Opportunity__Share>();
        for(Property_Opportunity__c pipeline : pipelines) {
            if(pipeline.Prospect__c != null) {
                if(prospectMap.containsKey(pipeline.Prospect__c)) {
                    Prospect__c pros = prospectMap.get(pipeline.Prospect__c);
                    if(userMap.containsKey(pros.OwnerId)) {
                         pipelineShare.add(new Property_Opportunity__Share(
                            ParentId        = pipeline.Id,
                            UserOrGroupId   = pros.OwnerId,
                            AccessLevel     = 'Read',
                            RowCause        = 'Manual'
                         ));
                    }
                }
            }
        }

        // Create Sharing record
        insert pipelineShare;
    }

    //If prospect creator is a Customer Portal User, Fetch the User's role.
    //and then share current Pipeline record with User's Role. All the broker users, associated with the account, will be having the same role.
    //So adding a sharing rule with that, will give them access on the Pipleine record
    public static void sharePipelineWithCoworkers(List<Property_Opportunity__c> pipeline) {

        //Create a set to hold all the Prospect ids
        Set<Id> prospectIds = new Set<Id>();

        //Loop through the Pipeline and populate the set of prospect ids. This set will be used in quering the Prospect data with appropriate creator
        for(Property_Opportunity__c pLine : pipeline) {

            //Add prospect Id in set
            if(pLine.Prospect__c != null)
                prospectIds.add(pLine.Prospect__c);
        }

        //check if records need to be shared
        if(prospectIds.size() > 0) {

            //Create a set of created By users
            Set<Id> createdByIds = new Set<Id>();

            //Query Prospect data with Created Id
            Map<Id, Prospect__c> mapProspects = new Map<Id, Prospect__c>([Select CreatedById from Prospect__c where Id IN: prospectIds]);

            //Loop through the map and Populate CreatorIds set
            for(Prospect__c prospect : mapProspects.values())
                createdByIds.add(prospect.CreatedById);

            //Create a map to hold the Creator's Name with RoleId
            Map<Id, Id> mapCreatorWithRoleId= new Map<Id, Id>();

            //Fetch owner's account infomarmation from database
            for(User user : [Select UserRoleId from User where Id IN: createdByIds AND Profile.UserLicense.Name != 'Authenticated Website'
                                AND IsPortalEnabled = true]) {

                //put data in Map
                mapCreatorWithRoleId.put(user.Id, user.UserRoleId);
            }

            //Create a new Map to hold the users with Group Id
            Map<Id, Id> mapRoleIdWithGroupId = new Map<Id, Id>();

            //Query all teh groups related with Roles
            for(Group grp : [Select Id, RelatedId from Group where RelatedId IN: mapCreatorWithRoleId.values() AND Type = 'Role']) {

                //Add data in Map
                mapRoleIdWithGroupId.put(grp.RelatedId, grp.Id);
            }

            //Chekc if map has values to process
            if(mapRoleIdWithGroupId.size() > 0) {

                //Create a List of sharing records
                List<Property_Opportunity__Share> shares = new List<Property_Opportunity__Share>();

                //Loop through the Pipeline Records and Create the Pipeline__Share record with the Pipeline and Appropriate Role
                for(Property_Opportunity__c pLine : pipeline) {

                    //Check for the Prospect Id
                    if(pLine.Prospect__c != null) {

                        //Get the Prospect data from Map
                        Prospect__c prospect = mapProspects.get(pLine.Prospect__c);

                        //Get the Group Id from mapGroupNameWithId map
                        if(mapCreatorWithRoleId.containsKey(prospect.CreatedById)) {

                            //RoleId
                            Id roleId = mapCreatorWithRoleId.get(prospect.CreatedById);

                            //Group Id
                            Id groupId = mapRoleIdWithGroupId.get(roleId);

                            //Create a Pipeline Share record for role Id
                            shares.add(new Property_Opportunity__Share(ParentId = pLine.Id, AccessLevel = 'Edit', UserOrGroupId = groupId));
                        }
                    }
                }

                //Check for the shares records
                if(shares.size() > 0)
                    insert shares;
            }
        }
    }

    //update HD Budget Walk
    public static void updateHDBudgetWalk( List<Property_Opportunity__c> pipelines ) {

        Map<Id, HD_Budget_Walk__c> mapHDBudgetWalkToUpdate = new Map<Id, HD_Budget_Walk__c>();

        //loop over pipelines to fill mapHDBudgetWalkToUpdate
        for( Property_Opportunity__c pipeline : pipelines ) {

            if( pipeline.HD_Budget_Walk__c != null ) {

                mapHDBudgetWalkToUpdate.put( pipeline.Id, new HD_Budget_Walk__c( Id = pipeline.HD_Budget_Walk__c,
                                                                                 Pipeline__c = pipeline.Id ) );

            }
        }

        //update hd budget walks
        if( mapHDBudgetWalkToUpdate.size() > 0 ) {
            update mapHDBudgetWalkToUpdate.values();
        }
    }
}