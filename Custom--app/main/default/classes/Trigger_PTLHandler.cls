/*********************************************************************************
 * Name             : Trigger_PTLHandler
 * Created By       : Jennifer Dauernheim(Appirio Consulting)
 * Created Date     : Feb 27, 2014
 * Purpose          : Handles multiple process related to the PTL record
 
***********************************************************************************/
public with sharing class Trigger_PTLHandler {

    public static boolean isTrigger_PTLCalld = false;
    public static Set<String> RehabIds = new Set<String>();
    
    
    
  
/***********************************************************************************
  Handler Method for Before Insert
************************************************************************************/
  public static void onBeforeInsert(List<PTL__c> newPTLList){

  	For(PTL__c PTLRec : NewPTLList){
  		rehabids.add(PTLRec.Rehab__c);
  	}
 
 	if(rehabids.size()>0){
 		UpdatePTLStatus(newPTLList, rehabids);
 	}
  	
  }
  
/***********************************************************************************
  Check for Existing PTL Records and update PTL Status
************************************************************************************/
  public static void UpdatePTLStatus(List<PTL__c> newPTLList, set<String> rehabIDSet){
		List<PTL__c> ExistingPTLs = new List<PTL__c>([select rehab__c, Type__c, ID
														from PTL__c
														where rehab__c in :rehabIDSet]);
														
		//create map of existing PTLs associated by rehab
		map<ID,List<PTL__c>> PTLMap = new map<ID, List<PTL__c>>();
		
		
		if(ExistingPtls.size()>0){
			List<PTL__c> ExistingPTLList = new List<PTL__c>();
			
			for( PTL__c ExistingPTLRec : ExistingPTLs){								//always start out with a clean list
				if(PTLMap.ContainsKey(ExistingPTLRec.Rehab__c)){
					ExistingPTLList = PTLMap.Get(ExistingPTLRec.Rehab__c);
					ExistingPTLList.add(ExistingPTLRec);
				}else{
					ExistingPTLList.add(ExistingPTLRec);
					
				}
				PTLMap.put(ExistingPTLRec.Rehab__c, ExistingPTLList);
			}
			
		}
		
		For( PTL__c PTLRec : newPTLList){
			if(ExistingPTLs.size()>0){
				if(PTLMap.containsKey(PTLRec.Rehab__c)){			//if contains the key then already existing record, type = change order
					PTLRec.Type__c = 'Change Order';
				}else{
					PTLRec.Type__c = 'Initial';						//if not match to key, then no existing record, type = initial
				}
			}else{
				PTLRec.Type__c = 'Initial';							//if no existing ptl records, type = Initial
			}
				
		}

  	
  }	

}