<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_Code_Field</fullName>
        <field>Unique_ID__c</field>
        <formula>Offering__c + &quot;-&quot; +  Package_Name__c</formula>
        <name>Update Unique Code Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Generate Unique Code</fullName>
        <actions>
            <name>Update_Unique_Code_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Package_Item__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Campaign Offering and Campaign Package_Name__c should be unique, the workflow is to generate the unique code</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
