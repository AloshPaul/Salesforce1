/**
 *  Description  	:	Schedule Class is to create main yardi .csv for all records
 *
 *  Created By		:	Abhinav Sharma
 *
 *  Created Date	:	08/21/2013
 *
 *  Current Version :   v1.0
 *
 *  Revision Logs	:	v1.0 - Created
 *
 **/

global with sharing class ScheduleGenerateYardiIntegrationMainCSV implements Schedulable{
	
    //Reporting Date
    public Date reportingDate;
    
    //execute schedule
    global void execute(SchedulableContext sc) {

    	//List to hold the Region Strings
    	String[] regionList1 = new List<String>{};

    	//Run Batch for generating Yardi main csv for all property records
    	BatchGenerateYardiIntegrationCSV.runJobForPropertiesByRegions(regionList1,reportingDate);
    }
}