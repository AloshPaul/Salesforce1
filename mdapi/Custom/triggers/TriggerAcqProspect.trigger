trigger TriggerAcqProspect on Acq_Prospect__c (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        AcqProspectTriggerHelper.updateOpportuniyStatus(Trigger.new);
    }
    
}