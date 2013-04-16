/*
    Type:       Utility for preparing test data
    Purpose:    Prepare Test data for Unit Test
    User Story: 
    Used By:    DealerSearchControllerTest.cls, 
                AccountMergeControllerTest.cls,
                CarModelComparisonControllerTest.cls,
                TriggerVehicleRelationshipTest.cls,
                TriggerSalesTest.cls,
                TriggerAftersalesTest.cls,
                DMRequestTriggerHandlerTest.cls
                EDMControllerExtensionTest.cls
                FAQNoticeControllerExtensionTest.cls
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-13
    2. Chris Overwrite createUser method by RoleName and ProfileName on 2013-03-14
    4. Mouse add Singleton and simple factory pattern to this class on 2013-03-15
*/
@isTest
Public class UtilTestData {
    private static Map<String, Id> recordTypeMap;
    private static Map<String, Id> roleMap;
    private static Map<String, Id> profileMap;
    
    public final static String ACCOUNT_RT_PERSON_ACCOUNT = 'Person Account';
    public final static String ACCOUNT_RT_DEALER = 'Dealer';
    public final static Integer BATCH_SIZE = 101;
    
    // Initiate recordTypeMap
    private static Map<String, Id> getRecordTypeMapInstance() {
        if (recordTypeMap == null) {
            recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [SELECT Id, Name, SobjectType FROM RecordType LIMIT 1000]) {
                recordTypeMap.put(rt.Name + rt.SobjectType, rt.Id);
            }
        }
        
        return recordTypeMap;
    }
    
    // Initiate roleMap
    private static Map<String, Id> getUserRoleMapInstance() {
        if (roleMap == null) {
            roleMap = new Map<String, Id>();
            for (UserRole role : [SELECT Id, Name FROM UserRole LIMIT 1000]) {
                roleMap.put(role.Name, role.Id);
            }
        }
        
        return roleMap;
    }
    
    // Initiate profileMap
    private static Map<String, Id> getProfileMapInstance() {
        if (profileMap == null) {
            profileMap = new Map<String, Id>();
            for (Profile prof : [SELECT Id, Name FROM Profile LIMIT 1000]) {
                profileMap.put(prof.Name, prof.Id);
            }
        }
        
        return profileMap;
    }
    
    // Get UserRoleId by Role Name
    private static Id getUserRoleId(String roleName) {
        return getUserRoleMapInstance().get(roleName);
    }
    
    // Get ProfileId by Profile Name
    private static Id getProfileId(String profileName) {
        return getProfileMapInstance().get(profileName);
    }
    
    // Create Test User
    private static User createUser(Id userRoleId, Id profileId) {
        User usr = new User();
        usr.UserName = 'test' + Math.rint(Math.random() * 100000) + '@daimler.com';
        usr.UserRoleId = userRoleId;
        usr.ProfileId = profileId;
        usr.LastName = 'Test User';
        usr.Email = 'test001@daimler.com.full';
        usr.Alias = 'test';
        usr.TimeZoneSidKey = 'Asia/Shanghai';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.localesidkey='en_US';
        
        insert usr;
        return usr;
    }

    // Create Test User by Role Name and Profile Name
    public static User createUser(String roleName, String profileName) {
        return createUser(getUserRoleId(roleName), 
                          getProfileId(profileName));
    }

    public static Sobject createSobject(Sobject so, String recordTypeName) {
        so = initiateSobject(so, recordTypeName);
        
        insert so;
        return so;
    }

    public static List<Sobject> createSobjects(List<Sobject> sos, String recordTypeName) {
        sos = initiateSobjects(sos, recordTypeName);

        insert sos;
        return sos;
    }
    
    // Initiate sobjects which number is BATCH_SIZE
    public static List<Sobject> initiateSobjects(List<Sobject> sos, String recordTypeName) {
        for (Sobject so : sos) {
            so = initiateSobject(so, recordTypeName);
        }

        return sos;
    }
    
    public static Sobject initiateSobject(Sobject so, String recordTypeName) {
        if (so instanceof Account) {
            if (recordTypeName == ACCOUNT_RT_PERSON_ACCOUNT) {
                so = initiatePersonAccount((Account) so);
            }
            else if (recordTypeName == ACCOUNT_RT_DEALER) {
                so = initiateDealer((Account) so);
            }
        }
        else if (so instanceof Contact) {
            so = initiateContact((Contact) so);
        }
        else if (so instanceof Vehicle__c) {
            so = initiateVehicle((Vehicle__c) so);
        }
        else if (so instanceof Vehicle_Relationship__c) {
            so = initiateVehicleRelationship((Vehicle_Relationship__c) so);
        }
        else if (so instanceof Sales__c) {
            so = initiateSales((Sales__c) so);
        }
        else if (so instanceof Aftersales__c) {
            so = initiateAftersales((Aftersales__c) so);
        }
        else if (so instanceof Car_Model__c) {
            so = initiateCarModel((Car_Model__c) so);
        }
        else if (so instanceof Attribute__c) {
            so = initiateAttribute((Attribute__c) so);
        }
        else if (so instanceof Car_Model_Attribute__c) {
            so = initiateCarModelAttribute((Car_Model_Attribute__c) so);
        }
        
        return so;
    }
    
    // Create Unsaved Dealer
    private static Account initiateDealer(Account acc) {
        acc.RecordTypeId = 
            getRecordTypeMapInstance().get(UtilTestData.ACCOUNT_RT_DEALER  + 'Account');
        acc.Dealer_Alternate_Name__c = 'Test Alternate';
        acc.Phone = '010-00000000';
        acc.Dealer_GC_Code__c = 'gc code';
        acc.Dealer_GS_Code__c = 'gs code';
        acc.Name = acc.Name == null ? 'test dealer' : acc.Name;
        
        return acc;
    }
    
    // Create Unsaved Person Account
    // N.B. Name is read only for Person Account
    private static Account initiatePersonAccount(Account acc) {
        acc.RecordTypeId = 
            getRecordTypeMapInstance().get(UtilTestData.ACCOUNT_RT_PERSON_ACCOUNT + 'Account');
        // acc.Name = 'Test';
        acc.LastName = 'Customer';
        acc.Gender__c = '0=Male';
        acc.ZipCode__c = '200235';
        acc.Type = acc.Type == null ? '0=Company' : acc.Type;
        acc.Phone = acc.Phone == null ? '010-00000000' : acc.Phone; 
        acc.Status__c = acc.Status__c == null ? '0=Customer' : acc.Status__c;
        
        return acc;
    }

    // Create Unsaved Contact
    private static Contact initiateContact(Contact con) {
        con.FirstName = 'Someone';
        con.LastName = 'Benz';
        
        return con;
    }

    // Create Unsaved Vehicle
    // UsVIN__c Length must be 17, 
    // EuroVIN__c length must be 17 or 18
    private static Vehicle__c initiateVehicle(Vehicle__c vehicle) {
        vehicle.UsVIN__c = 'usvin111111111111'; 
        vehicle.EuroVIN__c = 'eurovin1234567890';
        vehicle.Brand__c = 'MB';
        vehicle.Class__c = 'A-Class';
        vehicle.Model__c = '130i';
        vehicle.Colour__c = '40 黑色';
        vehicle.CommissionNumber__c = '123456';
        
        return vehicle;
    }
    
    // Create Unsaved Vehicle Relationship
    private static Vehicle_Relationship__c initiateVehicleRelationship(Vehicle_Relationship__c 
        relationship) {
            
        relationship.RegistrationProvince__c = '上海';
        relationship.Registration_City__c = '上海';
        relationship.Status__c = '0=Previously Owned';
        relationship.Main_Usage__c = '0=Taxi';
        relationship.Ownership__c = '1=Company';
        relationship.Car_Relation__c = 'User';
        relationship.New_Used__c = '0=New';
        relationship.Validity__c = 'Unknown';
        relationship.Purchase_Date__c = System.today();
        relationship.Registration_Date__c = System.today();
        
        return relationship;
    }

    // Create Unsaved Sales
    // If some field value are null, system will suibianly assign a value to it.
    private static Sales__c initiateSales(Sales__c sales) {
        sales.Name = 'test sales';
        sales.Valid__c = 'Unknow';
        
        sales.Sales_Handover_Date__c = sales.Sales_Handover_Date__c == null ? 
           System.today() : sales.Sales_Handover_Date__c;
           
        sales.Sales_Invoice_Date__c = sales.Sales_Invoice_Date__c == null ? 
           System.today() : sales.Sales_Invoice_Date__c;
           
        sales.Sales_Contract_Date__c = sales.Sales_Contract_Date__c == null ? 
           System.today() : sales.Sales_Contract_Date__c;
           
        sales.Sales_Person__c = sales.Sales_Person__c == null ? 'test' : 
           sales.Sales_Person__c;
           
        sales.Sales_Dealer__c = sales.Sales_Dealer__c == null ? 
           initiateDealer(new Account()).Id : sales.Sales_Dealer__c;
        
        return sales;
    }

    // Create Unsaved Aftersales
    private static Aftersales__c initiateAftersales(Aftersales__c aftersales) {
        aftersales.Name = 'test aftersales';
        aftersales.Valid__c = false;
        aftersales.Service_Dealer__c = aftersales.Service_Dealer__c == null ? 
           initiateDealer(new Account()).Id : aftersales.Service_Dealer__c;
        
        return aftersales;
    }
    
    // Create Unsaved Car Model
    private static Car_Model__c initiateCarModel(Car_Model__c carModel) {
        carModel.Name = carModel.Name == null ? 'test Benz' : 
           carModel.Name;
        carModel.Brand__c = 'MB';
        carModel.Model__c = 'B200';
        carModel.Series__c = 'A-Class';
        carModel.Description__c = 'Good Niubi Car';
        
        return carModel;
    }
    
    // Create Unsaved Attribute
    private static Attribute__c initiateAttribute(Attribute__c attr) {
        attr.Name = attr.Name == null ? '市场价' : attr.Name;
        attr.Attribute_Category__c = attr.Attribute_Category__c == null ?
           '基本参数' : attr.Attribute_Category__c;
        attr.Attribute_Type__c = attr.Attribute_Type__c == null ? 
           '价格' : attr.Attribute_Type__c;
        attr.Description__c = 'Niubi Attribute';

        return attr;
    }

    // Create Unsaved Car Model Attribute
    private static Car_Model_Attribute__c initiateCarModelAttribute(Car_Model_Attribute__c 
        carModelAttr) {
            
        carModelAttr.Attribute__c = carModelAttr.Attribute__c == null ?
           initiateAttribute(new Attribute__c()).Id : carModelAttr.Attribute__c;
        
        carModelAttr.Car_Model__c = carModelAttr.Car_Model__c == null ?
           initiateCarModel(new Car_Model__c()).Id : carModelAttr.Car_Model__c;
        
        carModelAttr.Value__c = '1000000';
        carModelAttr.Description__c = '好贵呀, 好好呀，好……呀';
        
        return carModelAttr;
    }
}