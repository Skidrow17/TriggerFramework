global without sharing class ContactTriggerHandler implements AfterUpdate {

    global void handleAfterUpdate(List<Contact> oldList, List<Contact> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {

        List<Account> accList = new List<Account>();

        for(Contact con : newList){
            if(con.AccountId != null && con.Fax != oldMap.get(con.Id).get('Fax')){
                Account newAcc = new Account();
                newAcc.Id = con.AccountId;
                newAcc.Fax = con.Fax;
                accList.add(newAcc);
            }
        }
        update accList;
    }

}