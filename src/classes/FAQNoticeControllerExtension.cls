public class FAQNoticeControllerExtension{

    public List<FAQ_Notice__c> results {
        get {
            if(results ==null){ 
                results = new List<FAQ_Notice__c>();
            }
            return results ;            
        }            
        set;            
    }   
     
    public String noticeTitle {
        get {
            if(noticeTitle==null){ 
                noticeTitle='';
            }
            return noticeTitle;            
        }            
        set;            
    } 
    
    public FAQNoticeControllerExtension(ApexPages.StandardController stdController) {

        //FAQ_Notice__c notice = (FAQ_Notice__c)stdController.getRecord();
        
        results = [Select Id,Name,Message_Detail__c From FAQ_Notice__c Where CreatedDate = LAST_N_DAYS:7  Order by Id Desc];

        if(results !=null && results.size()>0){
            //noticeContent = notice.Notice_Content__c;  
            noticeTitle = results[0].Name;      
        }        

        //System.debug('noticeContent = ' + noticeContent );
    }

}