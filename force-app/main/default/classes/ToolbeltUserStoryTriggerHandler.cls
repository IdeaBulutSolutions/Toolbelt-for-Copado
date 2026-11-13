/**
 * Routes copado__User_Story__c trigger events to the Toolbelt features.
 * Every Toolbelt rule on User Story is called from here, so the order they run in is explicit.
 */
public with sharing class ToolbeltUserStoryTriggerHandler {

    public static void handle(
        System.TriggerOperation operation,
        List<copado__User_Story__c> newStories,
        Map<Id, copado__User_Story__c> oldStories
    ) {
        switch on operation {
            when BEFORE_INSERT {
                UserStoryTitleAddition.apply(newStories, null);
            }
            when BEFORE_UPDATE {
                UserStoryTitleAddition.apply(newStories, oldStories);
            }
        }
    }
}
