/**
 *  Description :   This trigger is responsible for all the pre and post processing for Prospect records.
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   11/08/2012
 * 
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - Updated to update Region Data for Prospect. - Rajesh Shah - 12/08/2012
 *                  V1.2 - Added code to add method which validate the date -Vrajesh Sheth - 12/09/2012
 *                  V1.3 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  V1.4 - (01/28/2013) - Bhavi - updateRegionDataForProspect to be executed on insert and update event - D-00002244
 *                  V1.5 - (07/04/2013) - Bhavi - shareProspectWithCoworkers should be executed on after insert - D-00002244
 *                  V1.6 -  (09/02/2016) - Modified by Poonam Bhargava - D-00016126
 *					V1.7 - (11/03/2017) - Modified by Poonam Bhargava
 *                  
 **/ 

trigger Trigger_Prospect on Prospect__c (after insert, after update, before insert,before update) {
    
    try {
        
        //Execute the trigger only if required
        if(Constants.EXECUTE_TRIGGER == false
            || ProspectTriggerHelper.EXECUTE_PROSPECT_TRIGGER == false) 
            return;
        
        //Check for the request type
        if(Trigger.isAfter) { 
            
            //Check for the event type
            if(Trigger.isInsert) {
            
                //Calling helper class method
                ProspectTriggerHelper.shareProspectWithCoworkers(Trigger.New);
            }
            
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate) {
                
                //Calling Helper Class Method
                ProspectTriggerHelper.ProspectToPipelineConversion(Trigger.new, Trigger.old);
                
                //Added by Poonam Bhargava 11/03/2017
                //Calling Helper Class Method
                ProspectTriggerHelper.markedSWAYonResidence(Trigger.new);
            }
        }
        
        if(Trigger.isBefore){
             
            if(Trigger.isInsert) {
                //set defaults on azb prospect
                ProspectTriggerHelper.setAZBProspectDefultsFields(Trigger.New);
            }
                  
            //Check for the event type
            if(Trigger.isInsert || Trigger.isUpdate){
                
                
                //Update region data for Prospect
                ProspectTriggerHelper.updateRegionDataForProspect(Trigger.New, Trigger.oldMap);
                
                //validate the date fields
                ProspectTriggerHelper.validateAllDateField(Trigger.New);
                
                //Set Prospect Fields
                ProspectTriggerHelper.setProspectFields(Trigger.New, Trigger.oldMap);
                
                //Check for the required field for conversion
                ProspectTriggerHelper.validateBeforeConvert(Trigger.New, Trigger.oldMap);
                
                //method to populate residence field on prospect
                ProspectTriggerHelper.populateResidence(Trigger.New, Trigger.oldMap);
                
                //Added By Poonam Bhargava - D-00017166
                //Call the utility class method to populate Market field
                Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
                
            }       
        }
    } catch(DMLException e) {
        
        //Prepare a user friedly error message
        String failedRecordId = e.getDmlId(0);
        
        //Failue fields
        List<Schema.SObjectField> failureFields = e.getDmlfields(0);
        String failureMessage = e.getDmlMessage(0);
                       
        String errorMessage = '';
        if(failedRecordId != null && failedRecordId != '')
            errorMessage += 'Operation failed for ' + Label.SERVER_URL + failedRecordId + '. '; //Modified by Poonam Bhargava (09/02/2016) - D-00016126
        if(failureFields != null && failureFields.size() > 0) {
            
            errorMessage += failureFields[0].getDescribe().getLabel() + ': ';
        }
        if(failureMessage != null && failureMessage != '')
            errorMessage += failureMessage; 
        
        //Add error 
        Trigger.New[0].addError(errorMessage);
    } catch(Exception e) {
        
        //Add Error Message on Page
        Trigger.New[0].addError(e.getMessage());
    }
}