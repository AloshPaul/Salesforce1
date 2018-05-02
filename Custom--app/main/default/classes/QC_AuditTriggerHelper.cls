/**
 *  Description :   Helper class for Trigger_QC_Audit trigger.
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   03/14/2012
 *
 *  Revision Logs:  V1.0 - Created
 *
 *
 **/
 public without sharing class QC_AuditTriggerHelper {

	// method to reset populate Most Recent PreSignoff QC Audit on rehab
	public static void populateMostRecentPreSignoffQC_Audit( List<QC_Audit__c> listQCAuditNew,
															 List<QC_Audit__c> listQCAuditOld,
									   				   		 Map<ID, QC_Audit__c> mapQCAuditOld ) {

		// query 1 - Pre Signoff QC Audit record type
        List<RecordType> rtList = [ Select Id, Name, SObjectType
		                            From RecordType where Name = '1 - Pre Signoff QC Audit'
		                            And SObjectType = 'QC_Audit__c'
		                           ];
		Id preSignoffRecordTypeId;
		if( rtList.size() > 0 ) {
			preSignoffRecordTypeId = rtList.get(0).Id;
		}

		// when QC_Audit__c has '1 - Pre Signoff QC Audit' record type
	    if( preSignoffRecordTypeId != null ) {

			Map<Id, Rehab__c> mapRehabsToUdpate = new Map<Id, Rehab__c>();
			Set<Id> setIdRehabsToUpdate = new Set<Id>();

	    	// when insert trigger or update trigger
	        if( trigger.isInsert || trigger.isUpdate ) {

		    	// loop over new QC_Audit__c
			    for( QC_Audit__c qcAudit : listQCAuditNew ) {

					// when insert trigger
			        if( trigger.isInsert ) {
			        	if( qcAudit.Rehab__c != null
			        		&& qcAudit.RecordTypeId == preSignoffRecordTypeId ) {
			        		mapRehabsToUdpate.put( qcAudit.Rehab__c,
			        							   new Rehab__c( Id = qcAudit.Rehab__c,
		    													 Most_Recent_Pre_Signoff_QC_Audit__c = qcAudit.Id ));
			        	}
			        }
			        // when update trigger
			        if( trigger.isUpdate ) {
			        	// when RecordTypeId is updated
			        	if( qcAudit.Rehab__c != null
			        		&& Utility.hasFieldChanged( qcAudit, mapQCAuditOld, 'RecordTypeId' )) {
							// when RecordTypeId is updated to '1 - Pre Signoff QC Audit'
			        		if( qcAudit.RecordTypeId == preSignoffRecordTypeId ) {
			        			setIdRehabsToUpdate.add( qcAudit.Rehab__c );
			        		}
			        		// when RecordTypeId is updated from '1 - Pre Signoff QC Audit'
			        		else if( mapQCAuditOld.get(qcAudit.Id).RecordTypeId == preSignoffRecordTypeId ) {
			        			setIdRehabsToUpdate.add( qcAudit.Rehab__c );
			        		}
			        	}
			        }
			   	}
	        }

			// when delete trigger
	   	    if( trigger.isDelete ) {
		        // loop over old QC_Audit__c
				for( QC_Audit__c qcAudit : listQCAuditOld ) {
		   			// when RecordTypeId is '1 - Pre Signoff QC Audit'
		   			if( qcAudit.Rehab__c != null && qcAudit.RecordTypeId == preSignoffRecordTypeId ) {
	        			 setIdRehabsToUpdate.add( qcAudit.Rehab__c );
		        	}
		        }
	   	    }

			// when setIdRehabsToUpdate has items
		   	if( setIdRehabsToUpdate.size() > 0 ) {
		   		// query rehabs
			   	Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>( [Select Id,
			   														  Most_Recent_Pre_Signoff_QC_Audit__c,
			   														  ( Select Id
			   														  	From QC_Audit__r
			   														  	Where RecordTypeId =: preSignoffRecordTypeId
			   														  	Order By CreatedDate DESC LIMIT 1 )
			   														  From Rehab__c
			   														  Where Id in: setIdRehabsToUpdate] );

			    // loop over rehabs
			    for( Rehab__c rehab : mapRehabs.values() ) {
			   		// when rehab has a '1 - Pre Signoff QC Audit' QC Audit record
			   		if( rehab.QC_Audit__r.size() > 0 ) {
			   			mapRehabsToUdpate.put( rehab.Id, new Rehab__c( Id = rehab.Id,
			   														   Most_Recent_Pre_Signoff_QC_Audit__c = rehab.QC_Audit__r.get(0).Id ));
			   		}
			   		// when rehab does not have '1 - Pre Signoff QC Audit' QC Audit record
			   		else if( rehab.Most_Recent_Pre_Signoff_QC_Audit__c != null ) {
			   			mapRehabsToUdpate.put( rehab.Id, new Rehab__c( Id = rehab.Id,
			   														   Most_Recent_Pre_Signoff_QC_Audit__c = null ));
			   		}
			    }
		   	}

	   	    // when mapRehabsToUdpate has items
		    if( mapRehabsToUdpate.size() > 0 ) {
		    	// update mapRehabsToUdpate values
		   		update mapRehabsToUdpate.values();
		    }
	    }
	}
}