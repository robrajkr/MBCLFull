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
public class DMControllerExtensionTest {

    public static testMethod void testMyController() {
        
        User user1 = UtilTestData.createUser('IB CSR','CAC IB CSR');
        
        System.debug('-------user1-------:'+user1);
        
        System.runAs ( user1 ) {
        
        
            // Testing the eDM Send
            ApexPages.standardController controller = new ApexPages.standardController(new DM_Request__c());
            
            // Add parameters to page URL
            System.debug('--------Begin-------');
            Account customer = new Account(
                                         Phone = '13300000000',
                                         Last_Successful_Call_Office_Phone__c = System.today() - 10,
                                         DMS_Address__c = 'dmsaddress1',
                                         PersonEmail = 'test@daimler.com');
    
            customer = (Account)UtilTestData.createSobject(customer, UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);   
            
            
            ApexPages.currentPage().getParameters().put('accountId',customer.Id);
                        
            // Test click DM button from Account
            // Instantiate a new controller extension with all parameters in the page
            DMControllerExtension extension = new DMControllerExtension(controller);
            
            // Send DM
            extension.send();
            
            Task t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, OwnerId From Task t Where WhatId=:customer.Id Order by Id Desc Limit 1];
            System.assertEquals(t.Subject,'DM');
            System.assertEquals(t.Status,'Closed');
            System.assertEquals(t.OwnerId,user1.Id);
            System.assertEquals(t.WhoId,[Select Id From Contact Where accountId = :customer.Id].Id);
            
            //Test click eDM button from Case
            Case case1 = new Case(AccountId=customer.Id, Subject='Case-'+Datetime.now().formatLong());
            insert case1;
            ApexPages.currentPage().getParameters().put('caseId',case1.Id);
            
            extension = new DMControllerExtension(controller);
            
            // Send DM
            extension.send();
            
            t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, OwnerId From Task t Where WhatId=:case1.Id Order by Id Desc Limit 1];
            System.assertEquals(t.Subject,'DM');
            System.assertEquals(t.Status,'Closed');
            System.assertEquals(t.OwnerId,user1.Id);
            System.assertEquals(t.WhoId,[Select Id From Contact Where accountId = :customer.Id].Id);
            System.assertEquals(t.WhatId,case1.Id);
            
            // Cover Exception
	        controller = new ApexPages.standardController(new DM_Request__c());
	        extension = new DMControllerExtension(controller);
	      	// runAs readonly user
	        User user2 = UtilTestData.createUser('IB CSR','Read Only');
	        System.runAs ( user2 ) {  
	            extension.send();
	        }
        }
    }
}