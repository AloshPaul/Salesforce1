public with sharing class CompleteProspectStarredFieldsController {

	// Error Handling Variable
    public Boolean invalidRecord {get; private set;}
    public Prospect__c prospect {get; set;}

    public Boolean saveError {get; private set;}

	public CompleteProspectStarredFieldsController(ApexPages.StandardController ctrl) {
		invalidRecord = false;
		if(ctrl != null) {
			Id prospectId = ctrl.getId();

			prospect = (Prospect__c)Utility.selectStar(prospectId);
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
	private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Prospect__c.fields.getMap();

	private void updateFieldNames() {
		try {
			nullFieldNames = new List<String>();
			allFieldNames = new List<String>();

			/*for(String fieldName : fieldMap.keySet()) {
	    		Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
	    		if(fieldDescribe.getLabel().contains('*') && fieldDescribe.isAccessible()
	    				&& fieldDescribe.isUpdateable() && fieldDescribe.getType() != null) {
	    			if(prospect.get(fieldDescribe.getName()) == null)
	    				fieldNames.add(fieldDescribe.getName());
	    		}
	    	}*/

	    	//Create a set to hold fields name
	        Set<String> reqFields = new Set<String>();
	        Set<String> reqFieldsForTrustee = new Set<String>();
	        Set<String> reqFieldsForNonTrustee = new Set<String>();
	        Set<String> reqFieldsForNonTrusteeAndNonBulky = new Set<String>();

			//Create a list of Configuaration Manager
			List<Configuration_Manager__c> configs = new List<Configuration_Manager__c>();
			configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION));
			configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_TRUSTEE));
			configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE));
			configs.addAll(Constants.getConfigManagerByParameterKey(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE_AND_NON_BULKY));

			//Get all the required fields from Configuration Manager
	        for(Configuration_Manager__c config : configs) {

	            //Add field in set
	            if(config.Parameter_Value__c != null && fieldMap.containsKey(config.Parameter_Value__c.toLowerCase())) {

	                //Add in reqFields
	                if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION.equalsIgnoreCase(config.Parameter_Key__c))
	                    reqFields.add(config.Parameter_Value__c.toLowerCase());
	                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_TRUSTEE.equalsIgnoreCase(config.Parameter_Key__c))
	                    reqFieldsForTrustee.add(config.Parameter_Value__c.toLowerCase());
	                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE.equalsIgnoreCase(config.Parameter_Key__c))
	                    reqFieldsForNonTrustee.add(config.Parameter_Value__c.toLowerCase());
	                else if(Constants.REQUIRED_FIELD_FOR_PROSPECT_CONVERSION_FOR_NON_TRUSTEE_AND_NON_BULKY.equalsIgnoreCase(config.Parameter_Key__c))
	                    reqFieldsForNonTrusteeAndNonBulky.add(config.Parameter_Value__c.toLowerCase());
	            }
	        }

	        updateFieldLists(reqFields);

            //Check for the Bid Type
            // This condition is Bid Type = TRUSTEE
            if(Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c)) {
            	updateFieldLists(reqFieldsForTrustee);
            }

	        //Check for the Bid Type
	        // This condition is Bid Type != TRUSTEE && Bid Type != BULK SALE
	        if(!Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c) && !Constants.BID_TYPE_BULK_SALE.equalsIgnoreCase(prospect.Bid_Type__c)) {
	        	updateFieldLists(reqFieldsForNonTrusteeAndNonBulky);
	        }

            //Check for the Bid Type
            // THIS condition is Bid Type != TRUSTEE
            if(!Constants.BID_TYPE_TRUSTEE.equalsIgnoreCase(prospect.Bid_Type__c)) {
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
		        if(prospect.get(field) == null)
		            nullFieldNames.add(field);
		    }
	    }
	}

	public String prospectSaveStatus {
		get {
			if(prospectSaveStatus == null) {
				prospectSaveStatus = 'SAVE_NOT_CALLED';
			}
			return prospectSaveStatus;
		}
		private set;
	}

	public void saveProspect() {
		try {
			saveError = false;
			update prospect;
			prospectSaveStatus = 'SAVE_SUCCESSFUL';
		}
		catch(Exception e) {
			saveError = true;
			prospectSaveStatus = 'SAVE_ERROR';
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