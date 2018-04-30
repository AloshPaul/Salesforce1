/**
 * Description  :   This class is responsible for the creating HOA Payments record for selected HOA Tracking records.
 * Copyright    :   Invitation Homes 2013
 * Created By   :   Rajesh Shah
 * Created Date :   4th March, 2013
 * Revisiion Logs:  V1.0 - Created
 *					v1.1 - Modifiy by Abhinav Sharma on 6/29/2013 as per SIR - D-00005899
 *
**/

public with sharing class createHOAPaymentsExtension {

    private ApexPages.Standardsetcontroller setController;
    public createHOAPaymentsExtension(ApexPages.StandardSetController setController) {
        this.setController = setController;
    }

    // Error Handling Variables
    public Boolean pageHasError {get; set;}
    public String errorMessage {get; set;}

    public List<HOA_Payments__c> toInsertHoaPayments {get; set;}
    // Function to create Payment records.
    public void createPaymentRecords() {
        try {
                pageHasError = false;
                if(setController == null || setController.getSelected().size() == 0) {
                    pageHasError = true;
                    errorMessage = 'Please select one or more HOA Tracking record to create HOA Payment record.';
                    return;
                }

                // Get all the HOA Tracking IDs
                Set<Id> hoaTrackingIds = new Set<Id>();
                for(HOA_Tracking__c hoaTracking : (List<HOA_Tracking__c>)setController.getSelected())
                    hoaTrackingIds.add(hoaTracking.Id);

                // For Each HOA Tracking, create a HOA Payments record.
                toInsertHoaPayments = new List<HOA_Payments__c>();
                for(HOA_Tracking__c hoaTracking : [Select Payment_Amount__c, Day_in_Month_Due__c
                                                                        from    HOA_Tracking__c
                                                                        where   Id in :hoaTrackingIds]) {
                    HOA_Payments__c hoaPayment = new HOA_Payments__c();
                    hoaPayment.HOA_Tracker__c = hoaTracking.Id;
                    if(hoaTracking.Payment_Amount__c != null)
                        hoaPayment.Monthly_Amount__c = hoaTracking.Payment_Amount__c;
                    hoaPayment.Due_Date__c = getDueDate(hoaTracking.Day_in_Month_Due__c);
                    hoaPayment.Status__c = 'Needs Approval';

                    toInsertHoaPayments.add(hoaPayment);
                }

                // Insert HOA Payments records.
                insert toInsertHoaPayments;
                Set<Id> paymentIds = new Set<Id>();
                for(HOA_Payments__c hoaPayment : toInsertHoaPayments)
                    paymentIds.add(hoaPayment.Id);

                toInsertHoaPayments = [Select Name, HOA_Tracker__c, Monthly_Amount__c,  Due_Date__c, Status__c
                                                        from HOA_Payments__c
                                                        where Id in :paymentIds];
        }
        catch(Exception e) {
                // Show Error on page.
                pageHasError = true;
                errorMessage = 'Following exception occurred: ' + e.getMessage();
        }
    }

    // Calculate and returns the next due date based on the Day in Month due field.
    private Date getDueDate(String dayInMonthDue) {
        Date todayDate = system.today();

        // Get the month for next due date. If the current month is 12 (Dec), set the month as 1 (Jan)
        Integer month = (todayDate.month() < 12) ? todayDate.month() + 1 : 1;
        // Get the year for next due date. If the month is 1, add 1 to the todayDate's year.
        Integer year = (month == 1) ? todayDate.year() + 1 : todayDate.year();
        // Get the Day for the next due date. If the Day In Month is null, set default as 1.
        Integer day = (dayInMonthDue != null && dayInMonthDue != '') ? Integer.valueOf(dayInMonthDue) : 1;
        // Get the maximum days in month.
        Integer maxDayInMonth = Date.daysInMonth(todayDate.year(), month);
        // If the day is more than max day in month, set the day as the last month of the date.
        day = (day > maxDayInMonth) ? maxDayInMonth : day;
        return date.newInstance(year, month, day);
    }
}