/**
 * Description  :   This class is responsible for the merging two residence records.
 * Copyright    : 	Invitation Homes 2013
 * Created By   :   Rajesh Shah
 * Created Date :   12th March, 2013
 * Revisiion Logs:  V1.0 - Created
 *
**/

public class ResidenceMerge2Controller {

    // Error Handling Variable
    public Boolean invalidRecords {get; private set;}
    // Indicate if the user can switch residences.
    public Boolean noSwitch {get; private set;}

    // Master Record.
    public Residence__c firstResidenceRec   {get; set;}
    // To be merged and deleted record.
    public Residence__c secResidenceRec     {get; set;}

    public ResidenceMerge2Controller(ApexPages.StandardSetController setController) {
        try {
            invalidRecords = false;
            noSwitch = false;
            // If 2 records are not selected, through error.
            if((setController == null || setController.getSelected().size() != 2) && Utility.getPageParameter('IdsToMerge') == null) {
                invalidRecords = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select two Residence record to merge.'));
                return;
            }

            if(setController != null && setController.getSelected().size() == 2) {
	            // Get the residences.
	            List<Residence__c> residences = (List<Residence__c>)setController.getSelected();
	            firstResidenceRec   = getResidenceDetails(residences[0].Id);
	            secResidenceRec     = getResidenceDetails(residences[1].Id);
            }
            else if(Utility.getPageParameter('IdsToMerge') != null) {
            	String IdsToMerge = Utility.getPageParameter('IdsToMerge');
            	String[] ids = IdsToMerge.split(',');
            	if(ids == null || ids.size() != 2) {
            		invalidRecords = true;
                	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select two Residence record to merge.'));
                	return;
            	}
            	firstResidenceRec   = getResidenceDetails(ids[0]);
	            secResidenceRec     = getResidenceDetails(ids[1]);
            }
            // Check if the user belongs to the Asset Manager group.
            if(!userBelongsToAssetManagerGroup()) {
            	// Check if the residences have portfolios associated with them.
            	Boolean res1HasPortfolio = hasPortfolio(firstResidenceRec.Id);
            	Boolean res2HasPortfolio = hasPortfolio(secResidenceRec.Id);

            	// If both the Residences have porfolio associated with them, show error message.
            	if(res1HasPortfolio && res2HasPortfolio) {
            		invalidRecords = true;
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only Asset Managers may merge residences that are already linked with Portfolio records.'));
            	}
            	// If Residence 1 has portfolio and residence 2 has no portfolio, switch shouldn't be allowed.
            	else if(res1HasPortfolio && !res2HasPortfolio)
            		noSwitch = true;
            	// If Residence 2 has portfolio and residence 1 has no portfolio, switch the records and then switch shouldn't be allowed.
            	else if(!res1HasPortfolio && res2HasPortfolio) {
            		switchRecords();
            		noSwitch = true;
            	}
            }

            getAllFieldLabels();
        }
        catch(Exception e) {
            // Show Error on page.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Following exception occurred: ' + e.getMessage()));
        }
    }

    // List of Field Details with which one to retain.
    public List<fieldCompareClass> fieldValues {get; set;}

    // Map of Field Name with the field describe
	private static Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Residence__c.fields.getMap();

    public void getAllFieldLabels() {

    	try {

	    	Map<String, String> fieldLabelNameMap = new Map<String, String>();
	    	for(String fieldName : fieldMap.keySet()) {
	    		Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
	    		if(fieldDescribe.isAccessible()
		                    && fieldDescribe.isUpdateable()
		                    && fieldDescribe.getType() != null
		                    && fieldDescribe.getType() != Schema.DisplayType.LOCATION)
	    			fieldLabelNameMap.put(fieldDescribe.getLabel(), fieldName);
	    	}

	    	// Get all Field Labels and sort alphabetically.
	        List<String> fieldLabels = new List<String>();
	        fieldLabels.addAll(fieldLabelNameMap.keySet());
	        fieldLabels.sort();

	        // Get the Field Names. They will be in the sorted order.
	        List<String> fieldNames = new List<String>();
	        for(String fieldLabel : fieldLabels)
	        	fieldNames.add(fieldLabelNameMap.get(fieldLabel));

	        fieldValues = new List<fieldCompareClass>();
	        for(String fieldName : fieldNames) {
	        	// If the field is not part of To BE Omitted list, add to the compare class.
	        	if(!FIELD_TOBE_OMITTED_FOR_MERGE.contains(fieldName)) {
	        	    // Get Field Details.
	        	    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
	                // Add to the Field values list.
	                fieldValues.add(new fieldCompareClass(fieldName, fieldDescribe.getLabel(), false));
		     	}
	        }
    	}
    	catch(Exception e) {
    		throw e;
    	}
    }

    // Get Residence details.
    public Residence__c getResidenceDetails(Id residenceId) {
    	try {
	    	// Create the Dynamic Query.
	    	String residenceFields = '';
	        for(String fieldName : fieldMap.keySet()) {
	        	Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
	    		if(fieldDescribe.getType() != null && fieldDescribe.getType() != Schema.DisplayType.LOCATION) {
		        	if(residenceFields != '')
		        		residenceFields += ', ';
		        	residenceFields += fieldName;
                }
	        }
	        String residenceQuery = 'Select ' + residenceFields + ' from Residence__c where Id = \'' + residenceId + '\'';
	        List<Residence__c> residenceList = Database.Query(residenceQuery);
	        if(residenceList != null && residenceList.size() > 0)
		        return residenceList[0];
		    return null;
    	}
    	catch(Exception e) {
    		throw e;
    	}
    }

    // Does the residence has portolios associated with it?
    private boolean hasPortfolio(Id residenceId) {
    	List<Property__c> propList = new List<Property__c>();
    	propList = [Select Id from Property__c where Residence__c = :residenceId];
    	if(propList != null && propList.size() > 0)
    		return true;
    	return false;
    }

    // Variable to return all fields those need to be omitted for Residence Merge
    private Static Set<String> FIELD_TOBE_OMITTED_FOR_MERGE {
        get {
            //Create a Set of fields
            Set<String> setField = new Set<String>();

            //Configuration_Manager__c
			List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey('ResidenceMergeOmit');


            //Loop through the Config recoeds
            for(Configuration_Manager__c config : configs) {
                //Check for the parameter value
                if(config.Parameter_Value__c != null)
                    setField.add(config.Parameter_Value__c.toLowerCase());

            }
            return setField;
        }
    }

    // Wrapper Class
    public class fieldCompareClass {
        public String fieldName     {get; set;}
        public String fieldLabel    {get; set;}
        public Boolean secSelected  {get; set;} // If true, use the deleted records value.

        // Constructor
        public fieldCompareClass(String fieldName, String fieldLabel, Boolean secSelected) {
            this.fieldName   = fieldName;
            this.fieldLabel  = fieldLabel;
            this.secSelected = secSelected;
        }
    }

    // Check if the user belongs to the Asset Manager group or not.
    // Asset Manager Group : IT Support, System Administrator, and Invitation Asset Management
    private Boolean userBelongsToAssetManagerGroup() {
    	Set<String> setAllowedProfiles = new Set<String>();

    	//Configuration_Manager__c
		List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey('Portfolio Residence Lock Disabled Profile');

    	//fill set from custom settings
    	for(Configuration_Manager__c config : configs) {

			if(config.Parameter_Value__c != null) {
        		setAllowedProfiles.add(config.Parameter_Value__c.trim().toLowerCase());
			}
        }
    	//get profile name for urrent user
	    String profileName = [Select Name From Profile Where id =: Userinfo.getProfileId()].Name;

    	if(setAllowedProfiles.Contains(profileName.toLowerCase()))
    		return true;
    	return false;
    }

    // Function to switch records (FirstResidenceRec <--> SecondResidenceRec)
    public void switchRecords() {
    	Residence__c temp = firstResidenceRec;
    	firstResidenceRec = secResidenceRec;
    	secResidenceRec	  = temp;
    }

    // Function to merge records.
    public PageReference mergeRecords() {
		// Create a Savepoint before doing any DML operations.
		Savepoint sp = Database.setSavepoint();
		try {
			for(fieldCompareClass field : fieldValues) {
				if(field.secSelected) {
					firstResidenceRec.put(field.fieldName, secResidenceRec.get(field.fieldName));
				}
			}

			// For each childrelationship, find out the child records of second residence and associate with first residence.
			// Child relationships considered are all custom relationship and Notes and Attachments.
			for(Schema.ChildRelationShip childRelationship : Residence__c.SObjectType.getDescribe().getChildRelationships()) {
				// Get the field Name
				Schema.DescribeFieldResult field = childRelationship.getField().getDescribe();
				String fieldName = field.getName();

				// Get the object details.
				Schema.DescribeSObjectResult obj = childRelationship.getChildSObject().getDescribe();
				String objName =  childRelationship.getChildSObject().getDescribe().getName();
				// Use the below code if the object is custom or Notes or Attachment
				if(obj.isCustom() || objName == 'Note' || objName == 'Attachment') {
					// Check if the field is updateable (meaning Lookup relationship).
					// If so, attach the record to the new residence.
					// If no, clone the original object and attach it to the new residence.
					if(field.isUpdateable()) {
						// Create Query
						String query = 'Select Id from ' + objName + ' where ' + fieldName + ' = \'' + secResidenceRec.Id + '\'';
						List<SObject> objRecs = Database.query(query);
						for(SObject rec : objRecs) {
							rec.put(fieldName, firstResidenceRec.Id);
						}
						update objRecs;
					}
					else  {
						// Create query. Query needs to have all fields which are creatable.
						Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
						Map<String, Schema.SObjectField> objFieldMap = gd.get(objName).getDescribe().fields.getMap();

						String query = 'Select Id, ';
						for(String objFieldName : objFieldMap.keySet()) {
				    		Schema.DescribeFieldResult fieldDescribe = objFieldMap.get(objFieldName).getDescribe();
				    		if(fieldDescribe.isAccessible()
					                    && fieldDescribe.isCreateable()
					                    && fieldDescribe.getType() != null)
				    			query += objFieldName + ', ';
			    		}
			    		query = query.subString(0, query.length() - 2);
			    		query += ' from ' + objName + ' where ' + fieldName + ' = \'' + secResidenceRec.Id + '\'';
			    		List<SObject> objRecs = Database.query(query);

						List<Sobject> recToUpdate = new List<SObject>();
						for(SObject rec : objRecs) {
							// Clone the record and associate to the new residence.
							// Clone without the Id
							sObject newRec = rec.clone(false);
							newRec.put(fieldName, firstResidenceRec.Id);
							recToUpdate.add(newRec);
						}
						insert recToUpdate;
					}
				}
			}

			// Delete the Second residence Record.
			delete secResidenceRec;

			// Update the first Residence Record.
			update firstResidenceRec;

			// Redirect User to the First Residence Record page
			PageReference residenceRecPage = new PageReference('/' + firstResidenceRec.Id);
			residenceRecPage.setRedirect(true);
			return residenceRecPage;
		}
		catch(Exception e) {

			// Rollback the DML Operations.
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Following exception occurred: ' + e.getMessage()));
			firstResidenceRec = getResidenceDetails(firstResidenceRec.Id);
			return null;
		}
	}
}