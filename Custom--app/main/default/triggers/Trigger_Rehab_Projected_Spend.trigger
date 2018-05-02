/**
 *   Description  :  Trigger on Rehab_Projected_Spend__c Object
 *
 *   Created By Shrinath
 *
 *   Created Date:  11/15/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
 trigger Trigger_Rehab_Projected_Spend on Rehab_Projected_Spend__c (before insert, before update, after insert, after update) {
/**
        if( trigger.isBefore ) {
            if( trigger.isInsert ) {
                Rehab_Projected_SpendTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
            }

            if( trigger.isUpdate ) {
                Rehab_Projected_SpendTriggerHelper.updateRehabProjectedSpend( trigger.new, trigger.oldMap );
            }

        }

        if( trigger.isAfter ) {

            if( trigger.isInsert ) {
                Rehab_Projected_SpendTriggerHelper.updateRehab( trigger.new, trigger.oldMap );
            }

            if( trigger.isUpdate ) {
                Rehab_Projected_SpendTriggerHelper.updateRehab( trigger.new, trigger.oldMap );
            }
        }
**/
}