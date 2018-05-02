/**
 *  Description :   This trigger is responsible for updating prospect or pipeline from AZBidder
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   12/21/2012
 *
 *  Revision Logs:  V_1.0 - Created
 					V_1.1 - Bhavi Sharma - 06/08/2013 - Added check for Constants.EXECUTE_TRIGGER - D-00005253
 *					V_1.2 - Bhavi Sharma - 07/20/2013 - Added new method(validateAddressChanges) - D-00006528
 *
 *
 **/
trigger Trigger_AZB_Update on AZB_Update__c (before insert, before update, after insert, after update) {

 	//Check if trigger need to be executed
 	if(Constants.EXECUTE_TRIGGER == false)
		return;

    if(AZB_UpdateTriggerHelper.runAZBTrigger) {

        if(trigger.isBefore) {

            if(trigger.isInsert) {

            	//validate smarty street address updates
                AZB_UpdateTriggerHelper.validateSmartyStreetStatus(trigger.new);

            	//checks if key field values are avaialble appropriately to be processed
                AZB_UpdateTriggerHelper.validateUserForAZB_Updates(trigger.new);

            }

            if(trigger.isUpdate) {

            	//Validate Address changes
    			AZB_UpdateTriggerHelper.validateAddressChanges(Trigger.New, Trigger.oldMap);

            	//validate if updates need to be processed, checks if any critical field change
            	AZB_UpdateTriggerHelper.validateAZB_Updates(trigger.new, trigger.oldMap);

				//validate smarty street address updates
                AZB_UpdateTriggerHelper.validateSmartyStreetStatus(trigger.new, trigger.oldMap);

            	//checks if key field values are avaialble appropriately to be processed
                AZB_UpdateTriggerHelper.validateUserForAZB_Updates(trigger.new);

             	AZB_UpdateTriggerHelper.relinkProspectPipeline(trigger.new, trigger.oldMap);

				//call method to process AZB updates
            	AZB_UpdateTriggerHelper.populateAZB_Updates(trigger.new);

            }

        }

        if(trigger.isAfter) {

            if( trigger.isInsert ) {
            	//call method to process AZB updates
                AZB_UpdateTriggerHelper.populateAZB_Updates(trigger.new);
            } else if(Trigger.isUpdate) {

        		//Call the helper class method to update Win data and Atlanta Region on Residence
				AZB_UpdateTriggerhelper.validateAZBRecordForAtlantaRegion(Trigger.New, Trigger.oldMap);
            }
        }
    }
}