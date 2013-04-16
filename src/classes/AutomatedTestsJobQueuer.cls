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
    This class implements a utility to automate the running of Apex test classes. 
    The class implmenets a schedulable job which will query for all classes that contain 
    'test' in the class name.  It will queue an Apex synch test job with these classes.
    The system will run in the tests asynchronously in the background. 
      This class works in conjunction with the AutomatedTestingJob.cls which will process
     the test job results.    
 */

global with sharing class AutomatedTestsJobQueuer implements schedulable {
    
    global void execute(SchedulableContext SC) {
        doExecute();
    }
    
    @future (callout=true)
    public static void doExecute(){
        enqueueUnitTests();
    }
    
    public static void createScheduledJob(){
        AutomatedTestsJobQueuer  atj = new AutomatedTestsJobQueuer();  
        
        string sch = '0 00 23 ? * SUN';  // default run every sunday at 11pm
        system.schedule('Enqueue Unit Tests schedule[' + sch +  ']',sch,atj);
    }

  /* Allows us to externally enqueue our unit tests. For example,
       whenever we check our code into source control, we could
       run our unit tests.
    */
    webservice static void enqueueUnitTests(){      
        enqueueTests(false);
    }
    
    
        // Enqueue all classes beginning with "Test".  
    
    public static void enqueueTests(Boolean isTest) {
       /* The first thing you need to do is query the classes that contain
         the unit tests you want executed.
          For our purposes we'll look at all classes that don't have a namspace.
       */
            
       ApexClass[] testClasses = 
         [SELECT Id,
                 Name
            FROM ApexClass 
           WHERE NamespacePrefix = null];
              
       Integer testClassCnt = testClasses != null ? testClasses.size() : 0;
        
       system.debug('   enqueueTests::testClassCnt ' + testClassCnt);
            
       if (testClassCnt > 0) {
          /*
             Insertion of the ApexTestQueueItem causes the unit tests to be 
             executed. Since they're asynchronous, the apex async job id
             needs to be stored somewhere so we can process the test results
             when the job is complete.
          */
          ApexTestQueueItem[] queueItems = new List<ApexTestQueueItem>();
            
          for (ApexClass testClass : testClasses) {
              system.debug('   enqueueTests::testClass ' + testClass);
                
              queueItems.add(new ApexTestQueueItem(ApexClassId=testClass.Id));
          }
          if (!isTest){
              insert queueItems;
              // Get the job ID of the first queue item returned. 
    
              ApexTestQueueItem item = 
                [SELECT ParentJobId
                   FROM ApexTestQueueItem 
                  WHERE Id=:queueItems[0].Id
                  LIMIT 1];
                
              AutomatedTestingQueue__c atq = new AutomatedTestingQueue__c(
                  AsyncId__c = item.parentjobid, name='apexTest-'+ String.valueOf(Datetime.Now())
              );
    
              insert atq;
          } else {  // is test
               AutomatedTestingQueue__c atq = new AutomatedTestingQueue__c( 
                    AsyncId__c = 'test', name='apexTest-'+ String.valueOf(Datetime.Now())
               );
               insert atq;     
          }
       }
    }
    
   static testmethod void testJobQueue(){
    //get the base test result data
        enqueueTests(true);
        List<AutomatedTestingQueue__c> queuedTests = [select id, name, AsyncId__c from AutomatedTestingQueue__c ];
        System.Assert(queuedTests.size() > 0, 'Should have at least one queued job item');
        createScheduledJob();
   }
    
        
}