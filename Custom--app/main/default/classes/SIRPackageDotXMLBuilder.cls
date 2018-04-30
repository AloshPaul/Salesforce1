/**
 * Description    :    This class is to build Package.Xml file for particular SIR based on modifications.
 * 
 * Created By     :    Abhinav Sharma
 * 
 * Created Date   :    07/18/2013
 *
 * Revision Logs  :    V1.0 - Created
 * 
 **/
public with sharing class SIRPackageDotXMLBuilder {
    
    //Property to hold the SIR data
    private Issues_New_Feature_Request__c sIR;
    
    //String to hold the Component Migration name
    String componentNameStringForMigration;
    
    //Package.xml String
    public String packageDotXmlString {get; set;}
    
    //Variable to hold the list type custom setting map value where name behaves as a key
    Map<String, Migration_Configuration__c> migrationConfigMap = Constants.MIGRATION_CONFIGURATION_MAP;
    
    //Set to hold the component migration name string having obectName as prefix while adding them as a memeber in Package.xml file
    Set<String> setComponentNameStringWithObjectNamePrefix = Constants.SET_COMPONENTS_NAME_HAVING_OBJECT_NAME_PREFIX_AS_MEMBER;
    
    //Calling Constructor
    public SIRPackageDotXMLBuilder(ApexPages.StandardController controller) {
    
        //Getting SIR Record
        sIR = (Issues_New_Feature_Request__c)controller.getRecord();
        
        //Map to hold Component Name as Key and List of String (Component Name - Object Name - Component Type) as Key
        Map<String, List<String>> mapNameWithMemebers = new Map<String, List<String>>();
        
        //Set to hold the Component name and Object name String value
        Set<String> setComponentNameAndObjectName = new Set<String>();
        
        //Memory allocation to string variable
        packageDotXmlString = '';
    
        //Creating the Package.xml envelope
        
        //Dom Document
        DOM.Document doc = new DOM.Document();
        
        //Root element (Package)        
        dom.XmlNode mypackage = doc.createRootElement(Constants.PACKAGE_STRING , Constants.PACKAGEFILENAMESPACE , null);        
        
        //fullName Element
        dom.XmlNode fullName = mypackage.addChildElement(Constants.FULLNAME , null, null).addTextNode(Constants.INITIAL_TEXT);
        
        //List to hold the values corresponding to the Key in the map
        List<String> membersList = new List<String>();
        
        //Loop through modifications associated with the SIR record
        for(Modification__c modification : [Select ID, Component_Name__c, Component_Type__c, Object_Name__c 
                                                FROM Modification__c WHERE System_Issue_Report__c =: sIR.ID AND Manual_Step__c = false
                                                ORDER BY Component_Type__c DESC]) {
            
            //String to hold the combined string of Component Name and Object Name
            String componentNameAndObjectNameString = modification.Object_Name__c + '.' + modification.Component_Name__c + '.' + modification.Component_Type__c;
                
            //Getting Component Package.xml friendly Name value from the Custom setting 
            if(migrationConfigMap.containsKey(modification.Component_Type__c)) {
                
                //Populate String field with migration name value for the component
                componentNameStringForMigration = migrationConfigMap.get(modification.Component_Type__c).Component_Name__c;
                
                //Checking component name string for the null and blank value
                if(componentNameStringForMigration != null && componentNameStringForMigration != '') {
                    
                    //Checking for key in the map
                    if(mapNameWithMemebers.containsKey(componentNameStringForMigration) == false) { 
                        
                        //Adding new value in the list
                        membersList = new List<String>{componentNameAndObjectNameString};
                                                
                        //Populating set with String of Component name and Object name
                        setComponentNameAndObjectName.add(componentNameAndObjectNameString);
                        
                    } else {
                        
                        //Check for Uniqueness of values corresponding to the component name and object name values
                        if(!setComponentNameAndObjectName.contains(componentNameAndObjectNameString)) {
                            
                            //Adding values in the list
                            membersList = mapNameWithMemebers.get(componentNameStringForMigration);
                            membersList.add(componentNameAndObjectNameString);
                            
                            //Populating set with String of Component name and Object name
                            setComponentNameAndObjectName.add(componentNameAndObjectNameString);
                        }
                    }
                    
                    //Populating map with the values
                    mapNameWithMemebers.put(componentNameStringForMigration , membersList);
                }
            }                                                                                       
        }
        
        //Loop through Map keyset
        for(String nameString : mapNameWithMemebers.keySet()) {
                
            //types element
            dom.XmlNode types = mypackage.addChildElement(Constants.TYPES , null, null);
                
            //Loop through Map values for members
            for(String memberString : mapNameWithMemebers.get(nameString))  {
                
                //Check for components requires Object Name prefix in them as member of Package.xml file
                if(setComponentNameStringWithObjectNamePrefix.contains(nameString)) {
                                    
                    //List to hold the Splitted Strings
                    List<String> splittedStringListForMember = memberString.split('\\.');
                    
                    //List to hold the Component Name String
                    String componentNameSplittedString = '';
                
                    //Getting Component Name String
                    if(splittedStringListForMember.size() > 2) {
                        componentNameSplittedString = memberString.remove(splittedStringListForMember[2]);
                        componentNameSplittedString = componentNameSplittedString.removeEnd('.');
                    }
                    
                    //Members element
                    types.addChildElement(Constants.MEMBERS , null, null).addTextNode(componentNameSplittedString);        
                } 
                
                else if (nameString == Constants.LAYOUT) {
                                   
                    //Replace '.' String with '-'
                    memberString = memberString.replace('.', '-');
                    
                    //Checking for string value
                    if(memberString.split('\\-').size() > 2) {
                        memberString = memberString.remove(memberString.split('\\-')[2]);
                    }
                    
                    memberString = memberString.removeEnd('-');
                    
                    //Members element
                    types.addChildElement(Constants.MEMBERS , null, null).addTextNode(memberString);
                
                } else {
                    
                    //List to hold the Splitted Strings
                    List<String> splittedStringList = memberString.split('\\.');
                    
                    //List to hold the Component Name String
                    String componentNameSplittedString = '';
                
                    //Getting Component Name String
                    if(splittedStringList.size() > 1) {
                        componentNameSplittedString = splittedStringList[1];
                    }
                    
                    //Members element
                    types.addChildElement(Constants.MEMBERS , null, null).addTextNode(componentNameSplittedString);

                }                           
            }
            
            //Name element
            types.addChildElement(Constants.NAME , null, null).addTextNode(nameString);
            
        }
                        
        //Name Element
        mypackage.addChildElement(Constants.VERSION , null, null).addTextNode(Constants.VERSION_NO);
        
        //Package.xml String
        packageDotXmlString = doc.toXmlString();
        
        //Processing string for getting desired Package.xml string value
        packageDotXmlString = packageDotXmlString.remove('<?xml version="1.0" encoding="UTF-8"?><ns0:Package xmlns:ns0="http://soap.sforce.com/2006/04/metadata"><fullName>Migration test</fullName>');
        packageDotXmlString = packageDotXmlString.remove('<version>27.0</version></ns0:Package>');
        
    }
}