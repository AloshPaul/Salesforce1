/*********************************************************************************
 * Name             : Trigger_ShowingHandler
 * Created By       : Jennifer Dauernheim(Appirio Consulting)
 * Created Date     : Feb 27, 2014
 * Purpose          : Handles multiple process related to the Showing record
                    : Feb 17 ,2017  (Modified by Saurabh ) updateShowingSharingRules D-00016868
***********************************************************************************/
public without sharing class Trigger_ShowingHandler {

    public static boolean isTrigger_ShowingCalld = false;
    public static Set<String> ShowingFirstNameSet = new Set<String>();
    public static Set<String> ShowingLastNameSet = new Set<String>();
    public static Set<String> ShowingPhoneSet = new Set<String>();
    public static Map<String, Contact> ShowingRecsToCreateContact = new Map<String,Contact>();
    public static Map<String, Contact> ContactMap = new Map<String,Contact>();

/***********************************************************************************
  Handler Method for Before Insert
************************************************************************************/
  	public static void onBeforeInsert(List<Showing__c> newShowingList){

  		for(Showing__c ShowingRec : NewShowingList){
	  		ShowingFirstNameSet.add(ShowingRec.First_Name__c);
	  		ShowingLastNameSet.add(ShowingRec.Last_Name__c);
	  		ShowingPhoneSet.add(ShowingRec.Phone__c);

	  		if(ShowingRec.Agent_Name__c == Null){
	  			ShowingRec.Agent_Name__c = userinfo.getUserID();
	  		}
  		}

	  	//get existing contacts that match showing records
	  	Map<String, Contact> ExistingContactMap = new Map<String,Contact>(getContacts(ShowingFirstNameSet, ShowingLastNameSet, ShowingPhoneSet));
	  	createContacts(ExistingContactMap, NewShowingList);

	  	// Call function to update the Region based on listing
	  	updateRegion(newShowingList, null);
  	}

/***********************************************************************************
  Handler Method for Before Insert
************************************************************************************/

	public static void onAfterInsert(Map<Id, Showing__c> newShowingMap){
		checkForShowingSharing(newShowingMap, null);
	}

/***********************************************************************************
  Handler Method for Before Update
************************************************************************************/

	public static void onBeforeUpdate(List<Showing__c> newShowingList, Map<ID,Showing__c> oldShowingMap){
		// Call function to update the Region based on listing
	  	updateRegion(newShowingList, oldShowingMap);
  	}


/***********************************************************************************
  Handler Method for After Update
************************************************************************************/
  	public static void onAfterUpdate(Map<Id, Showing__c> newShowingMap, Map<ID,Showing__c> oldShowingMap){
		checkForShowingSharing(newShowingMap, oldShowingMap);
  	}



/***********************************************************************************
 getContacts
	from the listing of showing information, search for any contacts with matching parameters(firstname, last name, phone)
	Add contacts retrieved to map for processing later
************************************************************************************/
  	public static Map<String, Contact> getContacts(Set<String> FirstNameSet, Set<String> LastNameSet, Set<String> PhoneSet){

		List<Contact> ExistingContacts = New List<Contact>([ select FirstName, LastName, Phone, ID
															from Contact
															where firstName in :FirstNameSet
															and LastName in :LastNameSet
															and Phone in :PhoneSet]);
		system.debug('ExistingContacts:' + ExistingContacts);
		if(ExistingContacts.size()>0){
			For(Contact ContactRec : ExistingContacts){
				ContactMap.put(ContactRec.FirstName+'^' + ContactRec.LastName + '^' + ContactRec.Phone, ContactRec);
			}

		}
		return ContactMap;
  	}

/***********************************************************************************
  CheckforExistingContacts
	After getting contacts, check showing recs to see if any new contacts need to be created
************************************************************************************/
  	public static void createContacts(Map<String,Contact> ContactMap_Existing, List<Showing__c>NewShowingList){
		List<Contact> CreateContact = new List<Contact>();

		for(Showing__c ShowingRec : NewShowingList){
	  		String ShowingRecKey = ShowingRec.First_Name__c + '^' + ShowingRec.Last_name__c + '^' + showingRec.Phone__c;
	  		if(ContactMap_Existing.ContainsKey(ShowingRecKey)){
	  			system.debug('contact already existings');
	  			ShowingRec.Contact__c = ContactMap_Existing.get(ShowingRecKey).id;
	  		}else{
	  			Contact NewContactRec = new Contact();
	  			newContactRec.FirstName = ShowingRec.First_name__c;
	  			newContactRec.LastName = ShowingRec.Last_Name__c;
	  			newContactRec.Phone = ShowingRec.Phone__c;
	  			NewContactRec.MailingStreet = ShowingRec.Street__c;
	  			NewContactRec.MailingCity = Showingrec.City__c;
	  			newContactRec.MailingState = Showingrec.State_Province__c;
	  			newContactRec.MailingPostalCode = ShowingRec.Zip_Postal_Code__c;
	  			newContactRec.MailingCountry = ShowingRec.Country__c;
	  			newContactRec.Email = ShowingRec.Email__c;


	  			CreateContact.add(newContactRec);
	  		}

	  	}

	  	if(CreateContact.size()>0){
	  			Insert createContact;
	  	}

	  	//for all showing records that had new contacts created, update showing record with contact information.
	  	for(Showing__c ShowingRec : NewShowingList){
	  		if(ShowingRec.Contact__c == null){
	  			String ShowingRecKey = ShowingRec.First_Name__c + '^' + ShowingRec.Last_name__c + '^' + showingRec.Phone__c;
	  			For( Contact ContactRec : CreateContact){
	  				String ContactRecKey = ContactRec.FirstName + '^' + ContactRec.LastName + '^' + ContactRec.Phone;
	  				if (ContactRecKey == ShowingRecKey){
	  					ShowingRec.Contact__c = ContactRec.id;
	  				}
	  			}
	  		}
	  	}
  	}

  	/* Function to check if Sharing rules need to be modified for a Showing
  	// 1. When Showing is inserted and it has a reference to a Agent Name or a Listing or a Incoming Call
  	// 2. When Showing is updated and Agent Name is changed
  	// 3. When Showing is updated and Listing is changed
  	// 4. When Showing is updated and Incoming Call is changed.
  	*/
	public static void checkForShowingSharing(Map<Id,Showing__c> newShowingMap , Map<Id, Showing__c> oldShowingMap){
		List<Showing__c> showingList = new List<Showing__c>();
		for(Showing__c showing : newShowingMap.values()) {
			if((oldShowingMap == null
					&& (showing.Agent_Name__c != null || showing.Listing__c != null || showing.Call_Record_if_applicable__c != null))
				|| (showing.Agent_Name__c != oldShowingMap.get(showing.Id).Agent_Name__c
					|| showing.Listing__c != oldShowingMap.get(showing.Id).Listing__c
					|| showing.Call_Record_if_applicable__c != oldShowingMap.get(showing.Id).Call_Record_if_applicable__c)) {
				showingList.add(showing);
			}
		}

		updateShowingSharingRules(showingList);
	}

	/* Function to create Sharing Rules for Showing
		1) Listing__r.Listing_Agent__c gets access to all Showings
		2) Incoming_Call__r.Listing_Agent__c gets access to all Showings that have Showing__r.Listing__c == this listing
		3) Incoming_Call__r.Listing_Agent__c gets access to all Showings that have Showing__r.Call_Record_If_Applicable__c = this Incoming Call
		4) Showing__r.Agent_Name__c gets access to this showing
	*/

	public static void updateShowingSharingRules(List<Showing__c> showingList){
		set<Id> showingID = new set<Id>();
		Set<ID> listingIdSet = new Set<Id>();
		set<Id> incomingCallIdSet = new Set<Id>();
		Set<Id> agentIds = new Set<Id>();

		for(Showing__c showing : showingList){
			showingID.add(showing.Id);

			if(showing.Listing__c != null)
				listingIdSet.add(showing.Listing__c);
			if(showing.Call_Record_if_applicable__c != null)
				incomingCallIdSet.add(showing.Call_Record_if_applicable__c);

			if(showing.Agent_Name__c != null)
				agentIds.add(showing.Agent_Name__c);
		}

		// Delete all Manual Sharing rules
		List<Showing__Share> showingSharesTobeDeleted  = new List<Showing__Share>();
		showingSharesTobeDeleted = [Select Id from Showing__Share
		 								 	where 	RowCause = 'Manual'
		 							  		and 	ParentId in : showingId];

		 if(!showingSharesTobeDeleted.isEmpty())
	     	Database.delete(showingSharesTobeDeleted, false);

		// List of ShowingShares to be inserted
		Set<Showing__Share> showingSharesTobeInserted = new Set<Showing__Share>();
    	Map<Id, Listing__c> listingMap = new Map<Id, Listing__c>();
    	// Map of Listing Id with List of Incoming Calls
    	Map<Id, Set<Id> > listingIncomingMap = new Map<Id , Set<Id>>();

    	Map<Id, Incoming_Calls__c> incomingCallMap = new Map<Id, Incoming_Calls__c>();

    	// Get listing Details
    	if(!listingIdSet.isEmpty()) {
			listingMap = new Map<Id, Listing__c>([Select Listing_Agent__c from Listing__c
																			where Id in :listingIdSet
																			and Listing_Agent__c != null
																			and Listing_Agent__r.IsActive = true]);

			for(Incoming_Calls__c incomingCall : [Select Listing__c, Listing_Agent__c from Incoming_Calls__c
													 							where Listing__c in :listingIdSet
													 							and Listing_Agent__c != null
													 							and Listing_Agent__r.IsActive = true]){
				if(listingIncomingMap.containsKey(incomingCall.Listing__c))
					listingIncomingMap.get(incomingCall.Listing__c).add(incomingCall.Listing_Agent__c);
				else
					listingIncomingMap.put(incomingCall.Listing__c, new Set<Id>{incomingCall.Listing_Agent__c});
			}
    	}

    	// Get Incoming Call Details
    	if(!incomingCallIdSet.isEmpty()) {
    		incomingCallMap = new Map<Id, Incoming_Calls__c>([Select Listing_Agent__c from Incoming_Calls__c
																						where Id in :incomingCallIdSet
																						and Listing_Agent__c != null
																						and Listing_Agent__r.IsActive = true]);
    	}

    	// Agent User Active Map
    	Map<Id, User> agentMap = new Map<Id, User>();
    	if(!agentIds.isEmpty())
    		agentMap = new Map<Id, User>([Select Id from User where Id in :agentIds and IsActive = true]);
        
    	// Loop through all the Showing records and create sharing rules
		for(Showing__c showing : showingList) {

			// Insert a Showing Share for a new Agent Name
			if(showing.Agent_Name__c != null
					&& agentMap.containsKey(showing.Agent_Name__c)
					&& showing.Agent_Name__c != showing.OwnerId) {
	    		// Create New Sharing record on change of Agent Name
	    		showingSharesTobeInserted.add(
	    			new Showing__Share(
	    				ParentId 		= showing.Id,
	    				UserOrGroupId 	= showing.Agent_Name__c,
	    				AccessLevel 	= 'Edit'
					)
				);
			}

			// Insert sharing rule for Showing.Listing__r.Listing_Agent__c
			if(showing.Listing__c != null && listingMap.containsKey(showing.Listing__c)
					&& listingMap.get(showing.Listing__c).Listing_Agent__c != showing.OwnerId) {
    			// Create New Sharing record on change change of Listing. Listing_Agent
	    		showingSharesTobeInserted.add(
	    			new Showing__Share(
	    				ParentId 		= showing.Id,
	    				UserOrGroupId 	= listingMap.get(showing.Listing__c).Listing_Agent__c,
	    				AccessLevel 	= 'Edit'
					)
				);
			}

	    	// Create sharing rule for Listing Agent of All Incoming Calls associated with the listing
	    	if(showing.Listing__c != null && listingIncomingMap.containsKey(showing.Listing__c)) {
				for(ID incomingCallListingAgent : listingIncomingMap.get(showing.Listing__c)) {
					if(incomingCallListingAgent != showing.OwnerId) {
						showingSharesTobeInserted.add(
			    			new Showing__Share(
			    				ParentId 		= showing.Id,
			    				UserOrGroupId 	= incomingCallListingAgent,
			    				AccessLevel 	= 'Edit'
							)
						);
					}
				}
	
			}

			// Insert sharing rule for Showing.Call_Record_if_applicable__r.Listing_Agent__c
			if(showing.Call_Record_if_applicable__c != null
	    					&& incomingCallMap.containsKey(showing.Call_Record_if_applicable__c)
	    					&& incomingCallMap.get(showing.Call_Record_if_applicable__c).Listing_Agent__c != showing.OwnerId) {
    			// Create New Sharing record on change of Incomming Calls.
	    		showingSharesTobeInserted.add(
	    			new Showing__Share(
	    				ParentId 		= showing.Id,
	    				UserOrGroupId 	= incomingCallMap.get(showing.Call_Record_if_applicable__c).Listing_Agent__c,
	    				AccessLevel 	= 'Edit'
					)
				);
    		}
    	}

    	if(!showingSharesTobeInserted.isEmpty()) {
    		List<Showing__Share>  listshowingSharesTobeInserted = new List<Showing__Share>(showingSharesTobeInserted);
    		Database.SaveResult[] srList = Database.insert(listshowingSharesTobeInserted, false);
    	}
	}

	// Function to Update the Region on Insert or Listing Change.
	public static void updateRegion(List<Showing__c> newShowingList, Map<Id, Showing__c> oldShowingMap){
  		set<ID> listingSet = new Set<Id>();
  		// Get all listing record by looping through the Showing records
  		for(Showing__c showRec : newShowingList){
  			if(showRec.Listing__c != null
  					&& (oldShowingMap == null || oldShowingMap.get(showRec.Id).Listing__c != showRec.Listing__c)) {
  				listingSet.add(showRec.Listing__c);
  			}
  		}

  		Map<Id, Listing__c> listingMap = new Map<Id, Listing__c>([Select Id , Region__c from Listing__c where id in : listingSet]);
  		for(Showing__c showing : newShowingList){
  			if(showing.Listing__c != null
  					&& (oldShowingMap == null || oldShowingMap.get(showing.Id).Listing__c != showing.Listing__c)
  					&& listingMap.containsKey(showing.Listing__c)) {
  				showing.Region_Text__c = listingMap.get(showing.Listing__c).Region__c ;
  			}
  		}
  	}
}