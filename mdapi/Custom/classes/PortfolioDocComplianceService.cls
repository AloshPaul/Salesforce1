/**
 *   Description  :  Class contianing PortfolioDocCompliance Object related service methods
 *
 *   Created By Shrinath
 *
 *   Created Date:  09/07/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
public without sharing class PortfolioDocComplianceService {

    //method to update Portfolio Doc Compliance on S3 file uplaod , delete and move
    public static void updatePortfolioDocCompliance(Set<String> setFileType, Id portfolioId, String action) {
        updatePortfolioDocCompliance(setFileType, portfolioId, action, null);
    }

    //method to update Portfolio Doc Compliance on S3 file uplaod , delete and move
    public static void updatePortfolioDocCompliance(Set<String> setFileType, Id portfolioId, String action, Set<Id> setOfFSRToDelete  ) {

        //get Portfolio_Doc_Compliance__c field describe
        Map<String, Schema.SObjectField> resFldObjMap = schema.SObjectType.Portfolio_Doc_Compliance__c.fields.getMap();
        Set<String> setTargetFileTypeField = new Set<String>();
		MAP<String, String> mapTargetFileTypeFieldToFileType = new MAP<String, String>();

        for (Schema.SObjectField ft : resFldObjMap.values()) {
            Schema.DescribeFieldResult fd = ft.getDescribe();

            //if file type has a picklist field
            if( setFileType.contains( fd.getLabel() ) ) {
                //if the field is a picklist
                if ( fd.getType() == Schema.DisplayType.PICKLIST ) {
                    setTargetFileTypeField.add( fd.getName() );
                    mapTargetFileTypeFieldToFileType.put( fd.getName(), fd.getLabel() );
                }
            }
        }

		//fetch existing Portfolio_Doc_Compliance__c record
        List<Portfolio_Doc_Compliance__c> pDocComplianceList = [Select Id
                                                                  From Portfolio_Doc_Compliance__c
                                                                  Where Portfolio__c =: portfolioId];

        Map<String, Boolean> mapFileTypeToFileExists = new Map<String, Boolean>();

		//if action is delete then fetch exisitng files for the file types for the protffolio
        if ( action == 'delete' ) {
            List<File_Storage_Record__c> listFSR = [Select Id,
                                                    File_Type__c
                                                    From File_Storage_Record__c
                                                    Where Property__c =: portfolioId
                                                    And File_Type__c in: setFileType
                                                    And Id Not in: setOfFSRToDelete];

            for( File_Storage_Record__c fsrObj : listFSR )  {
				//fill map mapFileTypeToFileExists
                mapFileTypeToFileExists.put( fsrObj.File_Type__c, true );

            }
        }

		//if setTargetFileTypeField has values
        if( setTargetFileTypeField != null && setTargetFileTypeField.size() > 0 ) {

                Portfolio_Doc_Compliance__c pDocCompliance = pDocComplianceList.size() > 0 ? new Portfolio_Doc_Compliance__c( Id = pDocComplianceList.get(0).Id ) : new Portfolio_Doc_Compliance__c( Portfolio__c = portfolioId );
                String targetFileTypeFieldValue;
                if( action == 'upload') {
                    targetFileTypeFieldValue = 'Yes';
                }

                for ( String fieldAPIName : setTargetFileTypeField ) {
                    //if action is  delete then check if delted file is the last in the file type
                    if ( action == 'delete' ) {

                        if( mapFileTypeToFileExists.containsKey( mapTargetFileTypeFieldToFileType.get( fieldAPIName ) ) ) {
                            targetFileTypeFieldValue = 'Yes';
                        }
                        else {
                            targetFileTypeFieldValue = 'No';
                        }
                    }
                    //put value in portfolio doc compliance record
                    pDocCompliance.put( fieldAPIName , targetFileTypeFieldValue);
                }
				//update portfolio doc compliance record
                upsert pDocCompliance;
        }

    }

    //method to update Portfolio Doc Compliance on S3 file uplaod , delete and move
    public static void updatePortfolioDocCompliance(String filetype, Id portfolioId, String action, Id fileStorageRecordId ) {
        updatePortfolioDocCompliance( new Set<String> { filetype }, portfolioId, action, new Set<Id> { fileStorageRecordId } );
    }

    //method to update Portfolio Doc Compliance on S3 file uplaod , delete and move
    public static void updatePortfolioDocCompliance(String filetype, Id portfolioId, String action) {
        updatePortfolioDocCompliance( new Set<String> { filetype }, portfolioId, action );
    }

}