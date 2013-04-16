@isTest
public class DealerSearchControllerTest {
    public static testMethod void testDealerSearch_QueryException() {
        // Test DealerSearch
        PageReference pr  = new PageReference('/apex/DealerSearch');
        Test.setCurrentPage(pr);
        DealerSearchController dealerSearch = new DealerSearchController(
            new ApexPages.StandardController(new Account()));
        System.assert(dealerSearch.dealer.Province__c == null);
        System.assert(dealerSearch.dealer.City_CN__c == null);
    }
    
    public static testMethod void testDealerSearch() {
        // Create dealer
        Account dealer = new Account(Name = '上海test',
                                     Province__c = 'Shanghai',
                                     City_CN__c = '徐汇区',
                                     Dealer_Sales_Type__c = 'MBCL;Smart',
                                     Dealer_Service_Codes__c = 'Sales;Parts');
        dealer = (Account)UtilTestData.createSobject(dealer, UtilTestData.ACCOUNT_RT_DEALER);
        
        // Create Person Account
        Account personAccount = new Account(Province__c = 'Shanghai',
                                            City_CN__c = '徐汇区');
        personAccount = (Account)UtilTestData.createSobject(personAccount, 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);
        
        // Start Test
        Test.startTest();
        
        // Test DealerSearch
        PageReference pr  = new PageReference('/apex/DealerSearch?Id=' + personAccount.Id);
        Test.setCurrentPage(pr);
        DealerSearchController dealerSearch = new DealerSearchController(
            new ApexPages.StandardController(personAccount));
        System.assert(dealerSearch.dealers.size() == 1, 'Searched Dealers Size != 1');
        
        // Change name
        dealerSearch.name = '上海';
        dealerSearch.query();
        System.assert(dealerSearch.dealers.size() == 1, 'Searched Dealers Size != 1');
        
        // Change Dealer_Sales_Type__c
        dealerSearch.dealer.Province__c = null;
        dealerSearch.query();
        System.assert(dealerSearch.dealers.size() == 1, 'Searched Dealers Size != 1');
        
        // Change Dealer_Sales_Type__c
        dealerSearch.dealer.Dealer_Sales_Type__c = 'MBCL;Smart';
        dealerSearch.query();
        System.assert(dealerSearch.dealers.size() == 1, 'Searched Dealers Size != 1');
        
        // Change Dealer_Service_Codes__c
        // Service is in 'Sales;Parts'
        dealerSearch.dealer.Dealer_Service_Codes__c = 'Service';
        dealerSearch.query();
        System.assert(dealerSearch.dealers.size() == 0, 'Searched Dealers Size != 0');
        
        // Stop Test
        Test.stopTest();
    }
}