({
    doInit : function(component, event, helper) {
        helper.getValidatedAddress(component, event);
        helper.getProspectAddress(component, event);
    },
    saveAddress : function(component,event,helper) {
        console.log('On click of save button');
        var type = document.querySelector('input[name="options"]:checked').value;
        console.log('The type is ' + type);
        if(type === 'validated') {
            helper.updateAddress(component, event);
        } else {
			//Leave address as it is.
			helper.toastFunction("success","Original Address saved");
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
    },
    closeMe : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
});