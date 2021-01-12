global with sharing class AccountTriggerHandler implements AfterUpdate, AfterInsert {

    global void handleAfterUpdate(List<Account> oldList, List<Account> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {

        // Implement my trigger logic
        logic('Update');
    }

    global void handleAfterInsert(List<Account> newList, Map<Id,sObject> newMap) {

        // Implement my trigger logic
        logic('Insert');
    }

    private void logic(String event){
        System.debug('Triggers Logic on '+event);
    }

}