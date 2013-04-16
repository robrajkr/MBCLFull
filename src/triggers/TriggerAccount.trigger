/*
    Type:       Utility for TriggerAccount
    Purpose:    Link Dealer to Dealer City by City CN and Province 
    User Story: US-DS-001
    Used By:    
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-28
*/
trigger TriggerAccount on Account (before update) {
	// Get the Record Type Id of 'Dealer'
	Id dealerRecordTypeId = UtilRecordType.getRecordTypeIdByName('Account', 'Dealer');

	if (trigger.isUpdate && trigger.isBefore) {
		// US-DS-001, link dealer to Dealer City by City CN and Province
		UtilAccount.linkDealerCity(trigger.new, dealerRecordTypeId);
	}
}