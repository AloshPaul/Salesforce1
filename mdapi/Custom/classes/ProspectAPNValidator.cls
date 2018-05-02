/**
 *   Description  :  This class is to validate the APN and address for new prospect record.
 *
 *   Created By   :  Abhinav Sharma
 *
 *   Created Date:  01/04/2013
 *
 *   Revision Logs:     V1.0 - Created
 *                      V1.0 - Bhavi
 *                      v1.1 - Modified :-Remove a commented line of method createNewProspectWithValidatedValues- D -00015571
 **/
 //Class
 public with sharing class ProspectAPNValidator {

    /*Generic variables helpful in implementation of address validation functionality*/

    //List of wrapper class to hold the record Type details
    public List<RecordTypeWrapper> recordTypes {get; set;}

    //String to hold the apn value
    String apnValue;

    //Pagereference going to be held redirection URL and State Lookup Text Value
    PageReference pageRef;

    //Prospect Instance
    public Prospect__c prospect {get; set;}
    public Prospect__c newlyCreatedProspect {get; set;}

    //Variable to hold the address fields
    public String street {get; set;}
    public String addressUnit{get; set;}
    public String city {get; set;}
    public String zip {get; set;}
    String stateName;

    //Variable useful for populating State lookup field
    public String stateText {get; set;}
    public String stateId {get; set;}

    //List to hold the response
    List<IHSmartyStreetsService.ValidateAddressResponse> response;

    /*Boolean variables helpful in decision making and rendering on page*/

    //Flag value set to true if Prospect APN is unique
    public Boolean isProspectEligible {get; set;}

    //Flag to control the reRendering of related lists on same APN value
    public Boolean showRelatedRecords {get; set;}

    //Flag to control the reRendering of address field in input or Output mode
    public Boolean showInReadOnlyMode {get; set;}

    //Flag to control the reRendering of "Allow Duplicate" button on page
    public Boolean enableAllowDuplicateOnSameAPN {get; set;}

    //Flag to control the reREndering of "Address Duplicate" button on page
    public Boolean enableAllowAddressDuplicate {get; set;}

    //Flag to control the reRendering of lists and buttons for Brokers
    public Boolean hideListAndButtons {get; set;}

    //Boolean variable to control the rerendering of override button
    public Boolean showOverrideButton {get; set;}

    //Boolean variable to control the flow and rendering when residence is there with APN but do not have children records
    public Boolean residenceWithApnAndNotHaveAnyChildren {get; set;}

    //Boolean variable helpful in skipping of address validation.
    //When residence associated with the APN is validated and do not have any children records on it
    public Boolean isSkipAddressValidation {get; set;}

    //Boolean variable helpful in making several exception/decision for override case
    Boolean isOverrideHappens;

    /*List to hold the records which are going to display on page */

    //List going to be hold Prospect record with same APN
    public List<Prospect__c> prospects {get; set;}

    //List going to be hold Pipeline record with same APN
    public List<Property_Opportunity__c> pipelines {get; set;}

    //List going to be hold Portfolio record with same APN
    public List<Property__c> properties {get; set;}

    //List going to hold residence records
    public List<Residence__c> residences {get; set;}

    //Standard Controller
    public ProspectAPNValidator(ApexPages.StandardController controller) {

        //Get record for Prospect
        prospect = (Prospect__c)controller.getRecord();

        //Memory Allocation
        residences = new List<Residence__c>();
        newlyCreatedProspect = new Prospect__c();

        //Caling Method for getting RecordTypeIdWithName based on user profiles for sObject
        Map<Id,String> mapRecordTypeName = Utility.GetAvailableRecordTypesForSObject(prospect.getSobjectType());

        //Populate the set with record type id
        Set<Id> setRecordTypeId = mapRecordTypeName.keySet();

        //Setting default value for the flags
        isProspectEligible = false;
        showRelatedRecords = false;
        showInReadOnlyMode = false;
        enableAllowDuplicateOnSameAPN = false;
        enableAllowAddressDuplicate = false;
        hideListAndButtons = false;
        showOverrideButton = false;
        isOverrideHappens = false;
        residenceWithApnAndNotHaveAnyChildren = false;
        isSkipAddressValidation = false;

        //Checking Current logged in user for poratl user
        hideListAndButtons  = [select ID, IsPortalEnabled from User where Id = :Userinfo.getUserId()].IsPortalEnabled;

        //Memory allocation to wrapper list
        recordTypes = new List<RecordTypeWrapper>();

        //Loop through record types associated with prospect records
        for(RecordType rType : [Select ID, Name, SobjectType, Description From RecordType where ID IN : setRecordTypeId AND isActive = true]) {

            //Add values in list
            recordTypes.add(new RecordTypeWrapper(rType.Name, rType.Description));
        }
    }

    //Method going to be call when user will click on continue button
    public Pagereference continueCheck() {

        //Setting User region default value
        prospect.Region__c = Utility.currentLoggedInUserRegionValue(UserInfo.getUserId());

        //String to hold the APN with removal of special charector
        apnValue = Utility.removeExceptAlphaNumeric(prospect.APN__c);

        //Populating APN field with appropriate value
        prospect.APN__c = apnValue;

        //Setting flags values
        showRelatedRecords = false;
        enableAllowDuplicateOnSameAPN = false;
        residenceWithApnAndNotHaveAnyChildren = false;

        //Call Method for getting status for APN field value
        isProspectEligible = ResidenceService.isProspectEligible(apnValue);

        //If APN is valid then redirect to edit page with APN and Record Type populated with value
        if(!isProspectEligible) {

            //Checking residence record for children records presence if it have value in APN field.
            residenceWithApnAndNotHaveAnyChildren = ResidenceService.isResidenceIsThereWithoutChildren(apnValue);

            //Checking if residence record have children on it when APN value is already there on it
            if(residenceWithApnAndNotHaveAnyChildren) {

                //List going to the residence record
                residences = [SELECT ID, APN_Unique__c, Name, Address_Street__c, Address_Unit__c, Address_City__c, Address_Zip_Code__c, Address_State__c,
                                Address_Validated_Zip__c, Address_Validated_Street__c, County__c, Address_Validated_City__c, Address_Validated_Successfully__c
                                FROM Residence__c Where APN_Unique__c =: apnValue Limit 1];

                //Check list for size
                if(residences.size() > 0) {

                    //Checking for prior validation of residence record
                    if(residences[0].Address_Validated_Successfully__c) {

                        //Setting flag values
                        isProspectEligible = true;
                        enableAllowDuplicateOnSameAPN = false;
                        showRelatedRecords = false;
                        showInReadOnlyMode = true;
                        isSkipAddressValidation = true;

                        //Setting value in address fields
                        street = residences[0].Address_Street__c;
                        addressUnit = residences[0].Address_Unit__c;
                        city = residences[0].Address_City__c;
                        zip = residences[0].Address_Zip_Code__c;
                        prospect.Property_State__c = Utility.retrieveIdOnTheBasisOfStateName(residences[0].Address_State__c);
                        prospect.Property_County__c = residences[0].County__c;

                    } else {

                        //Setting flag values
                        isProspectEligible = false;
                        enableAllowDuplicateOnSameAPN = false;
                        showRelatedRecords = false;

                        //Adding error message on page
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.ERROR_APN_VALIDATION_INVALID_RESIDENCE));

                    }
                }

            } else {

                //If user not a customer portal user
                if(!hideListAndButtons) {

                    //Setting Flag
                    showRelatedRecords = true;
                    enableAllowDuplicateOnSameAPN = true;

                    //Query to get Prospect data
                    prospects = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Property_State_Text__c, Prospect_Status__c, Bid_type__c, LastModifiedBy.ID , LastModifiedBy.Name,LastModifiedDate, CreatedDate From Prospect__c WHERE APN__c =:apnValue];

                    //Query to get Pipeline data
                    pipelines = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Bid_type__c , Stage__c , LastModifiedBy.ID , LastModifiedBy.Name, LastModifiedDate, CreatedDate From Property_Opportunity__c WHERE APN__c =:apnValue];

                    //Query to get Property data
                    properties = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Property_Status__c,  Bid_type__c, LastModifiedBy.ID , LastModifiedBy.Name, LastModifiedDate, CreatedDate From Property__c WHERE APN__c =:apnValue];

                }

                //Error Message going to be displayed in case of duplicate APN
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ProspectTriggerHelper.ELIGIBILITY_ERROR_MESSAGE));
            }

        } else {

            //Check for SmartyStreets Status value
            if(IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.STATUS_OFF && prospect.APN__c == null) {

                //Setting the Page Reference
                pageRef = new PageReference('/a0n/e?retURL=%2Fa0n%2Fo&RecordType=' + prospect.RecordTypeId + '&ent=01IE0000000CO5k'+ '&nooverride=1');

            } else if(prospect.APN__c != null && IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.STATUS_OFF) {

                //Setting value for PageReference
                pageRef = new PageReference('/a0n/e?retURL=%2Fa0n%2Fo&RecordType=' + prospect.RecordTypeId + '&ent=01IE0000000CO5k' + '&00NE00000043OOS=' + apnValue+ '&nooverride=1');

            } else {

                //Seting flags values
                isProspectEligible = true;
                enableAllowDuplicateOnSameAPN = false;
            }
        }

        //Return Pagereference
        return pageRef;
    }

    //Method for allowing duplicate APN field value
    public PageReference allowDuplicates() {

        //Set the flag
        isProspectEligible = true;
        enableAllowDuplicateOnSameAPN = false;

        //Check for the Smarty Streets status
        if(IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.STATUS_ON || IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.SANDBOX) {

            //Set the flag for Read Only Address fields
            showInReadOnlyMode = true;

            //List going to the residence record
            residences = [SELECT ID, APN_Unique__c, Name, Address_Street__c, Address_Unit__c, County__c, Address_City__c, Address_Zip_Code__c, Address_State__c
                            FROM Residence__c Where APN_Unique__c =: Utility.removeExceptAlphaNumeric(prospect.APN__c) Limit 1];

            //Check list for size
            if(residences.size() > 0) {

                //Setting value in address fields
                street = residences[0].Address_Street__c;
                addressUnit = residences[0].Address_Unit__c;
                city = residences[0].Address_City__c;
                zip = residences[0].Address_Zip_Code__c;
                prospect.Property_State__c = Utility.retrieveIdOnTheBasisOfStateName(residences[0].Address_State__c);
                prospect.Property_County__c = residences[0].County__c;
            }

        } else {

          //Setting value for PageReference
          pageRef = new PageReference('/a0n/e?retURL=%2Fa0n%2Fo&RecordType=' + prospect.RecordTypeId + '&ent=01IE0000000CO5k' + '&00NE00000043OOS=' + apnValue+ '&nooverride=1');

        }

        //return value
        return pageRef;
    }

    //Method to call the Smarty Streets web service for Address validation
    public PageReference continueCheckForAddress() {

        //Checking for values
        if(street == null || street == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.PROSPECT_STREET_REQUIRED));
        }

        //Checking for values
        if(city == null || city == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.PROSPECT_CITY_REQUIRED));
        }

        //Checking for values
        if(zip == null || zip == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.PROSPECT_ZIP_REQUIRED));
        }

        if(ApexPages.hasMessages(ApexPages.Severity.Error))
            return null;

        //Getting State field value
        if(isProspectEligible == true && showInReadOnlyMode == true) {

            //Populate State Name String with value
            stateName = Utility.retrieveStateNameOnTheBasisOfID(prospect.Property_State__c);

        } else {

            //Populate State Name String with value
            stateName = stateText;
        }

        //Checking value of flag responsible for skipping of address validation before new prospect creation
        if(isSkipAddressValidation) {

            //Insert New Prospect with validated address fields values
            newlyCreatedProspect = createNewProspectWithValidatedValues(prospect.APN__c, street, city, Utility.retrieveIdOnTheBasisOfStateName(stateName), zip, '', prospect.Property_County__c, Prospect.Bid_Type__c, prospect.Region__c, null, null);

            //Checking user is of "Broker Customer Type" or not
            if(hideListAndButtons) {

                //Setting Pagereference for customer portal user
                pageRef = new PageReference('/apex/CustomerPortalProspect?Id='+ newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId);

            } else {

                //Setting Pagereference
                pageRef = new PageReference('/'+newlyCreatedProspect.Id + '/e?retURL=' + + newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId +'&nooverride=1');
            }

        } else {

            //Create a list of request
            List<IHSmartyStreetsService.ValidateAddressRequest> requests  = new List<IHSmartyStreetsService.ValidateAddressRequest>();

            //Add your address data in list
            requests.add(new IHSmartyStreetsService.ValidateAddressRequest(null, street, city, stateName, zip));

            //Call validate method
            SmartyStreetStub stub = new SmartyStreetStub();

            //Check for SmartyStreets Status value
            if(IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.STATUS_ON) {
                response = stub.doValidate(requests);
            }
            else if(IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.SANDBOX) {
                response = stub.doValidateForSandbox(requests);
            }

            //Check for response
            if(response[0].validateSuccess == false) {

                //Setting flag value
                showOverrideButton = true;

                //Message on the Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.RESIDENCE_WITH_NON_VALIDATED_ADDRESS));

            } else {

                //Validation SmartyStreet Corrected data with residence records pre-exists in database
                if(ResidenceService.isProspectEligible(addressUnit, response[0].street.trim(), response[0].city.trim(), stateName.trim(), response[0].zip.trim())) {

                    //Insert New Prospect with validated address fields values
                    newlyCreatedProspect = createNewProspectWithValidatedValues(prospect.APN__c, response[0].street, response[0].city, Utility.retrieveIdOnTheBasisOfStateName(stateName), response[0].zip, response[0].zipPlus4, response[0].county, Prospect.Bid_Type__c, prospect.Region__c, response[0].latitude, response[0].longitude);

                    //If user is not a cudtomer portal user then redirect to prospect edit page
                    if(!hideListAndButtons) {

                        //Setting Pagereference
                        pageRef = new PageReference('/'+newlyCreatedProspect.Id + '/e?retURL=' + + newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId +'&nooverride=1');

                    } else {

                        //Setting Pagereference for customer portal user
                        pageRef = new PageReference('/apex/CustomerPortalProspect?Id='+ newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId);
                    }

                 } else {

                    //If current user is not a Customer portal user
                    if(!hideListAndButtons) {

                        //Set value of flag
                        enableAllowAddressDuplicate = true;
                        showRelatedRecords = true;

                        //Set to hold the residences Id
                        Set<Id> setResidenceIds = new Set<Id>();

                        //Select Residence record having same address
                        for(Residence__c residence : [Select ID, APN_Unique__c From Residence__c
                                                        Where Address_Validated_Street__c =: response[0].street.trim()]) {

                            //Populating set with the values
                            setResidenceIds.add(residence.ID);
                        }

                        //Query to get Prospect data
                        prospects = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Property_State_Text__c,
                                Prospect_Status__c, Bid_type__c, LastModifiedBy.ID , LastModifiedBy.Name, LastModifiedDate, Address_Validated_Street__c,
                                Address_Validated_City__c, Address_Validated_State__c, Address_Validated_Zip__c, CreatedDate, Residence__c From Prospect__c
                                    WHERE Residence__c IN : setResidenceIds];

                        //Query to get Pipeline data
                        pipelines = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Bid_type__c , Stage__c ,
                                    LastModifiedBy.ID , LastModifiedBy.Name, LastModifiedDate, CreatedDate, Residence__c From Property_Opportunity__c
                                    WHERE Residence__c IN : setResidenceIds];

                        //Query to get Property data
                        properties = [Select Id , APN__c, Name, Property_Street__c , Property_City__c , Property_State__c, Property_Status__c,
                                        Bid_type__c, LastModifiedBy.ID , LastModifiedBy.Name, LastModifiedDate, CreatedDate , Residence__c From Property__c
                                        WHERE Residence__c IN : setResidenceIds];

                    }

                    //Message on the Page
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.RESIDENCE_WITH_SAME_ADDRESS));
                }
            }
        }

        //Return Pagereference
        return pageRef;
    }

    //Method for allowing duplicate APN field value
    public PageReference allowDuplicateWithSameAddress() {

        //Set the flag
        enableAllowAddressDuplicate = true;

        //Check for the Smarty Streets status
        if(IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.STATUS_ON || IHSmartyStreetsService.getSmartyStreetsStatus() == Constants.SANDBOX) {

            //Check for response
            if(response[0].validateSuccess == false) {

                //Message on the Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.NEW_PROSPECT_ADDRESS_ERROR));

            } else {

                //Insert New Prospect with validated address fields values
                newlyCreatedProspect = createNewProspectWithValidatedValues(prospect.APN__c, response[0].street, response[0].city, Utility.retrieveIdOnTheBasisOfStateName(stateName), response[0].zip, response[0].zipPlus4, response[0].county, Prospect.Bid_Type__c, prospect.Region__c, response[0].latitude, response[0].longitude);

                //Setting Pagereference
                pageRef = new PageReference('/'+newlyCreatedProspect.Id + '/e?retURL=' + + newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId +'&nooverride=1');

            }
        }

        //Return Pagereference
        return pageRef;
    }

    //Method having logic for Override button
    public Pagereference overrideAddress() {

        //Check for flag value
        if(showOverrideButton) {

            //Setting flag value
            isOverrideHappens = true;

            //Insert New Prospect with validated address fields values
            newlyCreatedProspect = createNewProspectWithValidatedValues(prospect.APN__c, street, city, Utility.retrieveIdOnTheBasisOfStateName(stateName), zip, response[0].zipPlus4, response[0].county, Prospect.Bid_Type__c, prospect.Region__c, response[0].latitude, response[0].longitude);

            //Setting Pagereference
            pageRef = new PageReference('/'+newlyCreatedProspect.Id + '/e?retURL=' + + newlyCreatedProspect.Id + '&RecordType=' + prospect.RecordTypeId +'&nooverride=1');

            //Return Pagereference
            return pageRef;
        }

        //Return
        return null;
    }

    //Method to create New Prospect with all required fields
    public Prospect__c createNewProspectWithValidatedValues(String validatedAPN, String validatedStreet, String validatedCity, ID validatedStateID, String validatedZIP, String validatedZIP4, String validatedCounty, String validatedBidType, String validatedRegion, Decimal validatedlat, Decimal validatedlon) {

      //Insert new Prospect record
      Prospect__c newProspect = new Prospect__c();

      //Checing APN for null
      if(validatedAPN != null) {
        newProspect.APN__c = validatedAPN;
      } else {
        newProspect.APN__c = '';
      }

      //Populating Prospect fields with values

      //If user clicks on Allow duplicate address button then populate Property street field with validated value
      if(enableAllowAddressDuplicate) {
          newProspect.Property_Street__c = validatedStreet;
      } else {
          newProspect.Property_Street__c = street;
      }

      newProspect.Address_Unit__c = addressUnit;
      newProspect.Property_City__c = validatedCity;
      newProspect.Property_State__c = validatedStateID;
      newProspect.Property_Zip_Code__c = validatedZIP;
      newProspect.Zip_Plus_4__c = validatedZIP4;
      newProspect.Property_County__c = validatedCounty;

      //Checking for flag value
      if(isOverrideHappens) {

            newProspect.Address_Validated_Street__c = null;
            newProspect.Address_Validated_City__c = null;
            newProspect.Address_Validated_State__c = null;
            newProspect.Address_Validated_Zip__c = null;
            newProspect.Address_Validated_County__c = null;
            newProspect.Geolocation__Latitude__s = null;
            newProspect.Geolocation__Longitude__s = null;
            newProspect.Address_Validated_Successfully__c = false;
            newProspect.Address_Validated_Last_Attempt__c = Datetime.newinstance(System.now().date(),System.now().time());

      } else {

          newProspect.Address_Validated_Street__c = validatedStreet;
          newProspect.Address_Validated_City__c = validatedCity;
          newProspect.Address_Validated_State__c = stateName;
          newProspect.Address_Validated_Zip__c = validatedZIP;
          newProspect.Address_Validated_County__c = validatedCounty;
          newProspect.Geolocation__Latitude__s = validatedlat;
          newProspect.Geolocation__Longitude__s = validatedlon;
          newProspect.Address_Validated_Successfully__c = true;
          newProspect.Address_Validated_Last_Attempt__c = Datetime.newinstance(System.now().date(),System.now().time());

      }

      newProspect.Bid_Type__c = validatedBidType;
      newProspect.Region__c = validatedRegion;
      //UnCommented Based on SIR  D -00015571
      newProspect.Acquisitions_Analyst__c = Userinfo.getUserId();
      insert newProspect;

      //Return Prospect
      return newProspect;
    }

    //Wrapper class for record type
    public class RecordTypeWrapper {

        //Variable to hold record type Name and Description
        public String RecordTypeName {get; set;}
        public String RecordTypeDescription {get; set;}

        //Constructor of wrapper class
        public RecordTypeWrapper(String RecordTypeName,String RecordTypeDescription) {

            this.RecordTypeName = RecordTypeName;
            this.RecordTypeDescription = RecordTypeDescription;
        }
    }
}