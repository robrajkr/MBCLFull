/*
    Type:       Apex Class
    Purpose:    Define methods used in DMMaterialTrigger
    User Story: US-DM-004
    Used By:    DMMaterialTrigger.trigger
    ---------------------------------------------------------------
    History:
    
    11-Mar-2013 Chris Huang (Breakingpoint)    Created
*/

public class DMRequestTriggerHandler { 
    

    public static void updateDaterialSentTotal(List<DM_Request__c> newList, List<DM_Request__c> oldList){
        
        System.debug('---------enter--------'); 
        
        map<Id, DM_Request__c> oldMap = new map<Id, DM_Request__c>();
        if(oldList!=null && oldList.size()>0){
            for(DM_Request__c dmr : oldList){
                oldMap.put(dmr.Id,dmr);
            }
        }
        
        System.debug('---------newList.size()---------'+newList.size());
        
        if(newList!=null && newList.size()>0){
            
            map<Id, Integer> updateMap = new map<Id,Integer>();
            
            for(DM_Request__c dmr : newList){

                if(dmr.Status__c == 'Sent' && (!oldMap.containsKey(dmr.Id) || oldMap.get(dmr.Id).Status__c!=dmr.Status__c)){
                    
                    if(dmr.Actual_DM_Material1__c!=null){
                        if(!updateMap.containsKey(dmr.Actual_DM_Material1__c)){
                            updateMap.put(dmr.Actual_DM_Material1__c,0);
                        }
                        Integer i = updateMap.get(dmr.Actual_DM_Material1__c) + 1;
                        updateMap.put(dmr.Actual_DM_Material1__c,i);
                    }
                    
                    if(dmr.Actual_DM_Material2__c!=null){
                        if(!updateMap.containsKey(dmr.Actual_DM_Material2__c)){
                            updateMap.put(dmr.Actual_DM_Material2__c,0);
                        }
                        Integer i = updateMap.get(dmr.Actual_DM_Material2__c) + 1;
                        updateMap.put(dmr.Actual_DM_Material2__c,i);
                    }
                    
                    if(dmr.Actual_DM_Material3__c!=null){
                        if(!updateMap.containsKey(dmr.Actual_DM_Material3__c)){
                            updateMap.put(dmr.Actual_DM_Material3__c,0);
                        }
                        Integer i = updateMap.get(dmr.Actual_DM_Material3__c) + 1;
                        updateMap.put(dmr.Actual_DM_Material3__c,i);
                    }
                               
                }//end if
                                
            }//end for
            
            System.debug('---------updateMap.size()--------'+updateMap.size());
            
            if(updateMap.size()>0){
            
                List<DM_Material__c> updateList = [Select Id, SentTotal__c From DM_Material__c Where Id in :updateMap.keySet()];
                
                for(DM_Material__c dmm : updateList){
                    if(dmm.SentTotal__c==null){
                        dmm.SentTotal__c = 0;
                    }
                    dmm.SentTotal__c += updateMap.get(dmm.Id);
                }
                
                if(updateList.size()>0){

                	update updateList;                      
      
                }
            
            }
        }   
    }

}