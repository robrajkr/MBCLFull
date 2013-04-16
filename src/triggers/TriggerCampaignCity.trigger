/*
    Type:       Trigger
    Purpose:    Delete all Participating_Dealer__c when the campaignCity is deleted 
    User Story: US-Cpn-002, US-Cpn-004
    Used By:    
    ---------------------------------------------------------------
    History:
    
	08-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

trigger TriggerCampaignCity on Campaign_City__c (before delete) {
	// get all deleted records
	if (trigger.isDelete && trigger.isBefore) {
		if(trigger.old.size() > 0) {
			UtilCampaignCity.deleteParticipatingDealer(trigger.old);
		}
	}
}