/**
 *  Description :   Helper class for property issues trigger.
 *
 *  Created By  :   Shirnath 
 *
 *  Created Date:   01/12/2016
 *
 *  Revision Logs:  V1.0 - Created
 *					V1.1 - Modified By Poonam Bharagav - (D-00017166)
 *  Code Coverage - 100%
 **/
 public without sharing class Property_IssuesTriggerHelper {

    //This flag is to control the execution of Property Trigger
    public static Boolean EXECUTE_PROPERTY_TRIGGER = true;
     
    public static void setPropertyIssueWhatRegion(List<Property_Issues__c> propertyIssues) {
        
        // when current user is Formstack API user
        if( Userinfo.getUserName().equalsIgnoreCase( Label.Username_For_Formstack_ApiUser ) || Test.isrunningTest()) {
            
            List<Property_Issues__c> listAllowedPropertyIssues = new List<Property_Issues__c>();
            Set<String> setZipCodes = new Set<String>(); 
            for( Property_Issues__c pi : propertyIssues ) {
                if( pi.Postal_Code_Web_Submission__c != null ) {
                    
                        listAllowedPropertyIssues.add( pi );
                        setZipCodes.add( pi.Postal_Code_Web_Submission__c );
                    
                }
            }
            
            if( setZipCodes.size() > 0 ) {
                Map<Id, Property__c> mapProperty = new Map<Id, Property__c>( [ Select Region__c, Property_Zip_Code__c
                                                                               From Property__c
                                                                               Where Property_Zip_Code__c in: setZipCodes   
                                                                              ]);
                
                Map<String, String> mapZipcodeToRegion = new Map<String, String>();
                for( Property__c propertyObj : mapProperty.values()) {
                    mapZipcodeToRegion.put( propertyObj.Property_Zip_Code__c, propertyObj.Region__c );
                }
                
                Map<String, String> mapRegionToStateWebSubmission = new Map<String, String>();
                
                // loop over custom metadata for Region State Web Submission Mappings
                for( Region_To_State_Web_Submission_Mapping__mdt objRegionSWSMapping : [ Select Region__c, 
                                                                                            State_Web_Submission__c
                                                                                        From Region_To_State_Web_Submission_Mapping__mdt
                                                                                        Where Region__c !=: NULL 
                                                                                        AND State_Web_Submission__c !=: NULL] ) {
                                                                                        
                    mapRegionToStateWebSubmission.put( objRegionSWSMapping.Region__c.trim().toLowerCase(), objRegionSWSMapping.State_Web_Submission__c );
                }
                
                // loop over property issues
                for( Property_Issues__c pi : listAllowedPropertyIssues ) {
                    // when mapZipcodeToRegion has value for the zipcode
                    if( mapZipcodeToRegion.containsKey( pi.Postal_Code_Web_Submission__c )) {
                        String regionForZipcode = mapZipcodeToRegion.get( pi.Postal_Code_Web_Submission__c );
                        // when region found from zip is not equals to What_Region_does_issue_Impact__c 
                        if( regionForZipcode != null && pi.What_Region_does_issue_Impact__c != regionForZipcode ) {
                            // when mapRegionToStateWebSubmission has value for the region
                            if( mapRegionToStateWebSubmission.containsKey( regionForZipcode.trim().toLowerCase() )) {
                                String stateWebSubmission = mapRegionToStateWebSubmission.get( regionForZipcode.trim().toLowerCase() ); 
                                if( stateWebSubmission != null ) {
                                    pi.State_Web_Submission__c = stateWebSubmission;
                                    pi.What_Region_does_issue_Impact__c = regionForZipcode;
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
	//Added by Poonam Bhargava  - D-00017166
	/**
	*	@description	:	Method to populate 'Market' field on Property Issues from Residence/Pipeline/Portfolio's Market field
	*
	*	@arg			:	List<Property_Issues__c> propertyIssues, Map<Id, Property_Issues__c> mapOldIssues
	*
	*	@return			:	Void  
	**/
    public static void populateMarketfromPortfolio(List<Property_Issues__c> propertyIssues, Map<Id, Property_Issues__c> mapOldIssues){
    
    	//Set to hold Portfolio Ids
    	Set<Id> setOfPortfolioIds = new Set<Id>(); 
    	
    	//Set to hold Residence Ids
    	Set<Id> setOfResidenceIds = new Set<Id>();
    	
    	//Set to hold P Ids 
    	Set<Id> setOfPipelineIds = new Set<Id>(); 
    	
    	//Loop over trigger.new list	
    	for(Property_Issues__c pI : propertyIssues){
    	
    		//Check for null value in Region and Market field	
    		if(pI.Region__c != null && pI.Market__c == null){
    		
    			//Check for Residence null value and populate set accordingly with residence ids
    			if(pI.Residence__c  != null)
    				setOfResidenceIds.add(pI.Residence__c);
    			
    			//Check for Pipeline null value and populate set accordingly with Pipeline ids
	    		else if(pI.Pipeline__c  != null)
	    			setOfPipelineIds.add(pI.Pipeline__c);
	    		
	    		//Check for Portfolio null value and populate set accordingly with Portfolio ids	
	    		else if(pI.Portfolio__c != null)
	    			setOfPortfolioIds.add(pI.Portfolio__c);	
	    		
	    		//Check for web submission field value and populayte market accordingly]
	    		else if(pI.Web_Submission__c)
    				pI.Market__c = pI.What_Region_does_issue_Impact__c;	
    		}	
    	}
    	
    	//Map to hold Residence Id with Residence records
    	Map<Id, Residence__c> mapResidence;
    	
    	//Map to hold Portfolio Id with Portfolio Record
      	Map<Id, Property__c> mapPortfolio;
 
 		//Map to hold Pipeline Id with Pipeline records
     	Map<Id, Property_Opportunity__c> mapPipeline;
    	
    	//Check for setOfResidenceIds set size and populate map mapResidence accordingly 
    	if(setOfResidenceIds.size() > 0)
    			mapResidence = new Map<Id, Residence__c>([SELECT Id, Market__c FROM Residence__c WHERE Id IN: setOfResidenceIds]);
    			
    	//Check for setOfPipelineIds set size and populate map mapPipeline accordingly
    	if(setOfPipelineIds.size() > 0)
    			mapPipeline = new Map<Id, Property_Opportunity__c>([SELECT Id, Market__c FROM Property_Opportunity__c WHERE Id IN: setOfPipelineIds]);
    		
		//Check for setOfPortfolioIds set size and populate map mapPortfolio accordingly
    	if(setOfPortfolioIds.size() > 0)
    			mapPortfolio = new Map<Id, Property__c>([SELECT Id, Market__c FROM Property__c WHERE Id IN: setOfPortfolioIds]);
    	
    	//Loop over proeprty issue records	
    	for(Property_Issues__c pI : propertyIssues){
    		
    		//Check for null value in Region and Market field	
    		if(pI.Region__c != null && pI.Market__c == null){
    		
    			//Check for Residence null value and populate Market field on YRR accordingly
    			if(pI.Residence__c  != null && mapResidence != null && mapResidence.containsKey(pI.Residence__c))
    				pI.Market__c = mapResidence.get(pI.Residence__c).Market__c;
    			
    			//Check for Pipeline null value and populate Market field on YRR accordingly
	    		else if(pI.Pipeline__c  != null && mapPipeline != null && mapPipeline.containsKey(pI.Pipeline__c))
	    			pI.Market__c = mapPipeline.get(pI.Pipeline__c).Market__c;
	    		
	    		//Check for Portfolio null value and populate Market field on YRR accordingly	
	    		else if(pI.Portfolio__c != null && mapPortfolio != null && mapPortfolio.containsKey(pI.Portfolio__c))
	    			pI.Market__c = mapPortfolio.get(pI.Portfolio__c).Market__c;	
    		}	
    	}
    }
}