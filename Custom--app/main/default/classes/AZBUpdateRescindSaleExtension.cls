public with sharing class AZBUpdateRescindSaleExtension {
	
	ApexPages.StandardController ctrl;
	
	// Constructor
	public AZBUpdateRescindSaleExtension(ApexPages.StandardController stdController){
		if(stdController == null || stdController.getId() == null) {
			VFUtil.AddErrorMessage('No AZB update record passed to the page.');
			return;
		}
		ctrl = stdController;
	}
	
	// Function to Rescind Sale	
	public PageReference rescindSale() {
		
		Savepoint sp = Database.setSavepoint();	
		try {
			if(ctrl != null) {
				Boolean updateProspect = false;
				Boolean updatePipeline = false;
				Boolean updateResidence = false;
				
				// Get AZB Update record detail
				AZB_Update__c azbUpdate = [Select IH_Pipeline__c, IH_Prospect__c, AZB_ID__c from AZB_Update__c 
																							where Id = : ctrl.getId()];
																							
				// Check if record is already rescinded.
				if(String.isNotBlank(azbUpdate.AZB_ID__c) && azbUpdate.AZB_ID__c.contains('-R')) {
					VFUtil.AddErrorMessage('This sales has already been rescinded; it cannot be rescinded again.');
					return null;	
				}
																											
				// Update Prospect
				Prospect__c prospect;
				if(azbupdate.IH_Prospect__c != null) {
					prospect  = [Select Prospect_Status__c, Residence__c, IsConverted__c from Prospect__c 
																						where Id = :azbupdate.IH_Prospect__c];
					if(!prospect.IsConverted__c) {
						prospect.Prospect_Status__c = 'Dead - Cancelled';
						updateProspect = true;
					}
				}
				
				// Update Pipeline
				Property_Opportunity__c pipeline ;
				if(azbupdate.IH_Pipeline__c != null) {	 
					 
					pipeline = [Select IsConverted__c, Stage__c from Property_Opportunity__c where Id = :azbupdate.IH_Pipeline__c];
					
					if (pipeline.IsConverted__c) {
						List<Property__c> portfolio = [Select Acquisition_Status__c from Property__c 
																					where Pipeline__c = :pipeline.Id
																					and Acquisition_Status__c != 'Cancelled'];
						if(portfolio != null && portfolio.size() > 0) {
							VFUtil.AddErrorMessage('You may not rescind a sale that is already converted to an active Portfolio record.'
														+ ' Contact Asset Management to cancel the Portfolio record.');
							return null;
						}
						else {
							pipeline.Stage__c = 'Dead - Cancelled';
							updatePipeline = true;
						}
					}
					else {
						pipeline.Stage__c = 'Dead - Cancelled';
						updatePipeline = true;
					}
				}
				
				// Update AZB ID 
				String azbId = azbupdate.AZB_ID__c + '-R%';
				System.debug('abxID: ' + azbId);
				List<AZB_Update__c> prevAZBRecs = [select Id from AZB_Update__c where AZB_ID__c like :azbId];
				
				azbUpdate.AZB_ID__c += (prevAZBRecs == null || prevAZBRecs.size() == 0) ? '-R' : '-R' + prevAZBRecs.size();
				
				// Update Residence
				Residence__c residence;
				if(prospect != null && prospect.Residence__c != null) {
					residence = new Residence__c(Id = prospect.Residence__c);
					residence.Atlanta_Auction__c = false;
					residence.Win_Date__c = null;
					updateResidence = true;
				}
				
				// Update the records
				update azbUpdate;
				
				if(updateProspect)
					update prospect;
					
				if(updatePipeline)
					update pipeline;
				
				if(updateResidence)
					update residence;
				
				PageReference azpPage = ctrl.view();
				azpPage.setRedirect(true);
				return azpPage;
			}
		}
		catch(Exception e) {
			Database.rollback(sp);	
			VFUtil.AddErrorMessage('You may not rescind sales outside your own region.');
		}
		return null;
	}	
}