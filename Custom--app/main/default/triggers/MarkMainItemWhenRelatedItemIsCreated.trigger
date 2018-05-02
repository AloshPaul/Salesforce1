/*
* When a related service item is created, this trigger will look for the main service
* item and will update it's status to "Related Service Item Created"
*/
trigger MarkMainItemWhenRelatedItemIsCreated on Service_Item__c (after insert)
{
	String relatedServiceItemId = [SELECT Id, Name FROM RecordType WHERE Name = 'Related Service Item'].Id;
	
	if(trigger.isAfter)
	{
		if(trigger.isInsert)
		{
			for(Service_Item__c item : trigger.new)
			{
				if(item.RecordTypeId == relatedServiceItemId)
				{
					Service_Item__c mainItem = [SELECT Id, Related_Service_Item_Created__c  FROM Service_Item__c WHERE Id =: item.Related_Service_Item__c];
					
					if(mainItem != null)
					{
						mainItem.Related_Service_Item_Created__c = true;
						
						update mainItem;
					}
				}
			}
		}
	}
}