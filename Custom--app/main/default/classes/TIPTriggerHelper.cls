/**
 *  Description :   Class to hold constant properties.
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   06/03/2013
 * 
 *  Revision Logs:  V1.0 - Created
                    V2.0  Saurabh Kumar - Added Method (validateTipType) and  webserviceamethod :checkSecondAcquisitionTip 
 *                  
 **/
global with sharing class TIPTriggerHelper {
    
    public Static List<String> accTipType =  new List<String>{'Post-Acquisition','Post Acquisition – Purchased Rented'};
    
    //Validate date field
    public static void validateAllDateField(List<SObject> sObjects) {

        Set<String> fieldNotAllowedToHoldFutureDate = Constants.TIP_FIELD_NOT_ALLLOWED_FOR_FUTURE_DATE;

        //Describe Rehab object
        Schema.DescribeSObjectResult tipObject = TIP_Tracking__c.sObjectType.getDescribe();

        //Describe Rehab object and get all the fields
        Map<String, Schema.SObjectField> tipFieldsMap = tipObject.fields.getMap();

        //loop through the records
        for(SObject sObj : sObjects) {

            //Loop through the fields name
            for(String fName : tipFieldsMap.keySet()) {

                //Describe field
                Schema.DescribeFieldResult field = tipFieldsMap.get(fName).getDescribe();

                //Check if the field is customa and type is Date
                if(field.isCustom() && (!field.isCalculated()) && (field.getType() == DisplayType.Date || field.getType() == DisplayType.DateTime)) {

                    //Check if field is not allowed to hold future date
                    if(fieldNotAllowedToHoldFutureDate.contains(fName .toLowerCase()) && sObj.get(fName) != null) {

                        //check for the value
                        if(field.getType() == DisplayType.Date) {

                            //Getting Local Time String
                            Date myDate = Date.valueOf(sObj.get(fName));
                            List<String> dateString = Date.valueOf(sObj.get(fName)).format().split('/');

                            //Chekc for the future date
                            if(date.newinstance(Integer.valueOf(dateString[2]), Integer.valueOf(dateString[0]), Integer.valueOf(dateString[1])) > Date.toDay()) {

                                //Error
                                sObj.addError(field.getLabel() + Constants.COLON + Constants.SPACE + Constants.ERROR_FUTUE_DATE);
                            }

                        } else if(field.getType() == DisplayType.DateTime) {

                            //Get the date time value
                            DateTime dtm = DateTime.valueOf(sObj.get(fName));

                            //Convert to Local time zone and dd/MM/yyyy format
                            List<String> datePair = dtm.format('dd/MM/yyyy').split('/');

                            //Check for the future date
                            if( Date.newInstance(Integer.valueOf(datePair[2]), Integer.valueOf(datePair[1]), Integer.valueOf(datePair[0]))  > Date.toDay()) {

                                //Error
                                sObj.addError(field.getLabel() + Constants.COLON + Constants.SPACE + Constants.ERROR_FUTUE_DATE);
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Function to Populate the Most Recent Tip on Residence
    public static void updateMostRecentTipOnResidence(List<Tip_Tracking__c> tips) {
        // Create a Map of Portfolio Id with the Tip ID
        Map<Id, Id> portTipMap = new Map<Id, Id>();
        for(Tip_Tracking__c tip : tips) {
            if(tip.Portfolio__c != null)
                portTipMap.put(tip.Portfolio__c, tip.Id);
        }
        
        Residence__c[] resListForUpdate = new List<Residence__c>(); 
        // Get all the Properties with Residence and add the corresponding Tip as the most recent Tip on the Residence.
        for(Property__c prop : [Select Residence__c from Property__c 
                                                    where Id in :portTipMap.keySet() 
                                                    and Residence__c != null
                                                    and Residence__r.Parent_Structure__c = false]) {
            Residence__c res = new Residence__c(Id = prop.Residence__c);
            res.Most_Recent_Tip__c = portTipMap.get(prop.Id);
            resListForUpdate.add(res);
        }
        // Update the Residences
        update resListForUpdate;
    } 
    
    
    //Method to Check second Post-Acquisition Tip/Post Acquisition – Purchase Rented Tip type on property 
     webservice Static String checkSecondAcquisitionTip ( String PropertyId,String RehabId ){   
          
           Boolean isPostAcquistionTip = false;
           Boolean canCreateNewTip   = true;
          
           if(PropertyId != null && RehabId != null)
           
               for(Tip_Tracking__c tip : [select id ,name ,Rehab__c ,TIP_Type__c ,TIP_Status__c from Tip_Tracking__c where Portfolio__c =:PropertyId]){
                  
                   if(tip.TIP_Type__c!=null &&(tip.TIP_Type__c.equalsIgnoreCase(accTipType[0])
                      || tip.TIP_Type__c.equalsIgnoreCase(accTipType[1]))) {
                            
                          isPostAcquistionTip = true; 
                                                   
                                               }
                   system.debug('Rehabid'+ RehabId+ '   Rehab__c'+ tip.Rehab__c);
                   if(tip.Rehab__c!=null && tip.Rehab__c == RehabId && tip.TIP_Status__c != null && !tip.TIP_Status__c.contains('Closed')) {
                        canCreateNewTip = false;
                   }   
               
               }
         
         return  '{ \"isPostAcquistionTipPresent\" : '+isPostAcquistionTip+', \"canCreateNewTip\" : '+canCreateNewTip+'}';
  
    }
    
    
    //Method To validate there should be only one Post-Acquisition Tip/Post Acquisition – Purchase Tip should be on property
    //And to check on rehab , A new tip can only created when all other tip on that rehab is closed
     public static void validateTipType(List<Tip_Tracking__c> newTipList , Map<Id, Tip_Tracking__c> Oldmap){
        //map to hold Property id and list of tip on that property which tip type is post acquisition or post acquistion purchase rented
        Map<Id,List<Tip_Tracking__c>> mapPropertyIdtoListTip = new Map<Id,List<Tip_Tracking__c>>();
         //map to hold rehab id with list of tip on that rehab
        Map<Id,List<Tip_Tracking__c>> mapRehabIdtoListTip = new Map<Id,List<Tip_Tracking__c>>();
        Set<Id> setPortfolioId = new Set<Id>();
        Set<Id> setRehabId =  new Set<Id>();
        for(Tip_Tracking__c tip : newTipList){
            //when tip is updated to Post acquisition /post acquisition purchage rented or new tip created with these tip type
            if( ((oldMap!=null && ((oldMap.containsKey(tip.id) 
                && oldMap.get(tip.id).TIP_Type__c != tip.TIP_Type__c) 
                || !oldMap.containsKey(tip.id)))
                || oldMap == null) && tip.TIP_Type__c!=null 
                && (tip.TIP_Type__c.equalsIgnoreCase(accTipType[0])
                || tip.TIP_Type__c.equalsIgnoreCase(accTipType[1]))
                ){
            
                    setPortfolioId.add(tip.Portfolio__c);
                    
                  }
            //when  new  tip is created with rehab!= null and  rehab is changed on tip 
            if((oldMap == Null ||(oldMap !=null && (!oldmap.containsKey(tip.Id) || 
                oldmap.get(tip.id).rehab__c != tip.Rehab__c))) && tip.Rehab__c!=null ){
                setRehabId.add(tip.Rehab__c);
            }
                    
          }
          //iterating through all tip present on related property
         For(Tip_Tracking__c tip : [select id ,TIP_Type__c ,Portfolio__c,Rehab__c ,Rehab__r.Sent_to_TIP__c , TIP_Status__c from Tip_Tracking__c where portfolio__c IN :setPortfolioId OR Rehab__c IN :setRehabId]){
             
            //checking if any active tip is present on rehab 
            if(tip.Rehab__c!=null 
               && tip.TIP_Status__c != Null && !tip.TIP_Status__c.contains('Closed') ){
                
               if(mapRehabIdtoListTip.containskey(tip.Rehab__c)){
                        mapRehabIdtoListTip.get(tip.Rehab__c).add(tip);
                    }
                    else{
                        mapRehabIdtoListTip.put(tip.Rehab__c , new list<Tip_Tracking__c>{tip});
                    } 
                
            }
            
            if(tip.TIP_Type__c != null && (tip.TIP_Type__c.equalsIgnoreCase(accTipType[0])
               || tip.TIP_Type__c.equalsIgnoreCase(accTipType[1]))){
                   
                    if(mapPropertyIdtoListTip.containskey(tip.portfolio__c)){
                        mapPropertyIdtoListTip.get(tip.portfolio__c).add(tip);
                    }
                    else{
                        mapPropertyIdtoListTip.put(tip.portfolio__c , new list<Tip_Tracking__c>{tip});
                    }
             }
        }   
        
         if(mapPropertyIdtoListTip.size() > 0 || mapRehabIdToListTip.size() >0){ 
                for(Tip_Tracking__c tip : newTipList){  
                    
                    //validation for only one Post acquisiton / post -acquistion purchase rented tip on a property 
                    if ( tip.Tip_Type__c != null 
                        && (tip.TIP_Type__c.equalsIgnoreCase(accTipType[0])
                        || tip.TIP_Type__c.equalsIgnoreCase(accTipType[1]))
                        && mapPropertyIdtoListTip!=null 
                        &&mapPropertyIdtoListTip.containskey(tip.portfolio__c)
                        ){
                         for(Tip_Tracking__c availableTip : mapPropertyIdtoListTip.get(tip.portfolio__c)){
                            
                             if(oldmap!=null && oldmap.containskey(tip.id) && tip.id == availableTip.id)    
                              continue;
                              
                             tip.addError('TIP Type:-'+availableTip.TIP_Type__c + '  already present on the property ,Please select Tip Type = \"Remediation\"   ');
                         }  
                            
                      }
                    //validation : A tip on rehab can only be created if all other tip on that rehab is closed 
                    if( (oldmap==null || (oldMap !=null && (!oldmap.containsKey(tip.Id) || 
                           oldmap.get(tip.id).rehab__c != tip.Rehab__c)) )&&tip.Rehab__c != null 
                           && mapRehabIdToListTip != null
                        && mapRehabIdToListTip.containsKey(tip.Rehab__c)){
                           
                          tip.addError('An Active Tip is alrady present on Rehab :'+ tip.Rehab__c);  
                       }
                 }
             
         }
            
        }       
      
}