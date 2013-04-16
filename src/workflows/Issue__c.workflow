<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Issue_Assignment_Notification</fullName>
        <ccEmails>vlee@salesforce.com</ccEmails>
        <description>Issue Assignment Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Issue_Assignment_Notification</template>
    </alerts>
    <alerts>
        <fullName>Non_PMO_Issue_Close_Notification</fullName>
        <description>Non-PMO Issue Close Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Issue_Close_Notification</template>
    </alerts>
    <alerts>
        <fullName>PMO_Issue_Close_Notification</fullName>
        <description>PMO Issue Close Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ray.chen@nttdata.com.production.full</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>xing.han@daimler.com.production.full</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Issue_Close_Notification</template>
    </alerts>
    <alerts>
        <fullName>PMO_Issue_need_update_notification</fullName>
        <description>PMO Issue need update notification</description>
        <protected>false</protected>
        <recipients>
            <field>Assign_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Issue_Need_Update_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_reminder_date</fullName>
        <field>Reminder_Date__c</field>
        <formula>Case(  Hidden_Formula_calculates_reminder_date__c ,
2, TODAY() +1,
3,TODAY() +7,
4,TODAY() +6,
5,TODAY() +5,
6,TODAY() +4,
0,TODAY() +3,
1,TODAY() +2,
NULL)</formula>
        <name>Update reminder date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Issue Assignment Notification</fullName>
        <actions>
            <name>Issue_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Assign_To__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Non PMO Issue close notification</fullName>
        <actions>
            <name>Non_PMO_Issue_Close_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Issue__c.Issue_Type__c</field>
            <operation>notEqual</operation>
            <value>Raise to PMO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PMO Issue close notification</fullName>
        <actions>
            <name>PMO_Issue_Close_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Issue__c.Issue_Type__c</field>
            <operation>equals</operation>
            <value>Raise to PMO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PMO Issue need update notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Issue__c.Issue_Type__c</field>
            <operation>equals</operation>
            <value>Raise to PMO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PMO Issue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.Reminder_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PMO Issue-update reminder date</fullName>
        <actions>
            <name>Update_reminder_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Issue__c.Issue_Type__c</field>
            <operation>equals</operation>
            <value>Raise to PMO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Issue__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
