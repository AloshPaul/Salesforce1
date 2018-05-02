public without sharing  class AcqBudgetWalkTriggerHelper {

    public static void createResidence(List<Acq_Budget_Walk__c> budgetWalks){
        
        List<Acq_Prospect__c> updateResOnPros = new List<Acq_Prospect__c>();
        List<HD_Budget_Walk__c> newHdBudWalk = new List<HD_Budget_Walk__c>();
      
        String resId ='';
        for(Acq_Budget_Walk__c budget:budgetWalks){
          
       
        Acq_Budget_Walk__c  acqBud = [select id ,name ,PipelineID__c, Prospect_ID__c,Prospect_ID__r.Address__r.Street__c,Prospect_ID__r.Address__r.Unit__c ,
                                       Prospect_ID__r.Address__r.City__c ,Prospect_ID__r.Address__r.State__r.Name,Prospect_ID__r.Address__r.Zip__c ,
                                       Prospect_ID__r.Address__r.County__c ,Prospect_ID__r.Opportunity__r.Market__c,Prospect_ID__r.Opportunity__r.APN__c,Prospect_ID__r.Opportunity__r.Unique_APN__c,
                                       Prospect_ID__r.Opportunity__r.Market__r.Name,Prospect_ID__r.Opportunity__r.Baths__c,Prospect_ID__r.Opportunity__r.Bedrooms__c,
                                       Prospect_ID__r.Opportunity__r.Square_Feet__c,Prospect_ID__r.Opportunity__r.Year_Built__c,Prospect_ID__r.Opportunity__r.Parking__c,Prospect_ID__r.Opportunity__r.Property_Type__c,
                                       Prospect_ID__r.Opportunity__r.Subdivision__c,Prospect_ID__r.Opportunity__r.HVAC_Type__c,Prospect_ID__r.Opportunity__r.Bid_Type__c,
                                       Prospect_ID__r.Opportunity__r.Lot_Sq_Ft__c,Prospect_ID__r.Property_Score__c,Prospect_ID__r.Location_Score__c,Prospect_ID__r.Overall_Asset_Score__c,
                                       Prospect_ID__r.Opportunity__r.HOA_Name__c,Prospect_ID__r.Opportunity__r.HOA__c,Prospect_ID__r.Opportunity__r.Roof_Type__c,Prospect_ID__r.Opportunity__r.Market2__c,Prospect_ID__r.Address__r.Location__c,
                                       Prospect_ID__r.Address__r.Location__latitude__s,Prospect_ID__r.Address__r.Location__longitude__s
                                            
                                       from Acq_Budget_Walk__c where ID =:budget.ID];

            String apnUniq = acqBud.Prospect_ID__r.Opportunity__r.APN__c;
            List<Residence__c> OldRes = [SELECT id,Name,APN__c,APN_Unique__c From Residence__c where APN_Unique__c =:apnUniq];
            Residence__c  createRes = new Residence__c (
             
                    Address_Street__c = acqBud.Prospect_ID__r.Address__r.Street__c,
                    Address_Validated_Street__c = acqBud.Prospect_ID__r.Address__r.Street__c,
                    Address_Unit__c = acqBud.Prospect_ID__r.Address__r.Unit__c ,
                    Address_City__c = acqBud.Prospect_ID__r.Address__r.City__c  ,
                    Address_Validated_City__c = acqBud.Prospect_ID__r.Address__r.City__c  ,
                    Address_State__c = acqBud.Prospect_ID__r.Address__r.State__r.Name ,
                    Address_Validated_State__c = acqBud.Prospect_ID__r.Address__r.State__r.Name ,
                    Address_Zip_Code__c = acqBud.Prospect_ID__r.Address__r.Zip__c,
                    Address_Validated_Zip__c  = acqBud.Prospect_ID__r.Address__r.Zip__c  ,
                    County__c = acqBud.Prospect_ID__r.Address__r.County__c ,
                    Address_Validated_County__c = acqBud.Prospect_ID__r.Address__r.County__c ,
                    Location__latitude__s = acqBud.Prospect_ID__r.Address__r.Location__latitude__s,
                    Location__longitude__s = acqBud.Prospect_ID__r.Address__r.Location__longitude__s,
                    Region__c = acqBud.Prospect_ID__r.Opportunity__r.Market2__c ,
                    APN__c = acqBud.Prospect_ID__r.Opportunity__r.APN__c,
                    APN_Unique__c = acqBud.Prospect_ID__r.Opportunity__r.Unique_APN__c,
                    Market__c = acqBud.Prospect_ID__r.Opportunity__r.Market__r.Name,
                    Baths__c = acqBud.Prospect_ID__r.Opportunity__r.Baths__c,
                    Bedrooms__c = acqBud.Prospect_ID__r.Opportunity__r.Bedrooms__c,
                    Square_Feet__c = Integer.valueOf(acqBud.Prospect_ID__r.Opportunity__r.Square_Feet__c),
                    Year_Built__c = Integer.valueOf(acqBud.Prospect_ID__r.Opportunity__r.Year_Built__c),
                    Parking__c = acqBud.Prospect_ID__r.Opportunity__r.Parking__c,
                    Property_Type__c = acqBud.Prospect_ID__r.Opportunity__r.Property_Type__c,
                    Subdivision__c = acqBud.Prospect_ID__r.Opportunity__r.Subdivision__c,
                    AC_or_Evap__c = acqBud.Prospect_ID__r.Opportunity__r.HVAC_Type__c,
                    Bid_Type__c = acqBud.Prospect_ID__r.Opportunity__r.Bid_Type__c,
                    Lot_Sq_Ft__c = acqBud.Prospect_ID__r.Opportunity__r.Lot_Sq_Ft__c,
                    Property_Score__c = acqBud.Prospect_ID__r.Property_Score__c,
                    Location_Score__c = acqBud.Prospect_ID__r.Location_Score__c,
                    Overall_Asset_Score__c =acqBud.Prospect_ID__r.Overall_Asset_Score__c,
                    HOA__c = acqBud.Prospect_ID__r.Opportunity__r.HOA_Name__c,
                    HOA_Options__c = acqBud.Prospect_ID__r.Opportunity__r.HOA__c,
                    Roof_Type__c = acqBud.Prospect_ID__r.Opportunity__r.Roof_Type__c,
                    Pipeline__c = acqBud.PipelineID__c,
                    Prospect__c = acqBud.Prospect_ID__c
                 
               
            );
            
           try{
               if(OldRes.size()>0){
                   resId =  OldRes[0].Id;
               }else {
                   insert createRes;
                   resId = createRes.Id;
               }  
            } catch(Exception e){
                // Send an email if trigger insertion fails
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       String[] toAddresses = new String[] {'sekarraj@zencloudtech.com'};
                       mail.setToAddresses(toAddresses);
                       mail.setSubject('Error Message When Creating Residence');
                       mail.setPlainTextBody
                       ('The error message' + e.getMessage());
                       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
          
                
                
           
            for(Residence__c resData:[SELECT id,Name,Prospect__c,Region__c,Market__c from Residence__c where ID=:resId]){
                HD_Budget_Walk__c hdBudgetWalk = new HD_Budget_Walk__c(Acq_Prospect_ID__c  = acqBud.Prospect_ID__c,
                                                                       Residence__c  = resData.Id,
                                                                       Type__c  = 'Pre-Acquisitions',
                                                                       Status__c  = 'New',
                                                                       Region__c = acqBud.Prospect_ID__r.Opportunity__r.Market2__c,
                                                                       Market__c = acqBud.Prospect_ID__r.Opportunity__r.Market__r.Name
                                                                      );
                
                newHdBudWalk.add(hdBudgetWalk);
                
                Acq_Prospect__c updPros = new Acq_Prospect__c(
                              Id = acqBud.Prospect_ID__c
                           );
                updPros.Residence__c  = resData.Id;
                updateResOnPros.add(updPros);
            }
            if(updateResOnPros.size()>0){
               update updateResOnPros;
            }
           
            
            if(newHdBudWalk.size()>0){
                insert newHdBudWalk;
                for(HD_Budget_Walk__c updHDBud : newHdBudWalk){
                    Acq_Budget_Walk__c upBud = new Acq_Budget_Walk__c(
                    Id = acqBud.id
                    );
                    upBud.BW_Estimator_Link__c = updHDBud.Id;
                    update upBud;
                }
                system.debug(newHdBudWalk + 'created HD budget ');
            }
            
       
      }
    }

}