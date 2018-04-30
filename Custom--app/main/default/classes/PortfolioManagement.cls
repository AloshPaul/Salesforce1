/**
    * Apex Class: PortfolioManagement
    * Description:
    * Created By: Sudhir Kr. Jagetiya
    * Created Date: March 20, 2013
    * Last Modified By: Barkha Jain
    * Modified Date: March 28, 2013
    */
public without sharing class PortfolioManagement {

    /*
    static final String PORTFOLIO_OCCUPIED_STATUS_ACQUISITION_VACANT = 'Vacant';
    public static void afterInsert(List<Property__c> newList) {
        createRehabAndListingRecords(newList);
    }
    private static void createRehabAndListingRecords(List<Property__c> newList) {
        Map<Id, Rehab__c> portfolioRehabMap = new Map<Id, Rehab__c>();
        List<Listing__c> listingRecords = new List<Listing__c>();
        List<TIP_Tracking__c> reordListTIP = new List<TIP_Tracking__c>();

        for(Property__c portfolio : newList) {
            if(portfolio.Occupied_Status_Acquisition__c != null &&
                    portfolio.Occupied_Status_Acquisition__c.equalsIgnoreCase(PORTFOLIO_OCCUPIED_STATUS_ACQUISITION_VACANT)) {
                if(portfolio.Residence__c != null) {
                    listingRecords.add(createListing(portfolio.Id, portfolio.Residence__c));
                    portfolioRehabMap.put(portfolio.Id, createRehab(portfolio.Id, portfolio.Residence__c));
                    //***4/5 jdauernheim(Appirio)
                    //since createRehab is called from somewhere else, setting stage here to not interfere with other code
                    For(String PortfolioKey : portfolioRehabMap.keyset()){
                        Rehab__c RehabRec = new Rehab__c();
                        RehabRec = portfolioRehabMap.get(PortfolioKey);
                        RehabRec.Stage__c = 'Re-key Ready';
                    }
                }
            } else {
                reordListTIP.add(createTIP(portfolio.Id, portfolio.Residence__c));
            }
        }

        insert reordListTIP;
        insert portfolioRehabMap.values();

        for(Listing__c listing : listingRecords) {
            listing.Rehab__c = portfolioRehabMap.get(listing.Portfolio__c).Id;
        }
        insert listingRecords;
    }

    public static Rehab__c createRehab(Id portfolioId, Id homeId) {
        Rehab__c rehabRec = new Rehab__c();
        rehabRec.Portfolio__c = portfolioId;
        rehabRec.Home__c = homeId;
      //  rehabRec.Re_Key_Ready__c = true;        //4-5 JD(appirio) per issue documented, this field should not be set & will be removed from object.
        rehabRec.Re_Key_Ready_Date__c = system.Today();
        rehabRec.Stage__c = 'New';
        //@Barkha: T-127726
        rehabRec.Type__c = 'Post-Acquisition';
        return rehabRec;
    }

    public static Listing__c createListing(Id portfolioId, Id homeId) {
        Listing__c listingRec = new Listing__c();
        listingRec.Residence__c = homeId;
        listingRec.Portfolio__c = portfolioId;
        return listingRec;
    }

    private static TIP_Tracking__c createTIP(Id portfolioId, Id homeId) {
        TIP_Tracking__c tipTracking = new TIP_Tracking__c();
        tipTracking.Portfolio__c = portfolioId;
        tipTracking.Residence__c = homeId;
        return tipTracking;
    }
    */

    /* SIR - D-00004782 Code needed to auto create Listing records */
    public static final String PORTFOLIO_OCCUPIED_STATUS_ACQUISITION_VACANT = 'Vacant';

    public static final String REHAB_STAGE_RE_KEY_READY = 'Re-key Ready';

    public static void createRehabAndListingRecords(List<Property__c> newList) {
        Map<Id, Rehab__c> portfolioRehabMap = new Map<Id, Rehab__c>();
        List<Listing__c> listingRecords = new List<Listing__c>();
        List<TIP_Tracking__c> reordListTIP = new List<TIP_Tracking__c>();

        RecordType postAcquisitionRT = [Select Id from RecordType Where SObjectType = 'Rehab__c' And DeveloperName = 'Post_Acquisition' ];

        for(Property__c portfolio : newList) {
        
            //Added by Poonam Bhargava - (D-00017506) - bypass logic for SWAY Market
            if(portfolio.Occupied_Status_Acquisition__c != null &&
                    portfolio.Occupied_Status_Acquisition__c.equalsIgnoreCase(PORTFOLIO_OCCUPIED_STATUS_ACQUISITION_VACANT) && !portfolio.SWAY__c) {
                    if(portfolio.Residence__c != null) {
                        listingRecords.add(createListing(portfolio.Id, portfolio.Residence__c));
                        Rehab__c RehabRec = createRehab(portfolio.Id, portfolio.Residence__c, postAcquisitionRT.Id);
                        RehabRec.Stage__c = REHAB_STAGE_RE_KEY_READY;
                        portfolioRehabMap.put(portfolio.Id, RehabRec);
                    }
			}else {
                    reordListTIP.add(createTIP(portfolio.Id, portfolio.Residence__c));
            }  
        }

        insert reordListTIP;
        insert portfolioRehabMap.values();

        for(Listing__c listing : listingRecords) {
            listing.Rehab__c = portfolioRehabMap.get(listing.Portfolio__c).Id;
        }

        insert listingRecords;

    }

    public static Rehab__c createRehab(Id portfolioId, Id homeId, Id recordTypeId) {
        Rehab__c rehabRec = new Rehab__c();
        rehabRec.Portfolio__c = portfolioId;
        rehabRec.Home__c = homeId;
        rehabRec.Re_Key_Ready_Date__c = system.Today();
        rehabRec.Stage__c = 'New';
        rehabRec.RecordTypeId = recordTypeId;
        return rehabRec;
    }

    public static Listing__c createListing(Id portfolioId, Id homeId) {
        Listing__c listingRec = new Listing__c();
        listingRec.Residence__c = homeId;
        listingRec.Portfolio__c = portfolioId;
        return listingRec;
    }

    private static TIP_Tracking__c createTIP(Id portfolioId, Id homeId) {
        TIP_Tracking__c tipTracking = new TIP_Tracking__c();
        tipTracking.Portfolio__c = portfolioId;
        tipTracking.Residence__c = homeId;
        return tipTracking;
    }
}