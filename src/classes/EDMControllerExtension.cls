/*
    Type:       controller
    Purpose:    eDMSendResult General Controller
    User Story: US-eDM-002 - Send eDM content to customer

    Used By:    VF Page - eDMSendResult.page
    ---------------------------------------------------------------
    History:

    06-Mar-2013 Chris Huang (Breakingpoint)    Created

*/

public class EDMControllerExtension {
    /* Public Properties */
    public eDM__c edm {get;set;}

    /* Private Properties */
    private Account accountObject {get;set;}
    private Case caseObject {get;set;}
    private ApexPages.standardController controller {get;set;}


    /* Public Methods */
    
    public PageReference send(){
    
        //create task
        createActivity();
            
        // use the standard controller to perform the save and redirect
        controller.save();
        return null;
    }
          
    /* Private Methods */
      
    private void createActivity(){
    
        if(edm.eDM_Template__c!=null){
            Template__c edmt = [Select Id,Name From Template__c Where Id=:edm.eDM_Template__c];
            if(edmt!=null){
                eDMTask.eDM_Template__c = edmt.Name;
            }
        }        

        if(caseObject!=null){
            eDMTask.WhatId = caseObject.Id;
        }else if(accountObject!=null){
            eDMTask.WhatId = accountObject.id;
        }
        
        if(accountObject!=null){
	        List<Contact> contactList = [Select Id From Contact Where accountId = :accountObject.Id];	        
	        if(contactList!=null && contactList.size()>0){
	            eDMTask.WhoId = contactList[0].Id;
	        }    
        }
           
        eDMTask.RecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('eDM').getRecordTypeId();
        
        try{
            insert eDMTask;  
        } catch (Exception e){
            ApexPages.addMessages(e);   
        }
    }
  
    private Task eDMTask {
        get{
            if (eDMTask == null){
                Task t = new Task();
                //t.eDM_Template__c = edm.eDM_Template__c;
                t.Email_Address__c = edm.Email_Address_del__c;
                t.Subject = 'eDM';
                t.IsReminderSet = false;
                t.Status = 'Closed';
                t.Activity_Status__c = 'Sent';
                //t.Priority = '普通';
                eDMTask = t;
            }
            return eDMTask ;
        }
        set;
    }  
    
    /* Inner classes and methods */

    /* Static initialisers */
  
    public eDMControllerExtension(ApexPages.StandardController stdController) {
        // constructor
        controller = stdController;       
        this.edm = (eDM__c)stdController.getRecord();

        //set account
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        System.debug('------accountId:----'+accountId);
        if(accountId != null && accountId != ''){
            List<Account> aList = [Select Id,PersonEmail From Account Where Id = :accountId];
            System.debug('------aList.size():----'+aList.size());
            if(aList!=null && aList.size()>0){
                accountObject = aList[0];
            }               
            
            if(accountObject!=null){
                edm.Customer_Name__c = accountObject.Id;
                edm.Email_Address_del__c = accountObject.PersonEmail;
            }
        } 
        
        //set case if eDM from case
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        System.debug('------caseId:----'+caseId);
        if(caseId != null && caseId != ''){
           caseObject = [Select Id From Case Where Id = :caseId];
        }
    }
}