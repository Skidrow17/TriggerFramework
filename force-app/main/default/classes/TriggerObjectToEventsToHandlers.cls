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

public without sharing class TriggerObjectToEventsToHandlers {
    private Map<String, TriggerEventsToTriggerHandlers> typeToEventHandlers;

    public TriggerObjectToEventsToHandlers() {
        typeToEventHandlers = new Map<String, TriggerEventsToTriggerHandlers>();
    }

    public void putAll(List<Trigger_Handler__mdt> triggerHandlers) {
        for(Trigger_Handler__mdt thisTriggerHandler : triggerHandlers) {
            TriggerEventsToTriggerHandlers theseTriggerHandlers = typeToEventHandlers.get(thisTriggerHandler.sObject__c);

            if(theseTriggerHandlers == null) {
                theseTriggerHandlers = new TriggerEventsToTriggerHandlers();

                typeToEventHandlers.put(thisTriggerHandler.sObject__c, theseTriggerHandlers);
            }

            theseTriggerHandlers.put(thisTriggerHandler);
        }
    }

    public TriggerEventsToTriggerHandlers get(String sObjectName) {
        return typeToEventHandlers.get(sObjectName);
    }
}