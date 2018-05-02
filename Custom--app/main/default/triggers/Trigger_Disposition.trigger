/**
  *    Description     :    Trigger on Disposition object and event is before insert and before update.
  * 
  *    Created By      :    Abhinav Sharma
  *  
  *    Created Date    :    05/27/2015
  *  
  *    Version         :    V_1.0
  *  
  *    Revision Logs   :    V_1.0 - Created  
                V_1.1 - Abhinav Sharma - 9/12/2015  - D-00014489   
                V_1.2 - Saurabh Kumar  - 6/27/2016 - D-00015414 Added Trigger Skip Statement 
                V_1.3 - Saurabh Kumar  - 8/9/2016  - D-00016020 Call a new method :-updateRenewalBasedonDispo
                V_1.4 - Poonam Bhargava - 03/07/2017 - call helper class method populateListingRehabFieldsBasedOnDisposition - D-00016958
                //V_1.5 - Poonam Bhargava - 06/29/2017 - call helper class method updateYardiFlagTrueOnAttributeChange - (D-00017213)
**/
trigger Trigger_Disposition on Disposition__c(before insert, before update, after insert, after update,after delete){

    //Execute the trigger only if required
     if(Constants.EXECUTE_TRIGGER == false || DispositionTriggerHelper.isTrigger_DispositionHandler)
       return;
    //Check the event
    //Check the event
    if(Trigger.isBefore){
    
        //Check for request type
        if(Trigger.isInsert || Trigger.isUpdate) {
        
            //Call the helper class method
            DispositionTriggerHelper.populateDataFromResidence(Trigger.new, Trigger.oldMap);
            
            //Call the helper to Validate Disposition 
            DispositionTriggerHelper.validateDisposition(Trigger.new, Trigger.oldMap); 
            
            //Call the helper class method - (D-00017213)
           // DispositionTriggerHelper.updateYardiFlagTrueOnAttributeChange(Trigger.new, Trigger.oldMap); 
        }
    }
    if(Trigger.isAfter) {
    
        //check for request type
        if(Trigger.isInsert) {
            
            //Added by Abhinav Sharma (D-00014489) 9/12/2015
            //call the helper class method
            DispositionTriggerHelper.mostRecentDispositionOnResidence(Trigger.new);
        }
        //Check for request type
        if(Trigger.isInsert || Trigger.isUpdate) {
          
            //Call the helper class method
            DispositionTriggerHelper.populateDataOnRenewalBasedOnDisposition(Trigger.new, Trigger.oldMap);
            DispositionTriggerHelper.updateRenewalBasedonDispo(Trigger.new, Trigger.oldMap);
        }
        
        
        //Check for delete request Type
        if(Trigger.isDelete){
            //added by saurabh on 10/7/2015
            //Call the helper class method 
            DispositionTriggerHelper.updatePortfolioafterDispositionDeleted(Trigger.oldMap);
        
        }

        //Check for request type
        if(Trigger.isUpdate) {
          
            //Added by Poonam Bhargava (03/07/2017) - D-00016958
            //Call the helper class method 
            DispositionTriggerHelper.populateListingRehabFieldsBasedOnDisposition(Trigger.new, Trigger.oldMap);
        }
    }
}