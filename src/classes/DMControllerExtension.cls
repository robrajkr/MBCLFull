/*
    Type:       controller
    Purpose:    DMSendResult General Controller
    User Story: US-DM-002 - Send DM content to customer

    Used By:    VF Page - DMSendResult.page
    ---------------------------------------------------------------
    History:

    28-Mar-2013 Chris Huang (Breakingpoint)    Created

*/

public class DMControllerExtension {
    /* Public Properties */
    public DM_Request__c dm {get;set;}
    //public Boolean afterSend {get;set;}


    /* Private Properties */
    private Account accountObject {get;set;}
    private Case caseObject {get;set;}
    private ApexPages.standardController controller {get;set;}
    
     /* Constructors */
      
    /* Public Methods */
    public PageReference send(){
        //create task
        createActivity();
        
        //afterSend = true;   
            
        // use the standard controller to perform the save and redirect
                 
        controller.save();  
        return null;
    }
  
  
    /* Private Methods */
  
    private void createActivity(){
         

        if(caseObject!=null){
            DMTask.WhatId = caseObject.Id;
        }else if(accountObject!=null){
            DMTask.WhatId = accountObject.id;
        }
        
        if(accountObject!=null){
            List<Contact> contactList = [Select Id From Contact Where accountId = :accountObject.Id];           
            if(contactList!=null && contactList.size()>0){
                DMTask.WhoId = contactList[0].Id;
            }    
        }
        
        DMTask.RecordTypeId = Schema.SObjectType.task.getRecordTypeInfosByName().get('DM').getRecordTypeId();
        
        try{
            insert DMTask;  
        } catch (Exception e){
            ApexPages.addMessages(e);   
        }
    }
  
    private Task DMTask {
        get{
            if (DMTask == null){
                Task t = new Task();
                //t.eDM_Template__c = edm.eDM_Template__c;
                t.Subject = 'DM';
                t.IsReminderSet = false;
                t.Status = 'Closed';
                t.Activity_Status__c = 'Sent';
                //t.Priority = '普通';
                DMTask = t;
            }
            return DMTask ;
        }
        set;
    } 

    /* Static initialisers */
  
    public DMControllerExtension(ApexPages.StandardController stdController) {
        // constructor
        controller = stdController;       
        this.dm = (DM_Request__c)stdController.getRecord();

        //set account
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        System.debug('------accountId:----'+accountId);
        if(accountId != null && accountId != ''){
            List<Account> aList = [Select Id From Account Where Id = :accountId];
            System.debug('------aList.size():----'+aList.size());
            if(aList!=null && aList.size()>0){
                accountObject = aList[0];
            }               
            
            if(accountObject!=null){
                dm.Customer_Name__c = accountObject.Id;
            }
        } 
        
        //set case if eDM from case
        String caseId = ApexPages.currentPage().getParameters().get('caseId');
        System.debug('------caseId:----'+caseId);
        if(caseId != null && caseId != ''){
           caseObject = [Select Id,CaseNumber From Case Where Id = :caseId];
           dm.Case_Number__c = caseId;
       }
    }
}