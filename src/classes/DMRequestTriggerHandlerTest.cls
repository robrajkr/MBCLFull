/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DMRequestTriggerHandlerTest {
    
    public static testMethod void testMyController() {
        
        User user1 = UtilTestData.createUser('Fulfillment Specialist','CAC Fulfillment User');
        
        System.debug('-------user1-------:'+user1);
        
        System.runAs ( user1 ) {
            
            //Prepare new DM Materials
            //DM Material1 openning stock is 10
            //DM Material2 openning stock is 20
            //DM Material3 openning stock is 30


            // DM Material
            DM_Material__c dm1 = new DM_Material__c(Name='TEST DM 1'+DateTime.now().formatLong(),Active__c=true);
            DM_Material__c dm2 = new DM_Material__c(Name='TEST DM 2'+DateTime.now().formatLong(),Active__c=true);
            DM_Material__c dm3 = new DM_Material__c(Name='TEST DM 3'+DateTime.now().formatLong(),Active__c=true);
            
            insert dm1;
            insert dm2;
            insert dm3;
            
            //init openning stock
            DM_Stock_Flow__c dsf1 = new DM_Stock_Flow__c(Stock_Type__c='Increase Stock', Valid__c=true, Material_Name__c=dm1.Id,Quantity__c=10);
            DM_Stock_Flow__c dsf2 = new DM_Stock_Flow__c(Stock_Type__c='Increase Stock', Valid__c=true, Material_Name__c=dm2.Id,Quantity__c=20);
            DM_Stock_Flow__c dsf3 = new DM_Stock_Flow__c(Stock_Type__c='Increase Stock', Valid__c=true, Material_Name__c=dm3.Id,Quantity__c=30);
            
            insert dsf1;
            insert dsf2;
            insert dsf3;
            
            dm1 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm1.Id];
            dm2 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm2.Id];
            dm3 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm3.Id];
            
            System.assertEquals(dm1.Stock__c, 10);
            System.assertEquals(dm2.Stock__c, 20);
            System.assertEquals(dm3.Stock__c, 30);
            
            
            //DM Request Test Scenarios:
            //1. Status not equals 'Sent'
            //2. Status equals 'Sent' but not changed
            //3. Status changed to 'Sent' (DM Material1=M1, DM Material2=M2, DM Material3=M3)
            //3.1 M1=value1, M2=value2, M3=value3
            //3.2 M1=M2=M3=value1
            
            Account customer = new Account(
                                     Phone = '13300000000',
                                     Last_Successful_Call_Office_Phone__c = System.today() - 10,
                                     DMS_Address__c = 'dmsaddress1');

            customer = (Account)UtilTestData.createSobject(customer, UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);        
            
            // Scenario 1:
            System.debug('--------Scenario 1--------');
            DM_Request__c dmr1 = new DM_Request__c(Actual_DM_Material1__c=dm1.Id, Status__c='Open', Customer_Name__c=customer.Id );
            insert dmr1;
            dm1 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm1.Id];
            System.assertEquals(dm1.Stock__c, 10);
            
            // Scenario 3.1
            System.debug('--------Scenario 3.1--------');
            dmr1.Actual_DM_Material1__c = dm1.Id;
            dmr1.Actual_DM_Material2__c = dm2.Id;
            dmr1.Actual_DM_Material3__c = dm3.Id;
            dmr1.Status__c = 'Sent';
            update dmr1;
            dm1 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm1.Id];
            dm2 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm2.Id];
            dm3 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm3.Id];
            System.assertEquals(dm1.Stock__c, 9);
            System.assertEquals(dm2.Stock__c, 19);
            System.assertEquals(dm3.Stock__c, 29);
            
            // Scenario 2
            System.debug('--------Scenario 2--------');
            dmr1.Comment__c = 'Scenario 2';
            update dmr1;
            dm1 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm1.Id];
            dm2 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm2.Id];
            dm3 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm3.Id];
            System.assertEquals(dm1.Stock__c, 9);
            System.assertEquals(dm2.Stock__c, 19);
            System.assertEquals(dm3.Stock__c, 29);
            System.assertEquals(dmr1.Comment__c, 'Scenario 2');
            
            // Scenario 3.2
            System.debug('--------Scenario 3.2--------');
            DM_Request__c dmr2 = new DM_Request__c(Actual_DM_Material1__c=dm2.Id, Actual_DM_Material2__c=dm2.Id, Actual_DM_Material3__c=dm2.Id, Status__c='Sent', Customer_Name__c=customer.Id);
            insert dmr2;
            dm1 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm1.Id];
            dm2 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm2.Id];
            dm3 = [Select Id,Name,Stock__c From DM_Material__c Where Id=:dm3.Id];
            System.assertEquals(dm1.Stock__c, 9);
            System.assertEquals(dm2.Stock__c, 16);
            System.assertEquals(dm3.Stock__c, 29);
            
        }
                
    }
    
}