/*
    Type:       Test class
    Purpose:    Test Class for Account Merge
    User Story: US-DD-002
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-3-06
*/
@isTest
public class AccountMergeControllerTest {
    // Senario 1
    // Click Merge button on Master detail page
    public static testMethod void testAccountMerge_Master() {
        Account master = new Account(Master_Record__c = true, 
                                     DUP_Nummer__c = '110',
                                     Phone = '13911111111',
                                     Last_Successful_Call_Office_Phone__c = System.today() - 10,
                                     DMS_Address__c = 'dmsaddress1');
                                     
        Account slave = new Account(Master_Record__c = false, 
                                    DUP_Nummer__c = '110',
                                    Phone = '13922222222',
                                    Last_Successful_Call_Office_Phone__c = System.today(),
                                    DMS_Address__c = 'dmsaddress2');
        
        master = (Account)UtilTestData.createSobject(master, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        slave = (Account)UtilTestData.createSobject(slave, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Start Test
        Test.startTest();
        
        PageReference selectSlavePR = new PageReference('/apex/SelectSlaveAccount?' + master.Id);
        Test.setCurrentPage(selectSlavePR);
        AccountMergeController selectSlave = new AccountMergeController(
           new ApexPages.StandardController(master));
        
        // Master has only one Suspect Account: slave
        System.assert(selectSlave.slaves.size() == 1);
        
        // Redirect page to Account Merge Page
        PageReference mergePR = new PageReference('/apex/AccountMerge?Id=' + 
           master.Id + '&slaveId=' + 
           slave.Id + '&retURL=/apex/SelectSlaveAccount?Id=' + 
           master.Id);
        Test.setCurrentPage(mergePR);
        
        AccountMergeController accountMerge = new AccountMergeController(
            new ApexPages.StandardController(master));
        
        // Choose all master value as default
        accountMerge.selectAllParam = 'master';
        accountMerge.selectAll(); 
        accountMerge.mergeAccount();
        Account mergedMaster = [SELECT Phone, DMS_Address__c 
                                FROM Account WHERE Id = :master.Id];
        System.assert(mergedMaster.Phone == '13911111111');
        
        accountMerge.previous();
        
        // Stop Test
        Test.stopTest();
    }
    
    // Senario 2
    // Click Merge button on Slave detail page
    public static testMethod void testAccountMerge_Slave() {
        Account master = new Account(Master_Record__c = true, 
                                     DUP_Nummer__c = '110',
                                     Phone = '13911111111', 
                                     Type = 'Company',
                                     DMS_Address__c = 'dmsaddress1');
                                     
        Account slave = new Account(Master_Record__c = false, 
                                    DUP_Nummer__c = '110',
                                    Phone = '13922222222',
                                    Type = 'Personal',
                                    DMS_Address__c = 'dmsaddress2');
        
        master = (Account)UtilTestData.createSobject(master, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        slave = (Account)UtilTestData.createSobject(slave, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Start Test
        Test.startTest();
        
        // Redirect page to Account Merge Page
        PageReference mergePR = new PageReference('/apex/AccountMerge?Id=' + 
           slave.Id + '&retURL=/' + 
           master.Id);
        Test.setCurrentPage(mergePR);
        
        AccountMergeController accountMerge = new AccountMergeController(
            new ApexPages.StandardController(slave));
        
        // Choose all slave value as default   
        accountMerge.selectAllParam = 'slave';
        accountMerge.selectAll(); 
        accountMerge.mergeAccount();
        
        Account mergedMaster = [SELECT Phone, DMS_Address__c 
                                FROM Account WHERE Id = :master.Id];
        System.assert(mergedMaster.Phone == '13922222222');
                
        // Stop Test
        Test.stopTest();
    }
    
    // Senario 3
    // Click Merge button on Non-Slave detail page
    public static testMethod void testAccountMerge_NonSlave() {
        Account master = new Account(Master_Record__c = true, 
                                     DUP_Nummer__c = '110',
                                     Phone = '13911111111',
                                     Last_Successful_Call_Office_Phone__c = System.today() - 10,
                                     DMS_Address__c = 'dmsaddress1');
                                    
        Account nonslave = new Account(Phone = '13933333333', 
                                       Master_Record__c = false, 
                                       DUP_Nummer__c = '120');
        
        master = (Account)UtilTestData.createSobject(master, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        nonslave = (Account)UtilTestData.createSobject(nonslave, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Start Test
        Test.startTest();
        
        // Redirect page to Account Merge Page
        PageReference mergePR = new PageReference('/apex/AccountMerge?Id=' + 
           nonslave.Id + '&retURL=/' + 
           master.Id);
        Test.setCurrentPage(mergePR);
        
        AccountMergeController accountMerge = new AccountMergeController(
            new ApexPages.StandardController(nonslave));
        
        System.assert(accountMerge.hasMessage == true);

        // Stop Test
        Test.stopTest();
    }
    
    public static testMethod void testSelectSlaveAccount_NoSlave() {
        Account master = new Account(Master_Record__c = true, 
                                     DUP_Nummer__c = '110',
                                     Phone = '13911111111',
                                     DMS_Address__c = 'dmsaddress1');
        master = (Account)UtilTestData.createSobject(master, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Start Test
        Test.startTest();
        
        PageReference selectSlavePR = new PageReference('/apex/SelectSlaveAccount?' + master.Id);
        Test.setCurrentPage(selectSlavePR);
        AccountMergeController selectSlave = new AccountMergeController(
           new ApexPages.StandardController(master));
        System.assert(selectSlave.hasSuspectAccounts == false);
        
        // Stop Test
        Test.stopTest();
    }
}