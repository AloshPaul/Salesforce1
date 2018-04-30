/**
 *   Description	:	Trigger on HOA Payments object to perform all the required pre and post operations.
 *
 *   Created By   	:	Bhavi Sharma
 *
 *   Created Date 	:	02/20/2014
 *
 *   Revision Logs	:	V_1.0 - Created
 *
 **/
trigger Trigger_HOAPayments on HOA_Payments__c (after insert, after update, after delete) {

	//Checking for request type
	if(Trigger.isAfter) {

		//Checking for event type
		if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {

			//Calling Helper class method to pull the most recent HOA_Payments__c to the parent HOA_Tracking__c (HOA Tracking) record.
			HOAPaymentsTriggerHelper.populateMostRecentHOAPayment(Trigger.new, Trigger.oldMap);
		}
	}
}