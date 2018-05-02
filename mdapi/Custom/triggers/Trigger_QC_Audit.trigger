/**
 *  Description :   This trigger on Object QC_Audit__c
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   03/14/2012
 *
 *  Revision Logs:  V1.0 - Created
 *
 **/
trigger Trigger_QC_Audit on QC_Audit__c ( after delete, after insert, after undelete,
										  after update, before delete, before insert, before update) {

	 // when after trigger
     if( trigger.isAfter ) {
		// when insert, update or delete trigger
     	if( trigger.isInsert || trigger.isUpdate || trigger.isDelete ) {
     		// call method to populate Most Recent PreSignoff QC_Audit on rehab
			QC_AuditTriggerHelper.populateMostRecentPreSignoffQC_Audit( trigger.new, trigger.old, trigger.oldMap );
     	}
     }
}