/**
 * @author: silvansholla@gmail.com
 * @date: 12/1/2021
 *
 * MIT License
 *
 * Copyright (c) 2021 Sholla Silvan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@IsTest
public class MetadataTriggerManagerTest {

    public static Set<String> lastNamesSeen = new Set<String>();

    public class TestHandler implements AfterDelete, AfterInsert, AfterUndelete, AfterUpdate, BeforeDelete,
            BeforeInsert, BeforeUpdate {

        public void handleAfterDelete(List<Contact> oldList, Map<Id,sObject> oldMap) {
            handle(oldList);
        }

        public void handleAfterInsert(List<Contact> newList, Map<Id,sObject> newMap) {
            handle(newList);
        }

        public void handleAfterUndelete(List<Contact> newList, Map<Id,sObject> newMap) {
            handle(newList);
        }

        public void handleAfterUpdate(List<sObject> oldList, List<sObject> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
            handle(newList);
        }

        public void handleBeforeDelete(List<Contact> oldList, Map<Id,sObject> oldMap) {
            handle(oldList);
        }

        public void handleBeforeInsert(List<Contact> newList) {
            handle(newList);
        }


        public void handleBeforeUpdate(List<sObject> oldList, List<sObject> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap) {
            handle(newList);
        }

        private void handle(List<Contact> aList) {
            for(Contact c : aList) {
                MetaDataTriggerManagerTest.lastNamesSeen.add(c.LastName);
            }
        }
    }

    @IsTest
    public static void basic() {
        String mockMetaDataString = '';

        Map<String, List<Boolean>> events = new Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false},
                'AfterInsert' => new List<Boolean>{false, false, true, false, false},
                'AfterUndelete' => new List<Boolean>{false, false, false, false, true},
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
                'BeforeDelete' => new List<Boolean>{true, false, false, true, false},
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String event : events.keySet()) {
            mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + event + '", '
                    + '"sObject__c": "Contact", "Class_Name__c": "MetaDataTriggerManagerTest.TestHandler"},';
        }

        mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';

        MetadataTriggerManager.mockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<Trigger_Handler__mdt>.class);

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.sObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        for(String event : events.keySet()) {
            List<Boolean> flags = events.get(event);
            lastNamesSeen = new Set<String>();
            manager.handle(flags[0], flags[1], flags[2], flags[3], flags[4], contactList, contactList, null, null);

            System.assert(lastNamesSeen.contains(contactList[0].LastName));
        }

    }
    @IsTest
    public static void noSuchHandler() {
        String mockMetaDataString = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"Event__c": "AfterUpdate", '
                + '"sObject__c": "Contact", "Class_Name__c": "NoSuchClass"}]';

        MetadataTriggerManager.mockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<Trigger_Handler__mdt>.class);

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.sObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        try {
            manager.handle(false, true, false, false, false, contactList, contactList, null, null);
        } catch(MetadataTriggerManager.ClassNotFoundException e) {
            // expected this!
            return;
        }

        System.assert(false, 'Expected a ClassNotFoundException');
    }

    @IsTest
    public static void noHandlers() {
        MetadataTriggerManager.mockMetaData = new List<Trigger_Handler__mdt>();

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.sObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        manager.handle(false, true, false, false, false, contactList, contactList, null, null);
        // no result
    }

    @IsTest
    public static void noHandlersForThisEvent() {
        String mockMetaDataString = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"Event__c": "AfterUpdate", '
                + '"sObject__c": "Contact", "Class_Name__c": "NoSuchClass"}]';

        MetadataTriggerManager.mockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<Trigger_Handler__mdt>.class);

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.sObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        manager.handle(true, true, false, false, false, contactList, contactList, null, null);
        // no result
    }

    @IsTest
    public static void queryHandlers() {

        MetadataTriggerManager manager = new MetadataTriggerManager(Contact.sObjectType);

        String lastName = 'Simpson';

        List<Contact> contactList = new List<Contact>{new Contact(LastName = lastName)};

        manager.handle(false, true, false, false, false, contactList, contactList, null, null);
        // no result
    }
}