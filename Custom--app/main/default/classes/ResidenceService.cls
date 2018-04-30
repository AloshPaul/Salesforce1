/**
 *  Description :   Residence Service Claas
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   03/06/2013
 *
 *  Revision Logs:  V1.0 - Created
 *          V1.1 - Added a new method (residenceExists) - D-00004835
 *
 *
 **/
 global without sharing class ResidenceService {

    private static Prospect__c prospect;
    private static Boolean moreThanOneProspect = false;

    private static Prospect__c getProspect(Id prospectId) {

        if(prospect == null) {
            SYstem.debug('Prspect: ' + prospect);
            List<Prospect__c> prospectList = [Select Id,
                                              Subdivision__c,
                                              Baths__c,
                                              APN__c,
                                              Bedrooms__c,
                                              Property_Street__c,
                                              Address_Unit__c,
                                              Property_Zip_Code__c,
                                              Property_City__c,
                                              Property_State__c,
                                              Property_State__r.Name,
                                              Property_County__c,
                                              HOA_Options__c,
                                              HOA__c,
                                              HOA_Phone__c,
                                              Parking__c,
                                              Pool__c,
                                              Property_Type__c,
                                              Roof_Type__c,
                                              Square_Feet__c,
                                              Year_Built__c,
                                              AC_or_Evap__c,
                                              Lot_Sq_Ft__c,
                                              Region__c,
                                              Market__c,
                                              Property_Cross_Streets__c,
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
                                              From Prospect__c Where Id =: prospectId];


             if(prospectList.size() == 0) {
                throw new CustomException('No prospect record found.');
             }
             else {

                prospect = prospectList.get(0);
                Set<String> statusToIgnore = new Set<String>{'Dead - Declined',
                                                               'Dead - Cancelled',
                                                               'Dead - Duplicate',
                                                               'Dead - No Activity'
                                                                                     };

                List<Prospect__c> prospectListForSameResidence = [Select id
                                                                  From Prospect__c
                                                                  Where Residence__c =: prospect.Residence__c
                                                                  And Id !=: prospect.id
                                                                  And Prospect_Status__c Not In: statusToIgnore
                                                                  Limit 1];

                List<Property_Opportunity__c> pipelinesForResidence = [Select Id
                                                                       From Property_Opportunity__c
                                                                       Where Residence__c =: prospect.Residence__c Limit 1];

                List<Property__c> propertiesForResidence = [Select Id
                                                            From Property__c
                                                            Where Residence__c =: prospect.Residence__c Limit 1];
                moreThanOneProspect = (prospectListForSameResidence.size() > 0 || pipelinesForResidence.size() > 0 || propertiesForResidence.size() > 0);
            }
        }

        return prospect;
    }


    //Method to update residence
    webservice static String refreshResidenceFromProspect(String prospectId) {
        return updateResidenceFromProspect(prospectId);
    }


    //Method to update residence
    public static String updateResidenceFromProspect(String prospectId) {
        getProspect(prospectId);
        if(moreThanOneProspect) {
            return 'The residence cannot be updated via the button because there is more than one prospect, pipeline or portfolio record associated with the residence.';
        }
        else {

            if(prospect.Residence__c == null) {
                return 'No residence found for the prospect.';
            }
            else {

                    Residence__c res = (Residence__c) Utility.selectStar(new List<Id>{prospect.Residence__c}).get(0);
                    if(isUpdatable(res, prospect)) {

                        res = populateResidence(res, prospect);
                        try {
                            update res;
                        }
                        catch(Exception e) {
                            System.debug('Following Exception occurred: ' + e.getMessage());
                            throw e;
                        }

                        return 'Updated Successfully';
                    }
                    else {
                        return 'All fields are similar on residence';
                    }
            }
        }

        return '';
    }

    public static Residence__c populateResidence(Residence__c res, Prospect__c pros) {
        return populateResidence(res, pros, null);
    }

    public static Residence__c populateResidence(Residence__c res, Prospect__c pros, Map<Id, State__c> mapState) {
        res = new Residence__c( Id = res.Id,
                                Baths__c = pros.Baths__c,
                                Subdivision__c = pros.Subdivision__c,
                                Bedrooms__c = pros.Bedrooms__c,
                                Address_Street__c = pros.Property_Street__c,
                                Address_Unit__c = pros.Address_Unit__c,
                                Address_Zip_Code__c = pros.Property_Zip_Code__c,
                                Address_City__c = pros.Property_City__c,
                                APN__c = pros.APN__c,
                                Address_State__c = ((mapState != null && mapState.containsKey(pros.Property_State__c)) ? mapState.get(pros.Property_State__c).Name : pros.Property_State__r.Name),
                                County__c = pros.Property_County__c,
                                HOA_Options__c = pros.HOA_Options__c,
                                HOA__c = pros.HOA__c,
                                HOA_Phone__c = pros.HOA_Phone__c,
                                Parking__c = pros.Parking__c,
                                Pool__c = pros.Pool__c,
                                Property_Type__c = pros.Property_Type__c,
                                Roof_Type__c = pros.Roof_Type__c,
                                Square_Feet__c = pros.Square_Feet__c,
                                Year_Built__c = pros.Year_Built__c,
                                AC_or_Evap__c = pros.AC_or_Evap__c,
                                Cross_Streets__c = pros.Property_Cross_Streets__c,
                                Region__c = pros.Region__c,
                                Lot_Sq_Ft__c = pros.Lot_Sq_Ft__c,
                                Address_Validated_City__c = pros.Address_Validated_City__c,
                                Address_Validated_County__c = pros.Address_Validated_County__c,
                                Address_Validated_Last_Attempt__c = pros.Address_Validated_Last_Attempt__c,
                                Address_Validated_State__c = pros.Address_Validated_State__c,
                                Address_Validated_Street__c = pros.Address_Validated_Street__c,
                                ZipPlus4__c = pros.Zip_Plus_4__c,
                                Location__Latitude__s = pros.Geolocation__Latitude__s,
                                Location__Longitude__s = pros.Geolocation__Longitude__s,
                                Address_Validated_Successfully__c = pros.Address_Validated_Successfully__c,
                                Address_Validated_Zip__c = pros.Address_Validated_Zip__c,
                                Address_Validation_Message__c = pros.Address_Validation_Message__c,
                                Market__c = pros.Market__c);  //Added By Poonam Bhargava - D-00017166

        if(res.id == null) {
            res = res.clone(false);
        }
        return res;
    }

    //method to find if residence needs to be updated
    private static boolean isUpdatable(Residence__c res, Prospect__c pros) {
        Boolean isUpdatable = false;
        isUpdatable = (res.Baths__c != pros.Baths__c) ||
        (res.Bedrooms__c != pros.Bedrooms__c) ||
        (res.Subdivision__c != pros.Subdivision__c) ||
        (res.Address_Street__c != pros.Property_Street__c) ||
        (res.Address_Zip_Code__c != pros.Property_Zip_Code__c) ||
        (res.Address_City__c != pros.Property_City__c) ||
        (res.APN__c != pros.APN__c) ||
        (res.Address_State__c != pros.Property_State__r.Name) ||
        (res.County__c != pros.Property_County__c) ||
        (res.HOA_Options__c != pros.HOA_Options__c) ||
        (res.HOA__c != pros.HOA__c) ||
        (res.HOA_Phone__c != pros.HOA_Phone__c) ||
        (res.Parking__c != pros.Parking__c) ||
        (res.Pool__c != pros.Pool__c) ||
        (res.Property_Type__c != pros.Property_Type__c) ||
        (res.Roof_Type__c != pros.Roof_Type__c) ||
        (res.Square_Feet__c != pros.Square_Feet__c) ||
        (res.Year_Built__c != pros.Year_Built__c) ||
        (res.AC_or_Evap__c != pros.AC_or_Evap__c) ||
        (res.Region__c != pros.Region__c) ||
        (res.Market__c != pros.Market__c) ||
        (res.Cross_Streets__c != pros.Property_Cross_Streets__c) ||
        (res.Lot_Sq_Ft__c != pros.Lot_Sq_Ft__c);

        return isUpdatable;
    }

    //find Residence and create map
    public static Map<String, Residence__c> searchResidenceFromAPN(Set<String> setAPNToSearch) {

        Map<String, Residence__c> mapAPNUnique_Residence = new Map<String, Residence__c>();
        List<Residence__c> residenceList = [Select APN_Unique__c From Residence__c
                          Where APN_Unique__c in : setAPNToSearch
                          AND Child_Unit__c != TRUE];
        for(Residence__c res : residenceList) {
            if(res.APN_Unique__c != null) {
                mapAPNUnique_Residence.put(res.APN_Unique__c.toLowerCase(), res);
            }
        }
        return mapAPNUnique_Residence;
    }

    //This method takes APN String as parameter and return boolean
    @RemoteAction
    public static Boolean isProspectEligible(String APN) {

        APN = Utility.removeExceptAlphaNumeric(APN);
        Boolean isProspectEligible = false;

        if(APN == null || APN.length() == 0) {
            isProspectEligible = true;
        }
        else {

            //Select Residence record having the APN
            //Get related prospect if prospect status does not starts with "Dead" and bid type not equal to "Trustee"
            List<Residence__c> residenceList = [Select APN_Unique__c,
                                                ( Select Id From Prospect__r
                                                  Where ( Not ( IsConverted__c =: TRUE OR Prospect_Status__c Like 'Dead%' ) )
                                                  AND ( Bid_Type__c <> 'Trustee' )
                                                  Limit 1
                                                 ),
                                                (Select Id
                                                  From Pipeline__r
                                                  Where (
                                                        NOT ( IsConverted__c =: TRUE OR Stage__c Like '%Dead%' OR Stage__c Like '%Closed%' OR Stage__c Like '%Cancelled%' )
                                                      )
                                                  Limit 1),
                                                (Select Id
                                                From Portfolio__r
                                              Where ( NOT Acquisition_Status__c Like '%Cancelled%' )
                                                  Limit 1)
                                                From Residence__c
                                                Where APN_Unique__c =: APN Limit 1];

            //if no residence exists for the APN
            if(residenceList.size() == 0) {
                isProspectEligible = true;
            }

            else {

                //if residence is only associated with a prospect having prospect status starting with "Dead"
                if(residenceList.get(0).Pipeline__r.size() == 0
                    && residenceList.get(0).Portfolio__r.size() == 0) {

                    //Query for residence records with dead or trustee status or get converted in prior
                    List<Residence__c> residences = [Select APN_Unique__c,
                                                            (Select Id From Prospect__r Where
                                                                IsConverted__c = true OR Prospect_Status__c Like 'Dead%' OR Bid_Type__c = 'Trustee'
                                                                    Limit 1) FROM Residence__c
                                                                        Where APN_Unique__c =: APN Limit 1];

                    //Checking if we are having only one prospect on residence with dead staus
                    if(residences.get(0).Prospect__r.size() > 0 && residenceList.get(0).Prospect__r.size() == 0) {

                        isProspectEligible = true;
                    }
                }
            }
        }

        return isProspectEligible;
    }

    //This method takes APN String as parameter and return boolean
    @RemoteAction
    public static Boolean isResidenceIsThereWithoutChildren(String aPN) {

        //Processing APN string for removing special characters
        aPN = Utility.removeExceptAlphaNumeric(APN);

        //Boolean variable
        Boolean isProspectEligible = false;

        //Checking APn string for null value
        if(aPN != null && aPN != '') {

            //Select Residence record having the APN
            //Get related prospect if prospect status does not starts with "Dead" and bid type not equal to "Trustee"
            List<Residence__c> residenceList = [Select APN_Unique__c,
                                                    (Select Id From Prospect__r Limit 1),
                                                    (Select Id From Pipeline__r Limit 1),
                                                    (Select Id From Portfolio__r Limit 1) From Residence__c Where APN_Unique__c =: APN Limit 1];

            //if no residence exists for the APN
            if(residenceList.size() > 0) {

                //if residence is only associated with a prospect having prospect status starting with "Dead"
                if(residenceList.get(0).Prospect__r.size() == 0
                    && residenceList.get(0).Pipeline__r.size() == 0
                        && residenceList.get(0).Portfolio__r.size() == 0) {

                    isProspectEligible = true;
                }
            }
        }

        return isProspectEligible;
    }

    //This method takes validated address fields and identify if prospect is eligible or not
    public static Boolean isProspectEligible(String addressUnit, String street, String city, String state, String zip) {

        //Prospect Eligible Flag
        Boolean isProspectEligible = false;

        //Select Residence record having same address
        List<Residence__c> residenceList = [Select APN_Unique__c,
                                          ( Select Id From Prospect__r
                                                  Where ( Not ( IsConverted__c =: TRUE OR Prospect_Status__c Like 'Dead%' ) )
                                                  AND ( Bid_Type__c <> 'Trustee' )
                                                  Limit 1
                                                 ),
                                                (Select Id
                                                  From Pipeline__r
                                                  Where (
                                                        NOT ( IsConverted__c =: TRUE OR Stage__c Like '%Dead%' OR Stage__c Like '%Closed%' OR Stage__c Like '%Cancelled%' )
                                                      )
                                                  Limit 1),
                                                (Select Id
                                                From Portfolio__r
                                              Where ( NOT Acquisition_Status__c Like '%Cancelled%' )
                                                  Limit 1)
                                          From Residence__c Where Address_Validated_Street__c =: street
                                                      AND Address_Validated_City__c =: city
                                                      AND Address_Validated_State__c =: state
                                                      AND Address_Validated_Zip__c =: zip
                                                      AND Address_Unit__c =: addressUnit Limit 1];

        //if no residence exists for the addresseses
        if(residenceList.size() == 0) {

            //Prospect is eligible
            isProspectEligible = true;


        } else {

            //if residence is only associated with a prospect having prospect status starting with "Dead"
             if(residenceList.get(0).Prospect__r.size() == 0
              && residenceList.get(0).Pipeline__r.size() == 0
                 && residenceList.get(0).Portfolio__r.size() == 0) {

                //Prospect is eligible
                 isProspectEligible = true;
             }
    }

      return isProspectEligible;
    }

    //This method takes APN and validated address fields and identify if prospect is eligible or not
    public static Boolean isProspectEligible(String APN, String addressUnit, String street, String city, String state, String zip) {

        //Prospect Eligible Flag
        Boolean isProspectEligible = false;

        //Check for the conditions
        if(isProspectEligible(APN) && isProspectEligible(addressUnit, street, city, state, zip))
          isProspectEligible = true;
       return isProspectEligible;
    }

  //This method takes APN String as parameter and return boolean
    public static Boolean apnExists(String APN) {
      APN = Utility.removeExceptAlphaNumeric(APN);
        Boolean isEligible = false;

        //Check for APn Value
        if(APN == null || APN.length() == 0) {
          isEligible = false;
        } else {

          //Get related prospect if prospect status does not starts with "Dead" and bid type not equal to "Trustee"
          List<Residence__c> residenceList = [Select APN_Unique__c,
                            (Select Id From Prospect__r
                              Where ( Not Prospect_Status__c Like 'Dead%' ) AND (Bid_Type__c <> 'Trustee' ) Limit 1
                             ),
                            (Select Id From Pipeline__r Limit 1),
                            (Select Id From Portfolio__r Limit 1)
                            From Residence__c
                            Where APN_Unique__c =: APN Limit 1];
          //Check for list size
          if(residenceList.size() > 0) {
            isEligible = true;
          }
      }

      return isEligible;
  }

  //This method is to check that whether residence exists or not'
    public static Boolean residenceExists(String street, String city, string state, String zip) {

      //Check if the same address already exists in data base
      List<Residence__c> residences = [Select Id from Residence__c where Address_Validated_Street__c =: street AND
                                        Address_Validated_City__c =: city AND Address_Validated_State__c =: state AND Address_Validated_Zip__c =: zip
                                        ORDER BY Parent_Structure__c DESC limit 1];

      //Check for the size if data exists
      if(residences.size() > 0)
        return true;

      //else retun null
      return false;
    }

    //This method is to check that whether residence exists or not'
    public static Residence__c getResidence(String street, String city, string state, String zip) {

      //Check if the same address already exists in data base
    List<Residence__c> residences = [Select Id from Residence__c where Address_Validated_Street__c =: street AND
                                          Address_Validated_City__c =: city AND Address_Validated_State__c =: state
                                          AND Address_Validated_Zip__c =: zip
                                          AND Child_Unit__c != TRUE
                                          ORDER BY Parent_Structure__c DESC limit 1];

       //Check for the size if data exists
        if(residences.size() > 0)
      return residences[0];

        //else retun null
        return null;
    }

    //This method is to check that whether residence exists or not'
    public static Map<String, Residence__c> getResidenceMap(Set<String> setStreet,
                               Set<String> setCity,
                               Set<String> setState,
                               Set<String> setZip) {

      Map<String, Residence__c> mapAddressKey_Residence = new Map<String, Residence__c>();
       for(Residence__c res : [Select  Id, Address_Validated_Street__c,
                         Address_Validated_City__c,
                         Address_Validated_State__c,
                         Address_Validated_Zip__c,
                         Child_Unit__c,
                         APN__c,
                         APN_Unique__c
                         From Residence__c
                         Where Address_Validated_Street__c =: setStreet AND
                                          Address_Validated_City__c in: setCity
                                          AND Address_Validated_State__c in: setState
                                          AND Address_Validated_Zip__c in: setZip
                                          AND Child_Unit__c != TRUE
                                          ORDER BY Parent_Structure__c DESC ]) {

         mapAddressKey_Residence.put(res.Address_Validated_Street__c
                       + res.Address_Validated_City__c
                       + res.Address_Validated_State__c
                       + res.Address_Validated_Zip__c, res);
       }


       return mapAddressKey_Residence;

    }

    //This method is to update the main record with the validated address recsponse
  public static void updateAddressValidationResults(List<IHSmartyStreetsService.ValidateAddressResponse> results) {

    //Create a list of residence records to be updated
    List<Residence__c> residences = new List<Residence__c>();

    //loop thorugh the response
    for(IHSmartyStreetsService.ValidateAddressResponse response : results) {

      //Create a clone of resedense
      Residence__c residence = new Residence__c(Id = response.recordId);

      //Update validated data on residence
      residence.Address_Validated_Street__c = response.street;
      residence.Address_Validated_City__c = response.city;
      residence.Address_Validated_Zip__c = response.zip;
      residence.Address_Validated_State__c = response.state;
      residence.Address_Validated_Last_Attempt__c = DateTime.now();
      residence.Address_Validated_Successfully__c = response.validateSuccess;

      //Other fields
      residence.ZipPlus4__c = response.zipPlus4;
      residence.Location__Latitude__s =  response.latitude;
      residence.Location__Longitude__s =  response.longitude;
      residence.Address_Validated_County__c = response.county;
      residence.Address_Validation_Message__c = response.errorMessage;

      //Add response in the list to be updated
      residences.add(residence);
    }

    //Check for the lis size and update tre records
    if(residences.size() > 0)
      update residences;
  }
}