/**
 *  Description :   Helper class for Trigger_HD_Budget_Walk trigger.
 *
 *  Created By  :   Shrinath Sharma
 *
 *  Created Date:   07/06/2012
 *
 *  Revision Logs:  V1.0 - Created
 *
 *
 **/
public without sharing class HD_Budget_WalkTriggerHelper {

    private static final String HD_BUDGET_WALK_STATUS_SUBMITTED = 'Submitted';
    private static final String HD_BUDGET_WALK_STATUS_APPROVED = 'Approved';

    //method to reset Photos_Uploaded_Before_Rehab__c and Photos_Uploaded_After_Rehab__c
    public static void resetRehabPhotosUploadedFields( List<HD_Budget_Walk__c> listHdBudgetWalkNew,
                                                       Map<ID, HD_Budget_Walk__c> mapHdBudgetWalkOld ) {

        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {
            //set Photos_Uploaded_Before_Rehab__c to false if Revised_Budget__c is changed
            if(hdBudgetWalk.Revised_Budget__c != mapHdBudgetWalkOld.get(hdBudgetWalk.id).Revised_Budget__c) {
                 hdBudgetWalk.Photos_Uploaded_Before_Rehab__c = false;
            }
        }
    }


    //method to populate HD Budget Walk
    public static void populateHDBudgetWalkOnRehab( List<HD_Budget_Walk__c> listHdBudgetWalkNew ) {
        MAP<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>();
        MAP<Id, Rehab__c> mapRehabsToUpdate = new Map<Id, Rehab__c>();
        //loop over HD Budget Walk
        for( HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew ) {

            if( hdBudgetWalk.Rehab__c != null) {
                //fill map
                mapRehabsToUpdate.put( hdBudgetWalk.Rehab__c, new Rehab__c( Id = hdBudgetWalk.Rehab__c,
                                                                            HD_Budget_Walk__c = hdBudgetWalk.Id
                                                                            )
                                      );

            }

        }

        //update rehabs
        if(mapRehabsToUpdate.size() > 0) {
            update mapRehabsToUpdate.values();
        }
    }

    //update rehab , pipeline and rehab on status changed to Submitted Or Approved
    public static void updateOnSubmittedOrApproved(List<HD_Budget_Walk__c> listHdBudgetWalkNew,
                                                   Map<ID, HD_Budget_Walk__c> mapHdBudgetWalkOld) {

        Set<ID> setPipelineIds = new Set<Id>();
        Set<ID> setProspectIds = new Set<Id>();

        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {
            setPipelineIds.add(hdBudgetWalk.Pipeline__c);
            setProspectIds.add(hdBudgetWalk.Prospect__c);
        }

        //Get non converted pipelines associated with HD BUdget Walks
        Map<Id, Property_Opportunity__c> mapNotConvertedPipelines = new Map<Id, Property_Opportunity__c>( [Select
                                                                                                         Id,
                                                                                                         IsConverted__c
                                                                                                         From Property_Opportunity__c
                                                                                                         Where Id in: setPipelineIds
                                                                                                         And IsConverted__c =: FALSE
                                                                                                         ] );

        //Get non converted prospects associated with HD BUdget Walks
        Map<Id, Prospect__c> mapNotConvertedProspect = new Map<Id, Prospect__c>( [Select Id,
                                                                               IsConverted__c
                                                                               From Prospect__c
                                                                               Where Id in: setProspectIds
                                                                               And IsConverted__c =: FALSE
                                                                              ] );


        Map<Id, Rehab__c> mapRehabsToUpdate = new Map<Id, Rehab__c>();
        Map<Id, Property_Opportunity__c> mapPipelinesToUpdate = new Map<Id, Property_Opportunity__c>();
        Map<Id, Prospect__c> mapProspectsToUpdate = new Map<Id, Prospect__c>();

        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {
            //if status is changed
            if(Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Status__c')) {

                if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_SUBMITTED || hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_APPROVED) {

                    if(hdBudgetWalk.Rehab__c != null
                        && (!mapRehabsToUpdate.containsKey(hdBudgetWalk.Rehab__c))
                        ) {
                        Rehab__c rehab = updateRehab(hdBudgetWalk);
                        mapRehabsToUpdate.put(hdBudgetWalk.Rehab__c, rehab);
                    }

                    if(hdBudgetWalk.Pipeline__c != null
                         && ( mapNotConvertedPipelines.containsKey(hdBudgetWalk.Pipeline__c) )
                         && (!mapPipelinesToUpdate.containsKey(hdBudgetWalk.Pipeline__c))
                        ) {
                        Property_Opportunity__c pipeline = updatePipeline(hdBudgetWalk);
                        mapPipelinesToUpdate.put(pipeline.Id, pipeline);
                    }

                    if(hdBudgetWalk.Prospect__c != null
                        && ( mapNotConvertedProspect.containsKey(hdBudgetWalk.Prospect__c) )
                        && (!mapProspectsToUpdate.containsKey(hdBudgetWalk.Prospect__c))
                        ) {
                        Prospect__c prospect = updateProspect(hdBudgetWalk);
                        mapProspectsToUpdate.put(prospect.Id, prospect);
                    }
                }
            }
        }

        if(mapRehabsToUpdate.size() > 0) {
            update mapRehabsToUpdate.values();
        }

        if(mapPipelinesToUpdate.size() > 0) {
            update mapPipelinesToUpdate.values();
        }

        if(mapProspectsToUpdate.size() > 0) {
            update mapProspectsToUpdate.values();
        }
    }

    private static Rehab__c updateRehab(HD_Budget_Walk__c hdBudgetWalk) {
        //Rehab Budget Est. @ UW  not found this field
        //Before_Photo_Date__c is Photos_Before_Date__c
        // Revised_Date__c is Final_Budget_Date__c in Rehab
        //Revised date is Revision_Date__c in HD Budget Walk

        Rehab__c rehab;
        if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_SUBMITTED) {
            rehab = new Rehab__c(Id = hdBudgetWalk.Rehab__c,
                                 Front_End_Budget__c = hdBudgetWalk.Submitted_Budget__c,
                                 Property_Notes_Rehab__c = hdBudgetWalk.Walk_Notes__c,
                                 //Photos_Before_Date__c = (hdBudgetWalk.Submit_Date__c != null ? hdBudgetWalk.Submit_Date__c.date() : null),
                                 Before_Photo_Date_Time__c = (hdBudgetWalk.Submit_Date__c != null ? hdBudgetWalk.Submit_Date__c : null),
                                 Submitted_PTL_Budget__c = hdBudgetWalk.Submitted_PTL_Budget__c,
                                 Submitted_GC_Budget__c = hdBudgetWalk.Submitted_GC_Budget__c
                                );
        }
        else if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_APPROVED) {
            rehab = new Rehab__c(Id = hdBudgetWalk.Rehab__c,
                                 Final_Budget_Date__c = (hdBudgetWalk.Revision_Date__c != null ? hdBudgetWalk.Revision_Date__c.date() : null),
                                 Revised_PTL_Budget__c = hdBudgetWalk.Revised_PTL_Budget__c,
                                 Revised_GC_Budget__c = hdBudgetWalk.Revised_GC_Budget__c,
                                 Budget_Revised__c = hdBudgetWalk.Revised_Budget__c,
                                 Budget_Revised_by__c = hdBudgetWalk.Revised_By__c
                                );
        }

        return rehab;
    }

    // update rehab on Walk_Supervisor__c is changed
    public static void updateRehabOnWalkSupervisorChange(List<HD_Budget_Walk__c> listHdBudgetWalkNew,
                                        Map<ID, HD_Budget_Walk__c> mapHdBudgetWalkOld) {

        Set<ID> setRehabIds = new Set<Id>();
        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {

            // when Walk_Supervisor__c is changed from null to non null or reverse
            if( Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Walk_Supervisor__c')
                && ( hdBudgetWalk.Walk_Supervisor__c == null || mapHdBudgetWalkOld.get(hdBudgetWalk.Id).Walk_Supervisor__c == null ) ) {
                if( hdBudgetWalk.Rehab__c != null ) {
                    setRehabIds.add( hdBudgetWalk.Rehab__c );
                }
            }
        }

        // query rehab
        Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>( [Select Id,
                                                             Stage__c,
                                                             RecordType.Name
                                                             From Rehab__c
                                                             Where Id in: setRehabIds
                                                             And RecordType.DeveloperName IN ('Turn', 'Post_Acquisition_TIP', 'Disposition')
                                                             And ( Stage__c =: Constants.REHAB_STAGE_MOVE_OUT_SCHEDULED
                                                                    OR
                                                                    Stage__c =: Constants.REHAB_STAGE_MOVE_OUT_ASSIGNED )
                                                      ]);

        Map<Id, Rehab__c> mapRehabToUpdateOnWalkSupervisorChange = new Map<Id, Rehab__c>();
        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {

                // when Walk_Supervisor__c is changed from null to non null or reverse
                if( Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Walk_Supervisor__c')
                    && ( hdBudgetWalk.Walk_Supervisor__c == null || mapHdBudgetWalkOld.get(hdBudgetWalk.Id).Walk_Supervisor__c == null )
                    ) {
                    if( hdBudgetWalk.Rehab__c != null && mapRehabs.containsKey( hdBudgetWalk.Rehab__c )) {
                        Rehab__c rehab = mapRehabs.get( hdBudgetWalk.Rehab__c );
                        if( hdBudgetWalk.Walk_Supervisor__c != null && rehab.Stage__c == Constants.REHAB_STAGE_MOVE_OUT_SCHEDULED ) {
                            mapRehabToUpdateOnWalkSupervisorChange.put( rehab.Id, new Rehab__c( Id = rehab.Id,
                                                                                                Stage__c = Constants.REHAB_STAGE_MOVE_OUT_ASSIGNED));
                        }
                        else if( hdBudgetWalk.Walk_Supervisor__c == null && rehab.Stage__c == Constants.REHAB_STAGE_MOVE_OUT_ASSIGNED ) {
                            mapRehabToUpdateOnWalkSupervisorChange.put( rehab.Id, new Rehab__c( Id = rehab.Id,
                                                                                                Stage__c = Constants.REHAB_STAGE_MOVE_OUT_SCHEDULED ));
                        }
                    }
                }
        }

        // update mapRehabToUpdateOnWalkSupervisorChange items
        if( mapRehabToUpdateOnWalkSupervisorChange.size() > 0 ) {
            update mapRehabToUpdateOnWalkSupervisorChange.values();
        }
    }

    //update rehab
    public static void updateRehab(List<HD_Budget_Walk__c> listHdBudgetWalkNew,
                                        Map<ID, HD_Budget_Walk__c> mapHdBudgetWalkOld) {

        Set<ID> setRehabIds = new Set<Id>();

        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {

            //if Walk_Supervisor__c is changed
            if( Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Walk_Supervisor__c') ) {
                if( hdBudgetWalk.Rehab__c != null
                    && hdBudgetWalk.Status__c != 'Cancelled'
                    && hdBudgetWalk.Status__c != 'Completed'
                ) {
                    setRehabIds.add( hdBudgetWalk.Rehab__c );
                }
            }
            //if status is changed
            if( hdBudgetWalk.Status__c == 'Cancelled' && Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Status__c') ) {
                setRehabIds.add( hdBudgetWalk.Rehab__c );
            }
            //if Revised_By__c is changed
            if( hdBudgetWalk.Rehab__c != null
                &&
                Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Revised_By__c') ) {

                setRehabIds.add( hdBudgetWalk.Rehab__c );
            }
        }

        Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>( [Select Id, 
                                                                     RecordType.DeveloperName,
                                                                     Front_End_Budget__c,
                                                                     Budget_Revised__c,
                                                                     Final_Budget_Date__c,
                                                                     RecordType.Name
                                                                     From Rehab__c
                                                                     Where Id in: setRehabIds
                                                                     //And Final_Budget_Date__c =: NULL
                                                              ]);

        Map<Id, Rehab__c> mapRehabToUpdate = new Map<Id, Rehab__c>();
        for(HD_Budget_Walk__c hdBudgetWalk : listHdBudgetWalkNew) {

            Id rehabId = hdBudgetWalk.Rehab__c;
            Rehab__c rehab;
            if( rehabId != null && mapRehabs.containsKey(rehabId) ) {
                rehab =  mapRehabs.get( rehabId );
            }

            //if status is changed
            if( hdBudgetWalk.Walk_Supervisor__c != null
                && rehabId != null
                && rehab != null
                && ( rehab.RecordType.DeveloperName != 'Turn' && rehab.RecordType.DeveloperName != 'Post_Acquisition_TIP' && rehab.RecordType.DeveloperName != 'Disposition')
                && rehab.Final_Budget_Date__c == null
                && hdBudgetWalk.Walk_Supervisor__c != null
                && Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Walk_Supervisor__c')
                && hdBudgetWalk.Status__c != 'Cancelled'
                && hdBudgetWalk.Status__c != 'Completed'
                    ) {

                    rehab.Stage__c = 'Front-End Assigned';
                    mapRehabToUpdate.put( rehabId, rehab );

            }

            //if status is changed
            if( trigger.isUpdate && hdBudgetWalk.Status__c == 'Cancelled' && Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Status__c') ) {

                rehab = mapRehabToUpdate.containsKey( rehabId ) ? mapRehabToUpdate.get( rehabId ) : rehab;

                if( rehabId != null && rehab != null ) {

                        rehab.Front_End_Budget__c = null;
                        rehab.Submitted_PTL_Budget__c = null;
                        rehab.Submitted_GC_Budget__c = null;
                        rehab.Before_Photo_Date_Time__c = null;
                        rehab.Sqft_Diff__c = null;

                        rehab.Budget_Revised__c = null;
                        rehab.Revised_PTL_Budget__c = null;
                        rehab.Revised_GC_Budget__c = null;
                        rehab.Final_Budget_Date__c = null;
                        rehab.Stage__c = 'Re-Key Complete';

                    mapRehabToUpdate.put( rehabId, rehab);
                }
            }

            // if rehabId for Budget Walk is not null and Revised_By__c is changed
            if( hdBudgetWalk.Rehab__c != null
                &&
                Utility.hasFieldChanged(hdBudgetWalk, mapHdBudgetWalkOld, 'Revised_By__c') ) {
                // when mapRehabToUpdate contains item for rehabId
                if( mapRehabToUpdate.containsKey( rehabId ) ) {
                    rehab = mapRehabToUpdate.get( rehabId );
                }
                else {
                    rehab = new Rehab__c( Id = rehabId );
                }
                // update Budget_Revised_by__c
                rehab.Budget_Revised_by__c = hdBudgetWalk.Revised_By__c;
                mapRehabToUpdate.put( rehabId, rehab);
            }
        }

        if( mapRehabToUpdate.size() > 0 ) {
            update mapRehabToUpdate.values();
        }
    }

    private static Property_Opportunity__c updatePipeline(HD_Budget_Walk__c hdBudgetWalk) {
        Property_Opportunity__c pipeline;
        if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_SUBMITTED) {
            pipeline = new Property_Opportunity__c(Id = hdBudgetWalk.Pipeline__c,
                                               Rehab_Budget_Est_UW__c = hdBudgetWalk.Submitted_Budget__c,
                                               HD_Budget_Walk_Notes__c = hdBudgetWalk.Walk_Notes__c
                                               );
        }
        else if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_APPROVED) {
            pipeline = new Property_Opportunity__c(Id = hdBudgetWalk.Pipeline__c,
                                               Rehab_Budget_Est_UW__c = hdBudgetWalk.Revised_Budget__c
                                               );
        }
        return pipeline;
    }

    private static Prospect__c updateProspect(HD_Budget_Walk__c hdBudgetWalk) {
        Prospect__c prospect;
        if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_SUBMITTED) {
            prospect = new Prospect__c(Id = hdBudgetWalk.Prospect__c,
                                   Rehab_Budget_Est_UW__c = hdBudgetWalk.Submitted_Budget__c,
                                   HD_Budget_Walk_Notes__c = hdBudgetWalk.Walk_Notes__c
                                   );
        }
        else if(hdBudgetWalk.Status__c == HD_BUDGET_WALK_STATUS_APPROVED) {
            prospect = new Prospect__c(Id = hdBudgetWalk.Prospect__c,
                                   Rehab_Budget_Est_UW__c = hdBudgetWalk.Revised_Budget__c
                                   );
        }
        return prospect;
    }

    // method to detach rehab projected spend from rehab when hd budget walk is cancelled
    public static void detachRehabProjectedSpend( List<HD_Budget_Walk__c> newHdBudgetWalkList,
                                                  Map<ID, HD_Budget_Walk__c> oldHDBudgetWalk ) {
          Set<Id> budgetWalkIds = new Set<Id>();
          Map<Id, Rehab__c> mapRehabs = new Map<Id, Rehab__c>();
          // loop over Budget Walk List
          for( HD_Budget_Walk__c hdBudgetWalkObj : newHdBudgetWalkList ) {
              // when status is cancelled and it was not cancelled earlier
              if( hdBudgetWalkObj.Status__c == 'Cancelled'
                  && Utility.hasFieldChanged(hdBudgetWalkObj, oldHDBudgetWalk, 'Status__c') ) {

                  // add hd budget walk id to set
                  budgetWalkIds.add( hdBudgetWalkObj.Id );
                  if( hdBudgetWalkObj.Rehab__c != null ) {
                        // update commulative fields on rehab to zero
                        mapRehabs.put( hdBudgetWalkObj.Rehab__c, new Rehab__c(  Id = hdBudgetWalkObj.Rehab__c,
                                                                                Actual_Spend_Total__c = 0,
                                                                                Selected_Bid_Total__c = 0,
                                                                                Projected_Spend_Base_Budget__c = 0,
                                                                                Projected_Spend_Changes_To_Budget__c = 0,
                                                                                Projected_Spend_Running_Total__c = 0
                                                                              ) );
                  }
              }
          }

          // query Rehab_Projected_Spend__c for the budget walks
          List<Rehab_Projected_Spend__c> listRehabProjectedSpend = [ Select HD_Budget_Walk__c
                                                                     From Rehab_Projected_Spend__c
                                                                     Where HD_Budget_Walk__c in: budgetWalkIds
                                                                     ];

          // map rehab spends to updated
          Map<Id, Rehab_Projected_Spend__c> mapRPSToUpdate = new Map<Id, Rehab_Projected_Spend__c>();
          // loop over rehab projected spends
          for ( Rehab_Projected_Spend__c rpsObj : listRehabProjectedSpend ) {
               rpsObj.Rehab__c = null;
               mapRPSToUpdate.put( rpsObj.Id, rpsObj );
          }

          // when mapRPSToUpdate has values
          if( mapRPSToUpdate.size() > 0 ) {
              // update mapRPSToUpdate
              update mapRPSToUpdate.values();
          }
          // when mapRehabs has values
          if( mapRehabs.size() > 0 ) {
              // update mapRehabs
              update mapRehabs.values();
          }
  }

}