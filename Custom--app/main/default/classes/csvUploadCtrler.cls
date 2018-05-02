public class csvUploadCtrler {
    
   

    public static Acq_Prospect__c insertOppandProsRecords(AcqCSVResponseHandler csvResponseHandler, Map<String,String> nameVsIdState,Map<String, Zip_code_reference__c> zipCodeReferenceMap,Map<String,Region__c> allRegionsByStrings,
                                                          String userName,Map<String,String> alloppres
                                                         
                                                         ){
    	
      				Id oppRecordTypeId = Schema.SObjectType.Acq_Opportunity__c.getRecordTypeInfosByName().get('After Submit for Underwriting').getRecordTypeId();
                            String Apn = csvResponseHandler.APN;
                            
                            Acq_Opportunity__c opp = new Acq_Opportunity__c();
                                    opp.APN__c = csvResponseHandler.APN;
                                    opp.Bid_Type__c = csvResponseHandler.Bid_Type;
                                    opp.Bulk_Deal__c = csvResponseHandler.Bulk_Deal;
                                    opp.Property_Type__c = csvResponseHandler.Property_Type;
                                    opp.Year_Built__c = csvResponseHandler.Year_Built;   
                                    opp.Bedrooms__c = decimal.valueOf(csvResponseHandler.Bedrooms.trim()); 
                                    opp.Baths__c = decimal.valueOf(csvResponseHandler.Baths.trim());
                                    opp.Square_Feet__c = Integer.valueOf(csvResponseHandler.Square_Feet.trim());
                                    opp.Parking__c = csvResponseHandler.Parking;
                                    opp.Roof_Type__c = csvResponseHandler.Roof_Type;
                                    opp.HVAC_Type__c = csvResponseHandler.HVAC_Type;
                                    opp.Lot_Sq_Ft__c = Integer.valueOf(csvResponseHandler.Lot_Sq_Ft);
                                    opp.HOA__c = csvResponseHandler.HOA;
                                    opp.Pool__c = Boolean.valueOf(csvResponseHandler.Pool);
                                    opp.HOA_Name__c = csvResponseHandler.HOA_Name;
                                    opp.status__c = 'Submit for Underwriting';
                                    opp.CSV_Upload__c = TRUE;
                                    opp.Broker__c = userName;
                                    opp.OwnerId= userName;
                                    opp.RecordTypeId = oppRecordTypeId;
                                    opp.Stage__c = 'Prospect';
                                    opp.Property_Claimed__c = TRUE;                        
                                     if(csvResponseHandler.Offer_Price_Max_Bid == ''){
                                            opp.Broker_Offer_Price__c  = 0;
                                     }else{
                                              opp.Broker_Offer_Price__c = Integer.valueOf(csvResponseHandler.Offer_Price_Max_Bid.trim());
                                    }
                                   if(csvResponseHandler.Market_Value == ''){
                                         opp.Broker_Market_Value__c = 0;
                                    } else{
                                        opp.Broker_Market_Value__c =  Integer.valueOf(csvResponseHandler.Market_Value.trim());
                                    }
                                    
                                   if(csvResponseHandler.Exp_Gross_Mon_Rent == ''){
                                         opp.Broker_Monthly_Rent__c = 0;
                                    } else{
                                        opp.Broker_Monthly_Rent__c =  Integer.valueOf(csvResponseHandler.Exp_Gross_Mon_Rent.trim());
                                    }
                                   if(csvResponseHandler.Initial_Rehab_Bud_Est == ''){
                                         opp.Broker_Rehab__c = 0;
                                    } else{
                                       opp.Broker_Rehab__c =   Integer.valueOf(csvResponseHandler.Initial_Rehab_Bud_Est.trim()); 
                                    }                          
                                    
                                   // If Property Tax Value value null,passing 0
                                   if(csvResponseHandler.Property_Tax_Est == ''){
                                        opp.Broker_Property_Taxes__c = 0;
                                    } else{
                                        opp.Broker_Property_Taxes__c = Integer.valueOf(csvResponseHandler.Property_Tax_Est.trim()); 
                                    }
                                      
                                   // If Closing Value value null,passing 0
                                    if(csvResponseHandler.Closing_Title_Acq_Cost_Est == ''){
                                           opp.Broker_Closing_Title_Fees_Est__c  = 0;
                                    } else{
                                         opp.Broker_Closing_Title_Fees_Est__c = Integer.valueOf(csvResponseHandler.Closing_Title_Acq_Cost_Est.trim());
                                    } 
                                   
									try{
                                       
                                        if((alloppres.get(Apn)) != (Apn)){
                                            
                                            	  insert opp;
                                               
                                        }
                                      } catch(Exception e){
                                        	System.debug(e.getMessage() + ' | ' +  e.getLineNumber());
                                            throw e;
                                            
                                      }
                                       
                                 Address__c addr = new Address__c();
                                            addr.Street__c = csvResponseHandler.Property_Street_Address;
                                            addr.City__c = csvResponseHandler.Property_City;
                                            addr.State__c = nameVsIdState.get(csvResponseHandler.Property_State);
                                            addr.Zip__c = csvResponseHandler.Property_Zip_Code;
                                            addr.County__c = csvResponseHandler.County;
                                       if((csvResponseHandler.Latitude != '') && (csvResponseHandler.Longitude !='')){
                                               addr.Location__latitude__s = decimal.valueOf(csvResponseHandler.Latitude);
                        					   addr.Location__longitude__s = decimal.valueOf(csvResponseHandler.Longitude);
                                             }
                                                             
                                        if(opp.Id != null){
                                            insert addr;
                                           }                                            
                                                                             
                            
                          // To get the Market
                               Zip_code_reference__c zipCodeReference = zipCodeReferenceMap.get(addr.Zip__c);
                               Region__c region = allRegionsByStrings.get(zipCodeReference.Market__c);
                              	
                                               
                          // To update opportunity
                          
                               Acq_Opportunity__c updateOpp = [SELECT Id,Name,APN__c From Acq_Opportunity__c where ID =:opp.Id];
                                
                               Acq_Opportunity__c oppUpdate = new Acq_Opportunity__c(Id=updateOpp.Id);
                               oppUpdate.Address__c = addr.Id;
                               oppUpdate.Market__c = region.Id;
                               oppUpdate.Submarket__c = zipCodeReference.SubMarket__c;
                               oppUpdate.Market2__c = zipCodeReference.Market2__c;
                            if(opp.Id != null){
                               update oppUpdate;
                             }
                                                                  
                           // To create prospect
                            Acq_Prospect__c addPros = new Acq_Prospect__c();
                                 addPros.Opportunity__c = oppUpdate.Id;
                                 addPros.Property_fits_buy_box__c = Boolean.ValueOf(csvResponseHandler.Property_Fits_Buy_Box);
                                 addPros.Property_Validated__c = Boolean.ValueOf(csvResponseHandler.Property_Details_Validated);
                                 addPros.Status__c = 'New';
                               // If market value null,passing 0
                                 if(csvResponseHandler.Market_Value == ''){
                                           addPros.Market_Value_UW__c = 0;
                                  } else {
                                            addPros.Market_Value_UW__c = Integer.valueOf(csvResponseHandler.Market_Value.trim());
                                  }
                                 // If Initial Rehab value null,passing 0 
                                  if(csvResponseHandler.Initial_Rehab_Bud_Est == ''){
                                         addPros.Initial_Rehab_Budget_Estimate__c = 0;
                                    } else{
                                      addPros.Initial_Rehab_Budget_Estimate__c = Integer.valueOf(csvResponseHandler.Initial_Rehab_Bud_Est.trim());
                                    } 
                                 // If Gross Mon Rent value null,passing 0 
                                 if(csvResponseHandler.Exp_Gross_Mon_Rent == ''){
                                          addPros.Expected_Gross_Monthly_Rent_UW__c = 0;
                                    } else{
                                        addPros.Expected_Gross_Monthly_Rent_UW__c = Integer.valueOf(csvResponseHandler.Exp_Gross_Mon_Rent.trim());
                                    }
                                 // If RPC value null,passing 0     
                                if(csvResponseHandler.RPC_Stru_PSF == ''){
                                          addPros.RPC_Structure_PSF_UW__c = 0;
                                    } else{
                                         addPros.RPC_Structure_PSF_UW__c = decimal.valueOf(csvResponseHandler.RPC_Stru_PSF.trim());
                                    }
                                  // If RPC Land value null,passing 0     
                                  if(csvResponseHandler.RPC_Land_Value == ''){
                                           addPros.RPC_Land_Value_UW__c = 0;
                                    } else{
                                         addPros.RPC_Land_Value_UW__c = decimal.valueOf(csvResponseHandler.RPC_Land_Value.trim());
                                    }
                                  // If Pre High Value value null,passing 0                               
                                  if(csvResponseHandler.Previous_High_Value == ''){
                                           addPros.Previous_High_Value__c = 0;
                                    } else{
                                         addPros.Previous_High_Value__c = decimal.valueOf(csvResponseHandler.Previous_High_Value.trim());
                                    }
                                 // If Property Tax Value value null,passing 0
                                   if(csvResponseHandler.Property_Tax_Est == ''){
                                           addPros.Property_Tax_Est_UW__c = 0;
                                    } else{
                                         addPros.Property_Tax_Est_UW__c = decimal.valueOf(csvResponseHandler.Property_Tax_Est.trim());
                                    }
                                 // If Monthly HOA Value value null,passing 0
                                     if(csvResponseHandler.Monthly_HOA == ''){
                                           addPros.Monthly_HOA_UW__c = 0;
                                    } else{
                                         addPros.Monthly_HOA_UW__c = decimal.valueOf(csvResponseHandler.Monthly_HOA.trim());
                                    }   
                                   // If Closing Value value null,passing 0
                                    if(csvResponseHandler.Closing_Title_Acq_Cost_Est == ''){
                                           addPros.Closing_Title_Acq_Cost_Est__c = 0;
                                    } else{
                                        addPros.Closing_Title_Acq_Cost_Est__c = decimal.valueOf(csvResponseHandler.Closing_Title_Acq_Cost_Est.trim());
                                    }  
                                 
                                 
                                 addPros.Entera_ID__c = csvResponseHandler.EnteraID;
                                 if(csvResponseHandler.EnteraID == NULL){
                                      addPros.Entera_Generated__c = FALSE;
                                 } else {
                                      addPros.Entera_Generated__c = TRUE;
                                  }
                                 
                                 addPros.RPC_Structure_Quality__c = csvResponseHandler.RPC_Structure_Qual;
                                 addPros.Market__c = oppUpdate.Market__c;
                                 addPros.Submarket__c = oppUpdate.Submarket__c;
                                 addPros.Address__c = oppUpdate.Address__c;
                                 addPros.IH_Stage__c = 'Prospect';
                                 addPros.IMG_Analyst__c = region.IMG_Analyst__c;
                                 addPros.IMG_Director__c = region.IMG_Director__c;
                                 addPros.SVP_IMG__c = region.SVP_IMG__c;
                                 addPros.OwnerId = region.IMG_Analyst__c;
                                 addPros.HOA_Y_N__c = csvResponseHandler.HOA;
                                 addPros.Bid_Type__c = csvResponseHandler.Bid_Type;
                              if(csvResponseHandler.Monthly_HOA == ''){
                                            addPros.Monthly_HOA_UW__c = 0;
                                 }else{
                                          addPros.Monthly_HOA_UW__c = Integer.valueOf(csvResponseHandler.Monthly_HOA.trim());
                                }
                                                             
                              if(csvResponseHandler.Previous_High_Value_Date == ''){
                                   addPros.Previous_High_Value_Date__c = NULL;
                                }
                                else{
                                    if(csvResponseHandler.EnteraID == NULL){
                                        try{
                                            addPros.Previous_High_Value_Date__c = Date.valueOf(csvResponseHandler.Previous_High_Value_Date);
                                        } catch(exception e){
                                            addPros.Previous_High_Value_Date__c = Date.parse(csvResponseHandler.Previous_High_Value_Date);
                                        }
                                       	   
                                     } else {
                                           addPros.Previous_High_Value_Date__c = Date.parse(csvResponseHandler.Previous_High_Value_Date);
                                     }
                                    
                              }
                                                            
                              
                                if(csvResponseHandler.Offer_Price_Max_Bid == ''){
                                            addPros.Offer_Price_Max_Bid__c = 0;
                                 }else{
                                          addPros.Offer_Price_Max_Bid__c = Integer.valueOf(csvResponseHandler.Offer_Price_Max_Bid.trim());
                                }
                                
                                                                   
                            try{
                                if(oppUpdate.Id != null){
                                    insert addPros;
                                }
                            } catch (Exception e)
                            {
                                System.debug(e.getMessage() + ' | ' +  e.getLineNumber()); 
                                throw e;
                               
                            }    
        		
      	    return addPros;
    }
    
    
    
}