<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>timesheet_reminder_Email</fullName>
        <description>timesheet reminder Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/timesheet_reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>status_to_approve</fullName>
        <field>Status__c</field>
        <literalValue>Approve</literalValue>
        <name>status to approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_to_draft2</fullName>
        <field>Status__c</field>
        <literalValue>Draft</literalValue>
        <name>status to draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_to_need_review</fullName>
        <field>Status__c</field>
        <literalValue>Need review</literalValue>
        <name>status to need review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status_to_reject</fullName>
        <field>Status__c</field>
        <literalValue>Reject</literalValue>
        <name>status to reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>timesheet reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Time_sheet__c.Status__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
