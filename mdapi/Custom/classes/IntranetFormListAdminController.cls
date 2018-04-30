/**********************************************************************************
  Apex Class: IntranetFormListAdminController
  CreatedBy : Harshit Jain
  CreatedDate : Feb 19, 2012
  Description: This class is used to show list of form type create by content admin.
                         List will be shown in table with custom pagination 
**********************************************************************************/
public with sharing class IntranetFormListAdminController {
  public Integer selectedPageNumber{get;set;} // Page number of form table
  public IntranetPaginationUtility formPagination{get;set;}
  public list<IntranetFormList__c> formList {get;set;} // form List
  public Integer deleteFormIndex {get;set;}
  
  /***************************************************************
  * Initializes the public member
  ***************************************************************/  
  public IntranetFormListAdminController() {
    formList = new list<IntranetFormList__c>();
    addPaginationOnForm(); 
  }
  
  /***************************************************************
  * Fetch list of all form type(intranetFormList) records 
  * and apply custom pagination to show them in table.
  ***************************************************************/  
  private void addPaginationOnForm() {
    List<IntranetFormList__c> intranetFormList = new List<IntranetFormList__c>();
    formPagination = new IntranetPaginationUtility();
    selectedPageNumber = 1;
    formList.clear();
    for(IntranetFormList__c intranetForm : [Select Id,Name,Active__c From IntranetFormList__c order by Name]) {
      intranetFormList.add(intranetForm);
    }
    if(intranetFormList.size() > 0) {
      formPagination.pageSize = 10;
      List<Object> tempList = formPagination.setPagination(intranetFormList);
      formList = getWrapperList(tempList);
    }
  }
  
  /************************************************************
  * Method to cast object into forms
  ************************************************************/
  private List<IntranetFormList__c> getWrapperList(List<Object> currentList) {
        formList.clear();
    for(Object obj : currentList) {
        formList.add((IntranetFormList__c)obj);
    }
    return formList;
  }
    
  /************************************************************
  * Method to get pagination list of forms
  ************************************************************/
  public PageReference getList() {
    formList = getWrapperList(formPagination.getPage(selectedPageNumber));
    return null;
  }
  
  /***************************************************************
  * Redirect to page where content admin can create new form type
  ***************************************************************/  
  public pageReference createNewForm() {
    return new PageReference('/apex/IntranetCreateFormList');
  }

  /***********************************************************************
  * Delete selected form type if form type has no associated form records
  ***********************************************************************/  
  public pageReference deleteForm() {
    Integer totalAssociatedRecord = [select count() from Intranet_Form__c where Form_Type__c =: formList.get(deleteFormIndex).Id];
    if(totalAssociatedRecord == 0) {
        delete formList.get(deleteFormIndex);
        addPaginationOnForm();
    }else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected Form type has associated records so can\'t be deleted.'));
    }
    return null;
  }

}