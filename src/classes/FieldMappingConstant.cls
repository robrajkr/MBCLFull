/*
    Type:       Save the Field Mapping Constant
    Purpose:    Store the constant used in Trigger and Class
    User Story: US-CP-014, US-CP-12, US-DD-002
    Used By:    TriggerSales, TriggerAftersales, AccountMergeController
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-03-05
    2. Mouse remove Purchase_Date__c => Sales_Invoice_Date__c 
       from SALES_FIELD_MAPPING_MAP on 2013-03-19
*/
public class FieldMappingConstant {
    // Field mapping between Vehicle Relationship and Sales
    public final static Map<String, String> SALES_FIELD_MAPPING_MAP = 
        new Map<String, String> {'Selling_Dealer__c' => 'Sales_Dealer__c'};
    
    // Field mapping between Vehicle Relationship and Aftersales
    public final static Map<String, String>  AFTERSALES_FIELD_MAPPING_MAP = 
        new Map<String, String> {'Last_Service_Dealer__c' => 'Service_Dealer__c'};
        
    // Define Datetime fields mapping with Phone fields and DMS Address
    public final static Map<String, String> PHONE_DMS_FIELDS_MAPPING = 
        new Map<String, String> {
            'Extension_Number__c' => 'Last_Successful_Call_Extension_Number__c',
            'PersonHomePhone' => 'Last_Successful_Call_Home_Phone__c',
            'Phone' => 'Last_Successful_Call_Office_Phone__c',
            'PersonMobilePhone' => 'Last_Successful_Call_Mobile__c',
            'Second_Mobile__c' => 'Last_Successful_Call_Second_Mobile__c',
            'DMS_Address__c' => 'LastModifiedDate'
    };
}