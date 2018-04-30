public with sharing class PortfolioCloneController {

	// Parent Residence Reference
	public Residence__c ParentResidence {get; set;}
	// Current Residence
	public Residence__c currResidence {get; set;}
	// Child Residences
	public Residence__c[] childResidences {get; set;}
	// Portfolio Record
	public Property__c portfolio {get; set;}

	// Boolean value to check if the Portfolio has a Parent Residence or not.
	public Boolean hasParentResidence {get; set;}

	// Set to true if the page is called without residence id or from a child Residence
	public Boolean invalidRecord {get; set;}

	// Constructor
	public PortfolioCloneController(ApexPages.StandardController stdController) {
		try {
			invalidRecord = false;
			hasParentResidence = false;
			childResidences = new List<Residence__c>();

			// Check if the user belongs to the Asset manager group
			if(!Utility.userBelongsToAssetManagerGroup()) {
				invalidRecord = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have permissions to clone the portfolio.'));
				return;
			}

			// Throw error if no parameter is passed.
			if(stdController == null || stdController.getId() == null) {
				invalidRecord = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Portfolio record passed to the page.'));
				return;
			}

			// Get the portfolio details
			portfolio = (Property__c)Utility.selectStar(stdController.getId());

			// If the portfolio has no residence, throw error
			if(portfolio.Residence__c == null) {
				invalidRecord = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Residence record associated with the Portfolio.'));
				return;
			}

			// Get the residence details
			parentResidence = (Residence__c)Utility.selectStar(portfolio.Residence__c);
			// Add Address unit to the unique Address units
			uniqueUnits.add(parentResidence.Address_Unit__c);

			// if the Residence is a child Unit, create a clone of it.
			if(parentResidence.Child_Unit__c && parentResidence.Parent_Residence__c != null) {
				currResidence = parentResidence.clone(false);

				// Nullify fields to ignore
				for(String field : fieldsToIgnore) {
					currResidence.put(field, null);
				}

				// Get the Parent Residence details
				parentResidence = (Residence__c)Utility.selectStar(currResidence.Parent_Residence__c);
				// Get the Child Residences
				for(Residence__c res : [Select Name, Bedrooms__c, Baths__c, Square_Feet__c, Address_Unit__c, Parking__c, AC_or_Evap__c,
													Current_Portfolio__c, Current_Portfolio__r.Property_Code__c
													from Residence__c
													where Parent_Residence__c = :parentResidence.Id
													and   Child_Unit__c = true]) {
					childResidences.add(res);
					uniqueUnits.add(res.Address_Unit__c);
				}

				hasParentResidence = true;
			}
			else {
				// This means that the Portfolio doesnt has a parent residence.
				currResidence = parentResidence.clone(false);

				// Nullify fields to ignore
				for(String field : fieldsToIgnore) {
					parentResidence.put(field, null);
				}
			}
		}
		catch(Exception e) {
			invalidRecord = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Following exception occurred on the page. ' + e.getMessage()));
		}
	}

	// Set to hold all the unique units
	private Set<String> uniqueUnits = new Set<String>();	// String to store the existing the Units.

	// Function to clone the portfolio
	public PageReference clonePortfolio() {
		// Create a savepoint
		Savepoint sp = Database.setSavepoint();
		try {
			if(currResidence != null) {
				// Check if the Address Unit is a duplicate.
				if(currResidence.Address_Unit__c == null || currResidence.Address_Unit__c == '' || uniqueUnits.contains(currResidence.Address_Unit__c)) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Address Unit is required and must be unique.'));
					return null;
				}
			}

			PageReference pg;

			if(hasParentResidence) {
				// If there is a parent residence,
				// Insert the new Residence, clone the portfolio and associate it with the new residence.

				currResidence.Parent_Residence__c = parentResidence.Id;
				currResidence.Child_Unit__c = true;
				currResidence.Parent_Structure__c = false;

				insert currResidence;

				Property__c newProp = (Property__c)portfolio.clone(false);
				newProp.Residence__c = currResidence.Id;
				newProp.Property_Code__c = PropertyTriggerHelper.getPropertyCode(newProp);

				insert newProp;

				pg = new PageReference('/apex/PortfolioClone?id=' + newProp.Id);
			}
			else {
				// If parent residence is not present
				// Update the parent residence with the Parent structure as true
				// and insert the new child residence. Link the Portfolio to this new residence.

				parentResidence.Parent_Structure__c = true;
				parentResidence.Child_Unit__c = false;
				update parentResidence;

				currResidence.Child_Unit__c = true;
				currResidence.Parent_Structure__c = false;
				currResidence.Parent_Residence__c = parentResidence.Id;
				insert currResidence;

				portfolio.Residence__c = currResidence.Id;
				update portfolio;

				pg = new PageReference('/apex/PortfolioClone?id=' + portfolio.Id);
			}

			pg.setRedirect(true);
			return pg;
		}
		catch(Exception e) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Following exception occurred on the page. ' + e.getMessage()));
		}
		return null;
	}

	// Get the list of Fields To Ignore from the Custom Settings
	private static Set<String> fieldsToIgnore {
		get {
			if(fieldsToIgnore == null) {
				fieldsToIgnore = new Set<String>();

				//Configuration_Manager__c
				List<Configuration_Manager__c> configs = Constants.getConfigManagerByParameterKey('ResidenceCloneIgnoreFields');

				//fill set from custom settings
		    	for(Configuration_Manager__c config : configs) {
					if(config.Parameter_Value__c != null) {
		        		fieldsToIgnore.add(config.Parameter_Value__c.trim().toLowerCase());
					}
		        }
			}
			return fieldsToIgnore;
		}
		private set;
	}
}