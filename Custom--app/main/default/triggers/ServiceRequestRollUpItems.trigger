trigger ServiceRequestRollUpItems on Service_Item__c (after delete, after insert, after undelete, 
after update)
{
 	if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
 	{
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition>
        {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Open__c', 'Number_of_Open_Items__c'), 
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Closed__c', 'Number_of_Closed_Items__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Urgent__c', 'Number_of_Urgent_items__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_High__c', 'Number_of_High_items__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Medium__c', 'number_of_Medium_items__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Low__c', 'Number_of_Low_items__c')
        };
         
        RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, trigger.new, 'Service_Item__c', 'Service_Request__c', 'Work_Order__c', '');
         
    }
     
    if(trigger.isDelete)
    {
        list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition>
        {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Open__c', 'Number_of_Open_Items__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'Is_Closed__c', 'Number_of_Closed_Items__c')
        };
         
        RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, trigger.old, 'Service_Item__c', 'Service_Request__c', 'Work_Order__c', '');
         
    }	

}