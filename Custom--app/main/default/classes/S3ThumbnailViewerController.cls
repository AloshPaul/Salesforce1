/**
 *   Description  :  Controller class for S3ImageManager visualforce pages for SObject
 *
 *   Created By Shrinath
 *
 *   Created Date:  07/24/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
 public without sharing class S3ThumbnailViewerController {

     Public Sobject sObj {get;set;}

     Public String pageTitle {get;set;}

     public List<SelectOption> fileStorageTypes { get; set; }
     // seleted option
     public String selectedFileStorageType { get; set; }
     // seleted file type
     public String selectedFileType { get; set; }

     // record id of seleted file type
     public String selectedObjectRecordId { get; set; }

     public List<FileStorageManagerWrapper> listFileStorageManagerWrapper {get;set;}
     public MAP<String, Map<Id, String>> mapOfFileType_mapFSR_s3RequestUrl {get; set;}
     public Map<String, Map<Id, String>> mapOfFileType_mapFSR_s3ThumbnailUrl {get; set;}
     public List<List<FileStorageManagerWrapper>> lstOfListImages {get; set;}
     public List<FileStorageManagerWrapper> lstOfListImagesCover {get; set;}
     public List<FileStorageManagerWrapper> imagesToShow {get; set;}
     public List<File_Storage_Record__c> listFileStorageRecordForSequenceUpdate  {get;set;}

     public S3ThumbnailViewerController(ApexPages.StandardController controller) {
        try {
                sObj = controller.getRecord();
                sObj = Utility.selectStar(sObj.Id);
                init();
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }
    }

    public Boolean showOtherPhotos {
        get {
              if(showOtherPhotos == null)
                  showOtherPhotos = false;
              return showOtherPhotos;
        }
        set;
    }

  // If no. of Images <= 4, do not show Other Photos link
    public Boolean getDisplayOtherPhotosLink() {
        //if(imagesToShow != null && imagesToShow.size() > 4)
        if(lstOfListImages != null && lstOfListImages.size() > 0)
            return true;
        return false;
    }

    public void toggleOtherPhotos() {
        showOtherPhotos = !showOtherPhotos;
    }

    // Used in page to decide if the page is view Photos mode or Edit Photo Sequence mode.
    public Boolean inEditPhotoOrder {
        get {
                if(inEditPhotoOrder == null)
                    inEditPhotoOrder = false;
                return inEditPhotoOrder;
        }
        set;
    }


    // Function to change the filetype and get the photos for that
    public void getChangedFileTypePhotos() {
      init();
    }

    //method to get other related object's
    private static Map<String, String> getAssociatedSObjects(Id sObjectId, SObject sObj){

         //get File_Storage_Record__c field describe
         Map<String, Schema.SObjectField> fileStorageRecordObjFieldMap = Schema.SObjectType.File_Storage_Record__c.fields.getMap();
         Set<String> setObjectHavingReferenceFieldInFSR = new Set<String>();
         for(String fieldName : fileStorageRecordObjFieldMap.keySet()){
             Schema.DescribeFieldResult fieldDescribe = fileStorageRecordObjFieldMap.get(fieldName).getDescribe();
             //if reference type field
             if(fieldDescribe.isCustom() && fieldDescribe.getType() == Schema.DisplayType.Reference) {
                 setObjectHavingReferenceFieldInFSR.add( fieldName.toLowerCase() );
             }
         }

         Map<String, String> mapFieldToSObjectAPIName = new Map<String, String>();
         String sObjectAPIName = String.valueOf( sObjectId.getSObjectType() );

         //get global describe
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         //get SObject describe
         Schema.SObjectType targetObjectType = gd.get(sObjectAPIName);

         //get field map for the SOBject passed in parameter
         Map<String, Schema.SObjectField> fieldMap = targetObjectType.getDescribe().fields.getMap();
         Set<String> setSObjectAPINames = new Set<String>();

         for(String fieldName : fieldMap.keySet()){

             Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();

             //if reference type field
             if(fieldDescribe.isCustom() && fieldDescribe.getType() == Schema.DisplayType.Reference) {

                 if ( sObj.get(fieldName) != null ) {

                      Id fieldValue = String.valueOf( sObj.get(fieldName) );
                      String relatedSObjectAPIName = String.valueOf( fieldValue.getSObjectType() );
                      //allowed when file storage record object has a lookup to this object
                      if( setObjectHavingReferenceFieldInFSR.contains( relatedSObjectAPIName.toLowerCase() ) ) {
                            mapFieldToSObjectAPIName.put(fieldName, relatedSObjectAPIName);
                            mapAssociatedObjectToRecordId.put( relatedSObjectAPIName.trim().toLowerCase(), fieldValue );
                      }
                 }
             }
         }
         return mapFieldToSObjectAPIName;
    }

    private static String getAssociatedObjectWhereCaluse(SObject sobj,
                                                         Map<String, String> mapFieldToSObjectAPIName) {
        String whereCondition = '';

        for( String mapKey : mapAssociatedObjectToRecordId.keySet() ) {

            Id fieldvalue = mapAssociatedObjectToRecordId.get( mapKey );
            whereCondition += ' OR ' + mapKey + ' = \'' + fieldvalue + '\' ';
        }

        return whereCondition;
    }

    private static Map<String, Id> mapAssociatedObjectToRecordId = new Map<String, Id>();

    //method to initia;ize all collections and properties
    private void init() {

      fileStorageTypes = new List<SelectOption>();
      String sObjectAPIName = String.valueOf(sObj.Id.getSObjectType());

      // Search through all SObjects
      Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
      Schema.sObjectType sObjType = gdMap.get(sObjectAPIName);
      Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
      //get relationship names
      String sObjectLabel = describeResult.getLabel();

      //check if object has access for thumbnail viewer
      File_Storage_Record__c fsrTemp = new File_Storage_Record__c();
      try {
             Object objVal = fsrTemp.get(sObjectAPIName);
      }
      catch(Exception e) {
             throw new CustomException('Thumbnail viewer is not supported for ' + sObjectLabel + '. Please contact to your administrator.');
      }
      pageTitle = describeResult.getLabel() + ' - Photos';

      Map<String, String> mapFieldToSObjectAPIName = getAssociatedSObjects( sObj.Id, sObj );
      // set sObjectsToFilter value
      String sObjectsToFilter = '\'' + sObjectAPIName + '\'';
      for( String sObjName : mapFieldToSObjectAPIName.values() ) {
          sObjectsToFilter += ',' + '\'' + sObjName + '\'';
      }


      String SOQLQueryForFileType = ' Select Name, Allowed_For_Objects__c From File_Storage_Type__c ';
      SOQLQueryForFileType += ' Where Allowed_For_Objects__c includes ( ' + sObjectsToFilter + ' ) ';
      SOQLQueryForFileType += ' And Name Like \'%Photo%\' Order By Name ASC ';

      Map<String, Id> mapSObjectReferenceOnFSRToIdValue = new Map<String, Id>();
      Map<String, String> mapSObjectReferenceOnFSRToFSRField = new Map<String, String>();

      mapSObjectReferenceOnFSRToIdValue.put( sObjectLabel, sObj.Id );
      mapSObjectReferenceOnFSRToFSRField.put( sObjectLabel , sObjectAPIName);


      Id contextRecordId = sObj.Id;
      List<File_Storage_Type__c> listFST = Database.query( SOQLQueryForFileType );
      Set<String> fileTypes = new Set<String>();
      for(File_Storage_Type__c fst : listFST ) {
          for( String allowedObject : fst.Allowed_For_Objects__c.split(';') ) {
              if( allowedObject.containsIgnoreCase(sObjectAPIName)
                  || mapAssociatedObjectToRecordId.containsKey(allowedObject.trim().toLowerCase()) ) {
                  fileTypes.add( fst.Name);
              }
          }
      }

      String SOQLQueryFSR =    'Select File_Type__c, '
                               + 'File_Name__c, '
                               + 'S3_Path_Name__c, '
                               + sObjectAPIName;

      for(String mapValue : mapFieldToSObjectAPIName.values() ) {
            SOQLQueryFSR  += ', ' + mapValue;
      }

      SOQLQueryFSR   += ' From File_Storage_Record__c '
                     + 'Where ( ' + sObjectAPIName + ' =: contextRecordId '
                     +  getAssociatedObjectWhereCaluse(sObj, mapFieldToSObjectAPIName)
                     + ' ) AND File_Type__c in: fileTypes '
                     + 'Order By File_Name__c ASC';

      Map<String, Set<String>> mapObjectAPINameToFileTypes = new Map<String, Set<String>>();

      for( File_Storage_Record__c fsr : Database.query( SOQLQueryFSR ) ) {

          if( IHS3IntegrationServiceEnh.isImageFile(fsr.File_Name__c) ) {

                  if( fsr.get( sObjectAPIName ) != null ) {

                      Set<String> setFileTypes = new Set<String>();
                      if( mapObjectAPINameToFileTypes.containsKey(sObjectAPIName.trim().toLowerCase()) ) {
                         setFileTypes = mapObjectAPINameToFileTypes.get(sObjectAPIName.trim().toLowerCase());
                      }
                      setFileTypes.add(fsr.File_Type__c.trim().toLowerCase());
                      mapObjectAPINameToFileTypes.put(sObjectAPIName.trim().toLowerCase(), setFileTypes);
                  }
                  else {
                      for( String fieldAPIName : mapFieldToSObjectAPIName.values() ) {
                            if( fsr.get( fieldAPIName ) != null ) {

                                Set<String> setFileTypes = new Set<String>();
                                if( mapObjectAPINameToFileTypes.containsKey(fieldAPIName.trim().toLowerCase()) ) {
                                    setFileTypes = mapObjectAPINameToFileTypes.get(fieldAPIName.trim().toLowerCase());
                                }
                                setFileTypes.add(fsr.File_Type__c.trim().toLowerCase());
                                mapObjectAPINameToFileTypes.put(fieldAPIName.trim().toLowerCase(), setFileTypes);
                                break;
                            }
                      }
                  }
          }
      }

      //add file types for the object in context
      for(File_Storage_Type__c fst : listFST ) {

          Set<String> setFileTypesWithImages = mapObjectAPINameToFileTypes.get(sObjectAPIName.trim().toLowerCase());

          for( String allowedObject : fst.Allowed_For_Objects__c.split(';') ) {

              if( ( allowedObject.containsIgnoreCase(sObjectAPIName)
                      )
                    && (  ( setFileTypesWithImages != null && setFileTypesWithImages.contains( fst.Name.trim().toLowerCase() ) ) ) ) {
                  fileStorageTypes.add(new SelectOption(sObjectLabel + ': ' + fst.Name, sObjectLabel + ': ' + fst.Name));
              }
          }
      }

      //add file types for the associated object to object in context
      for ( String fieldName : mapFieldToSObjectAPIName.keySet() ) {
          String sObjName = mapFieldToSObjectAPIName.get( fieldName );
          Schema.sObjectType sObjTypeForAllowedObject = gdMap.get(sObjName);
          Schema.DescribeSObjectResult describeResultForAllowedObject = sObjTypeForAllowedObject.getDescribe();
          String sObjectLabelForAllowedObject = describeResultForAllowedObject.getLabel();
          Id relatedRecordId = String.valueOf( sObj.get(fieldName) );
          Set<String> setFileTypesWithImages = mapObjectAPINameToFileTypes.get(sObjName.trim().toLowerCase());

          //add options based on allowed objects for file types
          for(File_Storage_Type__c fst : listFST ) {
              for( String allowedObject : fst.Allowed_For_Objects__c.split(';') ) {
                  if( allowedObject.containsIgnoreCase(sObjName)
                        && ( ( setFileTypesWithImages != null && setFileTypesWithImages.contains( fst.Name.trim().toLowerCase() ) ) ) ) {
                      fileStorageTypes.add(new SelectOption(sObjectLabelForAllowedObject + ': ' + fst.Name, sObjectLabelForAllowedObject + ': ' + fst.Name));
                      mapSObjectReferenceOnFSRToIdValue.put( sObjectLabelForAllowedObject, relatedRecordId );
                      mapSObjectReferenceOnFSRToFSRField.put( sObjectLabelForAllowedObject , allowedObject );
                  }
              }
          }
      }

      //when file storage type has options
      if( fileStorageTypes.size() > 0 ) {

          if( ( selectedFileStorageType == null || selectedFileStorageType == '' ) && fileStorageTypes.size() > 0 ) {
                selectedFileStorageType = fileStorageTypes.get(0).getValue();
          }

          String selectedObject = mapSObjectReferenceOnFSRToFSRField.get( selectedFileStorageType.split(':')[0].trim() );
          selectedObjectRecordId = mapSObjectReferenceOnFSRToIdValue.get( selectedFileStorageType.split(':')[0].trim() );
          //name of selcted file type splited the Object Label from slected option
          selectedFileType = selectedFileStorageType.split(':')[1].trim();

          List<File_Storage_Record__c> listOfFSRWithoutSequnce = new List<File_Storage_Record__c>();
          List<File_Storage_Record__c> listOfFSRWithSequnce = new List<File_Storage_Record__c>();
          Id sObjectId = sObj.Id;

          String SOQLQuery = 'Select File_Type__c, '
                           + 'File_Name__c, '
                           + 'S3_Path_Name__c '
                           + 'From File_Storage_Record__c '
                           + 'Where ' + selectedObject + ' =: selectedObjectRecordId '
                           + 'AND File_Type__c =: selectedFileType '
                           + 'Order By File_Name__c ASC';


          for( File_Storage_Record__c fsr : Database.query( SOQLQuery ) ) {
              if( IHS3IntegrationServiceEnh.isImageFile(fsr.File_Name__c) ) {
                    listOfFSRWithSequnce.add(fsr);
              }
          }

          ListFileStorageRecordForSequenceUpdate = new List<File_Storage_Record__c>();
          List<File_Storage_Record__c> listFileStorageRecord = new List<File_Storage_Record__c>();
          listFileStorageRecord.addAll(listOfFSRWithSequnce);
          listFileStorageRecord.addAll(listOfFSRWithoutSequnce);

          for(File_Storage_Record__c fsr : listFileStorageRecord) {
              listFileStorageRecordForSequenceUpdate.add(new File_Storage_Record__c(Id = fsr.Id));
          }

          mapOfFileType_mapFSR_s3RequestUrl = (mapOfFileType_mapFSR_s3RequestUrl == null ) ? new Map<String, Map<Id, String>>() : mapOfFileType_mapFSR_s3RequestUrl;
          mapOfFileType_mapFSR_s3ThumbnailUrl = (mapOfFileType_mapFSR_s3ThumbnailUrl == null ) ? new Map<String, Map<Id, String>>() : mapOfFileType_mapFSR_s3ThumbnailUrl;

          if(!mapOfFileType_mapFSR_s3RequestUrl.containsKey(selectedFileStorageType)) {
            mapOfFileType_mapFSR_s3RequestUrl.put(selectedFileStorageType, IHS3IntegrationServiceEnh.getS3FileUrlMap(listFileStorageRecord, sObj.Id));
          }

          if(!mapOfFileType_mapFSR_s3ThumbnailUrl.containsKey(selectedFileStorageType)) {
            mapOfFileType_mapFSR_s3ThumbnailUrl.put(selectedFileStorageType, IHS3IntegrationServiceEnh.getS3ThumbnailUrlMap(listFileStorageRecord, sObj.Id));
          }

          Map<Id, String> mapFSR_s3RequestUrl = mapOfFileType_mapFSR_s3RequestUrl.containsKey(selectedFileStorageType) ? mapOfFileType_mapFSR_s3RequestUrl.get(selectedFileStorageType) : new Map<Id, String>();
          Map<Id, String> mapFSR_s3ThumbnailUrl = mapOfFileType_mapFSR_s3ThumbnailUrl.containsKey(selectedFileStorageType) ? mapOfFileType_mapFSR_s3ThumbnailUrl.get(selectedFileStorageType) : new Map<Id, String>();

          listFileStorageManagerWrapper = new List<FileStorageManagerWrapper>();
          for(File_Storage_Record__c fsr : listFileStorageRecord) {
               if( IHS3IntegrationServiceEnh.isImageFile(fsr.File_Name__c) ) {

                    listFileStorageManagerWrapper.add(new FileStorageManagerWrapper( fsr,
                                                        mapFSR_s3RequestUrl.get(fsr.Id),
                                                        mapFSR_s3ThumbnailUrl.get(fsr.Id) ));

                }
          }

          imagesToShow = listFileStorageManagerWrapper;
          populateListofListImages(listFileStorageManagerWrapper);
      }
  }

  private void populateListofListImages(List<FileStorageManagerWrapper> imageWrappers) {

        lstOfListImages = new List<List<FileStorageManagerWrapper>>();
        lstOfListImagesCover = new List<FileStorageManagerWrapper>();

        Integer index = 0;
        for(FileStorageManagerWrapper imageW : imageWrappers) {
            if(index < 4)
                lstOfListImagesCover.add(imageW);
            else {
                if(Math.mod(index, 4) == 0)
                    lstOfListImages.add(new List<FileStorageManagerWrapper>());
                lstOfListImages[lstOfListImages.size() - 1].add(imageW);
            }
            index++;
        }
        while(index > 4 && Math.mod(index, 4) != 0) {
            lstOfListImages[lstOfListImages.size() - 1].add(new FileStorageManagerWrapper());
            index++;
        }

    }

    public class FileStorageManagerWrapper {

      public File_Storage_Record__c fileStorageRecord {get;set;}
      public String fileUrl {get;set;}
      public String thumbNailUrl {get;set;}

    public FileStorageManagerWrapper() {

    }

    public FileStorageManagerWrapper(File_Storage_Record__c fileStorageRecord,
                       String s3getFileUrl,
                       String s3thumbnailUrl
                       ) {
        this.fileStorageRecord = fileStorageRecord;
        this.fileUrl = s3getFileUrl;
        this.thumbNailUrl = s3thumbnailUrl;
      }
    }

}