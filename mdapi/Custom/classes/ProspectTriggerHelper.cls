/**
 *  Description :   Helper class for Trigger_Prospect trigger.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   11/08/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - Updated with the function updateRegionDataForProspect - Rajesh Shah - 12/08/2012
 *                  V1.2 - Added validateAllDateField method for D-00001001 by Vrajesh Sheth - 12/09/2012
 *                  V1.3 - Updated function updateRegionDataForProspect so it initializes 3 more fields 12/10/2012
 *                  V1.4 - Updated function ProspectToPipelineConversion to transfer activities from Prospect to Pipeline - 12/18/2012
 *                  V1.5 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  V1.6 - (01/16/2013) - Bhavi - Added a new method(validateBeforeConvert) - D-00002140
 *                  V1.7 - (01/22/2013) - Bhavi - Modified method validateBeforeConvert as per the Brad's Review Notes - D-00002140
 *                  V1.8 - (01/28/2013) - Bhavi - Modified method updateRegionDataForProspect to be executed on update event - D-00002244
 *                  V1.9 - (02/02/2013) - Abhinav - Modified method updateRegionDataForProspect for adding M1 Expense Margin Est UW - D-00002366
 *                  V2.0 - (05/06/2013) - Rajesh - Updated the condition used to update the Field M1 Expense Margin EST UW on Prospect
 *                  V2.1 - (07/04/2013) - Bhavi - Added a new method(shareProspectWithCoworkers) - D-00005983
 *                  V2.2 - (07/19/2013) - Bhavi - Modified shareProspectWithCoworkers method - D-00006512
 *                  V2.3 - (08/07/2013) - Bhavi - Modified ProspectToPipelineConversion method - D-00007041
 *                  //V2.4 - (05/14/2015) - Abhinav Sharma - createProspectInsuranceMtM method to be added - D-00014026
 *                  v2.5 - (05/16/2016) - Saurabh Kumar  - modified updateRegionDataForProspect - D -00015571
 *                  v2.6 - (09/30/2016) - Saurabh Kumar  - modified updateRegionDataForProspect - D-00016192
 *                  v2.7 - (11/03/2017) - Poonam Bhargava - Added a new method 'markedSWAYonResidence'

 **/

public class ProspectTriggerHelper {
    
    //Error message if prospect's apn is not eligible
    public static final String ELIGIBILITY_ERROR_MESSAGE = 'The APN number entered is already associated with a property that is Active in our system.';
    
    private static String PROSPECT_ACQUISITION_ANALYST_NULL_FOR_REGION = 'ProspectAcq_AnalystSkipForRegion';
    
    //This flag is to control the execution of Prospect Trigger 
    public static Boolean EXECUTE_PROSPECT_TRIGGER = true;
    
    private static Map<Id, State__c> mapState = new Map<Id, State__c>();
    private static Map<String, Residence__c> mapAPNUnique_Residence = new Map<String, Residence__c>();
    
    //Get APN Unique
    private static String getApnUnique(Prospect__c p){
        return Utility.getApnUnique(p.Bid_Type__c, p.APN__c);
    }
    
    //set to contain ids of prospects converted to pipeline
    private static Set<Id> convertedProspectIds = new Set<Id>();
    
    //populate Residence on prospect
    public static void populateResidence(List<Prospect__c> prospects, Map<ID, Prospect__c> prospectsOldMap) {
        
        Set<String> setAPNToSearch = new Set<String>();
        Set<Id> setStateIds = new Set<Id>();
        
        //loop over prospects
        for(Prospect__c p : prospects) {
            
            //if insert and residence equals to null or update and residence equals to null and apn updated to eligible prospect
            if( (trigger.isInsert && p.Residence__c == null)
               || (trigger.isUpdate &&
                   (Utility.hasFieldChanged(p, prospectsOldMap, 'APN__c') || p.Residence__c == null ))) {
                       
                       //if update and apn not eligible then throw error
                       if(trigger.isUpdate) {
                           
                           if(p.APN__c != null && (!ResidenceService.isProspectEligible(p.APN__c))) {
                               p.APN__c.addError(ELIGIBILITY_ERROR_MESSAGE);
                           }
                           
                       }
                       
                       
                       String apnSearch = p.Apn_Search__c != null ? p.Apn_Search__c : Utility.removeExceptAlphaNumeric(p.APN__c);
                       if(apnSearch != null && apnSearch.length() > 0) {
                           setAPNToSearch.add(apnSearch);
                       }
                       setStateIds.add(p.Property_State__c);
                   }
        }
        
        mapState = new Map<Id, State__c>([Select Name From State__c Where id in: setStateIds]);
        mapAPNUnique_Residence = ResidenceService.searchResidenceFromAPN(setAPNToSearch);
        List<Residence__c> listResidence = new List<Residence__c>();
        
        Integer index = 0;
        Map<Integer, Residence__c> mapProspectWithNewResidence = new Map<Integer, Residence__c>();
        
        Map<String, Residence__c> mapAPNUnique_NewResidence = new Map<String, Residence__c>();
        Set<String> setStreet = new set<String>();
        Set<String> setCity = new set<String>();
        Set<String> setState = new set<String>();
        Set<String> setZip = new set<String>();
        
        
        for(Prospect__c p : prospects) {
            Residence__c addressValidatedRes;
            //if Address_Validated_Successfully__c is true
            if(Utility.hasFieldChanged(p, prospectsOldMap, 'Address_Validated_Successfully__c')) {
                setStreet.add(p.Address_Validated_Street__c);
                setCity.add(p.Address_Validated_City__c);
                setState.add(p.Address_Validated_State__c);
                setZip.add(p.Address_Validated_Zip__c);
            }
        }
        setStreet.remove(null);
        setCity.remove(null);
        setState.remove(null);
        setZip.remove(null);
        
        Map<String, Residence__c> mapAddressKey_Residence = ResidenceService.getResidenceMap(setStreet,
                                                                                             setCity,
                                                                                             setState,
                                                                                             setZip
                                                                                            );
        
        for(Prospect__c p : prospects) {
            Residence__c addressValidatedRes;
            //if Address_Validated_Successfully__c is true
            if( (Utility.hasFieldChanged(p, prospectsOldMap, 'Address_Validated_Successfully__c'))
               && p.Address_Validated_Street__c != null
               && p.Address_Validated_City__c != null
               && p.Address_Validated_State__c != null
               && p.Address_Validated_Zip__c != null  ) {
                   String validatedAddressKey = p.Address_Validated_Street__c
                       + p.Address_Validated_City__c
                       + p.Address_Validated_State__c
                       + p.Address_Validated_Zip__c;
                   
                   addressValidatedRes = mapAddressKey_Residence.containsKey(validatedAddressKey) ? mapAddressKey_Residence.get(validatedAddressKey) : null;
                   System.debug('@@@@@@@ value in addressValidatedRes  ' + addressValidatedRes );
                   
                   //Checking for null
                   if(addressValidatedRes != null) {
                       // if residence is child unit
                       addressValidatedRes = (addressValidatedRes.Child_Unit__c) ? null : addressValidatedRes;
                   }
               }
            
            //if insert and residence equals to null or update and residence equals to null and apn updated to eligible prospect
            if((trigger.isInsert && p.Residence__c == null)
               || (trigger.isUpdate &&
                   (Utility.hasFieldChanged(p, prospectsOldMap, 'APN__c') || p.Residence__c == null ))) {
                       
                       String apnSearch = p.Apn_Search__c != null ? p.Apn_Search__c.toLowerCase().trim() :
                       ( Utility.removeExceptAlphaNumeric(p.APN__c) != null ? Utility.removeExceptAlphaNumeric(p.APN__c).toLowerCase().trim() : null);
                           
                           
                           
                           if(apnSearch != null && apnSearch.length() > 0 && mapAPNUnique_Residence.containsKey(apnSearch)
                              && (compareValidatedAddressFields(p, addressValidatedRes)
                                  || (addressValidatedRes.Id == mapAPNUnique_Residence.get(apnSearch).Id)
                                 )
                             ) {
                                 p.Residence__c = mapAPNUnique_Residence.get(apnSearch).Id;
                             }
                       //if apn is null for matched validated residence
                       else if(addressValidatedRes != null
                               && addressValidatedRes.APN_Unique__c == null
                              ) {
                                  p.Residence__c = addressValidatedRes.Id;
                                  //update residence apn with prospect's apn if residence's apn is null
                                  if(addressValidatedRes.APN__c == null && p.APN__c != null) {
                                      //add residence to list
                                      listResidence.add(new Residence__c(Id = addressValidatedRes.Id,
                                                                         APN__c = p.APN__c));
                                  }
                              }
                       else {
                           
                           Residence__c res;
                           
                           String alphaNumericAPN = p.Apn_Search__c;
                           
                           
                           if(alphaNumericAPN != null && alphaNumericAPN.length() > 0
                              && mapAPNUnique_NewResidence.containsKey(alphaNumericAPN)) {
                                  
                                  //get residence from map
                                  res = mapAPNUnique_NewResidence.get(alphaNumericAPN);
                              }
                           else {
                               
                               res = createNewResidnece(p);
                               listResidence.add(res);
                               if(alphaNumericAPN != null && alphaNumericAPN.length() > 0) {
                                   mapAPNUnique_NewResidence.put(alphaNumericAPN, res);
                               }
                               
                           }
                           mapProspectWithNewResidence.put(index, res);
                       }
                   }
            index++;
        }
        
        if(listResidence.size() > 0) {
            upsert listResidence;
        }
        
        
        for(Integer i : mapProspectWithNewResidence.keySet()) {
            if(prospects[i].Residence__c == null
               || (trigger.isUpdate &&
                   (Utility.hasFieldChanged(prospects[i], prospectsOldMap, 'APN__c')))) {
                       prospects[i].Residence__c = mapProspectWithNewResidence.get(i).id;
                   }
        }
    }

     private static Boolean compareValidatedAddressFields(Prospect__c p, Residence__c res) {
          if( (p.Address_Validated_Street__c == null ||
               p.Address_Validated_City__c == null ||
               p.Address_Validated_State__c == null ||
               p.Address_Validated_Zip__c == null
              )
              ||
              (res == null ||
               res.Address_Validated_Street__c == null ||
               res.Address_Validated_City__c == null ||
               res.Address_Validated_State__c == null ||
               res.Address_Validated_Zip__c == null
              )
            ) {
                return true;
          }
          else {

                return (   p.Address_Validated_Street__c.equalsIgnoreCase(res.Address_Validated_Street__c)
                          || p.Address_Validated_City__c.equalsIgnoreCase(res.Address_Validated_City__c)
                          || p.Address_Validated_State__c.equalsIgnoreCase(res.Address_Validated_State__c)
                          || p.Address_Validated_Zip__c.equalsIgnoreCase(res.Address_Validated_Zip__c)
                          );
          }
     }

     private static Residence__c createNewResidnece(Prospect__c pros) {

            Residence__c res = ResidenceService.populateResidence(new Residence__c(), pros, mapState);
            return res;
     }


     //This method is to set defults fileds on AZB prospects
     public static void setAZBProspectDefultsFields(List<Prospect__c> prospects) {

          //loop through the prospects
          for(Prospect__c prospect : prospects) {
                if(prospect.AZB_Update__c != null) {
                     prospect.Back_Taxes_Est_UW__c = 0;
                     prospect.Bid_Service_Expense__c = 1000;
                     prospect.CFK_Est_UW__c = 0;
                     prospect.HOA_Options__c = 'Unknown';
                     prospect.Liens_Fines_Est_UW__c = 0;
                     prospect.Other_Closing_Costs_Est_UW__c = 0;
                     prospect.Title_Policy_Cost_Est_UW__c = 0;
                }
          }
     }

    //This method is to set the prospect fileds
    public static void setProspectFields(List<Prospect__c> prospects, Map<ID, Prospect__c> prospectsOldMap) {
        
        //loop through the prospects
        for(Prospect__c prospect : prospects) {
            //if insert or update in bid type or apn
            if(trigger.IsInsert || (
                trigger.IsUpdate
                &&
                (
                    prospect.APN__c != prospectsOldMap.get(prospect.Id).APN__c
                )
            )
              ) {
                  //prospect.APN_Unique__c = getApnUnique(prospect);
                  prospect.APN_Unique__c = Utility.removeExceptAlphaNumeric(prospect.APN__c);
                  prospect.APN_Search__c = Utility.removeExceptAlphaNumeric(prospect.APN__c);
              }
            //Set Prospects data
            prospect.All_In_Cost_Est_UW__c = Utility.populateAllInCostEst(prospect);
        }
    }


    //This method is to validate the conversion
    public static void validateBeforeConvert(List<Prospect__c> listNewProspects, Map<Id, Prospect__c> mapOldProspects) {
        
        //Validation error message
        String validateRequiredFieldsErrorMessage = '';
        
        //Create a set to hold fields name
        Set<String> reqFields = new Set<String>();
        Set<String> reqFieldsForTrustee = new Set<String>();
        Set<String> reqFieldsForNonTrustee = new Set<String>();
        Set<String> reqFieldsForNonTrusteeAndNonBulky = new Set<String>();
        
        //Field Map
        Map<String, Schema.SObjectField> prospectMap = Schema.SObjectType.Prospect__c.fields.getMap();
        
        //Create a list of Configuration_Manager__c
        List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();
        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION));
        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_TRUSTEE));
        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE));
        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE_AND_NON_BULKY));
        
        
        //Get all the required fields from Configuration Manager
        for(Configuration_Manager__c config : configs) {
            
            //Add field in set
            if(config.Parameter_Value__c != null && prospectMap.containsKey(config.Parameter_Value__c.toLowerCase())) {
                
                //Add in reqFields
                if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION.equalsIgnoreCase(config.Parameter_Key__c))
                    reqFields.add(config.Parameter_Value__c.toLowerCase());
                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_TRUSTEE.equalsIgnoreCase(config.Parameter_Key__c))
                    reqFieldsForTrustee.add(config.Parameter_Value__c.toLowerCase());
                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE.equalsIgnoreCase(config.Parameter_Key__c))
                    reqFieldsForNonTrustee.add(config.Parameter_Value__c.toLowerCase());
                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE_AND_NON_BULKY.equalsIgnoreCase(config.Parameter_Key__c))
                    reqFieldsForNonTrusteeAndNonBulky.add(config.Parameter_Value__c.toLowerCase());
            }
        }
        
        //Loop through the properties
        for(Prospect__c prospect : listNewProspects) {
            
            //Check if prospect is being converted
            if(prospect.AZB_Update__c == null && prospect.IsConverted__c == true && (mapOldProspects == null || mapOldProspects.get(prospect.Id).IsConverted__c != prospect.IsConverted__c)) {
                
                //This variable is to hold the comma separated fields name
                String commaSeparatedField = '';
                
                //check for all the fields
                for(String field : reqFields) {
                    
                    System.debug('prospect.get(field):::::' + prospect.get(field));
                    
                    //Check for the pipeline data
                    if(prospect.get(field) == null) {
                        
                        if(commaSeparatedField == null || commaSeparatedField == '')
                            commaSeparatedField = 'For <B><a href="/' + prospect.get('id') + '" target="_blank" >' + prospect.get('name') + '</a></B> record ' +  prospectMap.get(field).getDescribe().getLabel();
                        else
                            commaSeparatedField += ', ' + prospectMap.get(field).getDescribe().getLabel();
                    }
                }
                
                //Check for the Bid Type
                if(Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c)) {
                    
                    //check for all the fields
                    for(String field : reqFieldsForTrustee) {
                        
                        //Check for the pipeline data
                        if(prospect.get(field) == null) {
                            
                            if(commaSeparatedField == null || commaSeparatedField == '')
                                commaSeparatedField = 'For <B><a href="/' + prospect.get('id') + '" target="_blank" >' + prospect.get('name') + '</a></B> record ' +  prospectMap.get(field).getDescribe().getLabel();
                            else
                                commaSeparatedField += ', ' + prospectMap.get(field).getDescribe().getLabel();
                        }
                    }
                }
                
                //Check for the Bid Type
                if(!Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c) && !Constants.BID_TYPE_BULK_SALE.equalsIgnoreCase(prospect.Bid_Type__c)) {
                    
                    //check for all the fields
                    for(String field : reqFieldsForNonTrusteeAndNonBulky) {
                        
                        //Check for the pipeline data
                        if(prospect.get(field) == null) {
                            
                            if(commaSeparatedField == null || commaSeparatedField == '')
                                commaSeparatedField = 'For <B><a href="/' + prospect.get('id') + '" target="_blank" >' + prospect.get('name') + '</a></B> record ' +  prospectMap.get(field).getDescribe().getLabel();
                            else
                                commaSeparatedField += ', ' + prospectMap.get(field).getDescribe().getLabel();
                        }
                    }
                }
                
                //Check for the Bid Type
                if(!Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c)) {
                    
                    //check for all the fields
                    for(String field : reqFieldsForNonTrustee) {
                        
                        //Check for the pipeline data
                        if(prospect.get(field) == null) {
                            
                            if(commaSeparatedField == null || commaSeparatedField == '')
                                commaSeparatedField = 'For <B><a href="/' + prospect.get('id') + '" target="_blank" >' + prospect.get('name') + '</a></B> record ' +  prospectMap.get(field).getDescribe().getLabel();
                            else
                                commaSeparatedField += ', ' + prospectMap.get(field).getDescribe().getLabel();
                        }
                    }
                }
                
                //Add suffix
                if(commaSeparatedField != null && commaSeparatedField != '') {
                    commaSeparatedField += ' field(s) are missing.';
                    validateRequiredFieldsErrorMessage += '<BR/>' + commaSeparatedField;
                }
            }
        }
        
        //Add error on Page
        if(validateRequiredFieldsErrorMessage != null && validateRequiredFieldsErrorMessage != '') {
            
            //throw error message
            throw new CustomException(validateRequiredFieldsErrorMessage);
        }
    }

    //Line commented on 06-15-2013 for fix related to pipeline without prospect
    //public static Set<String> setPreAcquisitionCode = new Set<String>();
    
    //This method is to for Prospect to Pipeline Conversion
    public static void ProspectToPipelineConversion(List<Prospect__c> newProspect, List<Prospect__c> oldProspect) {
        
        //Get all Values for Custom Setting
        List<Property_Conversion_Maching_For_Approval__c> listPropertyConversionSetting = Property_Conversion_Maching_For_Approval__c.getall().values();
        
        //List having custom setting records related to Prospect to Pipeline Connersion
        List<Property_Conversion_Maching_For_Approval__c> listProspectCustomSetting = new List<Property_Conversion_Maching_For_Approval__c>();
        
        //Loop through Custom Setting
        for(Property_Conversion_Maching_For_Approval__c setting : listPropertyConversionSetting) {
            
            //Check for Mapping Name field value for Custom Setting
            if(setting.Mapping_Name__c == Constants.PROSPECT_TO_PIPELINE_CONVERSION) {
                
                //Populate Set with Values
                listProspectCustomSetting.add(setting);
            }
        }
        
        //Create a list of pipelines
        List<Property_Opportunity__c> pipelines = new List<Property_Opportunity__c>();
        
        //List to hold the Prospect Ids
        List<Id> listProspectIds = new List<Id>();
        
        //Create maps to hold prospect and pipeline Schema
        Map<String, Schema.SObjectField> prospectSchema = Schema.SObjectType.Prospect__c.fields.getMap();
        Map<String, Schema.SObjectField> pipelineSchema = Schema.SObjectType.Property_Opportunity__c.fields.getMap();
        
        Map<Id, Schema.RecordTypeInfo> prospectRecordTypesById          = Schema.SObjectType.Prospect__c.getRecordTypeInfosById();
        Map<String, Schema.RecordTypeInfo> pipelineRecordTypesByName    = Schema.SObjectType.Property_Opportunity__c.getRecordTypeInfosByName();
        
        // This map is used for defaulting Owner_Entity__c at conversion time
        // Note that I put the Region object in the map so we can expand it for future values
        Map<String, Region__c> regionMap = new Map<String, Region__c>();
        for (Region__c region : [select name, Owner_Entity__c from Region__c]) {
            regionMap.put(region.name, region);
        }
        
        //Loop through new records list
        for(Integer i = 0; i < newProspect.size(); i++) {
            
            //check if id exists in static set, this will prevent duplicate coversion due to field update
            if( ( !convertedProspectIds.contains(newProspect[i].Id) ) ) {
                
                //Check for Value
                if(newProspect[i].IsConverted__c == true && (oldProspect == null || newProspect[i].IsConverted__c != oldProspect[i].IsConverted__c)) {
                    //add prospect id to static set
                    convertedProspectIds.add(newProspect[i].Id);
                    
                    //Add a new record
                    Property_Opportunity__c pipeline = new Property_Opportunity__c(
                        Name = 'PIPE-' + newProspect[i].Property_Code_PreAcquisition_F__c.substring(5), // In prospect preacq starts with "PROS-"
                        Property_Code_Preacquisition__c = 'PIPE-' +  newProspect[i].Property_Code_PreAcquisition_F__c.substring(5));
                    
                    
                    //Loop through Custom Setting
                    for(Property_Conversion_Maching_For_Approval__c settingConversion : listProspectCustomSetting) {
                        
                        //Validate the mapping
                        if(prospectSchema.containsKey(settingConversion.Source_API_Name__c.toLowerCase())
                           && pipelineSchema.containsKey(settingConversion.Target_API_Name__c.toLowerCase())) {
                               
                               //Check if fied is custom and not a calculation
                               Schema.DescribeFieldResult source = ProspectSchema.get(settingConversion.Source_API_Name__c.toLowerCase()).getDescribe();
                               Schema.DescribeFieldResult target = pipelineSchema.get(settingConversion.Target_API_Name__c.toLowerCase()).getDescribe();
                               
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
                                     Object pros = newProspect[i].get(settingConversion.Source_API_Name__c.toLowerCase());
                                     
                                     //Put Value
                                     pipeline.put(settingConversion.Target_API_Name__c.toLowerCase(), pros);
                                 }
                           }
                    }
                    
                    // Added by Rajesh to map Pipeline Record Type with Prospect Record Type.
                    // Get the corresponding record type for Pipeline from Prospect.
                    if(prospectRecordTypesById.containsKey(newProspect[i].RecordTypeId)) {
                        String recordTypeName = prospectRecordTypesById.get(newProspect[i].RecordTypeId).getName();
                        if(pipelineRecordTypesByName.containsKey(recordTypeName))
                            pipeline.RecordTypeId = pipelineRecordTypesByName.get(recordTypeName).getRecordTypeId();
                    }
                    // Default the Owner_Entity__c from the Region object
                    if (regionMap.get(pipeline.Region__c) != null) {
                        pipeline.Owner_Entity__c = regionMap.get(pipeline.Region__c).Owner_Entity__c;
                    }
                    
                    //Line commented on 06-15-2013 for fix related to pipeline without prospect
                    //if(setPreAcquisitionCode.add(pipeline.Property_Code_Preacquisition__c)) {
                    
                    //Add record in list to be updated
                    pipelines.add(pipeline);
                    
                    //Line commented on 06-15-2013 for fix related to pipeline without prospect
                    //}
                    
                    //Add all Ids from Set to List
                    listProspectIds.add(newProspect[i].Id);
                    
                }
            }
        }
        
        prospectRecordTypesById = null;
        pipelineRecordTypesByName = null;
        
        //Calling Utility Class Method for Automatic Approval Submission
        Utility.autoApprovalSubmission(listProspectIds);
        
        //Check for Size
        if(pipelines.size() > 0) {
            system.debug('pipelines : ' + pipelines.size());
            system.debug('pipelines : ' + pipelines);
            
            //Insert pipelines
            upsert pipelines;
            
            //Bhavi Sharma - 08/07/2013
            //Create a Map, Key => Prospect Id and Value => Pipeline Id
            Map<Id, Id> mapProspectIdWithPipelineId = new Map<Id, Id>();
            
            //Loop through the newly created Pipeline and populate the Map
            for(Property_Opportunity__c pipeline : pipelines)
                mapProspectIdWithPipelineId.put(pipeline.Prospect__c, pipeline.Id);
            
            //Migrate Attachments from Prospect to Pipeline
            Utility.migrateAttachmentFromSourceToTarget(mapProspectIdWithPipelineId);
            
            // Added by Rajesh - 12/18/2012
            if(!listProspectIds.isEmpty()) {
                // List of Tasks to Update
                List<Task> tasksToUpdate    = new List<Task>();
                // Get the Tasks Map for the Prospects.
                Map<Id, List<Task>> prospectTasksMap = getTasksForProspects(listProspectIds);
                if(!prospectTasksMap.isEmpty()) {
                    // For each pipeline, get the corresponding Tasks from the Prospect Id
                    for(Property_Opportunity__c pipeline : pipelines) {
                        if(prospectTasksMap.containsKey(pipeline.Prospect__c)) {
                            for(Task tsk : prospectTasksMap.get(pipeline.Prospect__c)) {
                                tsk.WhatId = pipeline.Id;
                                String description = '';
                                if(tsk.Description != null)
                                    description += tsk.description;
                                description += '\r\nTransferred from Prospect.';
                                tsk.Description = description;
                                tasksToUpdate.add(tsk);
                            }
                        }
                    }
                }
                update tasksToUpdate;
                
                // List of Events to Update
                List<Event> eventsToUpdate  = new List<Event>();
                // Get the Events Map for the Prospects.
                Map<Id, List<Event>> prospectEventsMap = getEventsForProspects(listProspectIds);
                if(!prospectEventsMap.isEmpty()) {
                    // For each pipeline, get the corresponding Events from the Prospect Id
                    for(Property_Opportunity__c pipeline : pipelines) {
                        if(prospectEventsMap.containsKey(pipeline.Prospect__c)) {
                            for(Event event : prospectEventsMap.get(pipeline.Prospect__c)) {
                                event.WhatId = pipeline.Id;
                                String description = '';
                                if(event.Description != null)
                                    description += event.description;
                                description += '\r\nTransferred from Prospect.';
                                event.Description = description;
                                eventsToUpdate.add(event);
                            }
                        }
                    }
                }
                update eventsToUpdate;
            }
            
            //Create a set of prospect records
            Set<Id> prospectIds = (new Map<Id, Prospect__c>(newProspect)).keySet();
            
            /** commented By Bhavi - 12/20/2012 - This will be implemented as Inline VF Page **/
            //Map to hold all the feed items
            /*Map<Id, List<FeedItem>> mapFeedItems = new Map<Id, List<FeedItem>>();
    
            //fetch all the feed items from database and populate the map
            for(FeedItem fItem : [Select Type, Title, RelatedRecordId, ParentId, LinkUrl, LikeCount, InsertedById, ContentType, ContentSize,
            ContentFileName, ContentDescription, ContentData, CommentCount, Body From FeedItem
            where ParentId IN: prospectIds]) {
            
            //Add all feeds against each prospect record
            if(mapFeedItems.containsKey(fItem.ParentId))
            mapFeedItems.get(fItem.ParentId).add(fItem);
            else
            mapFeedItems.put(fItem.ParentId, new List<FeedItem>{fItem});
            }
            
            //create a list of feed items to be inserted
            List<FeedItem> feedItems = new List<FeedItem>();
            
            //Loop through the pipeline records
            for(Property_Opportunity__c pipeLine : pipelines) {
            
            //Get the Prospect Id from pipeline record
            //Get the all the feed items from the Map based on the prospect Id
            if(pipeLine.Prospect__c != null && mapFeedItems.containsKey(pipeLine.Prospect__c)) {
            
            //get all the feed items related to prospect and add into list after cloning
            for(FeedItem fItem : mapFeedItems.get(pipeLine.Prospect__c)) {
            
            //Create a clone and stamp pipeline Id as parent
            FeedItem clonedFeedItem = fItem.clone(false);
            clonedFeedItem.ParentId = pipeLine.Id;
            
            //Add in list to be inserted
            feedItems.add(clonedFeedItem);
            }
            }
            }
            
            //Add in list
            if(feedItems.size() > 0)
            insert feedItems;*/
            /** Up To Here  commented By Bhavi - 12/20/2012 - This will be implemented as Inline VF Page **/
        }
        
    }
    
    // Added by Rajesh - 18/12/2012
    // Function to Get Tasks for List of Prospect Ids
    public static Map<Id, List<Task>> getTasksForProspects(List<Id> prospectIds) {
        // Map to hold the Prospect Id and the list of Tasks.
        Map<Id, List<Task>> prospectTasksMap = new Map<Id, List<Task>>();
        if(prospectIds != null && prospectIds.size() > 0) {
            for(Task tsk : [Select WhatId, Description from Task where WhatId in :prospectIds]) {
                if(prospectTasksMap.containsKey(tsk.WhatId))
                    prospectTasksMap.get(tsk.WhatId).add(tsk);
                else
                    prospectTasksMap.put(tsk.WhatId, new List<Task>{tsk});
            }
        }
        return prospectTasksMap;
    }
    
    // Added by Rajesh - 18/12/2012
    // Function to Get Events for List of Prospect Ids
    public static Map<Id, List<Event>> getEventsForProspects(List<Id> prospectIds) {
        // Map to hold the Prospect Id and the list of Tasks.
        Map<Id, List<Event>> prospectEventsMap = new Map<Id, List<Event>>();
        if(prospectIds != null && prospectIds.size() > 0) {
            for(Event event : [Select WhatId, Description from Event where WhatId in :prospectIds]) {
                if(prospectEventsMap.containsKey(event.WhatId))
                    prospectEventsMap.get(event.WhatId).add(event);
                else
                    prospectEventsMap.put(event.WhatId, new List<Event>{event});
            }
        }
        return prospectEventsMap;
    }
    
    
    private static List<AggregateResult> queryPropCodes(Datetime dateOffset) {
        List<AggregateResult> listAggr = [Select Region__c region, Max(Property_Code_Preacquisition_Number_Part__c) code from Prospect__c
                                          where Property_Code_Preacquisition_Number_Part__c != null and Region__c != null
                                          and CreatedDate >: dateOffset
                                          group by Region__c];
        return listAggr;
    }
    
    // This method constructs a prospect Property_Code_Reqcquisition__c string for the given region and code number
    // Note that the number is not changed or incremented inside this method
    public class RegionException extends Exception{}
    public static String buildPropCode(String regionBase, Integer propNumber) {
        System.assert(regionBase != null && regionBase != '');
        String prefix = regionBase;
        String newNumberPart = '000000' + propNumber;
        return(regionBase.toUpperCase() + newNumberPart.right(6));
    }
    
    
    // Populate Region data for Prospect
    public static void updateRegionDataForProspect(List<Prospect__c> prospectList, Map<Id, Prospect__c> mapOldProspect) {
        Boolean needMaxPropCode = false;
        // Get the Users Region. If it is null, stop execution.
        User u = [Select IsPortalEnabled, ContactId,Profile.name, Contact.AccountId, Region__c from User where Id = :UserInfo.getUserId()];
        if(u != null && u.Region__c == null)
            return;
        
        //Set of Region which need to be excluded for Prospect :- Acquisiiton Analyst field auto update :-D-00015571
        Set<String> setRegionsToBeExcluded = new Set<String>();
        
        //Configuration Manager
        List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey(PROSPECT_ACQUISITION_ANALYST_NULL_FOR_REGION);
        
        //fill set from custom settings
        for(Configuration_Manager__c config : configs) {
            
            if(config.Parameter_Value__c != null) {
                setRegionsToBeExcluded.add(config.Parameter_Value__c.trim().toLowerCase());
            }
        }
        
        System.debug('***setRegionsToBeExcluded***:'+setRegionsToBeExcluded);
        // Map of Region with the List of Propsects.
        Map<String, List<Prospect__c>> regionProspectList = new Map<String, List<Prospect__c>>();
        // For all Prospects having a Region, add the Prospect to the Map with the Region as the Key
        for(Prospect__c prospect : prospectList) {
            
            if (prospect.Region__c == null || prospect.Region__c == '') {
                prospect.Region__c = u.Region__c;
            }
            
            //Check if this is an update case and Region has been updated on Prospect
            if(mapOldProspect != null) {
                
                if(prospect.Region__c != mapOldProspect.get(prospect.Id).Region__c && prospect.IsConverted__c == false) {
                    
                    //Nullify some required field. These will be re-populated as per teh updated region
                    prospect.Region_Lookup__c = null;
                    prospect.Division__c = null;
                    prospect.Transaction_Coordinator__c = null;
                    prospect.Acquisitions_Team_Manager__c = null;
                    //prospect.M1_Expense_Margin_Est_UW__c = null;
                    
                } else {
                    
                    //Region data din't change. No need to process this record. Move on to the next record
                    continue;
                }
            }
            
            if(prospect.Region__c != null) {
                if(regionProspectList.containsKey(prospect.Region__c))
                    regionProspectList.get(prospect.Region__c).add(prospect);
                else
                    regionProspectList.put(prospect.Region__c, new List<Prospect__c>{prospect});
            }
            
        }
        
        // For every Region in the KeySet, update the correponding details from Region to Prospect.
        for(Region__c region : [Select Transaction_Coordinator__c, Name, Division__c, Property_Code_Base__c,  Acquisition_Team_Manager__c,
                                IH_REO_Manager__c, IH_REO_Manager__r.Name, M1_Expense_Margin_Fund1__c, M1_Expense_Margin_Fund2__c,
                                Prospect_Occupied_Status_Acquisition__c,Default_Title_Company__c
                                From    Region__c
                                where   Name in :regionProspectList.keySet()]) {
                                    
            if(regionProspectList.containsKey(region.Name)) {
                
                for(Prospect__c prospect : regionProspectList.get(region.Name)) {
                    // Set the Region Lookup
                    prospect.Region_Lookup__c = region.id;
                    // Update Transaction Co-ordinator
                    if(region.Transaction_Coordinator__c != null)
                        prospect.Transaction_Coordinator__c = region.Transaction_Coordinator__c;
                    // Update Division
                    if (region.Division__c != null && prospect.Division__c == null)
                        prospect.Division__c = region.Division__c;
                    // Update Team Manager
                    if (region.Acquisition_Team_Manager__c != null && prospect.Acquisitions_Team_Manager__c == null)
                        prospect.Acquisitions_Team_Manager__c = region.Acquisition_Team_Manager__c;
                    // Update Point of Contact
                    if(region.IH_REO_Manager__c != null)
                        prospect.B_IH_Point_of_Contact__c = region.IH_REO_Manager__r.Name;
                    // Update M1 Expense Margin Est UW - Condition updated by Rajesh as per SIR 4300 (05/06/2013)
                    /**if(region.Name.toUpperCase() != 'CHICAGO' && region.M1_Expense_Margin_Fund2__c != null)
                        prospect.M1_Expense_Margin_Est_UW__c = region.M1_Expense_Margin_Fund2__c;**/
                    
                    // For 'Brokersite Portal' users (Authenticated Licenses)
                    if (u.IsPortalEnabled && u.Profile.name == 'Brokersite portal') {
                        if (region.IH_REO_Manager__c != null) {
                            // Brokersite prospects need to be owned by internal profile folks
                            prospect.OwnerId = region.IH_REO_Manager__c;
                            // If user is Portal or Brokersite, default the Acquisitions Analyst
                            //comment out this field as per D-00015138 
                            prospect.Acquisitions_Analyst__c = region.IH_REO_Manager__c;
                        }
                        // BrokerSite portal users choose the B_Bid_Type__c and we copy it to Bid Type
                        if (prospect.Bid_Type__c == null) {
                            prospect.Bid_Type__c = prospect.B_Bid_Type__c;
                        }
                        // Set the IH_Agent_Contact to be the current user's Contact record
                        if (u.IsPortalEnabled && u.ContactId != null) {
                            prospect.IH_Agent_Contact__c = u.ContactId;
                        }
                        //Acquisition Analyst should be vacant for regions in setRegionsToBeExcluded
                        if(setRegionsToBeExcluded.contains(region.Name.toLowerCase())){
                            prospect.Acquisitions_Analyst__c = null;
                        }
                    }
                    // Now handle code for Communities/Customer Portal licenses
                    if (u.IsPortalEnabled && u.Profile.name != 'Brokersite portal') {
                        if (region.IH_REO_Manager__c != null) {
                            // If user is Portal or Brokersite, default the Acquisitions Analyst
                            //comment out this field as per D-00015138 
                            prospect.Acquisitions_Analyst__c = region.IH_REO_Manager__c;
                        }
                        
                        // Communities/Customer Portal users set Bid Type in "New Prospect" form, so we set their B_Bid_Type__c from that here
                        if (prospect.B_Bid_Type__c == null) {
                            prospect.B_Bid_Type__c =  prospect.Bid_Type__c;
                        }
                        // Default the IH_Agent_Contact to be the current user's Contact record and set the Brokerage
                        if (u.IsPortalEnabled && u.ContactId != null) {
                            prospect.IH_Agent_Contact__c = u.ContactId;
                            prospect.Brokerage__c = u.Contact.AccountId;
                        }
                        //Acquisition Analyst should be vacant for regions in setRegionsToBeExcluded
                        if(setRegionsToBeExcluded.contains(region.Name.toLowerCase())){
                            prospect.Acquisitions_Analyst__c = null;
                        }
                    }
                   // Code for Portal Enabled User :- D-00016192
                   if(u.IsPortalEnabled){
                      prospect.Title_Company__c = region.Default_Title_Company__c !=null?region.Default_Title_Company__c :null;
                      prospect.Occupied_Status_Acquisition__c = (region.Prospect_Occupied_Status_Acquisition__c != null && region.Prospect_Occupied_Status_Acquisition__c != '')? region.Prospect_Occupied_Status_Acquisition__c : null;
                   }
                }
            }
        }
    }
    
    //Validate date field
    public static void validateAllDateField(List<SObject> sObjects) {
        
        Set<String> fieldNotAllowedToHoldFutureDate = Constants.PROSPECT_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE;
        
        //Describe Prospect object
        Schema.DescribeSObjectResult prospectObject = Prospect__c.sObjectType.getDescribe();
        
        //Describe Prospect object and get all the fields
        Map<String, Schema.SObjectField> prospectFieldsMap = prospectObject.fields.getMap();
        
        //loop through the records
        for(SObject sObj : sObjects) {
            
            //Loop through the fields name
            for(String fName : prospectFieldsMap.keySet()) {
                
                //Describe field
                Schema.DescribeFieldResult field = prospectFieldsMap.get(fName).getDescribe();
                
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
    
    //If prospect Creator is a Customer Portal User, Fetch the User's role.
    //and then share current Prospect record with User's Role. All the broker users, associated with the account, will be having the same role.
    //So adding a sharing rule with that, will give them access on the Prospect record
    public static void shareProspectWithCoworkers(List<Prospect__c> prospects) {
        
        //Create a set of CreatorIds
        Set<Id> createdByIds = new Set<Id>();
        
        //Loop through the Prospect and populate the CreatorIds set
        for(Prospect__c prospect : prospects) {
            
            //add Creator in Set
            createdByIds.add(prospect.CreatedById);
        }
        
        //Create a map to hold the CreatorName with RoleId
        Map<Id, Id> mapCreatorWithRoleId= new Map<Id, Id>();
        
        //Fetch Creator's account infomarmation from database
        for(User user : [Select UserRoleId from User where Id IN: createdByIds AND Profile.UserLicense.Name != 'Authenticated Website'
                         AND IsPortalEnabled = true AND UserRoleId != null]) {
                             
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
        
        //Check if map has values to process
        if(mapRoleIdWithGroupId.size() > 0) {
            
            //Create a List of sharing records
            List<Prospect__Share> shares = new List<Prospect__Share>();
            
            //Loop through the Prospect Records and Create the Prospect__Share record with the Prospect and Appropriate Role
            for(Prospect__c prospect : prospects) {
                
                //Get the Group Id from mapGroupNameWithId map
                if(mapCreatorWithRoleId.containsKey(prospect.CreatedById)) {
                    
                    //RoleId
                    Id roleId = mapCreatorWithRoleId.get(prospect.CreatedById);
                    
                    //Group Id
                    Id groupId = mapRoleIdWithGroupId.get(roleId);
                    
                    //Create a Prospect Share record for role Id
                    shares.add(new Prospect__Share(ParentId = prospect.Id, AccessLevel = 'Edit', UserOrGroupId = groupId));
                }
            }
            
            //Check for the shares records
            if(shares.size() > 0)
                insert shares;
        }
    }
    
    //Added by Poonam Bhargava - 11/03/2017
    /** 
     * @description    :   Method to populate SWAY checkbox on Residence if the Prospect Record Type is 'New Build'  
     *
     * @arg            :    List<Prospect__c> newProspect, List<Prospect__c> oldProspect   
     *
     * @return         :    void  
     * 
    **/
    public static void markedSWAYonResidence(List<Prospect__c> newProspect){
      
        //Set to hold the residence Ids
        Set<Id> setResidenceIDs = new Set<Id>();
        
        //List to hold the residence records to be updated
        List<Residence__c> residencesToBeUpdated = new List<Residence__c>();
        
        //Loop over the new upcomming prospect to check its recordType and update the residence field SWAY accordinglly 
        for(Prospect__c pS : [Select Id, RecordType.DeveloperName, Residence__c, Residence__r.SWAY__c from Prospect__c where Id IN : newProspect]) {
            
                //Check for eligible criteria on Propsect and Populatee REsidece record accordingly 
                if(pS.Residence__c != null  &&  pS.RecordType.DeveloperName == 'New_Build' && !pS.Residence__r.SWAY__c && !setResidenceIDs.contains(pS.Residence__c)) {
                    
                    //Populate the Residence list to be upated 
                    residencesToBeUpdated.add(new Residence__c(Id = pS.Residence__c, SWAY__c = true));
                    
                    //Populate set with the Residence Ids
                    setResidenceIDs.add(pS.Residence__c);
                }
        }
        
        //Check for size of list to be updated and perform update operation on Residence
        if(residencesToBeUpdated.size() > 0)
            update residencesToBeUpdated;
    }  
}