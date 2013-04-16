/*
    Type:       Utility for TriggerSales and TriggerAftersales
    Purpose:    If Sales/Aftersales has change, just update Account, 
                Vehicle and Vehicle Relationship corresponding fields 
                according to related Sales/Aftersales.
    User Story: US-CP-014, US-CP-12
    Used By:    TriggerSales, TriggerAftersales
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
    2. Mouse Stop populating "Latest Handover Date", "Latest Contract Date" 
       and "Latest Invoice Date" on related vehicle record on 2013-03-19
*/
public class UtilSales {
    private static void updateSobjects(List<Sobject> sos) {
        try {
            update sos;
        }
        catch (DMLException e) {
            trigger.new[0].addError(e.getDMLMessage(0));
            System.debug('UtiSales DMLException Exception: ' + e);
        }
    }
    
    // Update the corresponding Vehicle by valid sales
    public static void updateVehicle(List<Sales__c> validSales) {
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        for (Sales__c sale : validSales) {
            Vehicle__c vehicle = new Vehicle__c(
                Id = sale.Sales_Vehicle_ID__c,
                Latest_Sales_Person__c = sale.Sales_Person__c
            );
            vehicles.add(vehicle);
        }
        
        updateSobjects(vehicles);
    }
    
    // Update all related Vehicle Relationship records by the valid Sales/valid Aftersales
    public static void updateVehicleRelationship(Map<Id, Sobject> vehicleIdSOMap, 
                                                 Map<String, String> fieldMappingMap) {
        List<Vehicle_Relationship__c> relationships = 
            new List<Vehicle_Relationship__c>();
        // If more relationship fields need to update, we just need to 
        // change the mapping constant in constant class 
        for (Vehicle__c vehicle : [SELECT Id, (SELECT Id FROM Vehicle_Relationships__r)
                                   FROM Vehicle__c
                                   WHERE Id IN :vehicleIdSOMap.keySet()]) {
            // Get the valid Sales by vehicle Id
            Sobject so = vehicleIdSOMap.get(vehicle.Id);
            
            // Update all related Vehicle Relationship records by the valid Sales
            for (Vehicle_Relationship__c relationship : vehicle.Vehicle_Relationships__r) {
                for (String vehicleRelationshipField : fieldMappingMap.keySet()) {
                    // Populate the vehicle relationship field value with 
                    // corresponding Sales/Aftersales field value
                    relationship.put(vehicleRelationshipField, 
                        so.get(fieldMappingMap.get(vehicleRelationshipField)));
                }
                
                relationships.add(relationship);
            }
            
            updateSobjects(relationships);
        }
    }
    
    // If this method is invoked in Sales Trigger, fix = 'Sales'
    // If this method is invoked in Aftersales trigger, fix = 'Service'
    public static void updateAccount(Map<Id, Sobject> accIdSOMap, String fix) {
        List<Account> accs = new List<Account>();
        for (Account acc : [SELECT Id, Latest_Sales_Dealer__c, Main_Dealer__c,
                                   (SELECT Sales_Dealer__c 
                                    FROM Sales_Person_Account__r),
                                   (SELECT Service_Dealer__c 
                                    FROM Aftersales__r)
                            FROM Account
                            WHERE Id IN :accIdSOMap.keySet()]) {
            // Update Latest Sales Dealer by Sales or Aftersales
            acc.put('Latest_' + fix + '_Dealer__c', 
                accIdSOMap.get(acc.Id).get(fix + '_Dealer__c'));
            
            // Count all valid "Sales" and "Aftersales" record related to this account, 
            //   and update the Account "Main Dealer" with the main used dealer.
            acc.Main_Dealer__c = getMainDealer(acc.Sales_Person_Account__r, 
                                               acc.Aftersales__r);
            accs.add(acc);
        }
        
        updateSobjects(accs);
    }
    
    public static Id getMainDealer(List<Sales__c> sales, 
                                   List<Aftersales__c> aftersales) {
        List<Id> dealerIds = new List<Id>();
        // Add sales dealer into accIds list
        for (Sales__c sale : sales) {
            dealerIds.add(sale.Sales_Dealer__c);
        }
        
        // Add service dealer into accs list
        for (Aftersales__c aftersale : aftersales) {
            dealerIds.add(aftersale.Service_Dealer__c);
        }
        
        // Populate the map with dealerId and corresponding frequency
        Map<Id, Integer> dealerIdFrequencyMap = new Map<Id, Integer>();
        for (Id dealerId : dealerIds) {
            Integer count = dealerIdFrequencyMap.get(dealerId);
            dealerIdFrequencyMap.put(dealerId, count == null ? 1 : ++count);
        }
        System.debug('dealerIdFrequencyMap=>' + dealerIdFrequencyMap);
        
        // Get the mainDealerId by comparing their frequency
        Id mainDealerId = null;
        for (Id dealerId : dealerIdFrequencyMap.keySet()) {       
            if (mainDealerId == null) {
                mainDealerId = dealerId;
            }
            else {
                if (dealerIdFrequencyMap.get(mainDealerId) < 
                        dealerIdFrequencyMap.get(dealerId)) {
                    mainDealerId = dealerId;
                }
            }
        }
        
        return mainDealerId;
    }
}