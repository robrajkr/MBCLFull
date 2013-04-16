/****************************************************************************************************
* Name: carcompare.cls
* Function:    Main class for car comparation module
* Author:       Jorry Chen
* Created Date: 2013-1-15
* Modify History:
* 
*****************************************************************************************************/

public class carcomparate {
    public List<Vehicle__c> vehicleList {get; set;}
    public List<Vehicle__c> compareList {get; set;}
    public List<SelectOption> options_Brand {get;}
    public List<SelectOption> options_Series {get;}
    public List<SelectOption> options_Models {get;}
    
    public carcomparate () {
        
    }
}