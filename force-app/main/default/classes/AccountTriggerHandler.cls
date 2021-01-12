global with sharing class AccountTriggerHandler implements AfterUpdate, AfterInsert {

    global void handleAfterUpdate(List<Account> oldList, List<Account> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {

        // Implement my trigger logic
        logic(newList);
    }

    global void handleAfterInsert(List<Account> newList, Map<Id,sObject> newMap) {

        // Implement my trigger logic
        logic(newList);
    }

    private void logic(List<Account> accList){
        System.debug('Hello World = '+accList);
    }

}