/**
 *  Description :   This trigger is responsiable for all the pre and post processing for property record
 *
 *  Created By  :   Bhavi
 *
 *  Created Date:   07/19/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - PropertyTriggerHelper.followPropertyByRegion
 *                         Commented out for initial upload
 *                  V1.2 - Bhavi - 09/23/2012 - New call added - populateBKContestInternalDecisionDate
 *                  V1.3 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  V1.4 - (10/09/2014) - Abhinav - 00013320 - Called Helper class method - setPropertyOwnerEntity
 *                  v1.5 - (27/03/2015) - Prashant - D-00013834 - Called helper class method - updateTipRecords
 *                  v1.6 -  (10/7/2015) - Saurabh  - D-00014396 - called helper class method -validatePortfolioAccStatus
 *                  v1.9 - (08/25/2015) - Abhinav - D-00014487 - Called helper class method - populatePMEmailOnViolations
 *                  v1.10 - (09/08/2015) -Saurabh - D-00014561 
 *                  v1.11 - (03-01-2016) - Abhinav -D-00014918 -  call helper class method populateDateCancelledBasedOnAcqStatus
 *                  v1.12 - (5/30/2016)  - Saurabh -D-00015599 - Call Method 'updateRelatedRenewalToSold' to update Renewal for Sold Properties
 *                  v1.13 - (06/14/2016) - Poonam Bhargava - D-00015709  - Call the method populateSubmarket to populate submarket field on Portfolio
 *                  V1.14 - (09/02/2016) - Modified by Poonam Bhargava - D-00016126
 *                  V1.15 - (2/15/2017)  - Modified by Saurabh Kuamr -  D-00016866
 *                  V1.16 - (11/06/2017) - Added by Poonam Bhargava  - D-00017574
 **/
trigger Trigger_Property on Property__c (before insert, before update, after insert, after update) {

    try {
         System.debug('Inside Trigger property******EXECUTE_TRIGGER  '+Constants.EXECUTE_TRIGGER +'PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER******'+PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER);
        //Execute the trigger only if required
        if(Constants.EXECUTE_TRIGGER == false
            || PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER == false)
            return ;
        //Check for the request type
        if(Trigger.isBefore) {
        
            if(Trigger.isInsert) {
            
                //Added by Poonam Bhargav  - D-00017574 (11/06/2017)
                //Calling Helper class method
                PropertyTriggerHelper.validatePropertyOnInsert(Trigger.New);
                
                PropertyTriggerHelper.populateYardiPropertyCodeOnPortfolio(Trigger.New);
            }
            
           
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {

                //Validate all date fields
                PropertyTriggerHelper.validateAllDateField(Trigger.New);
                //Validate Accquisation state 
                PropertyTriggerHelper.validatePortfolioAccStatus(Trigger.New,Trigger.OldMap) ;

                PropertyTriggerHelper.validateLawn_PoolMaintenanceEmailBeforeSendingEmail(Trigger.New, Trigger.OldMap);
                PropertyTriggerHelper.validateRehabCrewEmailBeforeSendingEmail(Trigger.New, Trigger.OldMap);

                //Populate status fields
                PropertyTriggerHelper.setPropertyFields(Trigger.New);
                PropertyTriggerHelper.setPropertyOwnerEntity(Trigger.New);

                //set YardiIntegrrationFlag
                //PropertyTriggerHelper.setYardiIntegrrationFlag(Trigger.New);
                PropertyTriggerHelper.setYardiIntegrrationFlagOnAttributeUpdate(Trigger.New, Trigger.OldMap);
                
                //Added by Abhinav Sharma  - D-00014918 (03-01-2016)
                //Calling Helper class method
                PropertyTriggerHelper.populateDateCancelledBasedOnAcqStatus(Trigger.New, Trigger.OldMap);
                
                //Added by Poonam Bhargava D-00015709 - (06-14-2016)
                //Calling Helper class method
                PropertyTriggerHelper.populateSubmarket(Trigger.New);
                
                //Added by Saurabh Kumar  D-00016866 updateDateSoldOnPortfolio
                PropertyTriggerHelper.updateDateSoldOnPortfolio(Trigger.New, Trigger.OldMap);
                
                //Added By Poonam Bhargava - D-00017166
                //Call the utility class method to populate Market field
                Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
                
                
            }
        } else if(Trigger.isAfter) {

            //Check for the Event Type
            if(Trigger.isInsert) {
                //Follow Records By Region
                //PropertyTriggerHelper.followPropertyByRegion(Trigger.New);

                //Share with 3rd Party Users
                PropertyTriggerHelper.sharePropertyWith3rdPartyUsers(Trigger.oldMap, Trigger.newMap, false);
                //Create new yardi property record
                PropertyTriggerHelper.createYardiProperty(Trigger.New);
                //create new child obkect
                PropertyTriggerHelper.createViolation(Trigger.New);
                PropertyTriggerHelper.createAactualResults(Trigger.New);
                PropertyTriggerHelper.createataskRehabManager(Trigger.New, Trigger.OldMap);

                // create new portfolio doc compliance
                PropertyTriggerHelper.createPortfolioDocCompliance( Trigger.New );

                //update residence with current portfolio
                PropertyTriggerHelper.updateResidence(Trigger.New, Trigger.OldMap);
                //set Create Folder
                PropertyTriggerHelper.createBoxPropertyFolder(Trigger.New, Trigger.NewMap);

                //Call helper class method
                PropertyTriggerHelper.createRehabAndListingRecords(Trigger.New);

                // Create AM Reporting Records
                PropertyTriggerHelper.createAMReportingRecords(trigger.new);

            }
            else if(Trigger.isUpdate) {

                //Update BK records with appropriate Contest Internal Decision Date
                PropertyTriggerHelper.populateBKContestInternalDecisionDate(Trigger.newMap);
                
                //Share with 3rd Party Users
                PropertyTriggerHelper.sharePropertyWith3rdPartyUsers(Trigger.oldMap, Trigger.newMap, true);
                PropertyTriggerHelper.createTaskForTIPCoordinator(trigger.oldMap,Trigger.new);
                PropertyTriggerHelper.createataskRehabManager(Trigger.New, Trigger.OldMap);
                
                //update residence with current portfolio
                PropertyTriggerHelper.updateResidence(Trigger.New, Trigger.OldMap);
                
                //update Tip records record type
                PropertyTriggerHelper.updateTipRecords(Trigger.New, Trigger.oldMap);
                
                //Call helper class method populatePMEmailOnViolations
                PropertyTriggerHelper.populatePMEmailOnViolations(Trigger.New, Trigger.OldMap);
                
                //Call helper class method updateRelatedRenewalToSold D-00015599(5/30/2016)
                PropertyTriggerHelper.updateRelatedRenewalToSold(Trigger.New, Trigger.OldMap);

            }
        }
    } catch(DMLException e) {

        //Prepare a user friedly error message
        String failedRecordId = e.getDmlId(0);

        //Failue fields
        List<Schema.SObjectField> failureFields = e.getDmlfields(0);
        String failureMessage = e.getDmlMessage(0);

        String errorMessage = '';
        if(failedRecordId != null && failedRecordId != '')
            errorMessage += 'Operation failed for '+ Label.SERVER_URL + failedRecordId + '. '; //Modified by Poonam Bhargava (09/02/2016) - D-00016126
        if(failureFields != null && failureFields.size() > 0) {

            errorMessage += failureFields[0].getDescribe().getLabel() + ': ';
        }
        if(failureMessage != null && failureMessage != '')
            errorMessage += failureMessage;

        //Add error
        Trigger.New[0].addError(errorMessage);
    } catch(Exception e) {

        //Add Error Message on Page
        Trigger.New[0].addError(e.getMessage());
    }
}