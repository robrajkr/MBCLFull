/*
    Type:       Trigger
    Purpose:    Auto modify SentTotal field on DM Material when DM Request Status changed to 'Sent'
    User Story: US-QC-002
    Used By:    
    ---------------------------------------------------------------
    History:
    
    25-Mar-2013 Sinow Zhang (NTTData)  Created
*/
trigger GenerateQCs on Task (after update) 
{
    //Gets Task record type ids
    String IBTaskRecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('IB Call').getRecordTypeId();
    String OBTaskRecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('OB Call').getRecordTypeId();
    String SSITaskRecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('SSI Task').getRecordTypeId();
    
    //Gets QC__c record type ids
    String IBQCRecordTypeId = Schema.SObjectType.QC__c.getRecordTypeInfosByName().get('IB Call').getRecordTypeId();
    String OBQCRecordTypeId = Schema.SObjectType.QC__c.getRecordTypeInfosByName().get('OB Call').getRecordTypeId();
    String SSIQCRecordTypeId = Schema.SObjectType.QC__c.getRecordTypeInfosByName().get('SSI').getRecordTypeId();
    List<User> QCSVUsers = [select Id from User where Profile.Name = 'CAC QC SV' limit 1];
    
    List<QC__c> newQCs = new List<QC__c>();
    QC__c qc;
    
    for(Task t : Trigger.new)
    {
        //When Generate QC is true, insert IB/OB QC records.
        if(t.Generate_QC__c && !Trigger.oldMap.get(t.Id).Generate_QC__c)
        {
            qc = new QC__c();
            qc.CSR_Name__c = t.OwnerId;
            qc.Status__c = 'Open';
            if(t.recordTypeId == IBTaskRecordTypeId)
            {
                qc.RecordTypeId = IBQCRecordTypeId;
                newQCs.add(qc);
            }
            if(t.recordTypeId == OBTaskRecordTypeId)
            {
                qc.RecordTypeId = OBQCRecordTypeId;
                newQCs.add(qc);
            }
        }
        
        //When SSI Status is Successful, insert SSI QC records.
        if(t.SSI_Status__c == 'Successful' && Trigger.oldMap.get(t.Id).SSI_Status__c != 'Successful' && t.RecordTypeId == SSITaskRecordTypeId)
        {
            qc = new QC__c();
            qc.CSR_Name__c = t.OwnerId;
            qc.Status__c = 'Open';
            qc.RecordTypeId = SSIQCRecordTypeId;
            qc.SSI__c = t.WhatId;
            if(QCSVUsers.size() > 0)
            {
                qc.OwnerId = QCSVUsers[0].Id;
                qc.Task_ID__c = t.Id;
                newQCs.add(qc);
            }
        }
    }
    
    if(newQCs.size() > 0)
    {
        try
        {
            insert newQCs;
        }
        catch(DMLException ex)
        {
            system.debug(ex);
        }
    }
}