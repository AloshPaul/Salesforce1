/**
 * 	Description		:	Controller class for EmailPropertyInvoicesCSV VF page.
 						This class is send the email to user with all All Invoices CSV where
 							Include_in_Yardi_Batch__c == true
 							Date_Submitted_to_Yardi__c == null
 							Status__c == 'Submitted'
  						Once the email is sent, Update the following fields of the queried records
  							Date_Submitted_to_Yardi__c = Today
  							Status__c = Paid
 *
 * 	Created By		:	Bhavi Sharma
 *
 * 	Created Date	:	11/21/2013
 *
 * 	Revision Logs	:	V_1.0 - Created
 *                      V_1.1 Shrinath : Made Without Sharing and D-00011329 ( Revision - BUG-4842 ) 02/05/2014
 *
 **/
public without sharing class EmailPropertyInvoicesCSVController {

	//Constructor
	public EmailPropertyInvoicesCSVController(ApexPages.StandardSetController controller) {

	}

	/**
	 * 	@description	:	This method is to query Property Invoices records which fit in the criteria
	 							Create a CSV and email to current user
	 							Update the fields of these records
	 *
	 * 	@args			:
	 *
	 * 	@return			:	void
	 *
	 **/
	public void emailCSVToUserAndUpdateInvoices() {

		//Create a savepoint to rollback the complete transaction in case of exception
		SavePoint sp = database.setSavePoint();

		try {

			//Query all the Invoices records
			List<Property_Invoice__c> propertyInvoices = [Select Type__c, Tran__c, Vendor_Code__c, Vendor__c, Vendor__r.Name, Invoice_Date__c, GL_Code_Original__c, GL_Code_Type_Adjusted__c, Post_Month__c,
																	Invoice_Number__c, Yardi_Code__c, Remarks_Appears_on_GL__c, Due_Date__c, Invoice_Amount__c,
																	Return_Check_to__c, Approved_By__c, Rehab_Projected_Spend__r.Name, Rehab__r.Name,
																	Comments__c, Include_in_Yardi_Batch__c, Rehab__c, Rehab_Projected_Spend__c
																	from Property_Invoice__c where Include_in_Yardi_Batch__c = true
																										AND Date_Submitted_to_Yardi__c = null
																										AND Status__c = 'Submitted'];
			//Display message if no records in CSV
			if(propertyInvoices.size() == 0) {

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No records to email.'));
				return;
			}

			//Send email to user
			EmailPropertyInvoicesCSVController.EmailCSVToUser(propertyInvoices, 'Property Invoices.csv', 'Property Invoices');

			//Loop through all the records and update the invoices records
			for(Property_Invoice__c pInvoice : propertyInvoices) {

				pInvoice.Date_Submitted_to_Yardi__c = Date.today();
	  			pInvoice.Status__c = 'Paid';
			}

			//update pInvoice
			update propertyInvoices;

			//Add message on page
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Email sent successfully on ' + UserInfo.getUserEmail() + '.'));
		} catch(Exception e) {

			//Rollback the complete transaction
			database.rollBack(sp);

			//Add error on page
			ApexPages.addMessages(e);
		}
	}

	/**
	 * 	@description	:	This method is to process the Property invoices list
	 							Create a CSV and email to current user
	 							Update the fields of these records
	 *
	 * 	@args			:	List<Property_Invoice__c>
	 *
	 * 	@return			:	void
	 *
	 **/
	public static void EmailCSVToUser(List<Property_Invoice__c> propertyInvoices, String fileName, String subject) {

		//Properties
		String seperator = ',';
   		String newLine = '\n';

		//Header Row Content string
        String headerRow = 'Type,Tran #,Vendor Code,Vendor,Invoice Date,Post Month,Invoice Number,Comments,Yardi Code,Invoice Amount,GL Code,Remarks,Return Check to,Approved by';

        //Data row content string
        String dataRows = '';
        String dataRow = '';

        //Loop through existing property invoices records list
		for(Property_Invoice__c pInvoice : propertyInvoices) {

			//Populate data row content string with existing property invoices fields value
			dataRow = (newLine
									+ parseNull(pInvoice.Type__c)
									+ seperator + parseNull(pInvoice.Tran__c)
									+ seperator + parseNull(pInvoice.Vendor_Code__c )
									+ seperator + parseNull(pInvoice.Vendor__r.Name)
									+ seperator + parseNull(string.valueOf(pInvoice.Invoice_Date__c))
									+ seperator + parseNull(pInvoice.Post_Month__c )
									+ seperator + parseNull(pInvoice.Invoice_Number__c)
									+ seperator + parseNull(pInvoice.Comments__c)
									+ seperator + parseNull(pInvoice.Yardi_Code__c)
									+ seperator + parseNull(pInvoice.Invoice_Amount__c)
									+ seperator + parseNull(pInvoice.GL_Code_Type_Adjusted__c)
									+ seperator + parseNull(pInvoice.Remarks_Appears_on_GL__c)
									+ seperator + parseNull(pInvoice.Return_Check_to__c)
									+ seperator + parseNull(pInvoice.Approved_By__c)
                                );

            //Appending row in the data rows string
   			dataRows += dataRow;
		}

		//Appending header row into the data rows
		dataRows = headerRow + dataRows;

		//Email Attachments List
		List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

		//Email Attachment for property invoice records csv
		Messaging.EmailFileAttachment emailCSVAttachment = new Messaging.EmailFileAttachment();
		emailCSVAttachment.setFileName(fileName);
		emailCSVAttachment.setBody(Blob.valueOf(dataRows));

		//Adding attachment record into the list
		emailAttachments.add(emailCSVAttachment);

		//Email Message Instahce
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		//Set attributes
		email.setSubject(subject);
     	email.setPlainTextBody('Please find the attached Property Invoices CSV.');
     	email.setFileAttachments(emailAttachments);
     	email.setToAddresses(new List<String>{UserInfo.getUserEmail()});
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}

	/**
	 * 	@description	:	Method to return blank string if value is null.
	 *
	 * 	@args			:	Object val
	 *
	 * 	@return			:	String
	 *
	 **/
     private static String parseNull(Object val) {
     	return (val == null ? '' : String.valueOf(val).escapeCSV());
     }
}