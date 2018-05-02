/*********************************************************************************
 * Name             : Trigger_Rehab
 * Created By       : Jennifer Dauernheim(Appirio Consulting)
 * Created Date     : Feb 27, 2013
 * Purpose          : To process changes to processs Rehab records
 *                  V_1.0 - Added code to handle exceptions tin user friendly format
 *                  v_1.1 - Modified - 04/20/2015 - Removed method (updateListingRecords) - D-00013862
 *                  v_1.2 - 09/14/2015 - (populatePreleasedOnListing) - Abhinav Sharma - D-00014490
 *                  v_1.3 - 12/1/2016 - (updateRehabListingAgentEmailField) - Saurabh kumar -D-00016509
 *                  V_1.4 - Poonam Bhargava - 03/07/2017 - call helper class method updateDispositionInfoOnRehab - D-00016958
 *                  V_1.5 - Poonam Bhargava - 01/12/2018 - call helper class method populatePointCentralFieldOnRehabCreation - D-00017711
 *                  V_1.6 - Poonam Bhargava - 01/12/2018 - call helper class method populatePointCentralFieldOnResidenceFromRehab - D-00017711
***********************************************************************************/
trigger Trigger_Rehab on Rehab__c (after insert, after update, before insert, before update) {
 
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return;
  try {  
  if(Trigger_RehabHandler.isTrigger_RehabCalld) 
      return;
 
  if(Trigger.isafter)
  {
    if(Trigger.isInsert)
    {
        Trigger_RehabHandler.isTrigger_RehabCalld = true;
        Trigger_RehabHandler.onAfterInsert(Trigger.new); 
             
    }
    if(Trigger.isUpdate)
    {
        Trigger_RehabHandler.isTrigger_RehabCalld = true;
        Trigger_RehabHandler.populatePointCentralFieldOnResidenceFromRehab(Trigger.new, Trigger.oldMap);
        Trigger_RehabHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        
        //Added By - Abhinav Sharma - D-00014490 - 09/14/2015
        //Calling helper class method
        Trigger_RehabHandler.populatePreleasedOnListing(Trigger.new, Trigger.oldMap);
        
    }
  }
  /**Modified By: Kirti Agarwal*/
  if(Trigger.isbefore){
     if(Trigger.isInsert){
         
            Trigger_RehabHandler.onBeforeInsert(Trigger.new);
            
            //Added by Poonam Bhargava - 01/12/2018 - D-00017711
            Trigger_RehabHandler.populatePointCentralFieldOnRehabCreation(Trigger.new);
        }
         if(Trigger.isUpdate)
        {
             // Trigger_RehabHandler.isTrigger_RehabCalld = true;
              Trigger_RehabHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        
        //Added By -Saurabh kumar -
        //call method to update rehab :Listing Agent field as per listing 
        Trigger_RehabHandler.updateRehabListingAgentEmailField(Trigger.new); 
    
        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Added by Poonam Bhargava (03/07/2017) - D-00016958
            //Call the helper class method 
            Trigger_RehabHandler.updateDispositionInfoOnRehab(Trigger.new, Trigger.oldMap);
        } 

   }
   } catch(DMLException e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getDmlMessage(0));
        else
            Trigger.New[0].addError(e.getDmlMessage(0));

    //Catching all Exceptions
    } catch(Exception e) {

        //Add Error Message on Page
        if(Trigger.isDelete)
            Trigger.Old[0].addError(e.getMessage() + e.getStackTraceString());
        else
            Trigger.New[0].addError(e.getMessage());
    }     
}