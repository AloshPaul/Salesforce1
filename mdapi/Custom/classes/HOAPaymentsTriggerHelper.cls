/**
 *   Description	:	Helper class to perform pre and post operations on HOA payments records.
 *
 *   Created By   	:	Bhavi Sharma
 *
 *   Created Date 	:	02/20/2014
 *
 *   Revision Logs	:	V_1.0 - Created
 *
 **/
public class HOAPaymentsTriggerHelper {

	/**
     *  @description    :   Method to set Most Recent HOA Due Payment lookup field on "HOA Tracking" object with most recent HOA Payments record.
     *
     *  @args           :   List of new HOA Payments, Map of old HOA Payments
     *
     *  @return         :   void
     *
     **/
    public static void populateMostRecentHOAPayment(List<HOA_Payments__c> newHOAPayments, Map<Id, HOA_Payments__c> mapOldHOAPayments) {

		//Set to hold Parent HOA Tracking Ids
        Set<Id> setHOATrackingIds = new Set<Id>();

	    //List to hold the current Context HOA_Payments__c
	    List<HOA_Payments__c> listHOAPayments = newHOAPayments != null ? newHOAPayments : mapOldHOAPayments.values();

	    //Loop through the records list and populate the setClaimIds
	    for(HOA_Payments__c hP : listHOAPayments) {

	    	//If trigger is executing in case of update, Check old and new value before executing the login
	    	//Run always for insert and delete
	    	if((newHOAPayments != null && mapOldHOAPayments != null && hP.Due_Date__c != mapOldHOAPayments.get(hP.Id).Due_Date__c)
	    			|| (newHOAPayments != null && mapOldHOAPayments == null && hP.Due_Date__c != null)
	    			|| (newHOAPayments == null && mapOldHOAPayments != null && hP.Due_Date__c != null)) {

	    		//This should be processed
	    		setHOATrackingIds.add(hP.HOA_Tracker__c);
	    	}
	    }

		//Chech set size before executing the query
		if(setHOATrackingIds.size() == 0)
			return;

	    //List to hold the "HOA Tracking" record to update
        List<HOA_Tracking__c> listHOATrackings = new List<HOA_Tracking__c>();

        //Populate Map to hold the Parent HOA Tracking record Id value as key and most recent HOA Payments record as value
        for(HOA_Tracking__c hTrack : [SELECT Id, Most_Recent_HOA_Payment__c,
        										(SELECT Id FROM HOA_Payments__r WHERE Due_Date__c != null ORDER BY Due_Date__c DESC LIMIT 1)
        										FROM HOA_Tracking__c WHERE Id IN : setHOATrackingIds] ) {

			//Only Process the record if found and
			if(hTrack.HOA_Payments__r.size() > 0 && hTrack.Most_Recent_HOA_Payment__c != hTrack.HOA_Payments__r[0].Id) {

				//Add record in the list to be updated
				hTrack.Most_Recent_HOA_Payment__c = hTrack.HOA_Payments__r[0].Id;
				listHOATrackings.add(hTrack);
			}
		}

        //Only update the records if there any
		if(listHOATrackings.size() > 0)
			update listHOATrackings;
	}
}