/*
    Type:       Test Class
    Purpose:    Test Class CarModelComparisonController
    User Story: US-Knowledge-003
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-11
*/
@isTest
public class CarModelComparisonControllerTest {
	public static testMethod void testCarModelComparison() {
		// Create Person Account
        Account personAccount = (Account)UtilTestData.createSobject(new Account(), 
            UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT);

		// Create Car Models
		List<Car_Model__c> carModels = new List<Car_Model__c>();
		for (Integer i = 0; i < 3; i++) {
			carModels.add(new Car_Model__c());
		}
		carModels = (List<Car_Model__c>)UtilTestData.createSobjects(carModels, null);

		// Create Attributes
		List<Attribute__c> attrs = new List<Attribute__c>();
		for (Integer i = 0; i < UtilTestData.BATCH_SIZE; i++) {
			attrs.add(new Attribute__c());
		}
		attrs = (List<Attribute__c>)UtilTestData.createSobjects(attrs, null);

		// Create Car Model Attributes by attributes and car models
		List<Car_Model_Attribute__c> modelAttrs = new List<Car_Model_Attribute__c>();
		for (Integer i = 0; i < UtilTestData.BATCH_SIZE; i++) {
			for (Car_Model__c model : carModels) {
				Car_Model_Attribute__c modelAttr = new Car_Model_Attribute__c(
	                Car_Model__c = model.Id,
	                Attribute__c = attrs[i].Id
	            );
	            modelAttrs.add(modelAttr);
	        }
		}
		modelAttrs = (List<Car_Model_Attribute__c>)UtilTestData.createSobjects(modelAttrs, null);

		// Test Start
        Test.startTest();

        PageReference pr = new PageReference('/apex/CarModelComparison/?retURL=/' + 
            personAccount.Id);
        Test.setCurrentPage(pr);
        CarModelComparisonController comparison = new CarModelComparisonController();
        
        for (Integer i = 0; i < 3; i++) {
        	comparison.proxies[i].Car_Model__c = carModels[i].Id;
        }

        comparison.compare();
        System.assert(comparison.chosenProxies.size() == 3);

        comparison.cancel();

		// Test Stop
		Test.stopTest();
	}
}