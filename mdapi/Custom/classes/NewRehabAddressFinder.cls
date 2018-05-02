/**
 *  Description     :   This class is there for applying jQuery Ajax Seach on address fields based on residences for current logged in user before new
                        rehab record creation and for appling some other validations.
 *
 *  Created By      :   Abhinav Sharma
 *
 *  Created Date    :   07/29/2013
 *
 *  Revision Logs   :   V1.0 - Created
                        V_1.1 - Bhavi Shamra - 03/17/2015 - Code updated for Including the new record type
                        V_1.2 - Abhinav Sharma - 05/01/2015 - D-00013971 - Rehab: Address Finder Page issue
 **/
public with sharing class NewRehabAddressFinder {

    //Rehab Instance
    public Rehab__c rehab {get; set;}

    //Variable to hold the page reference
    Pagereference pageRef;

    //String to hold the selected residence Id
    public String residenceId {get ; set;}
    
    //Abhinav Sharma - 05/01/2015 - D-00013971 - Rehab: Address Finder Page issue
    //String properties for hold the values
    public String propCode {get; set;}
    public String propName {get; set;}
    public String yardiPropCode {get;set;}
    public String residenceAddress {get; set;}

    //String to hold the selected residence street value
    public String residenceAddressStreet {get ; set;}

    //String to hold the Unified string of residence Id with residence street address
    String residenceIdWithStreetAndYardiCode = '';

    //String to hold the Yardi Code Value
    String yardiCodeString = '';

    //Variable to hold the select radio button value
    public string selectedTypeOption {get; set;}
    public Id selectedTypeOptionValue {get; set;}
    //List to hold the select options
    public List<SelectOption> getRehabTypeOptions() {

        //List to hold the Rehab Type Select Options
        List<SelectOption> options = new List<SelectOption>();
        //Adding options in the list for User selection
        for( RecordType rt : [Select Id, DeveloperName, Name
                              From RecordType
                               Where SObjectType = 'Rehab__c'] ) {
            if( !rt.DeveloperName.EqualsIgnoreCase('Expedited_Rehab') ) {
                options.add(new SelectOption(rt.Id , rt.Name));
            }
        }
        return options;
    }

    //Boolean variable going to be helpful in re-rendering
    public boolean isCreateNewRehab {get; set;}

    //Variable to hold the string parameter required for searching
    public String term {
        get {

            //Pass the input text to the search string
            term = ApexPages.currentPage().getParameters().get('term');
            return term;
        }
        set;
    }

    //Method responsible for making column header tiltes
    public String columnTitle {

        get {

            //Variable that return the columns title.
            String columnHeaderTitleString = '';
            columnHeaderTitleString  += '{name:'+'\''+ 'Address Street' +'\''+ ','+ 'width:'+'\'250px\'},'
                                                + '{name:'+'\''+ 'Yardi Property Code' +'\''+ ','+ 'width:'+'\'100px\'},'
                                                + '{name:'+'\''+ 'Property Code' +'\''+ ','+ 'width:'+'\'100px\'},';
            columnHeaderTitleString = '[' + columnHeaderTitleString.removeEnd(',') + ']';
            return columnHeaderTitleString;
        }
    }

    //Method for formatting of matching result for disply on VF Page
    public String result {

        get {

            //Replace special character of the input text according to requirement.
            String searchString = term.replaceAll('\\*','%') + '%';

            /*[['Red', '#f00'], ['Green', '#0f0'], ['Blue', '#00f']];*/ 

            //String to hold the current logged in user region field value
            String loggedInUserRegion = Utility.currentLoggedInUserRegionValue(UserInfo.getUserId());

            //List to hold the eligible residence records going to be diplayed to User according to region field value
            List<Residence__c> residenceList = new List<Residence__c>();

            //Checking for National region User
            if(loggedInUserRegion == Constants.REGION_NATIONAL) {

                System.debug('searchString : ' + searchString);
                //Checking for Search String length value to determine whether we have to search on the basis of Yardi Code or not
                if(searchString.length() >= 7) {

                    //Populating list with the suggestion with both type of search in OR logic
                    residenceList = [SELECT  Name, Address_Street__c, Most_Recent_Rehab__c, Current_Portfolio__r.Yardi_Property_Code__c,
                                            Current_Portfolio__r.Name, Current_Portfolio__r.Property_Code__c
                                        FROM Residence__c WHERE Current_Portfolio__c != null AND Region__c != null
                                        AND (Address_Street__c LIKE : searchString
                                                OR Current_Portfolio__r.Yardi_Property_Code__c LIKE : searchString
                                                OR Current_Portfolio__r.Property_Code__c LIKE :searchString)
                                        ORDER BY Address_Street__c ASC];

                } else {

                    //Populating list with the suggestion with both type of search in OR logic
                    residenceList = [SELECT  Name, Address_Street__c, Most_Recent_Rehab__c, Current_Portfolio__r.Yardi_Property_Code__c,
                                            Current_Portfolio__r.Name, Current_Portfolio__r.Property_Code__c
                                        FROM Residence__c WHERE Current_Portfolio__c != null AND Region__c != null
                                        AND Address_Street__c LIKE : searchString
                                        ORDER BY Address_Street__c ASC];

                }

            } else {

                //Checking for Search String length value to determine whether we have to search on the basis of Yardi Code or not
                if(searchString.length() >= 7) {

                    //Query for residence records for showing the suggestions on the page
                    residenceList = [SELECT Name, Address_Street__c, Most_Recent_Rehab__c, Current_Portfolio__r.Yardi_Property_Code__c,
                                            Current_Portfolio__r.Name, Current_Portfolio__r.Property_Code__c
                                        FROM Residence__c WHERE Current_Portfolio__c != null AND Region__c != null
                                        AND (Address_Street__c LIKE : searchString
                                                    OR Current_Portfolio__r.Yardi_Property_Code__c LIKE : searchString
                                                    OR Current_Portfolio__r.Property_Code__c LIKE :searchString)
                                        ORDER BY Address_Street__c ASC];
                } else {

                    //Query for residence records for showing the suggestions on the page
                    residenceList = [SELECT Name, Address_Street__c, Most_Recent_Rehab__c, Current_Portfolio__r.Yardi_Property_Code__c,
                                            Current_Portfolio__r.Name, Current_Portfolio__r.Property_Code__c
                                        FROM Residence__c WHERE Current_Portfolio__c != null AND Region__c != null
                                        AND Address_Street__c LIKE : searchString
                                        ORDER BY Address_Street__c ASC];

                }
                System.debug('Residence List: ' + residenceList);
            }

            //Loop through list of matched residences
            for(Residence__c residence : residenceList) {

                //Unifiied string having residence Id with residence street
                residenceIdWithStreetAndYardiCode += '"' + residence.Id + '"' + ','
                                                        + '"' + residence.Address_Street__c +  '"' + ','
                                                        + '"' + residence.Current_Portfolio__r.Yardi_Property_Code__c +  '"' + ','
                                                        + '"' + residence.Current_Portfolio__r.Property_Code__c +  '"' + ','
                                                        + '"' + residence.Current_Portfolio__r.Name + '"]';

                //Loop for add  character at end of the string according to Standard JQuery
                if(residenceIdWithStreetAndYardiCode.endsWith(']')) {

                    residenceIdWithStreetAndYardiCode += ',[';
                }
            }

            //Remove character from  end of the string according to Standard JQuery
            residenceIdWithStreetAndYardiCode = residenceIdWithStreetAndYardiCode.removeEnd(',[');
            residenceIdWithStreetAndYardiCode =  '[' + residenceIdWithStreetAndYardiCode;
            residenceIdWithStreetAndYardiCode =  '[ ' + residenceIdWithStreetAndYardiCode + ' ]';

            //Returning
            return residenceIdWithStreetAndYardiCode;
        }
    }

    //Standard Controller
    public NewRehabAddressFinder(ApexPages.StandardController controller) {

        //Get record for Rehab
        rehab = (Rehab__c)controller.getRecord();

        //Setting flag default value
        isCreateNewRehab = false;
        propCode = '';
        propName = '';
        yardiPropCode = '';
        residenceAddress = '';

    }

    //Controller
    public NewRehabAddressFinder() {

        //Setting flag default value
        isCreateNewRehab = false;
    }

    //Method for inserting new rehab with the submitted values
    public void submit() {

        //Create a save point to roll back the transaction in case of exception
        SavePoint sp = database.setSavePoint();

        try {

            //Rehab record Instance
            Rehab__c newRehab = new Rehab__c();

            //Listing record Instance
            Listing__c listing = new Listing__c();
            
            System.debug('$$$$$$$$$$$$$$$' + residenceAddress);

            //Check if user agrees on T&C
            if(selectedTypeOptionValue == null) {

                //Throw an error message
                throw new CustomException(System.label.REHAB_TYPE_SELECTION);

            }

            Map<Id, RecordType> mapRehabRecordType = new Map<Id, RecordType>( [Select Id, Name
                                                                               From RecordType
                                                                               Where SObjectType = 'Rehab__c']
                                                                              );

            if( mapRehabRecordType.containsKey(selectedTypeOptionValue)) {
                selectedTypeOption = mapRehabRecordType.get(selectedTypeOptionValue).Name;
            }
            
            
            //Checking for residence Id value
            if(residenceId != null && residenceId != '') {

                //Populating residence lookup on rehab record
                newRehab.Home__c = ID.valueOf(residenceId);

                //Query for residence records associated with Rehab record
                List<Residence__c> residences = [Select Id, Name, Current_Portfolio__c, Current_Portfolio__r.Yardi_Property_Code__c,
                                                    Most_Recent_Rehab__c, Address_Street__c FROM Residence__c
                                                    WHERE ID =: newRehab.Home__c];
                
                //Check for residencerecords list for null value
                if(residences.size() > 0) {
                    
                    //Getting Residence record value
                    Residence__c residence = residences[0];

                    //Populating string with the field values
                    yardiCodeString = residence.Current_Portfolio__r.Yardi_Property_Code__c;

                    //Populating Portfolio lookup on Rehab record
                    newRehab.Portfolio__c = residence.Current_Portfolio__c;
                    
                    Map<Id, Disposition__c> mapDispostion = new Map<Id, Disposition__c>( [ Select Portfolio__c 
                                                            From Disposition__c
                                                            Where Portfolio__c =: newRehab.Portfolio__c
                                                            And BX_Approval_of_Sale__c = 'Yes'
                                                            And IH_Approval_of_Sale__c = 'Yes'
                                                            ] );
                                                                        
                                                                   
                    Map<Id, Disposition__c> mapPortfolioIdToDispostion = new Map<Id, Disposition__c>();
                    for( Disposition__c dis : mapDispostion.values() ) {
                        mapPortfolioIdToDispostion.put( dis.Portfolio__c, dis );
                    }
                    
                    if( selectedTypeOption == Constants.DISPOSITION && ( !mapPortfolioIdToDispostion.containsKey(newRehab.Portfolio__c)) ) {
                           //Throw an error message
                           throw new CustomException(System.label.Disposition_Rehab_Not_Allowed);
                    }
                    
                    //Checking for Rehab type
                    if( selectedTypeOption == Constants.POST_ACQUISITION_TIP || selectedTypeOption == Constants.TURN || selectedTypeOption == Constants.POST_ACQUISITION || selectedTypeOption == Constants.DISPOSITION) {

                        //Populating Rehab Type value based on Most recent rehab lookup value
                        /*if(residence.Most_Recent_Rehab__c == null) {
                            newRehab.Type__c = Constants.POST_ACQUISITION;
                        } else {
                            newRehab.Type__c = selectedTypeOption;
                        }*/
                        newRehab.RecordTypeId = selectedTypeOptionValue;
                        //Insert New Rehab record
                        insert newRehab;
                        
                        //Populating Listing instance with the values
                        listing.Portfolio__c = residence.Current_Portfolio__c;
                        listing.Residence__c = residenceId;
                        listing.Rehab__c = newRehab.Id;

                        //Insert Listing
                        insert listing;


                    } else if(selectedTypeOption == Constants.REMEDIATION) {

                        //Setting Type field value for Rehab
                        newRehab.RecordTypeId = selectedTypeOptionValue;
                        System.debug('@@@@@ newRehab ' + newRehab);
                        //Insert New Rehab record
                        insert newRehab;
                        
                        //Query for Listing record associated with the residence record
                        List<Listing__c> listings = [Select ID, Residence__c, Rehab_Remediation_Record__c FROM Listing__c WHERE Residence__c = : residenceId];

                        //Listing list going to be update
                        List<Listing__c> listingsGoingToBeUpdate = new List<Listing__c>();

                        //Check for list size
                        if(listings.size()> 0) {

                            //Loop through Listing records
                            for(Listing__c lsting : listings) {

                                //Popualting listing record fields
                                listing = new Listing__c(Id = lsting.ID);
                                listing.Residence__c = lsting.Residence__c;
                                listing.Rehab_Remediation_Record__c = newRehab.ID;

                                //Populate list with the listing records
                                listingsGoingToBeUpdate.add(listing);
                            }

                            //Checking for size of list
                            if(listingsGoingToBeUpdate.size() > 0) {

                                //Update listing
                                update listingsGoingToBeUpdate;
                            }
                        }
                    }
                }

                //Setting flag value as true
                isCreateNewRehab = true;
                
                //Return to Rehab detail page
                pageRef = new Pagereference('/' + newRehab.Id);

                //Adding Message on Page
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Constants.NEW_REHAB_HAVE_BEEN_CREATED +  yardiCodeString + Constants.ADDRESS_STRING + residenceAddressStreet));

            }

            //Checking for non matched values
            else  {

                //Throwing custom exception on the page
                throw new CustomException(System.Label.UNMATCHED_ADDRESS);
            }

        } catch(Exception e) {

           //rollback the entire transaction in case of error
           database.rollBack(sp);

           //add error on page
           ApexPages.addMessages(e);
       }
    }

    //Method for redirecting user to Newly Created Rehab record detail page
    public pagereference redirectToRehabDetailPage() {

        //Checking flag value
        if(isCreateNewRehab) {

            //Return Pagereference of newly created Rehab record
            return pageRef;

        } else {

            //Return null
            return null;
        }
    }
}