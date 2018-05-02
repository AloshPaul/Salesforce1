/**
 *  Description     :   Apex class to hold the logic for "SIR Console v2" functionality.
 *
 *  Created By      :   Bhavi
 *
 *  Created Date    :
 *
 *  Revision Logs   :   V1.0 - Created
 						V1.1 - Bhavi Sharma - 03/18/2014 - Replaced Project Owner field with Development Owner - D-00012065
 						V1.2 - Bhavi Sharma - 03/21/2014 - Change SIR Console V3 to display Status_Composite__c instead of Status__c - BUG-5330
 *
 **/
public with sharing class SIRConsoleController_V3 {

    /*Table Sorting Variables*/

    //Table sorting direction variable (Default sorting direction = 'ASC')
    private String sortDirection = 'ASC';

    //Table sorting expression variable (Default value = 'Severity__c')
    //Sorting Expression Definition:- Sorting Expression variable is there to hold field API Name for which table sorting will be applicable on page.
    private String sortExp = 'Severity__c';

    //String to hold sorting full Expression
    String sortFullExp;

    //Getting and setting sorting expression value on the basis of sorting direction value
    public String sortExpression {
        get {
            return sortExp;
        }
        set {

          //If the column is clicked on then switch between Ascending and Descending modes
          if (value == sortExp) {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
          } else {
                sortDirection = 'ASC';
          }

          //Assign value
          sortExp = value;
        }
    }

    //Method to get sort direction value
    public String getSortDirection() {

        //If column is selected retrun it ascending
        if (sortExpression == null || sortExpression == '') {
            return 'ASC';
        } else {
            return sortDirection;
        }
    }

    //Method to set sort direction value
    public void setSortDirection(String value){
        sortDirection = value;
    }

    // Constructor
    public SIRConsoleController_V3() {
        // Set the dropdown values.
        setUserOptions();
        setSIRStatuses();
        setBugStatuses();
        // Get cookie values.
        getCookies();
    }

    /* SIR Start */
    // Get all SIRs
    public transient List<Issues_New_Feature_Request__c> sirList;
    public Map<Id, List<SI_Bug__c>> mapChildBugs {get; set;}

    public List<Issues_New_Feature_Request__c> getSirList() {
        sirList = new List<Issues_New_Feature_Request__c>();

        //Building full sort expression with sorting order 'ASC' & 'DESC' with 'NULLS LAST'
        sortFullExp = sortExpression  + ' ' + sortDirection + ' ' + 'NULLS LAST';

        //Checking for User selected preferences
        if(selectedSIRstatus != null && selectedSIRstatus.size() > 0
            && selectedUserIds != null && selectedUserIds.size() > 0) {

            //Create a set of Parent SIR, where selected user is not assigned, but selected user is in the Child SIRs
            Set<Id> relatedParentSIRIds = new Set<Id>();

            //Loop through
            for(Issues_New_Feature_Request__c cSIR : [Select Id, Parent_SIR__c from Issues_New_Feature_Request__c
                                                        where Parent_SIR__c != null AND Development_Owner__c IN: selectedUserIds AND Status__c IN: selectedSIRstatus]) {

                 //Add in set
                 relatedParentSIRIds.add(cSIR.Parent_SIR__c);
            }

            //String to hold the dynamic query
            String sOQLQueryForSIR = 'Select Type__c, Task_Owner__c, Task_Name__c, System_Category__c, Status__c, Status_Composite__c, Smoke_Test__c, Short_Description__c,'
                                            + ' Severity__c, Root_Cause__c, Rollout__c, Rollout__r.Name, Reviewer__c, Review_Notes__c, Resolution__c,'
                                            + ' Required_Completion_Date__c, Release_Notes__c, Project__c, Project_Owner__r.Name, Development_Owner__c, Development_Owner__r.Name,'
                                            + ' Parent_SIR__c, OwnerId, Next_Action__c, Name, Implementation_Approach__c, Hours_to_Complete_Estimated__c,'
                                            + ' Hours_to_Complete_Actual__c, Development_Phase__c, Development_Environment__c, Description__c,'
                                            + ' Date_Submitted_for_Review__c, Date_Put_On_Hold__c, Date_In_Process__c, Date_Estimated_Completion__c,'
                                            + ' Date_Declined__c, Date_Completed__c, Date_Assigned__c, CreatedDate, CreatedById, Collaborator_2__c,'
                                            + ' Collaborator_1__c, ChildObject__c, Actual_Rollout__c, LastModifiedDate';

            //Checking for Bug status valus
            if(selectedBugstatus != null && selectedBugstatus.size() > 0) {

                //Appending Inline Bug list query string literal in SOQL string
                sOQLQueryForSIR = sOQLQueryForSIR + ' , (' + 'Select Id, Name, Summary__c, Type__c, System_Issue_Report__c, Assigned_To__c, Assigned_To__r.Name,'
                            + ' Status__c from Bugs__r where Assigned_To__c IN ' + quotedString(selectedUserIds)
                            + ' AND Status__c IN ' + quotedString(selectedBugstatus) + ')';
            } else {

                //Appending Inline Bug list query string literal in SOQL string
                sOQLQueryForSIR = sOQLQueryForSIR + ' , (' + 'Select Id, Name, Summary__c, Type__c, System_Issue_Report__c, Assigned_To__c, Assigned_To__r.Name,'
                            + ' Status__c from Bugs__r where Assigned_To__c IN ' + quotedString(selectedUserIds)
                            + ' AND Status__c = null )';
            }

            //Adding the trailer part to the SOQL String
            sOQLQueryForSIR  = sOQLQueryForSIR + ' FROM Issues_New_Feature_Request__c'
                + ' WHERE (Development_Owner__c IN ' + quotedString(selectedUserIds)
                + ' AND Status__c IN ' + quotedString(selectedSIRstatus)
                + ')';

            //Processing and applying further validations over SOQL String
            sOQLQueryForSIR = processSOQLQueryString(sOQLQueryForSIR);

            //Database query for getting eligible SIR records
            sirList = Database.query(sOQLQueryForSIR + ' ORDER BY ' + sortFullExp + ' LIMIT 1000');

        }

        //Checking for SIR List for size value
        if(sirList.size() > 0) {

            //Set to hold the child Sir
            Set<Id> childSIRsIds = new Set<Id>();

            //Instantiate child BUG Map
            mapChildBugs = new Map<Id, List<SI_Bug__c>>();

            for(Issues_New_Feature_Request__c sIR : sirList) {

                //Loop through the Child SIRs
                for(Issues_New_Feature_Request__c cSIR : sIR.Child_SIRs__r) {

                    //Populate Set
                    childSIRsIds.add(cSIR.Id);
                    mapChildBugs.put(cSIR.Id, new List<SI_Bug__c>());
                }
            }


            //Query bugs records
            for(SI_Bug__c bug : [Select Id, Name, Summary__c, Type__c, System_Issue_Report__c, Assigned_To__c, Assigned_To__r.Name, Status__c from SI_Bug__c
                                    where Assigned_To__c in :selectedUserIds AND Status__c in :selectedBugstatus AND System_Issue_Report__c IN: childSIRsIds
                                        AND System_Issue_Report__c != null]) {

                //Add data in Map
                mapChildBugs.get(bug.System_Issue_Report__c).add(bug);
            }

            //Populate Child BUGs map
            //childBugs = new Map<Id, List>
        }

        return sirList;

    }

    /* SIR end */

    /* BUGs Start */
    // Get all Bugs
    public transient List<SI_Bug__c> bugList;
    public List<SI_Bug__c> getBugList() {
        bugList = new List<SI_Bug__c>();
        bugList = [Select System_Issue_Summary__c, System_Issue_Rollout__c, System_Issue_Report__c, System_Issue_Number__c, Type__c,
                            Summary__c, Status__c, Sandbox__c, Resolution__c, Name, LastModifiedDate, System_Issue_Report__r.Name,
                            LastModifiedById, How_To_Reproduce__c, Description__c, CreatedDate, CreatedById, Assigned_To__c, Assigned_To__r.Name
                        from    SI_Bug__c
                        where   Assigned_To__c in :selectedUserIds
                        and     Status__c in :selectedBugstatus
                        order by CreatedDate desc
                        limit 1000];

        return bugList;
    }

    /* BUGs END */

    /* Tasks Start  */
    // Get all Tasks
    public transient List<Task> taskList;
    public List<Task> getTaskList() {
        taskList = new List<Task>();

        // Get the prefix for SIR.
        String sirKeyPrefix = Schema.SObjectType.Issues_New_Feature_Request__c.getKeyPrefix();
        for(Task tsk : [Select WhoId, WhatId, Task_Name__c, Status, SIR_Status__c, SIR_ID__c, Required_Completion_Date__c,
                                Project__c, Priority, OwnerId, Owner.Name, LastModifiedDate, LastModifiedById, IsClosed, Type,
                                Development_Phase__c, Description, ActivityDate, Subject, AccountId
                        from    Task
                        where   OwnerId in :selectedUserIds
                        and     Status not in ('Completed', 'Unable to Complete')
                        and     WhatId != null
                        order by ActivityDate desc
                        limit 1000]) {
            // Check if the Task is related to a SIR.
            String whatId = tsk.WhatId;
            if(whatId.startsWith(sirKeyPrefix))
                taskList.add(tsk);
        }
        return taskList;
    }

    /* Tasks END */

    /* User Filter Start */
    public List<SelectOption> userOptions {get; private set;}
    public List<String> selectedUserIds {get; set;}

    // Set the User dropdowns
    public void setUserOptions() {
        if(userOptions == null) {
            userOptions = new List<SelectOption>();
            selectedUserIds = new List<String>();
            // Get all the users from the Custom Settings.
            for(SIR_Console_User__c consoleUser : SIR_Console_User__c.getAll().values()) {
                userOptions.add(new SelectOption(consoleUser.Name, consoleUser.User_Name__c));
            }
        }
    }
    /* User Filter End */

    /* SIR Status Filter Start */
    public List<SelectOption> sirStatusOptions {get; private set;}
    public List<String> selectedSIRstatus {get; set;}

    // Set the SIR Status
    public void setSIRStatuses() {
        if(sirStatusOptions == null) {
            sirStatusOptions = new List<SelectOption>();
            selectedSIRstatus = new List<String>();
            // Get SIR Picklist values.
            for(PicklistEntry pe : Issues_New_Feature_Request__c.Status__c.getDescribe().getPicklistValues()) {
                sirStatusOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
    }
    /* SIR Status Filter End */

    /* Bugs Status Filter Start */
    public List<SelectOption> bugStatusOptions {get; private set;}
    public List<String> selectedBugstatus {get; set;}

    // Set the Bug Status
    public void setBugStatuses() {
        if(bugStatusOptions == null) {
            bugStatusOptions = new List<SelectOption>();
            selectedBugstatus = new List<String>();
            // Get Bug Picklist Values.
            for(PicklistEntry pe : SI_Bug__c.Status__c.getDescribe().getPicklistValues()) {
                bugStatusOptions.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
    }
    /* Bugs Status Filter end */

    public void filterData() {
        setCookies();
        sirList = null;
        bugList = null;
        taskList = null;
    }

    /* Cookie Handler */
    // Get the Cookie values if any existing.
    public void getCookies() {
        String selectedIds = getCookieVal('userCookie');
        if(selectedIds != null && selectedIds != '') {
            selectedUserIds = selectedIds.split(',');
        }

        String selectedSIRstatuses = getCookieVal('sirCookie');
        if(selectedSIRstatuses != null && selectedSIRstatuses != '') {
            selectedSIRstatus = selectedSIRstatuses.split(',');
        }

        String selectedBugstatuses = getCookieVal('bugCookie');
        if(selectedBugstatuses != null && selectedBugstatuses != '') {
            selectedBugstatus = selectedBugstatuses.split(',');
        }
    }

    // Set the Cookies.
    public void setCookies() {
        String selectedIds = '';
        if(selectedUserIds != null && selectedUserIds.size() > 0) {
            for(String str : selectedUserIds) {
                if(selectedIds != null && selectedIds != '') selectedIds += ',';
                selectedIds += str;
            }
        }
        Cookie userCookie = new Cookie('userCookie', selectedIds, null, 315569260, false);

        String selectedSIRstatuses = '';
        if(selectedSIRstatus != null && selectedSIRstatus.size() > 0) {
            for(String str : selectedSIRstatus) {
                if(selectedSIRstatuses != null && selectedSIRstatuses != '') selectedSIRstatuses += ',';
                selectedSIRstatuses += str;
            }
        }
        Cookie sirCookie = new Cookie('sirCookie', selectedSIRstatuses, null, 315569260, false);

        String selectedBugstatuses = '';
        if(selectedBugstatus != null && selectedBugstatus.size() > 0) {
            for(String str : selectedBugstatus) {
                if(selectedBugstatuses != null && selectedBugstatuses != '') selectedBugstatuses += ',';
                selectedBugstatuses += str;
            }
        }
        Cookie bugCookie = new Cookie('bugCookie', selectedBugstatuses, null, 315569260, false);

        ApexPages.currentPage().setCookies(new Cookie[]{userCookie, sirCookie, bugCookie});
    }

    private String getCookieVal(String cookieName) {
        String cookieVal = '';
        Cookie cookie;
        cookie = ApexPages.currentPage().getCookies().get(cookieName);
        if(cookie != null)
            cookieVal = cookie.getValue();
        return cookieVal;
    }

    public PageReference createNewSir() {
        String sirKeyPrefix = Schema.SObjectType.Issues_New_Feature_Request__c.getKeyPrefix();
        PageReference sirNewPage = new PageReference('/' + sirKeyPrefix + '/e?retURL=' + URL.getCurrentRequestUrl().toExternalForm());
        sirNewPage.setRedirect(true);
        return sirNewPage;
    }
    /* END cookie Handler */

    /*Utility Method (Will moved to Utility class in future)*/
    //Method to convert a string list into a quoted, comma separated String literal for inclusion in a dynamic SOQL Query
    private String quotedString(List<String> parametersStringList) {

        //String to hold the new quoted comma seperated string value
        String newQuotedStr = '' ;

        //Checking string for null and blank value
        if(parametersStringList != null && parametersStringList.size() > 0) {

            //Loop through string list
            for(String myStr : parametersStringList) {

                //Converting string into quoted string
                newQuotedStr += '\'' + myStr + '\',';
            }
        }

        //Removing comma from the last (if any)
        newQuotedStr = newQuotedStr.lastIndexOf(',') > 0 ? '(' + newQuotedStr.substring(0,newQuotedStr.lastIndexOf(',')) + ')' : newQuotedStr ;

        //Returning quoted string
        return newQuotedStr;
    }

    /*Processing and validation SOQL String literal*/
    private string processSOQLQueryString(String sOQLString) {

        //String to hold the sOQLQuery String
        String sOQLQueryForsObject;

        //Trim String
        sOQLQueryForsObject = sOQLString.trim();

        //If query ends with 'AND'
        if(sOQLQueryForsObject.endsWith('AND')) {

            //fetching the value in between two 'AND's
            sOQLQueryForsObject = sOQLQueryForsObject.subString(0, sOQLQueryForsObject.lastIndexOf('AND'));
        }

        //If  the query ends with 'WHERE' i.e. unfilled values
        if(sOQLQueryForsObject.endsWith('WHERE')){

            //fetching the value in between two 'WHERE's
            sOQLQueryForsObject = sOQLQueryForsObject.subString(0, sOQLQueryForsObject.lastIndexOf('WHERE'));

        }

        //Return string
        return sOQLQueryForsObject;
    }
}