/**
 *  Description :   Controller class for VFP PortfolioHomeFrontThumbnail
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   12/27/2013
 *
 **/
 public without sharing class PortfolioHomeFrontThumbnailController {

	public Property__c portfolio {get;set;}

	public Map<Id, Map<String, List<List<FileStorageManagerWrapper>>>> mapSObjectIdToMapFileTypeToListofListOfFiles {get;set;}
	public Map<Id, SOBject> mapSObjectIdToSObject {get;set;}
	public Map<String, String> mapSObjectKeyPrefixToSObjectLabel {get;set;}
	public Map<Id, List<String>> mapSObjectIdToListOfFileTypes {get;set;}

	public Id selectedFileStorageRecordId { get;set; }
	public boolean hasError {get;set;}

	// constructor
    public PortfolioHomeFrontThumbnailController(ApexPages.StandardController controller) {
        try {
        		hasError = false;
        		Set<String> setFileTypeNames = new Set<String>{ 'Photos - Before Rehab' , 'Photos - After Rehab'};

				mapSObjectIdToMapFileTypeToListofListOfFiles = new Map<Id, Map<String, List<List<FileStorageManagerWrapper>>>>();
				mapSObjectIdToListOfFileTypes = new Map<Id, List<String>>();
				mapSObjectIdToSObject = new Map<Id, SOBject>();
				mapSObjectKeyPrefixToSObjectLabel = new Map<String, String>();

				portfolio = ( Property__c ) controller.getRecord();

				// query properties
			    Map<Id, Property__c> mapProperties = new Map<Id, Property__c> ( [Select Id,
			                                                                            Name,
			                                                                            Home_Front_Thumbnail_Image__c,
			                                                                            Home_Front_Thumbnail_Url_Suffix__c,
			 																        ( Select File_Type__c,
							                                                                File_Name__c,
							                                                                S3_Path_Name__c
							                                                          From File_Storage_Records__r
							                                                          Where File_Type__c in: setFileTypeNames
							                                                          Order By CreatedDate ASC
							                                                         )
						                                                          From Property__c
						                                                       	  Where Id =: portfolio.Id]
						                                                       );

				if( mapProperties.size() > 0 ) {
					String sObjectKeyPrefix = String.valueOf( mapProperties.values().get(0).Id ).subString(0, 3);
					if( !mapSObjectKeyPrefixToSObjectLabel.containsKey( sObjectKeyPrefix ) ) {
						Schema.SObjectType sObjectAPIName = mapProperties.values().get(0).Id.getSObjectType();
						mapSObjectKeyPrefixToSObjectLabel.put( sObjectKeyPrefix, sObjectAPIName.getDescribe().getLabel() );
					}
				}

				Integer noOfThumbnailPerRow = 4;
				// loop over properties
				for( Property__c property : mapProperties.values() ) {

					portfolio = property;
					mapSObjectIdToSObject.put( property.Id, property );
				    //system.assert( false , mapSObjectIdToSObject );
	                List<File_Storage_Record__c> listFSR = getImageFiles( property );
	                Map<Id, String> mapFSR_s3ThumbnailUrl = IHS3IntegrationServiceEnh.getS3ThumbnailUrlMap( listFSR, portfolio.Id );

	                Map<String, List<List<FileStorageManagerWrapper>>> mapFileTypeToListOfListOfFiles = new Map<String, List<List<FileStorageManagerWrapper>>>();
	                for( File_Storage_Record__c fsr : listFSR ) {

						List<List<FileStorageManagerWrapper>> listOfListFileStorageManagerWrapper = new List<List<FileStorageManagerWrapper>>();
	                	List<FileStorageManagerWrapper> listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();

	                	if( mapFileTypeToListOfListOfFiles.containsKey( fsr.File_Type__c ) ) {
	                		listOfListFileStorageManagerWrapper = mapFileTypeToListOfListOfFiles.get( fsr.File_Type__c );
	                		if( listOfListFileStorageManagerWrapper.size() > 0 ) {
	                			listFileStorageManagerWrapper = listOfListFileStorageManagerWrapper.get( listOfListFileStorageManagerWrapper.size() - 1 );
	                		}
	                	}

	                	if( listOfListFileStorageManagerWrapper.size() == 0 || listFileStorageManagerWrapper.size() >= noOfThumbnailPerRow ) {
	                		listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();
	                		listOfListFileStorageManagerWrapper.add( listFileStorageManagerWrapper );
	                	}
                		listFileStorageManagerWrapper.add( new FileStorageManagerWrapper( fsr, mapFSR_s3ThumbnailUrl.get(fsr.Id) ) );
                		mapFileTypeToListOfListOfFiles.put( fsr.File_Type__c, listOfListFileStorageManagerWrapper );

	                }

	            	// when has image files in "Photos - Before Rehab" or "Photos - After Rehab" file type
	            	if( listFSR.size() > 0 ) {
	            		// fill mapSObjectIdToMapFileTypeToListofListOfFiles
	                    mapSObjectIdToMapFileTypeToListofListOfFiles.put( property.Id, mapFileTypeToListOfListOfFiles );
	                }

		        }

                // query rehabs for the properties
      		    Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c> ( [Select Id,
      		    													  Name,
                                                                      Portfolio__c,
                                                                      HD_Budget_Walk__c,
                                                               ( Select File_Type__c,
                                                                        File_Name__c,
                                                                        S3_Path_Name__c
                                                                  From File_Storage_Records__r
                                                                  Where File_Type__c in: setFileTypeNames
                                                                  Order By CreatedDate ASC
                                                               )
                                                               From Rehab__c
                                                               Where Portfolio__c =: portfolio.Id
                                                               Order By CreatedDate DESC]
                                                             );


				if( mapRehabs.size() > 0 ) {
					String sObjectKeyPrefix = String.valueOf( mapRehabs.values().get(0).Id ).subString(0, 3);
					if( !mapSObjectKeyPrefixToSObjectLabel.containsKey( sObjectKeyPrefix ) ) {
						Schema.SObjectType sObjectAPIName = mapRehabs.values().get(0).Id.getSObjectType();
						mapSObjectKeyPrefixToSObjectLabel.put( sObjectKeyPrefix, sObjectAPIName.getDescribe().getLabel() );
					}
				}


				// loop over rehabs
		        for( Rehab__c rehab : mapRehabs.values() ) {

					mapSObjectIdToSObject.put( rehab.Id, rehab );

	                List<File_Storage_Record__c> listFSR = getImageFiles( rehab );
	                Map<Id, String> mapFSR_s3ThumbnailUrl = IHS3IntegrationServiceEnh.getS3ThumbnailUrlMap( listFSR, rehab.Id );

                    Map<String, List<List<FileStorageManagerWrapper>>> mapFileTypeToListOfListOfFiles = new Map<String, List<List<FileStorageManagerWrapper>>>();
	                for( File_Storage_Record__c fsr : listFSR ) {

						List<List<FileStorageManagerWrapper>> listOfListFileStorageManagerWrapper = new List<List<FileStorageManagerWrapper>>();
	                	List<FileStorageManagerWrapper> listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();

	                	if( mapFileTypeToListOfListOfFiles.containsKey( fsr.File_Type__c ) ) {
	                		listOfListFileStorageManagerWrapper = mapFileTypeToListOfListOfFiles.get( fsr.File_Type__c );
	                		if( listOfListFileStorageManagerWrapper.size() > 0 ) {
	                			listFileStorageManagerWrapper = listOfListFileStorageManagerWrapper.get( listOfListFileStorageManagerWrapper.size() - 1 );
	                		}
	                	}

	                	if( listOfListFileStorageManagerWrapper.size() == 0 || listFileStorageManagerWrapper.size() >= noOfThumbnailPerRow ) {
	                		listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();
	                		listOfListFileStorageManagerWrapper.add( listFileStorageManagerWrapper );
	                	}
                		listFileStorageManagerWrapper.add( new FileStorageManagerWrapper( fsr, mapFSR_s3ThumbnailUrl.get(fsr.Id) ) );
                		mapFileTypeToListOfListOfFiles.put( fsr.File_Type__c, listOfListFileStorageManagerWrapper );

	                }
	            	// when has image files in "Photos - Before Rehab" or "Photos - After Rehab" file type
	            	if( listFSR.size() > 0 ) {
	            		// fill mapSObjectIdToMapFileTypeToListofListOfFiles
	                    mapSObjectIdToMapFileTypeToListofListOfFiles.put( rehab.Id, mapFileTypeToListOfListOfFiles );
	                }
		        }

		        // query non cancelled HD Budget Walks for the Property
		        Map<Id, HD_Budget_Walk__c> mapHDBudgetWalks = new Map<Id, HD_Budget_Walk__c> ( [Select Id,
		                                                                                              Name,
										                                                              Rehab__c,
										                                                              Rehab__r.Portfolio__c,
										                                                       ( Select File_Type__c,
										                                                                File_Name__c,
										                                                                S3_Path_Name__c
										                                                          From File_Storage_Records__r
										                                                          Where File_Type__c =: setFileTypeNames
										                                                          Order By CreatedDate ASC
										                                                       )
										                                                       From HD_Budget_Walk__c
										                                                       Where Rehab__r.Portfolio__c =: portfolio.Id
										                                                       Order By CreatedDate DESC]
										                                                     );

				if( mapHDBudgetWalks.size() > 0 ) {
					String sObjectKeyPrefix = String.valueOf( mapHDBudgetWalks.values().get(0).Id ).subString(0, 3);
					if( !mapSObjectKeyPrefixToSObjectLabel.containsKey( sObjectKeyPrefix ) ) {
						Schema.SObjectType sObjectAPIName = mapHDBudgetWalks.values().get(0).Id.getSObjectType();
						mapSObjectKeyPrefixToSObjectLabel.put( sObjectKeyPrefix, sObjectAPIName.getDescribe().getLabel() );
					}
				}

				// loop over hd budget walks
		        for( HD_Budget_Walk__c hdBudgetWalk : mapHDBudgetWalks.values() ) {

			        mapSObjectIdToSObject.put( hdBudgetWalk.Id, hdBudgetWalk );

	                List<File_Storage_Record__c> listFSR = getImageFiles( hdBudgetWalk );
	                Map<Id, String> mapFSR_s3ThumbnailUrl = IHS3IntegrationServiceEnh.getS3ThumbnailUrlMap( listFSR, hdBudgetWalk.Id );

                    Map<String, List<List<FileStorageManagerWrapper>>> mapFileTypeToListOfListOfFiles = new Map<String, List<List<FileStorageManagerWrapper>>>();
	                for( File_Storage_Record__c fsr : listFSR ) {

						List<List<FileStorageManagerWrapper>> listOfListFileStorageManagerWrapper = new List<List<FileStorageManagerWrapper>>();
	                	List<FileStorageManagerWrapper> listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();

	                	if( mapFileTypeToListOfListOfFiles.containsKey( fsr.File_Type__c ) ) {
	                		listOfListFileStorageManagerWrapper = mapFileTypeToListOfListOfFiles.get( fsr.File_Type__c );
	                		if( listOfListFileStorageManagerWrapper.size() > 0 ) {
	                			listFileStorageManagerWrapper = listOfListFileStorageManagerWrapper.get( listOfListFileStorageManagerWrapper.size() - 1 );
	                		}
	                	}

	                	if( listOfListFileStorageManagerWrapper.size() == 0 || listFileStorageManagerWrapper.size() >= noOfThumbnailPerRow ) {
	                		listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();
	                		listOfListFileStorageManagerWrapper.add( listFileStorageManagerWrapper );
	                	}
                		listFileStorageManagerWrapper.add( new FileStorageManagerWrapper( fsr, mapFSR_s3ThumbnailUrl.get(fsr.Id) ) );
                		mapFileTypeToListOfListOfFiles.put( fsr.File_Type__c, listOfListFileStorageManagerWrapper );

	                }
	            	// when has image files in "Photos - Before Rehab" or "Photos - After Rehab" file type
	            	if( listFSR.size() > 0 ) {
	            		// fill mapSObjectIdToMapFileTypeToListofListOfFiles
	                    mapSObjectIdToMapFileTypeToListofListOfFiles.put( hdBudgetWalk.Id, mapFileTypeToListOfListOfFiles );
	                }

		        }

				for( Id sObjId : mapSObjectIdToMapFileTypeToListofListOfFiles.keySet() ) {
			        List<String> listSortedFileTypes = new List<String>();
	                for( String fileType : mapSObjectIdToMapFileTypeToListofListOfFiles.get(sObjId).keySet() ) {
	                 	listSortedFileTypes.add( fileType );
	                }
	                listSortedFileTypes.sort();
	            	mapSObjectIdToListOfFileTypes.put( sObjId, listSortedFileTypes );
				}
        }
        catch(Exception e){
        	ApexPages.addMessages(e);
        }
    }

	// method to get Photos - Afte Rehab Image files
	private List<File_Storage_Record__c> getImageFiles( SObject sObj ) {
    	List<File_Storage_Record__c> listFSR = new List<File_Storage_Record__c>();
    	if( sObj.getSObjects( 'File_Storage_Records__r' ) != null ) {
	    	// check for image file
	    	for( File_Storage_Record__c fsr : sObj.getSObjects( 'File_Storage_Records__r' ) ) {
	    		if( IHS3IntegrationServiceEnh.isImageFile(fsr.File_Name__c) ) {
	    			listFSR.add( fsr );
	    		}
	    	}
    	}
        return listFSR;
    }

	// method to get non expire thumbnail url suffix
	private String getThumbnailURLSuffix( File_Storage_Record__c fsr ) {
		String thumbnailURLSuffix;
		// get thumbnail url
		String thumbnailURL = IHS3IntegrationServiceEnh.getDirectS3FileUrlNonExpire( fsr, true );
		if( thumbnailURL != null ) {
			// split by OrgId
			List<String> listThumbnailURL = thumbnailURL.split( '/' + Userinfo.getOrganizationId() + '/', 2 );
			// when splited url's list has size greater than 1
			if( listThumbnailURL.size() > 1 ) {
				thumbnailURLSuffix = listThumbnailURL.get(1);
			}
		}
		// return thumbnail url suffix
		return thumbnailURLSuffix;
	}

    public void saveHomeFrontThumbnailImage() {
		try {
				if( selectedFileStorageRecordId != null && String.valueOf(selectedFileStorageRecordId).trim().length() > 0 ) {
					Property__c property = new Property__c( Id = portfolio.Id );
					property.Home_Front_Thumbnail_Url_Suffix__c = getThumbnailURLSuffix( ( File_Storage_Record__c )Utility.selectStar(selectedFileStorageRecordId) );
					update property;
					hasError = false;
				}

		}
		catch( Exception e ){
			hasError = true;
        	ApexPages.addMessages(e);
		}
	}


    // wrapper class
    public class FileStorageManagerWrapper {

        public File_Storage_Record__c fileStorageRecord {get;set;}
        public String s3getThumbnailUrl {get;set;}
        public Boolean isImg {get;set;}

        public FileStorageManagerWrapper(File_Storage_Record__c fileStorageRecord,
                                         String s3thumbnailUrl
                                         ) {

            this.fileStorageRecord = fileStorageRecord;
            this.s3getThumbnailUrl = s3thumbnailUrl;
            this.isImg = IHS3IntegrationServiceEnh.isImageFile(fileStorageRecord.File_Name__c);
	    }
    }

 }