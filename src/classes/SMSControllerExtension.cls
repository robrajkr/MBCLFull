/*
    Type:       controller
    Purpose:    SMSSendResult General Controller
    User Story: US-SMS-001 - Send SMS content to customer

    Used By:    VF Page - SMSSendResult.page
    ---------------------------------------------------------------
    History:

    07-Mar-2013 Sinow zhang (Nttdata)    Created
*/

public class SMSControllerExtension 
{
    /* Public Properties */
    public SMS__c sms { get; set; }
    public String templateId { get; set; }
    public String templateMessage { get; set; }
    public Account customer {get;set;}
    
    /* Private Properties */
    private Case caseObject {get;set;}
    private Map<String, String> templateMap { get; set; }
    private Map<String, String> templateNameMap { get; set; }
    private ApexPages.standardController controller {get;set;}

    /* Public Methods */
    public PageReference send() 
    {
        if(customer == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select one customer before send SMS.'));
            return null;
        }
        else if(customer.Second_Mobile__c == null && customer.PersonMobilePhone == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Customer Mobile Phone Number is null, Please fill it first.'));
        }
        if(templateId == null || templateId == '' || templateId == 'None')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select one SMS template.'));
            return null;
        }
        if(templateMessage == '' || templateMessage == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'SMS Preview is null, Please fulfill it.'));
            return null;
        }
        
        //create task
        createActivity();

        // use the standard controller to perform the save and redirect
        //return new PageReference('/' + customer.Id);
        return controller.cancel();
    }

    //set value to template message
    public PageReference parseTemplateMessage()
    {
        if(templateMap.containsKey(templateId)) 
        {
            if(templateMap.get(templateId).indexOf('{DEALER_') != -1)
            {
                if(sms.Dealer__c == null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select one Dealer.'));
                    return null;
                }
                templateMessage = optimzeContent(templateMap.get(templateId));
            }
            else
            {
                templateMessage = templateMap.get(templateId);
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select one SMS template.'));
            templateMessage = '';
        }
        return null;
    }

    //parse merge fields for message
    public String optimzeContent(String temp)
    {
        String handledContent = temp;
        if(handledContent.indexOf('{') != -1)
        {
            do
            {
                Integer mergeIndexStart = handledContent.indexOf('{');
                Integer mergeIndexEnd = handledContent.indexOf('}');
                String mergeObjectField = handledContent.subString(mergeIndexStart + 1, mergeIndexEnd);
                if(mergeObjectField.indexOf('_') != -1)
                {
                    String mergeObject = mergeObjectField.subString(0, mergeObjectField.indexOf('_'));
                    String mergeField = mergeObjectField.subString(mergeObjectField.indexOf('_') + 1);
                    if(mergeObject == 'DEALER' && sms.Dealer__c != null)
                    {
                        if(mergeField != 'ADDRESS')
                        {
                            String dealerQuery = 'select ' + mergeField + ' from Account where Id = \'' + sms.Dealer__c + '\' limit 1';
                            List<Account> dealerQuerys = Database.query(dealerQuery);
                            handledContent = handledContent.subString(0, mergeIndexStart) + dealerQuerys[0].get(mergeField) + handledContent.subString(mergeIndexEnd + 1);
                        }
                        else
                        {
                            Account dealerInfo = [select Dealer_Address_CN__c, City_CN__c, Dealer_Province__c from Account where Id = :sms.Dealer__c limit 1];
                            handledContent = handledContent.subString(0, mergeIndexStart) + dealerInfo.Dealer_Province__c + dealerInfo.City_CN__c + dealerInfo.Dealer_Address_CN__c + handledContent.subString(mergeIndexEnd + 1);
                        }
                    }
                    else
                    {
                        handledContent = handledContent.subString(0, mergeIndexStart) + ' ' + handledContent.subString(mergeIndexEnd + 1);
                    }
                }
                else
                {
                    handledContent = handledContent.subString(0, mergeIndexStart) + ' ' + handledContent.subString(mergeIndexEnd + 1);
                }
            }while(handledContent.indexOf('{') != -1);
        }
        return handledContent;
    }   

    //returns list options of templates
    public List<SelectOption> getTemplates() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--None--'));
        templateNameMap = new Map<String, String>();
        templateMap = new Map<String, String>();
        for(Template__c tem : [select Id, Name, Message_Detail__c from Template__c where RecordType.SObjectType='Template__c' and RecordType.Name='SMS' and Active__c = true])
        {
            options.add(new SelectOption(tem.Id, tem.Name));
            templateNameMap.put(tem.Id, tem.Name);
            templateMap.put(tem.Id, tem.Message_Detail__c);
        }
        return options;
    }

    /* Private Methods */
    private void createActivity()
    {
        if(caseObject != null)
        {
            smsTask.WhatId = caseObject.Id;
            if(customer != null)
            {
                Contact personContact = [select Id from Contact where AccountId = :customer.Id limit 1];
                smsTask.WhoId = personContact.Id;
            }
        }
        else
        {
            smsTask.WhatId = customer.id;
            Contact personContact = [select Id from Contact where AccountId = :customer.Id limit 1];
            smsTask.WhoId = personContact.Id;
        }
        
        if(sms.Dealer__c != null)
        {
            Account tempDealer = [select Id, Name from Account where Id = :sms.Dealer__c];
            smsTask.Dealer_Name__c = tempDealer.Name;
        }
        smsTask.SMS_Content__c = templateMessage;
        if(sms.Mobile__c)
        {
            smsTask.Phone__c = customer.PersonMobilePhone;
        }
        else if(sms.Secondary_Mobile__c)
        {
            smsTask.Phone__c = customer.Second_Mobile__c;
        }

        try
        {
            insert smsTask;
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
    }
    
    private Task smsTask 
    {
        get
        {
            if(smsTask == null)
            {
                smsTask = new Task();
                smsTask.Subject = 'SMS';
                smsTask.Status = 'Closed';
                smsTask.Activity_Status__c = 'Sent';
                smsTask.RecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('SMS').getRecordTypeId();
            }
            return smsTask;
        }
        set;
    }

    /* Static initialisers */
  
    public SMSControllerExtension(ApexPages.StandardController stdController) 
    {
        // constructor
        controller = stdController;       
        this.sms = (SMS__c)stdController.getRecord();
        if(sms == null)
        {
            sms = new SMS__c();
        }        
        
        //set account
        String accountId = ApexPages.currentPage().getParameters().get('accountId');

        if(accountId != null && accountId != '')
        {
            List<Account> aList = [Select Id, Name, PersonMobilePhone, Second_Mobile__c From Account Where Id = :accountId];
            if(aList.size() == 1)
            {
                customer = aList[0];
                sms.CustomerName__c = customer.Name;
                if(customer.Second_Mobile__c == null && customer.PersonMobilePhone == null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Customer Mobile Phone Number is null, Please fill it first.'));
                }
                if(customer.PersonMobilePhone != null && customer.PersonMobilePhone != '')
                {
                    sms.Mobile__c = true;
                }
                else if(customer.Second_Mobile__c != null && customer.Second_Mobile__c != '')
                {
                    sms.Secondary_Mobile__c = true;
                }
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have to select one customer before send SMS.'));
        }
        
        //set case if SMS from case
        String caseId = ApexPages.currentPage().getParameters().get('caseId');

        if(caseId != null && caseId != '')
        {
            caseObject = [Select Id, Account.Name, AccountId, Case_Dealer__c From Case Where Id = :caseId];
            if(caseObject.Case_Dealer__c != null)
            {
                sms.Dealer__c = caseObject.Case_Dealer__c;
            }
        }
    }
}