/**
 * Description    :     This class is helper class for Trigger_Bidding_Statistics.
 * 
 * Created By     :     Abhinav Sharma
 * 
 * Created Date   :     10/17/2012
 *
 * Revision Logs  :     V1.0 - Created
 *                      V1.1 - Bhavi - 11/19/2012 - New method added(attachBiddingStatWithPipelines)
                        V1.2 - Bhavi - 12/04/2012 - In case of fresh Acquisition Reporting record, date cannot be on weekend
                        V1.3 - Modified by Abhinav Sharma - 10/19/2015 - D-00014660 
 * 
**/
public class Bidding_StatisticsTriggerHelper {
    
    //Flag to control the execution of trigger
    public static Boolean EXECUTE_TRIGGER_BIDDING_STATISTICS = true;
    public static Boolean EXECUTE_VALIDATE_BIDDING_STATISTICS_RECORDS = true;
    public static Boolean EXECUTE_VALIDATE_NATIONAL_REPORTING_RECORDS = true;
    public static Boolean ISEXECUTED = false;
        
    //Validate bidding statistics records
    public static void validateBiddingStatisticsRecords(List<Bidding_Statistics__c> biddingStatistics, Map<Id, Bidding_Statistics__c> oldBiddingStatistics) {
        
        //Get Maximum date for each region
        AggregateResult[] aggrs = [Select Region__c region, Max(Date__c) maxDate from Bidding_Statistics__c 
                                    where Date__c != null AND Region__c != null 
                                   AND ID NOT IN: biddingStatistics group by Region__c];
        
        //Map to hold the reporting date against each region
        Map<String, Date> mapDateByRegion = new Map<String, Date>();
        
        //Loop through the aggrs
        for(AggregateResult aggr : aggrs) {
            
            //add data in collection
            String region = String.valueOf(aggr.get('region'));
            Date reportingDate = Date.valueOf(aggr.get('maxDate'));
            
            //discard for National region
            if(!region.equalsIgnoreCase(Constants.REGION_NATIONAL))
                mapDateByRegion.put(region, reportingDate);
        }
        
        //Create a list of new Biiding statistics to insert
        List<Bidding_Statistics__c> bSToInsert = new List<Bidding_Statistics__c>();
        
        //Loop through the in context bidding records
        for(Bidding_Statistics__c bS : biddingStatistics) {
            
            //Check if this is update scenerio and values changes in either Region or in Date field
            if(oldBiddingStatistics != null && oldBiddingStatistics.containsKey(bS.Id)){
                
                //Old Bidding Stat record
                Bidding_Statistics__c oldRecord = oldBiddingStatistics.get(bS.Id);
                
                //Check if there is a change in val
                if(bS.Region__c == oldRecord.Region__c && bS.Date__c == oldRecord.Date__c)
                    continue;
            }
            
            //check for the last date
            if(bS.Region__c != null && bS.Date__c != null && mapDateByRegion.containsKey(bS.Region__c)) {
                
                //Get max date from Map
                Date maxDate = mapDateByRegion.get(bS.Region__c);
                
                //Bidding Statistics with lower date can not be created
                if(bS.Date__c <= maxDate ) {
                    throw new CustomException('Acquisition Reporting for ' + maxDate.format() + ' exists. This record can not have date similar/smaller then this.');
                }
                
                //validate reporting date
                if(bS.Date__c > maxDate) {
                    
                    //Reporting can not be created for weekend
                    //Check for the last reporting date
                    String day = DateTime.newInstance(bS.Date__c.year(), bS.Date__c.month(), bS.Date__c.day()).format('EEEE');
                    
                    //Chekc if day is saturday or sunday
                    if(day.equalsIgnoreCase('saturday') || day.equalsIgnoreCase('sunday')) {
                        
                        //Throw error
                        throw new CustomException('Reporting can not be done for weekend.');                    
                    }
                
                    //Check if Biiding statistics are defined for privious days
                    if(day.equalsIgnoreCase('monday')) {
                        
                        //Throw error if bidding statistics were skipped
                        if(maxDate.daysBetween(bS.Date__c) != 3) {
                            
                            //Call helper class method to create the missing bidding statistics records directly from the code
                            bSToInsert.addAll(Utility.createBiddingStatisticsForMissingDays(maxDate, bs.Date__c, bs.Region__c));
                            
                            //Throw error
                            //throw new CustomException('Last reporting was defined on ' + maxDate.format() + '. Please define reporing record(s) after that.');
                        }
                    }
                    
                    //Throw error if bidding statistics were skipped
                    else if(maxDate.daysBetween(bS.Date__c) != 1) {
                        
                        //Call helper class method to create the missing bidding statistics records directly from the code
                        bSToInsert.addAll(Utility.createBiddingStatisticsForMissingDays(maxDate, bs.Date__c, bs.Region__c));
                            
                        //Throw error
                        //throw new CustomException('Last reporting was defined on ' + maxDate.format() + '. Please define reporing record(s) after that.');
                    }
                }
            } else if(bS.Date__c != null){
                
                //Reporting can not be created for weekend
                //Check for the last reporting date
                String day = DateTime.newInstance(bS.Date__c.year(), bS.Date__c.month(), bS.Date__c.day()).format('EEEE');
                
                //Chekc if day is saturday or sunday
                if(day.equalsIgnoreCase('saturday') || day.equalsIgnoreCase('sunday')) {
                    
                    //Throw error
                    throw new CustomException('Reporting can not be done for weekend.');                    
                }
            }
        }
        
        //Modified by Abhinav Sharma - D-00014660(10/19/2015)
        //Previously flag was setting in the if condition below. In case if condition not got satisfied somehow then as a result
        //of it this method will execute multiple times that was causing the issue
        //Set the flag for not to execute the trigger again
        Bidding_StatisticsTriggerHelper.EXECUTE_VALIDATE_BIDDING_STATISTICS_RECORDS = false;
        
        //insert records and deactivate Bidding Statistics trigger
        if(bSToInsert.size() > 0) {
            
            //insert records in bulk
            insert bSToInsert;
        }
    }

    //Method
    public static void populateTotalNoOfHomesWonField(List<Bidding_Statistics__c> listNewBiddingStatistics, List<Bidding_Statistics__c> listOldBiddingStatistics) {
    
        //Set to hold the Acquistions Dates
        Set<Date> setDates = new Set<Date>();
        
        //Set to hold the Regions
        Set<String> setRegions = new Set<String>();
        
        if(listNewBiddingStatistics != null) {
        
            //Loop through Bidding Statistics Records
            for(Bidding_Statistics__c bidding : listNewBiddingStatistics) {
                
                //Check for Null
                if(bidding.Date__c != Null) {
                
                    //Populate set with values
                    setDates.add(bidding.Date__c);
                }
                    
                //Check for Null
                if(bidding.Region__c != Null) {
                    
                    //Populate Set with values
                    setRegions.add(bidding.Region__c);
                }
            }
        }
        
        if(listOldBiddingStatistics != null) {
            
            //Loop through Bidding Statistics Records
            for(Bidding_Statistics__c biddingOld : listOldBiddingStatistics) {
            
                //Check for Null
                if(biddingOld.Date__c != Null) {
                
                    //Populate set with values
                    setDates.add(biddingOld.Date__c);
                }
                    
                //Check for Null
                if(biddingOld.Region__c != Null) {
                    
                    //Populate Set with values
                    setRegions.add(biddingOld.Region__c);
                }
            }
        }
        
        //Do Not execute Bidding Statistics trigger
        Bidding_StatisticsTriggerHelper.EXECUTE_TRIGGER_BIDDING_STATISTICS = false;
        
        //Calling Helper Class Method
        Utility.populateTotalNoHomes(setDates, setRegions);
    }
    
    //This method is to attach the pipeline records with appropriate bidding stat record
    public static void attachBiddingStatWithPipelines(List<Bidding_Statistics__c> listBiddingStatistics) {
        
        //create a set to hold the Bidding Stat date and region
        Set<Date> reportingDates = new Set<Date>();
        Set<String> regions = new Set<String>();
        Map<String, Id> mapBiddingStat = new Map<String, Id>();
        
        //Loop through the records and prepare data set
        for(Bidding_Statistics__c biddingStat : listBiddingStatistics) {
            
            //Populate data set
            if(biddingStat.Date__c != null && biddingStat.Region__c != null && biddingStat.Region__c != '') {
                
                reportingDates.add(biddingStat.Date__c);
                regions.add(biddingStat.Region__c);
                
                //Create key for map
                String key = biddingStat.Date__c + '-' + biddingStat.Region__c;
                
                //Check for the key
                if(!mapBiddingStat.containsKey(key)) {
                    
                    //put data in map
                    mapBiddingStat.put(key, biddingStat.Id);            
                }
            }
        }
        
        //List of pipeline records to be updated
        List<Property_Opportunity__c> pipeline = new List<Property_Opportunity__c>();
        
        //Fetch all the property records with the same reporting date
        for(Property_Opportunity__c pLine : [Select Id, Reporting_Date__c, Region__c, Acquisition_Reporting__c 
                                             from Property_Opportunity__c where Reporting_Date__c != null 
                                             AND Reporting_Date__c IN: reportingDates 
                                             AND Region__c != null AND Region__c IN: regions]) {
            
            //Create key for map
            String key = pLine.Reporting_Date__c + '-' + pLine.Region__c;
                
            //Check if pipeline is already assciated with correct Bidding Statistics
            //if not then update the relationship
            if(mapBiddingStat.containsKey(key) && mapBiddingStat.get(key) != pLine.Acquisition_Reporting__c) {
                
                //Populate pLine's bidding stat data
                pLine.Acquisition_Reporting__c = mapBiddingStat.get(key);
                
                //Add in list to be updated
                pipeline.add(pLine);
            }
        }
        
        //Modified by Abhinav Sharma - D-00014660 - (10/19/2015)
        //Do Not execute pipeline trigger
        Property_OpportunityTriggerHelper.EXECUTE_PIPELINE_TRIGGER = false;
        
        //Check for the size
        if(pipeline.size() > 0)
            update pipeline;
    }
    
    //Method is to create the National Region when 1st record is being created
    public static void createNationalRegion(List<Bidding_Statistics__c> biddingStatistics) {
        
        //Create a set if date to create the appropriate National Region record
        Set<Date> reportingDates = new Set<Date>();
        
        //Loop through the records
        for(Bidding_Statistics__c bS : biddingStatistics) {
            
            //Check and add date in set 
            if(bS.Date__c != null && bS.Region__c != Constants.REGION_NATIONAL) {
                
                //Add date in set
                reportingDates.add(bS.Date__c);     
            }
        }
        
        //Get all the national regions
        List<Bidding_Statistics__c> existingNationalRegions = [Select Id, Date__c from Bidding_Statistics__c 
                                                                where Date__c != null AND Date__c IN: reportingDates
                                                                AND Region__c =: Constants.REGION_NATIONAL];
        
        //Create a map of National Region By date
        Map<Date, Bidding_Statistics__c> mapNationalRegions = new Map<Date, Bidding_Statistics__c>();
        
        //loop throgh the region and check what is not existing
        for(Bidding_Statistics__c bS : existingNationalRegions) {
            
            //remove date from set and add in Map
            reportingDates.remove(bS.Date__c);
            mapNationalRegions.put(bS.Date__c, bS);
        }
        
        //list to hold the new Bidding_Statistics__c record
        List<Bidding_Statistics__c> nationalRegions = new List<Bidding_Statistics__c>();
        
        //Create Bidding stat data for remaing date
        for(Date reportingDate : reportingDates) {
            
            //Create a new natioanl Region record for given data
            nationalRegions.add(new Bidding_Statistics__c(Date__c = reportingDate, Region__c = Constants.REGION_NATIONAL));
        }
        
        //Check for the size and insert records
        if(nationalRegions.size() > 0)
            insert nationalRegions;
           
        //Loop through the regions and populate the map
        for(Bidding_Statistics__c bS : nationalRegions) {
            
            //Add data in map
            mapNationalRegions.put(bS.Date__c, bS);
        }
        
        //Create a list of records to be updated
        List<Bidding_Statistics__c> bSToUpdate = new List<Bidding_Statistics__c>();
        
        //lopp through the IN-Context records
        for(Bidding_Statistics__c bS : biddingStatistics) {
            
            //Get related national region
            if(bS.Date__c != null && mapNationalRegions.containsKey(bS.Date__c) && bS.Region__c != Constants.REGION_NATIONAL) {
                
                //Set parent Id
                bSToUpdate.add(new Bidding_Statistics__c(Id = bS.Id, National__c = mapNationalRegions.get(bS.Date__c).Id));
            }   
        }
       
        //update the bidding statistics again
        if(bSToUpdate.size() > 0)
            update bSToUpdate;
    }
    
    public static void markNationalRegionComplete(Map<Id, Bidding_Statistics__c> mapNewAcqReporting, Map<Id, Bidding_Statistics__c> mapOldAcqReporting) {
        
        //Create a list of National reporting regions
        Set<Id> nationalIds = new Set<Id>();
        
        //Loop through the  reporting region records
        for(Bidding_Statistics__c bS : mapNewAcqReporting.values()) {
            
            //Check if record is not national
            if(!bS.Name.EqualsIgnoreCase(Constants.REGION_NATIONAL)) {
                
                //Get the national reporting region Ids
                if(bS.National__c != null)
                    nationalIds.add(bS.National__c);            
            }
        }
        
        //Chekc if there are records to process
        if(nationalIds.size() > 0) {
            
            //Map to hold the Nation with Rgion
            Map<Id, Set<String>> mapNationalWithRegions = new Map<Id, Set<String>>();
            
            //Get records from database
            for(Bidding_Statistics__c bS : [Select Id, Region__c, National__c from Bidding_Statistics__c 
                                                where National__c != null AND National__c IN: nationalIds 
                                                AND Daily_Asset_Report_Completed_By__c != null 
                                                AND Daily_Asset_Report_Completed_Date__c != null ]) {
                
                //Add in map
                if(mapNationalWithRegions.containsKey(bS.National__c))
                    mapNationalWithRegions.get(bS.National__c).add(bS.Region__c);
                else
                    mapNationalWithRegions.put(bS.National__c, new Set<String>{bS.Region__c});
                
            }
            
            //Check if map have been all the regions against a National Key
            if(mapNationalWithRegions.size() > 0) {
            
                //Get all the region
                Schema.DescribeFieldResult F = Bidding_Statistics__c.Region__c.getDescribe();
                List<PicklistEntry> picklistValues =  F.getPicklistValues();
                
                //Get National records
                Map<Id, Bidding_Statistics__c> mapAcqReports = new Map<Id, Bidding_Statistics__c>([Select Id, Daily_Asset_Report_Completed_By__c, 
                                                                            Daily_Asset_Report_Completed_Date__c from Bidding_Statistics__c 
                                                                            where Id IN: mapNationalWithRegions.keySet()]);                                             
                
                //Create a list of records to be updated
                List<Bidding_Statistics__c> listBiddingStatistics = new List<Bidding_Statistics__c>();
                
                //Loop through the map
                for(Id nationalId : mapNationalWithRegions.keySet()) {
                    
                    //get the Bidding stat records
                    Bidding_Statistics__c bS = mapAcqReports.get(nationalId);
                    
                    //Chekc if National record needs to be updated
                    if(bS != null && bS.Daily_Asset_Report_Completed_By__c == null && bS.Daily_Asset_Report_Completed_Date__c == null) {
                        
                        //Get regions
                        Set<String> regions = mapNationalWithRegions.get(nationalId);
                        
                        //Check if all regions have been completed
                        if(regions.size() == picklistValues.size()) {
                            
                            //Modified by Abhinav Sharma - D-00014660 - (10/19/2015) - Added two more fields (in last) to populate on BS records 
                            //Add record in list to be updated
                            listBiddingStatistics.add(new Bidding_Statistics__c(Id = nationalId, 
                                                                                    Daily_Asset_Report_Completed_By__c = UserInfo.getUserId(), 
                                                                                    Daily_Asset_Report_Completed_Date__c = Date.today(),
                                                                                    Daily_Acq_Report_Complete_By__c = UserInfo.getUserId(),
                                                                                    Daily_Acq_Report_Complete_Date__c = Date.today()));                      
                        }
                    }
                }
                
                //Check for the size
                if(listBiddingStatistics.size() > 0) {
                    
                    //Set flag not to execute the trigger again
                    Bidding_StatisticsTriggerHelper.EXECUTE_VALIDATE_NATIONAL_REPORTING_RECORDS = false;
                    update listBiddingStatistics;
                }
            }
        }
    }
}