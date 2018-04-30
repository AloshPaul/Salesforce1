/**
* @author Prashant Wayal
* @date 18-Feb-2015
* @description Trigger to update related rehab records
* @modified by : Saurabh kumar (5/27/2016) D-00015600 : method createRehabBasedOnRenewalStatus commented 
  Modified by Poonam Bhargava(06/19/2017) - D-00017170
  Modified by Saurabh Kumar(25-4-2017) - D-00017164
*/
trigger Trigger_Renewal on Renewal__c (after insert, after update) {
  
  if(trigger.isAfter) {
  
    if(Trigger.isUpdate || Trigger.isInsert){
    
      Trigger_RenewalHelper.updateRehabs(Trigger.New);
  
        //Added by Poonam Bhargava(06/19/2017) - D-00017170
      Trigger_RenewalHelper.populateRenewalCoordinatorOnLease(trigger.new, trigger.oldMap);
  
      if( Trigger.isUpdate ) {
        Trigger_RenewalHelper.closeCancelRehabsOnLeaseRenewal( Trigger.new, Trigger.oldMap );
      }
      
      //Abhinav Sharma -(5/6/2015)
      //commented based on D-00015600 :- This method has been depricated 
      // Trigger_RenewalHelper.createRehabBasedOnRenewalStatus(Trigger.New, Trigger.oldMap);

      // Saurabh Kumar - (25-4-2017) - D-00017164
      Trigger_RenewalHelper.updateListingWhenLeaseRenewed(Trigger.new, Trigger.oldMap);
      }  
  }    
}