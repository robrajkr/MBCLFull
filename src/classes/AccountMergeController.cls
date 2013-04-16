/*
    Type:       Extension for AccountMerge Visualforce page 
    Purpose:    Merget the Master Account Record and Suspect Duplicate Account
    User Story: US-DD-002
    Used By:    SelectSlaveAccount.page
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-3-05
*/
public with sharing class AccountMergeController {
    // AccountMerge Page Variable
    public Account master                   {get; set;}
    public Account slave                    {get; set;}
    public List<AccountWrapper> wraps       {get; set;}
    public String selectAllParam            {get; set;}
    public Boolean hasMessage               {get; set;}

    // SelectSlaveAccount Page Variable
    public Boolean hasSuspectAccounts       {get; set;}
    public List<Account> slaves             {get; set;}

    // Soft deleted Account Record Type Name
    private final String RECORDTYPE_PERSON_ACCOUNT_SOFT_DELETED  = 
        'Person Account Soft Deleted';
    
    // Soft deleted Account Owner UserRole Name
    private final String USERROLE_PERSON_ACCOUNT_SOFT_DELETED = 
        'Data Service Specialist';
    
    // Get All Account fields Describe
    private Map<String, Schema.SObjectField> fieldNamesMap = 
        Account.sObjectType.getDescribe().fields.getMap();

    // Construtor
    public AccountMergeController(ApexPages.StandardController con) {
        // If it's in SelectSlavePage, just populate hasSuspectAccounts, 
        // slave And master, and then return
        String urlString = URL.getCurrentRequestUrl().toExternalForm();
        if (urlString.contains('/apex/SelectSlaveAccount')) {
            String masterId = con.getId();
            master = this.getQueriedAccount(masterId);
                      
            String dupNummer = master.DUP_Nummer__c;
            slaves = new List<Account>();
            slaves.add(master);
            slaves.addAll((List<Account>) Database.query('SELECT ' + 
                this.getSOQLFieldList(getFieldsListByFieldSet('SuspectAccountFields')) + 
                ' IsPersonAccount, Id FROM Account' +
                ' WHERE DUP_Nummer__c = :dupNummer' + 
                ' AND DUP_Nummer__c != null AND (NOT Id = :masterId)'));
            
            hasSuspectAccounts = slaves.size() > 1;
            
            if (!hasSuspectAccounts) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 
                                       Label.CP_No_Suspect_Customer_Found));
            }
            return;
        }

        // Initiate hasMessage and wraps
        hasMessage = false;
        wraps = new List<AccountWrapper>();
        
        Account tempAccount = this.getQueriedAccount(con.getId());
        
        // If this record is Master Record, it means this page is
        // redirected from SelectSlaveAccount Page
        if (tempAccount.Master_Record__c) {
            master = tempAccount;
            slave = this.getQueriedAccount(this.getParameter('slaveId'));
        }
        // If not, we need to get the corresponding master record by this slave account
        else {
            slave = tempAccount;
            String dupNummer = slave.DUP_Nummer__c;
            try {
                master = Database.query('SELECT ' + this.getSOQLFieldList(this.fieldAPIList) + 
                this.getSOQLFieldList(FieldMappingConstant.PHONE_DMS_FIELDS_MAPPING.values()) + 
                ' IsPersonAccount, DUP_Nummer__c, Name, Id FROM Account ' +
                ' WHERE DUP_Nummer__c = :dupNummer AND Master_Record__c = true');
            }
            catch (QueryException e) {
                hasMessage = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                    'No Master Record.'));
                return;
            }
            
        }

        // Populate Inner class List
        this.populateAccountWrappers();
    }
    
    // Get quried account with fields list in AccountMergeFields FieldSet by accId
    // N.B. SOQL Field List = FieldSet Members + FieldMappingConstant.PHONE_DMS_FIELDS_MAPPING.values()
    private Account getQueriedAccount(Id accId) {
        String soql = 'SELECT ' + this.getSOQLFieldList(this.fieldAPIList) + 
           this.getSOQLFieldList(FieldMappingConstant.PHONE_DMS_FIELDS_MAPPING.values());
        
        // Prevent duplicate Master_Record__c and DUP_Nummer__c in SOQL Field List,
        if (!soql.contains('Master_Record__c')) {
           soql += 'Master_Record__c, ';
        }
        
        if (!soql.contains('DUP_Nummer__c')) {
           soql += 'DUP_Nummer__c, ';
        }
        
        if (!soql.contains('Dup_Reason__c')) {
           soql += 'Dup_Reason__c, ';
        }
        
        return Database.query(soql + 
            ' IsPersonAccount, Name, Id FROM Account WHERE Id = :accId');
    }
    
    private void populateAccountWrappers() {
        for (String fieldAPI : this.fieldAPIList) {
            AccountWrapper wrap = new AccountWrapper();
            
            // Populate fieldLabel and fieldAPI
            wrap.fieldAPI = fieldAPI;
            wrap.fieldLabel = fieldNamesMap.get(fieldAPI).getDescribe().getLabel();
            
            // Get the Master Value and Slave Value by fieldAPI
            Object masterFieldValue = master.get(fieldAPI);
            Object slaveFieldValue = slave.get(fieldAPI);
     
            // Populate isMasterNull and isSlaveNull
            wrap.isMasterNull = (masterFieldValue == null);
            wrap.isSlaveNull = (slaveFieldValue == null);
            
            // If two values are both null, so,
            if (masterFieldValue == null && slaveFieldValue == null) {
                wrap.isSame = true;
                wrap.isMasterChecked = false;
                wrap.isSlaveChecked = false;
                wraps.add(wrap);
                continue;
            }
            
            // 1. If master field value is same with slave's, just choose master value
            // as default value
            // 2. User can't change the master record.
            if ((masterFieldValue != null && masterFieldValue == slaveFieldValue) ||
                    fieldAPI == 'Master_Record__c') {
                wrap.isSame = true;
                wrap.isMasterChecked = true;
                wrap.isSlaveChecked = false;
                wraps.add(wrap);
                continue;
            }
            
            // Populate isSame
            wrap.isSame = ( masterFieldValue == slaveFieldValue);
            
            // When one value is null, the other is default value
            wrap.isSlaveChecked = (masterFieldValue == null && 
                slaveFieldValue != null);
            wrap.isMasterChecked = (slaveFieldValue == null && 
                masterFieldValue != null);
                
            // Phone & DMS Address
            if (masterFieldValue != null && slaveFieldValue != null) {
                if (FieldMappingConstant.PHONE_DMS_FIELDS_MAPPING.keySet().contains(fieldAPI)) {
                    // Get the Mapping Field API
                    String latestTimeFieldAPI = 
                        FieldMappingConstant.PHONE_DMS_FIELDS_MAPPING.get(fieldAPI);
                    
                    // Get the Master Latest Contact Time
                    Datetime latestMasterTime = 
                        Datetime.valueOf(master.get(latestTimeFieldAPI));
                    
                    // Get the Slave Latest Contact Time
                    Datetime latestSlaveTime = 
                        Datetime.valueOf(slave.get(latestTimeFieldAPI));
                    
                    // When one value is null, the other is default value
                    wrap.isSlaveChecked = (latestMasterTime == null && 
                        latestSlaveTime != null);
                    wrap.isMasterChecked = (latestSlaveTime == null && 
                        latestMasterTime != null);
                    
                    // If both Latest Time of master and slave are null,
                    // Set master value as default value
                    if (latestMasterTime == null && latestMasterTime == null) {
                        wrap.isMasterChecked = true;
                        wrap.isSlaveChecked = false;
                    }
                    // If the two latest time is not null, 
                    // choose the larger fieldValue as default value
                    else if (latestMasterTime != null && 
                            latestSlaveTime != null) {
                        if (latestMasterTime >= latestSlaveTime) {
                            wrap.isMasterChecked = true;
                        }
                        else {
                            wrap.isSlaveChecked = true;
                        }
                    }
                }
                // The other fields, if master and salve are both not null,
                // just set master field value as default
                else {
                    wrap.isMasterChecked = true;
                    wrap.isSlaveChecked = false;
                }
            }
            
            wraps.add(wrap);            
        }
        System.debug(wraps);
    }
    
    // Get the Fields List that will be displayed in the pageBlockTable from fieldSet
    public List<String> fieldAPIList {
        get {
            return this.getFieldsListByFieldSet('AccountMergeFields');
        }
        set;
    }
    
    // Get the SOQL Expr by fieldList
    private String getSOQLFieldList(List<String> fieldList) {
        String SOQLFieldList = '';
        for (String field : fieldList) {
            SOQLFieldList += field + ', ';
        }
        
        return SOQLFieldList;
    }
    
    // Get the Field Set Member
    private List<String> getFieldsListByFieldSet(String fieldSetName) {
        List<String> fieldsList = new List<String>();
        List<Schema.FieldSetMember> fieldsetMembers = SObjectType.Account.FieldSets.getMap().
            get(fieldSetName).getFields();

        for (Schema.FieldSetMember member : fieldsetMembers) {
            fieldsList.add(member.getFieldPath());
        }

        return fieldsList;
    }
    
    // Inner Wrapper Class
    public class AccountWrapper {
        public String fieldLabel            {get; set;}
        public String fieldAPI              {get; set;}
        public Boolean isMasterNull         {get; set;}
        public Boolean isSlaveNull          {get; set;}
        public Boolean isSame               {get; set;}
        public Boolean isMasterChecked      {get; set;}
        public Boolean isSlaveChecked       {get; set;}
        
        public AccountWrapper() {}
    }
    
    // Need more change (RecordType, Assigned Owner on master)
    public PageReference mergeAccount() {
        // Get the User in the Data Service Specialist UserRole
        User usr;
        try {
            usr = [SELECT Id FROM User 
                   WHERE UserRole.Name = 
                   :this.USERROLE_PERSON_ACCOUNT_SOFT_DELETED
                   LIMIT 1];
        }
        catch (QueryException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                Label.CP_No_User_in_Data_Service_Specialist_UserRole));
            return null;
        }

        System.debug('wraps=>' + wraps);
        // Update Master
        for (AccountWrapper wrap : wraps) {
            // If isSlaveChecked is true, it means we choose 
            // slave field value to merge into master,
            // If isMasterChecked is true, it means master value doesn't need to change.
            if (wrap.isSlaveChecked) {
                master.put(wrap.fieldAPI, slave.get(wrap.fieldAPI));
            }
        }
        
        // Update Slave RecordTypeId and Owner
        slave.RecordTypeId = UtilRecordType.getRecordTypeIdByName('Account', 
            this.RECORDTYPE_PERSON_ACCOUNT_SOFT_DELETED); 
        slave.OwnerId = usr.Id;
        
        // If the merged record is the last suspected duplicate to the master record, 
        // after merge, also remove master record (checkbox) and Dup Number 
        // from the master record.
        Integer slaveCount = [SELECT COUNT() FROM Account 
                              WHERE DUP_Nummer__c = :master.DUP_Nummer__c
                              AND Master_Record__c = false];
        if (slaveCount == 1) {
            master.DUP_Nummer__c = null;
            master.Master_Record__c = false;
        }

        // Set SavePoint, if slave DML failed, master DML should be rollback .
        SavePoint sp = Database.setSavepoint();
        try {
            update master;
            update slave;
        }
        catch (DMLException e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                e.getDMLMessage(0)));
            return null;
        }
        
        return new PageReference('/' + master.Id);
    }
    
    // Get the Parameter value by Parameter Name
    private String getParameter(String param) {
        return ApexPages.currentPage().getParameters().get(param);
    }

    // Return to the previous page by retURL
    public PageReference previous() {
        System.debug(this.getParameter('retURL'));
        PageReference pr = new PageReference(this.getParameter('retURL'));
        pr.setRedirect(true);
        return pr;
    }
    
    // Click Cancel to return the master detail page
    public PageReference cancel() {
        return new PageReference('/' + master.Id);
    }
    
    // Method for selectAll Link
    // Check all radio by selectAllParam
    public void selectAll() {
        System.debug('selectAllParam=>' + selectAllParam);
        if (selectAllParam == 'master') {
            for (AccountWrapper wrap : wraps) {
                if (!wrap.isMasterNull) {
                    wrap.isMasterChecked = true;
                    wrap.isSlaveChecked = false;
                }
            }
        }
        else if (selectAllParam == 'slave') {
            for (AccountWrapper wrap : wraps) {
                if (!wrap.isSlaveNull) {
                    wrap.isSlaveChecked = true;
                    wrap.isMasterChecked = false;
                }
            }
        }
    }
}