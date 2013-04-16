/*
    Type:       Apex Class
    Purpose:    Define methods used in trigger.DearlerOffering
    User Story: US-Cpn-018, US-Cpn-019, US-Cpn-020, US-Cpn-021
    Used By:    TriggerCampaign.trigger
    ---------------------------------------------------------------
    History:
    
	25-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

public Class UtilCampaignTaskGeneration{
	// get all campaign Members
	public static List<Campaign> getTaskMembers(List<Campaign> cpList) {
		if(cpList.size() > 0) {
			List<ID> cpIdList = new List<ID>();
			for(Campaign cp : cpList) {
				cpIdList.add(cp.Id);
			}
			
			return [select id, Name, Template__c, DM_Material__c, 
								(select id, ContactId, LeadId, Task_Generated__c from CampaignMembers) 
							from Campaign
							where id in :cpIdList];
		} else {
			return null;
		}
	}
	
	//generate OB call tasks US-018
	public static void generateTasksOBCall(List<Campaign> cpList) {
		List<Task> taskList = new List<Task>();
		Map<String, Schema.RecordTypeInfo> taskRecordTypeMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
		List<User> userList = [select id, name from User where UserRole.Name = 'OB TL'];
		List<CampaignMember> cpMemberList = new List<CampaignMember>();
		if(cpList.size() > 0) {			
			for(Campaign cp : cpList) {
				for(CampaignMember cpMember : cp.CampaignMembers) {
					// check whether the member has realted task.
					if(!cpMember.Task_Generated__c) {
						for(User u : userList) {
						taskList.add(new Task(Subject= 'OB Call', 
												RecordTypeId = taskRecordTypeMap.get('OB Call').getRecordTypeId(),
												OwnerId = u.Id,
												Status_del__c = 'Open', 
												WhoId = (cpMember.ContactId == null ? cpMember.LeadId : cpMember.ContactId),
												WhatId = (cpMember.ContactId == null ? null : cp.Id),
												ActivityDate = date.today()));
						}
						cpMemberList.add(new CampaignMember(id=cpMember.Id, Task_Generated__c = true));
					}
					
				}
			}
		}
		
		Savepoint sp = Database.setSavepoint();
		try {
			if(taskList.size() > 0) insert taskList;
			if(cpMemberList.size() > 0) update cpMemberList;
		} catch(exception ex) {
    		Database.rollback(sp);
    		System.debug('create task failed : ' + ex);  			
		}
	}
	
	
	//generate eDM tasks  US-019
	public static void generateTaskseDM(List<Campaign> cpList) {
		List<Task> taskList = new List<Task>();
		Map<String, Schema.RecordTypeInfo> taskRecordTypeMap = Schema.SObjectType.Task.getRecordTypeInfosByName();
		List<User> userList = [select id, name from User where UserRole.Name = 'OB TL'];
		List<CampaignMember> cpMemberList = new List<CampaignMember>();
		if(cpList.size() > 0) {			
			for(Campaign cp : cpList) {
				for(CampaignMember cpMember : cp.CampaignMembers) {
					// check whether the member has realted task.
					if(!cpMember.Task_Generated__c) {
						for(User u : userList) {
						taskList.add(new Task(Subject= 'OB Call', 
												RecordTypeId = taskRecordTypeMap.get('OB Call').getRecordTypeId(),
												OwnerId = u.Id,
												Status_del__c = 'Open', 
												WhoId = (cpMember.ContactId == null ? cpMember.LeadId : cpMember.ContactId),
												WhatId = (cpMember.ContactId == null ? null : cp.Id),
												ActivityDate = date.today()));
						}
						cpMemberList.add(new CampaignMember(id=cpMember.Id, Task_Generated__c = true));
					}
					
				}
			}
		}
		
		Savepoint sp = Database.setSavepoint();
		try {
			if(taskList.size() > 0) insert taskList;
			if(cpMemberList.size() > 0) update cpMemberList;
		} catch(exception ex) {
    		Database.rollback(sp);
    		System.debug('create task failed : ' + ex);  			
		}
	}
	
	//generate SMS tasks
	
	//generate DM tasks
}