/*
    Type:       Extension for DealerSearch Visualforce page 
    Purpose:    Search Dealer by specified filters
    User Story: US-DS-001
    Used By:    DealerSearch.page
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-04

*/
public with sharing class DealerSearchController {
    public Account dealer                   {get; set;}
    public List<Account> dealers            {get; set;}
    public String name                      {get; set;}
    public Boolean hasQueryResult           {get; set;}
    
    // Query return limit and Dealer's Record Type Name
    private final Integer QUERY_LIMIT = 200;
    private final String ACCOUNT_RT_DEALER = 'Dealer';
    
    // Account Address Fields Mapping with Dealer City
    private final Map<String, String> ADDRESS_FIELD_MAPPING = new Map<String, String> {
        'Dealer_Region__c' => 'Dealer_Region__c',
        'Province__c' => 'Province__c',
        'City_CN__c' => 'City_CN__c'
    };
    
    // Two Muti-Select Fields on Account
    private final List<String> MUTI_SELECT_FIELDS = new List<String> {
        'Dealer_Sales_Type__c',
        'Dealer_Service_Codes__c'
    };
    
    public DealerSearchController(Apexpages.StandardController con) {
        // We must assign the Dealer Record Type Id to the proxy account
        Id dealerRecordTypeId = UtilRecordType.getRecordTypeIdByName('Account', 
            this.ACCOUNT_RT_DEALER);
        dealer = new Account(RecordTypeId = dealerRecordTypeId);
        
        try {
            Account personAccount = [ SELECT Name, Dealer_Province__c,
                                             Dealer_Sales_Type__c, Dealer_Service_Codes__c,
                                             Dealer_Region__c, Province__c, City_CN__c
                                      FROM Account 
                                      WHERE Id = :con.getId()];
            
            // We only need pass the province and city to the search page
            dealer.Province__c = personAccount.Province__c;
            dealer.City_CN__c = personAccount.City_CN__c;
        }
        catch (QueryException e) {
            // If user open this from home page, it means, 
            // we don't need to pass province and city
            System.debug('User may open this page in the Home Page Custom Link.');
        }

        query();
    }
    
    // Get the SOQL Expr of DealerSearchColumns FieldSet fields
    private String getColumns() {
        String columns = '';
        for (Schema.FieldSetMember member : this.getFieldSetMembers()) {
            columns += member.getFieldPath() + ', ';
        }
        
        return columns;
    }
    
    // Get the FieldSet Members of Account FieldSet(DealerSearchColumns)
    private List<Schema.FieldSetMember> getFieldSetMembers() {
        return SObjectType.Account.FieldSets.DealerSearchColumns.getFields();
    }
    
    // Parse these two mutiselect value (Dealer_Sales_Type__c, Dealer_Service_Codes__c) 
    // to SOQL Expression: 
    private String parseMutiSelect(String fieldAPI) {
        String retValue = fieldAPI + ' INCLUDES (';
        List<String> parseValues = String.valueOf(dealer.get(fieldAPI)).split(';');
        for (String value : parseValues) {
            retValue += '\'' + value + '\',';
        }
        retValue = retValue.subString(0, retValue.length() - 1) + ') ';
        
        return retValue;
    }
    
    public void query() {
        // We must inculde the IsPsersonAccount in the SOQL, otherwise, 
        // we will get exception in debug log but not display on the page
        String querySOQL = 'SELECT ' + this.getColumns() + 'IsPersonAccount, Id FROM Account ' +
                           'WHERE RecordType.Name = :ACCOUNT_RT_DEALER AND ';

        // If Name filter is not null, add it into SOQL
        if (name != null && name != '') {
            querySOQL += 'Name LIKE \'%' + name + '%\' AND ';
        }
        
        // For loop the address fields, if not null, add it into SOQL
        for (String fieldAPI : this.ADDRESS_FIELD_MAPPING.keySet()) {
            // Get the AddressInfo
            Object obj = dealer.get(fieldAPI);
            
            if (obj != null) {
                String addressInfo = String.valueOf(obj);
                querySOQL += this.ADDRESS_FIELD_MAPPING.get(fieldAPI) + ' = \'' + 
                    addressInfo + '\' AND ';
            }
        }
        
        // If Dealer Sales Type is not null, add it into SOQL
        // If Dealer Service Codes is not null, add it into SOQL
        for (String fieldAPI : this.MUTI_SELECT_FIELDS) {
            if (dealer.get(fieldAPI) != null) {
                querySOQL += this.parseMutiSelect(fieldAPI) + ' AND ';
            }
        }
        
        querySOQL = querySOQL.subString(0, querySOQL.length() - 4) + 
            'ORDER BY Dealer_Region__c DESC NULLS LAST LIMIT ' + this.QUERY_LIMIT;
        System.debug(querySOQL);
        
        dealers = Database.query(querySOQL);
        
        // If no query result, system alert no search result.
        hasQueryResult = (dealers.size() > 0);
        if (!hasQueryResult) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 
                                   Label.CP_No_Search_Result));
        }
    }
    
    /*
    public void clear() {
        dealer = new Account();
        query();
    }
    */
}