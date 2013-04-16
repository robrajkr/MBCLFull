/*
    Type:       Test Class for TriggerAccount
    Purpose:    Link Dealer to Dealer City by City CN and Province 
    User Story: US-DS-001
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-28
*/
@isTest
private class TriggerAccountTest {
    public static testMethod void linkDealerCityTest() {
        // Create Dealer
        Account dealer = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_DEALER);

        // Create Dealer City
        Dealer_City__c dealerCity = new Dealer_City__c(
            Name = '东城区',
            Province__c = '北京',
            Region__c = 'N'
        );
        dealerCity = (Dealer_City__c)UtilTestData.createSobject(dealerCity, null);

        // Update Dealer City CN and Province according to dealerCity
        dealer.City_CN__c = '东城区';
        dealer.Province__c = '北京';
        update dealer;

        // Assert updated Dealer City of Dealer is eqauals with dealerCity
        dealer = [SELECT Dealer_City__c FROM Account WHERE Id = :dealer.Id];
        System.assert(dealer.Dealer_City__c == dealerCity.Id);

        // Update dealer City CN and province to other value
        dealer.City_CN__c = '朝阳区';
        update dealer;

        // Assert updated Dealer City of Dealer is eqauals with dealerCity
        dealer = [SELECT Dealer_City__c FROM Account WHERE Id = :dealer.Id];
        System.assert(dealer.Dealer_City__c == null);
    }
}