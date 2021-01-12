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

public without sharing class MetadataTriggerManager {

    public class ClassNotFoundException extends Exception {}

    @TestVisible
    private static List<Trigger_Handler__mdt> mockMetadata;

    private static Set<String> skippedTriggers = new Set<String>(); 
    private TriggerEventsToTriggerHandlers theseEventsToTriggerHandlers;
    private static TriggerObjectToEventsToHandlers sObjectNameToEventsToTriggerHandlers =
            new TriggerObjectToEventsToHandlers();

    public MetadataTriggerManager() {
        if(Trigger.new != null) {
            init(Trigger.new.getSObjectType());
        } else {
            init(Trigger.old.getSObjectType());
        }
    }

    public MetadataTriggerManager(sObjectType objectType) {
        init(objectType);
    }

    public void init(sObjectType objectType) {
        String sObjectName = objectType.getDescribe().getName();

        theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(sObjectName);

        if(theseEventsToTriggerHandlers == null) {
            if(Test.isRunningTest() && mockMetadata != null) {
                sObjectNameToEventsToTriggerHandlers.putAll(mockMetadata);
            } else {
                sObjectNameToEventsToTriggerHandlers.putAll(
                [SELECT DeveloperName, NamespacePrefix, Event__c, sObject__c, Class_Name__c, Order__c, RunOnce__c
                FROM Trigger_Handler__mdt
                WHERE sObject__c = :sObjectName AND Active__c = true
                ORDER BY Order__c ASC]);
            }
            theseEventsToTriggerHandlers = sObjectNameToEventsToTriggerHandlers.get(objectType.getDescribe().getName());
        }
    }

    public static String triggerFlagsToString(boolean isBefore, boolean isUpdate, boolean isInsert, boolean isDelete, boolean isUndelete) {
        String returnVal = isBefore ? 'Before' : 'After';

        if(isInsert) {
            returnVal += 'Insert';
        } else if(isUpdate) {
            returnVal += 'Update';
        } else if(isDelete) {
            returnVal += 'Delete';
        } else {
            returnVal += 'Undelete';
        }

        return returnVal;
    }

    public void handle() {
        handle(Trigger.isBefore, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete, Trigger.isUndelete, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }

    public void handle(boolean isBefore, boolean isUpdate, boolean isInsert, boolean isDelete, boolean isUndelete, List<sObject> oldList, List<sObject> newList, Map<Id,sObject> oldMap, Map<Id,sObject> newMap ) {
        if(theseEventsToTriggerHandlers == null) {
            return;
        }
        String eventString = triggerFlagsToString(isBefore, isUpdate, isInsert, isDelete, isUndelete);
        List<Trigger_Handler__mdt> theseTriggerHandlers = theseEventsToTriggerHandlers.getTriggerHandlers(eventString);

        if(theseTriggerHandlers == null) {
            return;
        }

        for(Trigger_Handler__mdt thisTriggerHandler : theseTriggerHandlers) {

            if(skippedTriggers.contains(thisTriggerHandler.DeveloperName)) {
                continue;
            }

            if(thisTriggerHandler.RunOnce__c){
                skippedTriggers.add(thisTriggerHandler.DeveloperName);
            }
            
            Type handlerType = Type.forName(thisTriggerHandler.NamespacePrefix, thisTriggerHandler.Class_Name__c);
            Double start = System.Now().millisecond();
            Integer numberOfQueries = Limits.getQueries();
            Integer numberOfDMLS = Limits.getDmlRows();

            System.debug('Trigger : '+thisTriggerHandler.DeveloperName+ ' Start');
            if(handlerType == null) {
                throw new ClassNotFoundException('MetaDataTriggerManager: handler class not found for ' + thisTriggerHandler);
            } else {
                if(isBefore) {
                    if(isUpdate) {
                        ((BeforeUpdate)handlerType.newInstance()).handleBeforeUpdate(oldList, newList, oldMap, newMap);
                    } else if(isInsert) {
                        ((BeforeInsert)handlerType.newInstance()).handleBeforeInsert(newList);
                    } else if(isDelete) {
                        ((BeforeDelete)handlerType.newInstance()).handleBeforeDelete(oldList, oldMap);
                    }
                } else {
                    if(isUpdate) {
                        ((AfterUpdate)handlerType.newInstance()).handleAfterUpdate(oldList, newList, oldMap, newMap);
                    } else if(isInsert) {
                        ((AfterInsert)handlerType.newInstance()).handleAfterInsert(newList, newMap);
                    } else if(isDelete) {
                        ((AfterDelete)handlerType.newInstance()).handleAfterDelete(oldList, oldMap);
                    } else if(isUndelete) {
                        ((AfterUndelete)handlerType.newInstance()).handleAfterUndelete(newList, newMap);
                    }
                }
            }
            System.debug('Trigger : '+thisTriggerHandler.DeveloperName + ' End '
            + ' / Time Elapsed In Seconds : '+((System.Now().millisecond() - start) / 1000)
            + ' / Number Of Queries : '+(Limits.getQueries() - numberOfQueries)
            + ' / Number Of DML : '+(Limits.getDmlRows() - numberOfDMLS));
        }
    }

    public static void skipTrigger(String triggerName, Boolean skip){
        if(skip == true){
            skippedTriggers.add(triggerName);
        } else{
            skippedTriggers.remove(triggerName);
        }
    }
}