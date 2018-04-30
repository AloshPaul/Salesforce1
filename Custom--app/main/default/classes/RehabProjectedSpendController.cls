/**
 *   Description  :  Controller Class for VFP RehabProjectedSpend
 *
 *   Created By Shrinath
 *
 *   Created Date:  08/23/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
public without sharing class RehabProjectedSpendController {

    private Id rehabId;
    public Rehab__c rehab {get;set;}
    public List<RehabProjectedSpendWrapper> listRehabProjectedSpendWrapper {get;set;}
    
    public Boolean isRehabInProgress {get;set;}
    
    // constructor
    public RehabProjectedSpendController() {
        try {
                rehabId = ApexPages.currentPage().getParameters().get('id');
                init();
                // Changes done for SIR D-00014800 
                isRehabInProgress = false;
                if( !stopRPSInsertUpdateRTMSprintChangesPhase2() ) {
                    isRehabInProgress = rehabProjectedSpendRTMSprintChanges() ? false : true;
                    if( !isRehabInProgress ) {
                        if( rehab.Rehab_Status__c != null 
                            && rehab.Rehab_Status__c.containsIgnoreCase('In Process')
                            && rehab.Hd_Budget_Walk__r.Submit_Date__c != null 
                            && rehab.Hd_Budget_Walk__r.Submit_Date__c <= rtmSprintDate ) {
                               isRehabInProgress = true;
                           }
                    }
                }
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    public static Date rtmSprintDate = Date.newInstance( Integer.valueOf(Label.Do_Not_Change_RTM_Sprint3_Year), 
                                                     Integer.valueOf(Label.Do_Not_Change_RTM_Sprint3_Month), 
                                                     Integer.valueOf(Label.Do_Not_Change_RTM_Sprint3_Day)
                                                    );
                                                    
    public static Boolean rehabProjectedSpendRTMSprintChanges() {
        return ( ( Date.today() >  rtmSprintDate ) || test.isRunningTest() );
    }
    
    // Changes done for SIR D-00014800 
    public static Boolean stopRPSInsertUpdateRTMSprintChangesPhase2() {
        return true;
    }
    
    // method to get rehab record
    private Rehab__c getRehabRecord(Id rehabId) {
        // query to fetch rehab
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Rehab__c.FieldSets.RehabProjectedSpend.getFields()) {
            if( ! (    f.getFieldPath().equalsIgnoreCase('Id')
                    || f.getFieldPath().equalsIgnoreCase('Name')
                    || f.getFieldPath().equalsIgnoreCase('Property_Address_c')
                    || f.getFieldPath().equalsIgnoreCase('Projected_Spend_Running_Total__c')) )

            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Rehab_Status__c, Hd_Budget_Walk__r.Submit_Date__c, RecordType.Name, Name, Property_Address__c, Projected_Spend_Running_Total__c FROM Rehab__c Where Id =: rehabId ';
        query += ' LIMIT 1';
        return Database.query(query);
    }

    // method to initialize properties
    public void init() {

        rehab = getRehabRecord(rehabId);

        // show all rehab projected spends for all record types as now only GL Code starting with 126 exists
        // SOQL to fetch Rehab_Projected_Spend__c
        List<Rehab_Projected_Spend__c> listRehabProjectedSpend = [Select Id,
                                                                     GL_Code_Type_Adjusted__c,
                                                                     Running_Total__c,
                                                                     Base_Budget_Amount__c,
                                                                     Changes_To_Budget__c,
                                                                     Base_Budget_Reported_Timestamp__c,
                                                                     Selected_Bid_Total__c,
                                                                     Revised_Budget__c,
                                                                     Actual_Spend_Total__c,
                                                                     Variance_Actual_Spend_to_Selected_Bid__c,
                                                                     Variance_Actual_Spend_to_Base_Budget__c,
                                                                     Variance_Actual_Spend_to_Running_Total__c,
                                                                     Variance_Selected_Bid_to_Base_Budget__c,
                                                                     Comment__c,
                                                                     Seasonal_Item__c
                                                                  From Rehab_Projected_Spend__c
                                                                  Where Rehab__c =: rehab.Id
                                                                  And GL_Code_Type_Adjusted__c !=: NULL
                                                                  Order By CreatedDate Desc];

        /* commented code as right now on production there is only GL codes starting from 126 which needs to be shown for all record type
        List<Rehab_Projected_Spend__c> listRehabProjectedSpend;

        // when rehab record type name is 'Post-Acquisition'
        if( rehab.RecordType.Name == 'Post-Acquisition' ) {
            // SOQL to fetch Rehab_Projected_Spend__c
            listRehabProjectedSpend = [Select Id,
                                             GL_Code_Type_Adjusted__c,
                                             Running_Total__c,
                                             Base_Budget_Amount__c,
                                             Changes_To_Budget__c,
                                             Base_Budget_Reported_Timestamp__c,
                                             Selected_Bid_Total__c,
                                             Revised_Budget__c,
                                             Actual_Spend_Total__c,
                                             Variance_Actual_Spend_to_Selected_Bid__c,
                                             Variance_Actual_Spend_to_Base_Budget__c,
                                             Variance_Actual_Spend_to_Running_Total__c,
                                             Variance_Selected_Bid_to_Base_Budget__c,
                                             Comment__c,
                                             Seasonal_Item__c
                                          From Rehab_Projected_Spend__c
                                          Where Rehab__c =: rehab.Id
                                          And GL_Code_Type_Adjusted__c !=: NULL
                                          And GL_Code_Type_Adjusted__c Like '126%'
                                          Order By CreatedDate Desc];
        }
        else {
                // SOQL to fetch Rehab_Projected_Spend__c
                listRehabProjectedSpend = [Select Id,
                                                 GL_Code_Type_Adjusted__c,
                                                 Running_Total__c,
                                                 Base_Budget_Amount__c,
                                                 Changes_To_Budget__c,
                                                 Base_Budget_Reported_Timestamp__c,
                                                 Selected_Bid_Total__c,
                                                 Revised_Budget__c,
                                                 Actual_Spend_Total__c,
                                                 Variance_Actual_Spend_to_Selected_Bid__c,
                                                 Variance_Actual_Spend_to_Base_Budget__c,
                                                 Variance_Actual_Spend_to_Running_Total__c,
                                                 Variance_Selected_Bid_to_Base_Budget__c,
                                                 Comment__c,
                                                 Seasonal_Item__c
                                          From Rehab_Projected_Spend__c
                                          Where Rehab__c =: rehab.Id
                                          And GL_Code_Type_Adjusted__c !=: NULL
                                          And ( Not GL_Code_Type_Adjusted__c Like '126%' )
                                          Order By CreatedDate Desc];
        }*/

        Map<String, Rehab_Projected_Spend__c> mapGLCodeToRehabProjectedSpend = new Map<String, Rehab_Projected_Spend__c>();
        // loop over rehab projected spends
        for( Rehab_Projected_Spend__c rpsObj : listRehabProjectedSpend ) {

            if( rpsObj.GL_Code_Type_Adjusted__c != null ) {
                String mapKey = String.valueOf(rpsObj.GL_Code_Type_Adjusted__c).trim().toLowerCase();

                if( rpsObj.Base_Budget_Amount__c == null ) {
                    rpsObj.Base_Budget_Amount__c = 0;
                }
                if( rpsObj.Revised_Budget__c == null ) {
                    rpsObj.Revised_Budget__c = 0;
                }
                if( rpsObj.Selected_Bid_Total__c == null ) {
                    rpsObj.Selected_Bid_Total__c = 0;
                }
                // fill mapGLCodeToRehabProjectedSpend
                mapGLCodeToRehabProjectedSpend.put( mapKey, rpsObj );
            }
        }

        listRehabProjectedSpendWrapper = new List<RehabProjectedSpendWrapper>();
        // loop over GLCodeOptions
        for( GL_Code__c glCodeObj : getGLCodeOptions() ) {

            String glCode = glCodeObj.Name;
            String mapKey = String.valueOf(glCode).trim().toLowerCase();

            // when rehab projected spend exists for GL Code
            if( mapGLCodeToRehabProjectedSpend.containsKey(mapKey) ) {
                 listRehabProjectedSpendWrapper.add( new RehabProjectedSpendWrapper( mapGLCodeToRehabProjectedSpend.get(mapKey), rehab ));
            }
            // when rehab projected spend does not exists for GL Code
            else {
                    Boolean addGLcode = true;
                    // show all rehab projected spends for all record types as now only GL Code starting with 126 exists
                    /*
                    // when rehab recordtype name is 'Post-Acquisition'
                    if( rehab.RecordType.Name == 'Post-Acquisition' && glCode.startsWith( '126' ) ) {
                        addGLcode = true;
                    }
                    else if( rehab.RecordType.Name != 'Post-Acquisition' && ( !glCode.startsWith( '126' ) ) ) {
                        addGLcode = true;
                    }
                    */
                    // when addGLcode = True
                    if( addGLcode ) {

                        listRehabProjectedSpendWrapper.add( new RehabProjectedSpendWrapper( new Rehab_Projected_Spend__c( GL_Code_Original__c = glCodeObj.Id,
                                                                                                                          Running_Total__c = 0,
                                                                                                                          Base_Budget_Amount__c = 0,
                                                                                                                          Changes_To_Budget__c = 0,
                                                                                                                          Revised_Budget__c = 0,
                                                                                                                          Selected_Bid_Total__c = 0,
                                                                                                                          Rehab__c = rehab.Id ),
                                                                                                                          rehab ));
                    }
            }
        }

    }

    private static Map<Id, GL_Code__c> mapGLCode = new Map<Id, GL_Code__c>();

    // Method to get all GL Code Options
    private List<GL_Code__c> getGLCodeOptions() {
        // Query GL Codes
        mapGLCode = new Map<Id, GL_Code__c>( [ Select Name,
                                                      GL_Code_Acquisition__c,
                                                      GL_Code_Turn__c,
                                                      GL_Code_Acquisition__r.Name,
                                                      GL_Code_Turn__r.Name
                                               From GL_Code__c
                                               Where Name !=: Null
                                             ]);
        return mapGLCode.values();
    }

    /*
    // Method to picklist options
    public List<String> getPickListOptions(SObject sObjectInstance, String fieldAPIName) {
       List<String> picklistOptions = new List<String>();

       Schema.sObjectType sobjectType = sObjectInstance.getSObjectType();
       Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
       Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
       List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldAPIName).getDescribe().getPickListValues();
       for (Schema.PicklistEntry picklistOption : picklistValues) {
          picklistOptions.add( String.valueOf(picklistOption.getValue()) );
       }
       return picklistOptions;
    }
    */
    // methodd to cancel and return to rehab record
    public Pagereference cancel() {
        return new Pagereference('/' + rehab.Id);
    }

    // methodd to save rehab projected spends
    public void save() {
        try {
                List<Rehab_Projected_Spend__c> listRPSToUpsert = new List<Rehab_Projected_Spend__c>();
                rehab.Projected_Spend_Running_Total__c = 0;
                rehab.Projected_Spend_Base_Budget__c = 0;
                rehab.Projected_Spend_Changes_To_Budget__c = 0;
                rehab.Selected_Bid_Total__c = 0;
                // loop over listRehabProjectedSpendWrapper
                for( RehabProjectedSpendWrapper rpsWrapper : listRehabProjectedSpendWrapper ) {

                    if( rpsWrapper.rehabProjectedSpend.Base_Budget_Amount__c == null ) {
                        rpsWrapper.rehabProjectedSpend.Base_Budget_Amount__c = 0.00;
                    }

                    if(    rpsWrapper.rehabProjectedSpend.Id != null
                        || rpsWrapper.rehabProjectedSpend.Base_Budget_Amount__c > 0
                        || rpsWrapper.rehabProjectedSpend.Base_Budget_Amount__c < 0
                        || rpsWrapper.rehabProjectedSpend.Comment__c != null
                        || rpsWrapper.rehabProjectedSpend.Seasonal_Item__c
                       ) {

                        /*
                        if( rpsWrapper.rehabProjectedSpend.Base_Budget_Amount__c != 0
                            && rpsWrapper.rehabProjectedSpend.Base_Budget_Reported_Timestamp__c == null) {
                            rpsWrapper.rehabProjectedSpend.Base_Budget_Reported_Timestamp__c = Datetime.now();
                        }
                        */

                        listRPSToUpsert.add( rpsWrapper.rehabProjectedSpend );

                    }

                }

                if( listRPSToUpsert.size() > 0 ) {

                    upsert listRPSToUpsert;
                    for( RehabProjectedSpendWrapper rpsWrapper : listRehabProjectedSpendWrapper ) {
                        if( rpsWrapper.rehabProjectedSpend.Id == null ) {
                            rpsWrapper.editBaseBudgetAmount = true;
                        }
                        else {
                            rpsWrapper.editBaseBudgetAmount = false;
                        }
                    }
                }
                init();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private static Decimal returnZeroIfInputNull( Decimal inputVal ) {
        return ( inputVal == null ? 0 : inputVal );
    }

    // inner class for RehabProjectedSpendWrapper
    public class RehabProjectedSpendWrapper {

        public Rehab_Projected_Spend__c rehabProjectedSpend {get;set;}
        public String glCodeTypeAdjusted {get;set;}
        public Boolean editBaseBudgetAmount {get;set;}
        // constructor
        public RehabProjectedSpendWrapper(Rehab_Projected_Spend__c rehabProjectedSpend, Rehab__c rehabObj ) {

            this.rehabProjectedSpend = rehabProjectedSpend;
            this.rehabProjectedSpend.Running_Total__c = returnZeroIfInputNull( rehabProjectedSpend.Running_Total__c );
            this.rehabProjectedSpend.Base_Budget_Amount__c = returnZeroIfInputNull( rehabProjectedSpend.Base_Budget_Amount__c );
            this.rehabProjectedSpend.Changes_To_Budget__c = returnZeroIfInputNull( rehabProjectedSpend.Changes_To_Budget__c );

            this.rehabProjectedSpend.Seasonal_Item__c = ( rehabProjectedSpend.Seasonal_Item__c == null ? false : rehabProjectedSpend.Seasonal_Item__c );
            GL_Code__c glCodeObj = mapGLCode.get( rehabProjectedSpend.GL_Code_Original__c );

            // Type Adjusted GLCode
            this.glCodeTypeAdjusted = rehabProjectedSpend.Id != null ? rehabProjectedSpend.GL_Code_Type_Adjusted__c : GL_Code_Service.getTypeAdjustedGLCode( glCodeObj, rehabObj );

            if( rehabProjectedSpend.Id == null ) {
                this.editBaseBudgetAmount = true;
            }
            else {
                this.editBaseBudgetAmount = false;
            }

            /*
            Datetime baseBudgetReportedTimestampGMT = rehabProjectedSpend.Base_Budget_Reported_Timestamp__c;

            if( baseBudgetReportedTimestampGMT == null
                || baseBudgetReportedTimestampGMT > Datetime.now().addHours( -24 ) ) {
                this.editBaseBudgetAmount = true;
            }
            else {
                this.editBaseBudgetAmount = false;
            }
            */
        }
    }
	
	/*
    // methodd to Recalculate Totals
    public PageReference recalculateTotals() {

        Rehab__c rehabToUpdate = new Rehab__c( Id = rehab.Id );
        // Query Rehab Projected Spends
        Map<Id, Rehab_Projected_Spend__c> mapRPS = new Map<Id, Rehab_Projected_Spend__c>([ Select Id,
                                                                                                Actual_Spend_Total__c,
                                                                                                Selected_Bid_Total__c,
                                                                                                Base_Budget_Amount__c,
                                                                                                Changes_To_Budget__c,
                                                                                                Running_Total__c,
                                                                                                Seasonal_Item__c,
                                                                                                ( Select Amount__c,
                                                                                                         Selected_Approved_Bid__c,
                                                                                                         Change_Order_Type__c,
                                                                                                         Rehab_Projected_Spend__c
                                                                                                  From Change_Orders__r )
                                                                                            From Rehab_Projected_Spend__c
                                                                                            Where Rehab__c =: rehab.Id
                                                                                           ]
                                                                                         );
        // rehab projected spends to update
        Map<Id, Rehab_Projected_Spend__c> mapRehabProjectedSpendToUpdate = new Map<Id, Rehab_Projected_Spend__c>();

        rehabToUpdate.Contains_Seasonal_Items__c = false;
        for( Rehab_Projected_Spend__c rpsObj : mapRPS.values() ) {
            rpsObj.Selected_Bid_Total__c = 0;
            rpsObj.Changes_To_Budget__c = 0;
            for( Change_Orders__c coObj : rpsObj.Change_Orders__r ) {
                 // when Change_Order_Type not equals to "Bid"
                 if( coObj.Change_Order_Type__c != 'Bid' ) {
                     rpsObj.Changes_To_Budget__c = returnZeroIfInputNull( rpsObj.Changes_To_Budget__c )
                                                  + returnZeroIfInputNull( coObj.Amount__c );
                 }
                 // when Change_Order_Type not equals "Bid" and Selected_Approved_Bid is True
                 if( coObj.Change_Order_Type__c == 'Bid' && coObj.Selected_Approved_Bid__c ) {
                     rpsObj.Selected_Bid_Total__c = returnZeroIfInputNull( rpsObj.Selected_Bid_Total__c )
                                                  + returnZeroIfInputNull( coObj.Amount__c );
                 }
            }
            mapRehabProjectedSpendToUpdate.put( rpsObj.Id, rpsObj );

            // when rehab projected spend is Seasonal_Item__c then set Contains_Seasonal_Items__c to true
            rehabToUpdate.Contains_Seasonal_Items__c = rpsObj.Seasonal_Item__c ? rpsObj.Seasonal_Item__c : rehabToUpdate.Contains_Seasonal_Items__c;

        }

        // when mapRehabProjectedSpendToUpdate has items
        if( mapRehabProjectedSpendToUpdate.size() > 0 ) {
            update mapRehabProjectedSpendToUpdate.values();
        }

        AggregateResult[] groupedRPS = [ SELECT SUM(Actual_Spend_Total__c) actualSpendTotal,
                                                SUM(Selected_Bid_Total__c) selectedBidTotal,
                                                SUM(Base_Budget_Amount__c) baseBudgetAmount,
                                                SUM(Changes_To_Budget__c) changesToBudgetTotal,
                                                SUM(Running_Total__c) runningSpendTotal
                                         FROM Rehab_Projected_Spend__c
                                         Where Rehab__c =: rehab.Id
                                        ];

        // update commulative fields on rehab
        rehabToUpdate.Actual_Spend_Total__c = ( groupedRPS[0].get('actualSpendTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS[0].get('actualSpendTotal')) ) : 0;
        rehabToUpdate.Selected_Bid_Total__c = ( groupedRPS[0].get('selectedBidTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS[0].get('selectedBidTotal')) ) : 0;
        rehabToUpdate.Projected_Spend_Base_Budget__c = ( groupedRPS[0].get('baseBudgetAmount') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS[0].get('baseBudgetAmount')) ) : 0;
        rehabToUpdate.Projected_Spend_Changes_To_Budget__c = ( groupedRPS[0].get('changesToBudgetTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS[0].get('changesToBudgetTotal')) ) : 0;
        rehabToUpdate.Projected_Spend_Running_Total__c = ( groupedRPS[0].get('runningSpendTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS[0].get('runningSpendTotal')) ) : 0;

        // update rehab
        update rehabToUpdate;

        // call init method
        init();
        return ApexPages.currentPage();
    }
    */

	// methodd to Recalculate Totals
    public PageReference recalculateTotals() {

		Map<Id, Rehab__c> mapRehabToUpdate = recalculateTotalsForRehabs( new Set<Id> { rehab.Id } );
		// update rehab
        update mapRehabToUpdate.values();

        // call init method
        init();
        return ApexPages.currentPage();
    }
	
    public Map<Id, Rehab__c> recalculateTotalsForRehabs( Set<Id> rehabIds ) {


        AggregateResult[] groupedCOForChangesToBudgetRes = [ SELECT Rehab__c rehabId,
        														 SUM(Amount__c) changesToBudgetTotal
				                                           FROM Change_Orders__c
				                                           Where Rehab__c =: rehab.Id
				                                           And Change_Order_Type__c != 'Bid' 
				                                           Group By Rehab__c
				                                          ];
	                                    
	    Map<Id, AggregateResult> mapRehabIdToAggrResForChangesToBudget = new Map<Id, AggregateResult>();
        for( AggregateResult aggr : groupedCOForChangesToBudgetRes ) {
        	Id rehabRecordId = aggr.get('rehabId') != null ? String.valueOf( aggr.get('rehabId') ) : null;
        	if( rehabRecordId != null ) {
        		mapRehabIdToAggrResForChangesToBudget.put( rehabRecordId, aggr );
        	}
        }
        
	    AggregateResult[] groupedCOForSelectedBidTotalRes = [ SELECT Rehab__c rehabId,
	    														  SUM(Amount__c) selectedBidTotal
				                                           FROM Change_Orders__c
				                                           Where Rehab__c =: rehab.Id
				                                           And Change_Order_Type__c = 'Bid' 
				                                           And Selected_Approved_Bid__c =: True
				                                           Group By Rehab__c
		   		                                          ];
		
		Map<Id, AggregateResult> mapRehabIdToAggrResForSelectedBidTotal = new Map<Id, AggregateResult>();					                                        
        for( AggregateResult aggr : groupedCOForSelectedBidTotalRes ) {
        	Id rehabRecordId = aggr.get('rehabId') != null ? String.valueOf( aggr.get('rehabId') ) : null;
        	if( rehabRecordId != null ) {
        		mapRehabIdToAggrResForSelectedBidTotal.put( rehabRecordId, aggr );
        	}
        }
        
        AggregateResult[] groupedRPSRes = [ SELECT Rehab__c rehabId,
        										SUM(Actual_Spend_Total__c) actualSpendTotal,
                                                SUM(Base_Budget_Amount__c) baseBudgetAmount,
                                                SUM(Running_Total__c) runningSpendTotal
                                         FROM Rehab_Projected_Spend__c
                                         Where Rehab__c =: rehab.Id
                                         Group By Rehab__c
                                        ];

        
        
        Map<Id, AggregateResult> mapRehabIdToAggrResGroupedRPS = new Map<Id, AggregateResult>();
        for( AggregateResult aggr : groupedRPSRes ) {
        	Id rehabRecordId = aggr.get('rehabId') != null ? String.valueOf( aggr.get('rehabId') ) : null;
        	if( rehabRecordId != null ) {
        		mapRehabIdToAggrResGroupedRPS.put( rehabRecordId, aggr );
        	}
        }
        
        Map<Id, Rehab__c> mapRehabsToUpdate = new Map<Id, Rehab__c>();
        for( Id rehabId : rehabIds ) {
	        
	        AggregateResult groupedRPS = mapRehabIdToAggrResGroupedRPS.get( rehabId );
	        AggregateResult groupedCOForChangesToBudget = mapRehabIdToAggrResForChangesToBudget.get( rehabId );
	        AggregateResult groupedCOForSelectedBidTotal = mapRehabIdToAggrResForSelectedBidTotal.get( rehabId );
	        
	        Rehab__c rehabToUpdate = new Rehab__c( Id = rehabId );
	        
	    	// update commulative fields on rehab
	        rehabToUpdate.Actual_Spend_Total__c = ( groupedRPS != null && groupedRPS.get('actualSpendTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS.get('actualSpendTotal')) ) : 0;
	        rehabToUpdate.Projected_Spend_Base_Budget__c = ( groupedRPS != null && groupedRPS.get('baseBudgetAmount') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS.get('baseBudgetAmount')) ) : 0;
	        rehabToUpdate.Projected_Spend_Running_Total__c = ( groupedRPS != null && groupedRPS.get('runningSpendTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedRPS.get('runningSpendTotal')) ) : 0;
	    
	    	// update from change orders
	        rehabToUpdate.Selected_Bid_Total__c = ( groupedCOForSelectedBidTotal != null && groupedCOForSelectedBidTotal.get('selectedBidTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedCOForSelectedBidTotal.get('selectedBidTotal')) ) : 0;
	        rehabToUpdate.Projected_Spend_Changes_To_Budget__c = ( groupedCOForChangesToBudget != null && groupedCOForChangesToBudget.get('changesToBudgetTotal') != null ) ? Decimal.valueOf( String.valueOf( groupedCOForChangesToBudget.get('changesToBudgetTotal')) ) : 0;
	        
	        mapRehabsToUpdate.put( rehabToUpdate.Id, rehabToUpdate );
        }
        return mapRehabsToUpdate;
    }
}