({
	validateOppForm : function(component) {
		 var validOpp = true;
        // Show error messages if required fields are blank
        var allValid = component.find('apn').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        return validOpp;
	},
    getPickListValuesFromHelper : function(component, event) {
        this.getPicklistValuesForProperty(component, 'Property_Type__c');
        this.getBidTyprValuesForProperty(component, 'Bid_Type__c');
        this.getParkingValuesForProperty(component, 'Parking__c');
        this.getRoofValuesForProperty(component, 'Roof_Type__c');
        this.gethvacValuesForProperty(component, 'HVAC_Type__c');
        this.gethoaValues(component, 'HOA__c');
        this.getrpcQualValuesFromPros(component, 'RPC_Structure_Quality__c');
         
        
        
    },
    getPicklistValuesForProperty : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.PropOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    getBidTyprValuesForProperty : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.bidoptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    getParkingValuesForProperty : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.parkOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    getRoofValuesForProperty : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.roofOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    gethvacValuesForProperty : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.hvacOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    gethoaValues : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.hoaOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    getrpcQualValuesFromPros : function(component, type) {
        var picklistAction = component.get("c.getPicklistValues");
        var opts=[];
        picklistAction.setParams({
                "fieldName": type
            }); 
        picklistAction.setCallback(this,function(response){
            for(var i=0;i<response.getReturnValue().length;i++){
                opts.push({
                    class:"optionclass",
                    label:response.getReturnValue()[i],
                    value:response.getReturnValue()[i]
                })
            }
            component.set("v.rpcQualOptions",opts);
        });
        $A.enqueueAction(picklistAction);
    },
    getCOunty : function(component,Selectedstate) {
		var getCounty = component.get("c.getCounty");
        getCounty.setParams({
            'state':Selectedstate
        });
        getCounty.setCallback(this, function(response) {
            if(response.getState() =='SUCCESS'){
               
                var countyData = response.getReturnValue();
                component.set('v.candidateCounty',countyData);
            } 
               
           
        });
     $A.enqueueAction(getCounty);
	}
})