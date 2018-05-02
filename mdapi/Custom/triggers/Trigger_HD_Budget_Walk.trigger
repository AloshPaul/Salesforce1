/**
 *  Description :   This trigger on Object HD_Budget_Walk__c
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   07/06/2012
 *
 *  Revision Logs:  V1.0 - Created
 *
 **/
trigger Trigger_HD_Budget_Walk on HD_Budget_Walk__c (before update, after update) {

	//Check if trigger need to be executed
 	if(Constants.EXECUTE_TRIGGER == false)
		return;

	if(trigger.isBefore) {
		if(trigger.isUpdate) {
			//call method to reset boolean fields for RehabPhotosUploaded
			HD_Budget_WalkTriggerHelper.resetRehabPhotosUploadedFields( trigger.new, trigger.oldMap );
		}
	}

	if(trigger.isAfter) {

		if(trigger.isInsert) {
			//call method to populate HDBudgetWalk On Rehab
			HD_Budget_WalkTriggerHelper.populateHDBudgetWalkOnRehab( trigger.new );
			//methd to update rehab stage
			HD_Budget_WalkTriggerHelper.updateRehab( trigger.new, trigger.oldMap );
		}

		if(trigger.isUpdate) {
			//call method to update rehab , pipeline and rehab on status changed to Submitted Or Approved
			HD_Budget_WalkTriggerHelper.updateOnSubmittedOrApproved( trigger.new, trigger.oldMap );
			//methd to update rehab stage
			HD_Budget_WalkTriggerHelper.updateRehab( trigger.new, trigger.oldMap );

			// method to update rehab stage on HD Budget walk Supervisor update from null to non null or reverse
			HD_Budget_WalkTriggerHelper.updateRehabOnWalkSupervisorChange( trigger.new, trigger.oldMap );

			//detach projected spend when budget walk gets cancelled
			HD_Budget_WalkTriggerHelper.detachRehabProjectedSpend( trigger.new, trigger.oldMap );
		}
	}
}