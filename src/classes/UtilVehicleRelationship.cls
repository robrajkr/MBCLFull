/*
    Type:       Utility for TriggerVehicleRelationship
    Purpose:    If Vehicle_Relationship__c record has change, just assign the changed value to 
                corresponding Vehicle
    User Story: US-CP-008
    Used By:    TriggerVehicleRelationship
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
*/
public class UtilVehicleRelationship {
    public static void updateVehicle(Set<Id> vehicleIds) {
        List<Vehicle__c> vehicles = [SELECT Id, Valid__c,
                                            (SELECT Id, Validity__c
                                             FROM Vehicle_Relationships__r) 
                                     FROM Vehicle__c 
                                     WHERE Id IN :vehicleIds];
        // For loop vehicles
        for (Vehicle__c vehicle : vehicles) {
            Set<String> validSet = new Set<String>();
            for (Vehicle_Relationship__c relationship : 
                    vehicle.Vehicle_Relationships__r) {
                validSet.add(relationship.Validity__c);
            }

            // Add vehicle which needs updation to list
            if (validSet.contains('Yes')) {
                vehicle.Valid__c = 'Yes';
            }
            // If all vehicle relationships is not Yes and one is unknown,
            // update vehicle to unknown
            else if (!validSet.contains('Yes') && 
                      validSet.contains('Unknown')) {
                vehicle.Valid__c = 'Unknown';
            }
            // If all vehicle relationship ares not Yes and unknown,
            // update vehicle to unknown
            else if (!validSet.contains('Yes') && 
                      validSet.contains('No')) {
                vehicle.Valid__c = 'No';
            }
        }
        
        try {
            update vehicles;
        }
        catch (DMLException e) {
            trigger.new[0].addError(e.getDMLMessage(0));
            System.debug('UtilVehicleRelationship.updateVehicle Exception: ' + e);
        }
    }
}