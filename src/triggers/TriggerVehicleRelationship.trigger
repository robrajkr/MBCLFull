/*
    Type:       Trigger on Vehicle_Relationship__c
    Purpose:    If Vehicle_Relationship__c Validity has change, just assign the changed value to 
                corresponding Vehicle
    User Story: US-CP-008
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
*/
trigger TriggerVehicleRelationship on Vehicle_Relationship__c(after update) {
    if (trigger.isUpdate && trigger.isAfter) {
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle_Relationship__c relationship : trigger.new) {
            Vehicle_Relationship__c oldRelationship = trigger.oldMap.get(relationship.Id);
            if (oldRelationship.Validity__c != relationship.Validity__c) {
                vehicleIds.add(relationship.Vehicle_Id__c);
            }
            
            if (vehicleIds.size() > 0) {
                UtilVehicleRelationship.updateVehicle(vehicleIds);
            }
        }
    }
}