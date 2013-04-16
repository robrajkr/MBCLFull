/*
    Type:       Trigger on Aftersales   
    Purpose:    If Aftersales "Valid" is changed to "True", the corresponding fields of Vehicle Relationship 
                and Customer should be updated according to fields of this sales.
    User Story: US-CP-014
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
*/

trigger TriggerAftersales on Aftersales__c(after update) {
    if (trigger.isUpdate && trigger.isAfter) {
        Map<Id, Aftersales__c> vehicleIdSOMap = new Map<Id, Aftersales__c>();
        Map<Id, Aftersales__c> accIdSOMap = new Map<Id, Aftersales__c>();
        
        for (Aftersales__c aftersales : trigger.new) {
            Aftersales__c oldAftersales = trigger.oldMap.get(aftersales.Id);
            if (!oldAftersales.Valid__c && aftersales.Valid__c) {
                vehicleIdSOMap.put(aftersales.Service_Vehicle__c, aftersales);
                accIdSOMap.put(aftersales.Service_Contact__c, aftersales);
            }
        }
        
        // Update corresponding Vehicle Relationship and Customer
        if (vehicleIdSOMap.size() > 0) {
            UtilSales.updateVehicleRelationship(vehicleIdSOMap, 
                FieldMappingConstant.AFTERSALES_FIELD_MAPPING_MAP);
            UtilSales.updateAccount(accIdSOMap, 'Service');
        }
    }
}