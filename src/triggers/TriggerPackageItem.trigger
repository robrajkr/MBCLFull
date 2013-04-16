/*
    Type:       Trigger
    Purpose:    Every insert / delete on pack item will do same operation on dealer offering record. 
    User Story: US-Cpn-005
    Used By:    
    ---------------------------------------------------------------
    History:
    
	29-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

trigger TriggerPackageItem on Package_Item__c (before delete, after insert) {
	if(trigger.isInsert) UtilDealerOffering.UpdateDOByPackageItem(trigger.new, 'insert');
	else if(trigger.isDelete) UtilDealerOffering.UpdateDOByPackageItem(trigger.old, 'delete');
}