global class scheduledTimesheetEmail implements Schedulable{
   global void execute(SchedulableContext sc) {
      user u = [select Id, name, email from user where id = '00590000001K3ng' limit 1];
      
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {u.email};
      mail.setTemplateId('00X900000016ll3');
      mail.setToAddresses(toAddresses);
      mail.setSenderDisplayName('Salesforce Support');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}