/*
    Type:       Trigger
    Purpose:    Create Task when campaign is active and recordtype = Campaign Execution  
    User Story: US-Cpn-018, US-Cpn-019, US-Cpn-020, US-Cpn-021
    Used By:    
    ---------------------------------------------------------------
    History:
    
	08-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/


trigger TriggerCampaign on Campaign (after insert, after update) {
	if(trigger.isAfter) {
		Map<String, Schema.RecordTypeInfo> cpRecordTypeMap = Schema.SObjectType.Campaign.getRecordTypeInfosByName();
		List<Campaign> cpList = new List<Campaign>();
		for(Campaign cp : trigger.new) {
			if(cp.RecordTypeId == cpRecordTypeMap.get('Campaign Execution').getRecordTypeId()) {
				if(cp.IsActive && !trigger.oldMap.get(cp.Id).IsActive) {
					cpList.add(cp);
				}
			}
		}
		if(cpList.size() > 0) UtilCampaignTaskGeneration.generateTasksOBCall(UtilCampaignTaskGeneration.getTaskMembers(cpList));
	}
}