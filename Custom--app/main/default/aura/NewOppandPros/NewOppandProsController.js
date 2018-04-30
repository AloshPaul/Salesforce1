({
    doInit : function(component, event, helper){
        helper.getPickListValuesFromHelper(component, event);
        //helper.getStateList(component, event);
        //To get all the state List
        var action = component.get("c.getState");
        action.setCallback(this, function(data) {
            component.set("v.selectedLookUpRecord", data.getReturnValue());
            });
        $A.enqueueAction(action);
        
    },
    onCheck: function(component, event) {
        var checkvalue=component.find("checkbox").get("v.value"); 
        component.set("v.oppPool",checkvalue);
        var profFit=component.find("prpFit").get("v.value"); 
        component.set("v.prosPropFit",profFit);
        var propVal=component.find("PrpVal").get("v.value"); 
        component.set("v.prosPrpVal",propVal);

    },
	CreateOppPros : function(component, event, helper) {
        
        var bidtype = component.get("v.oppBidTypeSel");
        var bulkDeal = component.get("v.oppBulk");
        var propType = component.get("v.oppPropTypeSel");
        var yrbuilt = component.get("v.oppYrBuilt");
        var bedrooms = component.get("v.oppBed");
        var baths = component.get("v.oppBath");
        var sqFeet = component.get("v.oppSqFt");
        var Park = component.get("v.oppParkSel");
        var Roof = component.get("v.oppRoofSel");
        
        var hvac = component.get("v.oppHvAcSel");  
        var LotSqFt = component.get("v.oppLsqft");
        var hoa = component.get("v.oppHOASel");
        var opPool = component.get("v.oppPool");
        var hoaName = component.get("v.oppHoaName");
        var offMax = component.get("v.offMaxBid");
        var markVal = component.get("v.oppMarketVal");
        var grMonRent = component.get("v.oppGrMonRent");
        var initRTehab = component.get("v.initRehab");
        var propTaxEst = component.get("v.propTax");
        var closingTitCostEst = component.get("v.clsTitEst");
        var rpcQual = component.get("v.prosRPCQual");
        var rpcPsfUW = component.get("v.prosrpcPsfUW");
        var rpcLandUW = component.get("v.prosrpcLand");
        var preHighVal = component.get("v.prosPreHighVal");
        var MonHOA = component.get("v.prosMonHOA");
        var state = component.get("v.selectedValue");
        var SelCounty = component.get("v.selectedCounty");
        var Street = component.get("v.oppStreet");
        var City = component.get("v.oppCity");
        var Zip = component.get("v.oppZip");
        var preDate = component.get("v.prosPreDate");
        var PropFit = component.get("v.prosPropFit");
        var PropVal = component.get("v.prosPrpVal");
        var apn = component.get("v.oppAPN");
        
        //Create object to store all the input values from component
        var CSVResponseHandler = {
            APN: apn,
            Bid_Type :bidtype,
            Bulk_Deal : bulkDeal,
            Property_Type:propType,
            Year_Built:yrbuilt,
            Bedrooms:bedrooms,
            Baths:baths,
            Square_Feet:sqFeet,
            Parking:Park,
            Roof_Type:Roof,
            HVAC_Type:hvac,
            Lot_Sq_Ft:LotSqFt,
            HOA:hoa,
            Pool:opPool,
            HOA_Name:hoaName,
            Offer_Price_Max_Bid:offMax,
            Market_Value:markVal,
            Exp_Gross_Mon_Rent:grMonRent,
            Initial_Rehab_Bud_Est:initRTehab,
            Property_Tax_Est:propTaxEst,
            Closing_Title_Acq_Cost_Est:closingTitCostEst,
            Property_Fits_Buy_Box:PropFit,
            Property_Details_Validated:PropVal,
            RPC_Stru_PSF:rpcPsfUW,
            RPC_Land_Value:rpcLandUW,
            Previous_High_Value:preHighVal,
            Monthly_HOA:MonHOA,
            RPC_Structure_Qual:rpcQual,
            Previous_High_Value_Date:preDate,
            
            Property_Street_Address:Street,
            Property_City:City,
            Property_State:state,
            Property_Zip_Code:Zip,
            County:SelCounty,
            Latitude:'',
            Longitude :''
        };
        
       
     if(helper.validateOppForm(component)){
         // To check all the mandatory values
         if((apn != '') && (Street != '') && (City != '') && (state != '') && (SelCounty != '') &&
          	(bidtype != '') && (baths != '') && (bedrooms != '') && (yrbuilt != '') && (LotSqFt != '') &&
            (propType != '') && (sqFeet != '') && (Park != '') && (Roof != '') && (hoa != '')
           
          ){
               
            var action = component.get("c.createOpportunity");
            action.setParams({
                "csvdata":JSON.stringify(CSVResponseHandler)
            });
            action.setCallback(this,function(response){
                //alert(response.getReturnValue());
                var prosId = response.getReturnValue();
                var stringLen = prosId.length;
                var toastEvent = $A.get("e.force:showToast"); 
               if(stringLen == 18 ){  
                var recId = response.getReturnValue();
                    toastEvent.setParams({
                        "type":"success",
                        "title":"SUCCESS!",
                        "message":"Prospect Created Successfully"
                    });
                    toastEvent.fire();
                    var sObectEvent = $A.get("e.force:navigateToSObject");
                        sObectEvent .setParams({
                        "recordId": recId,
                        "slideDevName": "detail"
                      });
                      sObectEvent.fire();
                }
                else if((response.getReturnValue()) =='Duplicate APN cannot be inserted'){
                    toastEvent.setParams({
                        	"type":"error",
                            "title": "Error",
                            "message": "Duplicate APN cannot be inserted"
                        });
                        toastEvent.fire();
                   
                }
                else if((response.getReturnValue()) =='ERROR'){
                    toastEvent.setParams({
                        	"type":"error",
                            "title": "Error",
                            "message": "Zip Code not found"
                        });
                        toastEvent.fire();
                   
                }
                else {
                    toastEvent.setParams({
                        	"type":"error",
                            "title": "Error",
                            "message": "There was an error saving the record: " + (response.getReturnValue())
                        });
                        toastEvent.fire();
                   
                }
                
            });
            $A.enqueueAction(action);
        }
         else{
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                        	"type":"error",
                            "title": "Error",
                            "message": "Please fill all the mandatory values"
                        });
                        toastEvent.fire();
         }
      }
        
	},
    getCounty1:function(component,event,helper){
       var state = component.get("v.selectedValue");
        
        if(state !='' ){
            component.set('v.disabledPick',false);
            helper.getCOunty(component,state);
        } else {
            component.set('v.disabledPick',true);
            
        }
             

    },
    clickCancel:function(component,event,helper){
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Acq_Prospect__c"
        });
        homeEvt.fire();
    
    }
})