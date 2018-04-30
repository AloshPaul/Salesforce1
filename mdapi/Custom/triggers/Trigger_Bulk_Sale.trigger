/**
  * Description     :   Trigger on Bulk Deal object and event is before insert and before update.
  * 
  * Created By      :   Poonam Bhargava
  *  
  * Created Date    :   06/20/2017
  *  
  * Version         :   V_1.0
  *  
  * Revision Logs   :   V_1.0 - Created  
**/
trigger Trigger_Bulk_Sale on Bulk_Sale__c(before insert, before update) {

    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
        return ;

    //Check for the request type
    if(Trigger.isBefore) {

        //Check for the event type
        if(Trigger.isInsert || Trigger.isUpdate) {
            
            //Added By Poonam Bhargava - D-00017166
            //Call the utility class method to populate Market field
            Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
        }
    }
}