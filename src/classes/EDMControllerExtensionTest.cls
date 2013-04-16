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
public class EDMControllerExtensionTest {

    public static testMethod void testMyController() {
        
        User user1 = UtilTestData.createUser('IB CSR','CAC IB CSR');
        
        System.debug('-------user1-------:'+user1);
        
        System.runAs ( user1 ) {
        
        
            // Testing the eDM Send
            ApexPages.standardController controller = new ApexPages.standardController(new eDM__c());
            
            // Add parameters to page URL
            System.debug('--------Begin-------');
            Account customer = new Account(
                                         Phone = '13300000000',
                                         Last_Successful_Call_Office_Phone__c = System.today() - 10,
                                         DMS_Address__c = 'dmsaddress1',
                                         PersonEmail = 'test@daimler.com');
    
            customer = (Account)UtilTestData.createSobject(customer, UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);   
            
            
            ApexPages.currentPage().getParameters().put('accountId',customer.Id);
            
            //Create new eDM Template
            String rdid = [Select r.SobjectType, r.Name, r.Id From RecordType r Where Name='eDM' and SobjectType='Template__c'][0].Id;
            Template__c edmt = new Template__c(Type__c='Price List', Car_Series__c='A-Class', RecordTypeId=rdid);
            Insert edmt;
            edmt = [Select Id,Name From Template__c Where Id=:edmt.Id];
            System.assertEquals(edmt.Name,'A-Class - Price List');
            
            // Test click eDM button from Account
            // Instantiate a new controller extension with all parameters in the page
            EDMControllerExtension extension = new EDMControllerExtension(controller);
            extension.edm.eDM_Template__c = edmt.Id;
            
            // Send eDM
            extension.send();
            
            Task t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, t.eDM_Template__c,Email_Address__c,OwnerId From Task t Where WhatId=:customer.Id and eDM_Template__c=:edmt.Name];
            System.assertEquals(t.Subject,'eDM');
            System.assertEquals(t.Status,'Closed');
            System.assertEquals(t.OwnerId,user1.Id);
            System.assertEquals(t.Email_Address__c,'test@daimler.com');
            System.assertEquals(t.WhoId,[Select Id From Contact Where accountId = :customer.Id].Id);
            
                        
            //Test click eDM button from Case
            Case case1 = new Case(AccountId=customer.Id, Subject='Case-'+Datetime.now().formatLong());
            insert case1;
            ApexPages.currentPage().getParameters().put('caseId',case1.Id);
            
            extension = new EDMControllerExtension(controller);
            //extension.edm.eDM_Template__c = 'Price List' + Datetime.now().formatLong();
            
            // Send eDM
            extension.send();
            
            t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, t.eDM_Template__c,Email_Address__c,OwnerId From Task t Where WhatId=:case1.Id and eDM_Template__c=:edmt.Name];
            System.assertEquals(t.Subject,'eDM');
            System.assertEquals(t.Status,'Closed');
            System.assertEquals(t.OwnerId,user1.Id);
            System.assertEquals(t.Email_Address__c,'test@daimler.com');
            System.assertEquals(t.WhoId,[Select Id From Contact Where accountId = :customer.Id].Id);
            System.assertEquals(t.WhatId,case1.Id);
        
            // Cover Exception
	        //PageReference pr  = new PageReference('/apex/EDMSendResult?accountId='+customer.Id);
	        //Test.setCurrentPage(pr);
	        controller = new ApexPages.standardController(new eDM__c());
	        extension = new eDMControllerExtension(controller);
	      	// runAs readonly user
	        User user2 = UtilTestData.createUser('IB CSR','Read Only');
	        System.runAs ( user2 ) {  
	            extension.send();
	        }
        }
    }
}