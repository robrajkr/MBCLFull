/*
    Type:       Test class
    Purpose:    Test Class for TriggerSales
    User Story: US-CP-12
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-06
*/
@isTest
public class TriggerSalesTest {
    public static testMethod void testTriggerSales() {
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
        
        // Create Sales;
        Date dtToday = System.today();
        Sales__c sales = new Sales__c(Sales_Person__c = 'person',
                                      Sales_Dealer__c = dealer.Id,
                                      Sales_Vehicle_ID__c = vehicle.Id,
                                      Sales_Contact__c = personAccount.Id);
        sales = (Sales__c)UtilTestData.createSobject(sales, null);
        
        // Start Test
        Test.startTest();
        
        // Update sales
        sales.Valid__c = 'Yes';
        update sales;
       
        // Assert Updated Vehicle Result
        vehicle = [SELECT Latest_Sales_Person__c
                   FROM Vehicle__c
                   WHERE Id = :vehicle.Id];
        System.assertEquals(vehicle.Latest_Sales_Person__c, 'person');
       
        // Assert Updated personAccount Result
        personAccount = [SELECT Main_Dealer__c, Latest_Sales_Dealer__c
                         FROM Account
                         WHERE Id = :personAccount.Id];
        System.assertEquals(personAccount.Main_Dealer__c, dealer.Id);
        System.assertEquals(personAccount.Latest_Sales_Dealer__c, dealer.Id);
       
        // Assert Updated relationship Result
        relationship = [SELECT Selling_Dealer__c
                        FROM Vehicle_Relationship__c
                        WHERE Id = :relationship.Id];
        System.assertEquals(relationship.Selling_Dealer__c, dealer.Id);
        
        // Stop Test
        Test.stopTest();
    }
    
    public static testMethod void testTriggerSales_WithAftersales() {
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
        
        // Create Sales;
        Date dtToday = System.today();
        Sales__c sales = new Sales__c(Sales_Person__c = 'person',
                                      Sales_Dealer__c = dealer.Id,
                                      Sales_Vehicle_ID__c = vehicle.Id,
                                      Sales_Contact__c = personAccount.Id);
        sales = (Sales__c)UtilTestData.createSobject(sales, null);
        
        // Create Sales2 which has different sales dealer with sales;
        Sales__c sales2 = new Sales__c(Sales_Vehicle_ID__c = vehicle.Id,
                                       Sales_Contact__c = personAccount.Id);
        Sales2 = (Sales__c)UtilTestData.createSobject(sales2, null);
        
        // Create Sales3 which has different sales dealer with sales;
        Sales__c sales3 = new Sales__c(Sales_Vehicle_ID__c = vehicle.Id,
                                       Sales_Contact__c = personAccount.Id);
        Sales3 = (Sales__c)UtilTestData.createSobject(sales3, null);
        
        // Create Sales4 which has different sales dealer with sales;
        Sales__c sales4 = new Sales__c(Sales_Vehicle_ID__c = vehicle.Id,
                                       Sales_Contact__c = personAccount.Id);
        Sales4 = (Sales__c)UtilTestData.createSobject(sales4, null);
        
        // Create Aftersales;
        Aftersales__c aftersales = new Aftersales__c(Service_Dealer__c = dealer.Id,
                                                     Service_Vehicle__c = vehicle.Id,
                                                     Service_Contact__c = personAccount.Id);
        aftersales = (Aftersales__c)UtilTestData.createSobject(aftersales, null);
        
        // Start Test
        Test.startTest();
        
        // Update sales
        sales.Valid__c = 'Yes';
        update sales;
       
        // Assert Updated personAccount Result
        personAccount = [SELECT Main_Dealer__c, Latest_Sales_Dealer__c
                         FROM Account
                         WHERE Id = :personAccount.Id];
        System.assertEquals(personAccount.Main_Dealer__c, dealer.Id);
        System.assertEquals(personAccount.Latest_Sales_Dealer__c, dealer.Id);
        
        // Stop Test
        Test.stopTest();
    }
}