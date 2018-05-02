/**
 *   Description  :  This is to create .csv for new records
 *
 *   Created By Shrinath
 *
 *   Created Date:  07/08/2012
 *
 *   Revision Logs:  V1.0 - Created
 *                  v1.1 - Modified By Abhinav Sharma for D-00007335 (Logic added for calling batch from batch)
 *                  v1.2 - Modified by Poonam Bhargava - (05-06-2016) - (D-00015528) - Modified all SOQL by retrieving a field Property__r.Pool__c,Property__r.Property_City__c
 *                  v1.3 - Modified by Poonam Bhargava (12/02/2016) - (D-00016564) - Modified all SOQL by retrieving a field Property__r.Property_State__c
 *                  v1.4 - Modified by Poonam Bhargava - 10/27/2017 - (D-00017506) - Modified all SOQL by retrieving a field Property__r.SWAY__c and add the logic for SWAY market
 **/

global with sharing class BatchGenerateYardiIntegrationCSV implements Database.Batchable<sObject>, Database.Stateful {
    //map containig sheet name as key and content as value
    public MAP<String, String> mapCSVName_Content = new Map<String, String>();

    //list of properties
    public List<Property__c> propertyList = new List<Property__c>();
    public List<Rehab__c> rehabList = new List<Rehab__c>();

    //today's date
    public Date today = Date.today();

    //LatestAcquisition Date
    public Date latestAcquisitionDate;

    public Date acquisitionDate;
    public Date reportingDate;

    public Set<ID> setPropertyIds;

    public String SOQL;

    public Boolean runForAll = false;
    public String updateFailedRecordsAndErrorMessage = '';
    public Boolean batchForAttributes_PropertyStatus = false;
    //Boolean Variable for controlling the recursion of batch calling
    public Boolean EXECUTE_SECOND_BATCH = true;

    //method to run batch
    public static void runJob(Date acquisitionDateVal){

         Integer batchSize = 200;
         BatchGenerateYardiIntegrationCSV batchToGenerateCSV = new BatchGenerateYardiIntegrationCSV();
         batchToGenerateCSV.acquisitionDate = acquisitionDateVal;
         batchToGenerateCSV.SOQL = 'Select Property__r.SWAY__c,Property__r.Property_State__c,Property__r.Pool__c,Property__r.Property_City__c, Property__r.Yardi_Create_Date__c, Country__c, Ext_Ref_Property_Id__c, Ref_Owner_Id__c, Owner__c '+
                                    ', Addr1__c, Addr2__c, Addr3__c, Addr4__c, City__c, State__c, Zipcode__c, Notes__c '+
                                    ', Vat_Recovery_Type__c, Vat_Opted__c, International__c, Contract_Reserve__c ' +
                                    ', Commission_Percent__c, Commission_Min__c, Contract_Exp_Date__c, Residential__c, Is_Estate__c ' +
                                    ', Tax_Status_Changed__c, Status__c, Tax_Recovery_Percentage__c, MLA__c ' +
                                    ', Percent__c, Region_Prefix__c ' +
                                    ', Owner_Code__c, InvestDate__c ' +
                                    ', Record_Type__c, Rent__c, Deposit__c, Sqft__c, FSetAside__c, ContractRent__c, UtilityAllowance__c, RDBasicRent__c ' +
                                    ', Table_Name__c, Field_Name1__c, Field_Value1__c, Field_Name2__c, Field_Value2__c, Field_Name3__c, Field_Value3__c ' +
                                    ', Available_Date__c, Rent_Ready__c, Exclude__c, Unit_Type__c, BedRooms__c, Baths__c, Parking__c ' +
                                    ', Attributes_2__c, Field_Name4__c, Field_Value4__c' +
                                    ', Property__c ' +
                                    ', Rental_Type__c, Property__r.Region__c, Property__r.Acquisition_Date__c, Property__r.Property_Status__c, Property__r.Acquisition_Status__c ' +
                                    ', Property__r.Reporting_Date__c, Property__r.Owner.Name, Property__r.Yardi_Property_Code__c, Property__r.Fund__c, Property__r.Yardi_Rental_Unit_Status_Acquisition__c ' +
                                    'From Yardi_Property__c Where Property__r.Acquisition_Date__c =: acquisitionDate AND Property__r.Acquisition_Status__c != \'Cancelled\'';

         //execute batch
         database.executebatch(batchToGenerateCSV, batchSize);
    }

    //method to run batch
    public static void runJobForProperties(Set<Id> setPropertyIdVals, Date reportingDate){

         Integer batchSize = 200;
         BatchGenerateYardiIntegrationCSV batchToGenerateCSV = new BatchGenerateYardiIntegrationCSV();
         batchToGenerateCSV.setPropertyIds = setPropertyIdVals;
         batchToGenerateCSV.reportingDate = reportingDate;
         batchToGenerateCSV.SOQL = 'Select Property__r.SWAY__c,Property__r.Property_State__c,Property__r.Pool__c,Property__r.Property_City__c, Property__r.Yardi_Create_Date__c, Country__c, Ext_Ref_Property_Id__c, Ref_Owner_Id__c, Owner__c '+
                                    ', Addr1__c, Addr2__c, Addr3__c, Addr4__c, City__c, State__c, Zipcode__c, Notes__c '+
                                    ', Vat_Recovery_Type__c, Vat_Opted__c, International__c, Contract_Reserve__c ' +
                                    ', Commission_Percent__c, Commission_Min__c, Contract_Exp_Date__c, Residential__c, Is_Estate__c ' +
                                    ', Tax_Status_Changed__c, Status__c, Tax_Recovery_Percentage__c, MLA__c ' +
                                    ', Percent__c, Region_Prefix__c ' +
                                    ', Owner_Code__c, InvestDate__c ' +
                                    ', Record_Type__c, Rent__c, Deposit__c, Sqft__c, FSetAside__c, ContractRent__c, UtilityAllowance__c, RDBasicRent__c ' +
                                    ', Table_Name__c, Field_Name1__c, Field_Value1__c, Field_Name2__c, Field_Value2__c, Field_Name3__c, Field_Value3__c ' +
                                    ', Available_Date__c, Rent_Ready__c, Exclude__c, Unit_Type__c, BedRooms__c,  Baths__c, Parking__c ' +
                                    ', Attributes_2__c, Field_Name4__c, Field_Value4__c' +
                                    ', Property__c ' +
                                    ', Rental_Type__c, Property__r.Region__c, Property__r.Acquisition_Date__c, Property__r.Property_Status__c, Property__r.Acquisition_Status__c ' +
                                    ', Property__r.Reporting_Date__c, Property__r.Owner.Name, Property__r.Yardi_Property_Code__c, Property__r.Fund__c ' +
                                    ', Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.RecordType.DeveloperName ' +
                                    ', Rehab_Yardi_Integration__c ' +
                                    ', Rehab_Re_Key_Date__c ' +
                                    ', Rehab_Office_Signoff_Date__c ' +
                                    ', Property__r.Residence__r.Most_Recent_Rehab__c ' +
                                    ', Property__r.Yardi_Rental_Unit_Status_Acquisition__c ' +
                                    'From Yardi_Property__c Where (Property__c in: setPropertyIds OR ((Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.RecordType.DeveloperName = \'Post_Acquisition\' OR Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.RecordType.DeveloperName = \'Post_Acquisition_TIP\') AND Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.Yardi_Integration__c = true AND Property__r.Reporting_Date__c <=: reportingDate)) AND Property__r.Acquisition_Status__c != \'Cancelled\'';

         //execute batch
         database.executebatch(batchToGenerateCSV, batchSize);
    }

    //method to run batch
    public static void runJob(){
         Integer batchSize = 200;
         BatchGenerateYardiIntegrationCSV batchToGenerateCSV = new BatchGenerateYardiIntegrationCSV();

         //execute batch
         database.executebatch(batchToGenerateCSV, batchSize);
    }

    // method to run batch for all Property records - Added by Rajesh - 1/29/2013
    public static void runJobForPropertiesByRegions(String[] regions, Date reportingDate) {
        Integer batchSize = 200;
        BatchGenerateYardiIntegrationCSV batchToGenerateCSV = new BatchGenerateYardiIntegrationCSV();
        batchToGenerateCSV.runForAll = true;
        batchToGenerateCSV.batchForAttributes_PropertyStatus = true;
        batchToGenerateCSV.EXECUTE_SECOND_BATCH = false;
        batchToGenerateCSV.reportingDate = reportingDate;
        batchToGenerateCSV.SOQL = 'Select Property__r.SWAY__c,Property__r.Property_State__c,Property__r.Pool__c,Property__r.Property_City__c, Property__r.Yardi_Create_Date__c, Country__c, Ext_Ref_Property_Id__c, Ref_Owner_Id__c, Owner__c '+
                                    ', Addr1__c, Addr2__c, Addr3__c, Addr4__c, City__c, State__c, Zipcode__c, Notes__c '+
                                    ', Vat_Recovery_Type__c, Vat_Opted__c, International__c, Contract_Reserve__c ' +
                                    ', Commission_Percent__c, Commission_Min__c, Contract_Exp_Date__c, Residential__c, Is_Estate__c ' +
                                    ', Tax_Status_Changed__c, Status__c, Tax_Recovery_Percentage__c, MLA__c ' +
                                    ', Percent__c, Region_Prefix__c ' +
                                    ', Owner_Code__c, InvestDate__c ' +
                                    ', Record_Type__c, Rent__c, Deposit__c, Sqft__c, FSetAside__c, ContractRent__c, UtilityAllowance__c, RDBasicRent__c ' +
                                    ', Table_Name__c, Field_Name1__c, Field_Value1__c, Field_Name2__c, Field_Value2__c, Field_Name3__c, Field_Value3__c ' +
                                    ', Available_Date__c, Rent_Ready__c, Exclude__c, Unit_Type__c, BedRooms__c,  Baths__c, Parking__c ' +
                                    ', Attributes_2__c, Field_Name4__c, Field_Value4__c' +
                                    ', Property__c ' +
                                    ', Rental_Type__c, Property__r.Region__c, Property__r.Acquisition_Date__c, Property__r.Property_Status__c, Property__r.Acquisition_Status__c ' +
                                    ', Property__r.Reporting_Date__c, Property__r.Yardi_Property_Code__c, Property__r.Owner.Name, Property__r.Fund__c, Property__r.Yardi_Rental_Unit_Status_Acquisition__c ' +
                                    '  From Yardi_Property__c ' +
                                    ' Where Property__r.Yardi_Attributes_PropertyStatus__c = True AND Property__r.Reporting_Date__c <=: reportingDate';

        if(regions != null && regions.size() > 0) {
            batchToGenerateCSV.SOQL += ' where';
            Boolean start = true;
            for(String region : regions) {
                if(!start)
                    batchToGenerateCSV.SOQL += ' or';
                batchToGenerateCSV.SOQL += ' Property__r.Yardi_Property_Code__c like \'' + region + '%\'';
                start = false;
            }
        }
        //execute batch
        database.executebatch(batchToGenerateCSV, batchSize);

    }

    //get records to be processed by batch
    global Database.QueryLocator start(Database.BatchableContext BC){


        if(SOQL == null ||  SOQL.trim().length() == 0) {
            SOQL = 'Select Property__r.SWAY__c,Property__r.Property_State__c,Property__r.Pool__c,Property__r.Property_City__c, Property__r.Yardi_Create_Date__c, Country__c, Ext_Ref_Property_Id__c, Ref_Owner_Id__c, Owner__c '+
                        ', Addr1__c, Addr2__c, Addr3__c, Addr4__c, City__c, State__c, Zipcode__c, Notes__c '+
                        ', Vat_Recovery_Type__c, Vat_Opted__c, International__c, Contract_Reserve__c ' +
                        ', Commission_Percent__c, Commission_Min__c, Contract_Exp_Date__c, Residential__c, Is_Estate__c ' +
                        ', Tax_Status_Changed__c, Status__c, Tax_Recovery_Percentage__c, MLA__c ' +
                        ', Percent__c, Region_Prefix__c ' +
                        ', Owner_Code__c, InvestDate__c ' +
                        ', Record_Type__c, Rent__c, Deposit__c, Sqft__c, FSetAside__c, ContractRent__c, UtilityAllowance__c, RDBasicRent__c ' +
                        ', Table_Name__c, Field_Name1__c, Field_Value1__c, Field_Name2__c, Field_Value2__c, Field_Name3__c, Field_Value3__c ' +
                        ', Available_Date__c, Rent_Ready__c, Exclude__c, Unit_Type__c, BedRooms__c, Baths__c, Parking__c ' +
                        ', Attributes_2__c, Field_Name4__c, Field_Value4__c ' +
                        ', Property__c ' +
                        ', Rental_Type__c, Property__r.Region__c, Property__r.Acquisition_Date__c, Property__r.Property_Status__c, Property__r.Acquisition_Status__c ' +
                        ', Property__r.Reporting_Date__c, Property__r.Owner.Name, Property__r.Yardi_Property_Code__c, Property__r.Fund__c, Property__r.Yardi_Rental_Unit_Status_Acquisition__c ' +
                        'From Yardi_Property__c Where Property__r.Yardi_Integration__c = True AND Property__r.Acquisition_Status__c != \'Cancelled\'';
        }

        if(Test.isRunningTest()) {
            SOQL = SOQL + ' Order BY CreatedDate Desc Limit 1';
        }
        
        return Database.getQueryLocator(SOQL);
    }

    //execute batch to generate csv content
    global void execute(Database.BatchableContext BC, List<Yardi_Property__c> scope){
        
        System.debug('scope:::::' + scope);
        
        Set<String> setRegions = new Set<String>();
        //loop over records to generate row content
        for(Yardi_Property__c p : scope){
            setRegions.add(p.Property__r.Region__c);
            
            //calculate latest AcquisitionDate
            if(latestAcquisitionDate == null || latestAcquisitionDate < p.Property__r.Acquisition_Date__c)
                latestAcquisitionDate =  p.Property__r.Acquisition_Date__c;
        }
        System.debug('setRegions:::::' + setRegions);

        YardiIntegrationNewProperty.setMapRegionBankAccountCode(setRegions);
        
        List<Yardi_Property__c> listYardiPropertyTemp = new List<Yardi_Property__c>();
        MAP<String, List<Region_Configuration__c>> mapRegionBankAccutntCode = YardiIntegrationNewProperty.mapRegionBankAccountCode;
        
        System.debug('mapRegionBankAccutntCode:::::' + mapRegionBankAccutntCode);
        
        //List of Yardi Rehab properties
        List<Yardi_Property__c> listOfYardiRehabProperties = new List<Yardi_Property__c>();
        
        //List of Sway Properties
        List<Yardi_Property__c> listSWAYYardiProperty = new List<Yardi_Property__c>();

        for(Yardi_Property__c yp : scope) {
          
            if(yp.Property__r.Region__c != null && mapRegionBankAccutntCode.containsKey(yp.Property__r.Region__c.trim().toLowerCase())
                && mapRegionBankAccutntCode.get(yp.Property__r.Region__c.trim().toLowerCase()) != null
                && mapRegionBankAccutntCode.get(yp.Property__r.Region__c.trim().toLowerCase()).size() > 0) {
                
                if(runForAll) {
                    listYardiPropertyTemp.add(yp);
                }   
                    
                else {

                    //Check if the Yardi propetry record is for rehab
                    if(setPropertyIds.contains(yp.Property__c)) {
                        
                        if(yp.Property__r.SWAY__c)
                            listSWAYYardiProperty.add(yp);  
                        else
                            listYardiPropertyTemp.add(yp);
                        
                        //Additionally check if re-Key ready or Sign-Off date was changed on this record
                        if(((yp.Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.RecordType.DeveloperName == 'Post_Acquisition'
                          || yp.Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__r.RecordType.DeveloperName == 'Post_Acquisition_TIP')
                            && yp.Rehab_Yardi_Integration__c == true
                            )) {

                            //Add in Rehab list
                            listOfYardiRehabProperties.add(yp);
                        }
                    } else {

                        //Add in Rehab list
                        listOfYardiRehabProperties.add(yp);
                    }
                }
            }
        }
    
        if(listYardiPropertyTemp.size() > 0 || listSWAYYardiProperty.size() > 0) {
        	
            if(runForAll)
                mapCSVName_Content = YardiIntegrationNewProperty.generateCSVFilesForAll(listYardiPropertyTemp, mapCSVName_Content);
            else {

                mapCSVName_Content = YardiIntegrationNewProperty.generateCSVFiles(listYardiPropertyTemp, listSWAYYardiProperty, mapCSVName_Content);
                mapCSVName_Content = YardiIntegrationNewProperty.generateRehabOneToManyCSV(listOfYardiRehabProperties, mapCSVName_Content);
            }
            
            List<Yardi_Property__c> tempList = new List<Yardi_Property__c>();
            tempList.addAll(listYardiPropertyTemp);
            tempList.addAll(listSWAYYardiProperty);
            
            System.debug('tempList:::::' + tempList);
            
            //loop over the records to set Yardi Integration flsg to false
            for(Yardi_Property__c p : tempList){
                Property__c portfoliToUpdate = new Property__c(Id = p.Property__c, Yardi_Integration__c = false,
                                    Yardi_Create_Date__c = (p.Property__r.Yardi_Create_Date__c == null ? today : p.Property__r.Yardi_Create_Date__c));

                if( batchForAttributes_PropertyStatus ) {
                    portfoliToUpdate.Yardi_Attributes_PropertyStatus__c = false;
                }
                propertyList.add( portfoliToUpdate );
            }

            updateProperties();
            propertyList.clear();

        }
        
        if(listOfYardiRehabProperties.size() > 0) {

            rehabList = new List<Rehab__c>();

            //loop over the records to set Yardi Integration flsg to false
            for(Yardi_Property__c yp : listOfYardiRehabProperties){
                rehabList.add(new Rehab__c(Id = yp.Property__r.Residence__r.Most_Recent_Post_Acq_Rehab__c, Yardi_Integration__c = false));
            }

            //Update rehabs
            updateRehab();
        }
    }

    //finish method for batch to generate csv documents
    global void finish(Database.BatchableContext BC){

        //Create a save point
        SavePoint sp = database.setSavePoint();
        try {

            if(mapCSVName_Content.size() > 0) {
                //Get yardi integration folder
                Folder folder = [Select Id From Folder where Name =: YardiIntegrationNewProperty.YARDI_INTEGRATION_NEW_RECORD_FOLDER_NAME];
                List<Document> listDocument = new List<Document>();
                
                //loop over map of csv name and content pair
                for(String keyStr : mapCSVName_Content.keyset()) {
                    //assign content to blob
                    Blob b = Blob.valueOf(mapCSVName_Content.get(keyStr));
                    //new document with csv content
                    Document document = new Document(Body = b, name = keyStr + '_' + String.valueOf(reportingDate) + '.csv',
                                        FolderId = folder.Id, description = YardiIntegrationNewProperty.DESCRIPTION_NEW_RECORD);
                    listDocument.add(document);
                }
                //insert document
                insert listDocument;
                //update properties

                if(!propertyList.isEmpty())
                    updateProperties();
                    sendEmail(listDocument);
                    sendErrorEmail();
                }

            //Check for Boolean variable
            if(EXECUTE_SECOND_BATCH) {
               //Start the next batch by kicking off a scheduled job
               //Build the system time of now + 5 minutes to schedule the batch apex.
               Datetime sysTime = System.now();
               sysTime = sysTime.addMinutes(1);
               String CRON_EXP = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
               ScheduleGenerateYardiIntegrationMainCSV sched = new ScheduleGenerateYardiIntegrationMainCSV();
               sched.reportingDate = reportingDate;

               //Schedule the next job, and give it the system time so name is unique
               System.schedule('ScheduleGenerateYardiIntegrationMainCSV' + sysTime.getTime(), CRON_EXP, sched);
             }
        }
        catch(Exception e) {
            //rollback transaction
            database.rollback(sp);
            throw e;
        }
    }

    private void updateProperties() {
        if(propertyList != null && propertyList.size() > 0) {
            // No need for Trigger executing when the properties are updated.
            PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = false;
            Database.Saveresult[] saveResults = Database.update(propertyList, false);
            // Iterate through the Save Results
            for(Database.SaveResult sr : saveResults) {
                if(!sr.isSuccess()) {
                    updateFailedRecordsAndErrorMessage += sr.getId() + ' - ';
                    updateFailedRecordsAndErrorMessage += sr.getErrors()[0].getMessage() + '\n';
                }
            }
            if(updateFailedRecordsAndErrorMessage != null && updateFailedRecordsAndErrorMessage != '') {
                updateFailedRecordsAndErrorMessage = 'Update failed for following property records: \n' + updateFailedRecordsAndErrorMessage;
            }
        }
    }

    private void updateRehab() {
        if(rehabList != null && rehabList.size() > 0) {

            // No need for Trigger executing when the properties are updated.
            PropertyTriggerHelper.EXECUTE_PROPERTY_TRIGGER = false;
            Database.Saveresult[] saveResults = Database.update(rehabList, false);

            // Iterate through the Save Results
            for(Database.SaveResult sr : saveResults) {
                if(!sr.isSuccess()) {
                    updateFailedRecordsAndErrorMessage += sr.getId() + ' - ';
                    updateFailedRecordsAndErrorMessage += sr.getErrors()[0].getMessage() + '\n';
                }
            }
            if(updateFailedRecordsAndErrorMessage != null && updateFailedRecordsAndErrorMessage != '') {
                updateFailedRecordsAndErrorMessage = 'Update failed for following rehab records: \n' + updateFailedRecordsAndErrorMessage;
            }
        }
    }

    //method to send email with csv as attachement
    private void sendEmail(List<Document> listDocument) {

         //list of attachments
         List<Messaging.EmailFileAttachment> listMEFA = new List<Messaging.EmailFileAttachment>();

         //loop over dcuments to be attached with mail
         for(Document d : listDocument){
            Blob body = d.body;
            //Sets up the new attachment, invents a filename
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(d.Name);
            efa.setBody(body );
            //add to list
            listMEFA.add(efa);

         }

         //SingleEmailMessage instance
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

         //if has attachment then only send mail
         if(listMEFA.size() > 0){
             YardiIntegrationNewProperty.setYardiIntgrationEmailParams();
             //get from configuration
             Id contactId = YardiIntegrationNewProperty.YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID;
             Id templateID = YardiIntegrationNewProperty.YARDI_INTGRATION_EMAIL_TEMPLATE_ID;

             mail.setFileAttachments(listMEFA);

             mail.setTemplateId(templateID);
             mail.settargetobjectid(Id.valueOf(contactId));
             //get list of email address to be in CC
             List<String> ccAddresses = YardiIntegrationNewProperty.listYardiIntegrationCCEmailAddresses;

             if(ccAddresses != null && ccAddresses.size() > 0)
                mail.setCcAddresses(ccAddresses);

             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
    }

    public void sendErrorEmail() {
        if(updateFailedRecordsAndErrorMessage != null && updateFailedRecordsAndErrorMessage != '') {
            //SingleEmailMessage instance
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            YardiIntegrationNewProperty.setYardiIntgrationEmailParams();
            //get from configuration
            Id contactId = YardiIntegrationNewProperty.YARDI_INTGRATION_EMAIL_RECEIVER_CONTACT_ID;
            mail.settargetobjectid(Id.valueOf(contactId));
            //get list of email address to be in CC
            List<String> ccAddresses = YardiIntegrationNewProperty.listYardiIntegrationCCEmailAddresses;

            mail.setSubject('Yardi File Generation - Error Records');
            mail.setPlainTextBody(updateFailedRecordsAndErrorMessage);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}