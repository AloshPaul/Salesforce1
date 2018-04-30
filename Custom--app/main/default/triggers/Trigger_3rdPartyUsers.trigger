/**
 *  Description :   This trigger is responsiable for all the pre and post processing for 3rd Party users record
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   09/06/2012
 * 
 *  Revision Logs:  V1.1 - Updated By Vrajesh
 *  Last Updated Date:09/13/2012                 
 *                         
 **/ 
trigger Trigger_3rdPartyUsers on X3_Party_Users__c (after insert, after delete,before insert) {
    
    if(trigger.isInsert && trigger.isafter){
         
    }
    
    //Check for the request type
    if(Trigger.isAfter) {
        
        //Check for the event type
        if(Trigger.isInsert) {
        
            //Calling method to give sharing access to 3rd Party users to property records
            X3rdPartyUsersTriggerHelper.sharePropertyWith3rdPartyUsers(Trigger.New);
            list<id> recordIDList = new list<id>();
            for(X3_Party_Users__c newRecord : trigger.new){
                recordIDList.add(newrecord.id);
            } 
            //Add the BillCo users to BillCo Public User Group
            X3rdPartyUsersTriggerHelper.addUserintoPublicGroup(recordIDList);        
        } else if(Trigger.isDelete) {
            list<id> recordIDList = new list<id>();
            for(X3_Party_Users__c newRecord : trigger.Old){
                recordIDList.add(newrecord.id);
            }
            
            X3rdPartyUsersTriggerHelper.DeleteUserFromPublicGroup(recordIDList);
            //Calling method to give sharing access to 3rd Party users to property records
            X3rdPartyUsersTriggerHelper.removeSahringFor3rdPartyUsers(Trigger.Old);
             
        }
    }
}