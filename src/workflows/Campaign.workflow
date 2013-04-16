<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Activate_Campaign</fullName>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Activate Campaign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivate_Campaign</fullName>
        <field>IsActive</field>
        <literalValue>0</literalValue>
        <name>Deactivate Campaign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Content_Preview</fullName>
        <description>To display the Message Detail of selected Template</description>
        <field>Content_Preview__c</field>
        <formula>Template__r.Message_Detail__c</formula>
        <name>Update Content Preview</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Activate Campaign When Status Changes to %22Started%22</fullName>
        <actions>
            <name>Activate_Campaign</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Status</field>
            <operation>equals</operation>
            <value>Started</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>CAC CRM Campaign,CAS Marketing Campaign,Central Marketing Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When Status changed to Started, update Active to true.
Record Type = CAC CRM Campaign,CAS Marketing Campaign,Central Marketing Campaign</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>To update Content Preview</fullName>
        <actions>
            <name>Update_Content_Preview</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( Template__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
