public without sharing class S3PropertyIssueImagesController
{
    public Sobject sObj {get;set;}
    public String pageTitle {get;set;}
    public List<String> ImageURLs {get;set;}

    public List<Property_Issue_Photo__c> lstPIImages {get;set;}
       
    public S3PropertyIssueImagesController(ApexPages.StandardController controller) 
    {
        try
        {
            sObj = controller.getRecord();
            lstPIImages = new List<Property_Issue_Photo__c>();
            pageTitle = '';
            ImageURLs = new List<String>();
            
            lstPIImages = [Select id, name, S3_Bucket__c, S3_Path__c, S3_Image_URL__c, Type__c, Property_Issue__c from Property_Issue_Photo__c where Property_Issue__c =: sObj.id ];
                
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
    }
}