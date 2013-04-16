/*
    Type:       Test class
    Purpose:    Test Class for TriggerAftersales.trigger
    User Story: US-CP-14
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-06
*/
@isTest
public class TriggerAftersalesTest{
    public static testMethod void testTriggerAftersales() {
        // Create Test User
        // User usr = testUtil.createUser('IB CSR', 'CAC IB CSR');
        
        // Create Dealer
        Account dealer = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_DEALER);
        
        // Create Person Account
        Account personAccount = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Create Vehicle
        Vehicle__c vehicle = (Vehicle__c)UtilTestData.createSobject(new Vehicle__c(), null);
        
        // Create Vehicle Relationship
        Vehicle_Relationship__c relationship = 
            new Vehicle_Relationship__c(Vehicle_ID__c = vehicle.Id);
        relationship = (Vehicle_Relationship__c)UtilTestData.createSobject(relationship, null);
        
        // Create Aftersales;
        Aftersales__c aftersales = new Aftersales__c(Service_Dealer__c = dealer.Id,
                                                     Service_Vehicle__c = vehicle.Id,
                                                     Service_Contact__c = personAccount.Id);
        aftersales = (Aftersales__c)UtilTestData.createSobject(aftersales, null);
      
        // Start Test
        Test.startTest();
        
        // Update aftersales
        aftersales.Valid__c = true;
        update aftersales;
       
        // Assert Updated personAccount Result
        personAccount = [SELECT Main_Dealer__c, Latest_Service_Dealer__c
                         FROM Account
                         WHERE Id = :personAccount.Id];
        System.assertEquals(personAccount.Main_Dealer__c, dealer.Id);
        System.assertEquals(personAccount.Latest_Service_Dealer__c, dealer.Id);
       
        // Assert Updated relationship Result
        relationship = [SELECT Last_Service_Dealer__c
                        FROM Vehicle_Relationship__c
                        WHERE Id = :relationship.Id];
        System.assertEquals(relationship.Last_Service_Dealer__c, dealer.Id);
                
        // Stop Test
        Test.stopTest();
    }
}