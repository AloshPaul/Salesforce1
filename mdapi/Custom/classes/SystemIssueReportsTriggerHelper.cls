/**
 *  Description :   Helper class for Trigger_SystemIssueReports trigger.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   08/15/2012
 *
 *  Revision Logs:  V1.0 - Created
                    V1.1 - Modified by Abhinav Sharma for D-00000347 on 08/23/2012
                    V1.2 - New Method "newTaskforIssueProjectOwner" added by Abhinav Sharma on 08/27/2012
                    V1.3 - Existing Method "setEntitySubscription" modified By Abhinav Sharma for D-00000566 on 08/28/2012
                    V1.4 - New Methods creatNewTaskForSystemIssueReport,getRecordTypeID,getSIStatusAction added by Vrajesh Sheth for D-D-00000566 on 08/12/2012
                    V1.5 - Bhavi - 01/31/2013 - removed newTaskforIssueProjectOwner method
                    V1.6 - New Method "populateChildObjectData" added by Abhinav Sharma on 02/12/2013
                    V1.7 - Bhavi - 02/14/2013 - added populateSIRData
                    V1.8 - Bhavi - 03/18/2014 - Removed Box Code, Add Development_Owner__c as SIR Follower - D-00012065
 **/

public class SystemIssueReportsTriggerHelper {

    //This method is to populate the required/default data in SIR object before it saves in database
    public static void populateSIRData(List<Issues_New_Feature_Request__c> sIRs) {

        //get unallocated rollout
        List<SI_Rollout__c> rollouts = [Select Id from SI_Rollout__c where Name =: Constants.ROLLOUT_UNALLOCATED limit 1];

        //Check for teh size
        if(rollouts.size() > 0) {

            //Lopp through the SIRS
            for(Issues_New_Feature_Request__c sIR : sIRs) {

                //Check if Rollout is null and then populate the data
                if(sIR.Rollout__c == null)
                    sIR.Rollout__c = rollouts[0].Id;
            }
        }
    }

    //This method is to allow reviewer and project owner to automatically follow the record
     public static void setEntitySubscription(List<Issues_New_Feature_Request__c> listIssueNewFeatureRequest, Boolean isUpdate) {

        Id SalesforceAdministratorId = null;
        try {
            SalesforceAdministratorId = [Select id  From User where username =  'sfadmin@invitationhomes.com' LIMIT 1].id;
        } catch (Exception e) {
            // eat the exception if the Administrator isn't on the org/sandbox
        }
        //Define the list of new Subscribers
        List<EntitySubscription> newFollowers = new List <EntitySubscription>();

        //Map to hold teh users list against each user
        Map<Id, Set<Id>> issuesWithUsers = new Map<Id, Set<Id>>();

        //loop through the records and allow to follow
        for(Issues_New_Feature_Request__c issue : listIssueNewFeatureRequest) {

            //Create a set to hold the users
            Set<Id> setUsers = new Set<Id>();

            //add owner
            if (issue.ownerId != SalesforceAdministratorId )
                setUsers.add(issue.ownerId);

            //Add owner as followers
            if(issue.Project_Owner__c != null && issue.Project_Owner__c != SalesforceAdministratorId )
                setUsers.add(issue.Project_Owner__c);
            if(issue.Development_Owner__c != null && issue.Development_Owner__c != SalesforceAdministratorId)
                setUsers.add(issue.Development_Owner__c);
            if(issue.Reviewer__c != null && issue.Reviewer__c != SalesforceAdministratorId)
                setUsers.add(issue.Reviewer__c);

            /* Task Owner added as follower by Abhinav Sharma for D-00000347 on 08/23/2012 */

            //Add Task_Owner__c as follower
            if(issue.Task_Owner__c != null && issue.Task_Owner__c != SalesforceAdministratorId )
                setUsers.add(issue.Task_Owner__c);

            //Add in map
            issuesWithUsers.put(issue.Id, setUsers);
        }

        //Create a set of all the users and fetch data from data base
        Set<Id> allFollowers = new Set<Id>();

        //Create a set to maintain the existing a data
        Set<String> existingES = new Set<String>();

         //Check is trigger is running for update event
        if(isUpdate) {

            //Loop through the followers by records
            for(Set<Id> ids : issuesWithUsers.values() ) {
                allFollowers.addAll(ids);
            }

            //Get all records from database
            for(EntitySubscription eS : [Select Id, SubscriberId, ParentId from EntitySubscription where SubscriberId IN: allFollowers
                                            AND ParentId IN: issuesWithUsers.keySet()]) {

                //Add in set
                existingES.add(eS.SubscriberId + '-' + eS.ParentId);
            }
        }

        //loop through the map and add record in database
        for(Id issueId : issuesWithUsers.keySet()) {

            //loop through the users
            for(Id userId : issuesWithUsers.get(issueId)) {

                //Check if the record is already being followed
                if(!existingES.contains(userId + '-' + issueId)) {
                    newFollowers.add(new EntitySubscription(SubscriberId = userId, ParentId = issueId));
                }
            }
        }

        //Check for the size
        if(newFollowers.size() > 0)
            Database.insert(newFollowers, false);
   }

    //Method to insert a new task once the status of System Issue Report is chnaged
   /** public static void creatNewTaskForSystemIssueReport(List<Issues_New_Feature_Request__c> newValueList,Map<Id,Issues_New_Feature_Request__c> oldvalueMap){

        //Create a Map to hold SI Status Actions
        Map<String, SI_Status_Action__c> mapSIStatusAction = new Map<String, SI_Status_Action__c>();

        //Create a set of SIRs Ids
        Set<Id> sIRIds = oldvalueMap.keyset();

        //Create a Map of Task to hold SIR ID and List of Task
        Map<Id, List<Task>> mapSIRIdWithTasks = new Map<Id, List<Task>>();

        //Fetch all the open tasks associated with these SIRa
        for(Task task : [Select Id, SIR_ID__c, IsClosed from Task where SIR_ID__c =: sIRIds AND IsClosed = false ]) {

            //Populate the Map
            if(mapSIRIdWithTasks.containsKey(task.SIR_ID__c)) {

                //Put in Map
                mapSIRIdWithTasks.get(task.SIR_ID__c).add(task);
            } else {

                //Put in Map
                mapSIRIdWithTasks.put(task.SIR_ID__c, new List<Task>{task});
            }
        }

        //Get Status Action and loop through the records
        for(SI_Status_Action__c sIAction : [SELECT Id, Current_Status__c, Sequence__c, Status_After_Task_Failure__c, Status_After_Task_Success__c,
                                                            Task_Recipient__c FROM  SI_Status_Action__c where Current_Status__c != null]) {

            //Populate data in Map
            mapSIStatusAction.put(sIAction.Current_Status__c, sIAction);
        }

        //Create a list of tasks to be created
        List<Task> tasks = new List<Task>();

        //Check if Status actions are defined
        if(mapSIStatusAction.size() > 0) {

            //Fetch the Queues and Group Member
            Map<String, Set<Id>> mapGroupMembers = new Map<String, Set<Id>>();

            //Get all teh Group Member from QA queue and System Admin Queue
            for(GroupMember gM : [Select Group.Name, UserOrGroupId from GroupMember where Group.Name = 'QA Queue' OR Group.Name = 'SysAdmin Queue']) {

                //Add in Map
                if(mapGroupMembers.containskey(gM.Group.Name))
                    mapGroupMembers.get(gM.Group.Name).add(gM.UserOrGroupId);
                else
                    mapGroupMembers.put(gM.Group.Name, new Set<Id>{gM.UserOrGroupId});
            }

            //Loop through the new SIRs
            for(Issues_New_Feature_Request__c systemIssueReport : newValueList){

                //Check if SIR status have been changed
                if(systemIssueReport.Status__c != null
                    && systemIssueReport.Status__c != (oldvalueMap.get(systemIssueReport.id)).Status__c) {

                    //Get the status action
                    SI_Status_Action__c statusAction = mapSIStatusAction.get(systemIssueReport.Status__c);

                    //Check if there is any open task earlier
                    if(mapSIRIdWithTasks.containsKey(systemIssueReport.Id)) {

                        //Loop through the existing open tasks
                        //Mark all other tasks as completed as new tasks in being cretaed for this status
                        for(Task task : mapSIRIdWithTasks.get(systemIssueReport.Id)) {

                            //Mark this task as completed
                            task.Status = 'Completed';

                            //Add the record in list to be updated
                            tasks.add(task);
                        }
                    }

                    //check if new task bneed to be created
                    if(mapSIStatusAction.containsKey(systemIssueReport.Status__c)) {

                        //get mapSIStatusAction instance
                        SI_Status_Action__c sIStatusAction = mapSIStatusAction.get(systemIssueReport.Status__c);

                        //check if Task recepient is not blank
                        if(sIStatusAction.Task_Recipient__c != null) {

                            //If teh task recipient is a queue, then create task separately for each member
                            if(mapGroupMembers.containsKey(sIStatusAction.Task_Recipient__c)) {

                                //Get all the queue members
                                for(Id userId : mapGroupMembers.get(sIStatusAction.Task_Recipient__c)) {

                                    //Create a new Task
                                    Task newTask = new Task(WhatId = systemIssueReport.Id, Status = 'Not Started', Type = 'Other', ActivityDate = Date.today() + 1,
                                                                Subject = systemIssueReport.Name+' '+systemIssueReport.Status__c,
                                                                SIR_ID__c = systemIssueReport.Id,
                                                                SIR_Status__c = systemIssueReport.Status__c,
                                                                OwnerId = userId,
                                                                Description = 'You have been assigned a task related to System Issue ' + systemIssueReport.Name + ' which has been moved into status:' + systemIssueReport.Status__c + '.  Please close when complete');

                                    //Add task in the list to be updated
                                    tasks.add(newtask);
                                }
                            } else {

                                //If task recipient is an individual user, then create task based on task recipient
                                Task newTask = new Task(WhatId = systemIssueReport.Id, Status = 'Not Started', Type = 'Other', ActivityDate = Date.today() + 1,
                                                            Subject = systemIssueReport.Name+' '+systemIssueReport.Status__c,
                                                            SIR_ID__c = systemIssueReport.Id,
                                                            SIR_Status__c = systemIssueReport.Status__c,
                                                            Description = 'You have been assigned a task related to System Issue ' + systemIssueReport.Name + ' which has been moved into status:' + systemIssueReport.Status__c + '.  Please close when complete');

                                if(statusAction.Task_Recipient__c == 'Issue Reviewer' && systemIssueReport.Reviewer__c != null){
                                    newTask.ownerId = systemIssueReport.Reviewer__c;
                                } else if(statusAction.Task_Recipient__c == 'Issue Creator'){
                                    newTask.ownerid = systemIssueReport.ownerId;
                                } else if(statusAction.Task_Recipient__c == 'Issue Project Owner' && systemIssueReport.Project_Owner__c != null){
                                    newTask.ownerid = systemIssueReport.Project_Owner__c;
                                }

                                //Create the task only if recepient is defined
                                if(newTask.ownerId != null)
                                    tasks.add(newTask);
                            }
                        }
                    }
                }
            }

            //Check for the task size
            if(tasks.size()>0) {

                //Insert tasks
                upsert tasks;
            }
        }
    }**/

    //method to populate child object data
    public static void populateChildObjectData(List<Issues_New_Feature_Request__c> newSIRList) {

        //List of DCR's going to be update later
        List<SObject> parents = new List<SObject>();

        //Loop through SIR records
        for(Issues_New_Feature_Request__c sir : newSIRList) {

            //Check for appropriate match
            if(sir.ChildObject__c != null) {

                //Type cast sir.ChildObject__c as an ID
                Schema.SObjectType parentObj = Id.valueOf(sir.ChildObject__c).getSObjectType();

                //describe parent Obejct
                Schema.DescribesObjectResult parentDescribedObj = parentObj.getDescribe();

                //Create the Field Map for Parent object
                Map<String, Schema.SObjectField> fieldMap = parentDescribedObj.fields.getMap();

                //Instantiate a new record
                SObject sObj = parentObj.newSObject(Id.valueOf(sir.ChildObject__c));

                //Loop through the Fields
                for(Schema.SobjectField fieldType : fieldMap.values()) {

                    //Describe field
                    Schema.DescribeFieldResult descField = fieldType.getDescribe();

                    //Check for the Data Type and Refernece to
                    if(descField.getType() == DisplayType.REFERENCE && descField.getReferenceTo()[0] == Schema.Issues_New_Feature_Request__c.SObjectType) {

                        //Update reference field
                        sObj.put(fieldType, sir.Id);
                    }
                }

                //add record in parent
                parents.add(sObj);
            }
        }

        //Check for size
        if(parents.size() > 0) {

            //Update
            update parents;
        }
    }
}