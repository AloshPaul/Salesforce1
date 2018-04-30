/**
 *  Description :   This trigger is responsiable for all the pre and post processing for "Claim Update" records.
 *
 *  Created By  :   Bhavi Sharma
 *
 *  Created Date:   02/06/2014
 *
 *  Revision Logs:  V1.0 - Created
 *
 **/
trigger Trigger_ClaimUpdate on Claim_Update__c (after insert, after update, after delete) {

    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;

    //Check for the request type
    if(Trigger.isAfter) {

        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {

            //Call helper class method to update data
            ClaimUpdateTriggerHelper.populateMostRecentClaimUpdateOnClaim(Trigger.New, Trigger.oldMap);
        }
    }
}