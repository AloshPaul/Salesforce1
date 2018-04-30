/**
 *  Description :   This trigger is responsible for all the pre and post processing for Property Opportunity records.
 *
 *  Created By  :   Abhinav Sharma
 *
 *  Created Date:   10/27/2012
 *
 *  Revision Logs:  V1.0 - Created
 *                  V1.1 - added a new method to validate the dates by Vrajesh Sheth on 09/12/2012
 *                  V1.2 - (01/03/2013) - Bhavi - Do not execute the triggers if not required - D-00001585
 *                  V1.3 - (02/02/2013) - Bhavi - Call helper class method to create feed Items
 *                  V1.3 - (02/02/2013) - Bhavi Sharmna - Commented sharePipelineWithProspectOwner methos callout.
                                            As we are going to share Pipeline record with the Prospect role with "Edit", This method is no more requied
                                            Added call to sharePipelineWithCoworkers - D-00006512
 *                  V1.4 - (09/02/2016) - Modified by Poonam Bhargava - D-00016126
 *
 **/

trigger Trigger_Property_Opportunity on Property_Opportunity__c (before update, after update, after insert, before insert, after delete) {

    try {

        //Execute the trigger only if required
        if(Constants.EXECUTE_TRIGGER == false
            || Property_OpportunityTriggerHelper.EXECUTE_PIPELINE_TRIGGER == false)
            return;

        //Check for the request type
        if(Trigger.isBefore) {

            if(Trigger.isInsert) {
                // Populate Pipeline Address Street from Residence
                Property_OpportunityTriggerHelper.updatePipelineAddressFromResidence(trigger.new);

                //set defaults on azb pipeline
                Property_OpportunityTriggerHelper.setAZBPipelineDefultsFields(Trigger.New);
            }

            //Check for the event type
            if(Trigger.isUpdate) {

                //Call Helper Class Method
                Property_OpportunityTriggerHelper.setIsCovertedFlag(Trigger.new, Trigger.old);
                Property_OpportunityTriggerHelper.attachPipelinesWithBiddingStat(Trigger.New);
            }
            if(Trigger.isInsert || Trigger.isUpdate){
                // Update M1 Margin Expense EST UW from Region
                //Property_OpportunityTriggerHelper.updatePipelineExpenseMarginFromRegion(trigger.new, trigger.oldMap, trigger.isUpdate);

                //Validate the dates
                Property_OpportunityTriggerHelper.validateAllDateField(Trigger.new);

                //Populate field
                Property_OpportunityTriggerHelper.setPipelineFields(Trigger.new);
                
                //Added By Poonam Bhargava - D-00017166
                //Call the utility class method to populate Market field
                Utility.populateMarketFromRegion(Trigger.New, Label.Market2_AS_SOURCE, Label.Market_AS_TARGET);
            }
        }

         //Check for the request type
        if(Trigger.isAfter) {

            if(Trigger.isInsert) {

                //Call helper class method to create teh Feed Items
                Property_OpportunityTriggerHelper.createFeedItemForChatterGroup(Trigger.newMap, Trigger.oldMap);

                //Calling Helper Class Method to create Box Folder
                Property_OpportunityTriggerHelper.createBoxProspectFolder(Trigger.New, Trigger.NewMap);

                Property_OpportunityTriggerHelper.refreshResidence(Trigger.New);

                //Call helper class method for updating pipeline field on EMD/COE Request record
                Property_OpportunityTriggerHelper.updateEMDCOERequestPipelineFieldOnPipelineInsert(Trigger.new);

                //Property_OpportunityTriggerHelper.sharePipelineWithProspectOwner(trigger.new);
                Property_OpportunityTriggerHelper.sharePipelineWithCoworkers(Trigger.New);
                
                //update HD Budget Walk 
                Property_OpportunityTriggerHelper.updateHDBudgetWalk( Trigger.New );
            }

            if(Trigger.isInsert || Trigger.isDelete) {

                //Calling Helper Class Method
                Property_OpportunityTriggerHelper.totalNoOfHomesWon(Trigger.New, Trigger.Old);
            }

            //Check for the event type
            if(Trigger.isUpdate) {

                //Call helper class method to create teh Feed Items
                Property_OpportunityTriggerHelper.createFeedItemForChatterGroup(Trigger.newMap, Trigger.oldMap);

                //Calling Helper Class Method
                if(Property_OpportunityTriggerHelper.EXECUTE_TOTAL_NO_OF_HOMES_WON == true)
                    Property_OpportunityTriggerHelper.totalNoOfHomesWon(Trigger.New, Trigger.Old);

                //Call Helper Class Method
                if(Property_OpportunityTriggerHelper.EXECUTE_PROPERTY_OPPORTUNITY_TO_PROPERTY_CONVERSION == true)
                    Property_OpportunityTriggerHelper.propertyOpportunityToPropertyConversion(Trigger.new, Trigger.old);
            }
        }
    } catch(DMLException e) {

        //Prepare a user friedly error message
        String failedRecordId = e.getDmlId(0);

        //Failue fields
        List<Schema.SObjectField> failureFields = e.getDmlfields(0);
        String failureMessage = e.getDmlMessage(0);

        String errorMessage = '';
        if(failedRecordId != null && failedRecordId != '')
            errorMessage += 'Operation failed for ' + Label.SERVER_URL + failedRecordId + '. ';  //Modified by Poonam Bhargava (09/02/2016) - D-00016126
        if(failureFields != null && failureFields.size() > 0) {

            errorMessage += failureFields[0].getDescribe().getLabel() + ': ';
        }
        if(failureMessage != null && failureMessage != '')
            errorMessage += failureMessage;

        //Add error
        Trigger.New[0].addError(errorMessage);
    } catch(Exception e) {

        //Add Error Message on Page
        Trigger.New[0].addError(e.getMessage());
    }
}