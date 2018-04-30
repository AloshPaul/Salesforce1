trigger Trigger_CalculateOverallPriority on Work_Order__c (before update)
{
	if(trigger.isBefore)
	{
		if(trigger.isUpdate)
		{
			for(Work_Order__c request : trigger.new)
			{
				if(request.Number_of_Low_items__c > 0)
					request.Overall_Priority__c = 'Low';
				if(request.Number_of_Medium_items__c > 0)
					request.Overall_Priority__c = 'Medium';
				if(request.Number_of_High_items__c > 0)
					request.Overall_Priority__c = 'High';
				if(request.Number_of_Urgent_items__c > 0)
					request.Overall_Priority__c = 'Urgent';
			}
		}
	}

}