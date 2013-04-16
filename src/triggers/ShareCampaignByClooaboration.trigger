/*
    Type:       Trigger
    Purpose:    Share Campaign according to the collaboration team object 
    User Story: US-Cpn-006
    Used By:    
    ---------------------------------------------------------------
    History:
    
	25-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

trigger ShareCampaignByClooaboration on Collaboration_Team__c (before insert, before update, before delete) {
	if(trigger.isBefore && trigger.isInsert) {
		UtilCampaignShareByCollaboration.shareToUserInsert(trigger.new);
	}
	
	if(trigger.isBefore && trigger.isUpdate) {
		UtilCampaignShareByCollaboration.shareToUserUpdate(trigger.new);
	}
	
	if(trigger.isBefore && trigger.isDelete) {
		UtilCampaignShareByCollaboration.shareToUserDelete(trigger.old);
	}
}