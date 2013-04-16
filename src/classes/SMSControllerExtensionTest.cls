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
@isTest(SeeAllData=true)
public class SMSControllerExtensionTest {

    public static testMethod void testSMSControllerExtension() 
    {
        // Testing the SMS Send
        ApexPages.standardController controller = new ApexPages.standardController(new SMS__c());
        
        // Add parameters to page URL
        String personAccountRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String dealerRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account customer = new Account(LastName = 'Acme Customer', Phone = '01088888888', RecordTypeId = personAccountRecordTypeId);
        insert customer;
        Account dealer = new Account(Name = 'Acme Dealer', Phone = '01088888888', RecordTypeId = dealerRecordTypeId);
        insert dealer;
        //String accountId = [Select Id, PersonMobilePhone, Name From Account where isPersonAccount = true Limit 1][0].Id;
        ApexPages.currentPage().getParameters().put('accountId',customer.Id);
        ApexPages.currentPage().getParameters().put('retURL',customer.Id);
        
        // Test click SMS button from Account
        // Instantiate a new controller extension with all parameters in the page
        SMSControllerExtension extension = new SMSControllerExtension(controller);
        extension.sms.Dealer__c = dealer.Id;
        extension.templateId = [select Id, Name, Message_Detail__c from Template__c where RecordType.SObjectType='Template__c' and RecordType.Name='SMS' and Active__c = true limit 1].Id;
        List<SelectOption> Templates = extension.getTemplates();
        extension.parseTemplateMessage();
        String message = extension.optimzeContent('temp{DEALER_NAME}temp');
    
        // Send SMS
        extension.send();
        
        Task t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, t.SMS_Content__c From Task t Where WhatId=:customer.Id and SMS_Content__c=:extension.templateMessage];
        System.assertEquals(t.Subject, 'SMS');
        System.assertEquals(t.Status, 'Closed');
        System.assertEquals(t.WhoId, [Select Id From Contact Where accountId = :customer.Id limit 1].Id);
        
        //Test click SMS button from Case
        String inquiryRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Inquiry').getRecordTypeId();
        Case cas = new Case(AccountId = customer.Id, Subject = 'acme', RecordTypeId = inquiryRecordTypeId);
        insert cas;
        ApexPages.currentPage().getParameters().put('caseId', cas.Id);
        ApexPages.currentPage().getParameters().put('accountId', customer.Id);
        ApexPages.currentPage().getParameters().put('retURL', cas.Id);
        
        extension = new SMSControllerExtension(controller);
        extension.sms.Dealer__c = dealer.Id;
        extension.templateId = [select Id, Name, Message_Detail__c from Template__c where RecordType.SObjectType='Template__c' and RecordType.Name='SMS' and Active__c = true limit 1].Id;
        Templates = extension.getTemplates();
        extension.parseTemplateMessage();
        message = extension.optimzeContent('temp{DEALER_NAME}temp');
        
        // Send SMS
        extension.send();
        
        t = [Select t.WhoId, t.WhatId, t.Subject, t.Status, t.SMS_Content__c From Task t Where WhatId = :cas.Id and SMS_Content__c=:extension.templateMessage];
        System.assertEquals(t.Subject, 'SMS');
        System.assertEquals(t.Status, 'Closed');
        Contact personContact = [select Id from Contact where AccountId = :customer.Id limit 1];
        System.assertEquals(t.WhoId, personContact.Id);
    }
}