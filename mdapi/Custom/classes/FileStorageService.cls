/**
 *   Description  :  Class contianing methods having filestorage services
 *
 *   Created By Shrinath
 *
 *   Created Date:  06/11/2013
 *
 *   Revision Logs:  V1.0 - Created
 *	 				 V_1.1 - Updated GetNextFileSetForUploadStructuredFN method
 								//Bhavi Sharma - 03/02/2017 - D-00016961 - Upload all the files in IH1 Deal Room 
 **/
global without sharing class FileStorageService{

    //method to create File_Storage_Record__c once it gets notification of upload
    webservice static String fileStorageUploadNotificationBox(List<fileStorageRecord> fileStorageRecords) {
        try {

                List<File_Storage_Record__c> listFileStorageRecordWithBoxFileId = new List<File_Storage_Record__c>();
                List<File_Storage_Record__c> listFileStorageRecordWithS3Path = new List<File_Storage_Record__c>();

                Set<String> setFileType = new Set<String>();
                Id portfolioId;
                Property__c portfolio;
                for(fileStorageRecord fs : fileStorageRecords){
                        // create instance of File_Storage_Record__c
                        File_Storage_Record__c fileStorage = new File_Storage_Record__c(
                                                                                            File_Name__c = fs.filename,
                                                                                            File_Type__c = fs.fileType,
                                                                                            Box_File_Id__c = fs.boxFileId,
                                                                                            S3_Path_Name__c = fs.s3PathName,
                                                                                            Uploaded_To_Box_By__c = fs.boxUserName,
                                                                                            Uploaded_To_Box_Date__c = fs.uploadedToBoxDate,
                                                                                            Uploaded_To_S3_By__c = fs.userId,
                                                                                            Uploaded_To_S3_Date__c = (fs.userId != null ? Datetime.now() : null),
                                                                                            File_Size_Bytes__c = fs.fileSizeBytes
                                                                                        );

                        fileStorage = (File_Storage_Record__c)Utility.insertSObjectId(fs.salesforceRecordId, fileStorage);

                        if( fileStorage.Property__c != null ) {
                            setFileType.add( fileStorage.File_Type__c );
                            portfolioId = fileStorage.Property__c;
                        }

                        //add file storage record
                        if(fs.s3PathName != null) {
                            listFileStorageRecordWithS3Path.add(fileStorage);
                        }
                        else {
                            listFileStorageRecordWithBoxFileId.add(fileStorage);
                        }
                }

                if( portfolioId != null ) {
                    portfolio = [Select Id,
                                        Fund__c
                                 From Property__c
                                 Where Id =: portfolioId ];
                }
                Map<String, File_Storage_Type__c> mapFileTypeNameToFileType = new Map<String, File_Storage_Type__c>();

                if( setFileType.size() > 0 ) {
                    String sObjectName = 'Property__c';
                    //get the file type
                    List<File_Storage_Type__c> listFST = [Select Name,
                                                                  Allowed_For_Objects__c,
                                                                  Folder_Access__c,
                                                                  MetaData_Record__c,
                                                                  Upload_To_SFN__c,
                                                                  Url_Expiration_Minutes__c
                                                          From File_Storage_Type__c
                                                          Where Allowed_For_Objects__c includes (:sObjectName)
                                                          And Name =: setFileType
                                                          ];


                    for( File_Storage_Type__c fst : listFST ) {
                        mapFileTypeNameToFileType.put( fst.Name, fst);
                    }
                }

                for(File_Storage_Record__c fsr : listFileStorageRecordWithS3Path){
                      File_Storage_Type__c fst = new File_Storage_Type__c();
                      if( fsr.File_Type__c != null ) {
                            fst =  mapFileTypeNameToFileType.containsKey( fsr.File_Type__c.trim() ) ? mapFileTypeNameToFileType.get( fsr.File_Type__c.trim() ) : new File_Storage_Type__c();
                      }
                      //when file storage record assocaited with portfolio and a file type having Upload_To_SFN__c true
                      if( fsr.Property__c != null
                          && portfolio != null
                          &&
                            fst.Id != null
                          &&
                            fst.Upload_To_SFN__c != null
                          &&
                            fst.Upload_To_SFN__c ) {

                          fsr.SFN_Upload_Queued__c = Datetime.now();
                          fsr.Uploaded_To_SFN_Date__c = null;
                          fsr.SFN_Upload_Error_Message__c = null;
                          fsr.SFN_Upload_Last_Attempt__c = null;
                      }
                }

                if(listFileStorageRecordWithS3Path.size() > 0) {
                    Schema.SObjectField externalIdFieldUsedUpsert = File_Storage_Record__c.Fields.S3_Path_Name__c;
                    Database.upsert(listFileStorageRecordWithS3Path, externalIdFieldUsedUpsert);
                }

                if(listFileStorageRecordWithBoxFileId.size() > 0) {
                    Schema.SObjectField externalIdFieldUsedUpsert = File_Storage_Record__c.Fields.Box_File_Id__c;
                    Database.upsert(listFileStorageRecordWithBoxFileId, externalIdFieldUsedUpsert);
                }

                if( setFiletype.size() > 0 &&  portfolioId != null ) {
                    PortfolioDocComplianceService.updatePortfolioDocCompliance(setFiletype, portfolioId, 'upload');
                }
        }
        catch(Exception e) {
            throw e;
        }
        return 'success';
        //do we want to log the request
    }

    //inner class to for fileStorage object
    global class fileStorageRecord {
       webService String salesforceRecordId;
       webService String filename;
       webService String fileType;
       webService String boxFileId;
       webService String s3PathName;
       webService String boxUserName;
       webService Datetime uploadedToBoxDate;
       webService String userId;
       webservice Integer fileSizeBytes;

       //webService Boolean uploadedToSfn;
       global fileStorageRecord() {
       }
    }

    //method to Notify DocCoordinator
    webservice static String notifyDocCoordinator(String region, String subject, String body) {
        try {
                validateEmailParameter(region, subject, body);

                List<Region__c> listRegion = [Select Document_Coordinator__c
                                    From Region__c
                                    Where Name =: region Limit 1];

                if(listRegion.size() == 0) {
                    throw new FileStorageServiceException('Region "' + region + '" could not be found.');
                }

                Region__c regionObj = listRegion.get(0);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if( regionObj.Document_Coordinator__c == null ) {
                    throw new FileStorageServiceException( 'Region document coordinator for "' + region + '" does not have email.' );
                }
                String[] toAddresses = new String[] {regionObj.Document_Coordinator__c};
                mail.setToAddresses(toAddresses);
                mail.setSubject(subject);
                mail.setHTMLBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});

        }
        catch(Exception e) {
            throw e;
        }
        return 'success';
        //do we want to log the request
    }

    //validate the email parameters and throw exception if invalid parameter
    private static void validateEmailParameter(String region, String subject, String body) {
        if(region == null || region.length() == 0) {
            throw new FileStorageServiceException('Invalid region, region can not be null or blank.');
        }
        if(subject == null || subject.length() == 0) {
            throw new FileStorageServiceException('Invalid Email Subject.');
        }
        if(region == null || region.length() == 0) {
            throw new FileStorageServiceException('Invalid Email Body.');
        }
    }

    //method to return FileStorageAlias
    public static String getFileStorageAlias( Id sObjectId ) {

        Schema.SObjectType sObjType = sObjectId.getSObjectType();
        Schema.DescribeSObjectResult describeRes = sObjType.getDescribe();

        //Get sObject APIName
        String sObjName = describeRes.getName();

        //Getting Map<String,Schema.SObjectField> for sObject
        Map<String, Schema.SObjectField> sObjectFieldsMap = describeRes.fields.getMap();
        Boolean hasFileStorageAlias = false;

        //Loop through sObject field names
        for (String fieldName : sObjectFieldsMap.keySet()) {
            //Getting field describe results
            if( fieldName.equalsIgnoreCase('File_Storage_Alias__c') ) {
                hasFileStorageAlias = true;
            }
        }

        String fileStorageAlias = '';
        //if SObject has a field File_Storage_Alias__c
        if( hasFileStorageAlias ) {

            String soql = 'Select File_Storage_Alias__c From ' + sObjName + ' Where Id =: sObjectId ';
            SObject sObj = Database.query(soql);
            if ( sObj.get( 'File_Storage_Alias__c' ) != null ) {
                fileStorageAlias =  String.valueOf( sObj.get( 'File_Storage_Alias__c' ) );
            }
        }
        return fileStorageAlias;
    }

    // method to return next upto 10 item for SFn upload
    webservice static List<NextFileForUploadStructuredFn> GetNextFileSetForUploadStructuredFN() {

        try {

                // fetch next File_Storage_Records to be uploaded to SFN
                List<File_Storage_Record__c> fsrList = [Select SFN_Upload_Queued__c,
                                                               SFN_Upload_Error_Message__c,
                                                               Uploaded_To_SFN_Date__c,
                                                               Property__c,
                                                               File_Type__c,
                                                               File_Name__c
                                                        From File_Storage_Record__c
                                                        Where SFN_Upload_Queued__c !=: NULL
                                                        And SFN_Upload_Last_Attempt__c =: NULL
                                                        And Uploaded_To_SFN_Date__c =: Null
                                                        AND Property__c !=: NULL
                                                        Order By SFN_Upload_Queued__c ASC
                                                        Limit 10];

                Set<Id> setPropertyIds = new Set<Id>();
                for( File_Storage_Record__c fsr : fsrList ) {
                    // if record is portfolio
                    if( fsr.Property__c != null ) {
                        setPropertyIds.add( fsr.Property__c );
                    }
                }

                Map<Id, Property__c> mapProperties = new map<Id, Property__c>( [ Select Region__c,
                                                                                        Securitization_Pool__c,
                                                                                        Fund__c
                                                                                 From Property__c
                                                                                 Where Id in: setPropertyIds
                                                                                ] );

                String region;
                String fund;

                List<NextFileForUploadStructuredFn> objNextFileForUploadStructuredFnList;
                // when fsrList has items
                if( fsrList.size() > 0 ) {
                    objNextFileForUploadStructuredFnList = new List<NextFileForUploadStructuredFn>();
                }

                Datetime currentTime = Datetime.now();
                for( File_Storage_Record__c fsr : fsrList ) {

                    // if record is portfolio
                    if( fsr.Property__c != null ) {
                        Property__c p = mapProperties.get( fsr.Property__c );
                        region = (p.Region__c != null ? p.Region__c : '');
                        // when Securitization_Pool__c not equals to null
                        if( p.Securitization_Pool__c != null && p.Securitization_Pool__c.length() == 2 ) {
                            fund = (p.Securitization_Pool__c != null ? 'S' + p.Securitization_Pool__c : '');
                        }
                        else {
                            fund = (p.Fund__c != null ? p.Fund__c : '');
                        }
                    }
                    fsr.SFN_Upload_Last_Attempt__c = currentTime;
                    fsr.Uploaded_To_SFN_Date__c = null;
                    fsr.SFN_Upload_Error_Message__c = null;
                    
                    //Added by Bhavi Sharma - 03/02/2017 - D-00016961 - Upload all the files in IH1 Deal Room
                    fund = '01';
                    // create instance of NextFileForUploadStructuredFn
                    objNextFileForUploadStructuredFnList.add( new NextFileForUploadStructuredFn(
                                                                                                 fsr.Property__c,
                                                                                                 fsr.File_Type__c,
                                                                                                 fsr.File_Name__c,
                                                                                                 fund,
                                                                                                 region
                                                                                                 ));


                }

                // update file storage record
                Database.update( fsrList, false );

                return objNextFileForUploadStructuredFnList;
        }
        catch(Exception e) {
            throw e;
        }
    }

    // method to save error or Uploaded_To_SFN_Date__c
    webservice static String notifyUploadStructuredFn( List<UploadStructuredFnNotification> uploadStructuredFnNotifications ) {
        try {
                Map<String, UploadStructuredFnNotification> mapS3PathNameToUploadStructuredFnNotification = new Map<String, UploadStructuredFnNotification>();
                for( UploadStructuredFnNotification uploadSFNNotification : uploadStructuredFnNotifications ) {
                    if( uploadSFNNotification.s3PathName!= null ) {
                        mapS3PathNameToUploadStructuredFnNotification.put( uploadSFNNotification.s3PathName.trim().toLowerCase(),
                                                                           uploadSFNNotification );
                    }
                }


                // query File_Storage_Record__c to be updated for SFN upload
                List<File_Storage_Record__c> fsrList = [ Select SFN_Upload_Queued__c,
                                                               SFN_Upload_Error_Message__c,
                                                               Uploaded_To_SFN_Date__c,
                                                               Property__c,
                                                               Property__r.Region__c,
                                                               File_Type__c,
                                                               File_Name__c,
                                                               S3_Path_Name__c
                                                         From File_Storage_Record__c
                                                         Where S3_Path_Name__c in: mapS3PathNameToUploadStructuredFnNotification.keySet()
                                                         And Property__c !=: NULL ];


                Datetime currentTime = Datetime.now();

                for( File_Storage_Record__c fsr : fsrList ) {

                    UploadStructuredFnNotification uploadSFNNotification = mapS3PathNameToUploadStructuredFnNotification.get( fsr.S3_Path_Name__c.trim().toLowerCase() );

                    // when errorMessage is null or blank string
                    if( uploadSFNNotification.errorMessage == null || uploadSFNNotification.errorMessage.trim().length() == 0) {
                        fsr.Uploaded_To_SFN_Date__c = currentTime;
                        fsr.SFN_Upload_Error_Message__c = uploadSFNNotification.errorMessage;
                    }
                    else {
                            uploadSFNNotification.errorMessage = uploadSFNNotification.errorMessage.trim();
                            if( uploadSFNNotification.errorMessage.length() > 255 ) {
                                fsr.SFN_Upload_Error_Message__c = uploadSFNNotification.errorMessage.subString(0, 255);
                            }
                            else {
                                fsr.SFN_Upload_Error_Message__c = uploadSFNNotification.errorMessage;
                            }
                    }
                }

                // update file storage record
                Database.update( fsrList, false );

                return 'Success';
        }
        catch(Exception e) {
            throw e;
        }
    }

    // inner class for SFN Upload Notification
    global class UploadStructuredFnNotification {
        webService String s3PathName;
        webService String errorMessage;
        //constructor
        global UploadStructuredFnNotification( String s3PathName, String errorMessage ) {
            this.s3PathName = s3PathName;
            this.errorMessage = errorMessage;
        }
    }

    //inner class for next File for SFN Upload
    global class NextFileForUploadStructuredFn {
        webService String salesforceRecordId;
        webService String fileType;
        webService String fileName;
        webService String fund;
        webService String region;
        //constructor
        global NextFileForUploadStructuredFn(String salesforceRecordId,
                                             String fileType,
                                             String fileName,
                                             String fund,
                                             String region
                                            ) {
            this.salesforceRecordId = salesforceRecordId;
            this.fileType = fileType;
            this.fileName = fileName;
            this.fund = fund;
            this.region = region;

        }
    }

    // method to PortfolioInformation for SFn upload
    webservice static List<PortfolioInformation> GetPortfolioInformation(List<String> propertyCodes) {

         List<PortfolioInformation> listPortfolioInformation = new List<PortfolioInformation>();
         // loop over portfolio records
         for( Property__c portfolio : [ Select Id, Property_Code__c
                                        From Property__c
                                        Where Property_Code__c in: propertyCodes
                                        ] ) {

            listPortfolioInformation.add( new PortfolioInformation(portfolio.Id, portfolio.Property_Code__c ));
         }
         return listPortfolioInformation;
    }

    //inner class for PortfolioInformation for SFn upload
    global class PortfolioInformation {
        webService String salesforceRecordId;
        webService String propertyCode;
        //constructor
        global PortfolioInformation(String salesforceRecordId, String propertyCode) {
            this.salesforceRecordId = salesforceRecordId;
            this.propertyCode = propertyCode;
        }
    }

    public class FileStorageServiceException Extends Exception {}

}