public without sharing class createOppController {
    public class IntegException extends Exception {}
    @AuraEnabled
    public static String createOpportunity(String csvdata){
     	String res ='';
      try{ 
        AcqCSVResponseHandler csvResponseHandler = new AcqCSVResponseHandler();
		csvResponseHandler = (AcqCSVResponseHandler) System.JSON.deserialize(csvdata, AcqCSVResponseHandler.class);
       
        // To Fetch the State Id
                Map<String,String> nameVsIdState;
                nameVsIdState = new Map<String,String>();
                for(State__c st : [SELECT id,Name From State__c]){
                    if(!nameVsIdState.containsKey(st.Name)){
                        nameVsIdState.put(st.Name, st.Id);
                    }
                }
            
           // To Fetch the Zip Code Details
                Map<String, Zip_code_reference__c> zipCodeReferenceMap = new Map<String, Zip_code_reference__c>();
                for(Zip_code_reference__c zip : [SELECT Name, Zip__c, Market__c,Market2__c, LocationScore__c, SubMarket__c
                                                 FROM Zip_code_reference__c]) {
                                                     zipCodeReferenceMap.put(zip.Name, zip);
                                                 }
               
                
        	//Get the region Map against a Region Name
                Map<String,Region__c> allRegionsByStrings = new Map<String, Region__c>();
                for(Region__c region : [SELECT Id, Name, IMG_Director__c, IMG_Analyst__c, SVP_IMG__c FROM Region__c]) {
                    allRegionsByStrings.put(region.Name,region);
                }
          // Get Broker IQ id
          List<AcquisitionIQ__c> customUser = [SELECT id,Name,User_Name__c from AcquisitionIQ__c];
           
          Map<String,String> brokUserId  = new Map<String,String>();
            
         
            for(User userId :[SELECT id,Name,Username  from User]){
                if(!brokUserId.containsKey(userId.Username)){
                    brokUserId.put(userId.Username ,userId.Id);
                }
                
            }
          //string userName = brokUserId.get(customUser[0].User_Name__c);
           string userName = UserInfo.getUserId();
           Map<String,String> alloppres = new Map<String,String>();
            
            for(Acq_Opportunity__c oppList : [SELECT Id,Name,APN__c from Acq_Opportunity__c]){
                if(!alloppres.containsKey(oppList.APN__c)){
                	alloppres.put(oppList.APN__c,oppList.APN__c);
                }
            }
          
          // Duplicate APN Check
           string apn = csvResponseHandler.APN;
            if(apn.contains(' ')){
                  csvResponseHandler.APN =apn.replaceAll( '\\s+','');
              }
			else if(Apn.contains('-')){
                   csvResponseHandler.APN =apn.replaceAll( '-','');
            }
            else if(Apn.contains('.')){
                   csvResponseHandler.APN =apn.replaceAll('\\.', '');
            }
            else{
                   csvResponseHandler.APN = apn;                               
			} 
          
            if((alloppres.get(csvResponseHandler.APN)) == (csvResponseHandler.APN)){
            	throw new IntegException('APNexception');
            }
          	if((zipCodeReferenceMap.get(csvResponseHandler.Property_Zip_Code)) == null){
            	throw new IntegException('ZIPexception');
            }
      
           Acq_Prospect__c prosId =  csvUploadCtrler.insertOppandProsRecords(csvResponseHandler,nameVsIdState,zipCodeReferenceMap,allRegionsByStrings,
                                                              userName,alloppres);
     	  
          String recId = prosId.Id;
          
          res = recId;
          
      }  catch(IntegException Exp){
           
            //Add custom error code when you could not insert a record
            if(Exp.getMessage() == 'APNexception'){
                 res = 'Duplicate APN cannot be inserted';
            } 
            if(Exp.getMessage() == 'ZIPexception') {
                res = 'ERROR';
            }
        }
        catch(Exception e){
            system.debug(e.getMessage());
            res = e.getMessage();
            //res = 'ERROR';
            
            
      }
      	system.debug(res);
          return res;
    }
    @AuraEnabled
    public static List<String> getPicklistValues(String fieldName){
        List<String> PickValues = new List<String>();
        Schema.DescribeFieldResult fieldResult;
        List<Schema.PicklistEntry> outputs;
        if(fieldName == 'Property_Type__c') {
           fieldResult = Acq_Opportunity__c.Property_Type__c.getDescribe();
           
        }
        if(fieldName == 'Bid_Type__c') {
           fieldResult = Acq_Prospect__c.Bid_Type__c.getDescribe();
           
        }
        if(fieldName == 'Parking__c') {
           fieldResult = Acq_Opportunity__c.Parking__c.getDescribe();
           
        }
        if(fieldName == 'Roof_Type__c') {
           fieldResult = Acq_Opportunity__c.Roof_Type__c.getDescribe();
           
        }
        if(fieldName == 'HVAC_Type__c') {
           fieldResult = Acq_Opportunity__c.HVAC_Type__c.getDescribe();
           
        }
        if(fieldName == 'HOA__c') {
           fieldResult = Acq_Opportunity__c.HOA__c.getDescribe();
           
        }
        if(fieldName == 'RPC_Structure_Quality__c') {
           fieldResult = Acq_Prospect__c.RPC_Structure_Quality__c.getDescribe();
           
        }
        
           outputs = fieldResult.getPicklistValues();
           for(Schema.PicklistEntry fout:outputs){
           PickValues.add(fout.getLabel());
        	}
        
         
        return PickValues;
    }
    @AuraEnabled 
    public static List<State__c> getState(){
        return[select id,Name  from State__c];
    }
    @AuraEnabled 
    public static List<County__c > getCounty(String state){
        return[select id,Name,State__r.Name from County__c where State__r.Name=:state];
    }
    
}