trigger TriggerAcqPipeline on AcqPipeline__c (after insert) {
    
    
     if(Trigger.isAfter && Trigger.isInsert){
        TriggerAcqPipelineHelper.updateBudWalk(Trigger.new);
    }
    
    
}