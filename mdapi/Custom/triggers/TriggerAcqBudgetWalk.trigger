trigger TriggerAcqBudgetWalk on Acq_Budget_Walk__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
          AcqBudgetWalkTriggerHelper.createResidence(Trigger.new);
       
        
        }
    
}