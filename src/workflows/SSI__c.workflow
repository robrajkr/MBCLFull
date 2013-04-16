<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_status_to_In_process</fullName>
        <description>DealerCheck Status=&apos;Valid&apos; or&apos; Suspect&apos;, SuspectDealer Review is not &apos;Reject&apos;, Status will be updated as &apos;In process&apos;.</description>
        <field>Status__c</field>
        <literalValue>In Process</literalValue>
        <name>Update status to &quot;In process&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_In_process_1</fullName>
        <description>If CarModelCheck Status=&apos;Valid&apos; or&apos; Suspect&apos;, SuspectCarModel Review is not &apos;Reject&apos;, Status will be updated as &apos;In process&apos;.</description>
        <field>Status__c</field>
        <literalValue>In Process</literalValue>
        <name>Update status to &apos;In process&apos; 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_invalid_for_Carmodel</fullName>
        <description>When field SuspectCarModel Review is &apos;Reject&apos;, Status will be updated as ‘Invalid’.</description>
        <field>Status__c</field>
        <literalValue>Invalid</literalValue>
        <name>Update status to &apos;invalid&apos; for Carmodel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_status_to_invalid</fullName>
        <description>Set criteria SuspectDealer Review is &apos;Reject&apos;, Status will be updated as ‘Invalid’</description>
        <field>Status__c</field>
        <literalValue>Invalid</literalValue>
        <name>update status to &apos;invalid&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update status to %22In process%22 When Carmodel check passed</fullName>
        <actions>
            <name>Update_status_to_In_process_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>SSI__c.CarModelCheck_Status__c</field>
            <operation>equals</operation>
            <value>Valid</value>
        </criteriaItems>
        <criteriaItems>
            <field>SSI__c.CarModelCheck_Status__c</field>
            <operation>equals</operation>
            <value>Suspect</value>
        </criteriaItems>
        <criteriaItems>
            <field>SSI__c.SuspectCarModel_Review__c</field>
            <operation>notEqual</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>If CarModelCheck Status=&apos;Valid&apos; or&apos; Suspect&apos;, SuspectCarModel Review is not &apos;Reject&apos;, Status will be updated as &apos;In process&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update status to %22In process%22 When Dealer check passed</fullName>
        <actions>
            <name>Update_status_to_In_process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>SSI__c.DealerCheck_Status__c</field>
            <operation>equals</operation>
            <value>Valid</value>
        </criteriaItems>
        <criteriaItems>
            <field>SSI__c.DealerCheck_Status__c</field>
            <operation>equals</operation>
            <value>Suspect</value>
        </criteriaItems>
        <criteriaItems>
            <field>SSI__c.SuspectDealer_Review__c</field>
            <operation>notEqual</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>DealerCheck Status=&apos;Valid&apos; or&apos; Suspect&apos;, SuspectDealer Review is not &apos;Reject&apos;, Status will be updated as &apos;In process&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update status to %27invalid%27 When Dealer check failed</fullName>
        <actions>
            <name>update_status_to_invalid</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SSI__c.SuspectDealer_Review__c</field>
            <operation>equals</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>When SuspectDealer Review is &apos;Reject&apos;, update status to &apos;invalid&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Updated status %E2%80%98Invalid%E2%80%99 When SuspectCarModel check failed</fullName>
        <actions>
            <name>Update_status_to_invalid_for_Carmodel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SSI__c.SuspectCarModel_Review__c</field>
            <operation>equals</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>When field SuspectCarModel Review is &apos;Reject&apos;, Status will be updated as ‘Invalid’.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
