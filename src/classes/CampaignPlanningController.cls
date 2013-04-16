/*
    Type:       controller
    Purpose:    Campaign Planning General Controller
    User Story: US-Cpn-002 - Select participating region/province/city for a central marketing campaign

    Used By:    VF Page - CampaignPlanning.Page
    ---------------------------------------------------------------
    History:

    05-Mar-2013 Jorry Chen (Breakingpoint)    Created
    22-Mar-2013 Jorry Chen (Breakingpoint)    Update: 
                                delete "MB_Sub_Region__c", "Smart_Sub_Region__c", "Sub_Region__c" from query fields
*/

public class CampaignPlanningController {
        /* Public Properties */
        public Campaign myCampaign {get;set;}   
        public List<clsDealerCity> DealerCityList {get;set;}
        public List<clsDealer> partiDealerList {get; set;}
         
        /* Static Variables */
        
        /* Private Properties */
        private Map<String, Set<String>> regionMap;
        private Set<String> ProvinceSet;
        private List<Dealer_City__c> CityList;
        
        private List<Campaign_City__c> campaignCityList;
        private List<Campaign_City__c> campaignCityDelList;
        private List<Campaign_City__c> campaignCityInsList;
        
        private List<Participating_Dealer__c> pDealerList;
        private List<Participating_Dealer__c> pDealerListDel;
        private List<Participating_Dealer__c> pDealerListIns;
        
        private set<ID> cityIdListIn;
        private set<ID> cityIdListOut;
        private set<ID> cityIdListAll;
        
        /* Constructors */
        
        /* Public Methods */
        public PageReference queryDealers() {
                try {
                        fnQueryDealers();
                        return null;
                } catch(exception ex) {
                        return null;
                }
        }
        
        public PageReference selectRegion() {
                try {
                        fuQueryCities();
                        fnQueryDealers();
                        return null;
                } catch (exception ex) {
                        return null;
                }
        }
        
        public PageReference cancel() {
                return null;
        }
        
        // the class will remove the unchecked cities and insert new one.
        public PageReference Save() {           
                SaveCampaignCity();
                SaveParticentDealers();
                return null;
        }
        
        /* Private Methods */
        private void fuQueryCities() {
                try {
                        DealerCityList.clear(); 
                        if(myCampaign.Participating_Region_Province__c <> null && myCampaign.Participating_Region_Province__c <> '') 
                                CityList = Database.query(generateQueryString(myCampaign.Participating_Region_Province__c));
                        else 
                                return;
                                
                        //find the existed dealer cities in the select region
                        for(Integer i = 0; i < cityList.size(); i++) {
                                Boolean blExist = false;
                                for(Campaign_City__c cpCity : campaignCityList) {                               
                                        if(cpCity.Dealer_City__c == cityList[i].Id) {
                                                blExist = true;
                                                break;
                                        }
                                }
                                if(blExist) DealerCityList.add(new clsDealerCity(cityList[i], true));
                                else DealerCityList.add(new clsDealerCity(cityList[i],false));
                        }
                
                        return;
                } catch (exception ex) {
                        return;
                }               
        }
        
        
        private void fnQueryDealers() {
                try {                   
                        cityIdListIn = new Set<ID>();
                        cityIdListOut = new Set<ID>();
                        cityIdListAll = new Set<ID>();
                        
                        for(clsDealerCity city : DealerCityList) {
                                if(city.isChecked) {
                                        cityIdListIn.add(city.dealerCity.Id);
                                }       
                        }
                        
                        partiDealerList = queryDealerList(myCampaign.Id, cityIdListAll, cityIdListIn, cityIdListOut);
                        
                        return;
                } catch (exception ex) {
                        return;         
                }
        }
        
        private void SaveParticentDealers() {
                Savepoint sp = Database.setSavepoint();
                try {
                        List<Account> pDealercheckedList = new List<Account>();
                        pDealerListIns = new List<Participating_Dealer__c>();
                        
                        for(clsDealer pdealer : partiDealerList) {
                                if(pdealer.isChecked) {
                                        pDealercheckedList.add(pdealer.dealer);
                                }
                        }
                        
                        for(Integer i = 0; i < pDealercheckedList.size(); i++) {
                                Boolean blExist = false;
                                for(Integer j = 0; j < pDealerList.size(); j++) {
                                        if(pDealercheckedList[i].Id == pDealerList[j].Dealer__c) {
                                                pDealerList.remove(j);
                                                blExist = true;
                                                break;
                                        }
                                }
                                if(!blExist) {
                                        pDealerListIns.add(new Participating_Dealer__c(Dealer__c = pDealercheckedList[i].Id, Campaign__c = myCampaign.Id));                                     
                                }
                        }
                        
                        if(pDealerListIns.size() > 0) {
                                insert pDealerListIns;
                        }
                        
                        if(pDealerList.size() > 0) {
                                delete pDealerList;
                        }                       
                } catch (exception ex) {
                        Database.rollback(sp);
                        return;
                }
        }
        
        private void SaveCampaignCity() {
                Savepoint sp = Database.setSavepoint();
                try {
                        List<Dealer_City__c> dCitycheckedList = new List<Dealer_City__c>();
                        campaignCityInsList = new List<Campaign_City__c>();
                        
                        for(clsDealerCity cpCity : DealerCityList) {
                                if(cpCity.isChecked) {
                                        dCitycheckedList.add(cpCity.dealerCity);
                                }
                        }
                        
                        for(Integer i = 0; i < dCitycheckedList.size(); i++) {
                                Boolean blExist = false;
                                for(Integer j = 0; j < campaignCityList.size(); j++) {
                                        if(campaignCityList[j].Dealer_City__c == dCitycheckedList[i].Id) {
                                                blExist = true;
                                                campaignCityList.remove(j);
                                        }
                                }
                                if(!blExist) {
                                        campaignCityInsList.add(new Campaign_City__c(Campaign__c = myCampaign.Id, Dealer_City__c = dCitycheckedList[i].Id));
                                }
                        }
                        
                        if(campaignCityList.size() > 0) {
                                delete campaignCityList;
                        }
                        
                        if(campaignCityInsList.size() > 0) {
                                insert campaignCityInsList;
                        }
                        
                        update new Campaign(id=myCampaign.id, Participating_Region_Province__c=myCampaign.Participating_Region_Province__c);
                        
                        return;
                } catch(exception ex) {
                        Database.rollback(sp);
                        return;
                }               
        }
        
        // get all dealer account in the selected city list
        private List<clsDealer> queryDealerList(Id cpid, set<ID> allIds, set<ID> inIds, set<ID> outIds) {
                try {
                        partiDealerList = new List<clsDealer>();
                        Set<ID> idList = new Set<ID>();
                                        
                        List<Account> dealerList = [select Id, name, Dealer_City__c, Province__c, Dealer_Region__c, Dealer_City_EN__c 
                                                                                from Account 
                                                                                where Dealer_City__c in :inIds
                                                                                order by Dealer_Region__c];
                        
                        for(Participating_Dealer__c pDealer : pDealerList) {
                                idList.add(pDealer.Dealer__c);
                        }
                        
                        for(Account ac : dealerList) {
                                if(idList.contains(ac.Id)) {
                                        partiDealerList.add(new clsDealer(ac, true));
                                } else {
                                        partiDealerList.add(new clsDealer(ac, false));
                                }
                        }
                        
                        return partiDealerList;
                } catch(exception ex) {
                        return null;
                }
        }
        
        private String generateQueryString(String str) {
                try{
                        str = str.replaceAll('\t', ' ');                                        // add to make data qualified.
                        String queryStr = 'Select Id, Name, Province__c, Region__c from Dealer_City__c ';
                        Set<String> regionString = new Set<String>();
                        for(String myStr : str.split(';')){
                                regionString.add(myStr);
                        }
                        
                        if(regionString.contains('All')){
                                return queryStr;
                        }
                                        
                        regionMap = new Map<String, Set<String>>();
                        List<String> regionList = new List<String>();
                        
                        for(String myStr : regionString) {                              
                                if(!regionMap.containsKey(myStr.split(' ')[0])) { 
                                        regionMap.put(myStr.split(' ')[0], new Set<String>());
                                        regionList.add(myStr.split(' ')[0]);
                                }
                                // to handle the picklist values, with more than 2 blank space
                                regionMap.get(myStr.split(' ')[0]).add((myStr.split(' ').size() > 2 ? (myStr.split(' ')[1] + ' ' + myStr.split(' ')[2]) : (myStr.split(' ')[1])));
                        }
                        
                        for(integer i = 0; i < regionList.size(); i++) {
                                if(0 == i) queryStr += 'where (';
                                if(regionMap.get(regionList[i]).contains('All')) {
                                        queryStr += 'Region__c =\'' + regionList[i] + '\') ';
                                } else {
                                        ProvinceSet = regionMap.get(regionList[i]);
                                        queryStr += 'Region__c =\'' + regionList[i] + '\' and Province__c in :ProvinceSet) ';
                                }
                                if(regionList.size()-1 <> i) queryStr += 'or (';
                        }
                        
                        return queryStr;
                } catch (exception ex){
                        return '';
                }
        }
        /* Inner classes and methods*/
        public class clsDealerCity{
                public Boolean isChecked {get;set;}
                public Dealer_City__c dealerCity {get; set;}
                
                public clsDealerCity(Dealer_City__c city, Boolean isExist) {
                        this.isChecked = isExist;
                        this.dealerCity = city;
                }
        }
        
        public class clsDealer{
                public Boolean isChecked {get;set;}
                public Account dealer {get; set;}
                
                public clsDealer(Account pDealer, Boolean isExist) {
                        this.isChecked = isExist;
                        this.dealer = pDealer;
                }
        }
        
        
        /* Static initialisers */
        public CampaignPlanningController() {           
                Id campaignId = ApexPages.currentPage().getParameters().get('id');
                
                myCampaign = [select id, Participating_Region_Province__c from Campaign where id = :campaignId];
                campaignCityList = [select id, Dealer_City__c from Campaign_City__c where Campaign__c = :campaignId];
                
                //get all default dealer_cities         
                if(myCampaign.Participating_Region_Province__c <> null && myCampaign.Participating_Region_Province__c <> '') 
                        CityList = Database.query(generateQueryString(myCampaign.Participating_Region_Province__c));
                else 
                        CityList = new List<Dealer_City__c>();
                
                //get all campaign_dealers from the campaign record
                pDealerList = [Select id, Name, Campaign__c, Campaign_Package__c, Dealer__c, 
                                        Session_End_Date__c, Session_Start_Date__c
                                from Participating_Dealer__c
                                where Campaign__c = :campaignId];
                
                DealerCityList = new List<clsDealerCity>();               
                cityIdListAll = new set<ID>();
                cityIdListIn = new set<ID>();
                cityIdListOut = new set<ID>();
                
                //find the existed dealer cities
                for(Integer i = 0; i < cityList.size(); i++) {
                        Boolean blExist = false;
                        for(Campaign_City__c cpCity : campaignCityList) {                               
                                if(cpCity.Dealer_City__c == cityList[i].Id) {
                                        blExist = true;
                                        break;
                                }
                        }
                        if(blExist) { 
                                DealerCityList.add(new clsDealerCity(cityList[i], true));
                                cityIdListIn.add(cityList[i].Id);
                                cityIdListAll.add(cityList[i].Id);
                        }
                        else {
                                DealerCityList.add(new clsDealerCity(cityList[i],false));
                                cityIdListOut.add(cityList[i].Id);
                                cityIdListAll.add(cityList[i].Id);
                        }
                }
                
                partiDealerList = queryDealerList(campaignId, cityIdListAll, cityIdListIn, cityIdListOut);
        }

}