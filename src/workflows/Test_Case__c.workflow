<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Upate_Status_to_Failed</fullName>
        <field>Status__c</field>
        <literalValue>Failed</literalValue>
        <name>Upate Status to Failed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upate_Status_to_Passed</fullName>
        <field>Status__c</field>
        <literalValue>Passed</literalValue>
        <name>Upate Status to Passed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upate_Status_to_WIP</fullName>
        <field>Status__c</field>
        <literalValue>WIP</literalValue>
        <name>Upate Status to WIP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Upate Status to Failed</fullName>
        <actions>
            <name>Upate_Status_to_Failed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When total test steps&apos; status contains Failed and status doesn&apos;t contain None, system should update Test Case Status to Failed.</description>
        <formula>and (Count_Failed_Step__c  +  Count_Passed__c  =  Count_Steps__c ,  Count_Failed_Step__c  &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upate Status to Passed</fullName>
        <actions>
            <name>Upate_Status_to_Passed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When total test steps&apos; status equal to Passed, system should update Test Case Status to Passed.</description>
        <formula>Count_Passed__c  =  Count_Steps__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Upate Status to WIP</fullName>
        <actions>
            <name>Upate_Status_to_WIP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When total test steps&apos; status contains None, system should update Test Case Status to WIP.</description>
        <formula>Count_Failed_Step__c  +  Count_Passed__c   &lt;  Count_Steps__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
