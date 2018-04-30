public with sharing class CompletePipelineRequiredFieldsController {

	// Error Handling Variable
    public Boolean invalidRecord {get; private set;}
    public Property_Opportunity__c pipeline {get; set;}

    public Boolean saveError {get; private set;}

	public CompletePipelineRequiredFieldsController(ApexPages.StandardController ctrl) {
		invalidRecord = false;
		if(ctrl != null) {
			Id pipelineId = ctrl.getId();

			pipeline = (Property_Opportunity__c)Utility.selectStar(pipelineId);
			updateFieldNames();
		}
		else {
			invalidRecord = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Page called from invalid source.'));
		}
	}

	public List<String> nullFieldNames 	{get; private set;}
	public List<String> allFieldNames 	{get; private set;}

	// Map of Field Name with the field describe
	private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Property_Opportunity__c.fields.getMap();

	private void updateFieldNames() {
		try {
			nullFieldNames = new List<String>();
			allFieldNames = new List<String>();

			//Create a set to hold fields name
	        Set<String> reqFields = new Set<String>();
	        Set<String> reqFieldsForTrustee = new Set<String>();
	        Set<String> reqFieldsForNonTrustee = new Set<String>();

	        //Create a list of Configuration_Manager__c
	        List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();
	        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.APPROVAL_REQUIRED_FIELD_FOR_PIPELINE));
	        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.APPROVAL_REQUIRED_FIELD_FOR_TRUSTEE_PIPELINE));
	        configs.addAll(Constants.getConfigManagerByParameterKey(Constants.APPROVAL_REQUIRED_FIELD_FOR_NON_TRUSTEE_PIPELINE));

	        //Get all the required fields from Configuration Manager
	        for(Configuration_Manager__c config : configs) {

	            //Add field in set
	            if(fieldMap.containsKey(config.Parameter_Value__c.toLowerCase())) {
				    //Add in reqFields
				    if(Constants.APPROVAL_REQUIRED_FIELD_FOR_PIPELINE.equalsIgnoreCase(config.Parameter_Key__c))
                    	reqFields.add(config.Parameter_Value__c.toLowerCase());
                    else if(Constants.APPROVAL_REQUIRED_FIELD_FOR_TRUSTEE_PIPELINE.equalsIgnoreCase(config.Parameter_Key__c))
                    	reqFieldsForTrustee.add(config.Parameter_Value__c.toLowerCase());
                	else if(Constants.APPROVAL_REQUIRED_FIELD_FOR_NON_TRUSTEE_PIPELINE.equalsIgnoreCase(config.Parameter_Key__c))
                    	reqFieldsForNonTrustee.add(config.Parameter_Value__c.toLowerCase());
	            }
	        }

	        updateFieldLists(reqFields);
	        // This condition is Bid Type = TRUSTEE
            if(Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(pipeline.Bid_Type__c)) {
            	updateFieldLists(reqFieldsForTrustee);
            }
            // This condition is Bid Type != TRUSTEE
            else if(!Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(pipeline.Bid_Type__c)) {
            	updateFieldLists(reqFieldsForNonTrustee);
            }

            nullFieldNames.sort();
            allFieldNames.sort();
		}
		catch(Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Following exception occurred: ' + e.getMessage()));
		}
	}

	private void updateFieldLists(Set<String> fieldSet) {
		//check for all the fields
	    for(String field : fieldSet) {
	    	Schema.DescribeFieldResult fieldDescribe = fieldMap.get(field).getDescribe();
	    	if(fieldDescribe.isAccessible() && fieldDescribe.isUpdateable()) {
		        allFieldNames.add(field);
		    	//Check for the pipeline data
		        if(pipeline.get(field) == null)
		            nullFieldNames.add(field);
		    }
	    }
	}

	public String pipelineSaveStatus {
		get {
			if(pipelineSaveStatus == null) {
				pipelineSaveStatus = 'SAVE_NOT_CALLED';
			}
			return pipelineSaveStatus;
		}
		private set;
	}

	public void savePipeline() {
		try {
			saveError = false;
			update pipeline;
			pipelineSaveStatus = 'SAVE_SUCCESSFUL';
		}
		catch(Exception e) {
			saveError = true;
			pipelineSaveStatus = 'SAVE_ERROR';
		}
	}

	public Boolean showAllFields {
		get {
			if(showAllFields == null)
				showAllFields = false;
			return showAllFields;
		}
		set;
	}

	public void toggleFieldsToShow() {
		showAllFields = !showAllFields;
	}
}