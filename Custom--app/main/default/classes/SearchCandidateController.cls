public without sharing class SearchCandidateController {
	@AuraEnabled
    public static String checkClaim(String apn, String county, Id state) {
        //Null check
        system.debug(apn+county+state);
        List<Acq_Opportunity__c> candidates;
        State__c s;
        String status;
        String uniqueApn;
        if(county != '' && state != null) {
            s = [SELECT Name FROM State__c WHERE Id = :state];
            if(s != null){
                uniqueApn = apn + '-' + county + '-' + s.Name;
            } else {
                uniqueApn = apn + '-' + county;
            }
            candidates = [SELECT ID, Property_Claimed__c
                        FROM Acq_Opportunity__c
                        WHERE Unique_APN__c = :uniqueApn];

        } else {
            candidates = [SELECT ID, Property_Claimed__c
                        FROM Acq_Opportunity__c
                        WHERE APN__c =:apn];
        }


        if(candidates.size() > 1) {
            //More candidate with same APN, county and state
            //status = 'More than 1 candidate';
            status = 'No County OR State';
        } else if(candidates.size() == 1) {
            for(Acq_Opportunity__c c : candidates){
                If(c.Property_Claimed__c == false){
              		status = 'Claim Candidate'; //Allow to claim candidate - Claim candidate
				} else if (c.Property_Claimed__c == true) {
					status = 'Candidate Claimed'; //Sorry you cannot claim the property - toast
				} 
            } 
        } else {
            //Create a new Candidate
            status = 'New Candidate';
        }
        
        return status;
        
    }
    
    @AuraEnabled
    public static Boolean checkActiveClaimsByUser() {
        //Check active claims per broker
        Integer countClaims = [SELECT count() 
                                FROM Acq_Opportunity__c 
                                WHERE Broker__c =:UserInfo.getUserId() 
                                AND status__c in ('New','Claimed','Working')];
        System.debug('Active claims are' + countClaims);
        //Get the User region
        User u = [SELECT ID, Region__c FROM User WHERE id = :UserInfo.getUserID()];
        //Market Active_Claims_per_Broker__c
        Region__c reg = [SELECT ID, Active_Claims_per_Broker__c FROM Region__c WHERE Name = :u.Region__c];
        if(countClaims >= reg.Active_Claims_per_Broker__c) {
            return true;
        } else {
            return false;
        }  
    }
    
    @AuraEnabled 
    public static List<State__c> getState(){
        return[select id,Name  from State__c order by Name];
    }
    
    @AuraEnabled 
    public static State__c getStateId(String StateName){
        return[select id from State__c where Name=:StateName];
    }
    
    
   @AuraEnabled 
    public static List<County__c > getCounty(String state){
        return[select id,Name,State__r.Name from County__c where State__r.Name=:state order by Name];
    }
   
    @AuraEnabled
    public static String getURLName(){
        String host = URL.getSalesforceBaseUrl().getHost();
        return host;
    }
    
}