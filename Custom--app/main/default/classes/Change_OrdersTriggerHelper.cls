/**
 *   Description  :  Helper Class for Trigger_Change_Orders on Change_Orders__c Object
 *
 *   Created By Shrinath
 *
 *   Created Date:  08/23/2013
 *
 *   Revision Logs:  V1.0 - Created
 **/
public without sharing class Change_OrdersTriggerHelper {

    // Boolean to remove validation for GL Code Required, It will be false from test method of GLCodeSyncTest class
    public static Boolean validateGLCodeRequired = true;

    /*
        Method to populate rehab projected spend
    */
    public static void populateRehabProjectedSpend( List<Change_Orders__c> newChangeOrders,
                                                    Map<Id, Change_Orders__c> oldMapChangeOrders ) {

        Set<String> setGLCodesTypeAdjusted = new Set<String>();
        Set<Id> setRehabIds = new Set<Id>();

        for( Change_Orders__c coObj : newChangeOrders ) {

            if( coObj.GL_Code_Original__c == null && validateGLCodeRequired ) {
                coObj.GL_Code_Original__c.addError( 'Please enter a value in GL Code' );
            }
            else {
                if( trigger.isInsert || coObj.Rehab_Projected_Spend__c == null ) {
                    setRehabIds.add(coObj.Rehab__c);
                    setGLCodesTypeAdjusted.add( coObj.GL_Code_Type_Adjusted__c );
                }
            }
        }

        Map<Id, Rehab__c> mapRehab = new Map<Id, Rehab__c>( [ Select RecordType.Name,
                                                                     Rehab_Status__c,
                                                                     Hd_Budget_Walk__r.Submit_Date__c               
                                                               From Rehab__c
                                                               Where Id =: setRehabIds
                                                             ]);

        // query rehab projected spend
        List<Rehab_Projected_Spend__c> listRehabProjectedSpends = [Select Id,
                                                                          Rehab__c,
                                                                          GL_Code_Original__c,
                                                                          GL_Code_Type_Adjusted__c
                                                                   From Rehab_Projected_Spend__c
                                                                   Where GL_Code_Type_Adjusted__c in: setGLCodesTypeAdjusted
                                                                   And Rehab__c in: setRehabIds];

        Map<String, Rehab_Projected_Spend__c> mapGLCodeToRehabProjectedSpend = new Map<String, Rehab_Projected_Spend__c>();

        Map<String, Rehab_Projected_Spend__c> mapGLCodeToRehabProjectedSpendToInsert = new Map<String, Rehab_Projected_Spend__c>();

        for( Rehab_Projected_Spend__c rpsObj : listRehabProjectedSpends ) {
            if( rpsObj.GL_Code_Original__c != null && rpsObj.GL_Code_Type_Adjusted__c != null ) {
                String mapKey = rpsObj.Rehab__c + rpsObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
                mapGLCodeToRehabProjectedSpend.put( mapKey, rpsObj );
            }

        }

        Map<String, GL_Code__c> mapGLCodeNameToGLCode = new Map<String, GL_Code__c>();
        // Query GL Codes
        Map<Id, GL_Code__c> mapGLCode = new Map<Id, GL_Code__c>( [ Select Name,
                                                                          GL_Code_Acquisition__c,
                                                                          GL_Code_Turn__c,
                                                                          GL_Code_Acquisition__r.Name,
                                                                          GL_Code_Turn__r.Name
                                                                   From GL_Code__c
                                                                   Where Name !=: Null
                                                                 ]);
        for( GL_Code__c glCodeObj : mapGLCode.values() ) {
            mapGLCodeNameToGLCode.put( glCodeObj.Name.trim().toLowerCase(), glCodeObj );
        }
        
        for( Change_Orders__c coObj : newChangeOrders ) {
              if( coObj.GL_Code_Original__c != null
                  && coObj.Rehab__c != null
                  && coObj.Rehab_Projected_Spend__c == null ) {

                    String mapKey = coObj.Rehab__c + coObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
                    if( !mapGLCodeToRehabProjectedSpend.containsKey( mapKey ) ) {
                          Rehab__c rehab = mapRehab.get( coObj.Rehab__c );
                          // Changes done for SIR D-00014800 
                          Boolean isRehabInProgress = false;
                          if( !RehabProjectedSpendController.stopRPSInsertUpdateRTMSprintChangesPhase2() ) {
                              isRehabInProgress = RehabProjectedSpendController.rehabProjectedSpendRTMSprintChanges() ? false : true;
                              if( !isRehabInProgress ) {
                                    if( rehab.Rehab_Status__c != null 
                                        && rehab.Rehab_Status__c.containsIgnoreCase('In Process')
                                        && rehab.Hd_Budget_Walk__r.Submit_Date__c != null 
                                        && rehab.Hd_Budget_Walk__r.Submit_Date__c <= RehabProjectedSpendController.rtmSprintDate ) {
                                     
                                           isRehabInProgress = true;
                                     }
                              }
                          }        
                                                                    
                          if( isRehabInProgress ) { 
                            
                              GL_Code__c glCodeObj = mapGLCode.get( coObj.GL_Code_Original__c );
    
                              String glCodeTypeAdjusted = GL_Code_Service.getTypeAdjustedGLCode( glCodeObj, rehab );
                              GL_Code__c glCodeTypeAdjustedObj = mapGLCodeNameToGLCode.get( glCodeTypeAdjusted.trim().toLowerCase() );
                              mapGLCodeToRehabProjectedSpendToInsert.put( mapKey, new Rehab_Projected_Spend__c( Running_Total__c = 0,
                                                                                                                Rehab__c = coObj.Rehab__c,
                                                                                                                GL_Code_Original__c = glCodeTypeAdjustedObj.Id ) );
                         }
                    }
              }
        }
        
        if( mapGLCodeToRehabProjectedSpendToInsert.size() > 0 ) {
            insert mapGLCodeToRehabProjectedSpendToInsert.values();
        }
        mapGLCodeToRehabProjectedSpend.putAll( mapGLCodeToRehabProjectedSpendToInsert );
        for( Change_Orders__c coObj : newChangeOrders ) {

            if( coObj.GL_Code_Original__c != null
                    && coObj.Rehab__c != null
                    && coObj.Rehab_Projected_Spend__c == null ) {

                String mapKey = coObj.Rehab__c + coObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
                if(mapGLCodeToRehabProjectedSpend.containsKey( mapKey ) ) {
                    coObj.Rehab_Projected_Spend__c = mapGLCodeToRehabProjectedSpend.get( mapKey ).Id;
                }
            }
        }

    }

    /*
    	// Changes done for SIR D-00014800
        Method to update rehab projected spend
    */
    public static void updateRehab( List<Change_Orders__c> newChangeOrders,
                  	                Map<Id, Change_Orders__c> oldMapChangeOrders) {
    
    
		Set<Id> setRehabIds = new Set<Id>();
		
		List<Change_Orders__c> allowedChangeOrders = new List<Change_Orders__c>();
		
		for( Change_Orders__c coObj : newChangeOrders ) {

               if( coObj.Rehab__c != null
                                      &&
                                      (
                                            Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Amount__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Selected_Approved_Bid__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Change_Order_Type__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab_Projected_Spend__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab__c')
                                       ) ) {
					
                    setRehabIds.add( coObj.Rehab__c );
					allowedChangeOrders.add( coObj );
               }
        }
		
		if( setRehabIds.size() > 0 ) {
			
		
			Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>(
	                                                               [Select Id,
	                                                                       Projected_Spend_Changes_To_Budget__c,
	                                                                       Selected_Bid_Total__c
	                                                                From Rehab__c
	                                                                Where Id in: setRehabIds
	                                                               ]
	                                                              );
	
	        Map<Id, Rehab__c> mapRehabsToUpdate = new map<Id, Rehab__c>();
        
	        for( Change_Orders__c coObj : allowedChangeOrders ) {
	
	                    // when mapRehabs has rehab 
	                    if( mapRehabs.containsKey( coObj.Rehab__c ) ) {
	
	                        Rehab__c rehab = mapRehabs.get( coObj.Rehab__c );
	                        
	                        // when insert trigger context
	                        if( trigger.isInsert ) {
	                            // when Change_Order_Type not equals to "Bid"
	                            if( coObj.Change_Order_Type__c != 'Bid' ) {
	                                rehab.Projected_Spend_Changes_To_Budget__c = returnZeroIfInputNull( rehab.Projected_Spend_Changes_To_Budget__c )
	                                                              + returnZeroIfInputNull( coObj.Amount__c );
	                            }
	                            // when Change_Order_Type not equals "Bid" and Selected_Approved_Bid is True
	                            if( coObj.Change_Order_Type__c == 'Bid' && coObj.Selected_Approved_Bid__c ) {
	                                rehab.Selected_Bid_Total__c = returnZeroIfInputNull( rehab.Selected_Bid_Total__c )
	                                                              + returnZeroIfInputNull( coObj.Amount__c );
	                            }
	                        }
	                        if( trigger.isUpdate ) {
	                            
                                // when Change_Order_Type not equals to "Bid"
                                if( coObj.Change_Order_Type__c != 'Bid' ) {
                                    // when condition was matched earlier
                                    if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c != 'Bid' ) {
                                        rehab.Projected_Spend_Changes_To_Budget__c = returnZeroIfInputNull( rehab.Projected_Spend_Changes_To_Budget__c )
				                                                                      + returnZeroIfInputNull( coObj.Amount__c )
				                                                                      - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );
                                    }
                                    else {
                                            rehab.Projected_Spend_Changes_To_Budget__c = returnZeroIfInputNull( rehab.Projected_Spend_Changes_To_Budget__c )
                                                                          + returnZeroIfInputNull( coObj.Amount__c );
                                    }
                                }
                                // when condition was matched earlier
                                else if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c != 'Bid' ) {

                                    rehab.Projected_Spend_Changes_To_Budget__c = returnZeroIfInputNull( rehab.Projected_Spend_Changes_To_Budget__c )
                                                                  - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );

                                }

                                // when Change_Order_Type equals "Bid" and Selected_Approved_Bid is True
                                if( coObj.Change_Order_Type__c == 'Bid' && coObj.Selected_Approved_Bid__c ) {
                                    // when condition was matched earlier
                                    if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c == 'Bid' && oldMapChangeOrders.get( coObj.Id ).Selected_Approved_Bid__c ) {
                                        rehab.Selected_Bid_Total__c = returnZeroIfInputNull( rehab.Selected_Bid_Total__c )
                                                                       + returnZeroIfInputNull( coObj.Amount__c )
                                                                       - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );
                                    }
                                    else {
                                        rehab.Selected_Bid_Total__c = returnZeroIfInputNull( rehab.Selected_Bid_Total__c )
                                                                       + returnZeroIfInputNull( coObj.Amount__c );

                                    }
                                }
                                // when condition was matched earlier
                                else if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c == 'Bid' && oldMapChangeOrders.get( coObj.Id ).Selected_Approved_Bid__c ) {

                                            rehab.Selected_Bid_Total__c = returnZeroIfInputNull( rehab.Selected_Bid_Total__c )
                                                                           - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );

                                }
                            
	                        }
	                        
	                    	mapRehabsToUpdate.put( rehab.Id, rehab );
	                    }
	               }
	               
	               if( mapRehabsToUpdate.size() > 0 ) {
	               		update mapRehabsToUpdate.values();
	               }	        
		}
        
    }
    
    /*
        Method to update rehab projected spend
    */
    /*
    // Commented the code for : // Changes done for SIR D-00014800
    public static void updateRehabProjectedSpend( List<Change_Orders__c> newChangeOrders,
                                                  Map<Id, Change_Orders__c> oldMapChangeOrders) {

    	
        Set<Id> setRehabProjectedSpendIds = new Set<Id>();
        for( Change_Orders__c coObj : newChangeOrders ) {

               if( coObj.Rehab_Projected_Spend__c != null
                                      &&
                                      (
                                            Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Amount__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Selected_Approved_Bid__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Change_Order_Type__c')
                                         || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab_Projected_Spend__c')
                                       ) ) {

                    if(  trigger.isUpdate && Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab_Projected_Spend__c') ) {
                        Id rpsIdOld = oldMapChangeOrders.get( coObj.Id ).Rehab_Projected_Spend__c;
                        if( rpsIdOld != null ) {
                            setRehabProjectedSpendIds.add( rpsIdOld );
                        }
                    }
                    setRehabProjectedSpendIds.add(coObj.Rehab_Projected_Spend__c);

               }
        }

        Map<Id, Rehab_Projected_Spend__c> mapRehabProjectedSpends = new Map<Id, Rehab_Projected_Spend__c>(
                                                                                                           [Select Id,
                                                                                                                   Changes_To_Budget__c,
                                                                                                                   Base_Budget_Amount__c,
                                                                                                                   Base_Budget_Reported_Timestamp__c,
                                                                                                                   Running_Total__c,
                                                                                                                   Rehab__c,
                                                                                                                   GL_Code_Original__c,
                                                                                                                   Revised_Budget__c,
                                                                                                                   Selected_Bid_Total__c,
                                                                                                                   Rehab__r.Projected_Spend_Running_Total__c,
                                                                                                                   Rehab__r.Projected_Spend_Changes_To_Budget__c,
                                                                                                                   Rehab__r.Selected_Bid_Total__c
                                                                                                            From Rehab_Projected_Spend__c
                                                                                                            Where Id in: setRehabProjectedSpendIds
                                                                                                           ]
                                                                                                          );

        Map<Id, Rehab__c> mapRehabsToUpdate = new map<Id, Rehab__c>();

        for( Change_Orders__c coObj : newChangeOrders ) {


                // when change order is associated with rehab projeccted spend
                if( coObj.Rehab_Projected_Spend__c != null
                          &&
                            (   Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Amount__c')
                                || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Selected_Approved_Bid__c')
                                || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Change_Order_Type__c')
                                || Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab_Projected_Spend__c')
                             )
                                ) {

                    // when mapRehabProjectedSpends has rehab projeccted spend
                    if( mapRehabProjectedSpends.containsKey( coObj.Rehab_Projected_Spend__c ) ) {

                        Rehab_Projected_Spend__c rpsObj = mapRehabProjectedSpends.get( coObj.Rehab_Projected_Spend__c );
                        Rehab__c rehab;

                        if( !mapRehabsToUpdate.containsKey( rpsObj.Rehab__c ) ) {
                            // create rehab instancce
                            rehab = new Rehab__c( Id = rpsObj.Rehab__c,
                                                  Projected_Spend_Running_Total__c = ( rpsObj.Rehab__r.Projected_Spend_Running_Total__c == null ? 0 : rpsObj.Rehab__r.Projected_Spend_Running_Total__c ),
                                                  Projected_Spend_Changes_To_Budget__c = ( rpsObj.Rehab__r.Projected_Spend_Changes_To_Budget__c == null ? 0 : rpsObj.Rehab__r.Projected_Spend_Changes_To_Budget__c ),
                                                  Selected_Bid_Total__c = ( rpsObj.Rehab__r.Selected_Bid_Total__c == null ? 0 : rpsObj.Rehab__r.Selected_Bid_Total__c )
                                                );
                        }
                        else {
                            rehab = mapRehabsToUpdate.get( rpsObj.Rehab__c );
                        }

                        // when insert trigger context
                        if( trigger.isInsert ) {
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
                        if( trigger.isUpdate ) {

                            //if reference Rehab_Projected_Spend__c is changed
                            if( Utility.hasFieldChanged( coObj, oldMapChangeOrders, 'Rehab_Projected_Spend__c') ) {

                                Id rpsIdOld = oldMapChangeOrders.get( coObj.Id ).Rehab_Projected_Spend__c;

                                if( rpsIdOld != null && mapRehabProjectedSpends.containsKey( rpsIdOld ) ) {

                                    Rehab_Projected_Spend__c rpsObjOldConnected = mapRehabProjectedSpends.get( rpsIdOld );

                                    // when Change_Order_Type not equals to "Bid"
                                    if( coObj.Change_Order_Type__c != 'Bid' ) {
                                        rpsObjOldConnected.Changes_To_Budget__c = returnZeroIfInputNull( rpsObjOldConnected.Changes_To_Budget__c )
                                                                      -  ( returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c ) );
                                    }
                                    // when Change_Order_Type not equals "Bid" and Selected_Approved_Bid is True
                                    if( coObj.Change_Order_Type__c == 'Bid' && coObj.Selected_Approved_Bid__c ) {
                                        rpsObjOldConnected.Selected_Bid_Total__c = returnZeroIfInputNull( rpsObjOldConnected.Selected_Bid_Total__c )
                                                                                   -  ( returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c ) );
                                    }
                                }

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
                            else {

                                    // when Change_Order_Type not equals to "Bid"
                                    if( coObj.Change_Order_Type__c != 'Bid' ) {
                                        // when condition was matched earlier
                                        if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c != 'Bid' ) {
                                            rpsObj.Changes_To_Budget__c = returnZeroIfInputNull( rpsObj.Changes_To_Budget__c )
                                                                          + returnZeroIfInputNull( coObj.Amount__c )
                                                                          - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );
                                        }
                                        else {
                                                rpsObj.Changes_To_Budget__c = returnZeroIfInputNull( rpsObj.Changes_To_Budget__c )
                                                                              + returnZeroIfInputNull( coObj.Amount__c );
                                        }
                                    }
                                    // when condition was matched earlier
                                    else if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c != 'Bid' ) {

                                        rpsObj.Changes_To_Budget__c = returnZeroIfInputNull( rpsObj.Changes_To_Budget__c )
                                                                      - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );

                                    }

                                    // when Change_Order_Type equals "Bid" and Selected_Approved_Bid is True
                                    if( coObj.Change_Order_Type__c == 'Bid' && coObj.Selected_Approved_Bid__c ) {
                                        // when condition was matched earlier
                                        if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c == 'Bid' && oldMapChangeOrders.get( coObj.Id ).Selected_Approved_Bid__c ) {
                                            rpsObj.Selected_Bid_Total__c = returnZeroIfInputNull( rpsObj.Selected_Bid_Total__c )
                                                                           + returnZeroIfInputNull( coObj.Amount__c )
                                                                           - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );
                                        }
                                        else {
                                            rpsObj.Selected_Bid_Total__c = returnZeroIfInputNull( rpsObj.Selected_Bid_Total__c )
                                                                           + returnZeroIfInputNull( coObj.Amount__c );

                                        }
                                    }
                                    // when condition was matched earlier
                                    else if( oldMapChangeOrders.get( coObj.Id ).Change_Order_Type__c == 'Bid' && oldMapChangeOrders.get( coObj.Id ).Selected_Approved_Bid__c ) {

                                            rpsObj.Selected_Bid_Total__c = returnZeroIfInputNull( rpsObj.Selected_Bid_Total__c )
                                                                           - returnZeroIfInputNull( oldMapChangeOrders.get( coObj.Id ).Amount__c );

                                    }
                            }
                        }
                    }
               }
        }

        // update projected rehab spends
        if( mapRehabProjectedSpends.size() > 0 ) {
            update mapRehabProjectedSpends.values();
        }
		
    }
	*/
	
    private static Decimal returnZeroIfInputNull( Decimal inputVal ) {
        return ( inputVal == null ? 0 : inputVal );
    }
    
}