({
	getProspectAddress : function(component, event) {
        console.log("getProspectAddress started");
		var action = component.get("c.getAddressFields");
        action.setParams({
            "acqProspectId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log("Got the response for broker !!");
                component.set("v.broker", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
	},
    getValidatedAddress : function(component, event) {
        console.log('getValidated address started');
		var action = component.get("c.getValidatedAddressFromCallout");
        action.setParams({
            "acqProspectId" : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log("Got the response for validation !!");
                component.set("v.validated", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
	},
    updateAddress : function(component, event) {
        console.log('update validated address address started');
		var action = component.get("c.updateValidatedAddress");
        action.setParams({
            "acqProspectId" : component.get("v.recordId"),
            "validatedAddress" : component.get("v.validated")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                console.log("Got the response for validation address!!");
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
        //Show a toast 
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        //this.toastFunction("success","USPS Address saved");
	},
    toastFunction : function(type, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title" : title
        });
        toastEvent.fire();
    }
})