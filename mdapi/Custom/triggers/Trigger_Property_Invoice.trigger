/**
 *   Description  :  Trigger on Property_Invoice__c Object
 *
 *   Created By Shrinath
 *
 *   Created Date:  11/08/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
trigger Trigger_Property_Invoice on Property_Invoice__c (after insert, after update, before insert, before update) {

	if( trigger.isBefore ) {

		if( trigger.isInsert ) {
			Property_InvoiceTriggerHelper.populateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}

		if( trigger.isUpdate ) {
			Property_InvoiceTriggerHelper.populateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}
	}

	if( trigger.isAfter ) {
		if( trigger.isInsert ) {
			Property_InvoiceTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}

		if( trigger.isUpdate ) {
			Property_InvoiceTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
		}
	}

}