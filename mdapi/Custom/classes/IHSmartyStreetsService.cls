/**
 * 	Description		:	This class is to validate the residence address data with Smarty Street. Validated address will be stored in fields.
 * 
 * 	Created by		:	Bhavi Sharma
 * 
 * 	Created Date	:	05/20/2013
 * 
 * 	Revision Logs	:	V_1.0 - Created
 * 
 **/ 

public with sharing class IHSmartyStreetsService {
	
	//Inner class to hold the validate address request object
	public class ValidateAddressRequest {
		
		//properties
		public Id recordId;
		public String street;
		public String city;
		public String state;
		public String zipcode;
		
		//Constructor
		public ValidateAddressRequest(Id recordId, String street, String city, String state, String zipcode) {
			
			//Assign into properties
			this.recordId = recordId;
			this.street = street;
			this.city = city;
			this.state = state;
			this.zipcode = zipcode;
		}
	}
	
	//Inner class to hold the validate address request object
	public class ValidateAddressResponse {
		
		//properties
		public Id recordId;
		public Boolean validateSuccess;
		public String errorMessage;
		public String street;
		public String city;
		public String state;
		public String zip;
		public String zipPlus4;
		public Double latitude;
		public Double longitude;
		public String county;
	}
	
	//This method is to get the current status of Samrty Street
	public static String getSmartyStreetsStatus() {
		
		//Get SmartyStreets_Configuration data
		SmartyStreets_Configuration__c config = Constants.SMARTY_STREETS_CONFIGURATION;
		
		//Return Off is SmartyStreets doesn't exist or SmartyStreetsActive = false
		if(config.SmartyStreetsActive__c == false)
			return Constants.STATUS_OFF;
		//Return "On" if SmartyStreetsActive = true and Current environment is Production
		else if(config.SmartyStreetsActive__c && config.ProdOrgRoot__c != null && UserInfo.getOrganizationId().containsIgnoreCase(config.ProdOrgRoot__c))
			return Constants.STATUS_ON;
		//Return "Sandbox" if SmartyStreetsActive = true and Current environment is not Production
		else if(config.SmartyStreetsActive__c && (config.ProdOrgRoot__c == null || !UserInfo.getOrganizationId().containsIgnoreCase(config.ProdOrgRoot__c)))
			return Constants.SANDBOX;
		//return "off" for all other cases
		else
			return Constants.STATUS_OFF;
	}
	
	//This property will be only used in scheduled job to check of schecduled jobs need to be executed
	public static Boolean IsActiveForOrg {
		get {
			//Get SmartyStreets_Configuration data
			SmartyStreets_Configuration__c config = Constants.SMARTY_STREETS_CONFIGURATION;
			
			//Return true if org is defined for validate
			if(config.ProdOrgRoot__c != null && UserInfo.getOrganizationId().containsIgnoreCase(config.ProdOrgRoot__c))
				return true;
			
			return false;
		}
	}
	
	//This method is to update the main record with the validated address recsponse
	public static void updateAddressValidationResults(List<ValidateAddressResponse> results) {
		
		//Check for the result size and call method accordingly
		if(results != null && results.size() > 0 && results[0].recordId != null) {
			
			//Check for sObject Type on the basis of Id and describing the sObjectType for information's
			Schema.SObjectType objectType = results[0].recordId.getSObjectType();
			
			//Check for the object type and call the appropriate method
			if(objectType == Schema.Residence__c.SObjectType) {
				
				//Update residence records
				ResidenceService.updateAddressValidationResults(results);
			} else if(objectType == Schema.AZB_Update__c.SObjectType) {
				
				//Update AZB update records
				AZB_UpdateService.updateAddressValidationResults(results);		
			}
		}
	}		 
}