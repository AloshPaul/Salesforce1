/**
 *  Description :   This trigger is responsiable for calling and population of "SystemIssueReportsTriggerHelper" helper
                    class with values.
 *
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   08/15/2012
 *
 *  Revision Logs:  V1.0 - Created/
 *                  V1.1 - Added ne/w method creatNewTaskForSystemIssueReport for Task D-00000994 by Vrajesh Sheth on 08/12/2012
 *                       - Commented newTaskforIssueProjectOwner Method as it throws some exception
 					V1.2 - Bhavi - 02/14/2014 - Added new event type(before insert)
 					V1.3 - Bhavi - 03/18/2014 - Removed Box Code - D-00012065
 **/
trigger Trigger_SystemIssueReports on Issues_New_Feature_Request__c (before insert, after insert, after update) {

    //Check for teh request type
    if(Trigger.isBefore) {

    	//Check for teh event type
    	if(Trigger.isInsert) {

    		//Call helper class method to popiulate the default data
    		SystemIssueReportsTriggerHelper.populateSIRData(Trigger.New);
    	}
    }

    //Check for the request type
    else if(Trigger.isAfter) {

        //Check for the event type
         if(Trigger.isInsert || Trigger.isUpdate) {

            //Call Helper class method
            SystemIssueReportsTriggerHelper.setEntitySubscription(Trigger.New, Trigger.isUpdate);

            //Check for event type
            if(Trigger.isInsert) {

                //Call Helper class method to populate child Object data
                SystemIssueReportsTriggerHelper.populateChildObjectData(Trigger.New);
            }
        }
    }
}