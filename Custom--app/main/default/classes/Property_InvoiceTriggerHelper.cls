/**
 *   Description  :  Helper Class for Trigger_Property_Invoice on Property_Invoice__c Object
 *
 *   Created By Shrinath
 *
 *   Created Date:  11/8/2013k
 *
 *   Revision Logs:  V1.0 - Created
 **/
public without sharing class Property_InvoiceTriggerHelper {

		/*
			Method to populate rehab projected spend
		*/
		public static void populateRehabProjectedSpend( List<Property_Invoice__c> newPropertyInvoice,
												   		Map<Id, Property_Invoice__c> oldMapPropertyInvoice ) {

			Set<String> setGLCodesTypeAdjusted = new Set<String>();
			Set<Id> setRehabIds = new Set<Id>();

			for( Property_Invoice__c piObj : newPropertyInvoice ) {

				if( piObj.GL_Code_Original__c == null ) {
					piObj.GL_Code_Original__c.addError( 'Please enter a value in GL Code' );
				}
				else {
						if( trigger.isInsert || piObj.Rehab_Projected_Spend__c == null ) {
							setRehabIds.add(piObj.Rehab__c);
							setGLCodesTypeAdjusted.add( piObj.GL_Code_Type_Adjusted__c );
						}
				}
			}

			Map<Id, Rehab__c> mapRehab = new Map<Id, Rehab__c>( [ Select RecordType.Name
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

	        	String mapKey = rpsObj.Rehab__c + rpsObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
	        	mapGLCodeToRehabProjectedSpend.put( mapKey, rpsObj );

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

			for( Property_Invoice__c piObj : newPropertyInvoice ) {

			      if( piObj.GL_Code_Original__c != null
			          && piObj.Rehab__c != null
			          && piObj.Rehab_Projected_Spend__c == null ) {

		                String mapKey = piObj.Rehab__c + piObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
				        if( !mapGLCodeToRehabProjectedSpend.containsKey( mapKey ) ) {
							  Rehab__c rehab = mapRehab.get( piObj.Rehab__c );
			        	      GL_Code__c glCodeObj = mapGLCode.get( piObj.GL_Code_Original__c );
			        	      String glCodeTypeAdjusted = GL_Code_Service.getTypeAdjustedGLCode( glCodeObj, rehab );
			        	      GL_Code__c glCodeTypeAdjustedObj = mapGLCodeNameToGLCode.get( glCodeTypeAdjusted.trim().toLowerCase() );

					          mapGLCodeToRehabProjectedSpendToInsert.put( mapKey, new Rehab_Projected_Spend__c( Running_Total__c = 0,
															                                                    Rehab__c = piObj.Rehab__c,
															                                                    GL_Code_Original__c = glCodeTypeAdjustedObj.Id ) );
				        }
			      }
		    }

			insert mapGLCodeToRehabProjectedSpendToInsert.values();
			mapGLCodeToRehabProjectedSpend.putAll( mapGLCodeToRehabProjectedSpendToInsert );

			for( Property_Invoice__c piObj : newPropertyInvoice ) {

				if( piObj.GL_Code_Original__c != null
						&& piObj.Rehab__c != null
						&& piObj.Rehab_Projected_Spend__c == null ) {

	    	            String mapKey = piObj.Rehab__c + piObj.GL_Code_Type_Adjusted__c.trim().toLowerCase();
						if(mapGLCodeToRehabProjectedSpend.containsKey( mapKey ) ) {
							piObj.Rehab_Projected_Spend__c = mapGLCodeToRehabProjectedSpend.get( mapKey ).Id;
						}
				}
			}

	}

	/*
		Method to update rehab projected spend
	*/
	public static void updateRehabProjectedSpend( List<Property_Invoice__c> newPropertyInvoice,
											   	  Map<Id, Property_Invoice__c> oldMapPropertyInvoice ) {


		Set<Id> setRehabProjectedSpendIds = new Set<Id>();
		for( Property_Invoice__c piObj : newPropertyInvoice ) {

			   if( piObj.Rehab_Projected_Spend__c != null
									  &&
									  (
									  	   Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Invoice_Amount__c')
									  	|| Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Rehab_Projected_Spend__c')
									   ) ) {

					if(  trigger.isUpdate && Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Rehab_Projected_Spend__c') ) {
						Id rpsIdOld = oldMapPropertyInvoice.get( piObj.Id ).Rehab_Projected_Spend__c;
						if( rpsIdOld != null ) {
							setRehabProjectedSpendIds.add( rpsIdOld );
						}
					}
					setRehabProjectedSpendIds.add(piObj.Rehab_Projected_Spend__c);

			   }
		}

    	Map<Id, Rehab_Projected_Spend__c> mapRehabProjectedSpends = new Map<Id, Rehab_Projected_Spend__c>(
    	                                                                                                   [Select Id,
    	                                                                                                   		   Actual_Spend_Total__c,
    	                                                                                                   		   Changes_To_Budget__c,
    	                                                                                                   		   Base_Budget_Amount__c,
    	                                                                                                   		   Base_Budget_Reported_Timestamp__c,
    	                                                                                                   		   Running_Total__c,
																											 	   Rehab__c,
																										           GL_Code_Original__c,
																										           Rehab__r.Actual_Spend_Total__c,
																										           Rehab__r.Projected_Spend_Running_Total__c,
																										           Rehab__r.Projected_Spend_Changes_To_Budget__c
																										    From Rehab_Projected_Spend__c
																										    Where Id in: setRehabProjectedSpendIds
																										   ]
    																									  );

		Map<Id, Rehab__c> mapRehabsToUpdate = new map<Id, Rehab__c>();

    	for( Property_Invoice__c piObj : newPropertyInvoice ) {

				if( piObj.Rehab_Projected_Spend__c != null
						  &&
						  	(   Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Invoice_Amount__c')
						  	 || Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Rehab_Projected_Spend__c')) ) {

					if( mapRehabProjectedSpends.containsKey( piObj.Rehab_Projected_Spend__c ) ) {

						Rehab_Projected_Spend__c rpsObj = mapRehabProjectedSpends.get( piObj.Rehab_Projected_Spend__c );
						Rehab__c rehab;

						if( !mapRehabsToUpdate.containsKey( rpsObj.Rehab__c ) ) {
							rehab = new Rehab__c( Id = rpsObj.Rehab__c,
												  Actual_Spend_Total__c = ( rpsObj.Rehab__r.Actual_Spend_Total__c == null ? 0 : rpsObj.Rehab__r.Actual_Spend_Total__c )
												);
						}
						else {
							rehab = mapRehabsToUpdate.get( rpsObj.Rehab__c );
						}

						Decimal invoiceAmount = returnZeroIfInputNull( piObj.Invoice_Amount__c );

						if( trigger.isInsert ) {

							Decimal actualSpendTotal = returnZeroIfInputNull( rpsObj.Actual_Spend_Total__c );
							rpsObj.Actual_Spend_Total__c = actualSpendTotal + invoiceAmount;

							rehab.Actual_Spend_Total__c = returnZeroIfInputNull( rehab.Actual_Spend_Total__c )
																	 + returnZeroIfInputNull( invoiceAmount );

						}
						if( trigger.isUpdate ) {
							Decimal invoiceAmountOld = returnZeroIfInputNull( oldMapPropertyInvoice.get( piObj.Id ).Invoice_Amount__c );

							//if reference Rehab_Projected_Spend__c is changed
							if( Utility.hasFieldChanged( piObj, oldMapPropertyInvoice, 'Rehab_Projected_Spend__c') ) {

								Id rpsIdOld = oldMapPropertyInvoice.get( piObj.Id ).Rehab_Projected_Spend__c;

								if( rpsIdOld != null && mapRehabProjectedSpends.containsKey( rpsIdOld ) ) {

									Rehab_Projected_Spend__c rpsObjOldConnected = mapRehabProjectedSpends.get( rpsIdOld );

									Decimal actualSpendTotal = returnZeroIfInputNull( rpsObjOldConnected.Actual_Spend_Total__c );
									rpsObjOldConnected.Actual_Spend_Total__c = actualSpendTotal - invoiceAmount;
								}

								Decimal actualSpendTotal = returnZeroIfInputNull( rpsObj.Actual_Spend_Total__c );
								rpsObj.Actual_Spend_Total__c = actualSpendTotal + invoiceAmount;

							}
							else {

									Decimal actualSpendTotal = returnZeroIfInputNull( rpsObj.Actual_Spend_Total__c );
									rpsObj.Actual_Spend_Total__c = actualSpendTotal + invoiceAmount - invoiceAmountOld;
							}

							/*
							rehab.Actual_Spend_Total__c = returnZeroIfInputNull( rehab.Actual_Spend_Total__c )
																 + returnZeroIfInputNull( invoiceAmount ) - invoiceAmountOld;
							*/

						}

						//mapRehabsToUpdate.put( rpsObj.Rehab__c, rehab );

					}
			   }
		}

		if( mapRehabProjectedSpends.size() > 0 ) {
			update mapRehabProjectedSpends.values();
		}
		/*
		if( mapRehabsToUpdate.size() > 0 ) {
			update mapRehabsToUpdate.values();
		}
		*/
	}

	private static Decimal returnZeroIfInputNull( Decimal inputVal ) {
    	return ( inputVal == null ? 0 : inputVal );
    }
}