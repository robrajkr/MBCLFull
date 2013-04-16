/*
    Type:       Apex Class
    Purpose:    Define methods used in trigger.DearlerOffering
    User Story: US-Cpn-005
    Used By:    DealerOffering.trigger
    ---------------------------------------------------------------
    History:
    
	25-Mar-2013 Jorry Chen (Breakingpoint)    Created
*/

public class UtilDealerOffering {
    public static List<Campaign_Package__c> querycpPackageList(List<Participating_Dealer__c> pdList) {
    	if(pdList.size() > 0) {
    		Set<ID> cpPackageIdList = new Set<ID>();
    		List<Campaign_Package__c> cpPackageList;  
    		
    		for(Participating_Dealer__c pd : pdList) {
    			if(pd.Campaign_Package__c <> null)
    			cpPackageIdList.add(pd.Campaign_Package__c);
    		}
    		
    		cpPackageList = [select id, Campaign__c, Package_Description__c, (select id, Offering__c, Offering__r.Campaign__c, Package_Name__c from Package_Items__r) 
    							from Campaign_Package__c
    							where id in :cpPackageIdList];
    							
    		return cpPackageList;     		
    	} else {
    		return null;
    	}
    }
    
    
    public static void InsertDealerOfferingRecords(List<Participating_Dealer__c> pdList, List<Campaign_Package__c> cpPackageList) {
    	List<Dealer_Offering__c> dealerOffering = new List<Dealer_Offering__c>();
    	if(cpPackageList.size() > 0) {    		
    		//generate dealerOffering items    		
    		for(Campaign_Package__c cpPackage : cpPackageList) {
    			for(Participating_Dealer__c pd : pdList){    				
	    			for(Package_Item__c cpItem : cpPackage.Package_Items__r) {
	    				if(pd.Campaign__c == cpItem.Offering__r.Campaign__c) {
		    				dealerOffering.add(new Dealer_Offering__c(Campaign_Offering__c = cpItem.Offering__c, Dealer__c = pd.Dealer__c, 
		    															Session_Start_Date__c = pd.Session_Start_Date__c,
		    															Session_End_Date__c = pd.Session_End_Date__c,
		    															Package_Item__c = cpItem.Id));
		    			}
    				}
	    		}
    		}
    	} else {
    		return;
    	}
    	
    	
    	Savepoint sp = Database.setSavepoint();
    	try {
    		if(dealerOffering.size() > 0) insert dealerOffering;
    	} catch(exception ex) {
    		Database.rollback(sp);
    	    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
    	    ApexPages.addMessage(msg);  		
    	}
    }
    
    public static void DelDealerOfferingRecords(List<Participating_Dealer__c> pdList, List<Campaign_Package__c> cpPackageList) {
    	List<Dealer_Offering__c> dealerOfferingList = new List<Dealer_Offering__c>();
    	if(cpPackageList.size() > 0) {    								
    		//delete dealerOffering items
    		Set<ID> offeringIdList = new Set<ID>();
    		Set<ID> dealerIdList = new Set<ID>();    		
			for(Campaign_Package__c cpPackage : cpPackageList) {
				for(Package_Item__c cpItem : cpPackage.Package_Items__r) {
					offeringIdList.add(cpItem.Offering__c);
				}
			}
			
			for(Participating_Dealer__c pd : pdList) {
				dealerIdList.add(pd.Dealer__c);
			}
			
			dealerOfferingList = [select id from Dealer_Offering__c
									where Campaign_Offering__c in :offeringIdList
									and Dealer__c in :dealerIdList];
    	} else {
    		return;
    	}    	
    	
    	Savepoint sp = Database.setSavepoint();
    	try {
    		if(dealerOfferingList.size() > 0) delete dealerOfferingList;
    	} catch(exception ex) {
    		Database.rollback(sp);
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()); 
    		ApexPages.addMessage(msg);    		
    	}    	
    	
    }
    
    public static void DelDealerOfferingRecords(List<Participating_Dealer__c> pdList) {
    	List<Dealer_Offering__c> dealerOfferingList = new List<Dealer_Offering__c>();
    	Set<ID> cpIdList = new Set<ID>();
    	Set<ID> pdIdList = new Set<ID>();
    	
    	for(Participating_Dealer__c pd : pdList) {
    		cpIdList.add(pd.Campaign__c);
    		pdIdList.add(pd.Dealer__c);
    	}
    	
    	List<Campaign_Offering__c> coList = [select id, (select id, Dealer__c from Dealer_Offerings__r) from Campaign_Offering__c
    											where Campaign__c in :cpIdList];
    	
    	if(coList <> null) {
    		for(Campaign_Offering__c co : coList) {
    			for(Dealer_Offering__c dealerOffering : co.Dealer_Offerings__r) {
    				if(pdIdList.contains(dealerOffering.Dealer__c))
    					dealerOfferingList.add(dealerOffering);
    			}
    		}
    	}
    	
    	Savepoint sp = Database.setSavepoint();
    	try{
    		if(dealerOfferingList.size() > 0) delete dealerOfferingList;
    	} catch (exception ex) {
    		Database.rollback(sp);
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()); 
    		ApexPages.addMessage(msg); 
    	}
    }
    
    public static void UpdateDOByPackageItem(List<Package_Item__c> packageItemList, String dmlOperation) {
    	List<Dealer_Offering__c> dealerOfferingList = new List<Dealer_Offering__c>();
    	Set<ID> cpPackageIdList = new Set<ID>();
    	if(packageItemList.size() > 0) {
    		Set<ID> packageItemIdList = new Set<ID>();     		   		
    		for(Package_Item__c packageItem : packageItemList) {
    			packageItemIdList.add(packageItem.Id);
    			cpPackageIdList.add(packageItem.Package_Name__c);
    		}
    		
    		
    		dealerOfferingList = [select id, Campaign_Offering__c, Comments__c, Dealer__c, Package_Item__c, Session_End_Date__c, Session_Start_Date__c
    								from Dealer_Offering__c
    								where Package_Item__c in :packageItemIdList];
    	} else {
    		return;
    	}
    	
    	Savepoint sp = Database.setSavepoint();
    	try{
    		if(dmlOperation == 'delete' && dealerOfferingList.size() > 0) delete dealerOfferingList;
    		else if(dmlOperation == 'insert') {
    			// insert dealer offerings
    			List<Dealer_Offering__c> DOInsertList = new List<Dealer_Offering__c>();
    			List<Campaign_Package__c> cpPackageList = [select id, Campaign__c, Package_Description__c, 
    														(select id, Campaign__c, Dealer__c, Session_Start_Date__c, Session_End_Date__c 
    																				from Participating_Dealers__r) 
							    							from Campaign_Package__c
							    							where id in :cpPackageIdList];
    			if(cpPackageList.size() > 0 && cpPackageList <> null) {
    				for(Campaign_Package__c cpPackage : cpPackageList) {
    					for(Package_Item__c packageItem : packageItemList) {
    						if(packageItem.Package_Name__c == cpPackage.Id) {
    							for(Participating_Dealer__c pd : cpPackage.Participating_Dealers__r) {
    								if(pd.Campaign__c == packageItem.Related_Campaign_ID__c)
    									DOInsertList.add(new Dealer_Offering__c(Campaign_Offering__c = packageItem.Offering__c,
	    																		Dealer__c = pd.Dealer__c,
	    																		Package_Item__c = packageItem.Id,
	    																		Session_End_Date__c = pd.Session_End_Date__c,
	    																		Session_Start_Date__c = pd.Session_Start_Date__c));
    							}
    							break;
    						}
    					}
    				}
    			}
    			
    			if(DOInsertList.size() > 0) insert DOInsertList;
    		}
    	} catch(exception ex){
    		Database.rollback(sp);
    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()); 
    		ApexPages.addMessage(msg);    		
    	}
    }
}