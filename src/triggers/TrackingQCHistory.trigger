/*
    Type:       Trigger
    Purpose:    Auto track field history when QC record be changed.
    User Story: US-QC-014
    Used By:    
    ---------------------------------------------------------------
    History:
    
    27-Mar-2013 Sinow Zhang (NTTData)  Created
*/
trigger TrackingQCHistory on QC__c (after update) 
{
    List<QC_History__c> QCHistorys = new List<QC_History__c>();
    QC_History__c qch;
    
    for(QC__c qc : Trigger.new)
    {
        if(qc.Status__c == 'Complete')
        {
            //If field value changed, create new QC history records
            if(qc.Provide_Accurate_Complete_Information__c != Trigger.oldMap.get(qc.Id).Provide_Accurate_Complete_Information__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Provide Accurate Complete Information', qc.Provide_Accurate_Complete_Information__c, Trigger.oldMap.get(qc.Id).Provide_Accurate_Complete_Information__c));
            }
            if(qc.Q1_Comments__c != Trigger.oldMap.get(qc.Id).Q1_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Provide Accurate Complete Info Comments', qc.Q1_Comments__c, Trigger.oldMap.get(qc.Id).Q1_Comments__c));
            }
            if(qc.Document_Accuracy__c != Trigger.oldMap.get(qc.Id).Document_Accuracy__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Document Accuracy', qc.Document_Accuracy__c, Trigger.oldMap.get(qc.Id).Document_Accuracy__c));
            }
            if(qc.Q2_Comments__c != Trigger.oldMap.get(qc.Id).Q2_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Document Accuracy Comments', qc.Q2_Comments__c, Trigger.oldMap.get(qc.Id).Q2_Comments__c));
            }
            if(qc.Follow_The_Operation_Process__c != Trigger.oldMap.get(qc.Id).Follow_The_Operation_Process__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Follow The Operation Process', qc.Follow_The_Operation_Process__c, Trigger.oldMap.get(qc.Id).Follow_The_Operation_Process__c));
            }
            if(qc.Q3_Comments__c != Trigger.oldMap.get(qc.Id).Q3_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Follow The Operation Process Comments', qc.Q3_Comments__c, Trigger.oldMap.get(qc.Id).Q3_Comments__c));
            }            
            if(qc.Following_Questionnaire_Logic__c != Trigger.oldMap.get(qc.Id).Following_Questionnaire_Logic__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Following Questionnaire Logic', qc.Following_Questionnaire_Logic__c, Trigger.oldMap.get(qc.Id).Following_Questionnaire_Logic__c));
            }
            if(qc.Q4_Comments__c != Trigger.oldMap.get(qc.Id).Q4_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Following Questionnaire Logic Comments', qc.Q4_Comments__c, Trigger.oldMap.get(qc.Id).Q4_Comments__c));
            }
            if(qc.Correctly_Interpret_The_Questionnaire__c != Trigger.oldMap.get(qc.Id).Correctly_Interpret_The_Questionnaire__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Correctly Interpret The Questionnaire', qc.Correctly_Interpret_The_Questionnaire__c, Trigger.oldMap.get(qc.Id).Correctly_Interpret_The_Questionnaire__c));
            }
            if(qc.Q5_Comments__c != Trigger.oldMap.get(qc.Id).Q5_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Correctly Interpret The Questio Comments', qc.Q5_Comments__c, Trigger.oldMap.get(qc.Id).Q5_Comments__c));
            }
            if(qc.Familiar_MBCL_Smart_Knowledge__c != Trigger.oldMap.get(qc.Id).Familiar_MBCL_Smart_Knowledge__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Familiar MBCL/Smart/ Knowledge', qc.Familiar_MBCL_Smart_Knowledge__c, Trigger.oldMap.get(qc.Id).Familiar_MBCL_Smart_Knowledge__c));
            }
            if(qc.Q6_Comments__c != Trigger.oldMap.get(qc.Id).Q6_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Familiar MBCL/Smart/ Knowledge Comments', qc.Q6_Comments__c, Trigger.oldMap.get(qc.Id).Q6_Comments__c));
            }
            if(qc.Responsibility__c != Trigger.oldMap.get(qc.Id).Responsibility__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Responsibility', qc.Responsibility__c, Trigger.oldMap.get(qc.Id).Responsibility__c));
            }
            if(qc.Q7_Comments__c != Trigger.oldMap.get(qc.Id).Q7_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Responsibility Comments', qc.Q7_Comments__c, Trigger.oldMap.get(qc.Id).Q7_Comments__c));
            }
            if(qc.Standard_Opening__c != Trigger.oldMap.get(qc.Id).Standard_Opening__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Standard Opening', qc.Standard_Opening__c, Trigger.oldMap.get(qc.Id).Standard_Opening__c));
            }
            if(qc.Q8_Comments__c != Trigger.oldMap.get(qc.Id).Q8_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Standard Opening Comments', qc.Q8_Comments__c, Trigger.oldMap.get(qc.Id).Q8_Comments__c));
            }
            if(qc.Proper_Pronunciation_Intonation_Speed__c != Trigger.oldMap.get(qc.Id).Proper_Pronunciation_Intonation_Speed__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Proper Pronunciation&Intonation&Speed', qc.Proper_Pronunciation_Intonation_Speed__c, Trigger.oldMap.get(qc.Id).Proper_Pronunciation_Intonation_Speed__c));
            }
            if(qc.Q9_Comments__c != Trigger.oldMap.get(qc.Id).Q9_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Proper Pronunciation&Intonation Comments', qc.Q9_Comments__c, Trigger.oldMap.get(qc.Id).Q9_Comments__c));
            }
            if(qc.Specification_Polite_Language__c != Trigger.oldMap.get(qc.Id).Specification_Polite_Language__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Specification - Polite Language', qc.Specification_Polite_Language__c, Trigger.oldMap.get(qc.Id).Specification_Polite_Language__c));
            }
            if(qc.Q10_Comments__c != Trigger.oldMap.get(qc.Id).Q10_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Specification - Polite Language Comments', qc.Q10_Comments__c, Trigger.oldMap.get(qc.Id).Q10_Comments__c));
            }
            if(qc.Specification_Spoken_Language__c != Trigger.oldMap.get(qc.Id).Specification_Spoken_Language__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Specification - Spoken Language', qc.Specification_Spoken_Language__c, Trigger.oldMap.get(qc.Id).Specification_Spoken_Language__c));
            }
            if(qc.Q11_Comments__c != Trigger.oldMap.get(qc.Id).Q11_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Standard Conclusion Comments', qc.Q11_Comments__c, Trigger.oldMap.get(qc.Id).Q11_Comments__c));
            }
            if(qc.Standard_Conclusion__c != Trigger.oldMap.get(qc.Id).Standard_Conclusion__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Standard Conclusion Comments', qc.Standard_Conclusion__c, Trigger.oldMap.get(qc.Id).Standard_Conclusion__c));
            }
            if(qc.Q13_Comments__c != Trigger.oldMap.get(qc.Id).Q13_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Specification - Spoken Language Comments', qc.Q13_Comments__c, Trigger.oldMap.get(qc.Id).Q13_Comments__c));
            }
            if(qc.Communicate_Ability_Listening_Ability__c != Trigger.oldMap.get(qc.Id).Communicate_Ability_Listening_Ability__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability - Listening Ability', qc.Communicate_Ability_Listening_Ability__c, Trigger.oldMap.get(qc.Id).Communicate_Ability_Listening_Ability__c));
            }
            if(qc.Q12_Comments__c != Trigger.oldMap.get(qc.Id).Q12_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability - Listening Comments', qc.Q12_Comments__c, Trigger.oldMap.get(qc.Id).Q12_Comments__c));
            }
            if(qc.Communicate_Ability_Initiative__c != Trigger.oldMap.get(qc.Id).Communicate_Ability_Initiative__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability - Initiative', qc.Communicate_Ability_Initiative__c, Trigger.oldMap.get(qc.Id).Communicate_Ability_Initiative__c));
            }
            if(qc.Q15_Comments__c != Trigger.oldMap.get(qc.Id).Q15_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability - Initiative Comments', qc.Q15_Comments__c, Trigger.oldMap.get(qc.Id).Q15_Comments__c));
            }
            if(qc.Communicate_Ability_Rapid_Response__c != Trigger.oldMap.get(qc.Id).Communicate_Ability_Rapid_Response__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability - Rapid Response', qc.Communicate_Ability_Rapid_Response__c, Trigger.oldMap.get(qc.Id).Communicate_Ability_Rapid_Response__c));
            }
            if(qc.Q14_Comments__c != Trigger.oldMap.get(qc.Id).Q14_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Communicate Ability Response Comments', qc.Q14_Comments__c, Trigger.oldMap.get(qc.Id).Q14_Comments__c));
            }
            if(qc.Perception_Focus_On_Customer_Feel__c != Trigger.oldMap.get(qc.Id).Perception_Focus_On_Customer_Feel__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Focus On Customer Fee', qc.Perception_Focus_On_Customer_Feel__c, Trigger.oldMap.get(qc.Id).Perception_Focus_On_Customer_Feel__c));
            }
            if(qc.Q16_Comments__c != Trigger.oldMap.get(qc.Id).Q16_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Focus On Customer Comments', qc.Q16_Comments__c, Trigger.oldMap.get(qc.Id).Q16_Comments__c));
            }
            if(qc.Perception_Patience_Degree__c != Trigger.oldMap.get(qc.Id).Perception_Patience_Degree__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Patience Degree', qc.Perception_Patience_Degree__c, Trigger.oldMap.get(qc.Id).Perception_Patience_Degree__c));
            }
            if(qc.Q17_Comments__c != Trigger.oldMap.get(qc.Id).Q17_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Patience Degree Comments', qc.Q17_Comments__c, Trigger.oldMap.get(qc.Id).Q17_Comments__c));
            }
            if(qc.Perception_JinYongYu__c != Trigger.oldMap.get(qc.Id).Perception_JinYongYu__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - JinYongYu', qc.Perception_JinYongYu__c, Trigger.oldMap.get(qc.Id).Perception_JinYongYu__c));
            }
            if(qc.Q18_Comments__c != Trigger.oldMap.get(qc.Id).Q18_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - JinYongYu Comments', qc.Q18_Comments__c, Trigger.oldMap.get(qc.Id).Q18_Comments__c));
            }
            if(qc.Perception_Hang_Up__c != Trigger.oldMap.get(qc.Id).Perception_Hang_Up__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Hang Up', qc.Perception_Hang_Up__c, Trigger.oldMap.get(qc.Id).Perception_Hang_Up__c));
            }
            if(qc.Q19_Comments__c != Trigger.oldMap.get(qc.Id).Q19_Comments__c)
            {
                QCHistorys.add(newQCHistory(qc.Id, 'Perception - Hang Up Comments', qc.Q19_Comments__c, Trigger.oldMap.get(qc.Id).Q19_Comments__c));
            }
        }
    }
    
    //Insert QC historys.
    if(QCHistorys.size() > 0)
    {
        try
        {
            insert QCHistorys;
        }
        catch(DMLException ex)
        {
            system.debug(ex);
        }
    }
    
    //Creates new QC historys.
    private QC_History__c newQCHistory(Id qcId, String label, String newValue, String oldValue)
    {
        qch = new QC_History__c();
        qch.QC__c = qcId;
        qch.User__c = UserInfo.getUserId();
        qch.Action__c = 'Changed ' + label + ' from <b>' + oldValue + '</b> to <b>' + newValue + '</b>';
        return qch;
    }
}