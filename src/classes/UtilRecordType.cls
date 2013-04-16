/*
    Type:       Utility for RecordType for replacing SOQL
    Purpose:    Get Record Type Name By Id or Id by Name
    User Story: US-DD-002
    Used By:    AccountMergeController.cls
    ---------------------------------------------------------------
    History:
    
    1. Mouse Created on 2013-3-11.

*/
public with sharing class UtilRecordType {
    /*
    // Gets the object record type name according to the recordTypeId.
    public static String getRecordTypeNameById(String objectName, Id recordTypeId){
        Schema.SobjectType d = Schema.getGlobalDescribe().get(objectName);
        Map<Id, Schema.RecordTypeInfo> rtMapById = d.getDescribe().getRecordTypeInfosById();
        Schema.RecordTypeInfo rtById =  rtMapById.get(recordTypeId);
        return rtById.getName();
    }
    */
    
    // Gets the object record type id according to the recordType name.
    public static String getRecordTypeIdByName(String objectName, String recordTypeName){
        Schema.SobjectType d = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.RecordTypeInfo> rtMapByName = d.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get(recordTypeName);
        return rtByName.getRecordTypeId();
    }
}