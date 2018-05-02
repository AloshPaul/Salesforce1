global without sharing class IHS3IntegrationServiceEnh {

  /**
 *   Description  :  Class contianing methods having filestorage services for S3 Integration
 *
 *   Created By Shrinath
 *
 *   Created Date:  07/02/2013
 *   Update By Krishna
 *   update date: 08/18/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
    public static final String S3_ACTION_DELETE_FILE = 's3deleteFile';
    public static final String S3_ACTION_GET_FILE = 's3getFile';
    public static final String S3_ACTION_GET_THUMBNAIL = 's3getThumbnail';
    public static final String S3_ACTION_MOVE_FILE = 's3moveFile';
    public static final String S3_ACTION_UPLOAD_FILE = 's3uploadFile';
    public static final String S3_ACTION_RENAME_FILE = 's3renameFile';

  public static Boolean getDirectS3File = true;

    private static String getTimeoutGmt( File_Storage_Type__c fst, String s3Action ) {
        String timeoutGmt = '';
        if( s3Action == S3_ACTION_GET_FILE ) {
            timeoutGmt = (fst.Url_Expiration_Minutes__c == null || fst.Url_Expiration_Minutes__c == 0) ? '' : Datetime.now().addMinutes(Integer.valueOf(fst.Url_Expiration_Minutes__c)).formatGmt('yyyyMMddHHmmss');
        }
        else if( s3Action == S3_ACTION_DELETE_FILE || s3Action == S3_ACTION_MOVE_FILE || s3Action == S3_ACTION_RENAME_FILE){
            timeoutGmt = Datetime.now().addMinutes(10).formatGmt('yyyyMMddHHmmss');
        }
        //return timeoutGmt
        return timeoutGmt;
    }

    private static String getURLEncodedString(String strValue) {
        strValue = Encodingutil.urlEncode(strValue, 'UTF-8');
        return strValue;
    }


    //method to get s3 File Url
    private static String getS3FileUrl(File_Storage_Record__c fsr,
                                      Id sObjectRecordId,
                                      Map<String, File_Storage_Type__c> mapFileType_Fst) {

        String action = S3_ACTION_GET_FILE;

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;

        String fileType = (fsr.File_Type__c != null ? fsr.File_Type__c : '');
        String fileName = (fsr.File_Name__c != null ? fsr.File_Name__c : '');

        File_Storage_Type__c fst = (mapFileType_Fst.containsKey(fileType.toLowerCase()) ? mapFileType_Fst.get(fileType.toLowerCase()) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);
        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' + getURLEncodedString(signature);
        return s3RequestUrl;

    }

    // Method for s3 rename File
    public static HttpResponse s3renameFile(Id fileStorageRecordId, Id sObjectRecordId, String fileNameNew) {

      	String action = S3_ACTION_RENAME_FILE;
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());
        File_Storage_Record__c fsr = (File_Storage_Record__c) Utility.selectStar(fileStorageRecordId);

        String fileNameOld = fsr.file_Name__c;
        String fileType = fsr.File_Type__c;
        String folderAccess = '';

        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileType
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        if(fst.Id != null) {
            folderAccess = fst.Folder_Access__c;
        }

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;

        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileNameOld=' + getURLEncodedString(fileNameOld)
                                + '&fileNameNew='+ getURLEncodedString(fileNameNew)
                                + '&folderAccess=' + folderAccess
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' + getURLEncodedString(signature);


        HttpResponse response = executeGet(s3RequestUrl);

        return response;
    }

    //method to get S3 thumbnail Url
    private static String getS3ThumbnailUrl(File_Storage_Record__c fsr,
                                            Id sObjectRecordId,
                                            Map<String, File_Storage_Type__c> mapFileType_Fst) {

        String action = S3_ACTION_GET_THUMBNAIL;

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;

        String fileType = (fsr.File_Type__c != null ? fsr.File_Type__c : '');
        String fileName = (fsr.File_Name__c != null ? fsr.File_Name__c : '');

        File_Storage_Type__c fst = (mapFileType_Fst.containsKey(fileType.toLowerCase()) ? mapFileType_Fst.get(fileType.toLowerCase()) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);
        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);

        s3RequestUrl += '&signature=' + getURLEncodedString(signature);
        return s3RequestUrl;

  }

  //method to get portfolio Ids during the Box--> S3 Migration that, given a Property Code will return both the Property Code and Object Id back
  webservice static List<PortfolioS3Migration> getPortfolioIds(List<String> propertyCodes) {

        List<PortfolioS3Migration> listPortfolioS3Migration = new List<PortfolioS3Migration>();
        try {
        Map<String, Property__c> mapPropertyCode_Portfolio = new map<String, Property__c>();
              //query portfolios with propertycodes
              for(Property__c p : [Select Id,
                        Property_Code__c
                        From Property__c
                        Where Property_Code__c != NULL
                        And Property_Code__c in: propertyCodes]) {
          //fill map with property code a s key and portfolio as value
            mapPropertyCode_Portfolio.put(p.Property_Code__c, p);
          }

        //loop through property codes
          for(String propertyCode : propertyCodes) {
          //if property code has a portfolio
            if(mapPropertyCode_Portfolio.containsKey(propertyCode)) {
              listPortfolioS3Migration.add(new PortfolioS3Migration(propertyCode, mapPropertyCode_Portfolio.get(propertyCode).Id));
            }
            else {
              listPortfolioS3Migration.add(new PortfolioS3Migration(propertyCode, null));
            }
          }
      }
        catch(Exception e) {
            throw e;
        }
        //return list of string having property code and Sobject Ids separated by blank space
        return listPortfolioS3Migration;
    }

    //method to create File_Storage_Record__c once it gets notification of upload
    webservice static String fileStorageUploadNotification(List<fileStorageRecord> fileStorageRecords) {
        try {

                List<File_Storage_Record__c> listFileStorageRecordWithS3Path = new List<File_Storage_Record__c>();

                Set<Id> budgetWalkIds = new Set<Id>();
                Set<Id> rehabIds = new Set<Id>();

                Set<String> setFileType = new Set<String>();
                Set<Id> setFileStorageRecordIds = new Set<Id>();
                Id portfolioId;
                for(fileStorageRecord fs : fileStorageRecords){

                        File_Storage_Record__c fileStorage = new File_Storage_Record__c(
                                                                                            File_Name__c = fs.filename,
                                                                                            File_Type__c = fs.fileType,
                                                                                            S3_Path_Name__c = fs.s3PathName,
                                                                                            Uploaded_To_S3_By__c = fs.userId,
                                                                                            Uploaded_To_S3_Date__c = Datetime.now(),
                                                                                            File_Size_Bytes__c = fs.fileSizeBytes
                                                                                        );

                        fileStorage = (File_Storage_Record__c)Utility.insertSObjectId(fs.salesforceRecordId, fileStorage);

                        if(fileStorage.HD_Budget_Walk__c != null) {
                            budgetWalkIds.add(fileStorage.HD_Budget_Walk__c);
                        }
                        if(fileStorage.Rehab__c != null) {
                            rehabIds.add(fileStorage.Rehab__c);
                        }

                        if( fileStorage.Property__c != null ) {
                            setFileType.add( fileStorage.File_Type__c );
                            setFileStorageRecordIds.add( fileStorage.Id );
                            portfolioId = fileStorage.Property__c;
                        }

                        //add file storage record
                        if(fs.s3PathName != null) {
                            listFileStorageRecordWithS3Path.add(fileStorage);
                        }
                }

                Property__c portfolio;
                if( portfolioId != null ) {
            		portfolio = [Select Id,
                                 		Fund__c,
                                 		Securitization_Pool__c
                    			 From Property__c
                    			 Where Id =: portfolioId ];
                }

                //get budget walk map
		        Map<Id, HD_Budget_Walk__c> mapBudgetWalks = new Map<ID, HD_Budget_Walk__c> ([Select Photos_Uploaded_Before_Rehab__c,
		                                                              								Photos_Uploaded_After_Rehab__c,
		                                                              								Rehab__c
											                                                 From HD_Budget_Walk__c
											                                                 Where Id in: budgetWalkIds
											                                                 And ( Photos_Uploaded_Before_Rehab__c =: FALSE OR Photos_Uploaded_After_Rehab__c =: FALSE )
											                                                 ]);
				//get rehab map
		        Map<Id, Rehab__c> mapRehabs = new Map<ID, Rehab__c> ([Select HD_Budget_Walk__c
					                                                  From Rehab__c
					                                                  Where Id in: rehabIds
					                                                  And HD_Budget_Walk__c !=: NULL
					                                                  And ( HD_Budget_Walk__r.Photos_Uploaded_After_Rehab__c =: FALSE )
					                                                  ]);

		        Map<Id, HD_Budget_Walk__c> mapBudgetWalkToUpdate = new Map<Id, HD_Budget_Walk__c>();

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
					  Boolean fileStorage = false;
					  File_Storage_Type__c fst = new File_Storage_Type__c();
					  if( fsr.File_Type__c != null ) {
					  		fst =  mapFileTypeNameToFileType.containsKey( fsr.File_Type__c.trim() ) ? mapFileTypeNameToFileType.get( fsr.File_Type__c.trim() ) : new File_Storage_Type__c();
					  }

					  //checking null as parameter coming from webservice
                      //if(fs.uploadedToSfn != null && fs.uploadedToSfn) {
	                  if( fsr.Property__c != null
	                  	  && portfolio != null
	                  	  &&
	                  	  	fst.Id != null
                  	  	  &&
                  	  	  	fst.Upload_To_SFN__c != null
	                  	  &&
	                  	  	fst.Upload_To_SFN__c ) {
                          // when securitization_pool__c is null or securitization_pool__c is not null and is for Lease Agreement file type
                          if( portfolio.Fund__c != null
                              || portfolio.securitization_pool__c == null
                          	  || ( portfolio.securitization_pool__c != null
					  	  	       && portfolio.securitization_pool__c.length() == 2
					  	  	       && fsr.File_Type__c == 'Lease Agreement' )) {

						  	  fsr.SFN_Upload_Queued__c = Datetime.now();
		                      fsr.Uploaded_To_SFN_Date__c = null;
		                      fsr.SFN_Upload_Error_Message__c = null;
		                      fsr.SFN_Upload_Last_Attempt__c = null;
		  	  	          }
					  }


	                  Id budgetWalkId = fsr.HD_Budget_Walk__c;
	                  Id rehabId = fsr.Rehab__c;
	                  if( budgetWalkId != null ) {

		                    if( mapBudgetWalks.containsKey(budgetWalkId) ) {

			                      HD_Budget_Walk__c budgetWalk = mapBudgetWalkToUpdate.containsKey(budgetWalkId) ? mapBudgetWalkToUpdate.get(budgetWalkId) : mapBudgetWalks.get(budgetWalkId);
					              //if image  is uploaded
					              if(isImageFile(fsr.File_Name__c)) {

			                          //if file name contains before and photos and Photos_Uploaded_Before_Rehab__c is false
					                  if( fsr.File_Type__c.containsIgnoreCase('before')
					                      && fsr.File_Type__c.containsIgnoreCase('photos')
					                      && (!budgetWalk.Photos_Uploaded_Before_Rehab__c) ) {

						                    //set Photos_Uploaded_Before_Rehab__c to Ture
						                    budgetWalk.Photos_Uploaded_Before_Rehab__c = true;
						                    mapBudgetWalkToUpdate.put(budgetWalkId, budgetWalk);
				    	              }
					                  //if file name contains after and photos and Photos_Uploaded_After_Rehab__c is false
					                  else if( fsr.File_Type__c.containsIgnoreCase('after')
					                      && fsr.File_Type__c.containsIgnoreCase('photos')
					                      && (!budgetWalk.Photos_Uploaded_After_Rehab__c) ) {

						                      //set Photos_Uploaded_After_Rehab__c to Ture
						                      budgetWalk.Photos_Uploaded_After_Rehab__c = true;
						                      mapBudgetWalkToUpdate.put(budgetWalkId, budgetWalk);
			                  		  }
			                      }
		                      }
		                      //when file is upload for rehab record
		                      else if( rehabId != null ) {
		                      		//when mapRehab contains rehabid
		                      		if( mapRehabs.containsKey(rehabId) ) {
										Rehab__c rehab = mapRehabs.get(rehabId);
										budgetWalkId = rehab.HD_Budget_Walk__c;
										if( budgetWalkId != null ) {
			                      			HD_Budget_Walk__c budgetWalk = mapBudgetWalkToUpdate.containsKey(budgetWalkId) ? mapBudgetWalkToUpdate.get(budgetWalkId) : new HD_Budget_Walk__c( Id  = budgetWalkId );
			                      			//if image  is uploaded
							                if(isImageFile(fsr.File_Name__c)) {

	          				                      //if file name contains after and photos and Photos_Uploaded_After_Rehab__c is false
								                  if( fsr.File_Type__c.containsIgnoreCase('after')
								                      && fsr.File_Type__c.containsIgnoreCase('photos')
								                      && (!budgetWalk.Photos_Uploaded_After_Rehab__c) ) {

								                      //set Photos_Uploaded_After_Rehab__c to Ture
								                      budgetWalk.Photos_Uploaded_After_Rehab__c = true;
								                      mapBudgetWalkToUpdate.put(budgetWalkId, budgetWalk);
						                  		  }
						                    }
										}
		                      		}
		                      }
	                  }

		        }

                //update hd budget walk records
                update mapBudgetWalkToUpdate.values();

                if(listFileStorageRecordWithS3Path.size() > 0) {
                    Schema.SObjectField externalIdFieldUsedUpsert = File_Storage_Record__c.Fields.S3_Path_Name__c;
                    Database.upsert(listFileStorageRecordWithS3Path, externalIdFieldUsedUpsert);
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

  	//method to rename File_Storage_Record__c once it gets notification of rename of file
    webservice static String fileStorageRenameNotification( String s3PathNameOld,
								                            String s3PathNameNew,
								                            String fileNameNew,
								                            String userId) {
        try {

                List<File_Storage_Record__c> listFileStorageRecordWithS3Path = getFileStorageRecordsByS3PathName( s3PathNameOld );

				File_Storage_Record__c fileStorageRecordOld;

		        if( listFileStorageRecordWithS3Path.size() > 0 ) {
		        			fileStorageRecordOld = listFileStorageRecordWithS3Path.get(0).clone( true, true );
							File_Storage_Record__c fileStorage = new File_Storage_Record__c(
		                                                      								Id = listFileStorageRecordWithS3Path.get(0).Id,
                                                                                            File_Name__c = fileNameNew,
								                                                            S3_Path_Name__c = s3PathNameNew,
								                                                            Uploaded_To_S3_By__c = userId
									                                                        );
							// portfolio id associated with File Storage record
							Id portfolioId = listFileStorageRecordWithS3Path.get(0).Property__c;
							File_Storage_Type__c fst = new File_Storage_Type__c();
							// when file is associated with portfolio
							if( portfolioId != null ) {
								Property__c portfolio = [Select Id,
						                                 		Fund__c
						                    			 From Property__c
						                    			 Where Id =: portfolioId ];

			        			String sObjectName = String.valueOf(portfolioId.getSObjectType());
			        			String fileType = listFileStorageRecordWithS3Path.get(0).File_Type__c;
								//get the file type
			        			List<File_Storage_Type__c> listFST = [Select Name,
								                                              Allowed_For_Objects__c,
								                                              Folder_Access__c,
								                                              MetaData_Record__c,
								                                              Upload_To_SFN__c,
								                                              Url_Expiration_Minutes__c
						                                              From File_Storage_Type__c
						                                              Where Allowed_For_Objects__c includes (:sObjectName)
						                                              And Name =: fileType
						                                              Limit 1];
						        // when list has a record
						        fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
								// when file type has Upload_To_SFN__c true
								if( portfolio != null
							  	    &&
							  	    	fst.Id != null && fst.Upload_To_SFN__c != null && fst.Upload_To_SFN__c ) {

									fileStorage.SFN_Upload_Queued__c = Datetime.now();
			                        fileStorage.Uploaded_To_SFN_Date__c = null;
			                        fileStorage.SFN_Upload_Error_Message__c = null;
			                        fileStorage.SFN_Upload_Last_Attempt__c = null;
								}
							}
							//update file storage record
	                        update fileStorage;

	                        FileStorageHistoryService.insertFileStorageHistory( fileStorage,
																				fileStorageRecordOld,
																				userId,
																				'Rename'
							                                                   );

		        }
		        else {
		          		throw new IHS3IntegrationServiceException('Could not find file storage record for the renamed file.');
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
       webService String s3PathName;
       webService String userId;
       webservice Integer fileSizeBytes;

       //constructor
       global fileStorageRecord() {
       }
    }

    //method to delete File_Storage_Record__c once it gets notification of delete
    webservice static String fileStorageDeleteNotification(String s3PathName, String userId) {
        try {
                List<File_Storage_Record__c> fileStorageRecords = getFileStorageRecordsByS3PathName( s3PathName );

                if(fileStorageRecords.size() > 0) {
                    File_Storage_Record__c fileStorageRecord = fileStorageRecords.get(0);
                    delete fileStorageRecord;

                    FileStorageHistoryService.insertFileStorageHistory( null,
																		fileStorageRecord,
																		userId,
																		'Delete'
					                                                   );

                    if( fileStorageRecord.Property__c != null ) {
                        PortfolioDocComplianceService.updatePortfolioDocCompliance(fileStorageRecord.File_Type__c, fileStorageRecord.Property__c, 'delete', fileStorageRecord.Id );
                    }
                }
        }
        catch(Exception e) {
            throw e;
        }
        return 'success';
        //do we want to log the request
    }

    //method to delete File_Storage_Record__c once it gets notification of move
    webservice static String fileStorageMoveNotification(String s3PathNameOld,
                                                         String s3PathNameNew,
                                                         String fileTypeNew,
                                                         String userId) {
        try {
                List<File_Storage_Record__c> fileStorageRecords = getFileStorageRecordsByS3PathName( s3PathNameOld );
                File_Storage_Record__c fileStorageRecordOld;
                String fileTypeOld;
                if(fileStorageRecords.size() > 0) {
                	fileStorageRecordOld = fileStorageRecords.get(0).clone( true, true );
                    File_Storage_Record__c fileStorageRecord = fileStorageRecords.get(0);

                    fileTypeOld = fileStorageRecord.File_Type__c;

                    fileStorageRecord.File_Type__c = fileTypeNew;
                    fileStorageRecord.S3_Path_Name__c = s3PathNameNew;
                    fileStorageRecord.Uploaded_To_S3_By__c = userId;

					// portfolio id associated with File Storage record
					Id portfolioId = fileStorageRecords.get(0).Property__c;

					File_Storage_Type__c fst = new File_Storage_Type__c();

					// when file is associated with portfolio
					if( portfolioId != null ) {
						Property__c portfolio = [Select Id,
				                                 		Fund__c
				                    			 From Property__c
				                    			 Where Id =: portfolioId ];

						Boolean uploadedToSfn = false;
						String sObjectName = String.valueOf(portfolioId.getSObjectType());
	        			//get the file type
	        			List<File_Storage_Type__c> listFST = [Select Name,
						                                              Allowed_For_Objects__c,
						                                              Folder_Access__c,
						                                              MetaData_Record__c,
						                                              Upload_To_SFN__c,
						                                              Url_Expiration_Minutes__c
				                                              From File_Storage_Type__c
				                                              Where Allowed_For_Objects__c includes (:sObjectName)
				                                              And Name =: fileTypeNew
				                                              Limit 1];
				        // when list has a record
				        fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
						// when file type has Upload_To_SFN__c true
						if( portfolio != null
					  	    &&
					  	    	fst.Id != null && fst.Upload_To_SFN__c != null && fst.Upload_To_SFN__c ) {
					  	    // set uploadedToSfn to true
							uploadedToSfn = true;
						}

						//checking null as parameter coming from webservice
	                    if(uploadedToSfn != null && uploadedToSfn) {
	                        fileStorageRecord.SFN_Upload_Queued__c = Datetime.now();
	                        fileStorageRecord.Uploaded_To_SFN_Date__c = null;
	                        fileStorageRecord.SFN_Upload_Error_Message__c = null;
	                        fileStorageRecord.SFN_Upload_Last_Attempt__c = null;
	                    }
	                    else {
		                    	fileStorageRecord.SFN_Upload_Queued__c = null;
		                        fileStorageRecord.Uploaded_To_SFN_Date__c = null;
		                        fileStorageRecord.SFN_Upload_Error_Message__c = null;
		                        fileStorageRecord.SFN_Upload_Last_Attempt__c = null;
	                    }
					}

                    update fileStorageRecord;
					FileStorageHistoryService.insertFileStorageHistory( fileStorageRecord,
																		fileStorageRecordOld,
																		userId,
																		'Move'
					                                                   );

                    if( fileStorageRecord.Property__c != null ) {
                        PortfolioDocComplianceService.updatePortfolioDocCompliance(fileTypeNew, fileStorageRecord.Property__c, 'upload' );
                        PortfolioDocComplianceService.updatePortfolioDocCompliance(fileTypeOld , fileStorageRecord.Property__c, 'delete', fileStorageRecord.Id );
                    }
                }
        }
        catch(Exception e) {
            throw e;
        }
        return 'success';
        //do we want to log the request
    }

    // Method for s3 File Delete
    public static HttpResponse s3DeleteFile(Id[] fileStorageRecordId, Id sObjectRecordId, String fileType) {

      List<String> listOfFileName = new  List<String> ();

        String action = 's3deleteFile';
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        list<File_Storage_Record__c> fsr = (list<File_Storage_Record__c>) Utility.selectStar(fileStorageRecordId);

        for(File_Storage_Record__c selectedId : fsr){
         listOfFileName.add(selectedId.File_Name__c);
      }

     String fileName = String.join(listOfFileName, '*');

    Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;



        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileType
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&timeoutGmt=' + timeoutGmt;

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' + getURLEncodedString(signature);
        HttpResponse response = executeGet(s3RequestUrl);
        return response;
    }

    // Method for s3 File Move form one folder to another
    public static HttpResponse s3MoveFile(Id[] fileStorageRecordId, Id sObjectRecordId, String fileTypeNew, String fileType) {

        List<String> listOfFileName = new  List<String> ();
        String action = S3_ACTION_MOVE_FILE;
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        list<File_Storage_Record__c> fsr = (list<File_Storage_Record__c>) Utility.selectStar(fileStorageRecordId);

        for(File_Storage_Record__c selectedId : fsr){
         	listOfFileName.add(selectedId.File_Name__c);
        }

        String fileName = String.join(listOfFileName, '*');
        String folderAccess = '';

        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileTypeNew
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        if(fst.Id != null) {
            folderAccess = fst.Folder_Access__c;
        }

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;

        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileTypeNew=' + getURLEncodedString(fileTypeNew)
                                + '&fileTypeOld=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&folderAccess=' + folderAccess
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' + getURLEncodedString(signature);

    System.debug('mymovefile '+s3RequestUrl);
        HttpResponse response = executeGet(s3RequestUrl);
        return response;
    }

    // Method for s3 File View
    // returns HttpResponse object
    public static HttpResponse s3GetFile(Id fileStorageRecordId,
                                         Id sObjectRecordId) {

        File_Storage_Record__c fileStorageRecord = (File_Storage_Record__c) Utility.selectStar(fileStorageRecordId);
        HttpResponse response = executeGet(getS3FileUrl(fileStorageRecord, sObjectRecordId));
        return response;
    }


  // Method for s3 File View
    // returns Url for get file

    //method to get s3 File Url
    public static String getDirectS3FileUrl( File_Storage_Record__c fsr ) {
      return getDirectS3FileUrl(fsr, false);
    }

    //method to get s3 File Url
    public static String getDirectS3FileThumbnailUrl( File_Storage_Record__c fsr ) {
      return getDirectS3FileUrl(fsr, true);
    }


	private static boolean isNonExpire = false;
	//method to get non expire s3 File Url
    public static String getDirectS3FileUrlNonExpire( File_Storage_Record__c fsr, Boolean isThumbnail ) {
    	isNonExpire = true;
    	return getDirectS3FileUrl( fsr, isThumbnail );
    }

    //method to get s3 File Url
    public static String getDirectS3FileUrl( File_Storage_Record__c fsr, Boolean isThumbnail ) {

        // Access Key
        String Access_Key_ID = 'AKIAJHNU4WTFXCCTG3PQ';

        // Secret Access Key
        String Secret_Access_Key = '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';
        String productionBucket = 'ih-prod';
        String sandboxBucket = 'ih-sandbox';

        String productionBucketUrl = 'https://ih-prod.s3.amazonaws.com';
        String sandboxBucketUrl = 'https://ih-sandbox.s3.amazonaws.com';
        String productionOrg = 'E0000000YNkj';
        String endPointUrl = Userinfo.getOrganizationId().contains(productionOrg) ? productionBucketUrl : sandboxBucketUrl;

        String expires = ( isNonExpire ) ? String.valueOf(Datetime.now().addYears(15).getTime()/1000) : String.valueOf(Datetime.now().addHours(24).getTime()/1000);

        String filePath = fsr.S3_Path_Name__c;

        if( isThumbnail ) {
            List<String> filePathSplited = filePath.split('\\.');
            filePath = '';

            Integer arrayLength = filePathSplited.size();
            for( Integer i = 0; i < filePathSplited.size() ; i++ ) {
                if( i == 0 ) {
                    filePath += filePathSplited[i];
                }
                else if( i == arrayLength - 1 ) {
                    filePath += '_thumbnail' + '.' + filePathSplited[i];
                }
                else {
                    filePath += '.' + filePathSplited[i];
                }
            }
        }

        //Encode file path URL
        filePath = Encodingutil.urlEncode(filePath, 'UTF-8');

        //remove specific encoded characters(%2F, +)
        filePath = filePath.replaceAll('\\+', '%20').replaceAll('%2F', '/');

        String stringToSign = ( Userinfo.getOrganizationId().contains(productionOrg) ? productionBucket : sandboxBucket )
                              + '/' + filePath;

        String s3RequestUrl =   endPointUrl
                                + '/'
                                + filePath
                                + '?'
                                + 'AWSAccessKeyId=' + Access_Key_ID
                                + '&Expires=' + expires;

        // Now add the GET 0A 0A 0A part after the debug statement
        stringToSign = 'GET\n\n\n' + expires + '\n/' + stringToSign;

        String signature = Encodingutil.urlEncode( IHSignatureService.getS3Signature(stringToSign, Secret_Access_Key), 'UTF-8');
        signature = signature.replaceAll('%2F', '/');

        s3RequestUrl += '&Signature=' + signature;
        System.debug('s3RequestUrl='+ s3RequestUrl);
        return s3RequestUrl;
    }

    // Method for s3 File View
    // returns Url for get file
    public static String getS3FileUrl(File_Storage_Record__c fsr,
                                      Id sObjectRecordId) {
        List<String> lists3FileUrl = getS3FileUrlMap(new List<File_Storage_Record__c>{fsr}, sObjectRecordId).values();
        return (lists3FileUrl.size() > 0 ? lists3FileUrl.get(0) : '');
    }


    // Method for s3 File View
    // returns Url for get map Key=>Value : List of File Storage Record Ids => Url of file
    public static Map<Id, String> getS3FileUrlMap(List<File_Storage_Record__c> listFsr,
                                      Id sObjectRecordId) {

        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        Map<String, File_Storage_Type__c> mapFileType_Fst = new Map<String, File_Storage_Type__c>();
        //when getDirectS3File is false
        if( !getDirectS3File ) {
	        Set<String> setOfFileTypes = new Set<String>();
	        for(File_Storage_Record__c fsr : listFsr) {
	            setOfFileTypes.add(fsr.File_Type__c);
	        }

	        List<File_Storage_Type__c> listFST = [Select Name,
	                                              Allowed_For_Objects__c,
	                                              Folder_Access__c,
	                                              MetaData_Record__c,
	                                              Upload_To_SFN__c,
	                                              Url_Expiration_Minutes__c
	                                              From File_Storage_Type__c
	                                              Where Allowed_For_Objects__c includes (:sObjectName)
	                                              And Name in: setOfFileTypes
	                                              ];

	        for(File_Storage_Type__c fst : listFST) {
	            mapFileType_Fst.put(fst.Name.toLowerCase(), fst);
	        }
        }

        Map<Id, String> mapFSR_s3RequestUrl = new Map<Id, String>();
        for(File_Storage_Record__c fsr : listFsr) {
	          if( getDirectS3File ) {
	            mapFSR_s3RequestUrl.put(fsr.Id, getDirectS3FileUrl(fsr));
	          }
	          else {
	            mapFSR_s3RequestUrl.put(fsr.Id, getS3FileUrl(fsr, sObjectRecordId, mapFileType_Fst));
	          }
        }

        return mapFSR_s3RequestUrl;

    }

    // method to get thumbnail url for single reocrd
    public static String getS3Thumbnail(File_Storage_Record__c fsr,
                                      Id sObjectRecordId) {
        List<String> lists3FileUrl = getS3FileUrlMap(new List<File_Storage_Record__c>{fsr}, sObjectRecordId).values();
        return (lists3FileUrl.size() > 0 ? lists3FileUrl.get(0) : '');
    }

    // method to get thumbnail url for multiple file storage records
    public static Map<Id, String> getS3ThumbnailUrlMap(List<File_Storage_Record__c> listFsr,
                                      Id sObjectRecordId) {

        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        Set<String> setOfFileTypes = new Set<String>();
        for(File_Storage_Record__c fsr : listFsr) {
            setOfFileTypes.add(fsr.File_Type__c);
        }

        Map<String, File_Storage_Type__c> mapFileType_Fst = new Map<String, File_Storage_Type__c>();
        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name in: setOfFileTypes
                                              ];

        for(File_Storage_Type__c fst : listFST) {
            mapFileType_Fst.put(fst.Name.toLowerCase(), fst);
        }

        Map<Id, String> mapFSR_s3RequestUrl = new Map<Id, String>();
        for(File_Storage_Record__c fsr : listFsr) {

            mapFSR_s3RequestUrl.put(fsr.Id, getDirectS3FileThumbnailUrl(fsr));
            //mapFSR_s3RequestUrl.put(fsr.Id, getS3ThumbnailUrl(fsr, sObjectRecordId, mapFileType_Fst));

        }

        return mapFSR_s3RequestUrl;

    }

    //method to upload file to S3 server
    public static HttpResponse s3UploadFile(Id sObjectRecordId,
                                            String fileName,
                                            String fileType) {

        String action = S3_ACTION_UPLOAD_FILE;
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        String folderAccess = '';

        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileType
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        if(fst.Id != null) {
            folderAccess = fst.Folder_Access__c;
        }

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&folderAccess=' + folderAccess
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' +  getURLEncodedString(signature);

        HttpResponse response = executeGet(s3RequestUrl);
        return response;
    }

    // method to send GET request
    public static HttpResponse executeGet(String sUrl){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sUrl);
        req.setMethod('GET');
        req.setTimeout(60000);
        HttpResponse res;
        if(!Test.isRunningTest()){
            res = h.send(req);
        }
        else{
             res = new HttpResponse();
        }
        return res;
    }

  public static HttpResponse s3uploadFileFromAttachment(Id attachmentId, String fileType) {

        Attachment att = ( Attachment ) Utility.selectStar(attachmentId);
        Id sObjectRecordId = att.ParentId;

        String action = 's3uploadFileFromAttachment';
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        String fileName = att.Name;

        String folderAccess = '';

        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileType
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        if(fst.Id != null) {
            folderAccess = fst.Folder_Access__c;
        }

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&attachmentId=' + attachmentId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&folderAccess=' + folderAccess
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' +  getURLEncodedString(signature);

        HttpResponse response = executeGet( s3RequestUrl );
        return response;
    }

    public static void uploadAttachmentToS3FromBase64(Id attachmentId, String fileType) {
        Attachment att = ( Attachment )Utility.selectStar(attachmentId);
        s3UploadFileFromBase64( EncodingUtil.base64Encode(att.Body), att.Name, att.ContentType, fileType, att.ParentId );
    }

    //method to upload file to S3 server FromBase64
    public static HttpResponse s3UploadFileFromBase64(  String fileBodyBase64Encoded,
                                                        String fileName,
                                                        String contentType,
                                                        String fileType,
                                                        Id sObjectRecordId
                                                       ) {

        String action = 's3uploadFileFromBase64';
        String sObjectName = String.valueOf(sObjectRecordId.getSObjectType());

        String folderAccess = '';

        //SOQL to get list of file storage records
        List<File_Storage_Type__c> listFST = [Select Name,
                                              Allowed_For_Objects__c,
                                              Folder_Access__c,
                                              MetaData_Record__c,
                                              Upload_To_SFN__c,
                                              Url_Expiration_Minutes__c
                                              From File_Storage_Type__c
                                              Where Allowed_For_Objects__c includes (:sObjectName)
                                              And Name =: fileType
                                              Limit 1];

        File_Storage_Type__c fst = (listFST.size() > 0 ? listFST.get(0) : new File_Storage_Type__c());
        String timeoutGmt = getURLEncodedString(getTimeoutGmt(fst, action));
        if(fst.Id != null) {
            folderAccess = fst.Folder_Access__c;
        }

        Box_Configuration__c boxConfig = Box_Configuration__c.getOrgDefaults();
        String endPointUrl = boxConfig.Cloudbees_End_Point_Url__c;
        String secret = boxConfig.Cloudbees_Service_Secret__c;
        String s3RequestUrl =   endPointUrl
                                + action
                                + '?orgId=' + Userinfo.getOrganizationId()
                                + '&recordId=' + sObjectRecordId
                                + '&userId=' + Userinfo.getUserId()
                                + '&fileType=' + getURLEncodedString(fileType)
                                + '&fileName=' + getURLEncodedString(fileName)
                                + '&folderAccess=' + folderAccess
                                + '&timeoutGmt=' + getURLEncodedString(timeoutGmt);

        String signature = IHSignatureService.getCloudbeesSignature(s3RequestUrl, secret);
        s3RequestUrl += '&signature=' +  getURLEncodedString(signature);

        HttpResponse response = executePost( s3RequestUrl, fileBodyBase64Encoded, contentType );
        return response;
    }

  //execute post
    private static HttpResponse executePost(String sUrl,
                                            String reqBodyBase64,
                                            String contentType) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();

        if(contentType != null) {
            req.setHeader('Content-Type', contentType);
        }

        req.setEndpoint(sUrl);
        req.setMethod('POST');
        req.setBody(reqBodyBase64);
        req.setTimeout(60000);
        HttpResponse res;
        if(!Test.isRunningTest()){
            res = h.send(req);
        }
        else{
             res = new HttpResponse();
        }
        return res;
    }

	// Method to get File_Storage_Record__c all fields by filter on S3PathName
	private static List<File_Storage_Record__c> getFileStorageRecordsByS3PathName( String s3PathName ) {

		String SOQLQueryFSR =    'Select ';
        Schema.DescribeSObjectResult describeFileStorageRecord = File_Storage_Record__c.SObjectType.getDescribe();
        //Getting Map<String,Schema.SObjectField> for sObject
        Map<String,Schema.SObjectField> sObjectFieldsMap = describeFileStorageRecord.fields.getMap();

        String fieldsToQuery = '';
        //Loop through sObject field names
        for (String fieldName : sObjectFieldsMap.keySet()) {
            //Getting field describe results
            if(sObjectFieldsMap.get(fieldName).getDescribe().getType() != Schema.DisplayType.LOCATION) {
                fieldsToQuery += ', ' + fieldName;
            }
        }
        fieldsToQuery = fieldsToQuery.subString(1);
        SOQLQueryFSR += fieldsToQuery;
    	SOQLQueryFSR   +=   ' From File_Storage_Record__c '
	    	                  + ' Where S3_Path_Name__c =: s3PathName '
							  + ' Limit 1 ';

        List<File_Storage_Record__c> fileStorageRecordList = Database.query( SOQLQueryFSR );
        return fileStorageRecordList;

	}
    //inner class to for getPortfolioIds method
    global class PortfolioS3Migration {
       webService String salesforceRecordId;
       webService String propertyCode;
       //constructor
       global PortfolioS3Migration(String propertyCode, String salesforceRecordId) {
           this.propertyCode = propertyCode;
           this.salesforceRecordId = salesforceRecordId;
       }
    }

    public class IHS3IntegrationServiceException extends Exception {

    }

    public static boolean isImageFile(String filename) {
      return (filename.containsIgnoreCase('.jpeg')
              ||filename.containsIgnoreCase('.jpg')
              ||filename.containsIgnoreCase('.png')
              ||filename.containsIgnoreCase('.gif')
              ||filename.containsIgnoreCase('.bmp'));
    }



}