trigger ToolbeltUserStoryTrigger on copado__User_Story__c (before insert, before update) {
    ToolbeltUserStoryTriggerHandler.handle(Trigger.operationType, Trigger.new, Trigger.oldMap);
}
