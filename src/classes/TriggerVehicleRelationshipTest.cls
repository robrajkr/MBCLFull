/*
    Type:       Test class
    Purpose:    Test Class for TriggerVehicleRelationship.trigger
    User Story: US-CP-008
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-06
*/
@isTest
public class TriggerVehicleRelationshipTest {
    public static testMethod void testTriggerVehicleRelationship() {
        UtilTestData testUtil = new UtilTestData();
        // Create Dealer
        Account dealer = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_DEALER);
        
        // Create Person Account
        Account personAccount = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Create Vehicle
        Vehicle__c vehicle = (Vehicle__c)UtilTestData.createSobject(new Vehicle__c(), null);
        
        // Create Vehicle Relationship
        Vehicle_Relationship__c relationship = new Vehicle_Relationship__c();
        relationship.Vehicle_ID__c = vehicle.Id;
        relationship.Contact__c = personAccount.Id;
        relationship.Selling_Dealer__c = dealer.Id;
        relationship = (Vehicle_Relationship__c)UtilTestData.createSobject(relationship, null);
        
        // Create Vehicle Relationship
        Vehicle_Relationship__c relationship2 = new Vehicle_Relationship__c();
        relationship2.Vehicle_ID__c = vehicle.Id;
        relationship2.Contact__c = personAccount.Id;
        relationship2.Selling_Dealer__c = dealer.Id;
        relationship2 = (Vehicle_Relationship__c)UtilTestData.createSobject(relationship2, null);

        // Start Test
        Test.startTest();

        // Test TriggerVehicleRelationship
        // Vehicle has two child relationships, if any one is Yes,
        // vehicle Valid is Yes
        relationship.Validity__c = 'Yes';
        update relationship;
        System.assert([SELECT Valid__c 
                       FROM Vehicle__c 
                       WHERE Id = :vehicle.Id].Valid__c == 'Yes');
        
        // Two child Relationship records, one is No, one is Unknown,
        // so Vehicle Valid is Unkown
        relationship.Validity__c = 'No';
        update relationship;
        System.assert([SELECT Valid__c 
                       FROM Vehicle__c 
                       WHERE Id = :vehicle.Id].Valid__c == 'Unknown');

        // Two child Relationship records, both are no,
        // so Vehicle Valid is No
        relationship2.Validity__c = 'No';
        update relationship2;
        System.assert([SELECT Valid__c 
                       FROM Vehicle__c 
                       WHERE Id = :vehicle.Id].Valid__c == 'No');

        // Stop Test
        Test.stopTest();
    }
}