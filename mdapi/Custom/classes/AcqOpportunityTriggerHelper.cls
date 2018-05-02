public without sharing class AcqOpportunityTriggerHelper {
    public static void addMarketFromAddress(List<Acq_Opportunity__c> acqOpportunities) {
        //Get the region Map against a Region Name
        Map<String,Region__c> allRegionsByStrings = new Map<String, Region__c>();
        for(Region__c region : [SELECT Id, Name FROM Region__c]) {
            allRegionsByStrings.put(region.Name,region);
        }
        System.debug('All regions by String ' + allRegionsByStrings);
        System.debug('Trigger.new is ' + acqOpportunities);

        //All address in a set
        Set<Id> allAddressIds = new Set<Id>();
        for(Acq_Opportunity__c opp : acqOpportunities) {
            if(opp.Address__c != null) {
                allAddressIds.add(opp.Address__c);
            }
        }

        List<Address__c> allAddresses = [SELECT Id, Zip__c FROM Address__c WHERE Id in :allAddressIds];
        //Get all Zip values to filter from custom setting
        Map<Id,String> allZipMapIds = new Map<Id, String>();
        for(Address__c address : allAddresses) {
            allZipMapIds.put(address.Id, address.Zip__c);
        }
        System.debug('All Id to Zip for opp ' + allZipMapIds);


        Map<String, Zip_code_reference__c> zipCodeReferenceMap = new Map<String, Zip_code_reference__c>();
        for(Zip_code_reference__c zip : [SELECT Name, Zip__c, Market__c, Market2__c, LocationScore__c, SubMarket__c
        FROM Zip_code_reference__c WHERE Name in :allZipMapIds.values()]) {
            zipCodeReferenceMap.put(zip.Name, zip);
        }
        System.debug('Zip code Reference Map ' + zipCodeReferenceMap);

        for(Acq_Opportunity__c opp : acqOpportunities) {
            if(opp.Address__c != null){
                System.debug('Zip code from address ' + opp.Address__r.zip__c);
                Zip_code_reference__c zipCodeReference = zipCodeReferenceMap.get(allZipMapIds.get(opp.Address__c));
                if(zipCodeReference != null){
                    System.debug('zipCodeReference.Market__c gives ' + zipCodeReference.Market__c);
                    Region__c region = allRegionsByStrings.get(zipCodeReference.Market__c);
                    if(region != null)
                    {
                        opp.Market__c = region.Id;
                    }
                    opp.Market2__c = zipCodeReference.Market2__c;
                    opp.Submarket__c = zipCodeReference.SubMarket__c;
                }

            }

        }
    }
    
}