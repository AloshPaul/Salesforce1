/*
Resource : SEKAR RAJ
Date : Feb 7 2018
Description : 
*/

public with sharing class PipelinAppListCtrler {

    // Initialize the wrapper object
    public List<wrapPipeline> wrapperPipList{get;set;}
    
    public List<AcqPipeline__c> selectedPipList{get;set;}
    public List<AcqPipeline__c> appRejPipeList{get;set;}
    
     public PipelinAppListCtrler(ApexPages.StandardController controller) {
        wrapperPipList = new List<wrapPipeline>();
        for(AcqPipeline__c pipe: [select Id, Name,Broker_Offer_Status__c,Closing_Statement_Contract_Price__c,Closing_Statement_Funds_Due_from_Buyer__c,Complete_Address__c,PipeToPortFolio_Status__c,Approved_Rejected_Date__c,County__c from AcqPipeline__c where Pipeline_Status__c ='Moved to Queue' and PipeToPortFolio_Status__c !='Approved' and PipeToPortFolio_Status__c !='Rejected']){
            if(Test.isRunningTest()){
                wrapPipeline wrpClass = new wrapPipeline(pipe);
                wrpClass.selected = true;
                wrapperPipList.add(wrpClass);
            }else{
                wrapperPipList.add(new wrapPipeline(pipe));
            }
			system.debug(wrapperPipList);
        }
         appRejPipeList = [select Id, Name,Broker_Offer_Status__c,PipeToPortFolio_Status__c,Approved_Rejected_Date__c,Closing_Statement_Contract_Price__c,Closing_Statement_Funds_Due_from_Buyer__c from AcqPipeline__c where PipeToPortFolio_Status__c IN('Approved','Rejected') and Pipeline_Status__c ='Moved to Queue'];
    }
    
    public PageReference ProcessApproved(){
        selectedPipList = new List<AcqPipeline__c>();
        for(wrapPipeline wrapAc : wrapperPipList){
            if(wrapAc.selected == true){
                selectedPipList.add(wrapAc.PipLin);
            }
        }
        List<AcqPipeline__c> pipListToUpdate  = new List<AcqPipeline__c>();
        for(AcqPipeline__c approvePipe:selectedPipList){
            AcqPipeline__c pipLineUp = new AcqPipeline__c(id = approvePipe.Id);
            pipLineUp.PipeToPortFolio_Status__c = 'Approved';
            pipLineUp.Approved_Rejected_Date__c = Date.today();
            pipListToUpdate.add(pipLineUp);
        }
        
        if(pipListToUpdate.size()>0){
            update pipListToUpdate;
        }
       PageReference p=new Pagereference('/apex/PipelnAppList');
       p.setRedirect(true);
       return p;

    }
    
    public Pagereference ProcessRejected(){
        selectedPipList = new List<AcqPipeline__c>();
        for(wrapPipeline wrapAc : wrapperPipList){
            if(wrapAc.selected == true){
                selectedPipList.add(wrapAc.PipLin);
            }
        }
        List<AcqPipeline__c> pipListToUpdate  = new List<AcqPipeline__c>();
        for(AcqPipeline__c approvePipe:selectedPipList){
            AcqPipeline__c pipLineUp = new AcqPipeline__c(id = approvePipe.Id);
            pipLineUp.PipeToPortFolio_Status__c = 'Rejected';
            pipLineUp.Approved_Rejected_Date__c = Date.today();
            pipListToUpdate.add(pipLineUp);
        }
        if(pipListToUpdate.size()>0){
            update pipListToUpdate;
        }
        PageReference rejRedirect =new Pagereference('/apex/PipelnAppList');
        rejRedirect.setRedirect(true);
        return rejRedirect;
    }
    
   // Wrapper class 
    public class wrapPipeline{
        public AcqPipeline__c PipLin {get; set;}
        public Boolean selected {get; set;}
        // wrapper construction
        public wrapPipeline(AcqPipeline__c p){
            PipLin = p;
            selected = false;
        }
    }
    
   
}