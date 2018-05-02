public with sharing class TriggerAcqPipelineHelper {
    
     public static void updateBudWalk(List<AcqPipeline__c> acqPipe){
         
        List<Acq_Budget_Walk__c> budgetWalkToUpdate = new List<Acq_Budget_Walk__c>();
        List<Id> listIds = new List<Id>();
        for(AcqPipeline__c pipeRecId : acqPipe){
            listIds.add(pipeRecId.Prospect_Record__c);
        }
        List<Acq_Budget_Walk__c> budgetWalks = [SELECT ID FROM Acq_Budget_Walk__c 
                                                        WHERE Prospect_ID__c IN : listIds];
        for(AcqPipeline__c pipelineRecord : acqPipe) {
            if(pipelineRecord.doOrderBudgetWalk__c == true) {
                //Check if Budget walk is not already associated with it.
                //Get budget walk record associated with Prospect
                if(budgetWalks.size() > 0) {
                 for(Acq_Budget_Walk__c b1 : budgetWalks) {
                       b1.PipelineID__c = pipelineRecord.ID;
                            budgetWalkToUpdate.add(b1);
                   }
                }
            }
        }
        
        update budgetWalkToUpdate;
             
     }

}