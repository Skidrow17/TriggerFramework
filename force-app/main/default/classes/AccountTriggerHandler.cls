global without sharing class AccountTriggerHandler implements AfterUpdate, AfterInsert {

    global void handleAfterUpdate(List<Account> oldList, List<Account> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {

        List<Account> accList = new List<Account>();

        for(Account acc : oldList){
            Account newAcc = new Account();
            newAcc.Id = acc.Id;
            newAcc.Type = 'Prospect';
            accList.add(newAcc);
        }

        //MetadataTriggerManager.skipTrigger('AccountTriggerHandlerAfterUpdate',true);
        update accList;
        //MetadataTriggerManager.skipTrigger('AccountTriggerHandlerAfterUpdate',false);

    }

    global void handleAfterInsert(List<Account> newList, Map<Id,sObject> newMap) {
        // Implement my trigger logic
    }

}