/**
 *   Description  :  Apex Class for managing File Storage Histories
 *
 *   Created By Shrinath
 *
 *   Created Date:  12/05/2013
 *
*/
public without sharing class FileStorageHistoryService {

	// method to insert File Storage History Records
	public static File_Storage_History__c insertFileStorageHistory(  File_Storage_Record__c fsrNew,
																	 File_Storage_Record__c fsrOld,
																	 Id salesforceUserId,
																	 String fileAction ) {

			Id salesforceRecordId = getSalesforceRecordId( fsrOld );
			// create new instance of file storage hostory record
			File_Storage_History__c fsh = new File_Storage_History__c(  File_Name_Orig__c = fsrOld.File_Name__c,
																		File_Size_Bytes__c = fsrOld.File_Size_Bytes__c,
																		File_Type_Orig__c = fsrOld.File_Type__c,
																		S3_Path_Name_Orig__c = fsrOld.S3_Path_Name__c,
																		Linked_Record_Id__c = salesforceRecordId,
																		File_Action_By__c = salesforceUserId
																 	  );
		    // when action is Move
		    if( fileAction.equalsIgnoreCase('Move') ) {
		    	fsh = setFileStorageHistoryForMove( fsrNew, fsrOld, fsh );
		    }
		    // when action is delete
		    else if( fileAction.equalsIgnoreCase('Delete') ) {
		    	fsh = setFileStorageHistoryForDelete( fsrNew, fsh );
		    }
		    // when action is Rename
		    else if( fileAction.equalsIgnoreCase('Rename') ) {
		    	fsh = setFileStorageHistoryForRename( fsrNew, fsrOld, fsh );
		    }
			// insert file storage history record
		    insert fsh;
		    // return file storage history record
		    return fsh;
	}

	// method to set File Storage History record field values when action is Move
	private static File_Storage_History__c setFileStorageHistoryForMove( File_Storage_Record__c fsrNew,
																	     File_Storage_Record__c fsrOld,
																	     File_Storage_History__c fsh ) {

		fsh.File_Action__c = 'Move';
		fsh.File_Type_New__c = fsrNew.File_Type__c;
		fsh.S3_Path_Name_New__c = fsrNew.S3_Path_Name__c;
		return fsh;
	}

	// method to set File Storage History record field values when action is Delete
	private static File_Storage_History__c setFileStorageHistoryForDelete( File_Storage_Record__c fsrNew,
																	       File_Storage_History__c fsh ) {

		fsh.File_Action__c = 'Delete';
		return fsh;
	}

	// method to set File Storage History record field values when action is Rename
	private static File_Storage_History__c setFileStorageHistoryForRename( File_Storage_Record__c fsrNew,
																	       File_Storage_Record__c fsrOld,
																	       File_Storage_History__c fsh ) {

		fsh.File_Action__c = 'Rename';
		fsh.File_Name_New__c = fsrNew.File_Name__c;
		fsh.S3_Path_Name_New__c = fsrNew.S3_Path_Name__c;
		return fsh;
	}

	// method to get Related RecordId for which file is uploaded
	private static Id getSalesforceRecordId( File_Storage_Record__c fsr ) {

		 Id salesforceRecordId;

		 // get File_Storage_Record__c field describe
         Map<String, Schema.SObjectField> fileStorageRecordObjFieldMap = Schema.SObjectType.File_Storage_Record__c.fields.getMap();
         Set<String> setObjectHavingReferenceFieldInFSR = new Set<String>();
         for(String fieldName : fileStorageRecordObjFieldMap.keySet()){
             Schema.DescribeFieldResult fieldDescribe = fileStorageRecordObjFieldMap.get(fieldName).getDescribe();
             // if reference type field
             if(fieldDescribe.isCustom() && fieldDescribe.getType() == Schema.DisplayType.Reference) {
                 if( fsr.get( fieldName ) != null && isSObjectType( fieldName ) ) {
                 	salesforceRecordId = String.valueOf( fsr.get( fieldName ) );
                 }
             }
         }
		 return salesforceRecordId;
	}

	// method to determine string is an Object
	private static Boolean isSObjectType( String objectAPIName ) {
		//get global describe
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();

		// Get the Schema sObjetc Type
        Schema.SObjectType targetType = gd.get( objectAPIName );

        // Check for the Schema type
        return targetType != null;
	}
}