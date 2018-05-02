/**
 *  Description     :   Helper class for "Claim Update" trigger.
 *
 *  Created By      :   Bhavi Sharma
 *
 *  Created Date    :   02/06/2014
 *
 *  Revision Logs   :   V1.0 - Created
 *
 **/
public without sharing class ClaimUpdateTriggerHelper {

    /**
     *  @description    :   Method to sets Master's Most_Recent_Claim_Update__c lookup to the most recently modified claim update record value.
     *
     *  @args           :   List of new claim updates, Map of old claim updates
     *
     *  @return         :   void
     *
     **/
    //Code added by Bhavi Sharma - 02/06/2014 - D-00011450
    public static void populateMostRecentClaimUpdateOnClaim(List<Claim_Update__c> newClaimUpdates, Map<Id, Claim_Update__c> mapOldClaimUpdates) {

        //Create a new Map of Claims to be update
        Map<Id, Claims__c> mapClaimsToUpdate = new Map<Id, Claims__c>();

        //Set to hold Parent claim records Id value
        Set<Id> setClaimIds = new Set<Id>();

        //List to hold the current Context Claim_Update__c
        List<Claim_Update__c> claimUpdates = newClaimUpdates != null ? newClaimUpdates : mapOldClaimUpdates.values();

        //Loop through the records list and populate the setClaimIds
        for(Claim_Update__c cU : claimUpdates)
            setClaimIds.add(cU.Claim__c);

        //In Case of Insert, directly assign the new CU in Most_Recent_Claim_Update__c field on claim
        if(newClaimUpdates != null && mapOldClaimUpdates == null) {

            //Loop through the Claim Updates and Add the Most recent one on Claim
            for(Claim_Update__c cU : newClaimUpdates) {

                //Update the Most_Recent_Claim_Update__c directly
                mapClaimsToUpdate.put(cu.Claim__c, new Claims__c(Id = cu.Claim__c, Most_Recent_Claim_Update__c = cu.Id, Most_Recent_Claim_Update_Note__c = cu.Note__c));
            }
        } if(newClaimUpdates != null && mapOldClaimUpdates != null) {

            //Update Scenario: Check if the Most_Recent_Claim_Update__c is already on the Claimn

            //Fetch existing Map records
            Map<Id, Claims__c> mapClaims = new Map<Id, Claims__c>([Select Id, Most_Recent_Claim_Update__c, Most_Recent_Claim_Update_Note__c from Claims__c where Id IN: setClaimIds]);

            //Loop through the Claim Updates and Add the Most recent one on Claim Update
            for(Claim_Update__c cU : newClaimUpdates) {

                //Check if Most_Recent_Claim_Update__c on Claim is different then cu.Id, only then process the record
                if(mapClaims.containsKey(cu.Claim__c) && (mapClaims.get(cu.Claim__c).Most_Recent_Claim_Update__c != cu.Id || mapClaims.get(cu.Claim__c).Most_Recent_Claim_Update_Note__c != cu.Note__c))
                    mapClaimsToUpdate.put(cu.Claim__c, new Claims__c(Id = cu.Claim__c, Most_Recent_Claim_Update__c = cu.Id, Most_Recent_Claim_Update_Note__c = cu.Note__c));
            }
        } else {

            //Delete Scenerio: Get the Most recent record from Claim Update and add in Map to Update
            for(Claims__c claim : [Select Id, Most_Recent_Claim_Update__c, Most_Recent_Claim_Update_Note__c,
            							(Select Id, Claim__c, Note__c from Claim_Statuses__r ORDER BY LastModifiedDate DESC LIMIT 1)
            						from Claims__c where Id IN: setClaimIds]) {

                //Add Most recent data in Map
                if(claim.Claim_Statuses__r != null && claim.Claim_Statuses__r.size() > 0
                	&& (claim.Most_Recent_Claim_Update__c != claim.Claim_Statuses__r[0].Id || claim.Most_Recent_Claim_Update_Note__c != claim.Claim_Statuses__r[0].Note__c)
                ) {

                    //Update Most recent claim update and Note
                    claim.Most_Recent_Claim_Update__c = claim.Claim_Statuses__r[0].Id;
                    claim.Most_Recent_Claim_Update_Note__c = claim.Claim_Statuses__r[0].Note__c;
                    mapClaimsToUpdate.put(claim.Id, claim);
                } else if(!String.IsBlank(claim.Most_Recent_Claim_Update_Note__c)) {

                	//Blank out Note field
                	claim.Most_Recent_Claim_Update_Note__c = null;
                	mapClaimsToUpdate.put(claim.Id, claim);
                }
            }
        }

        //Update the Claims if any
        if(mapClaimsToUpdate.size() > 0)
            update mapClaimsToUpdate.values();
    }
}