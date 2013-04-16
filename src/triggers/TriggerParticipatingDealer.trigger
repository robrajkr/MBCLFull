/*
    Type:       Trigger
    Purpose:    Trigger when update/insert participating_dealer__c 
    User Story: US-Cpn-005
    Used By:    
    ---------------------------------------------------------------
    History:
    
	25-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

trigger TriggerParticipatingDealer on Participating_Dealer__c (after insert, after update, before delete) {
	if(trigger.isUpdate && trigger.isAfter) {
		List<Participating_Dealer__c> pdList = new List<Participating_Dealer__c>();
		for(Participating_Dealer__c pd : trigger.new) {
			if(pd.Campaign_Package__c <> trigger.oldMap.get(pd.Id).Campaign_Package__c ||
				(pd.Campaign_Package__c <> null && 
				(pd.Session_Start_Date__c <> trigger.oldMap.get(pd.Id).Session_Start_Date__c ||
				pd.Session_End_Date__c <> trigger.oldMap.get(pd.Id).Session_End_Date__c))) {
				//insert new dealer offering items
				pdList.add(pd);
			}
		}
		
		if(pdList.size() > 0) {
			List<Campaign_Package__c> cpPackageList = UtilDealerOffering.querycpPackageList(pdList);
			UtilDealerOffering.DelDealerOfferingRecords(pdList);
			UtilDealerOffering.InsertDealerOfferingRecords(pdList, cpPackageList);
		}
	}
	
	if(trigger.isDelete) {
		UtilDealerOffering.DelDealerOfferingRecords(trigger.old);
	}
}