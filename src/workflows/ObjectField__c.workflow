<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetFieldUniqueID</fullName>
        <field>UniqueID__c</field>
        <formula>SystemObject__r.Name + &quot;.&quot; + Name</formula>
        <name>SetFieldUniqueID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SetUniqueID</fullName>
        <actions>
            <name>SetFieldUniqueID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ObjectField__c.UniqueID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
