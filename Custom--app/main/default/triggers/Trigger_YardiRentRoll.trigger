/**
 *  Description     :   This trigger is to handle the pre processing operation for Yardi Rent Roll object.
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   05/09/2013
 *
 *  Revision Logs   :   V_1.0 - Created
 *                      V_1.1 - Abhinav Sharma - 7/10/2013 - Added new method(mostRecentYardiRentRollOnResidence) - D-00005982
 *                      V1_1.2 - Abhinav Sharma - 7/23/2013 - New Method Added(populateRegionBasedOnPortfolioRegionValue) - BUG-1944
 *                      V_1.3 - Abhinav Sharma - 04/03/2015 - New method added (populateYRRMoveDateOnMostRecentListing) - D-00013862
                        v_1.4 - Saurabh kumar  - 07/17/2015-  New Method added (createDispositionRehabOnPortfolio)   - D- 00014396
                        V_1.5 - Abhinav Sharma - 10/16/2015 - New method added(populateYRRMakeReadyDateOnMostRecentListing) - D-00014655 
                        V_1.6 - Poonam Bhargava - 03/28/2016 - New method added(updatePortfolioOwnerFromYRR) - D-00015227
                        V_1.7 - Poonam Bhargava - Added a new method updateMarketfieldfromMarket2 - (D-00017166)
**/ 
trigger Trigger_YardiRentRoll on Yardi_Rent_Roll__c (before insert, before update, after insert, after update) {

    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;
    
    //Check for the request type
    if(Trigger.isBefore) {

        //Check for event type
        if(Trigger.isInsert || Trigger.isUpdate) {

            //Call helper class method
            YardiRentRollTriggerHelper.attachPortfolioWithYardiRentRoll(Trigger.New , Trigger.oldMap);
            
            //Call Helper class method for populating Region field value based on Parent Portfolio record
            YardiRentRollTriggerHelper.populateRegionBasedOnPortfolioRegionValue(Trigger.new, Trigger.oldMap);
            
            //Call helper class method - (D-00017166)
            YardiRentRollTriggerHelper.updateMarketfieldfromMarket2(Trigger.new, Trigger.oldMap);
        }
    }

    else if(trigger.isAfter) {
        
         //calling Method to create disposition rehab when a current tenant status is changed to Notice
         YardiRentRollTriggerHelper.createDispositionRehabOnPortfolio(Trigger.New , Trigger.oldMap);

        if(trigger.isInsert) {

            // Associate the Yardi Rent Roll records with the AM Reporting records
            YardiRentRollTriggerHelper.associateYardiRentRollToAMReporting(trigger.new);

            //Added by Abhinav Sharma on 7/10/2103
            YardiRentRollTriggerHelper.mostRecentYardiRentRollOnResidence(trigger.new);
            
            //Added By - Poonam Bhargava - 03/28/2016  - (D-00015227)
            //Calling helper class method
           YardiRentRollTriggerHelper.updatePortfolioOwnerFromYRR(trigger.new, Trigger.oldMap);
        }
        
        //Check for the event type
        if(Trigger.isUpdate) {
        
            //Added By - Abhinav Sharma - 10/16/2015 - D-00014655
            //Calling helper class method
            YardiRentRollTriggerHelper.populateYRRMakeReadyDateOnMostRecentListing(trigger.new, Trigger.oldMap);
            
            //Added By - Poonam Bhargava - 03/28/2016 - (D-00015227)
            //Calling helper class method
            YardiRentRollTriggerHelper.updatePortfolioOwnerFromYRR(trigger.new, Trigger.oldMap);
        }
    }
}