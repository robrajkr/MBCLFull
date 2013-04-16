<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>EP_Dealer_Codes</fullName>
        <apiVersion>27.0</apiVersion>
        <description>Send Dealer codes to EP</description>
        <endpointUrl>https://crm-dev.mercedes-benz.com.cn/webservices/DealerMappingUpdate</endpointUrl>
        <fields>Dealer_DMS_CRM_Code_2__c</fields>
        <fields>Dealer_DMS_CRM_Code__c</fields>
        <fields>Dealer_DMS_SR_Code_2__c</fields>
        <fields>Dealer_DMS_SR_Code__c</fields>
        <fields>Dealer_Default_Flag__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>ep.user1@daimler.full</integrationUser>
        <name>EP Dealer Codes</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Dealer Mapping Update</fullName>
        <actions>
            <name>EP_Dealer_Codes</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Send updates to DMS system when the DMS codes or Default Flag have been updated in SFDC</description>
        <formula>OR( ISCHANGED( Dealer_Default_Flag__c ) , ISCHANGED( Dealer_DMS_SR_Code__c ) ,  ISCHANGED( Dealer_DMS_SR_Code_2__c )  ,  ISCHANGED( Dealer_DMS_CRM_Code__c )  ,  ISCHANGED( Dealer_DMS_CRM_Code_2__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
