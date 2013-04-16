/*
    Type:       Trigger
    Purpose:    Auto modify SentTotal field on DM Material when DM Request Status changed to 'Sent'
    User Story: US-DM-004
    Used By:    
    ---------------------------------------------------------------
    History:
    
    11-Mar-2013 Chris Huang (Breakingpoint)    Created
*/
trigger DMRequestTrigger on DM_Request__c (before insert, after insert, after update) {

    /*
    //auto set contact
    if(trigger.isInsert && trigger.isBefore){
        for(DM_Request__c dm : trigger.new){
            if(dm.Customer_Name__c!=null){
                List<Contact> cList = [Select Id From Contact Where AccountId=:dm.Customer_Name__c];
                if(cList!=null && cList.size()>0){
                    dm.Contact__c = cList[0].Id;                
                }                            
            }                    
        }    
    }    
    */

    // get all records
    if ((trigger.isInsert || trigger.isUpdate) && trigger.isAfter) {
        DMRequestTriggerHandler.updateDaterialSentTotal(trigger.new, trigger.old);         
    }
    
}