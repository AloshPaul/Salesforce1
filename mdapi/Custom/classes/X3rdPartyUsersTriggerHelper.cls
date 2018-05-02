/**
 *  Description :   Helper class for 3rdPartyUsers trigger.
 * 
 *  Created By  :   Abhinav Sharma
 * 
 *  Created Date:   09/06/2012
 * 
 *  Revision Logs:  V1.1 - Updated by Vrajesh
 *  Added Functionality:https://na9.salesforce.com/a0ME0000001Ycjv
 **/
public class X3rdPartyUsersTriggerHelper {
    
    //This method is to give sharing access to 3rd Party users to property records
    public static void sharePropertyWith3rdPartyUsers(List<X3_Party_Users__c> thirdPartyUsers) {
    
        //Set to Hold Account Id
        Set<Id> accIds = new Set<Id>();
        
        //Loop through 3rd Party Users
        for(X3_Party_Users__c thirdPartyUser : thirdPartyUsers) {
        
            //Check for X3_Party_Agency__c
            if(thirdPartyUser.X3_Party_Agency__c != Null) {
                
                //Populate Set with Ids
                accIds.add(thirdPartyUser.X3_Party_Agency__c);
            }
        }
        
        //Create a map to hold the Properties for Account
        Map<Id, Set<Id>> mapAccountIdWithProperties = new Map<Id, Set<Id>>();
        
        //Get all the Properties related to account ids
        for(Property__c property : [Select Id, X3rd_Party_Door_Knock_Agency__c, X3rd_Party_Lease_Agency__c
                                     from property__c where X3rd_Party_Door_Knock_Agency__c IN: accIds OR
                                     X3rd_Party_Lease_Agency__c IN : accIds]) {
                                     
            //Check for X3rd_Party_Door_Knock_Agency__c
            if(property.X3rd_Party_Door_Knock_Agency__c != Null) {
            
                //Check if account is already added
                if(mapAccountIdWithProperties.containsKey(property.X3rd_Party_Door_Knock_Agency__c)) {
                    
                    //Add property in set
                    mapAccountIdWithProperties.get(property.X3rd_Party_Door_Knock_Agency__c).add(property.Id);
                    
                } else {
                    
                    //Add property in set
                    mapAccountIdWithProperties.put(property.X3rd_Party_Door_Knock_Agency__c, new Set<Id>{property.Id});
                }
            }

            //Check for X3rd_Party_Lease_Agency__c
            if(property.X3rd_Party_Lease_Agency__c != Null) {
            
                //Check if account is already added
                if(mapAccountIdWithProperties.containsKey(property.X3rd_Party_Lease_Agency__c)) {
                    
                    //Add property in set
                    mapAccountIdWithProperties.get(property.X3rd_Party_Lease_Agency__c).add(property.Id);
                    
                } else {
                    
                    //Add property in set
                    mapAccountIdWithProperties.put(property.X3rd_Party_Lease_Agency__c, new Set<Id>{property.Id});
                }
            }
        }
        
        //Create a list for sharing access
        List<Property__Share> propertiesSharing = new List<Property__Share>();
        
        //set to maintain the uniqueness
        //This will hold the key in form of PropertyId-UserId
        Set<String> propIdWithPartyUserId = new Set<String>();
        
        //Loop through the 3rd Part Users records for getting access related to Property
        for(X3_Party_Users__c partyUser : thirdPartyUsers) {
            
            //Check for the 3rd party agencies
            if(partyUser.X3_Party_Agency__c != null) {
                
                //check the account is map
                if(mapAccountIdWithProperties.containsKey(partyUser.X3_Party_Agency__c)) {
                    
                    //get all the properties from the map
                    for(Id propertyId : mapAccountIdWithProperties.get(partyUser.X3_Party_Agency__c)) {
                        
                        //Create a pair to check the uniqueness
                        String propUserPair = propertyId  + '-' + partyUser.User__c;
                        
                        if(!propIdWithPartyUserId.contains(propUserPair)) {
                            
                            //Add user for Sharing access
                            propertiesSharing.add(new Property__Share(UserOrGroupId = partyUser.User__c   , AccessLevel = Constants.ACCESS_LEVEL_EDIT, ParentId = propertyId)); 
                        
                            //Add pair in set
                            propIdWithPartyUserId.add(propUserPair);
                        }    
                    }
                }
            }
        }
        
        //Check for the size
        if(propertiesSharing.size() > 0)
            insert propertiesSharing;
    }
    
    //Remove sharing for 3rd Party users
    public static void removeSahringFor3rdPartyUsers(List<X3_Party_Users__c> thirdPartyUsers) {
    
        //loop through the thirdPartyUsers and create a set of Account Ids
        //This Set will be get used to fetch all the property records related to 3rd Party Users
        Set<Id> accIds = new Set<Id>();
        
        //Create a map to hold teh user id with Account Id
        Map<Id, Set<Id>> mapUsersWithAcc = new Map<Id, Set<Id>>();
        
        for(X3_Party_Users__c tPU : thirdPartyUsers) {
            
            //Check if 3rd Party is not null
            if(tPU.X3_Party_Agency__c != null && tPU.User__c != null) {
                
                //Add in set
                accIds.add(tPU.X3_Party_Agency__c);
                
                //Prepare map
                if(mapUsersWithAcc.containsKey(tPU.User__c))
                    mapUsersWithAcc.get(tPU.User__c).add(tPU.X3_Party_Agency__c);
                else
                    mapUsersWithAcc.put(tPU.User__c, new Set<Id>{tPU.X3_Party_Agency__c});
            }
        }
        
        //Create  a map for Paroperty Id and Account Ids
        Map<Id, Set<Id>> mapAccWithProperties = new Map<Id, Set<Id>>();
        
        //Fetch Properties and 
        for(Property__c property : [Select Id, X3rd_Party_Door_Knock_Agency__c, X3rd_Party_Lease_Agency__c from Property__c 
                                        where X3rd_Party_Door_Knock_Agency__c =: accIds OR X3rd_Party_Lease_Agency__c =: accIds]) {
            
            //Add in Map
            if(property.X3rd_Party_Door_Knock_Agency__c != null) {
                
                if(mapAccWithProperties.containsKey(property.X3rd_Party_Door_Knock_Agency__c))
                    mapAccWithProperties.get(property.X3rd_Party_Door_Knock_Agency__c).add(property.Id);
                else
                    mapAccWithProperties.put(property.X3rd_Party_Door_Knock_Agency__c, new Set<Id>{property.Id});
            }
            
            if(property.X3rd_Party_Lease_Agency__c != null) {
                
                if(mapAccWithProperties.containsKey(property.X3rd_Party_Lease_Agency__c))
                    mapAccWithProperties.get(property.X3rd_Party_Lease_Agency__c).add(property.Id);
                else
                    mapAccWithProperties.put(property.X3rd_Party_Lease_Agency__c, new Set<Id>{property.Id});
            }   
        }
        
        //Create a list of sharing records to be deleted
        List<Property__Share> propertySharingToBeDeleted = new List<Property__Share>();
        
        //Check size before performing any operation
        if(mapUsersWithAcc.size() > 0) {
            
            //Ftech Property Sharing records
            for(Property__Share pS : [Select Id, ParentId, UserOrGroupId from Property__Share where UserOrGroupId IN: mapUsersWithAcc.keySet()]) {
                
                //Check if sharing need to be deleted
                if(mapUsersWithAcc.containsKey(pS.UserOrGroupId)) {
                    
                    //Check if property for this user
                    for(Id accId : mapUsersWithAcc.get(pS.UserOrGroupId)) {
                        
                        if(mapAccWithProperties.containsKey(accId) && mapAccWithProperties.get(accId).contains(pS.ParentId)) {
                            
                            //Add record for deletion
                            propertySharingToBeDeleted.add(pS);
                        }
                    }
                    
                }
                    
            }
            
            //delete data
            if(propertySharingToBeDeleted.size() > 0)
                delete propertySharingToBeDeleted;
        }
    }
    
   //Method to add 3rd party users from any account to Public user Group
    @future
    public static void addUserintoPublicGroup(List<ID> thirdPartyUsersID){
        //Variables 
        list<X3_Party_Users__c > thirdPartyUsers = new list<X3_Party_Users__c >();
        List<GroupMember> groupMemberToInsert = new list<GroupMember>();
        List<Group> GroupList = new List<Group>();
        List<Group> GroupListToInsert = new List<Group>();
        List<Account> AccountList = new List<Account>();
        map<id,string> userIDAccountName = new map<id,string>();
        map<String,Group> groupNameGroupMap = new map<String,Group>();
        map<String,Account> accountNameAccountMap = new map<string,Account>();
        list<String> nameList = new list<string>();
        
        
        //Get 3rd Party user records
        thirdPartyUsers = [SELECT X3_Party_Agency__c ,X3_Party_Agency__r.Name ,id,User__c FROM X3_Party_Users__c WHERE id in :thirdPartyUsersID];
        
        //Get the list of Account name
        for(X3_Party_Users__c thirdPartyUser : thirdPartyUsers){
            userIDAccountName.put(thirdPartyUser.id,thirdPartyUser.X3_Party_Agency__r.Name);
            nameList.add(thirdPartyUser.X3_Party_Agency__r.Name);
            }
        //Get public Group records
        GroupList = [SELECT id,Name FROM GROUP WHERE Name in :nameList];
        
        //Create a map with Group name and Group Record
        for(Group groupRecord: GroupList){
            groupNameGroupMap.put(groupRecord.Name,groupRecord);
        }
        
        //Get the Account Record
        AccountList = [SELECT id,Name FROM Account WHERE Name in :nameList];
        
        //Get the map with account name and Account record and check if there 
        //is any public group associated with that account
        for(Account accountRecord : AccountList){
            accountNameAccountMap.put(accountRecord.Name,accountRecord);
            if(groupNameGroupMap.get(accountRecord.Name)==NULL){
                Group publicGroup = new Group(Name=accountRecord.Name,Type = 'Regular');
                GroupListToInsert.add(publicGroup);
            }
        }
        
        //Insert public group if necessary
        if(GroupListToInsert.size()>0){
            insert GroupListToInsert;
        }
        
        //Get the map of Group name and group record
        for(Group groupRecord: GroupListToInsert){
            groupNameGroupMap.put(groupRecord.Name,groupRecord);
        }
        
        //Create a new public group member for the new 3rd party User
        for(X3_Party_Users__c thirdPartyUser : thirdPartyUsers){
            if(groupNameGroupMap.get(thirdPartyUser.X3_Party_Agency__r.Name)<> null && accountNameAccountMap.get(thirdPartyUser.X3_Party_Agency__r.Name)<>null){
                GroupMember newMember = new GroupMember(GroupId = (groupNameGroupMap.get(thirdPartyUser.X3_Party_Agency__r.Name)).id,UserOrGroupId=thirdPartyUser.User__c);
                groupMemberToInsert.add(newMember);
            }
        }
        
        //Insert the public group member
        if(groupMemberToInsert.size()>0){
                insert groupMemberToInsert;
            }
        }
        
 
    @future
    public static void DeleteUserFromPublicGroup(List<ID> thirdPartyUsersID){
        //Variables 
        list<X3_Party_Users__c > thirdPartyUsers = new list<X3_Party_Users__c >();
        list<GroupMember> GroupMemberList = new list<GroupMember>();
        list<GroupMember> GroupMemberListToDelete = new list<GroupMember>();
        list<id> UserIDList = new List<id>();
        
        //Get 3rd Party user records
        thirdPartyUsers = [SELECT X3_Party_Agency__c ,X3_Party_Agency__r.Name ,id,User__c FROM X3_Party_Users__c WHERE id in :thirdPartyUsersID ALL ROWS];
        
        //Get user id list
        for(X3_Party_Users__c thirdPartyUser : thirdPartyUsers){
            UserIDList.add(thirdPartyUser.User__c);
            }
        
        //Query Group Member record
        GroupMemberList = [SELECT id,Groupid,Group.Name,UserOrGroupId FROM GroupMember WHERE UserOrGroupId in :UserIDList];
        
        //Get the record which will be deleted      
        for(X3_Party_Users__c thirdPartyUser : thirdPartyUsers){
            for(GroupMember groupMemberrecord : GroupMemberList){
                if(groupMemberrecord.UserOrGroupId == thirdPartyUser.User__c
                    && groupMemberrecord.Group.Name == thirdPartyUser.X3_Party_Agency__r.Name){
                        GroupMemberListToDelete.add(groupMemberrecord);
                    }
            }
        }
        //Delete groupmember records
        if(GroupMemberListToDelete.size()>0){
            Delete GroupMemberListToDelete;
        }
    }            
}