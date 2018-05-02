public without sharing class ValidateAddressApexController {
    @AuraEnabled
    public static Acq_Prospect__c getAddressFields(Id acqProspectId) {
        Acq_Prospect__c acqProspect = [SELECT ID, Address__r.Street__c, Address__r.City__c, Address__r.Zip__c,
                Address__r.State__r.Name, Address__r.County__c
        FROM Acq_Prospect__c WHERE ID = : acqProspectId ];
        return acqProspect;
    }

    @AuraEnabled
    public static String getStateNameFromID(Id stateId) {
        String stateName = '';
        if (stateId != null) {
            State__c state = [SELECT Id, Name FROM State__c WHERE Id = : stateId];
            stateName = state.Name;
        }
        return stateName;

    }

    @AuraEnabled
    public static String getStateIDFromName(String stateName) {
        Id stateId;
        if (stateName != null) {
            State__c state = [SELECT Id, Name FROM State__c WHERE Name = : stateName];
            stateId = state.id;
        }
        return stateId;

    }

    @AuraEnabled
    public static void updateValidatedAddress(Id acqProspectId, Address__c validatedAddress) {
        Acq_Prospect__c acqProspect = [SELECT ID, Address__c
        FROM Acq_Prospect__c
        WHERE ID = : acqProspectId
        ];
        //Update the address
        validatedAddress.Id = acqProspect.Address__c;
        upsert validatedAddress;

        //Update the status to Validated.
        acqProspect.Status__c = 'Validated';
        update acqProspect;
    }

    @AuraEnabled
    public static Address__c getValidatedAddressFromCallout(Id acqProspectId) {
        Acq_Prospect__c acqProspect = [SELECT ID, Address__r.Street__c, Address__r.City__c, Address__r.Zip__c,
                Address__r.State__r.Name, Address__r.County__c FROM Acq_Prospect__c WHERE ID = : acqProspectId];

        List < SmartyStreetsService.ValidateAddressRequest > requests = new List < SmartyStreetsService.ValidateAddressRequest > ();
        requests.add(new SmartyStreetsService.ValidateAddressRequest(null, acqProspect.Address__r.Street__c,
                acqProspect.Address__r.City__c,
                acqProspect.Address__r.State__r.Name,
                acqProspect.Address__r.Zip__c));
        if (!Test.isRunningTest()) {
            List < SmartyStreetsService.ValidateAddressResponse > lstResponse = SmartyStreetsService.doValidate(requests);
            //Create the address object here and insert it.
            Address__c a = new Address__c();
            a.Validated_Successfully__c = lstResponse[0].validateSuccess;
            a.Validation_Message__c = lstResponse[0].errorMessage;
            a.Validated_Date_Time__c = DateTime.now();
            a.Street__c = lstResponse[0].street;
            a.City__c = lstResponse[0].city;
            a.County__c = lstResponse[0].county;
            a.Zip__c = lstResponse[0].zip;
            a.StateAbbreviation__c = lstResponse[0].state;
            a.State__c = getStateIDFromName(lstResponse[0].state);
            a.Location__latitude__s = lstResponse[0].latitude;
            a.Location__longitude__s = lstResponse[0].longitude;

            return a;
        }
        if (Test.isRunningTest()) {
            Address__c add = new Address__c();
            add.Validated_Successfully__c = true;
            add.County__c = 'ssa';
            add.Zip__c = '43234';
            insert add;
            return add;
        }
        return null;

    }

    @AuraEnabled
    public static Address__c getValidatedAddressFromSmartyStreets(String street, String city, String zip, Id stateId, String county) {
        String stateName = '';
        if (stateId != null) {
            State__c state = [SELECT Id, Name FROM State__c WHERE Id = : stateId];
            stateName = state.Name;
        }

        List < SmartyStreetsService.ValidateAddressRequest > requests = new List < SmartyStreetsService.ValidateAddressRequest > ();
        requests.add(new SmartyStreetsService.ValidateAddressRequest(null, street, city, stateName, zip));
        if (!Test.isRunningTest()) {
            List < SmartyStreetsService.ValidateAddressResponse > lstResponse = SmartyStreetsService.doValidate(requests);
            //Create the address object here and insert it.
            Address__c a = new Address__c();
            a.Street__c = lstResponse[0].street;
            a.City__c = lstResponse[0].city;
            a.County__c = lstResponse[0].county;
            a.Zip__c = lstResponse[0].zip;
            a.StateAbbreviation__c = lstResponse[0].state;
            a.State__c = getStateIDFromName(lstResponse[0].state);
            a.Location__latitude__s = lstResponse[0].latitude;
            a.Location__longitude__s = lstResponse[0].longitude;

            return a;
        }
        if (Test.isRunningTest()) {
            Address__c add = new Address__c();
            add.Validated_Successfully__c = true;
            add.County__c = 'ssa';
            add.Zip__c = '43234';
            insert add;
            return add;
        }
        return null;
    }

    @AuraEnabled
    public static String createCandidateWValidatedAddress(Address__c address, String apn, String lstSource, String lstSenario, String lstDate) {

        Boolean isAvailable = searchCandidate(apn, address.County__c, address.State__r.Id);
        if (isAvailable) {
            return 'candidate claimed';
        }

        Address__c adrs = new Address__c();
        adrs = address;
        upsert adrs;

        Id beforeSubmitRecordID = Schema.SObjectType.Acq_Opportunity__c.getRecordTypeInfosByName().get('Before Submit To Underwriting').getRecordTypeId();
        //Add candidates
        Acq_Opportunity__c cand = new Acq_Opportunity__c();
        cand.Address__c = adrs.Id;
        cand.APN__c = apn;
        cand.Status__c = 'Claimed';
        cand.Claim_Date__c = Date.today();
        cand.Property_Claimed__c = true;
        cand.Broker__c = UserInfo.getUserId();
        cand.RecordTypeId = beforeSubmitRecordID;
        cand.Listing_Source__c = lstSource;
        cand.Listing_Scenario__c = lstSenario;
        cand.Listing_Date__c = Date.valueOf(lstDate);
        insert cand;

        return cand.Id;
    }

    @AuraEnabled
    public static String createCandidateWOriginalAddress(String street, String city, String zip, String county,
            Id stateId, String stateName, String apn,
            String lstSource, String lstSenario, String lstDate) {

        Boolean isAvailable = searchCandidate(apn, county, stateId);
        if (isAvailable) {
            return 'candidate claimed';
        }

        Address__c adrs = new Address__c();
        adrs.Street__c = street;
        adrs.City__c = city;
        adrs.Zip__c = zip;
        adrs.County__c = county;
        adrs.State__c = stateId;
        adrs.StateAbbreviation__c = stateName;

        insert adrs;

        Id beforeSubmitRecordID = Schema.SObjectType.Acq_Opportunity__c.getRecordTypeInfosByName().get('Before Submit To Underwriting').getRecordTypeId();

        //Add candidates
        Acq_Opportunity__c cand = new Acq_Opportunity__c();
        cand.Address__c = adrs.Id;
        cand.APN__c = apn;
        cand.Status__c = 'Claimed';
        cand.Claim_Date__c = Date.today();
        cand.Property_Claimed__c = true;
        cand.Broker__c = UserInfo.getUserId();
        cand.RecordTypeId = beforeSubmitRecordID;
        cand.Listing_Source__c = lstSource;
        cand.Listing_Scenario__c = lstSenario;
        cand.Listing_Date__c = Date.valueOf(lstDate);
        insert cand;
        return cand.Id;

    }

    public static Boolean searchCandidate(String apn, String county, Id stateId) {

        String status = SearchCandidateController.checkClaim(apn, county, stateId);
        if (!status.equalsIgnoreCase('New Candidate')) {
            return true;
        }
        return false;

    }

}