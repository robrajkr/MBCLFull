/*
    Type:       Apex Class
    Purpose:    Define methods used in trigger.CampaignShareByCollaboration
    User Story: US-Cpn-006
    Used By:    CampaignShareByCollaboration.trigger
    ---------------------------------------------------------------
    History:
    
	25-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

public class UtilCampaignShareByCollaboration {
	// insert campaign sharing records
    public static void shareToUserInsert(List<Collaboration_Team__c> ctList) {
    	Savepoint sp = Database.setSavepoint();
    	List<CampaignShare> csList = new List<CampaignShare>();
    	try{
    		if(ctList.size() > 0) {
    			for(Collaboration_Team__c ct : ctList) {
    				csList.add(new CampaignShare(CampaignId = ct.Campaign__c,
    												UserOrGroupId = ct.Member_Name__c, 
    												CampaignAccessLevel = (ct.Access_Type__c == 'Read Only' ? 'Read' : 'Edit')));
    			}
    		
			if(csList.size() > 0) Database.SaveResult[] lsr = Database.insert(csList,false);
    			
	        // Process the save results
    		}
    	} catch(exception ex) {
    		Database.rollback(sp);
    		System.debug('share Campaign failed : ' + ex);
    	}
    }
    
    // update campaign sharing records
    public static void shareToUserUpdate(List<Collaboration_Team__c> ctList) {
    	Savepoint sp = Database.setSavepoint();
    	List<CampaignShare> csList = new List<CampaignShare>();
    	List<ID> userIdList = new List<ID>();
    	List<ID> cpIdList = new List<ID>();
    	try{
    		if(ctList.size() > 0) {
    			for(Collaboration_Team__c ct : ctList) {
    				userIdList.add(ct.Member_Name__c);
    				cpIdList.add(ct.Campaign__c);
    			}
    			
    			csList = [select Id, UserOrGroupId, CampaignId, CampaignAccessLevel, RowCause from CampaignShare
    						where CampaignId in :cpIdList and UserOrGroupId in :userIdList];
    			
    			for(Integer i = 0; i < ctList.size(); i++) {
    				for(Integer j = 0; j < csList.size(); j++) {
    					if(csList[j].UserOrGroupId == ctList[i].Member_Name__c) {
    						String strAccessLevel = ctList[i].Access_Type__c == 'Read Only' ? 'Read' : 'Edit';
    						if(strAccessLevel <> csList[j].CampaignAccessLevel && csList[j].RowCause <> 'Owner') {
    							csList[j].CampaignAccessLevel = strAccessLevel;
    							break;
    						} else {
    							csList.remove(j);
    							j--;
    							break;
    						}
    					}
    				}
    			}
    			
    			if(csList.size() > 0) Database.SaveResult[] lsr = Database.update(csList,false);
    		}
    	} catch(exception ex) {
    		Database.rollback(sp);
    		System.debug('share Campaign failed : ' + ex);    		
    	}
    }
    
    // delete campaign sharing records
    public static void shareToUserDelete(List<Collaboration_Team__c> ctList) {
    	Savepoint sp = Database.setSavepoint();
    	List<CampaignShare> csList = new List<CampaignShare>();
    	List<CampaignShare> csDelList = new List<CampaignShare>();
    	List<ID> userIdList = new List<ID>();
    	List<ID> cpIdList = new List<ID>();
    	try{
    		if(ctList.size() > 0) {
    			for(Collaboration_Team__c ct : ctList) {
    				userIdList.add(ct.Member_Name__c);
    				cpIdList.add(ct.Campaign__c);
    			}
    			
    			csList = [select Id, UserOrGroupId, CampaignId, CampaignAccessLevel, RowCause from CampaignShare
    						where CampaignId in :cpIdList and UserOrGroupId in :userIdList];
    			
    			for(Integer i = 0; i < ctList.size(); i++) {
    				for(Integer j = 0; j < csList.size(); j++) {
    					if(csList[j].UserOrGroupId == ctList[i].Member_Name__c && (csList[j].RowCause <> 'Owner' || csList[j].RowCause <> 'Administrator')) {
							csDelList.add(csList[j]);
							break;
    					}
    				}
    			}
    			
    			if(csDelList.size() > 0) Database.DeleteResult[] lsr = Database.delete(csDelList,false);
    		}
    	} catch(exception ex) {
    		Database.rollback(sp);
    		System.debug('share Campaign failed : ' + ex);    		
    	}
    }
}