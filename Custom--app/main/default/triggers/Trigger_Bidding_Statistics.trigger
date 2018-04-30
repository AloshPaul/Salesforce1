/**
 *  Description :   This trigger is responsiable for calling and population of "BiddingStatisticsTriggerHelper" helper 
 *                  class with values.
 *   
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   10/17/2012
 * 
 *  Revision Logs:  V1.0 - Created
 *               
 **/ 
trigger Trigger_Bidding_Statistics on Bidding_Statistics__c (before insert, before update, after insert, after update) {
    
    //Check wheather trigger need to be get executed
    if(Bidding_StatisticsTriggerHelper.EXECUTE_TRIGGER_BIDDING_STATISTICS) {
        
        try {
            //Check for the request type
            if(Trigger.isBefore) { 
                
                //Check for the event type
                if(Trigger.isInsert || Trigger.isUpdate) {
                
                    //Calling Helper Class Methods
                    //Chekc if methid need to be executed
                    if(Bidding_StatisticsTriggerHelper.EXECUTE_VALIDATE_BIDDING_STATISTICS_RECORDS)
                        Bidding_StatisticsTriggerHelper.validateBiddingStatisticsRecords(Trigger.New, Trigger.oldMap);
                    
                    //Bidding_StatisticsTriggerHelper.populateTotalNoOfHomesWonField(Trigger.New);
                    
                    //Added By Poonam Bhargava - D-00017166
                    //Call the utility class method to populate Market field
                    Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
                }
            } else if(Trigger.isAfter) {
                
                //check for the event type
                if(Trigger.isInsert) {
                    
                    //Attach bidding statistics records with pipeline
                    Bidding_StatisticsTriggerHelper.attachBiddingStatWithPipelines(Trigger.New);
                    
                    //Calling Helper Class Methods
                    Bidding_StatisticsTriggerHelper.createNationalRegion(Trigger.New);
                    
                    //Update Home Won count
                    //Bidding_StatisticsTriggerHelper.populateTotalNoOfHomesWonField(Trigger.New, Trigger.Old);
                } 
                
                //Chekc for the update
                if(Trigger.isUpdate) {
                    
                    //Attach bidding statistics records with pipeline
                    Bidding_StatisticsTriggerHelper.attachBiddingStatWithPipelines(Trigger.New);
                    
                    if(Bidding_StatisticsTriggerHelper.EXECUTE_VALIDATE_NATIONAL_REPORTING_RECORDS)
                        Bidding_StatisticsTriggerHelper.markNationalRegionComplete(Trigger.newMap, Trigger.oldMap);
                    //Bidding_StatisticsTriggerHelper.populateTotalNoOfHomesWonField(Trigger.New, Trigger.Old);
                }
            }
        } catch(Exception e) {
            
            //Add error on Page
            Trigger.New[0].addError(e.getMessage());
        }
    }
}