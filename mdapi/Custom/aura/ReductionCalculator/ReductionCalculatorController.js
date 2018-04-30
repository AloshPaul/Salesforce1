({
    doInit : function(component, event, helper){
        var recId = component.get("v.recordId");
        var getPros = component.get("c.getProspectValues");
        getPros.setParams({
                "recordId": recId
            });
        getPros.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                var acqPros = response.getReturnValue();
                component.set('v.marketValue',acqPros.Market_Value_UW__c);
                component.set('v.ExGrsMonRent',acqPros.Expected_Gross_Monthly_Rent_UW__c);
                component.set('v.propTax',acqPros.Property_Tax_Est_UW__c);
                component.set('v.monHOA',acqPros.Monthly_HOA_UW__c);
                component.set('v.CostBasis',acqPros.Cost_Basis_Est_UW__c);
                component.set('v.proForma',acqPros.Pro_forma_NOI_UW__c);
                component.set('v.costBasMv',acqPros.Cost_Basis_as_of_MV__c);
                component.set('v.costBasDis',acqPros.Cost_Basis_Discount_to_MV__c );
                component.set('v.capRate',acqPros.Cap_Rate_UW__c);
                
            }
        });
        $A.enqueueAction(getPros);
    },
    
    calculateReduction : function(component, event, helper) {
        var markValue = component.get('v.marketValue');
        var expGrMonRent = component.get('v.ExGrsMonRent');
        var ContPrice = component.get('v.ContPrice');
        var propTax = component.get('v.propTax');
        var monHOA = component.get('v.monHOA');
        
        var recId = component.get("v.recordId");
        
        // To Call reductionCalculator Apex Class updateProspect Method
        var action = component.get("c.calcReduction");
        action.setParams({
                "recordId": recId
            });
            action.setCallback(this,function(response){
                if(response.getState() == 'SUCCESS'){
                    component.set("v.toggleSpinner",true);
                    var markValue1 = component.get('v.marketValue');
                    var expGrMonRent1 = component.get('v.ExGrsMonRent');
                    var propTax1 = component.get('v.propTax');
                    var monHOA1 = component.get('v.monHOA');
                    var redValues = response.getReturnValue();
                    var closingTitCost;
             // To calculate total Income and Fixed Expenses
                    var expGrsAnnRent = expGrMonRent1*12;
                    //alert(expGrsAnnRent + 'annrent');
                    //alert(redValues.Market__r.Occupancy__c+'marOcc');
                    //Stabilized_Vacany_Loss_UW__c  = -1*( Expected_Gross_Annual_Rent_UW__c*(1- Market__r.Occupancy__c))
                    var marOcc = (1-(redValues.Market__r.Occupancy__c));
                    var stabVacLoss = (-1*(expGrsAnnRent*marOcc));
                    // alert(stabVacLoss + 'stab');
                    var rentalInc = expGrsAnnRent + stabVacLoss;
                   // alert(rentalInc + 'renInc');
                    var poolExp ;
                    if(redValues.Pool__c){
                       poolExp = redValues.Market__r.Pool_Exp_Per_Home__c;
                       // alert(poolExp + 'pool');
                    }
                    else {
                        poolExp= 0;
                    }
                    var fixedExpIncPool = (-1*(propTax1 + (monHOA1 *12) + redValues.Annual_Insurance_Est_UW__c+poolExp ));
                   // alert(fixedExpIncPool+'fixdExp');
                    var otherIncBadDebt= (rentalInc * redValues.Market__r.OI_Conc_BD_as_of_RI__c);
                   // alert(otherIncBadDebt+'otherIncBad');
                    var totalRevInc = rentalInc+otherIncBadDebt;
                   // alert(totalRevInc+'totalRev');
                    var effGrsinc = totalRevInc+fixedExpIncPool;
                   // alert(effGrsinc + 'effGrIn2');
                    if(isNaN(redValues.Closing_Title_Acq_Cost_Est__c)){
                        closingTitCost =0;
                    } else{
                        closingTitCost = redValues.Closing_Title_Acq_Cost_Est__c;
                    }
                    
                    var costBasis = redValues.Purchase_Price__c + redValues.Initial_Rehab_Budget_Estimate__c+
                        				closingTitCost+redValues.Capitalized_Acq_Costs_Estimate__c;
                   
                    // alert(costBasis + '.....cost');
                   // Effective_Gross_Income_UW__c = Total_Revenue_UW__c + Fixed_Expenses_Inc_Pool_UW__c;
                   //Total_Revenue_UW__c = Rental_Income_UW__c + Other_Inc_Conc_Bad_Debt_UW__c;
                   //Rental_Income_UW__c = Expected_Gross_Annual_Rent_UW__c + Stabilized_Vacany_Loss_UW__c;
                   //Stabilized_Vacany_Loss_UW__c = -1*( Expected_Gross_Annual_Rent_UW__c*(1- Market__r.Occupancy__c));
                   //Expected_Gross_Annual_Rent_UW__c = Expected_Gross_Monthly_Rent_UW__c * 12;
                   //
                    
                    
                    
                    var effectiveGrsInc = redValues.Total_Revenue_UW__c + redValues.Fixed_Expenses_Inc_Pool_UW__c;
                   // alert(effectiveGrsInc + '.....');
                    var ctrlExp ;
                    var contrlExp = (-1*(redValues.Total_Revenue_UW__c*redValues.Market__r.Control_Pool_Exp__c)); 
                    //alert(contrlExp);
                    if(isNaN(contrlExp)){
                        ctrlExp =0;
                        //alert(ctrlExp);
                    }
                    else{
                        ctrlExp = (-1*(redValues.Total_Revenue_UW__c*redValues.Market__r.Control_Pool_Exp__c));
                   		//alert(ctrlExp);
                    }
                    var dirService; 
                    var dirSharService = (-1*(redValues.Market__r.Direct_SSA_Per_Home__c)); 
                    if(isNaN(dirSharService)){
                        dirService =0;
                        //alert(dirService);
                    }
                    else{
                        dirService = (-1*(redValues.Market__r.Direct_SSA_Per_Home__c)); 
                   		//alert(dirService);
                    }
                    var proForm = effGrsinc+ctrlExp+dirService;
                   
                    var Cost_Basis_MV = ((costBasis / markValue1) * 100).toFixed(2);
                   // alert(Cost_Basis_MV +'.....1');
                    var Cost_Basis_MV1 =(costBasis / markValue1);
                   
                    var CostBasDiscount = ((1-Cost_Basis_MV1)*100).toFixed(2);
                    //var CostBasDiscount = (1-Cost_Basis_MV);
                    var capRa = ((effGrsinc/costBasis)*100).toFixed(2);
                   // alert('Calculating Reduction');
                    component.set('v.CostBasis',costBasis);
                    component.set('v.proForma',proForm);
                    component.set('v.costBasMv',Cost_Basis_MV);
                    component.set('v.costBasDis',CostBasDiscount);
                    component.set('v.capRate',capRa);
                    
                    window.setTimeout($A.getCallback(function(){
                          component.set("v.toggleSpinner", false);                         
                     }),700);
				}
            });
        $A.enqueueAction(action);
       
	},
   
    updateReduction : function(component,event,helper) {
        var markValue1 = component.get('v.marketValue');
        var expGrMonRent1 = component.get('v.ExGrsMonRent');
        var propTax1 = component.get('v.propTax');
        var monHOA1 = component.get('v.monHOA');
        var recId = component.get("v.recordId");
        // To Call reductionCalculator Apex Class updateProspect Method
        var updateRed = component.get("c.updateProspect");
        updateRed.setParams({
                "marketValue":markValue1,
                "expGrsMon":expGrMonRent1,
                "propTaxEst":propTax1,
                "monHoaDet":monHOA1,
                "recordId": recId
            });
         updateRed.setCallback(this,function(response){
             //alert(response.getState());
             var toastEvent = $A.get("e.force:showToast"); 
                if(response.getState() == 'SUCCESS' && (response.getReturnValue() != 'Cancelled / Dead')){
                    toastEvent.setParams({
                        "type":"success",
                        "title":"SUCCESS!",
                        "message":"Prospect Updated Successfully"
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        "type":"warning",
                        "title":"WARNING!",
                        "message":"Can't Update Prospect When Status is Cancelled / Dead"
                    });
                    toastEvent.fire();
                }
             	
            });
        $A.enqueueAction(updateRed);
       
	}
    

})