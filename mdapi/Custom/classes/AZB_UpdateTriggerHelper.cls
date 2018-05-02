/**
 *  Description :   Helper class for Trigger_AZB_Update trigger.
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   12/21/2012
 *
 *  Revision Logs:  V1.0 - Created
 *  Revision Logs:  V1.1 - (10/25/2013) - Shrinath - Made class without sharing
 *
 **/
public without sharing class AZB_UpdateTriggerHelper {

    private static final String PIPELINE_APPROVAL_MESSAGE = 'Unable to update Pipeline record that\'' + 's pending approval';

    private static final String PIPELINE_STAGE_BID_LOST = 'Dead – Bid Lost';
    private static final String AZBUPDTAE_STATUS_BID_LOST = 'Bid Lost';

    public static boolean runAZBTrigger = true;

    private static MAP<String, User> mapAZBUser_User;
    private static MAP<String, User> mapAZBUserEmail_User;


    private static MAP<String, ID> mapAZBState_StateId;

    private static MAP<String, Account> mapAZBTrusteeCompany_Account;
    private static MAP<String, Account> mapAZBBidService_Account;

    private static Set<String> setAZB_APN = new Set<String>();

    private static Map<Integer, String> mapAZBIndex_APNUnique = new Map<Integer, String>();


    private static Set<String> setAccountNameTrusteeCompany = new Set<String>();

    private static Set<String> setAccountNameBidService = new Set<String>();

    private static MAP<String, Id> mapABZAPN_ABZID = new MAP<String, Id>();

    private static MAP<Integer, Boolean> mapAZBNeedsProcessing = new MAP<Integer, Boolean>();

    private static Id prospectRecordTypeId;
    private static Id pipelineRecordTypeId;
    private static Id trustyCompanyAccountRecordTypeId;

    private static Boolean isAZBFieldUpdated(AZB_Update__c azbRecordNew, AZB_Update__c azbRecordOld, String fieldAPIName) {
        if(fieldAPIName.equalsIgnoreCase('APN__c')){
            return (azbRecordNew.APN__c != azbRecordOld.APN__c);
        }
        else {
            return (azbRecordNew.get(fieldAPIName) != azbRecordOld.get(fieldAPIName));
        }
    }

    //validate azb record's updates whether they are to be processed, checks if any critical field change
    public static void validateAZB_Updates(List<AZB_Update__c> listAZBUpdateNew, Map<ID, AZB_Update__c> mapAZBUpdateOld) {

        //prospect fields if they get updated then process AZB Update
        List<String> listProspectFields = new List<String>{ 'APN__c',
                                       'Property_Street__c',
                                       'Property_City__c',
                                       'Property_Zip_Code__c',
                                       'Property_County__c',
                                       'Property_State__c',
                                       'Baths__c',
                                       'Bedrooms__c',
                                       'Lot_Sq_Ft__c',
                                       'Square_Feet__c',
                                       'Year_Built__c',
                                       'AZB_Winning_Bid_Amount__c',
                                       'AZB_IH_Final_Max_Bid__c',
                                       'AZB_IH_Original_Bid_Max__c',
                                       'AZB_Bid_Type__c',
                                       'AZB_Drive_Report_Notes__c',
                                       'AZB_Underwriting_Notes__c',
                                       'AZB_User_Id__c',
                                       'Trustee_Company__c' ,
                                       'Bid_Service__c',
                                       'AZB_Bid_Status__c'};

        //pipeline fields if they get updated then process AZB Update
        List<String> listPipelineFields = new List<String>{
                                       'APN__c',
                                       'Property_Street__c',
                                       'Property_City__c',
                                       'Property_Zip_Code__c',
                                       'Property_County__c',
                                       'Property_State__c',
                                       'Baths__c',
                                       'Bedrooms__c',
                                       'Lot_Sq_Ft__c',
                                       'Square_Feet__c',
                                       'Year_Built__c',
                                       'AZB_User_Id__c',
                                       'AZB_Winning_Bid_Amount__c',
                                       'AZB_IH_Final_Max_Bid__c',
                                       'AZB_IH_Original_Bid_Max__c',
                                       'AZB_Bid_Type__c',
                                       'AZB_Bid_Status__c',
                                       'Bid_Service_Expense__c',
                                       'Bid_Service_Form_of_Payment__c',
                                       'Form_Of_Payment__c',
                                       'Trustee_Company__c' ,
                                       'Bid_Service__c',
                                       'AZB_Underwriting_Notes__c'
                                       };

        //set fields to
        for(AZB_Update__c azb : listAZBUpdateNew){
            if(azb.IH_Needs_Processing__c) {
                azb.IH_Needs_Processing__c = false;
                azb.IH_Last_Result_Message__c = '';
            }
            else {
                azb.IH_Last_Result_Message__c = 'IH Needs Processing flag was unchecked.';
            }
        }

        for(AZB_Update__c azb : listAZBUpdateNew){
            //force run the trigger and process records
            if(azb.IH_Force_Run_Trigger__c) {
                azb.IH_Needs_Processing__c = true;
            }
            else {
                    //if azb update has a pipeline
                    if(azb.IH_Pipeline__c != null) {
                        //loop over fields and check crictical udpates
                        for(String field : listPipelineFields) {
                            if(isAZBFieldUpdated(azb, mapAZBUpdateOld.get(azb.Id), field)) {
                                azb.IH_Needs_Processing__c = true;
                                break;
                            }
                        }
                    }
                    else {
                        //loop over fields and check crictical udpates
                        for(String field : listProspectFields) {
                            if(isAZBFieldUpdated(azb, mapAZBUpdateOld.get(azb.Id), field)) {
                                azb.IH_Needs_Processing__c = true;
                                break;
                            }
                        }
                    }
            }
        }

        //if no updates for process then set message
        for(AZB_Update__c azb : listAZBUpdateNew){
            if( (!azb.IH_Needs_Processing__c) && azb.IH_Last_Result_Message__c == '' ) {
                azb.IH_Last_Result_Message__c = 'No critical updates so did not process.';
            }
        }

    }

    //validate azb record's user record
    public static void validateUserForAZB_Updates(List<AZB_Update__c> listAZBUpdateNew) {
        List<RecordType> rtList = [Select Id, Name, SObjectType
                                   From RecordType where ( Name = 'AZ Bidder' OR Name = 'Trustee Company')
                                   And (SObjectType = 'Prospect__c' OR SObjectType = 'Property_Opportunity__c' OR SObjectType = 'Account')];


        for(RecordType rt : rtList) {

            if(rt.SObjectType.trim().equalsIgnoreCase('Prospect__c')){
                prospectRecordTypeId = rt.Id;
            }
            else if(rt.SObjectType.trim().equalsIgnoreCase('Property_Opportunity__c')){
                pipelineRecordTypeId = rt.Id;
            }
            else {
                trustyCompanyAccountRecordTypeId = rt.Id;
            }
        }


        Set<String> setAZBUserId = new Set<String>();
        Set<String> setAZBUserEmailId = new Set<String>();

        Set<String> setAZBState = new Set<String>();
        setAccountNameTrusteeCompany = new Set<String>();

        Set<ID> setProspectIds = new Set<ID>();
        Set<ID> setPipelineIds = new Set<ID>();

        mapAZBIndex_APNUnique = new Map<Integer, String>();
        Integer azbIndex = 0;

        //prepare sets for userid, state, trustee company, bid service account, apn
        for(AZB_Update__c azb : listAZBUpdateNew){
            if(azb.IH_Needs_Processing__c) {
                if(azb.Region__c.toLowerCase() == Constants.REGION_N_CALIFORNIA.toLowerCase()) {
                   azb.Region__c = Constants.REGION_SACRAMENTO;
                }
                if(azb.AZB_User_ID__c != null) {
                    setAZBUserId.add(azb.AZB_User_ID__c);
                }
                if(azb.Property_State__c != null) {
                    setAZBState.add(azb.Property_State__c);
                }
                if(azb.Trustee_Company__c != null) {
                    setAccountNameTrusteeCompany.add(azb.Trustee_Company__c);
                }

                if(azb.Bid_Service__c != null) {
                    setAccountNameBidService.add(azb.Bid_Service__c);
                }

                String azbUnique = Utility.getApnUnique(azb.AZB_Bid_Type__c, azb.APN__c);
                if(azbUnique != null) {
                    setAZB_APN.add(azbUnique);
                    mapAZBIndex_APNUnique.put(azbIndex, azbUnique);
                }


                if(azb.IH_Prospect__c != null) {
                    setProspectIds.add(azb.IH_Prospect__c);
                }

                if(azb.IH_Pipeline__c != null) {
                    setPipelineIds.add(azb.IH_Pipeline__c);
                }

                if(azb.AZB_User_Email__c != null) {
                    setAZBUserEmailId.add(azb.AZB_User_Email__c);
                }
            }
            azbIndex = azbIndex + 1;
        }

        //Create a field on user for AZB User ID
        mapAZBUser_User = new Map<String, User>();

        mapAZBUserEmail_User = new Map<String, User>();

        if(setAZBUserId.size() > 0 || setAZBUserEmailId.size() > 0) {
            for(User u : [Select Id, AZB_User_Id__c, Email, Region__c From User Where AZB_User_ID__c in : setAZBUserId OR Email in : setAZBUserEmailId]) {
                if(u.AZB_User_Id__c != null) {
                    mapAZBUser_User.put(u.AZB_User_Id__c.toLowercase().trim(), u);
                }
                if(u.Email != null) {
                    mapAZBUserEmail_User.put(u.Email.toLowercase().trim(), u);
                }
            }
        }

        //Create a field on user for AZB User ID
        mapAZBState_StateId = new Map<String, ID>();
        if(setAZBState.size() > 0) {
            for(State__c s : [Select Id, Name From State__c Where Name in : setAZBState]) {
                if(s.Name != null) {
                    mapAZBState_StateId.put(s.Name, s.Id);
                }
            }
        }

        //Create a field on user for AZB User ID
        mapAZBTrusteeCompany_Account = new Map<String, Account>();
        mapAZBBidService_Account = new Map<String, Account>();

        if(setAccountNameTrusteeCompany.size() > 0 || setAccountNameBidService.size() > 0) {
            for(Account a : [Select Id, Name, RecordTypeId From Account Where (Name in : setAccountNameTrusteeCompany OR Name in: setAccountNameBidService)]) {
                if(a.Name != null) {
                    if(a.RecordTypeId == trustyCompanyAccountRecordTypeId){
                        mapAZBTrusteeCompany_Account.put(a.Name, a);
                    }
                    else {
                        mapAZBBidService_Account.put(a.Name, a);
                    }
                }
            }
        }


        MAP<String, Id> mapAPN_ProspectId = new MAP<String, Id>();
        MAP<ID, ID> mapProspectID_PipelineID = new MAP<ID, ID>();

        MAP<Id, Property_Opportunity__c> mapPipelines = new Map<ID, Property_Opportunity__c>(
                                                            [Select Prospect__c, APN__c, Acquisition_Reporting_Date__c
                                                             From Property_Opportunity__c
                                                             Where id in : setPipelineIds OR Prospect__c in : setProspectIds]);

        for(Property_Opportunity__c pipelineObj : mapPipelines.values()) {
            mapProspectID_PipelineID.put(pipelineObj.Prospect__c, pipelineObj.Id);
        }


        azbIndex = 0;
        for(AZB_Update__c azb : listAZBUpdateNew){
            if(azb.IH_Needs_Processing__c) {

                if(azb.IH_Prospect__c != null && mapProspectID_PipelineID.containsKey(azb.IH_Prospect__c)) {
                    azb.IH_Pipeline__c = mapProspectID_PipelineID.get(azb.IH_Prospect__c);
                }


                if( mapAZBUser_User != null
                    && azb.AZB_User_Id__c != null
                    && mapAZBUser_User.containsKey(azb.AZB_User_Id__c.toLowercase().trim())
                    && mapAZBUser_User.get(azb.AZB_User_Id__c.toLowercase().trim()) != null
                    ) {

                        azb.IH_User_Not_Found__c = false;
                        azb.IH_User_ID__c = mapAZBUser_User.get(azb.AZB_User_Id__c.toLowercase().trim()).Id;
                        azb.Region__c = mapAZBUser_User.get(azb.AZB_User_Id__c.toLowercase().trim()).Region__c;
                        mapAZBNeedsProcessing.put(azbIndex, true);
                }
                else if(mapAZBUserEmail_User != null
                    && azb.AZB_User_Email__c != null
                    && mapAZBUserEmail_User.containsKey(azb.AZB_User_Email__c.toLowercase().trim())
                    && mapAZBUserEmail_User.get(azb.AZB_User_Email__c.toLowercase().trim()) != null) {

                        azb.IH_User_Not_Found__c = false;
                        azb.IH_User_ID__c = mapAZBUserEmail_User.get(azb.AZB_User_Email__c.toLowercase().trim()).Id;
                        azb.Region__c = mapAZBUserEmail_User.get(azb.AZB_User_Email__c.toLowercase().trim()).Region__c;
                        mapAZBNeedsProcessing.put(azbIndex, true);
                }
                else {
                        if(azb.IH_Prospect__c == null && azb.IH_Pipeline__c == null && azb.IH_User_Id__c == null) {
                            azb.IH_User_Not_Found__c = true;
                            azb.IH_Last_Result_Message__c = 'AZB User not found';
                            mapAZBNeedsProcessing.put(azbIndex, false);
                        }
                        else {
                            azb.IH_User_Not_Found__c = false;
                            mapAZBNeedsProcessing.put(azbIndex, true);
                        }
                }


                if(mapAZBTrusteeCompany_Account != null
                    && mapAZBTrusteeCompany_Account.containsKey(azb.Trustee_Company__c)
                    && mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c) != null) {
                        azb.IH_Trustee_Company__c = mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c).Id;
                }

                if(mapProspectID_PipelineID.containsKey(azb.IH_Prospect__c)) {
                    azb.IH_Pipeline__c = mapProspectID_PipelineID.get(azb.IH_Prospect__c);
                }

                if(mapPipelines.containsKey(azb.IH_Pipeline__c)
                    && mapPipelines.get(azb.IH_Pipeline__c).Acquisition_Reporting_Date__c != null) {
                    azb.IH_Last_Result_Message__c = PIPELINE_APPROVAL_MESSAGE;
                }
            }
            //End if azb.IH_Needs_Processing__c
            azbIndex = azbIndex + 1;
        }

        //End for loop
    }
	/*
    //validate azb record, checks key field values needed to be processed
    public static void validateAZB_Updates(List<AZB_Update__c> listAZBUpdateNew) {
        validateUserForAZB_Updates(listAZBUpdateNew);
    }
    */

    //populate azb update on prospect or pipelene
    public static void populateAZB_Updates(List<AZB_Update__c> listAZBUpdateNew) {

        for(AZB_Update__c azb : listAZBUpdateNew){
            if(azb.IH_Needs_Processing__c) {
                if(azb.APN__c != null) {
                    mapABZAPN_ABZID.put(azb.APN__c, azb.Id);
                }
            }
        }

        Set<Id> setProspectId = new Set<Id>();
        Set<Id> setPipelineId = new Set<Id>();

        List<Prospect__c>  listProspectToUpdate = new List<Prospect__c>();
        List<Property_Opportunity__c>  listPipelineToUpdate = new List<Property_Opportunity__c>();

        Set<Id> setIdAZBToPopulate_Prospect_Pipeline = new Set<ID>();

        MAP<Integer, AZB_Update__c> mapPipelineIndex_AZB = new MAP<Integer, AZB_Update__c>();
        MAP<Integer, AZB_Update__c> mapProspectIndexIndex_AZB = new MAP<Integer, AZB_Update__c>();


        Integer pipelineIndex = 0;
        Integer prospectIndex = 0;
        Integer azbIndex = 0;

        // loop over AZB updates
        for(AZB_Update__c azb : listAZBUpdateNew){

            //if needs to be processed
            if(azb.IH_Needs_Processing__c) {

                if( mapAZBNeedsProcessing.containsKey(azbIndex)
                    && ( !azb.IH_User_Not_Found__c ) ) {

                    if(azb.IH_Pipeline__c != null && setPipelineId.add(azb.IH_Pipeline__c)) {
                            listPipelineToUpdate.add(populatePipeline(azb,
                                                     azb.IH_Pipeline__c));
                            mapPipelineIndex_AZB.put(pipelineIndex, azb);
                            pipelineIndex = pipelineIndex + 1;
                    }
                    else if (azb.IH_Prospect__c == null || setProspectId.add(azb.IH_Prospect__c)){

                        listProspectToUpdate.add(populateProspect(azb,
                                                 azb.IH_Prospect__c));
                        mapProspectIndexIndex_AZB.put(prospectIndex, azb);
                        prospectIndex = prospectIndex + 1;
                    }

                    if(azb.IH_Pipeline__c == null || azb.IH_Prospect__c == null) {
                        setIdAZBToPopulate_Prospect_Pipeline.add(azb.Id);
                    }
                }
            }
            azbIndex = azbIndex + 1;
        }

        MAP<ID, String> mapIHLastResultLog = new MAP<ID, String>();

        Set<ID> setProspectUpdated = new Set<ID>();

        if(listProspectToUpdate.size() > 0) {
              prospectIndex = 0;

              List<Database.upsertResult> upsertResults = Database.upsert(listProspectToUpdate, false);

              for(Database.upsertResult result : upsertResults) {
                 AZB_Update__c azbObj = mapProspectIndexIndex_AZB.get(prospectIndex);
                 prospectIndex = prospectIndex + 1;
                 if(azbObj != null) {
                     if (result.isSuccess()) {
                          if(azbObj.AZB_Bid_Status__c == AZBUPDTAE_STATUS_BID_LOST) {
                              setProspectUpdated.add(result.getID());
                          }
                          mapIHLastResultLog.put(azbObj.Id, null);
                          if( trigger.isUpdate ) {

                              AZB_Update__c azbRec = ( AZB_Update__c ) trigger.newMap.get( azbObj.Id );
                              azbRec.IH_Prospect__c = result.getID();
                              azbRec.IH_Last_Result_Message__c = null;
                              azbRec.IH_Last_Result_Success__c = azbRec.IH_Last_Result_Message__c == null;
                              azbRec.IH_Needs_Processing__c = false;
                              azbRec.IH_Force_Run_Trigger__c = false;
                          }
                     }
                     else {
                              String errorMessage = result.getErrors().get(0).getMessage();
                              mapIHLastResultLog.put(azbObj.Id, errorMessage);
                              if( trigger.isUpdate ) {
                                 AZB_Update__c azbRec = ( AZB_Update__c ) trigger.newMap.get( azbObj.Id );
                                 azbRec.IH_Last_Result_Message__c = errorMessage;
                                 azbRec.IH_Last_Result_Success__c = azbRec.IH_Last_Result_Message__c == null;
                                 azbRec.IH_Needs_Processing__c = false;
                                 azbRec.IH_Force_Run_Trigger__c = false;
                              }
                     }
                 }
              }
        }


        //update pipeline state for Bid Lost AZB Updates
        List<Property_Opportunity__c> listPipeline;
        if( trigger.isInsert ) {
            listPipeline = [Select Id From Property_Opportunity__c
                            Where Prospect__c in: setProspectUpdated
                            And AZB_Update__r.AZB_Bid_Status__c =: AZBUPDTAE_STATUS_BID_LOST
                            ];
        }
        else {
            listPipeline = [Select Id,
                            Prospect__c,
                            AZB_Update__c,
                            AZB_Update__r.AZB_Bid_Status__c
                            From Property_Opportunity__c
                            Where Prospect__c in: setProspectUpdated
                            OR AZB_Update__c in: trigger.new
                            ];
        }

        Map<Id, Id> mapAZBId_PipelineId = new Map<Id, Id>();
        List<Property_Opportunity__c> otherPipelinesToUpdate = new List<Property_Opportunity__c>();
        for(Property_Opportunity__c p : listPipeline) {

            if( trigger.isInsert ) {
                p.Stage__c = PIPELINE_STAGE_BID_LOST;
                otherPipelinesToUpdate.add( p );
            }
            else if( trigger.isUpdate ) {
                if( setProspectUpdated.contains( p.Prospect__c ) && p.AZB_Update__r.AZB_Bid_Status__c == AZBUPDTAE_STATUS_BID_LOST) {
                    p.Stage__c = PIPELINE_STAGE_BID_LOST;
                    otherPipelinesToUpdate.add( p );
                }
                if( p.AZB_Update__c != null ) {
                    mapAZBId_PipelineId.put( p.AZB_Update__c, p.Id );
                }
            }

        }

        //set pipeline ids if null
        if( trigger.isUpdate ) {
            for( AZB_Update__c azbRec : listAZBUpdateNew ) {
                if( azbRec.IH_Pipeline__c == null && mapAZBId_PipelineId.containsKey(azbRec.Id) ) {
                    azbRec.IH_Pipeline__c = mapAZBId_PipelineId.get(azbRec.Id);
                }
            }
        }

        //update listPipeline;
        listPipelineToUpdate.addAll(otherPipelinesToUpdate);

        if(listPipelineToUpdate.size() > 0) {
              pipelineIndex = 0;

              List<Database.saveResult> saveResults = Database.update(listPipelineToUpdate, false);

              for(Database.saveResult result : saveResults) {
                 AZB_Update__c azbObj = mapPipelineIndex_AZB.get(pipelineIndex);
                 pipelineIndex = pipelineIndex + 1;
                 if(azbObj != null) {
                     if (result.isSuccess()) {
                          mapIHLastResultLog.put(azbObj.Id, null);
                          if( trigger.isUpdate ) {
                             AZB_Update__c azbRec = ( AZB_Update__c ) trigger.newMap.get( azbObj.Id );
                             if( azbRec.IH_Pipeline__c == null ) {
                                azbRec.IH_Pipeline__c = result.getID();
                             }
                             azbRec.IH_Last_Result_Message__c = null;
                             azbRec.IH_Last_Result_Success__c = azbRec.IH_Last_Result_Message__c == null;
                             azbRec.IH_Needs_Processing__c = false;
                             azbRec.IH_Force_Run_Trigger__c = false;
                          }
                     }
                     else {
                          String errorMessage = result.getErrors().get(0).getMessage();
                          mapIHLastResultLog.put(azbObj.Id, errorMessage);
                          if( trigger.isUpdate ) {
                             AZB_Update__c azbRec = ( AZB_Update__c ) trigger.newMap.get( azbObj.Id );
                             azbRec.IH_Last_Result_Message__c = errorMessage;
                             azbRec.IH_Last_Result_Success__c = azbRec.IH_Last_Result_Message__c == null;
                             azbRec.IH_Needs_Processing__c = false;
                             azbRec.IH_Force_Run_Trigger__c = false;
                          }
                     }
                 }
              }

        }

        if( trigger.isInsert ) {
            if( setIdAZBToPopulate_Prospect_Pipeline.size() > 0 || mapIHLastResultLog.size() > 0 ) {
                updateAZBidder(setIdAZBToPopulate_Prospect_Pipeline, setAZB_APN, mapABZAPN_ABZID, mapIHLastResultLog);
            }
        }
    }

    //populate pipeline from azb record
    private static Property_Opportunity__c populatePipeline(AZB_Update__c azb, Id recordId) {
        Property_Opportunity__c pipeline = new Property_Opportunity__c(Id = recordId,
                                            RecordTypeId = pipelineRecordTypeId,
                                            AZB_Update__c = azb.Id,
                                            Bid_Service_Expense__c = azb.Bid_Service_Expense__c,
                                            Bid_Service_Form_of_Payment__c = azb.Bid_Service_Form_of_Payment__c,
                                            Contract_Price__c = (azb.AZB_Winning_Bid_Amount__c != null ? azb.AZB_Winning_Bid_Amount__c : azb.AZB_IH_Final_Max_Bid__c),
                                            Bid_Type__c = azb.AZB_Bid_Type__c,
                                            Trustee_Form_of_Payment__c = azb.Form_Of_Payment__c,
                                            AZB_Drive_Report_Notes__c = azb.AZB_Drive_Report_Notes__c,
                                            AZB_Underwriting_Notes__c = azb.AZB_Underwriting_Notes__c
                                            );


        Boolean cancelPipeline = (azb.AZB_IH_Final_Max_Bid__c != null && azb.AZB_IH_Final_Max_Bid__c == 0 && azb.IH_Pipeline__c != null);

        if(cancelPipeline){
            pipeline.Stage__c = Constants.PIPELINE_STAGE_CANCELLED;
        }

        if(azb.AZB_Bid_Status__c == AZBUPDTAE_STATUS_BID_LOST) {
            pipeline.Stage__c = PIPELINE_STAGE_BID_LOST;
        }

        if(mapAZBUser_User.containsKey(azb.AZB_User_Id__c)) {
            pipeline.Acquisitions_Analyst__c = mapAZBUser_User.get(azb.AZB_User_Id__c).Id;
        }

        if(mapAZBTrusteeCompany_Account.containsKey(azb.Trustee_Company__c)
            && mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c) != null) {
            pipeline.Trustee_Company__c = mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c).Id;
        }

        if(mapAZBBidService_Account.containsKey(azb.Bid_Service__c)
            && mapAZBBidService_Account.get(azb.Bid_Service__c) != null) {
            pipeline.Bid_Service__c = mapAZBBidService_Account.get(azb.Bid_Service__c).Id;
        }


        if(recordId == null) {
            pipeline = pipeline.clone(false);
        }

        return pipeline;
    }

    //populate prospect from azb record
    private static Prospect__c populateProspect(AZB_Update__c azb, Id recordId) {

        Prospect__c prospect = new Prospect__c(Id = recordId,
                                                RecordTypeId = prospectRecordTypeId,
                                                Region__c = azb.Region__c,
                                                AZB_Update__c = azb.Id,
                                                APN__c = (azb.APN__c != null ? (azb.APN__c.trim().equalsIgnoreCase('NOTAVAILABLE') ? null : azb.APN__c) : null ),
                                                Baths__c = azb.Baths__c,
                                                Bedrooms__c = azb.Bedrooms__c,
                                                Lot_Sq_Ft__c = azb.Lot_Sq_Ft__c,
                                                Property_Street__c = azb.Property_Street__c,
                                                Property_City__c = azb.Property_City__c,
                                                Property_Zip_Code__c = azb.Property_Zip_Code__c,
                                                Property_County__c = azb.Property_County__c,
                                                Square_Feet__c = azb.Square_Feet__c,
                                                Year_Built__c = azb.Year_Built__c,
                                                Contract_Price__c = (azb.AZB_Winning_Bid_Amount__c != null ? azb.AZB_Winning_Bid_Amount__c : azb.AZB_IH_Final_Max_Bid__c),
                                                Bid_Type__c = azb.AZB_Bid_Type__c,
                                                AZB_Drive_Report_Notes__c = azb.AZB_Drive_Report_Notes__c,
                                                AZB_Underwriting_Notes__c = azb.AZB_Underwriting_Notes__c
                                                //Address Validation Fields
                                                , Address_Validated_City__c = azb.Address_Validated_City__c,
                                                Address_Validated_County__c = azb.Address_Validated_County__c,
                                                Address_Validated_Last_Attempt__c = azb.Address_Validated_Last_Attempt__c,
                                                Address_Validated_State__c = azb.Address_Validated_State__c,
                                                Address_Validated_Street__c = azb.Address_Validated_Street__c,
                                                Address_Validated_Zip__c = azb.Address_Validated_Zip__c,
                                                Zip_Plus_4__c = azb.ZipPlus4__c,
                                                Geolocation__Latitude__s = aZB.Location__Latitude__s,
                                                Geolocation__Longitude__s = aZB.Location__Longitude__s,
                                                Address_Validation_Message__c = azb.Address_Validation_Message__c,
                                                Address_Validated_Successfully__c = azb.Address_Validated_Successfully__c
                                                );


        if(mapAZBUser_User.containsKey(azb.AZB_User_Id__c)
            && mapAZBUser_User.get(azb.AZB_User_Id__c) != null) {
            prospect.Acquisitions_Analyst__c = mapAZBUser_User.get(azb.AZB_User_Id__c).Id;
        }

        if(mapAZBState_StateId.containsKey(azb.Property_State__c)
            && mapAZBState_StateId.get(azb.Property_State__c) != null) {
            prospect.Property_State__c = mapAZBState_StateId.get(azb.Property_State__c);
        }

        if(mapAZBTrusteeCompany_Account.containsKey(azb.Trustee_Company__c)
            && mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c) != null) {
            prospect.Trustee_Company__c = mapAZBTrusteeCompany_Account.get(azb.Trustee_Company__c).Id;
        }

        if(mapAZBBidService_Account.containsKey(azb.Bid_Service__c)
            && mapAZBBidService_Account.get(azb.Bid_Service__c) != null) {
            prospect.Bid_Service__c = mapAZBBidService_Account.get(azb.Bid_Service__c).Id;
        }

        Boolean createPipeline = (azb.AZB_IH_Original_Bid_Max__c != null && azb.AZB_IH_Original_Bid_Max__c != 0 && azb.IH_Pipeline__c == null);


        if(createPipeline){

            prospect.IsConverted__c = true;
            prospect.B_Status__c = 'Converted to Pipeline';
            prospect.Prospect_Status__c = 'Converted to Pipeline';
            prospect.Date_Converted_to_Pipeline__c = DateTime.now();

        }


        if(recordId == null) {
            prospect = prospect.clone(false);
        }

        return prospect;
    }


    //method to update azb record to populate prospect and pipelene ids
    @future
    public static void updateAZBidder(Set<ID> azbIDs,
                                      Set<String> setAPN,
                                      MAP<String, Id> mapAZBAPN_ID,
                                      MAP<Id, String> mapIHLastresultLogs){


        MAP<ID, AZB_Update__c> mapAZB = new Map<ID, AZB_Update__c>();

        for(Prospect__c prospect : [Select id, AZB_Update__c From Prospect__c Where AZB_Update__c in : azbIDs]) {
            AZB_Update__c azb = mapAZB.containsKey(prospect.AZB_Update__c) ? mapAZB.get(prospect.AZB_Update__c) : new AZB_Update__c(Id = prospect.AZB_Update__c);
            azb.IH_Prospect__c = prospect.Id;
            mapAZB.put(azb.Id, azb);
        }

        for(Property_Opportunity__c pipeline : [Select id, AZB_Update__c, APN__c From Property_Opportunity__c Where AZB_Update__c in : azbIDs]) {

            if(pipeline.AZB_Update__c != null) {
                AZB_Update__c azb = mapAZB.containsKey(pipeline.AZB_Update__c) ? mapAZB.get(pipeline.AZB_Update__c) : new AZB_Update__c(Id = pipeline.AZB_Update__c);
                azb.IH_Pipeline__c = pipeline.Id;
                mapAZB.put(azb.Id, azb);
            }
        }

        MAP<ID, AZB_Update__c> mapAZBToUpdate = new MAP<ID, AZB_Update__c>();
        for(Id azbId : mapIHLastresultLogs.keySet()) {
            AZB_Update__c azb = mapAZB.containsKey(azbId) ? mapAZB.get(azbId) : new AZB_Update__c(Id = azbId);
            azb.IH_Last_Result_Message__c = (mapIHLastresultLogs.containsKey(azb.Id) ? mapIHLastresultLogs.get(azb.Id) : null);
            azb.IH_Last_Result_Success__c = azb.IH_Last_Result_Message__c == null;
            azb.IH_Needs_Processing__c = false;
            azb.IH_Force_Run_Trigger__c = false;
            mapAZBToUpdate.put(azbId, azb);
        }

        AZB_UpdateTriggerHelper.runAZBTrigger = false;

        List<Database.saveResult> saveResults = Database.update(mapAZBToUpdate.values(), false);
    }


    //method to set null values in validate address fields if Smarty Street is On and Address Changed
    public static void validateSmartyStreetStatus(List<AZB_Update__c> listAZBUpdateNew) {
        validateSmartyStreetStatus(listAZBUpdateNew, null);
    }

    //method to set null values in validate address fields if Smarty Street is On and Address Changed
    public static void validateSmartyStreetStatus(List<AZB_Update__c> listAZBUpdateNew, Map<ID, AZB_Update__c> mapAZBUpdateOld) {
        String smartyStreetStatus = IHSmartyStreetsService.getSmartyStreetsStatus();
        Set<String> setAddressFields = new Set<String> {'Property_Street__c',
                                                        'Property_City__c',
                                                        'Property_State__c',
                                                        'Property_Zip_Code__c'
                                                       };

        if(smartyStreetStatus.equalsIgnorecase('On') || smartyStreetStatus.equalsIgnorecase('Off')) {

            //loop over azb updates
            for(AZB_Update__c azbUpdate : listAZBUpdateNew) {
                //loop over address fields
                for(String fieldAPIName : setAddressFields) {

                    if( trigger.isInsert || Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, fieldAPIName) ) {

                        azbUpdate.Address_Validated_City__c = null;
                        azbUpdate.Address_Validated_County__c = null;
                        azbUpdate.Address_Validated_State__c = null;
                        azbUpdate.Address_Validated_Street__c = null;
                        azbUpdate.Address_Validated_Zip__c = null;
                        aZBUpdate.ZipPlus4__c = null;
                        aZBUpdate.Location__Latitude__s =  null;
                        aZBUpdate.Location__Longitude__s =  null;
                        azbUpdate.Address_Validated_Last_Attempt__c = null;
                        azbUpdate.Address_Validated_Successfully__c = false;
                        azbUpdate.Address_Validation_Message__c = null;

                        if(smartyStreetStatus.equalsIgnorecase('On')) {
                            azbUpdate.IH_Needs_Processing__c = false;
                            azbUpdate.IH_Last_Result_Message__c = 'Waiting for address validation before processing.';
                        }//End If

                    }//End If

                }//End For Loop over setAddressFields

                //if Adress Validation attempted Or Address_Validated_Successfully__c changed to true
                if( trigger.isUpdate &&
                      ( azbUpdate.Address_Validated_Last_Attempt__c != null && Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, 'Address_Validated_Last_Attempt__c' ))
                      || ( azbUpdate.Address_Validation_Message__c != null && Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, 'Address_Validation_Message__c' ))
                      || ( Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, 'Address_Validated_Successfully__c' )
                           && azbUpdate.Address_Validated_Successfully__c ) ) {

                            //needs processing as address is validated
                            azbUpdate.IH_Needs_Processing__c = true;

                }//End If

            }//End For Loop over listAZBUpdateNew
        }
        //if smarty stree status  is Sandbox
        else if(smartyStreetStatus.equalsIgnorecase('Sandbox')) {
            //loop over AZB Update list and copy adrress fields
            for(AZB_Update__c azbUpdate : listAZBUpdateNew) {

                azbUpdate.Address_Validated_City__c = azbUpdate.Property_City__c;
                azbUpdate.Address_Validated_County__c = azbUpdate.Property_County__c;
                azbUpdate.Address_Validated_Last_Attempt__c = Datetime.now();
                azbUpdate.Address_Validated_State__c = azbUpdate.Property_State__c;
                azbUpdate.Address_Validated_Street__c = azbUpdate.Property_Street__c;
                azbUpdate.Address_Validated_Successfully__c = true;
                azbUpdate.Address_Validated_Zip__c = azbUpdate.Property_Zip_Code__c;
                azbUpdate.Address_Validation_Message__c = null;
            }
        }
    }

    //method to relink prospect and pipeline if new address is validated
    public static void relinkProspectPipeline(List<AZB_Update__c> listAZBUpdateNew, Map<ID, AZB_Update__c> mapAZBUpdateOld) {

        //get smarty street status
        String smartyStreetStatus = IHSmartyStreetsService.getSmartyStreetsStatus();

        if( smartyStreetStatus.equalsIgnorecase('On') ) {
            List<Residence__c> listResidenceToInserted = new List<Residence__c>();
            Set<String> setAddressFields = new Set<String> {'Property_Street__c',
                                                            'Property_City__c',
                                                            'Property_State__c',
                                                            'Property_Zip_Code__c'
                                                           };

            Map<Id, Integer> mapAZBUpdateID_ResIndex = new Map<Id, Integer>();

            for(AZB_Update__c azbUpdate : listAZBUpdateNew) {
                for(String fieldAPIName : setAddressFields) {

                    //if Address Changed is changed to true
                    if(
                        Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, fieldAPIName)
                      ) {
                            //azbUpdate.IH_Needs_Processing__c = true;
                            Residence__c resNew = createResidence(azbUpdate);
                            //set apn to null if APN is not changed, as there will be another residence with this APN
                            if(!Utility.hasFieldChanged(azbUpdate, mapAZBUpdateOld, 'APN__c')) {
                                resNew.APN__c = null;
                            }
                            listResidenceToInserted.add(resNew);
                            mapAZBUpdateID_ResIndex.put(azbUpdate.Id, (listResidenceToInserted.size() - 1));
                            break;
                    }
                }
            }


            if( listResidenceToInserted.size() > 0 ) {

                //system.assert( false, listResidenceToInserted );
                insert listResidenceToInserted;
            }

            List<Prospect__c> listProspectsToRelink = new List<Prospect__c>();
            List<Property_Opportunity__c> listPipelineToRelink = new List<Property_Opportunity__c>();

            for(AZB_Update__c azbUpdate : listAZBUpdateNew) {
                if(mapAZBUpdateID_ResIndex.containsKey(azbUpdate.Id)) {
                    if(azbUpdate.IH_Prospect__c != null) {
                        listProspectsToRelink.add(new Prospect__c(Id = azbUpdate.IH_Prospect__c,
                                                    Residence__c = listResidenceToInserted.get(mapAZBUpdateID_ResIndex.get(azbUpdate.Id)).Id));
                    }
                    if(azbUpdate.IH_Pipeline__c != null) {
                        listPipelineToRelink.add(new Property_Opportunity__c(Id = azbUpdate.IH_Pipeline__c,
                                                    Residence__c = listResidenceToInserted.get(mapAZBUpdateID_ResIndex.get(azbUpdate.Id)).Id));
                    }
                }
            }

            if( listProspectsToRelink.size() > 0 ) {
                update listProspectsToRelink;
            }

            if( listPipelineToRelink.size() > 0 ) {
                update listPipelineToRelink;
            }
        }
    }

    private static Residence__c createResidence(AZB_Update__c azbUpdate) {
        Residence__c res = new Residence__c(Baths__c = azbUpdate.Baths__c,
                                Bedrooms__c = azbUpdate.Bedrooms__c,
                                Address_Street__c = azbUpdate.Property_Street__c,
                                Address_Zip_Code__c = azbUpdate.Property_Zip_Code__c,
                                Address_City__c = azbUpdate.Property_City__c,
                                APN__c = azbUpdate.APN__c,
                                County__c = azbUpdate.Property_County__c,
                                Square_Feet__c = azbUpdate.Square_Feet__c,
                                Year_Built__c = azbUpdate.Year_Built__c,
                                Region__c = azbUpdate.Region__c,
                                Lot_Sq_Ft__c = azbUpdate.Lot_Sq_Ft__c,
                                //validated address fields
                                Address_Validated_City__c = azbUpdate.Address_Validated_City__c,
                                Address_Validated_County__c = azbUpdate.Address_Validated_County__c,
                                Address_Validated_State__c = azbUpdate.Address_Validated_State__c,
                                Address_Validated_Street__c = azbUpdate.Address_Validated_Street__c,
                                Address_Validated_Zip__c = azbUpdate.Address_Validated_Zip__c,
                                ZipPlus4__c = azbUpdate.ZipPlus4__c,
                                Location__Latitude__s = aZBUpdate.Location__Latitude__s,
                                Location__Longitude__s = aZBUpdate.Location__Longitude__s,
                                Address_Validated_Last_Attempt__c = azbUpdate.Address_Validated_Last_Attempt__c,
                                Address_Validation_Message__c = azbUpdate.Address_Validation_Message__c,
                                Address_Validated_Successfully__c = azbUpdate.Address_Validated_Successfully__c
                                );
        return res;
    }

    //This method is to check if address data has been changed.
    //If any of the address field has been changed to AZB record, nullify all the validated address data
    //and Mark this as Validated_Successfully = false and set Last Attempt Date as Null
    public static void validateAddressChanges(List<AZB_Update__c> aZBUpdates, Map<Id, AZB_Update__c> mapOldAZBUpdates) {

        //Loop through all the new residences and check if address data have been changed in any of the field
        for(AZB_Update__c aZBUpdate : aZBUpdates) {

            //Get the AZB update old instance
            AZB_Update__c oldAZBUpdate = mapOldAZBUpdates.get(aZBUpdate.Id);

            //Compare new residence with old record and check if address data has been changed
            if(aZBUpdate.Property_Street__c != oldAZBUpdate.Property_Street__c
                || aZBUpdate.Property_City__c != oldAZBUpdate.Property_City__c
                || aZBUpdate.Property_State__c != oldAZBUpdate.Property_State__c
                || aZBUpdate.Property_Zip_Code__c != oldAZBUpdate.Property_Zip_Code__c) {

                //Nullify all the validated address fields
                aZBUpdate.Address_Validated_Street__c = null;
                aZBUpdate.Address_Validated_City__c = null;
                aZBUpdate.Address_Validated_State__c = null;
                aZBUpdate.Address_Validated_Zip__c = null;
                aZBUpdate.ZipPlus4__c = null;
                aZBUpdate.Location__Latitude__s =  null;
                aZBUpdate.Location__Longitude__s =  null;
                aZBUpdate.Address_Validated_County__c = null;
                aZBUpdate.Address_Validation_Message__c = null;
                aZBUpdate.Address_Validated_Last_Attempt__c = null;
                aZBUpdate.Address_Validated_Successfully__c = false;
            }
        }
    }

    /**
     * 	@description	:	This method is to check the AZB update record if Win Date has been stamped and record in from Atlanta reging.
     							If yes, then update the residence record with the wining date and mark Atlanta_Auction__c = true
     *
     * 	@args			:	Trigger.New, Trigger.oldMap
     *
     * 	@return			:
     *
     **/
    public static void validateAZBRecordForAtlantaRegion(List<AZB_Update__c> newAZBUpdates, Map<Id, AZB_Update__c> mapOldAZBUpdates) {

    	//Set to hold the residence ids
    	Set<Id> prospectsIds = new Set<Id>();

    	//Loop through the records
    	for(AZB_Update__c aZBUpdate : newAZBUpdates) {

    		//Process record only if it is from Atlanta
    		if(Constants.REGION_ATLANTA.equalsIgnoreCase(aZBUpdate.Region__c) && aZBUpdate.IH_Prospect__c != null && aZBUpdate.AZB_IH_Win_Date__c != null
    			&& aZBUpdate.AZB_IH_Win_Date__c != mapOldAZBUpdates.get(aZBUpdate.Id).AZB_IH_Win_Date__c) {

				//Add in set
				prospectsIds.add(aZBUpdate.IH_Prospect__c);
			}
    	}

    	//Check if there is data to query
    	if(prospectsIds.size() > 0) {

    		//query Prospcts with Reging information
    		Map<Id, Prospect__c> mapProspect = new Map<Id, Prospect__c>([Select Id, Residence__c, Residence__r.Win_Date__c, Residence__r.Atlanta_Auction__c from Prospect__c
    																		where Id IN: prospectsIds AND Residence__c != null]);

    		//Check if there are records to process
    		if(mapProspect.size() > 0) {

    			//Create a list of residences to be updated
    			List<Residence__c> residences = new List<Residence__c>();

    			//Loop through the new AZB Updates
    			for(AZB_Update__c aZBUpdate : newAZBUpdates) {

		    		//Process record only if it is from Atlanta
		    		if(Constants.REGION_ATLANTA.equalsIgnoreCase(aZBUpdate.Region__c) && aZBUpdate.IH_Prospect__c != null
		    			&& aZBUpdate.AZB_IH_Win_Date__c != null
		    			&& aZBUpdate.AZB_IH_Win_Date__c != mapOldAZBUpdates.get(aZBUpdate.Id).AZB_IH_Win_Date__c
		    			&& mapProspect.containsKey(aZBUpdate.IH_Prospect__c)) {

						//Add in the list to be updated
						if(aZBUpdate.AZB_IH_Win_Date__c != mapProspect.get(aZBUpdate.IH_Prospect__c).Residence__r.Win_Date__c || mapProspect.get(aZBUpdate.IH_Prospect__c).Residence__r.Atlanta_Auction__c == false)
							residences.add(new Residence__c(Id = mapProspect.get(aZBUpdate.IH_Prospect__c).Residence__c,
																		Win_Date__c = aZBUpdate.AZB_IH_Win_Date__c,
																		Atlanta_Auction__c = true));
					}
		    	}

		    	//Check if list has records to process
		    	if(residences.size() > 0)
		    		update residences;
    		}
    	}
    }
}