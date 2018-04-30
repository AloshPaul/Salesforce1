/*******************************************************************************************************
 * Name             : reductionCalculator
 * Created By       : SEKAR RAJ
 * Created Date     : Apr 09,2018
 * Purpose          : TO calculate reduction Amount and update relevant prospect  
 * Version			: 1.0 - SEKAR RAJ  
 					  1.1 - SEKAR RAJ -- Updated Prospect and Calclating Reduction Amount                     
***********************************************************************************************************/
public class reductionCalculatorCtrler {
    
/***********************************************************************************
  Method to Calculate Reduction
************************************************************************************/
    @auraEnabled
    public static Acq_Prospect__c getProspectValues(String recordId
                                              ){
        Acq_Budget_Walk__c acqBud = [SELECT id,Name,Prospect_ID__c from Acq_Budget_Walk__c where id=:recordId ];
                                                  
        Acq_Prospect__c acqProsData = [SELECT id,Name,Purchase_Price__c,Initial_Rehab_Budget_Estimate__c,
                                   Closing_Title_Acq_Cost_Est__c,Capitalized_Acq_Costs_Estimate__c,Total_Revenue_UW__c,
                                   Fixed_Expenses_Inc_Pool_UW__c,Market__r.Control_Pool_Exp__c,Market__r.Direct_SSA_Per_Home__c,
                                   Pro_forma_NOI_UW__c ,Cost_Basis_Est_UW__c,Market_Value_UW__c,Cap_Rate_UW__c, Expected_Gross_Monthly_Rent_UW__c,
                                   Property_Tax_Est_UW__c, Monthly_HOA_UW__c,Cost_Basis_as_of_MV__c,Cost_Basis_Discount_to_MV__c,Effective_Gross_Income_UW__c
                                   from Acq_Prospect__c where Id=:acqBud.Prospect_ID__c];   
         
       return acqProsData;
    }
    
    @auraEnabled
    public static Acq_Prospect__c calcReduction(String recordId){
        Acq_Budget_Walk__c acqBud = [SELECT id,Name,Prospect_ID__c from Acq_Budget_Walk__c where id=:recordId ];
                                                  
        Acq_Prospect__c acqPros = [SELECT id,Name,Purchase_Price__c,Initial_Rehab_Budget_Estimate__c,
                                   Closing_Title_Acq_Cost_Est__c,Capitalized_Acq_Costs_Estimate__c,Total_Revenue_UW__c,
                                   Fixed_Expenses_Inc_Pool_UW__c,Market__r.Control_Pool_Exp__c,Market__r.Direct_SSA_Per_Home__c,
                                   Pro_forma_NOI_UW__c ,Cost_Basis_Est_UW__c,Market_Value_UW__c,Cap_Rate_UW__c,Market__r.Occupancy__c,
                                   Market__r.OI_Conc_BD_as_of_RI__c,Annual_Insurance_Est_UW__c,Market__r.Pool_Exp_Per_Home__c,Pool__c
                                   from Acq_Prospect__c where Id=:acqBud.Prospect_ID__c];   
         
       return acqPros;
    }
    
    @auraEnabled
    public static String updateProspect(Integer marketValue,Integer expGrsMon,Integer propTaxEst,Integer monHoaDet,String recordId){
        Acq_Budget_Walk__c acqBud = [SELECT id,Name,Prospect_ID__c,Prospect_ID__r.Status__c from Acq_Budget_Walk__c where id=:recordId];
        Acq_Prospect__c updatePros = new Acq_Prospect__c(
        		Id=acqBud.Prospect_ID__c
        );
        
        updatePros.Market_Value_UW__c = Integer.valueOf(marketValue);
        updatePros.Expected_Gross_Monthly_Rent_UW__c  = Integer.valueOf(expGrsMon);
        updatePros.Property_Tax_Est_UW__c  = Integer.valueOf(propTaxEst);
        updatePros.Monthly_HOA_UW__c = Integer.valueOf(monHoaDet);
        try{
            if(acqBud.Prospect_ID__r.Status__c == 'Cancelled / Dead'){
                return acqBud.Prospect_ID__r.Status__c;
            } else{
                update updatePros;
            	return acqBud.Prospect_ID__r.Status__c;
            }
        	
        }catch(DMLException de){
            System.debug('Error>>>'+ de.getLineNumber()+'>>> '+de.getMessage());
        }                       
        return null;
    }
    
}