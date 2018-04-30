/**
 *  Description :   AZB Update Service Class.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   05/24/2013
 *
 *  Revision Logs:  V1.0 - Created
 *					
 *
 **/ 
public with sharing class AZB_UpdateService {
	
	//This method is to update the main record with the validated address recsponse
	public static void updateAddressValidationResults(List<IHSmartyStreetsService.ValidateAddressResponse> results) {
		
		//Create a list of residence records to be updated
		List<AZB_Update__c> aZBRecords = new List<AZB_Update__c>();
				
		//loop thorugh the response
		for(IHSmartyStreetsService.ValidateAddressResponse response : results) {
			
			//Create a clone of resedense
			AZB_Update__c aZB = new AZB_Update__c(Id = response.recordId);
				
			//Update validated data on residence
 			aZB.Address_Validated_Street__c = response.street;
			aZB.Address_Validated_City__c = response.city;
			aZB.Address_Validated_Zip__c = response.zip;
			aZB.Address_Validated_State__c = response.state;
			aZB.Address_Validated_Last_Attempt__c = DateTime.now();
			aZB.Address_Validated_Successfully__c = response.validateSuccess;
				
			//Other fields
			aZB.ZipPlus4__c = response.zipPlus4;
			aZB.Location__Latitude__s =  response.latitude;
			aZB.Location__Longitude__s =  response.longitude;
			aZB.Address_Validated_County__c = response.county;
			aZB.Address_Validation_Message__c = response.errorMessage;
				
			//Add response in the list to be updated
			aZBRecords.add(aZB);
		}
		
		//Check for the lis size and update tre records
		if(aZBRecords.size() > 0)
			update aZBRecords;
	}
}