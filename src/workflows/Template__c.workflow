<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_eDM_Template_Name</fullName>
        <description>Update eDM Template Name = Car Series + eDM Template Type.</description>
        <field>Name</field>
        <formula>TEXT(Car_Series__c ) + &apos; - &apos; + TEXT( Type__c )</formula>
        <name>Update eDM Template Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update eDM Template Name</fullName>
        <actions>
            <name>Update_eDM_Template_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Template__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>eDM</value>
        </criteriaItems>
        <description>Auto update eDM Template Name = Car Series + Type</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
