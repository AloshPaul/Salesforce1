/**
 * Description  :   This class is resposible for PhotoSlide Show functionality.
 *
 * Created By   :   Krishna Bhatt
 *
 * Created Date :   07/06/2013
 *
 * Revisiion Logs:  V1.0 - Created
 *
**/
public without sharing class PhotoSlideshowViewerController {
	
	//get Sobject Record
    public SObject sObjectRecord {get;set;}
    //get Sobject Name
    public String sObjName {get;set;}
    public List<GenericImageWrapper> listOfGenericImages {get;set;}
    public String fileType;
    public String fsAlias {get;set;}
    public String Url {get;set;}

    public PhotoSlideshowViewerController(){

        try {

            //get Sobject Id
            Id sObjectId = ApexPages.currentPage().getParameters().get('id');
            //get fileType
            fileType = ApexPages.currentPage().getParameters().get('filetype');
            //get url of parent window
            Url =   System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+sObjectId;
            //pass sObject id
            init(sObjectId);
        }
        catch(Exception e) {

            ApexPages.addMessages(e);
        }
    }

    private void init(Id sObjectId) {
 
        //create List of Sobject
        list<SObject> listOfSObject = getSObjectWithGenericImage(sObjectId);
        if(listOfSObject.size() > 0) {

            sObjectRecord = listOfSObject.get(0);
            //create list for wrapper class
            listOfGenericImages = new List<GenericImageWrapper>();
            // create list for file storage type
            List<File_Storage_Record__c> listFileStorageRecord = (List<File_Storage_Record__c>)sObjectRecord.getSObjects('File_Storage_Records__r');

            //get url for PhotoslideShow Viewer images
            Map<Id, String> mapPSV_s3RequestUrl = IHS3IntegrationServiceEnh.getS3FileUrlMap(listFileStorageRecord, sObjectRecord.Id);
            //get url for PhotoslideShow Viewer's Thumbnail Images
            Map<Id, String> mapPSV_s3ThumbnailUrl = IHS3IntegrationServiceEnh.getS3ThumbnailUrlMap(listFileStorageRecord, sObjectRecord.Id);

            for(File_Storage_Record__c fsr : listFileStorageRecord) {

                // check files for images
                if( IHS3IntegrationServiceEnh.isImageFile(fsr.File_Name__c) ) {

                                listOfGenericImages.add(new GenericImageWrapper(fsr, mapPSV_s3RequestUrl.get(fsr.Id), mapPSV_s3ThumbnailUrl.get(fsr.Id) ));
                            }
            }
        }
    }


    public List<SObject> getSObjectWithGenericImage( Id objId) {

        //get Object Name From Id
        String ObjectName = String.valueOf(objId.getSobjectType());
        
        fsAlias = FileStorageService.getFileStorageAlias(objId);
                
        // Get all the fields and build the SOQL
        String soql = 'select Id, Name ';
        soql +=' , ( Select id,name,file_type__c,s3_path_name__c,file_name__c';
        soql +=' from File_Storage_Records__r where File_Type__c=\''+ this.filetype +'\' Order By File_Name__c ASC)';
        soql += ' from ' + ObjectName;
        soql += ' where id =\''+ objId +'\'';

        return Database.query( soql);
    }

    // Wrapper class
    public class GenericImageWrapper {

        public File_Storage_Record__c fileStorageRecord {get;set;}
        public String s3getFileUrl {get;set;}
        public String s3getThumbnailUrl {get;set;}
        public String FileName{get;set;}

        public GenericImageWrapper(File_Storage_Record__c fileStorageRecord,String s3getFileUrl,String s3thumbnailUrl) {
        	
        	//get File Storage Record
            this.fileStorageRecord = fileStorageRecord;
            //get File Name
            this.FileName = fileStorageRecord.File_Name__c;
            //get Image Url
            this.s3getFileUrl = s3getFileUrl;
            //get thumbnail Url
            this.s3getThumbnailUrl = s3thumbnailUrl;
        }
    }

}