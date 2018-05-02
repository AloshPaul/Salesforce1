/**
  *	Description		:	Trigger on Violation object and event is before insert and before update.
  *
  *	Created By		:	Abhinav Sharma
  *
  *	Created Date	:	08/25/2015
  *
  *	Version			:	V_1.0	
  *
  *	Revision Logs	:	V_1.0 - Created	
**/
trigger Trigger_Violation on Violations__c (before insert, before update) {

	//Check the event
	if(Trigger.isBefore) {
		
		//Check the request type
		if(Trigger.isInsert || Trigger.isUpdate){
			
			//Call the helper class method
			ViolationTriggerHelper.populatePMEmailBasedOnPortfolio(Trigger.new, Trigger.oldMap) ;
		}
	}
}