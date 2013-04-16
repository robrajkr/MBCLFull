<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_DM_Request_External_Id</fullName>
        <description>Auto update DM Request External Id = DM Number.</description>
        <field>DM_Request_External_Id__c</field>
        <formula>Name</formula>
        <name>Update DM Request External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateDMRequestExternalId</fullName>
        <actions>
            <name>Update_DM_Request_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Auto update DM Request External Id = DM Number.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
