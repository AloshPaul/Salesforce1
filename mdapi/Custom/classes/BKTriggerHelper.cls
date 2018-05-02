/**
 *  Description :   Helper class for Trigger_BK trigger.
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   09/25/2012
 * 
 *  Revision Logs:  V1.0 - Created
                   
 **/
 
public class BKTriggerHelper {

     //Method
     public static void newTaskForTransactionCoordinator(List<BK__c> listBK) {
     
         //List to Hold Tasks
         List<Event> newEventsList = new List<Event>();
        
         //Loop through New Records List
         for(Bk__c bk : [SELECT ID, Property__c, Property__r.Transaction_Coordinator__c, Property__r.Name,
                         Property__r.Property_City__c, Property__r.Property_State__c, Property__r.Property_Country__c,
                         Property__r.Property_Street__c, Property__r.Property_Zip_Code__c,
                         Trial_Hearing_Date__c,(Select Id from OpenActivities where IsTask = false)
                         FROM BK__c WHERE ID IN : listBK AND Property__r.Transaction_Coordinator__c != Null AND 
                         Trial_Hearing_Date__c != Null]) {
             
             //Check if there is already a Task, if not then create a new
             if(bk.OpenActivities == null || bk.OpenActivities.size() == 0) {
             
                 String propertyName = bk.Property__r.Name;
                 String propertyStreet = bk.Property__r.Property_Street__c;
                 String propertyCity = bk.Property__r.Property_City__c;
                 String propertyState = bk.Property__r.Property_State__c;
                 String propertyZipCode = bk.Property__r.Property_Zip_Code__c;
                
                //Add task in list
                newEventsList.add(new Event(OwnerId = bk.Property__r.Transaction_Coordinator__c, 
                                          WhatId = bk.Id,
                                          Subject = 'Trial Hearing Date is set your assigned' + ' ' + propertyName 
                                          + ' ' + '&' + ' ' + propertyStreet + ',' + ' ' + propertyCity 
                                           + ',' + ' ' + propertyState + ',' + ' ' + propertyZipCode, StartDateTime = bk.Trial_Hearing_Date__c, EndDateTime = bk.Trial_Hearing_Date__c));
             }
         }
         
         //Check for the size
        if(newEventsList.size() > 0)
            insert newEventsList;
     }
     
     
    //Update property Data
    public static void updateDataOnProperty(Map<Id, BK__c> newBKS, Map<Id, BK__c> oldBKS) {
        
        //Create a list of properties to be updated
        List<Property__c> properties = new List<Property__c>();
        
        //Loop through the properties
        for(BK__c bk : newBKS.values()) {
            
            //Email Statuses
            String emailStatuses = '';
            
            //Check all the attributes to be updated
            if(bk.Type__c == 'PostAcq BK' && (oldBKS == null || oldBKS.get(bk.Id).Type__c != bk.Type__c)) {
                
                //Add property to update
                emailStatuses = 'PostACQ BK';       
            } 
            
            //MFR Notification 
            if(bk.MFR_Lifted_Date__c != null && (oldBKS == null || oldBKS.get(bk.Id).MFR_Lifted_Date__c != bk.MFR_Lifted_Date__c)) {
                
                //Add property to update
                emailStatuses += 'MFR Lifted Date';     
            } 
            
            if(emailStatuses != '')
                properties.add(new Property__c(Id = bk.Property__c, Email_Statuses__c = emailStatuses));
        }
        
        //Check if there is data to update
        if(properties.size() > 0)
            update properties;
    }
}