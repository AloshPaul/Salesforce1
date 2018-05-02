/**
 *  Description :   This class is to call methods from Javascript.
 *
 *  Created By  :   Bhavi Sharma
 *
 *  Created Date:   12/22/2012
 *
 *  Revision Logs:  V1.0 - Created
 *
 **/
public without sharing class Override_AcqReportingNewController {
	
	//Standard controller
	public Override_AcqReportingNewController(ApexPages.StandardController controller) {
		
	}
	
	//Get user region
	public PageReference validateRedirect() {
		
		//Get user region
		User user = [Select Id, Region__c from User where Id =: UserInfo.getUserId()];
		
		//redirect to page
		PageReference pageRef = new PageReference('/' + Bidding_Statistics__c.sObjectType.getDescribe().getKeyPrefix() + '/e');
		
		//Add parameters
		pageRef.getParameters().put('retURL', '/' + Bidding_Statistics__c.sObjectType.getDescribe().getKeyPrefix());
		pageRef.getParameters().put(Constants.VIEW_CONFIGURATION.Acquisition_Reporting_Region__c, user.Region__c);
		pageRef.getParameters().put('nooverride', '1');
		
		//return
		return pageRef;
	}
}