/*
    Type:       Trigger on Sales
    Purpose:    If Sales "Valid" is changed to "True", the corresponding fields of Vehicle, 
                Vehicle Relationship and Customer should be updated according to fields of this sales.
    User Story: US-CP-012
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
*/
trigger TriggerSales on Sales__c(after update) {
    if (trigger.isUpdate && trigger.isAfter) {
        Map<Id, Sales__c> vehicleMap = new Map<Id, Sales__c>();
        Map<Id, Sales__c> accIdSOMap = new Map<Id, Sales__c>();
        List<Sales__c> validSales = new List<Sales__c>();
        
        for (Sales__c sales : trigger.new) {
            Sales__c oldSales = trigger.oldMap.get(sales.Id);
            if (oldSales.Valid__c != 'Yes' && sales.Valid__c == 'Yes') {
                validSales.add(sales);
                vehicleMap.put(sales.Sales_Vehicle_ID__c, sales);
                accIdSOMap.put(sales.Sales_Contact__c, sales);
            }
        }
        
        // Update corresponding Vehicle, Vehicle Relationship and Customer
        if (validSales.size() > 0) {
            UtilSales.updateVehicle(validSales);
            UtilSales.updateVehicleRelationship(vehicleMap, FieldMappingConstant.SALES_FIELD_MAPPING_MAP);
            UtilSales.updateAccount(accIdSOMap, 'Sales');
        }
    }
}