/*
Copyright (c) 2012 salesforce.com, inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/*  
    This class implements a utility to automate the collection of Apex test class results 
    and will send out an email with the test results.  The class implmenets a schedulable
    job which will check if any Scheduled apex test jobs have completed and are ready
    for processing.
      This class works in conjunction with the AutomatedTestJobQueuer.cls
 */ 
global with sharing class AutomatedTestsJob implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        doExecute();
    }

    // Have to use a future method so the email will be sent out.
    @future (callout=true)
    public static void doExecute(){
        processAsyncResults();
    }
    
    /*
        Schedule String Format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    */
    
    public static void createScheduledJobs(){
        AutomatedTestsJob atj = new AutomatedTestsJob();  
        string sch = '0 01 * * * ?'; 
        Datetime sysTime = System.now();
        system.schedule('Process Queued Unit' + sysTime.getTime() ,sch,atj);
    }
    
    public static void processAsyncResults(){
        List<AutomatedTestingQueue__c> queuedTests = 
           [select id,
                   name,
                   AsyncId__c
              from AutomatedTestingQueue__c
             limit 5];
        
        if (queuedTests != null && queuedTests.size() > 0){
            Set<Id> AsyncIds = new Set<Id>();

            for (AutomatedTestingQueue__c queuedJob : queuedTests){
                 AsyncIds.add(queuedJob.AsyncId__c);
            }
            
            List<ApexTestQueueItem> queuedItems = checkClassStatus(AsyncIds);
            
            Map<Id, List<ApexTestQueueItem>> groupedTestsByJob = new Map<Id, List<ApexTestQueueItem>>();

            for (ApexTestQueueItem atqi : queuedItems){
                 if (groupedTestsByJob.containsKey(atqi.ParentJobId) == true){
                     List<ApexTestQueueItem> groupedTests = groupedTestsByJob.get(atqi.ParentJobId);
                     groupedTests.add(atqi);
                 }
                 else{
                     List<ApexTestQueueItem> groupedTests = new List<ApexTestQueueItem>();
                     groupedTests.add(atqi);
                     groupedTestsByJob.put(atqi.ParentJobId, groupedTests);
                 }
            }
            
            Set<Id> completedAsyncIds = getCompletedAsyncJobsIds(groupedTestsByJob);
            
            if (completedAsyncIds != null && completedAsyncIds.size() > 0){
                
                List<ApexTestResult> testResults = checkMethodStatus(completedAsyncIds);
                
                Map<Id, List<ApexTestResult>> groupedTestResultsByJob = new Map<Id, List<ApexTestResult>>();
                
                
                for (ApexTestResult testResult : testResults){
                    if (groupedTestResultsByJob.containsKey(testResult.AsyncApexJobId)){
                        List<ApexTestResult> groupedTestsResults = groupedTestResultsByJob.get(testResult.AsyncApexJobId);
                        groupedTestsResults.add(testResult);
                    }
                    else{
                        List<ApexTestResult> groupedTestsResults = new List<ApexTestResult>();
                        groupedTestsResults.add(testResult);
                        
                        groupedTestResultsByJob.put(testResult.AsyncApexJobId, groupedTestsResults );
                    }
                }

                List<AutomatedTestingQueue__c> queuedTestsToDelete = new List<AutomatedTestingQueue__c>(); 
                
                for (List<ApexTestResult> jobTestResults : groupedTestResultsByJob.values()){
                    sendTestResultEmail(jobTestResults);
                }
                
                for (AutomatedTestingQueue__c queuedTest : queuedTests){
                    for (Id completedAsyncId : completedAsyncIds){
                        if (queuedTest.AsyncId__c == completedAsyncId){
                            queuedTestsToDelete.add(queuedTest);
                            break;
                        }
                    }
                    if (groupedTestsByJob.containsKey(queuedTest.asyncId__c) == false){
                        queuedTestsToDelete.add(queuedTest);
                    }
                }
                
                if (queuedTestsToDelete.size() > 0){
                    delete queuedTestsToDelete;
                }
            }
        }
    }
    
    public static Set<Id> getCompletedAsyncJobsIds(Map<Id, List<ApexTestQueueItem>> groupedTestsByJob){
        Set<Id> completedAsyncJobIds = new Set<Id>();
        
        for (List<ApexTestQueueItem> jobTests : groupedTestsByJob.values()){
            if (jobTests == null || jobTests.size() == 0){
                continue;
            }
            
            Boolean allCompleted = true;
            
            for (ApexTestQueueItem queuedTest : jobTests){
                if (queuedTest.Status != 'Completed' && queuedTest.Status != 'Failed' && queuedTest.Status != 'Aborted'){
                    allCompleted = false;
                    break;
                }
            }
            
            if (allCompleted == true){
                completedAsyncJobIds.add(jobTests[0].ParentJobId);
            }
        }
        
        return completedAsyncJobIds;
    }
    
    private static void sendTestResultEmail(List<ApexTestResult> jobTestResults){
        system.debug(' In sendTestResultEmail');
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Use the custom setting AutomatedTestingEmail__c to store the recipient emails
        List<AutomatedTestingEmail__c> emailList = [select userEmail__c from AutomatedTestingEmail__c]; 
        
        String[] toAddresses = new String[]{};
        for (AutomatedTestingEmail__c eachEmail : [select userEmail__c from AutomatedTestingEmail__c] ) {
            toAddresses.add(eachEmail.userEmail__c);
        }

        mail.setToAddresses(toAddresses);
        String orgName = UserInfo.getOrganizationName();
        String emailSubject = 'Test Results ' + orgName + ' on ' + String.valueOf(Date.today()); 
    
        mail.setSubject(emailSubject);

        String testResultEmailbody = getTestResultHtmlEmailBody(jobTestResults);

        mail.setHtmlBody(testResultEmailbody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
        
        system.debug(' sent test results email');
    }
    
    private static String getTestResultHtmlEmailBody(List<ApexTestResult> jobTestResults){
        system.debug(' In getTestResultHtmlEmailBody');
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
        
        List<ApexTestResult> successTests = new List<ApexTestResult>();
        List<ApexTestResult> failedTests = new List<ApexTestResult>();
        
        for (ApexTestResult jobTestResult : jobTestResults){
            if (jobTestResult.Outcome == 'Pass'){
                successTests.add(jobTestResult);
            }
            else{
                failedTests.add(jobTestResult);
            }
        }
        
        Integer numTestsRun = successTests.size() + failedTests.size();
        Integer numFailures = failedTests.size();
        Integer successNum = numTestsRun - numFailures;
        
        if (successNum < 0){
            successNum = 0;
        }
        
        String testResultBody = '';
        
        // Unfortunately, css has to be inlined because many email service providers now exclude external CSS
        // because it can pose a security risk.

        testResultBody += '<table><tbody>';
        testResultBody += '<tr class="firstTr"><td><b>Total Tests Run:</b></td><td>' + numTestsRun + '</td></tr>';
        testResultBody += '<tr><td><b>Failure Count:</b></td><td>' + numFailures + '</td></tr>';
        testResultBody += '<tr><td><b>Success Count:</b></td><td>' + successNum + '</td></tr>';
        testResultBody +='</tbody></table>';
                
        if (numFailures > 0){
            
            testResultBody += '<div style="margin: 5px 0px; font-weight: bold;">Test Failures</div>';
            testResultBody += '<table><tbody>';            
            testResultBody += '';
            
            testResultBody += '';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Test Class</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Unit Test</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Message</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Stack Trace</th>';
            testResultBody += '<th style="text-align: left; padding-left: 5px;">Time (Ms)</th>';
            testResultBody += '';
            for (ApexTestResult testFailure : failedTests){
                String testResultURL = sfdcBaseURL + testFailure.id;
                testResultBody += '<tr>';
                
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexClass.Name +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + '<a href="' + testResultURL +'">'+ testFailure.MethodName +'</a>';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.message +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.stackTrace +'';
                testResultBody += '<td style="padding: 5px; vertical-align: top;">' + testFailure.ApexLog.DurationMilliseconds +'';
                //testResultBody += '<td style="vertical-align: top;">' + testFailure.type_x +'';
                testResultBody += '</tr>';
            }
            testResultBody += '</tbody></table>';
        }       
        
        return testResultBody;
    }


    // Get the status and pass rate for each class 
    // whose tests were run by the job. 
    // that correspond to the specified job ID. 
    
    public static List<ApexTestQueueItem> checkClassStatus(Set<ID> jobIds) {
        ApexTestQueueItem[] items = 
           [SELECT ApexClass.Name,
                   Status,
                   ExtendedStatus,
                   ParentJobId
            FROM ApexTestQueueItem 
            WHERE ParentJobId in :jobIds];
            
        for (ApexTestQueueItem item : items) {
            String extStatus = item.extendedstatus == null ? '' : item.extendedStatus;
            System.debug(item.ApexClass.Name + ': ' + item.Status + extStatus);
        }
        
        return items;
    }

    // Get the result for each test method that was executed. 
    public static List<ApexTestResult> checkMethodStatus(Set<ID> jobIds) {
        ApexTestResult[] results = 
           [SELECT id, 
                   Outcome,
                   MethodName,
                   Message,
                   StackTrace,
                   AsyncApexJobId, 
                   ApexClass.Name,
                   ApexClass.Body,
                   ApexClass.LengthWithoutComments,
                   ApexClass.NamespacePrefix,
                   ApexClass.Status,
                   ApexLogId,
                   ApexLog.DurationMilliseconds,
                   ApexLog.Operation,
                   ApexLog.Request,
                   ApexLog.Status,
                   ApexLog.Location,
                   ApexLog.Application
            FROM ApexTestResult 
            WHERE AsyncApexJobId in :jobIds];
            
        for (ApexTestResult atr : results) {
            System.debug(atr.ApexClass.Name + '.' + atr.MethodName + ': ' + atr.Outcome);
            if (atr.message != null) {
                System.debug(atr.Message + '\n at ' + atr.StackTrace);
            }
        }
        
        return results;
    }
    
   @isTest(SeeAllData=true)  
   private static  List<ApexTestResult> sampleDataTestResults () {
     ApexTestResult[] results = 
           [SELECT id, 
                   Outcome,
                   MethodName,
                   Message,
                   StackTrace,
                   AsyncApexJobId, 
                   ApexClass.Name,
                   ApexClass.Body,
                   ApexClass.LengthWithoutComments,
                   ApexClass.NamespacePrefix,
                   ApexClass.Status,
                   ApexLogId,
                   ApexLog.DurationMilliseconds,
                   ApexLog.Operation,
                   ApexLog.Request,
                   ApexLog.Status,
                   ApexLog.Location,
                   ApexLog.Application
            FROM ApexTestResult limit 10];
       return results;
   }
   
   static testmethod void testSendResultsEmail(){
    //get the base test result data
       List<ApexTestResult> sampleTestResults = sampleDataTestResults();
       AutomatedTestingEmail__c em1 = new AutomatedTestingEmail__c (name='bob', userEmail__c='bob@sfdc.com');
       insert em1;                  
       sendTestResultEmail(sampleTestResults);
   }
    
}