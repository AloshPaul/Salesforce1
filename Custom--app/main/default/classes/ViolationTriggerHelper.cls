/** Description         :  Trigger helper class to populate PM Email field based on Portfolio's Email.
  * 
  * Created Date        :   08/25/2015
  *
  * Created By          :   Abhinav Sharma 
  *  
  * Version             :   V_1.0 
  * 
  * Revision Logs       :   V_1.0 - Created 
**/
public without sharing class ViolationTriggerHelper {

    /**
      * @Description    :   Method for maintain violation field  "PM Email" values.
      *
      * @arg            :   List of new violation, map of old violation.
      *
      * @return         :   Void
    **/
    public static void populatePMEmailBasedOnPortfolio(List<Violations__c> newViolation, map<Id, Violations__c> oldViolation){
    	
    	//Set to hold Portfolio ids
    	Set<Id> setPortfolioIds = new Set<Id>();
    	
        //Loop through voildation records
    	for(Violations__c vio : newViolation) {
    		
    		//Checking for null condition
    		if(vio.Portfolio__c != null)
    			setPortfolioIds.add(vio.Portfolio__c);	
    	}
    	
    	//Checking for set size
    	if(setPortfolioIds.size() > 0){
    		
    		//Map to hold portfolios 
    		Map<Id, Property__c> mapPortfolios = new Map<Id, Property__c>([Select Id, OwnerId, Owner.Email, Owner.Type, 
                                                                           Owner.IsActive from Property__c 
                                                                           where Id IN : setPortfolioIds]); 
        
			//Loop through Trigger.new list
			for(Violations__c vio : newViolation){
			
				//Check for null
				if(vio.Portfolio__c != null && mapPortfolios != null
					&& mapPortfolios.containsKey(vio.Portfolio__c) && mapPortfolios.get(vio.Portfolio__c) != null) {
				    
				    //Check for condition and populate violation field
				    if(mapPortfolios.get(vio.Portfolio__c).OwnerId != null
                    	&& mapPortfolios.get(vio.Portfolio__c).Owner.Type != 'Queue' 
				    	&& mapPortfolios.get(vio.Portfolio__c).Owner.IsActive != null
                      	&& mapPortfolios.get(vio.Portfolio__c).Owner.IsActive) {
				        vio.PM_Email__c = mapPortfolios.get(vio.Portfolio__c).Owner.Email;
				    }
				    else
				        vio.PM_Email__c = null;       
				}   
			}
    	}
    }
}