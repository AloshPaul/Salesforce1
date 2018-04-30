trigger Trigger_CalculateShowings on Showing__c (after insert, after update, after delete) 
{
    //Execute the trigger only if required
    if(Constants.EXECUTE_TRIGGER == false)
    	return;
    
    List<Listing__c> listingsforUpdate = new List<Listing__c>();
    Set<Id> listingIds = new Set<Id>();
    if(trigger.isInsert)
    {
        for(Showing__c newShowing : trigger.New)
        {
            listingIds.add(newShowing.Listing__c);
        }
    }
    if(trigger.isUpdate)
    {
        for(Showing__c newShowing : trigger.New)
        {
            if(trigger.oldMap.get(newShowing.Id).Listing__c != newShowing.Listing__c)
            {
                listingIds.add(newShowing.Listing__c);
                listingIds.add(trigger.oldMap.get(newShowing.Id).Listing__c);
            }
        }
    }
    if(trigger.isDelete)
    {
        for(Showing__c oldShowing : trigger.Old)
        {
            listingIds.add(oldShowing.Listing__c);
        }
    }
    for(Listing__c listing : [select Id, (select Id from Showings__r) from Listing__c where Id in :listingIds])
    {
        listing.Total_Showings_C__c = listing.Showings__r.size();
        listingsforUpdate.add(listing);
    }
    if(listingsforUpdate.size() > 0)
    {
        update listingsforUpdate;
    }
}