/**
 *    Description       :    Apex Class used to open the Concierge Detail page based on User's Region
 *
 *    Created By        :    Poonam Bhargava
 *
 *    Created Date      :    02/15/2017    
 *
 *    Revision Logs     :    V1.0 - Created
 **/
public with sharing class OverrideConciergeNewController{
            
    //Initialize Constructor
    public OverrideConciergeNewController(ApexPages.StandardController controller) {
    }

    //Method to redirect the user on next screen based on User's Region
    public PageReference redirect(){
    
        //Get the record Type from Url
        String recordTypeId = Apexpages.currentPage().getParameters().get('RecordType');
        
        //Query on Record Type
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName from RecordType where Id =: recordTypeId 
                                            AND DeveloperName !=: Label.Concierge_Record_Type_Treasury_Request 
                                            AND DeveloperName !=: Label.Concierge_Record_Type_Datamatics_Request];
    
        
        //Retrieve Users records
        //List<User> users = [Select Id, Region__c, Dallas_Office__c from User where Id =: UserInfo.getUserId() AND Region__c =: Constants.REGION_NATIONAL AND Dallas_Office__c = true]; 
        
        //Check for list size
        //if(users.size() > 0 && recordTypes.size() > 0){
        if(recordTypes.size() > 0){
            
            //Initialize the page reference variable and set target location
            return new PageReference('http://invitationhomes.service-now.com/');
        }
        else{
            
            //Initialize map of string and populate with url paramerter values
            Map<String, String> mapParams = ApexPages.currentPage().getParameters();
            
            //Get the key Prefix of Concierge object
            String  keyPrefix = Schema.getGlobalDescribe().get('Concierge__c').getDescribe().getKeyPrefix();
            
            //URL variable
            String url = '';
            
            //Loop over mapParams keyset
            for(String uRLParam : mapParams.keyset()){
                
                //Check for condition and populate url varible 
                if(uRLParam != 'save_new')
                    url += uRLParam + '=' + mapParams.get(uRLParam) + '&';  
            }  
            
            //Set nooverride value in url
            url += 'nooverride=1';
            
            //Set url in PageReference and return ref
            return new PageReference('/' + keyPrefix + '/e?'+url);                
        }      
		
        return null;
		
    }
}