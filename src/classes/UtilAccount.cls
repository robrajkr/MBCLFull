/*
    Type:       Utility for TriggerAccount
    Purpose:    Link Dealer to Dealer City by City CN and Province 
    User Story: US-DS-001
    Used By:    TriggerAccount.trigger
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-28
*/
public class UtilAccount {
    public static void linkDealerCity(List<Account> triggerNew, Id dealerRecordTypeId) {
        if (trigger.isUpdate && trigger.isBefore && trigger.isExecuting) {
            // Get cities, provinces and the dealer 
            // which city or province has change
            Set<Id> dealerIdSet = new Set<Id>();
            Set<String> cities = new Set<String>();
            Set<String> provinces = new Set<String>();

            for (Account acc : triggerNew) {
                // Get the dealer which City CN or Province has change
                Account oldAcc = (Account) trigger.oldMap.get(acc.Id);
                if (acc.RecordTypeId == dealerRecordTypeId && 
                        (acc.City_CN__c != oldAcc.City_CN__c ||
                         acc.Province__c != oldAcc.Province__c)) {
                    dealerIdSet.add(acc.Id);

                    // Populate cities and provinces
                    if (acc.City_CN__c != null) {
                        cities.add(acc.City_CN__c);
                    }

                    if (acc.Province__c != null) {
                        provinces.add(acc.Province__c);
                    }
                }
            }

            // Dealer City Name + Province => Dealer City Id
            Map<String, Id> cityProvince2DealerCityId = 
                new Map<String, Id>();
            for (Dealer_City__c dealerCity : [SELECT Id, Name, Province__c 
                                              FROM Dealer_City__c
                                              WHERE Name IN :cities
                                              AND Province__c IN :provinces]) {
                cityProvince2DealerCityId.put(
                    dealerCity.Name + dealerCity.Province__c, dealerCity.Id);
            }
            System.debug(cityProvince2DealerCityId);

            // Populate dealerCityId by cityProvince2DealerCityId
            for (Account dealer : triggerNew) {
                if (dealerIdSet.contains(dealer.Id)) {
                    dealer.Dealer_City__c = cityProvince2DealerCityId.get(
                        dealer.City_CN__c + dealer.Province__c);
                }
            }
        }
    }
}