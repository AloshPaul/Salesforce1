trigger TriggerAcqOpportunity on Acq_Opportunity__c (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        
        for(Acq_Opportunity__c oppData: Trigger.new){
            if(oppData.CSV_Upload__c == FALSE){
               // system.debug('calling trigger if not csv upload ');
                 AcqOpportunityTriggerHelper.addMarketFromAddress(Trigger.new);
            }
           
        }
        
    }
    

}