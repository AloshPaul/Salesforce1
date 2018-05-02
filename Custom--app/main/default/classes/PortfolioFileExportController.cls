/**
 *   Description  :  Controller Class for VFP PortfolioFileExport
 *
 *   Created By Shrinath
 *
 *   Created Date:  01/23/2014
 *
 *   Revision Logs:  V1.0 - Created
 **/
public without sharing class PortfolioFileExportController {

	// Get the List of Regions
	public List<SelectOption> regionOptions {
		get {
			if(regionOptions == null) {
				regionOptions = new List<SelectOption>();
				regionOptions.add(new SelectOption('', 'Select'));
				for(Region__c region : [Select Name from Region__c order by Name])
					regionOptions.add(new SelectOption(region.Name, region.Name));
			}
			return regionOptions;
		}
		private set;
	}

	// Get the List of File Storage Types
	public List<SelectOption> fileStrTypeOptions {
		get {
			if(fileStrTypeOptions == null) {
				fileStrTypeOptions = new List<SelectOption>();
				fileStrTypeOptions.add(new SelectOption('', 'Select'));
				// Get all the File Types for Property
				for(File_Storage_Type__c fileStrType : [SELECT Name FROM File_Storage_Type__c
																	WHERE Upload_To_SFN__c = true
																	AND Allowed_For_Objects__c INCLUDES ('Property__c')
																	order by Name])
					fileStrTypeOptions.add(new SelectOption(fileStrType.Name, fileStrType.Name));
			}
			return fileStrTypeOptions;
		}
		private set;
	}

	public String fund {get; set;}
	public String region {get; set;}
	public String fileStrType {get; set;}

	// Constructor
	public PortfolioFileExportController() {

		// Get the values from the Query String parameters
		fund = VFUtil.getPageParameter('fund');
		region = VFUtil.getPageParameter('region');
		fileStrType = VFUtil.getPageParameter('fileStrType');
		// when fileStrType is null , fund == null so that it is defaulted only when user comes on page first time not when he clicks on search
		if(  fileStrType == null && fund == null ) {
			fileStrType = 'Lease Agreement';
		}

		//showMarkDelivered = false;
	}

	// Function to search the records
	public PageReference searchRecords() {
		// Show error message if any of the filter selected is blank
		if(String.isBlank(fund)) {
			VFUtil.AddErrorMessage('Fund is required for all searches.');
			return null;
		}
		fileStrRecordList = null;
		return getCurrentPageReference();
	}

	public PageReference getCurrentPageReference() {
		// Add the paramters to page and recall the page.
		PageReference pg = Page.PortfolioFileExport;
		pg.getParameters().put('fund', fund);
		pg.getParameters().put('region', region);
		pg.getParameters().put('fileStrType', fileStrType);

		pg.setRedirect(true);
		return pg;
	}

	public Integer totalSize {get; set;}

	// Variable to Get the File Storage records in a wrapper class
	public List<FileStorageRecordWrapper> fileStrRecordList {
		get {
			if(fileStrRecordList == null) {
				//showMarkDelivered = false;
				totalSize = 0;
				fileStrRecordList = new List<FileStorageRecordWrapper>();
				// Get records only if all the filter criterias are selected
				if(String.isNotBlank(fund)) {

					String query = 'Select Name, File_Name__c, S3_Path_Name__c, File_Type__c, Property__c, Property__r.Region__c, Property__r.Fund__c from 	File_Storage_Record__c';
						  query += ' where Property__c != null '
						  		   + ' and Last_Export_Date__c = null';
					if(String.isNotBlank(fund))
						query += ' and Property__r.Fund__c = :fund';
					if(String.isNotBlank(region))
						query += ' and Property__r.Region__c = :region';
					if(String.isNotBlank(fileStrType))
						query += ' and File_Type__c = :fileStrType';
					query += ' order by Property__r.Region__c, File_Type__c, File_Name__c desc limit 49900';

					List<File_Storage_Record__c> fileStrRecords = (List<File_Storage_Record__c>)Database.query(query);
					if(fileStrRecords != null && !fileStrRecords.isEmpty()) {
						// Get the S3 Url for the files from the helper function
						totalSize = fileStrRecords.size();
						Map<Id, String> mapFSR_s3RequestUrl = IHS3IntegrationServiceEnh.getS3FileUrlMap(fileStrRecords, fileStrRecords[0].Property__c);
						// Add the records to the wrapper list
						for(File_Storage_Record__c fileStrRec : fileStrRecords) {
							String s3Url = (mapFSR_s3RequestUrl.containsKey(fileStrRec.Id)) ? mapFSR_s3RequestUrl.get(fileStrRec.Id) : '';
							fileStrRecordList.add(new FileStorageRecordWrapper(fileStrRec, s3Url));
							if(fileStrRecordList.size() == 200)
								break;
						}
					}
				}

			}
			return fileStrRecordList;
		}
		set;
	}

	// Function to get the File Recors size
	public Integer getFileStrRecordsSize() {
		return (fileStrRecordList != null) ? fileStrRecordList.size() : 0;
	}

	// Wrapper class
	public class FileStorageRecordWrapper {
		public File_Storage_Record__c fileStrRec {get; set;}
		public Boolean errOnUpload {get; set;}
		public String s3Url {get; set;}

		// Constructor
		public FileStorageRecordWrapper(File_Storage_Record__c fileStrRec, String s3Url) {
			this.fileStrRec = fileStrRec;
			this.s3Url = s3Url;
			errOnUpload = false;
		}
	}

	// Function to Mark Deliver the files
	public PageReference markDelievered() {

		List<File_Storage_Record__c> fileStrRecordsForUpdate = new List<File_Storage_Record__c>();
		for(FileStorageRecordWrapper fileStrRecWrap : fileStrRecordList) {
			File_Storage_Record__c temp = fileStrRecWrap.fileStrRec;
			// If error, add error message else add the Uploaded date
			if(!fileStrRecWrap.errOnUpload)
				temp.Last_Export_Date__c = System.today();

			fileStrRecordsForUpdate.add(temp);
		}

		try {
			// Update the file storage records
			update fileStrRecordsForUpdate;
			return getCurrentPageReference();
		}
		catch(Exception e) {
			VFUtil.AddErrorMessage('Following error occurred: ' + e.getMessage());
		}
		return null;
	}

}