/**
 *   Description  :  Controller Class for VFP RehabProjectedSpend
 *
 *   Created By Shrinath
 *
 *   Created Date:  02/02/2014
 *
 *   Revision Logs:  V1.0 - Created
 **/
 public without sharing class GL_Code_Service {

	private static Map<Id, RecordType> mapRehabRecordType;

	// method to get type adjusted GL Code from Associated Rehab
	public Static String getTypeAdjustedGLCode( GL_Code__c glCodeObj, Rehab__c rehabObj ) {

		if( mapRehabRecordType == null ) {
			mapRehabRecordType = new Map<Id, RecordType>( [Select Id, Name
															  From RecordType
														   Where SObjectType = 'Rehab__c']
														  );
		}

		String recordTypeName = rehabObj.RecordType.Name;
		if( recordTypeName == null && rehabObj.RecordTypeId != null && mapRehabRecordType.containsKey( rehabObj.RecordTypeId )) {
		 	recordTypeName = mapRehabRecordType.get( rehabObj.RecordTypeId ).Name;
		}

		if( recordTypeName != null && recordTypeName == 'Post-Acquisition' ) {
			return  ( glCodeObj.GL_Code_Acquisition__c != null && glCodeObj.GL_Code_Acquisition__r.Name != null ) ? glCodeObj.GL_Code_Acquisition__r.Name : glCodeObj.Name;
		}
		else {
			return ( glCodeObj.GL_Code_Turn__c != null && glCodeObj.GL_Code_Turn__r.Name != null ) ? glCodeObj.GL_Code_Turn__r.Name : glCodeObj.Name;
		}
	}

	// method to get type adjusted GL Code from Associated HD Budget Walk
	public Static String getTypeAdjustedGLCode( GL_Code__c glCodeObj, HD_Budget_Walk__c hdBudgetWalkObj ) {

		if( hdBudgetWalkObj.Type__c != null && hdBudgetWalkObj.Type__c.containsIgnoreCase( 'Acquisition' )) {
			return  ( glCodeObj.GL_Code_Acquisition__c != null && glCodeObj.GL_Code_Acquisition__r.Name != null ) ? glCodeObj.GL_Code_Acquisition__r.Name : glCodeObj.Name;
		}
		else {
			return ( glCodeObj.GL_Code_Turn__c != null && glCodeObj.GL_Code_Turn__r.Name != null ) ? glCodeObj.GL_Code_Turn__r.Name : glCodeObj.Name;
		}
	}
}