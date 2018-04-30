public without sharing class AcqProspectTriggerHelper {
    
    public static void updateOpportuniyStatus(List<Acq_Prospect__c> acqPros){
        
        List<Id> listIds = new List<Id>();
        for (Acq_Prospect__c childObj : acqPros) {
            listIds.add(childObj.Id);
         }
        List<Acq_Opportunity__c> oppListToUpdate  = new List<Acq_Opportunity__c>();
        for(Acq_Prospect__c pros : [SELECT Id, Status__c, name,IMG_Analyst__r.Id,IMG_Director__r.Id, Approved_Offer_Price__c,Director_IMG_Offer_Approval_Date__c,Opportunity__r.Name, Opportunity__r.Id from Acq_Prospect__c where Id IN : listIds]){
            if(pros.Status__c == 'Offer Approved'){
                Acq_Opportunity__c opp = new Acq_Opportunity__c(Id = pros.Opportunity__r.Id);
                opp.Broker_Offer_Status__c = 'IH Director Approved';
                opp.Broker_Offer_Price__c = pros.Approved_Offer_Price__c;
                opp.Offer_Price__c = pros.Approved_Offer_Price__c;
                opp.Director_IMG_Offer_Approval_Date__c = pros.Director_IMG_Offer_Approval_Date__c;
                opp.IMG_Analyst__c = pros.IMG_Analyst__r.Id;
                opp.IMG_Director__c = pros.IMG_Director__r.Id;
                oppListToUpdate.add(opp);
                
            }
    	}
        
        if(oppListToUpdate.size() > 0){
            update oppListToUpdate;
        }
 	}
    
    @InvocableMethod
    public static void updateLocationScore(List<ID> acqProsIDs) {
        Map<String, Decimal> locationScoreMap = new Map<String, Decimal>();
        for(Zip_code_reference__c score : Zip_code_reference__c.getAll().values())
        {
             locationScoreMap.put(score.Name , score.LocationScore__c);
        }
        List<Acq_Prospect__c> prospects = [SELECT ID, Address__r.Zip__c FROM Acq_Prospect__c WHERE ID in :acqProsIDs];
        for(Acq_Prospect__c prospect : prospects) {
            System.debug('Property Zip ' + prospect.Address__r.Zip__c);
            System.debug('Score is ' + locationScoreMap.get(prospect.Address__r.Zip__c));
            prospect.Location_Score__c = locationScoreMap.get(prospect.Address__r.Zip__c);            
        }
        update prospects;
        System.debug('Prospects after ' + prospects);
    }
    

}