/*
    Type:       Apex Class
    Purpose:    Define methods used in triggerCampaignCity
    User Story: US-Cpn-002, US-Cpn-004
    Used By:    TriggerCampaignCity.trigger
    ---------------------------------------------------------------
    History:
    
	08-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

public class UtilCampaignCity {
	public static void deleteParticipatingDealer(List<Campaign_City__c> cpCityList){
		Savepoint sp = Database.setSavepoint();
		try{
			List<ID> cityIdList = new List<ID>();
			
			System.debug('@!!!!! begin');
			for(Campaign_City__c city : cpCityList){
				cityIdList.add(city.Dealer_City__c);
				System.debug('@!!!!! city.Dealer_City__c ' + city.Dealer_City__c);
			} 	
			
			List<Participating_Dealer__c> pDealerList = [select id from Participating_Dealer__c
															where Dealer__r.Dealer_City__c in :cityIdList and Campaign__c = :cpCityList[0].Campaign__c];
			
			System.debug('@!!!!! city.Dealer_City__c ' + pDealerList.size());
															
			if(pDealerList.size() > 0) {
				delete pDealerList;
			}
		} catch(exception ex) {
			Database.rollback(sp);
            System.debug('deleteCampaigndealer failed : ' + ex);
		}
	}	
}