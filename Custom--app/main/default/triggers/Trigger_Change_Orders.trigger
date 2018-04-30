/**
 *   Description  :  Trigger on Change_Orders__c Object
 *
 *   Created By Shrinath
 *
 *   Created Date:  08/23/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
trigger Trigger_Change_Orders on Change_Orders__c (after insert, after update, before insert, before update) {

	if( trigger.isBefore ) {

		if( trigger.isInsert ) {
			Change_OrdersTriggerHelper.populateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}

		if( trigger.isUpdate ) {
			Change_OrdersTriggerHelper.populateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}
	}

	if( trigger.isAfter ) {
		if( trigger.isInsert ) {
			// Changes done for SIR D-00014800
			//Change_OrdersTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
			Change_OrdersTriggerHelper.updateRehab( trigger.new, trigger.oldMap );
		}

		if( trigger.isUpdate ) {
			// Changes done for SIR D-00014800
			//Change_OrdersTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
			Change_OrdersTriggerHelper.updateRehab( trigger.new, trigger.oldMap );
		}
	}
}